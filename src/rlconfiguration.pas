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
  procedure ResetGroup( const aGroupID : AnsiString );
  function CatalogForEntry( const aID : AnsiString ) : TBindingCatalog;
  function SnapshotValues : TConfigurationValueMap;
  procedure RestoreValues( aValues : TConfigurationValueMap );
  function ValuesValid : Boolean;
  function ReadSettings : Boolean;
  function WriteSettings : Boolean;
  destructor Destroy; override;
private
  FLuaConfig         : TGameConfig;
  FNameOverridden    : Boolean;
  FFullscreenOverride : Integer;
  FGameKeyBindings   : TGameBindingCatalog;
  FUIKeyBindings     : TGameBindingCatalog;
  FRunModifier       : TIntegerConfigurationEntry;
  FAttackModifier    : TIntegerConfigurationEntry;
  FSettingsPath      : AnsiString;
public
  property FullscreenOverride : Integer read FFullscreenOverride write FFullscreenOverride;
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
  FFullscreenOverride := -1;

  iDisplayGroup := AddGroup( GAME_CONFIGURATION_GROUP_DISPLAY );
  iDisplayGroup.AddInteger( 'display_mode', 0 ).SetName( 'Resolution' )
    .SetDescription( 'Native desktop size or a window resolution.' );
  iDisplayGroup.AddInteger( 'screen_width', 0 );
  iDisplayGroup.AddInteger( 'screen_height', 0 );
  iDisplayGroup.AddToggle( 'fullscreen', True ).SetName( 'Fullscreen' )
    .SetDescription( 'Use native desktop fullscreen. Launch flags override this setting.' );
  iDisplayGroup.AddInteger( 'font_multiplier', 0 ).SetRange( 0, 255 ).SetName( 'Font size multiplier' )
    .SetDescription( 'Automatic uses the largest font that fits at least 80x25 characters.' );
  iDisplayGroup.AddToggle( 'ascii_mode', False ).SetName( 'ASCII mode' )
    .SetDescription( 'Use the native text terminal. Requires restart.' );
  iDisplayGroup.AddInteger( 'ascii_width', 100 ).SetRange( 80, 240 ).SetName( 'ASCII columns' )
    .SetDescription( 'Native terminal columns. Requires restart.' );
  iDisplayGroup.AddInteger( 'ascii_height', 30 ).SetRange( 25, 120 ).SetName( 'ASCII rows' )
    .SetDescription( 'Native terminal rows. Requires restart.' );

  iGroup := AddGroup( GAME_CONFIGURATION_GROUP_GAMEPLAY );
  iGroup.AddInteger( 'run_delay', 10 ).SetRange( 0, 1000, 10 ).SetName( 'Run delay (ms)' )
    .SetDescription( 'Delay between automatic movement steps.' );
  iGroup.AddToggle( 'reveal_town', False ).SetName( 'Reveal town' )
    .SetDescription( 'Reveal town when starting or loading a Session.' );
  iGroup.AddString( 'always_name', '' ).SetName( 'Default player name' )
    .SetDescription( 'Leave empty to ask for a name. Applies to the next character; --name overrides it.' );

  iGroup := AddGroup( GAME_CONFIGURATION_GROUP_AUDIO );
  iGroup.AddToggle( 'walk_sound', True ).SetName( 'Walking sound' )
    .SetDescription( 'Play footsteps while moving.' );
  iGroup.AddInteger( 'sound_volume', 100 ).SetRange( 0, 100, 5 ).SetName( 'Sound volume' )
    .SetDescription( 'Sound volume from 0 to 100.' );
  iGroup.AddInteger( 'music_volume', 100 ).SetRange( 0, 100, 5 ).SetName( 'Music volume' )
    .SetDescription( 'Music volume from 0 to 100.' );

  FGameKeyBindings := TGameBindingCatalog.Create( GameKeyBindingInfo );
  iMovementGroup := AddGroup( GAME_BINDING_GROUP_MOVEMENT );

  FRunModifier := iMovementGroup.AddInteger( 'input_run_modifier', Ord( GMM_SHIFT ) );
  FRunModifier.SetRange( Ord(GMM_NONE), Ord(GMM_CTRL) ).SetNames( ['None', 'Shift', 'Alt', 'Ctrl'] );
  FRunModifier.SetName( 'Run modifier' );
  FRunModifier.SetDescription( 'Hold this modifier with a movement key to run.' );

  FAttackModifier := iMovementGroup.AddInteger( 'input_attack_modifier', Ord( GMM_CTRL ) );
  FAttackModifier.SetRange( Ord(GMM_NONE), Ord(GMM_CTRL) ).SetNames( ['None', 'Shift', 'Alt', 'Ctrl'] );
  FAttackModifier.SetName( 'Attack modifier' );
  FAttackModifier.SetDescription( 'Hold this modifier with a movement key to attack in place.' );

  FGameKeyBindings.RegisterGroup( iMovementGroup, GAME_BINDING_GROUP_MOVEMENT );
  FGameKeyBindings.RegisterGroup( AddGroup( GAME_BINDING_GROUP_ACTIONS ), GAME_BINDING_GROUP_ACTIONS );
  FGameKeyBindings.RegisterGroup( AddGroup( GAME_BINDING_GROUP_PANELS ), GAME_BINDING_GROUP_PANELS );
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
  Option_Graphics := not GetBoolean( 'ascii_mode' );
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

function TGameConfiguration.CatalogForEntry( const aID : AnsiString ) : TBindingCatalog;
begin
  if FGameKeyBindings.ActionForID( aID ) <> BINDING_NONE then Exit( FGameKeyBindings );
  if FUIKeyBindings.ActionForID( aID ) <> BINDING_NONE then Exit( FUIKeyBindings );
  Result := nil;
end;

procedure TGameConfiguration.ResetValues;
var iGroup : TConfigurationGroup;
    iEntry : TConfigurationEntry;
begin
  for iGroup in Groups do
    for iEntry in iGroup.Entries do iEntry.Reset;
end;

procedure TGameConfiguration.ResetGroup( const aGroupID : AnsiString );
var iGroup   : TConfigurationGroup;
    iEntry   : TConfigurationEntry;
    iCatalog : TBindingCatalog;
begin
  iGroup := Group[ aGroupID ];
  for iEntry in iGroup.Entries do
  begin
    iCatalog := CatalogForEntry( iEntry.ID );
    if iCatalog = nil then
      iEntry.Reset
    else
      iCatalog.SetKey( iCatalog.ActionForID( iEntry.ID ),
        TIntegerConfigurationEntry( iEntry ).Default );
  end;
end;

function TGameConfiguration.SnapshotValues : TConfigurationValueMap;
var iGroup : TConfigurationGroup;
    iEntry : TConfigurationEntry;
begin
  Result := TConfigurationValueMap.Create;
  for iGroup in Groups do
    for iEntry in iGroup.Entries do
      if iEntry is TIntegerConfigurationEntry then
        Result[ iEntry.ID ] := TIntegerConfigurationEntry( iEntry ).Value
      else if iEntry is TToggleConfigurationEntry then
        Result[ iEntry.ID ] := TToggleConfigurationEntry( iEntry ).Value
      else if iEntry is TStringConfigurationEntry then
        Result[ iEntry.ID ] := TStringConfigurationEntry( iEntry ).Value;
end;

procedure TGameConfiguration.RestoreValues( aValues : TConfigurationValueMap );
var iGroup : TConfigurationGroup;
    iEntry : TConfigurationEntry;
begin
  for iGroup in Groups do
    for iEntry in iGroup.Entries do
      if iEntry is TIntegerConfigurationEntry then
        TIntegerConfigurationEntry( iEntry ).Value := aValues[ iEntry.ID ]
      else if iEntry is TToggleConfigurationEntry then
        TToggleConfigurationEntry( iEntry ).Value := aValues[ iEntry.ID ]
      else if iEntry is TStringConfigurationEntry then
        TStringConfigurationEntry( iEntry ).Value := aValues[ iEntry.ID ];
end;

procedure TGameConfiguration.ApplyLiveSettings;
begin
  Option_RunDelay := GetInteger( 'run_delay' );
  Option_TownReveal := GetBoolean( 'reveal_town' );
  Option_WalkSound := GetBoolean( 'walk_sound' );
  if not FNameOverridden then Option_AlwaysName := GetString( 'always_name' );
end;

function TGameConfiguration.ValuesValid : Boolean;
var iGroup : TConfigurationGroup;
    iEntry : TConfigurationEntry;
begin
  Result := FGameKeyBindings.ValuesValid and FUIKeyBindings.ValuesValid( 255 ) and
    (FRunModifier.Value in [Ord(Low(TGameMovementModifier))..Ord(High(TGameMovementModifier))]) and
    (FAttackModifier.Value in [Ord(Low(TGameMovementModifier))..Ord(High(TGameMovementModifier))]) and
    ((FRunModifier.Value = Ord(GMM_NONE)) or (FRunModifier.Value <> FAttackModifier.Value));
  Result := Result and (GetInteger( 'display_mode' ) >= 0) and
    (GetInteger( 'screen_width' ) >= 0) and (GetInteger( 'screen_width' ) <= High(Word)) and
    (GetInteger( 'screen_height' ) >= 0) and (GetInteger( 'screen_height' ) <= High(Word));
  for iGroup in Groups do
    for iEntry in iGroup.Entries do
      if iEntry is TIntegerConfigurationEntry then
        with TIntegerConfigurationEntry( iEntry ) do
          if Max > Min then Result := Result and (Value >= Min) and (Value <= Max);
end;

function TGameConfiguration.ReadSettings : Boolean;
begin
  ResetValues;
  Result := inherited Read( FSettingsPath ) and ValuesValid;
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
