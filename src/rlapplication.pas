{$INCLUDE rl.inc}
unit rlapplication;
interface

uses sysutils, vapp, vrlapp, viorl, vlua, rlgame, rlpersistence, rlaudio, rlviews;

// Owns reusable services and one content generation, with one active Session.
type TGameRuntime = class( TRLRuntime )
  private
    FSession     : TGameSession;
    FPersistence : TPersistence;
    FAudio       : TGameAudio;
  protected
    function CreateIO : TIORL; override;
    function CreateLua : TLua; override;
    function PrepareGameData : Boolean; override;
    procedure InitializeGameData; override;
    function RunGame : TVRunResult; override;
    procedure ShutdownGameData; override;
  public
    constructor Create( const aPaths : TGamePaths; var aConfiguration : TObject ); override;
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

uses vos, vioevent, vdebug, rlconfiguration, rlconfig, rlglobal, rlui, rllua;

function TGameRuntime.CreateIO : TIORL;
begin
  // Configuration and Paths are already transferred, and ApplyOptions has
  // resolved the launch choices before the inherited constructor calls this.
  Result := TGameUI.Create( TGameConfiguration( Configuration ), Paths.DataPath );
end;

constructor TGameRuntime.Create( const aPaths : TGamePaths; var aConfiguration : TObject );
begin
  inherited Create( aPaths, aConfiguration );
  // The former TGame used TRNG.Create, which randomizes instead of seeding zero.
  GameRNG.Randomize;
end;

function TGameRuntime.CreateLua : TLua;
begin
  Result := TGameLua.Create( TGameConfiguration( Configuration ).LuaConfig, TGameUI( IO ) );
end;

function TGameRuntime.PrepareGameData : Boolean;
var iConfiguration : TGameConfiguration;
begin
  Result := True;
  iConfiguration := TGameConfiguration( Configuration );
  FPersistence := TPersistence.Create( Paths.ScorePath );
  if iConfiguration.LuaConfig.Configure( 'sound', 'NONE' ) <> 'NONE' then
    FAudio := TGameAudio.Create( iConfiguration.LuaConfig, IO.VisualRNG, iConfiguration.SoundPath );
  TGameUI( IO ).SetAudio( FAudio );
end;

procedure TGameRuntime.InitializeGameData;
begin
  TGameLua( FLua ).Initialize;
  // Runtime outlives Lua; the natives resolve the Session active at each call.
  // Natives register before scripts run: core.lua guards globals.
  TGameSession.RegisterLuaAPI( FLua, @FSession );
  TGameLua( FLua ).LoadData( Paths.DataPath );
  TGameLua( FLua ).LoadCells( TGameUI( IO ).GraphicsMode );
  if GodMode then RegisterDebugConsole( VKEY_F1 );
end;

function TGameRuntime.RunGame : TVRunResult;
var iChoice : TGameMenuResult;
    iUI     : TGameUI;
begin
  Result := VRR_QUIT;
  iUI := TGameUI( IO );
  try
    iUI.HideCursor;
    iUI.PlayMusic( 'music/dintro.wav' );
    iUI.RunLayer( TIntroScreen.Create );
    repeat
      iUI.RunLayer( TMainMenuScreen.Create( FPersistence,
        FileExists( Paths.WritePath + 'save' ), iChoice ) );
      if iChoice = GMR_QUIT then
      begin
        iUI.RunLayer( TOutroScreen.Create );
        Break;
      end;
      FSession := TGameSession.Create( Self, FPersistence );
      if FSession.Execute( iChoice = GMR_LOAD ) = GSR_LOAD_FAILED then
        Log( 'Load failed; returning to main menu.' );
      // Exceptional Sessions stay alive for the outer crash-save handler.
      iUI.UnPrepare;
      iUI.Clear;
      FreeAndNil( FSession );
      iUI.HaltSound;
      iUI.PlayMusic( 'music/dintro.wav' );
    until False;
  except
    on E : EGameProcessQuit do Result := VRR_QUIT;
  end;
  iUI.UnPrepare;
  iUI.Clear;
  if not TGameConfiguration( Configuration ).WriteSettings then
    Log( 'Could not save settings on shutdown.' );
end;

procedure TGameRuntime.HandleGameException( aException : Exception );
begin
  if FSession = nil then Exit;
  if FSession.Ended or not FSession.CanSave then Exit;
  try
    FSession.Save;
  except
    on E : Exception do
      Log( 'Crash save failed: ' + E.Message );
  end;
end;

procedure TGameRuntime.ShutdownGameData;
begin
  if IO <> nil then
  begin
    TGameUI( IO ).UnPrepare;
    IO.Clear;
  end;
  FreeAndNil( FSession );
  if IO <> nil then TGameUI( IO ).SetAudio( nil );
  FreeAndNil( FAudio );
  FreeAndNil( FPersistence );
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
end;

procedure TGameApplication.BeforeConfiguration( var aPaths : TGamePaths );
begin
  GodMode := HasOption( 'god' );
end;

function TGameApplication.CreateConfiguration( var aPaths : TGamePaths ) : TObject;
var iConfiguration : TGameConfiguration;
    iConfig : TGameConfig;
begin
  // The godmode.lua lookup precedes the Lua and command-line DataPath overrides.
  iConfiguration := TGameConfiguration.Create( aPaths.ConfigurationPath,
    aPaths.SettingsPath, aPaths.DataPath + 'godmode.lua' );
  iConfig := iConfiguration.LuaConfig;
  try
    aPaths.DataPath := iConfig.Configure( 'DataPath', aPaths.DataPath );
    aPaths.WritePath := iConfig.Configure( 'WritePath', aPaths.WritePath );
    aPaths.ScorePath := iConfig.Configure( 'ScorePath', aPaths.ScorePath );
    iConfiguration.SoundPath := iConfig.Configure( 'SoundPath',
      aPaths.ResourcePath + 'sound' + PathDelim );
    Result := iConfiguration;
  except
    iConfiguration.Free;
    raise;
  end;
end;

procedure TGameApplication.ApplyOptions;
var iConfiguration : TGameConfiguration;
    iLaunch        : TGameLaunchOptions;
begin
  iConfiguration := TGameConfiguration( Configuration );
  if HasOption( 'datapath' ) then FPaths.DataPath := GetOptionValue( 'datapath' );
  if HasOption( 'writepath' ) then FPaths.WritePath := GetOptionValue( 'writepath' );
  if HasOption( 'scorepath' ) then FPaths.ScorePath := GetOptionValue( 'scorepath' );
  if HasOption( 'soundpath' ) then iConfiguration.SoundPath := GetOptionValue( 'soundpath' );
  iLaunch := iConfiguration.Launch;
  iLaunch.HasName := HasOption( 'name' );
  if iLaunch.HasName then iLaunch.Name := GetOptionValue( 'name' );
  iLaunch.ForceConsole := HasOption( 'console' );
  iLaunch.ForceGraphics := HasOption( 'graphics' );
  if HasOption( 'fullscreen' ) then iLaunch.Fullscreen := 1;
  if HasOption( 'windowed' ) then iLaunch.Fullscreen := 0;
  iConfiguration.Launch := iLaunch;

  FPaths.Normalize;
  if FPaths.ScorePath = '' then FPaths.ScorePath := FPaths.WritePath;
  FPaths.DeriveDiagnostics;
  if iConfiguration.SoundPath <> '' then
    iConfiguration.SoundPath := IncludeTrailingPathDelimiter( iConfiguration.SoundPath );
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
