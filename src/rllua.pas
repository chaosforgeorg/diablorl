// @abstract(Lua bindings for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)

{$INCLUDE rl.inc}
unit rllua;
interface

uses sysutils, vnode, vrltools, vlua, vlualibrary, vluagamestack, vdf, rlglobal, rlnpc, rlitem, rlthing, rllevel, rlconfig, rlui;

type

{ TGameLua }

TGameLua = class(TLua)
       constructor Create( aConfig : TGameConfig; aUI : TGameUI );
       // Registers the natives; the Session natives register after this.
       procedure Initialize;
       // Loads content; natives register first, because core.lua guards globals.
       procedure LoadData( const aDataPath : AnsiString );
       // Factories creating entities from Lua use the active Session's context.
       procedure BindNodeContext( aContext : TNodeContext );
       // Fills the cell table once per Lua generation.
       procedure LoadCells( aGraphicsMode : Boolean );
       destructor Destroy; override;
       procedure OnError(const ErrorString : Ansistring); override;
     private
       CoreData : TVDataFile;
       FUI      : TGameUI;    // borrowed from Runtime
       FNodeContext : TNodeContext; // borrowed from the active Session
       FCells   : TCellTable;
     private
       procedure ReadData( const DataFile : AnsiString );
     public
       property NodeContext : TNodeContext read FNodeContext;
       property Cells : TCellTable read FCells;
     end;

{ TGameLuaStack }

TGameLuaStack = object(TLuaGameStack)
  function ToNewItem( Index : Integer; aContext : TNodeContext ) : TItem;
  function ToItemList( Index : Integer; MaxSize : DWord = 0 ) : TItemList;
end;

implementation

uses vluaentitynode, vluatools, vdebug, viotypes, vluadungen,
     rlplayer, rlshop;

{ TGameLuaStack }

function TGameLuaStack.ToNewItem ( Index : Integer; aContext : TNodeContext ) : TItem;
begin
  if IsString( Index ) then Exit( TItem.Create( aContext, ToString( Index ) ) );
  if IsObject( Index ) then Exit( ToObject( Index ) as TItem );
  Error('Item/id expected!');
end;

function TGameLuaStack.ToItemList ( Index : Integer; MaxSize : DWord = 0 ) : TItemList;
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

procedure TGameLua.ReadData(const DataFile: AnsiString);
begin
  Log('Loading data from %s...',[DataFile]);
  CoreData := TVDataFile.Create(DataFile);
  RegisterModule('diablorl',CoreData);
  LoadStream(CoreData,'','const.inc');
  LoadStream(CoreData,'','core.lua');
  LoadStream(CoreData,'','main.lua');
  Log('%s loaded.',[DataFile]);
end;

procedure TGameLua.OnError(const ErrorString: Ansistring);
begin
  FUI.Msg( 'LuaError: '+ ErrorString );
  Log('LuaError: '+ErrorString);
end;

constructor TGameLua.Create( aConfig : TGameConfig; aUI : TGameUI );
begin
  if GodMode then inherited Create( aConfig.Raw ) else inherited Create;
  FUI := aUI;
  FCells := TCellTable.Create;
end;

procedure TGameLua.BindNodeContext( aContext : TNodeContext );
begin
  FNodeContext := aContext;
end;

procedure TGameLua.Initialize;
var Count     : DWord;
    LuaInfo   : TLuaClassInfo;
begin
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

  LuaInfo := GetClassInfo( TLevel );
  LuaInfo.RegisterHooks( [ Hook_OnCreate, Hook_OnEnter, Hook_OnKillAll ], HookNameList );

  LuaInfo := GetClassInfo( TItem );
  LuaInfo.RegisterHooks( [ Hook_OnCreate, Hook_OnUse, Hook_OnHit, Hook_OnPickUp, Hook_OnDrop ], HookNameList );

  LuaInfo := GetClassInfo( TNPC );
  LuaInfo.RegisterHooks( [ Hook_OnCreate, Hook_OnAttack, Hook_OnBroadcast, Hook_OnAct, Hook_OnTalk, Hook_OnSpot, Hook_OnHit, Hook_OnDrop, Hook_OnDie ], HookNameList );

  LuaInfo := GetClassInfo( TPlayer );
  LuaInfo.RegisterHooks( [ Hook_OnCreate, Hook_OnAttack, Hook_OnBroadcast, Hook_OnAct, Hook_OnTalk, Hook_OnSpot, Hook_OnHit, Hook_OnDie ], HookNameList );

  FUI.RegisterLuaAPI( Self );
  TNode.RegisterLuaAPI( Self, 'game_object');
  TThing.RegisterLuaAPI( Self );
  TLuaEntityNode.RegisterLuaAPI( Self, 'thing');

  TItem.RegisterLuaAPI( Self );
  TNPC.RegisterLuaAPI( Self );
  TShop.RegisterLuaAPI( Self );
  TLevel.RegisterLuaAPI( Self );
  TPlayer.RegisterLuaAPI( Self );

  RegisterDunGenClass( Raw, 'generator' );
end;

procedure TGameLua.LoadData( const aDataPath : AnsiString );
begin
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
    ReadData( aDataPath + 'diablorl.mpq' );

end;

procedure TGameLua.LoadCells( aGraphicsMode : Boolean );
var CellCount : Word;
    Count,C   : Word;
begin
  for Count := 1 to 255 do FCells.Data[Count].id := '';

  CellCount := Get(['cells','__counter']);

  for Count := 1 to CellCount do
  with GetTable( ['cells', Count] ) do
  try
    with FCells.Data[Count] do
    begin
      id      := GetString('id');

      flags   := GetFlags('flags');
      color   := GetInteger('color');
      pic     := GetString('pic')[1];
      if not aGraphicsMode then
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

  FCells.Floor      := Defines['floor'];
  FCells.StairsUp   := Defines['stairs_up'];
  FCells.TownPortal := Defines['shimmering_portal'];
end;

destructor TGameLua.Destroy;
begin
  FreeAndNil(CoreData);
  inherited Destroy;
  FreeAndNil(FCells);
end;

{ TGameLuaStack }

end.
