{$INCLUDE rl.inc}
unit rlapplication;
interface

uses SysUtils, vapp, vrlapp, viorl, vluasystem, rlgame, rlpersistence, rlaudio, rlviews;

// Owns reusable services and one content generation, with one active Session.
type TGameRuntime = class( TRLRuntime )
  private
    FSession     : TGameSession;
    FPersistence : TPersistence;
    FAudio       : TGameAudio;
    procedure LoadCells;
  protected
    function CreateIO : TIORL; override;
    function CreateLua : TLuaSystem; override;
    procedure PrepareGameData; override;
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

uses vos, vioevent, vdebug, rlconfig, rlglobal, rlui, rllua;

function TGameRuntime.CreateIO : TIORL;
begin
  // Configuration is already transferred; launch globals were resolved by
  // ApplyOptions before the inherited Runtime constructor calls this factory.
  UI := TGameUI.Create( TGameConfig( Configuration ) );
  Result := UI;
end;

constructor TGameRuntime.Create( const aPaths : TGamePaths; var aConfiguration : TObject );
begin
  inherited Create( aPaths, aConfiguration );
  // The former TGame used TRNG.Create, which randomizes instead of seeding zero.
  GameRNG.Randomize;
end;

function TGameRuntime.CreateLua : TLuaSystem;
begin
  Result := TGameLua.Create( TGameConfig( Configuration ) );
end;

procedure TGameRuntime.PrepareGameData;
begin
  FPersistence := TPersistence.Create( Paths.ScorePath );
  if TGameConfig( Configuration ).Configure( 'sound', 'NONE' ) <> 'NONE' then
    FAudio := TGameAudio.Create( TGameConfig( Configuration ), IO.VisualRNG, SoundPath );
  TGameUI( IO ).SetAudio( FAudio );
end;

procedure TGameRuntime.InitializeGameData;
begin
  TGameLua( Lua ).Initialize( Paths.DataPath );
  LoadCells;
  if GodMode then IO.RegisterDebugConsole( VKEY_F1 );
end;

function TGameRuntime.RunGame : TVRunResult;
var iChoice : TGameMenuResult;
begin
  Result := VRR_QUIT;
  try
    IO.HideCursor;
    UI.PlayMusic( 'music/dintro.wav' );
    IO.RunLayer( TIntroScreen.Create );
    repeat
      IO.RunLayer( TMainMenuScreen.Create( FPersistence, iChoice ) );
      if iChoice = GMR_QUIT then
      begin
        IO.RunLayer( TOutroScreen.Create );
        Exit;
      end;
      FSession := TGameSession.Create( Self, FPersistence );
      Game := FSession;
      if FSession.Execute( iChoice = GMR_LOAD ) = GSR_LOAD_FAILED then
        Log( 'Load failed; returning to main menu.' );
      // Exceptional Sessions stay alive for the outer crash-save handler.
      UI.UnPrepare;
      IO.Clear;
      FreeAndNil( FSession );
      UI.HaltSound;
      UI.PlayMusic( 'music/dintro.wav' );
    until False;
  except
    on E : EGameProcessQuit do Result := VRR_QUIT;
  end;
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
var iCell : Integer;
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
  for iCell := Low( CellData ) to High( CellData ) do
    CellData[ iCell ] := Default( TCellData );
  CELL_FLOOR := 0;
  CELL_STAIR_UP := 0;
  CELL_TOWN_PORTAL := 0;
end;

destructor TGameRuntime.Destroy;
begin
  ShutdownGameData;
  inherited Destroy;
end;

procedure TGameRuntime.LoadCells;
var CellCount : Word;
    Count,C   : Word;
begin
  for Count := 1 to 255 do CellData[Count].id := '';

  CellCount := Lua.Get(['cells','__counter']);

  for Count := 1 to CellCount do
  with Lua.GetTable( ['cells', Count] ) do
  try
    with CellData[Count] do
    begin
      id      := GetString('id');

      flags   := GetFlags('flags');
      color   := GetInteger('color');
      pic     := GetString('pic')[1];
      if not Option_Graphics then
        pic     := GetString('piclow')[1];
      name    := GetString('name');
      cost    := GetFloat('cost',1.0);
      Hooks := [];
      for C := Low( CellHookNames ) to High( CellHookNames ) do
        if isFunction( CellHookNames[C] ) then
          Include( Hooks, C );
    end;
  finally
    Free;
  end;

  CELL_FLOOR         := Lua.Defines['floor'];
  CELL_STAIR_UP      := Lua.Defines['stairs_up'];

  CELL_TOWN_PORTAL   := Lua.Defines['shimmering_portal'];
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
