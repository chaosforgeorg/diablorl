// @abstract(Lua bindings for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)

{$include rl.inc}
unit rllua;
interface

uses SysUtils, vrltools, vluasystem, vluagamestate, rlnpc, rlitem, rlthing, rllevel, vdf;

var LuaPlayerX : Byte = 2;
    LuaPlayerY : Byte = 2;

type

{ TRLLua }

TRLLua = class(TLuaSystem)
       constructor Create;
       destructor Destroy; override;
//       function RunHook(const TableName: Ansistring; Index: Variant; const Name: Ansistring; const Args: array of const ) : Variant;
       procedure RegisterPlayer(Thing: TThing);
       procedure OnError(const ErrorString : Ansistring); override;
     private
       CoreData: TVDataFile;
     private
       procedure ReadData( const DataFile : AnsiString );
     end;

{ TRLLuaState }

TRLLuaState = object(TLuaGameState)
  function ToNewNPC( Index : Integer ) : TNPC;
  function ToNewItem( Index : Integer ) : TItem;
  function ToItemList( Index : Integer; MaxSize : DWord = 0 ) : TItemList;
end;


implementation

uses vnode, vlualibrary, vluaentitynode, vluatools, vdebug, rlglobal, viotypes, rlgame,
     vutil, vluadungen, rlplayer, rlui, rlshop;

{ TRLLuaState }

function TRLLuaState.ToNewNPC ( Index : Integer ) : TNPC;
begin
  if IsString( Index ) then Exit( TNPC.Create( ToString( Index ) ) );
  if IsObject( Index ) then Exit( ToObject( Index ) as TNPC );
  Error('NPC/id expected!');
end;

function TRLLuaState.ToNewItem ( Index : Integer ) : TItem;
begin
  if IsString( Index ) then Exit( TItem.Create( ToString( Index ) ) );
  if IsObject( Index ) then Exit( ToObject( Index ) as TItem );
  Error('Item/id expected!');
end;

function TRLLuaState.ToItemList ( Index : Integer; MaxSize : DWord = 0 ) : TItemList;
begin
  Index := lua_absindex( FState, Index );
  if not IsTable( Index ) then Exit( nil );
  if MaxSize = 0 then MaxSize := lua_objlen( FState, Index );
  ToItemList := TItemList.Create( MaxSize );
  lua_pushnil( FState );
  while lua_next( FState, Index ) <> 0 do
  begin
    ToItemList.Push( ToObjectOrNil( -1 ) as TItem );
    lua_pop( FState, 1 );
  end;
end;

// ************************************************************************ //
// ************************************************************************ //

procedure TRLLua.ReadData(const DataFile: AnsiString);
begin
  Log('Loading data from %s...',[DataFile]);
  CoreData := TVDataFile.Create(DataFile);
  RegisterModule('diablorl',CoreData);
  LoadStream(CoreData,'','const.inc');
  LoadStream(CoreData,'','core.lua');
  LoadStream(CoreData,'','main.lua');
  Log('%s loaded.',[DataFile]);
end;

procedure TRLLua.RegisterPlayer(Thing: TThing);
begin
  SetValue( 'player', Thing );
  RegisterKillsClass( Raw, TPlayer(Thing).Kills, 'kills' );
  RegisterStatisticsClass( Raw, TPlayer(Thing).Stats, 'stats' );
end;

procedure TRLLua.OnError(const ErrorString: Ansistring);
begin
  if (UI <> nil)  then
  begin
    UI.Msg( 'LuaError: '+ ErrorString );
  end
  else
    raise ELuaException.Create('LuaError: '+ErrorString);
  Log('LuaError: '+ErrorString);
end;

function lua_world_end_game(L: Plua_State): Integer; cdecl;
begin
  Result := 0;
  GameEnd:=true;
  Game.Player.SpeedCount := Game.Player.SpeedCount - 50;
end;

// temp?
function lua_world_get_shop(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    ID     : AnsiString;
    Shop   : TShop;
begin
  State.Init(L);
  ID := State.ToString(1);
  if ID = '' then Exit(0);
  Shop := Game.FindChild( ID ) as TShop;
  if Shop = nil then Exit(0);
  State.Push( Shop );
  Result := 1;
end;

// temp?
function lua_world_get_level(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    ID     : AnsiString;
    Level  : TLevel;
begin
  State.Init(L);
  ID := State.ToString(1);
  if ID = '' then Exit(0);
  Level := Game.FindChild( ID ) as TLevel;
  if Level = nil then Exit(0);
  State.Push( Level );
  Result := 1;
end;

function lua_world_get_turn_count(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
begin
  State.Init(L);
  State.Push( LongInt( Game.TurnCount ) );
  Result := 1;
end;

const lua_world_lib : array[0..4] of luaL_Reg = (
    ( name : 'get_level';        func : @lua_world_get_level),
    ( name : 'get_shop';         func : @lua_world_get_shop),
    ( name : 'get_turn_count';   func : @lua_world_get_turn_count),
    ( name : 'end_game';         func : @lua_world_end_game),
    ( name : nil;                func : nil; )
);

constructor TRLLua.Create;
var Count     : DWord;
    LuaInfo   : TLuaClassInfo;
begin
  if GodMode
    then inherited Create( UI.Config.Raw )
    else inherited Create;

  CoreData := nil;
  LuaSystem := Self;

  for Count := 0 to 15 do SetValue(ColorNames[Count],Count);

  RegisterTableAuxFunctions( Raw );
  RegisterMathAuxFunctions( Raw );
  RegisterCoordClass( Raw );
  RegisterAreaClass( Raw );
  RegisterAreaFull( Raw, NewArea( NewCoord2D( 1, 1 ), NewCoord2D( MapSizeX, MapSizeY ) ) );
  RegisterDungenClass( Raw, 'generator' );

  RegisterType( TLevel, 'level', 'levels' );
  RegisterType( TShop,  'shop', 'shops' );
  RegisterType( TItem,  'item', 'items' );
  RegisterType( TNPC,   'npc',  'npcs' );
  RegisterType( TPlayer,'player',  'klasses' );

  LuaInfo := LuaSystem.GetClassInfo( TLevel );
  LuaInfo.RegisterHooks( [ Hook_OnCreate, Hook_OnEnter, Hook_OnKillAll ], HookNameList );

  LuaInfo := LuaSystem.GetClassInfo( TItem );
  LuaInfo.RegisterHooks( [ Hook_OnCreate, Hook_OnUse, Hook_OnHit, Hook_OnPickUp, Hook_OnDrop ], HookNameList );

  LuaInfo := LuaSystem.GetClassInfo( TNPC );
  LuaInfo.RegisterHooks( [ Hook_OnCreate, Hook_OnAttack, Hook_OnBroadcast, Hook_OnAct, Hook_OnTalk, Hook_OnSpot, Hook_OnHit, Hook_OnDrop, Hook_OnDie ], HookNameList );

  LuaInfo := LuaSystem.GetClassInfo( TPlayer );
  LuaInfo.RegisterHooks( [ Hook_OnCreate, Hook_OnAttack, Hook_OnBroadcast, Hook_OnAct, Hook_OnTalk, Hook_OnSpot, Hook_OnHit, Hook_OnDie ], HookNameList );

//  AddVar('VERSION',Version);
  Register( 'world', lua_world_lib );

  TGameUI.RegisterLuaAPI( State );
  TNode.RegisterLuaAPI('game_object');
  TThing.RegisterLuaAPI();
  TLuaEntityNode.RegisterLuaAPI('thing');

  TItem.RegisterLuaAPI();
  TNPC.RegisterLuaAPI;
  TShop.RegisterLuaAPI;
  TLevel.RegisterLuaAPI;
  TPlayer.RegisterLuaAPI;

  RegisterDunGenClass( Raw, 'generator' );

  if GodMode then
  try
    RegisterModule('diablorl','lua' + DirectorySeparator);
    LoadFile('const.inc');
    LoadFile('lua' + DirectorySeparator + 'core.lua');
    LoadFile('lua' + DirectorySeparator + 'main.lua');
  except
    on e : ELuaException do
      raise Exception.Create( e.Message );
  end
  else
    ReadData(DataPath+'diablorl.mpq');


end;


destructor TRLLua.Destroy;
begin
  FreeAndNil(CoreData);
  inherited Destroy;
end;

{ TRLLuaState }

end.
