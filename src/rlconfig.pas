{$INCLUDE rl.inc}
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

TGameConfig = class(TLuaConfig)
  constructor Create( const aFilename : AnsiString );
  function RunBinding( aKeyCode : Word ) : Variant;
  function RunGodKey( aKeyCode : Word ) : Variant;
end;

implementation

uses vioevent, vlualibrary, rlglobal;

constructor TGameConfig.Create( const aFilename : AnsiString );
begin
  inherited Create();
  lua_newtable( Raw );
  lua_setglobal( Raw, 'Keybindings' );

  LoadMain( aFileName );
  if GodMode then
    Load( DataPath+'godmode.lua' );

  SetConstant('VERSION', Version);
end;

function TGameConfig.RunBinding( aKeyCode : Word ) : Variant;
begin
  if GodMode and HasValue( 'godkey.' + IOKeyCodeToString( aKeyCode ) ) then
    Exit( RunGodKey( aKeyCode ) );
  Result := Call( ['Keybindings', IOKeyCodeToString( aKeyCode )], [] );
end;

function TGameConfig.RunGodKey( aKeyCode : Word ) : Variant;
begin
  Exit( Call(['godkey', IOKeyCodeToString( aKeyCode ) ],[]) );
end;

end.
