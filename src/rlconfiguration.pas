{$INCLUDE rl.inc}
unit rlconfiguration;
interface

uses vbindings, vioevent, vconfiguration, rlconfig, rlbindings;

const GAME_CONFIGURATION_GROUP_DISPLAY  = 'display';
      GAME_CONFIGURATION_GROUP_GAMEPLAY = 'gameplay';
      GAME_CONFIGURATION_GROUP_AUDIO    = 'audio';

type TGameConfiguration = class( TConfigurationManager )
  constructor Create( const aConfigurationPath, aSettingsPath : AnsiString );
  procedure ApplyLiveSettings;
  procedure LoadBindings( aGame, aUI : TBindingContext );
  procedure ResetValues;
  function ReadSettings : Boolean;
  function WriteSettings : Boolean;
  destructor Destroy; override;
private
  FLuaConfig         : TGameConfig;
  FNameOverridden    : Boolean;
  FGameKeyBindings   : TGameBindingCatalog;
  FUIKeyBindings     : TGameBindingCatalog;
  FRunModifier       : TIntegerConfigurationEntry;
  FAttackModifier    : TIntegerConfigurationEntry;
  FSettingsPath      : AnsiString;
public
  property NameOverridden  : Boolean read FNameOverridden write FNameOverridden;
  property LuaConfig       : TGameConfig                 read FLuaConfig;
  property GameKeyBindings : TGameBindingCatalog        read FGameKeyBindings;
  property UIKeyBindings   : TGameBindingCatalog        read FUIKeyBindings;
  property RunModifier     : TIntegerConfigurationEntry read FRunModifier;
  property AttackModifier  : TIntegerConfigurationEntry read FAttackModifier;
  property SettingsPath    : AnsiString                  read FSettingsPath;
end;

implementation

uses SysUtils, vutil, vdebug, rlglobal;

constructor TGameConfiguration.Create( const aConfigurationPath,
  aSettingsPath : AnsiString );
var iDisplayGroup  : TConfigurationGroup;
    iMovementGroup : TConfigurationGroup;
    iGroup         : TConfigurationGroup;
begin
  inherited Create;
  FSettingsPath := aSettingsPath;

  iDisplayGroup := AddGroup( GAME_CONFIGURATION_GROUP_DISPLAY );
  iDisplayGroup.AddToggle( 'graphics', True ).SetName( 'Graphical ASCII' );
  iDisplayGroup.AddToggle( 'fullscreen', True ).SetName( 'Fullscreen' );
  iDisplayGroup.AddInteger( 'console_x', 100 ).SetRange( 80, 240 ).SetName( 'Columns' );
  iDisplayGroup.AddInteger( 'console_y', 33 ).SetRange( 25, 120 ).SetName( 'Rows' );
  iDisplayGroup.AddInteger( 'screen_x', 1024 ).SetRange( 640, 16384 ).SetName( 'Window width' );
  iDisplayGroup.AddInteger( 'screen_y', 768 ).SetRange( 480, 16384 ).SetName( 'Window height' );

  iGroup := AddGroup( GAME_CONFIGURATION_GROUP_GAMEPLAY );
  iGroup.AddInteger( 'run_delay', 10 ).SetRange( 0, 1000, 10 ).SetName( 'Run delay (ms)' );
  iGroup.AddToggle( 'reveal_town', False ).SetName( 'Reveal town' );
  iGroup.AddString( 'always_name', '' ).SetName( 'Default player name' );

  iGroup := AddGroup( GAME_CONFIGURATION_GROUP_AUDIO );
  iGroup.AddToggle( 'walk_sound', True ).SetName( 'Walking sound' );
  iGroup.AddInteger( 'sound_volume', 100 ).SetRange( 0, 100, 5 ).SetName( 'Sound volume' );
  iGroup.AddInteger( 'music_volume', 100 ).SetRange( 0, 100, 5 ).SetName( 'Music volume' );

  FGameKeyBindings := TGameBindingCatalog.Create( GameKeyBindingInfo );
  iMovementGroup := AddGroup( GAME_BINDING_GROUP_MOVEMENT );

  FRunModifier := iMovementGroup.AddInteger( 'input_run_modifier', Ord( GMM_SHIFT ) );
  FRunModifier.SetName( 'Run modifier' );
  FRunModifier.SetDescription( 'Hold this modifier with a movement key to run.' );

  FAttackModifier := iMovementGroup.AddInteger( 'input_attack_modifier', Ord( GMM_CTRL ) );
  FAttackModifier.SetName( 'Attack modifier' );
  FAttackModifier.SetDescription( 'Hold this modifier with a movement key to attack in place.' );

  FGameKeyBindings.RegisterGroup( iMovementGroup, GAME_BINDING_GROUP_MOVEMENT );
  FGameKeyBindings.RegisterGroup( AddGroup( GAME_BINDING_GROUP_ACTIONS ), GAME_BINDING_GROUP_ACTIONS );
  FGameKeyBindings.RegisterGroup( AddGroup( GAME_BINDING_GROUP_ITEMS ), GAME_BINDING_GROUP_ITEMS );
  FGameKeyBindings.ValidateRegistration;

  FUIKeyBindings := TGameBindingCatalog.Create( UIKeyBindingInfo );
  FUIKeyBindings.RegisterGroup( AddGroup( UI_KEY_BINDING_GROUP ), UI_KEY_BINDING_GROUP );
  FUIKeyBindings.ValidateRegistration;

  FLuaConfig := TGameConfig.Create( aConfigurationPath );

  if (FSettingsPath <> '') and FileExists( FSettingsPath )
    then ReadSettings
    else if FSettingsPath <> ''
      then WriteSettings;
  ApplyLiveSettings;
  Option_Graphics := GetBoolean( 'graphics' );
  Option_FullScreen := GetBoolean( 'fullscreen' );
end;

procedure TGameConfiguration.LoadBindings( aGame, aUI : TBindingContext );
var iKey : TIOKeyCode;
    procedure AddModifier( aModifier, aOffset : Integer );
    const Masks : array[ TGameMovementModifier ] of TIOKeyCode =
      ( 0, IOKeyCodeShiftMask, IOKeyCodeAltMask, IOKeyCodeCtrlMask );
    var iAction : TBindingAction;
        iChord, iMask : TIOKeyCode;
    begin
      iMask := Masks[ TGameMovementModifier( aModifier ) ];
      if iMask = 0 then Exit;
      for iAction := COMMAND_WALKNORTH to COMMAND_WALKSW do
      begin
        iChord := aGame.GetKey( iAction );
        if iChord = 0 then Continue;
        if (iChord and iMask) <> 0 then
        begin
          Log( LOGERROR, 'Movement binding already uses its modifier: ' + IOKeyCodeToString( iChord ) );
          Continue;
        end;
        iChord := iChord or iMask;
        if aGame.ResolveKey( iChord ) = BINDING_NONE then
          aGame.BindKey( iChord, iAction + aOffset )
        else if aGame.ResolveKey( iChord ) <> iAction + aOffset then
          Log( LOGERROR, 'Explicit binding overrides movement chord: ' + IOKeyCodeToString( iChord ) );
      end;
    end;
begin
  aGame.Clear;
  if FLuaConfig.TableExists( 'Keybindings' ) then
    FLuaConfig.LoadKeybindings( aGame, 'Keybindings' );
  // Only function bindings belong to expert Lua configuration.
  for iKey := 1 to IOKeyCodeMax do
    if aGame.ResolveKey( iKey ) <> BINDING_FORWARD_LUA then
      aGame.BindKey( iKey, BINDING_NONE );
  if GodMode then FLuaConfig.LoadKeybindings( aGame, 'godkey' );
  aGame.LoadKeys( FGameKeyBindings );
  AddModifier( FRunModifier.Value, 10 );
  AddModifier( FAttackModifier.Value, 20 );
  if (aGame.GetKey( COMMAND_WAIT ) = VKEY_PERIOD) and
     (aGame.ResolveKey( VKEY_CENTER ) = BINDING_NONE) then
    aGame.BindKey( VKEY_CENTER, COMMAND_WAIT );
  aUI.Clear;
  aUI.LoadKeys( FUIKeyBindings );
end;

procedure TGameConfiguration.ResetValues;
var iGroup : TConfigurationGroup;
    iEntry : TConfigurationEntry;
begin
  for iGroup in Groups do
    for iEntry in iGroup.Entries do iEntry.Reset;
end;

procedure TGameConfiguration.ApplyLiveSettings;
begin
  Option_RunDelay := GetInteger( 'run_delay' );
  Option_TownReveal := GetBoolean( 'reveal_town' );
  Option_WalkSound := GetBoolean( 'walk_sound' );
  if not FNameOverridden then Option_AlwaysName := GetString( 'always_name' );
end;

function TGameConfiguration.ReadSettings : Boolean;
var iGroup : TConfigurationGroup;
    iEntry : TConfigurationEntry;
begin
  ResetValues;
  Result := inherited Read( FSettingsPath );
  if Result then
    Result := FGameKeyBindings.ValuesValid and FUIKeyBindings.ValuesValid( 255 ) and
      ( FRunModifier.Value >= Ord( Low( TGameMovementModifier ) ) ) and
      ( FRunModifier.Value <= Ord( High( TGameMovementModifier ) ) ) and
      ( FAttackModifier.Value >= Ord( Low( TGameMovementModifier ) ) ) and
      ( FAttackModifier.Value <= Ord( High( TGameMovementModifier ) ) ) and
      ( ( FRunModifier.Value = Ord( GMM_NONE ) ) or
        ( FRunModifier.Value <> FAttackModifier.Value ) );
  for iGroup in Groups do
    for iEntry in iGroup.Entries do
      if ( iEntry is TIntegerConfigurationEntry ) and ( iEntry.Name <> '' ) then
        with iEntry as TIntegerConfigurationEntry do
          if Max > Min then Result := Result and ( Value >= Min ) and ( Value <= Max );
  if not Result then
  begin
    ResetValues;
    Log( LOGERROR, 'Invalid settings; source defaults restored.' );
  end;
end;

function TGameConfiguration.WriteSettings : Boolean;
begin
  if FSettingsPath = '' then Exit( False );
  Result := Write( FSettingsPath );
end;

destructor TGameConfiguration.Destroy;
begin
  FreeAndNil( FUIKeyBindings );
  FreeAndNil( FGameKeyBindings );
  FreeAndNil( FLuaConfig );
  inherited Destroy;
end;

end.
