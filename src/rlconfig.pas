{$include rl.inc}
// @abstract(Configuration for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)

unit rlconfig;
interface

uses Classes, SysUtils, vluaconfig;

const
  COMMAND_WALKNORTH = 2;
  COMMAND_WALKSOUTH = 3;
  COMMAND_WALKEAST  = 4;
  COMMAND_WALKWEST  = 5;
  COMMAND_WALKNE    = 6;
  COMMAND_WALKSE    = 7;
  COMMAND_WALKNW    = 8;
  COMMAND_WALKSW    = 9;
  COMMAND_WAIT      = 10;

  COMMAND_RUNNORTH  = 12;
  COMMAND_RUNSOUTH  = 13;
  COMMAND_RUNEAST   = 14;
  COMMAND_RUNWEST   = 15;
  COMMAND_RUNNE     = 16;
  COMMAND_RUNSE     = 17;
  COMMAND_RUNNW     = 18;
  COMMAND_RUNSW     = 19;

  COMMAND_ATKNORTH  = 22;
  COMMAND_ATKSOUTH  = 23;
  COMMAND_ATKEAST   = 24;
  COMMAND_ATKWEST   = 25;
  COMMAND_ATKNE     = 26;
  COMMAND_ATKSE     = 27;
  COMMAND_ATKNW     = 28;
  COMMAND_ATKSW     = 29;

  COMMAND_SWITCHMODE= 40;
  COMMAND_PICKUP    = 41;
  COMMAND_DROP      = 42;
  COMMAND_INVENTORY = 43;
  COMMAND_EQUIPMENT = 44;
  COMMAND_ACT       = 45;
  COMMAND_CAST      = 46;
  COMMAND_LOOK      = 47;
  COMMAND_FIRE      = 48;
  COMMAND_USE       = 49;

  COMMAND_PLAYERINFO= 50;
  COMMAND_QUICKSLOT = 51;
  COMMAND_ESCAPE    = 52;
  COMMAND_JOURNAL   = 53;
  COMMAND_SPELLBOOK = 54;
  COMMAND_SPELLS    = 55;
  COMMAND_CWIN      = 56;
  COMMAND_MESSAGES  = 57;
  COMMAND_SSHOT     = 58;
  COMMAND_SSHOTBB   = 59;

  COMMAND_SOUNDVOLUP= 60;
  COMMAND_SOUNDVOLDN= 61;
  COMMAND_MUSICVOLUP= 62;
  COMMAND_MUSICVOLDN= 63;

  COMMAND_QUICKSLOT1    = 71;
  COMMAND_QUICKSLOT2    = 72;
  COMMAND_QUICKSLOT3    = 73;
  COMMAND_QUICKSLOT4    = 74;
  COMMAND_QUICKSLOT5    = 75;
  COMMAND_QUICKSLOT6    = 76;
  COMMAND_QUICKSLOT7    = 77;
  COMMAND_QUICKSLOT8    = 78;

  COMMAND_QUICKSKILL    = 80;
  COMMAND_SPELLSLOT1    = 81;
  COMMAND_SPELLSLOT2    = 82;
  COMMAND_SPELLSLOT3    = 83;
  COMMAND_SPELLSLOT4    = 84;

  COMMAND_OK            = 90;

  COMMAND_GODKEY        = 100;

  COMMAND_INVALID       = 201;

  COMMANDS_MOVE       = [COMMAND_WALKNORTH..COMMAND_WALKSW];
  COMMANDS_RUN        = [COMMAND_RUNNORTH..COMMAND_RUNSW];
  COMMANDS_ATTACK     = [COMMAND_ATKNORTH..COMMAND_ATKSW];

type

TDiabloConfig = class(TLuaConfig)
  constructor Create( const aFilename : AnsiString );
  function RunGodKey( aKeyCode : Word ) : Variant;
end;

implementation

uses vsystems, vluastate, vioevent, rlui, rlglobal, rlgame;

function lua_command_messages(L: PLua_State): Integer; cdecl;
begin
  UI.ShowRecent();
  Result := 0;
end;

function lua_command_help(L: PLua_State): Integer; cdecl;
begin
  UI.ShowManual();
  Result := 0;
end;

function lua_command_quit(L: PLua_State): Integer; cdecl;
begin
  GameEnd := true;
  Game.Player.SpeedCount := Game.Player.SpeedCount - 50;
  Result := 0;
end;

function lua_command_screenshot(L: PLua_State): Integer; cdecl;
var State: TLuaState;
begin
  State.Init(L);
  UI.ScreenShot( State.ToBoolean( 1 ) );
  Result := 0;
end;

function lua_command_quick_slot(L: PLua_State): Integer; cdecl;
var State: TLuaState;
begin
  State.Init(L);
  Game.Player.useQuickSlot( State.ToInteger( 1 ) );
  Result := 0;
end;

function lua_command_quick_spell(L: PLua_State): Integer; cdecl;
var State: TLuaState;
begin
  State.Init(L);
  Game.Player.useQuickSkill( State.ToInteger( 1 ) );
  Result := 0;
end;

constructor TDiabloConfig.Create( const aFilename : AnsiString );
begin
  inherited Create();

  SetConstant( 'COMMAND_WALKNORTH', COMMAND_WALKNORTH );
  SetConstant( 'COMMAND_WALKSOUTH', COMMAND_WALKSOUTH );
  SetConstant( 'COMMAND_WALKEAST',  COMMAND_WALKEAST );
  SetConstant( 'COMMAND_WALKWEST',  COMMAND_WALKWEST );
  SetConstant( 'COMMAND_WALKNE',    COMMAND_WALKNE );
  SetConstant( 'COMMAND_WALKSE',    COMMAND_WALKSE );
  SetConstant( 'COMMAND_WALKNW',    COMMAND_WALKNW );
  SetConstant( 'COMMAND_WALKSW',    COMMAND_WALKSW );

  SetConstant( 'COMMAND_RUNNORTH',  COMMAND_RUNNORTH );
  SetConstant( 'COMMAND_RUNSOUTH',  COMMAND_RUNSOUTH );
  SetConstant( 'COMMAND_RUNEAST',   COMMAND_RUNEAST );
  SetConstant( 'COMMAND_RUNWEST',   COMMAND_RUNWEST );
  SetConstant( 'COMMAND_RUNNE',     COMMAND_RUNNE );
  SetConstant( 'COMMAND_RUNSE',     COMMAND_RUNSE );
  SetConstant( 'COMMAND_RUNNW',     COMMAND_RUNNW );
  SetConstant( 'COMMAND_RUNSW',     COMMAND_RUNSW );

  SetConstant( 'COMMAND_ATKNORTH',  COMMAND_ATKNORTH );
  SetConstant( 'COMMAND_ATKSOUTH',  COMMAND_ATKSOUTH );
  SetConstant( 'COMMAND_ATKEAST',   COMMAND_ATKEAST );
  SetConstant( 'COMMAND_ATKWEST',   COMMAND_ATKWEST );
  SetConstant( 'COMMAND_ATKNE',     COMMAND_ATKNE );
  SetConstant( 'COMMAND_ATKSE',     COMMAND_ATKSE );
  SetConstant( 'COMMAND_ATKNW',     COMMAND_ATKNW );
  SetConstant( 'COMMAND_ATKSW',     COMMAND_ATKSW );

  SetConstant( 'COMMAND_WAIT',      COMMAND_WAIT );
  SetConstant( 'COMMAND_ESCAPE',    COMMAND_ESCAPE );
  SetConstant( 'COMMAND_FIRE',      COMMAND_FIRE );
  SetConstant( 'COMMAND_PICKUP',    COMMAND_PICKUP );
  SetConstant( 'COMMAND_DROP',      COMMAND_DROP );
  SetConstant( 'COMMAND_INVENTORY', COMMAND_INVENTORY );
  SetConstant( 'COMMAND_EQUIPMENT', COMMAND_EQUIPMENT );
  SetConstant( 'COMMAND_ACT',       COMMAND_ACT );
  SetConstant( 'COMMAND_CAST',      COMMAND_CAST );
  SetConstant( 'COMMAND_LOOK',      COMMAND_LOOK );
  SetConstant( 'COMMAND_USE',       COMMAND_USE );
  SetConstant( 'COMMAND_PLAYERINFO',COMMAND_PLAYERINFO );
  SetConstant( 'COMMAND_QUICKSLOT', COMMAND_QUICKSLOT );
  SetConstant( 'COMMAND_JOURNAL',   COMMAND_JOURNAL );
  SetConstant( 'COMMAND_SPELLBOOK', COMMAND_SPELLBOOK );
  SetConstant( 'COMMAND_SPELLS',    COMMAND_SPELLS );
  SetConstant( 'COMMAND_CWIN',      COMMAND_CWIN );
  SetConstant( 'COMMAND_MESSAGES',  COMMAND_MESSAGES );
  SetConstant( 'COMMAND_SOUNDVOLUP',COMMAND_SOUNDVOLUP );
  SetConstant( 'COMMAND_SOUNDVOLDN',COMMAND_SOUNDVOLDN );
  SetConstant( 'COMMAND_MUSICVOLUP',COMMAND_MUSICVOLUP );
  SetConstant( 'COMMAND_MUSICVOLDN',COMMAND_MUSICVOLDN );

  SetConstant( 'COMMAND_SSHOT',      COMMAND_SSHOT );
  SetConstant( 'COMMAND_SSHOTBB',    COMMAND_SSHOTBB );

  SetConstant( 'COMMAND_SWITCHMODE',COMMAND_SWITCHMODE );

  SetConstant( 'COMMAND_GODKEY',    COMMAND_GODKEY );

  SetConstant( 'COMMAND_QUICKSLOT1', COMMAND_QUICKSLOT1 );
  SetConstant( 'COMMAND_QUICKSLOT2', COMMAND_QUICKSLOT2 );
  SetConstant( 'COMMAND_QUICKSLOT3', COMMAND_QUICKSLOT3 );
  SetConstant( 'COMMAND_QUICKSLOT4', COMMAND_QUICKSLOT4 );
  SetConstant( 'COMMAND_QUICKSLOT5', COMMAND_QUICKSLOT5 );
  SetConstant( 'COMMAND_QUICKSLOT6', COMMAND_QUICKSLOT6 );
  SetConstant( 'COMMAND_QUICKSLOT7', COMMAND_QUICKSLOT7 );
  SetConstant( 'COMMAND_QUICKSLOT8', COMMAND_QUICKSLOT8 );

  SetConstant( 'COMMAND_QUICKSKILL', COMMAND_QUICKSKILL );
  SetConstant( 'COMMAND_SPELLSLOT1', COMMAND_SPELLSLOT1 );
  SetConstant( 'COMMAND_SPELLSLOT2', COMMAND_SPELLSLOT2 );
  SetConstant( 'COMMAND_SPELLSLOT3', COMMAND_SPELLSLOT3 );
  SetConstant( 'COMMAND_SPELLSLOT4', COMMAND_SPELLSLOT4 );

  LoadMain( aFileName );
  if GodMode then
    Load( ConfigurationPath+'godmode.lua' );

  Option_RunDelay   := Entries['run_delay'];
  Option_TownReveal := Entries['reveal_town'];
  Option_WalkSound  := Entries['walk_sound'];

  UI.SetSoundVolume(Entries['sound_volume']);
  UI.SetMusicVolume(Entries['music_volume']);
  //lua bounds
  SetConstant('VERSION', Version);
  State.Register( 'command', 'messages', @lua_command_messages );
  State.Register( 'command', 'quit', @lua_command_quit );
  State.Register( 'command', 'help', @lua_command_help );
  State.Register( 'command', 'screenshot', @lua_command_screenshot );
  State.Register( 'command', 'quick_slot', @lua_command_quick_slot );
  State.Register( 'command', 'quick_spell', @lua_command_quick_spell );
  TGameUI.RegisterLuaAPI( State );
end;

function TDiabloConfig.RunGodKey( aKeyCode : Word ) : Variant;
begin
  Exit( Call(['godkey', IOKeyCodeToString( aKeyCode ) ],[]) );
end;

end.
