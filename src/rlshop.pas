{$include rl.inc}
// @abstract(Shop class for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
//
// This unit holds the TShop class.

unit rlshop;
interface

uses sysutils, classes, vnode, rlglobal, rlitem;

type

{ TShop }

TShop = class( TNode )
  // General constructor
  constructor Create(const thingID :string);
  // Destructor
  destructor Destroy; override;
  // Stream constructor
  constructor CreateFromStream( ISt : TStream ); override;
  // Stream writer
  procedure WriteToStream( OSt : TStream ); override;
  // Add item
  procedure AddItem( Item : TItem );
  // Gets amount of non-nil items
  function getCount : DWord;
  // Resorts the shop
  procedure Resort;

  // register lua functions
  class procedure RegisterLuaAPI;
public
  // Items
  FItems : array[1..ITEMS_SHOP] of TItem;
  FLevel : Word;
published
  property name     : AnsiString  read FName write FName;
  property id       : AnsiString  read FID;
  property level  : Word read FLevel write FLevel;
  property amount : DWord read getCount;
end;

implementation

// Remove
uses vluasystem, rllua;

{ TShop }

constructor TShop.Create(const thingID: string);
var Count : DWord;
begin
  inherited Create(thingID,True);
  for Count := 1 to ITEMS_SHOP do FItems[Count] := nil;
  FLevel := 0;
end;

destructor TShop.Destroy;
var Count : DWord;
begin
  for Count := 1 to ITEMS_SHOP do FreeAndNil( FItems[Count] );
  inherited Destroy;
end;

constructor TShop.CreateFromStream(ISt: TStream);
var Count, Size : DWord;
begin
  inherited CreateFromStream(ISt);
  for Count := 1 to ITEMS_SHOP do FItems[Count] := nil;
  FLevel := ISt.ReadWord;
  Size := ISt.ReadDWord;
  for Count := 1 to Size do
    AddItem(TItem.CreateFromStream(ISt));
end;

procedure TShop.WriteToStream(OSt: TStream);
var Count, Size : DWord;
begin
  inherited WriteToStream(OSt);
  Resort;
  OSt.WriteWord(FLevel);
  Size := getCount;
  OSt.WriteDWord(Size);
  for Count := 1 to Size do
    FItems[Count].WriteToStream(OSt);
end;

procedure TShop.AddItem(Item: TItem);
var Count : DWord;
begin
  for Count := 1 to ITEMS_SHOP do
    if FItems[Count] = nil then
    begin
      FItems[Count] := Item;
      Exit;
    end;
end;

function TShop.getCount: DWord;
var Count : DWord;
begin
  getCount := 0;
  for Count := 1 to ITEMS_SHOP do
    if FItems[Count] <> nil then
      Inc( getCount );
end;

procedure TShop.Resort;
var Count : DWord;
begin
  for Count := 1 to ITEMS_SHOP-1 do
    if FItems[Count] = nil then
    begin
      FItems[Count]     := FItems[Count + 1];
      FItems[Count + 1] := nil;
    end;
end;

function lua_shop_item_get(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Shop   : TShop;
    Slot   : Word;
begin
  State.Init(L);
  Shop := State.ToObject(1) as TShop;
  Slot := State.ToInteger(2);

  if (Slot = 0) or (Slot > ITEMS_SHOP)
    then State.Push( nil )
    else State.Push( Shop.FItems[Slot] );
  Exit(1);
end;

function lua_shop_item_set(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Slot   : Word;
    Shop   : TShop;
begin
  State.Init(L);
  Shop := State.ToObject(1) as TShop;
  Slot := State.ToInteger(2);
  if (Slot = 0) or (Slot > ITEMS_SHOP) then Exit(0);
  FreeAndNil(Shop.FItems[slot]);
  Shop.fItems[slot] := State.ToObjectOrNil(3) as TItem;
  Exit(0);
end;

function lua_shop_nil_item(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Shop   : TShop;
    Item   : TItem;
    Count   : Word;
begin
  State.Init(L);
  Shop := State.ToObject(1) as TShop;
  if State.StackSize > 1 then
  begin
    if State.IsNumber(2) then
      Shop.FItems[State.ToInteger(2)] := nil
    else
    begin
      Item := State.ToObject(2) as TItem;
      for Count := 1 to ITEMS_SHOP-1 do
        if Shop.FItems[Count] = Item then
          Shop.FItems[Count] := nil;
    end;
  end
  else
    for Count := 1 to ITEMS_SHOP-1 do
      Shop.FItems[Count] := nil;
  Exit(0);
end;

function lua_shop_sort(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Shop   : TShop;
begin
  State.Init(L);
  Shop := State.ToObject(1) as TShop;
  Shop.Resort;
  Exit(0);
end;

const lua_shop_lib : array[0..4] of luaL_Reg = (
  ( name : 'item_set';   func : @lua_shop_item_set ),
  ( name : 'item_get';   func : @lua_shop_item_get ),
  ( name : 'sort';       func : @lua_shop_sort ),
  ( name : 'nil_item';   func : @lua_shop_nil_item ),
  ( name : nil;          func : nil; )
);

class procedure TShop.RegisterLuaAPI;
begin
  LuaSystem.Register( 'shop', lua_shop_lib );
end;

end.

