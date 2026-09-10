{$INCLUDE rl.inc}
unit rlapplication;
interface

uses SysUtils, vapp, vrlapp, viorl, vluasystem, rlgame;

// Stage 1 adapter: owns IO, Lua and configuration around one legacy TGame.
// TGame still owns its randomized gameplay RNG and playthrough services.
// Replace this adapter with Runtime/Session ownership in Stage 2.
type TGameRuntime = class( TRLRuntime )
  private
    FLegacyGame : TGame;
    FPrepared   : Boolean;
  protected
    function CreateIO : TIORL; override;
    function CreateLua : TLuaSystem; override;
    function RunGame : TVRunResult; override;
    procedure ShutdownGameData; override;
  public
    destructor Destroy; override;
    procedure HandleGameException( aException : Exception ); override;
  end;

// Owns process options, paths, diagnostics and one Runtime.
type TGameApplication = class( TRLApplication )
  protected
    procedure DefineOptions; override;
    procedure ValidateOptions; override;
    procedure DiscoverPaths( var aPaths : TGamePaths ); override;
    procedure BeforeConfiguration( var aPaths : TGamePaths ); override;
    function CreateConfiguration( var aPaths : TGamePaths ) : TObject; override;
    procedure ApplyOptions; override;
    procedure BeforeDiagnostics; override;
    function CreateRuntime( const aPaths : TGamePaths;
      var aConfiguration : TObject ) : TRLRuntime; override;
  end;

implementation

uses vos, vuid, vdebug, rlconfig, rlglobal, rlui;

function TGameRuntime.CreateIO : TIORL;
begin
  // Configuration is already transferred; launch globals were resolved by
  // ApplyOptions before the inherited Runtime constructor calls this factory.
  UI := TGameUI.Create( TGameConfig( Configuration ) );
  Result := UI;
end;

function TGameRuntime.CreateLua : TLuaSystem;
begin
  // The legacy constructor still loads Lua after publishing its randomized RNG.
  // On success the shared Runtime takes sole ownership of that Lua system.
  FLegacyGame := TGame.Create;
  Result := FLegacyGame.Lua;
end;

function TGameRuntime.RunGame : TVRunResult;
begin
  FLegacyGame.Prepare;
  FPrepared := True;
  FLegacyGame.Run;
  Result := VRR_QUIT;
end;

procedure TGameRuntime.HandleGameException( aException : Exception );
begin
  // Preserve the old Run-only crash-save boundary. Preparation failures do not
  // have a valid playthrough, and must not try to save a partially built player.
  if not FPrepared or GameEnd or ( FLegacyGame = nil ) then Exit;
  if ( FLegacyGame.Player = nil ) or ( FLegacyGame.Level = nil ) or
     ( UIDs = nil ) then Exit;
  try
    FLegacyGame.Save;
  except
    on E : Exception do
      Log( 'Crash save failed: ' + E.Message );
  end;
end;

procedure TGameRuntime.ShutdownGameData;
begin
  FPrepared := False;
  if IO <> nil then
  begin
    TGameUI( IO ).UnPrepare;
    IO.Clear;
  end;
  FreeAndNil( FLegacyGame );
  // The legacy Prepare/Load paths still register this store with Systems.
  // Freeing it detaches it, after the legacy node tree has been destroyed.
  FreeAndNil( UIDs );
end;

destructor TGameRuntime.Destroy;
begin
  ShutdownGameData;
  inherited Destroy;
end;

procedure TGameApplication.DefineOptions;
begin
  AddFlag( 'god', #0, 'Enable god mode and loose Lua from the working directory.' );
  AddFlag( 'console', #0, 'Force native console mode.' );
  AddFlag( 'graphics', #0, 'Force graphical ASCII mode; takes precedence over --console.' );
  AddFlag( 'fullscreen', #0, 'Force fullscreen graphics.' );
  AddFlag( 'windowed', #0, 'Force windowed graphics; takes precedence over --fullscreen.' );
  AddValueOption( 'name', #0, 'PLAYER_NAME', 'Override the configured player name.' );
  AddValueOption( 'soundpath', #0, 'DIR', 'Override the loose audio directory.' );
  AddValueOption( 'datapath', #0, 'DIR', 'Alias for --data-path.' );
  AddValueOption( 'writepath', #0, 'DIR', 'Alias for --write-path.' );
  AddValueOption( 'scorepath', #0, 'DIR', 'Alias for --score-path.' );
end;

procedure TGameApplication.ValidateOptions;
begin
  if HasOption( 'datapath' ) and HasOption( 'data-path' ) then
    FailOption( 'Use only one of --datapath and --data-path.' )
  else if HasOption( 'writepath' ) and HasOption( 'write-path' ) then
    FailOption( 'Use only one of --writepath and --write-path.' )
  else if HasOption( 'scorepath' ) and HasOption( 'score-path' ) then
    FailOption( 'Use only one of --scorepath and --score-path.' );
end;

procedure TGameApplication.DiscoverPaths( var aPaths : TGamePaths );
begin
  // Preserve the original platform policy, including working-directory paths
  // on Unix outside a macOS application bundle.
  aPaths.ExecutablePath := ExtractFilePath( ExeName );
  aPaths.ResourcePath := '';
  {$IFDEF DARWIN}
  {$IFDEF OSX_APP_BUNDLE}
  aPaths.ResourcePath := GetResourcesPath;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF WINDOWS}
  aPaths.ResourcePath := aPaths.ExecutablePath;
  {$ENDIF}
  aPaths.ConfigurationPath := aPaths.ResourcePath + 'config.lua';
  aPaths.SettingsPath := aPaths.ResourcePath + 'settings.lua';
  aPaths.DataPath := aPaths.ResourcePath;
  aPaths.WritePath := aPaths.ResourcePath;
  aPaths.ScorePath := '';
  SoundPath := aPaths.ResourcePath + 'sound' + PathDelim;
end;

procedure TGameApplication.BeforeConfiguration( var aPaths : TGamePaths );
begin
  GodMode := HasOption( 'god' );
  ConfigurationPath := aPaths.ConfigurationPath;
  // The existing godmode.lua lookup precedes Lua/CLI DataPath overrides.
  DataPath := aPaths.DataPath;
end;

function TGameApplication.CreateConfiguration( var aPaths : TGamePaths ) : TObject;
var iConfig : TGameConfig;
begin
  iConfig := TGameConfig.Create( aPaths.ConfigurationPath );
  try
    aPaths.DataPath := iConfig.Configure( 'DataPath', aPaths.DataPath );
    aPaths.WritePath := iConfig.Configure( 'WritePath', aPaths.WritePath );
    aPaths.ScorePath := iConfig.Configure( 'ScorePath', aPaths.ScorePath );
    SoundPath := iConfig.Configure( 'SoundPath', SoundPath );
    Option_AlwaysName := iConfig.Configure( 'always_name', Option_AlwaysName );
    Option_Graphics := iConfig.Configure( 'graphics', Option_Graphics );
    Option_FullScreen := iConfig.Configure( 'fullscreen', Option_FullScreen );
    Result := iConfig;
  except
    iConfig.Free;
    raise;
  end;
end;

procedure TGameApplication.ApplyOptions;
begin
  if HasOption( 'datapath' ) then FPaths.DataPath := GetOptionValue( 'datapath' );
  if HasOption( 'writepath' ) then FPaths.WritePath := GetOptionValue( 'writepath' );
  if HasOption( 'scorepath' ) then FPaths.ScorePath := GetOptionValue( 'scorepath' );
  if HasOption( 'soundpath' ) then SoundPath := GetOptionValue( 'soundpath' );
  if HasOption( 'name' ) then Option_AlwaysName := GetOptionValue( 'name' );
  if HasOption( 'console' ) then Option_Graphics := False;
  if HasOption( 'graphics' ) then Option_Graphics := True;
  if HasOption( 'fullscreen' ) then Option_FullScreen := True;
  if HasOption( 'windowed' ) then Option_FullScreen := False;

  FPaths.Normalize;
  if FPaths.ScorePath = '' then FPaths.ScorePath := FPaths.WritePath;
  FPaths.DeriveDiagnostics;
  if SoundPath <> '' then SoundPath := IncludeTrailingPathDelimiter( SoundPath );
  DataPath := FPaths.DataPath;
  WritePath := FPaths.WritePath;
  ScorePath := FPaths.ScorePath;
end;

procedure TGameApplication.BeforeDiagnostics;
begin
  FPaths.LogPath := FPaths.WritePath + 'log.txt';
end;

function TGameApplication.CreateRuntime( const aPaths : TGamePaths;
  var aConfiguration : TObject ) : TRLRuntime;
begin
  Result := TGameRuntime.Create( aPaths, aConfiguration );
end;

end.
