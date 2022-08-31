{$include rl.inc}
// @abstract(Level class for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
// @created(January 17, 2005)
//
// This unit hold's level class : TLevel.

unit rllevel;
interface
uses classes,
     vnode, vgenerics, vcolor, vutil, vrltools,
     vluaentitynode, vluamapnode,
     rlglobal, rlnpc, rlitem;

type TTravelPoint = class( TVObject )
  constructor Create( aWhere : TCoord2D; aWhat : AnsiString );
  constructor CreateFromStream( aStream : TStream ); override;
  procedure WriteToStream( aStream : TStream ); override;
private
  FWhere : TCoord2D;
  FWhat  : AnsiString;
public
  property Where : TCoord2D   read FWhere;
  property What  : AnsiString read FWhat;
end;

type TTravelPoints = specialize TGObjectArray< TTravelPoint >;


// The TLevel class. Holds an array of TCells (see above). TLevel is the
// parent to all the TThings (Items, NPCs, and also the Player (who of
// course is also a NPC ;-) ).
type TLevel = class(TLuaMapNode)
       // The map array that holds TCells.
       private
       FIterate        : TNode;
       FTravelPoints   : TTravelPoints;
       FWallColor      : TColor;
       FBaseWallColor  : DWord;
       FFloorColor     : TColor;
       FBaseFloorColor : DWord;
       FDepth          : DWord;
       FMusic          : AnsiString;
       public
       // Overriden constructor.
       constructor Create( const aLevelID : AnsiString );
       // Disposes the children (TThings) and clears the map.
       procedure ClearInit;
       // Adds a travel point
       procedure AddTravelPoint( const aWhere : TCoord2D; const aWhat : AnsiString );
       // Removes a travel point
       procedure RemoveTravelPoint( const aWhere : TCoord2D );
       // Returns whether travel point exists
       function HasTravelPoint( const aWhere : TCoord2D ) : Boolean;
       // True if given cell blocks vision
       function blocksVision( const coord : TCoord2D ) : boolean; override;
       // Levels time flow procedure. See TGameObject.
       procedure TimeFlow(time : LongInt);
       // Places a portal. Will check if portal exists and remove it.
       procedure PlacePortal( aPortalID : DWord; aWhere : TCoord2D );
       // Removes all portals
       procedure RemovePortals( aPortalID : DWord );
       // Find first given thing
       function Find(const ThingID: string) : TNode;
       // noMonsters,noItems,noObstacles
       function isPassable( const c : TCoord2D ) : boolean; override;
       // noMonsters,noItems,noObstacles
       function isEmpty( const c : TCoord2D; cFlags : TFlags32 = [] ) : boolean; override;
       // Overriden destructor.
       destructor Destroy; override;
       //Calculates and draws explosion
       procedure Explosion( c : TCoord2D; Color, Range:byte; DmgMin, DmgMax : word; DrawDelay: Word = 50; DamageType: byte = DAMAGE_GENERAL; Attacker: TNPC = nil; aDelay : DWord = 0);
       // Call event in all nearby NPCs
       procedure BroadcastEvent(origin : TCoord2D; radius : Word; event : String);
       // Do stuff when a monster dies
       procedure OnMonsterDie(c : TCoord2D);
       // register lua functions
       class procedure RegisterLuaAPI;
       // Call a cellhook if present. Returns true if hook was present, false otherwise
       function CellHook( Hook : Byte; c : TCoord2D; const Params : array of Const ) : Boolean;
       // Override of remove - automatic map clear
       procedure Remove( aNode : TNode ); override;
       // Find space that is near, but not neccesarily right beside
       function FindNearSpace(var Where : TCoord2D; Range : Byte; EmptyFlags : TFlags32) : boolean;
       function FindEmptySquare : TCoord2D;
       function GetTileFlags( const aCoord : TCoord2D ) : TFlags;
       function GetBeing( const aCoord : TCoord2D ) : TNPC; override;
       function GetItem( const aCoord : TCoord2D ) : TItem; override;
       function CellToID ( const aCell : Byte ) : AnsiString; override;
       function GetPicture( const aCoord : TCoord2D ) : Word;

       //Initialization before construction
       procedure Init;
       // Stream constructor
       constructor CreateFromStream( aStream : TStream ); override;
       procedure WriteToStream( aStream : TStream ); override;
       // Abstract function for child creation from stream
       // NPC = 1, Item = 2
       function EntityFromStream( aStream : TStream; aEntityID : Byte ) : TLuaEntityNode; override;
     public
       property NPCs[ const aCoord2D : TCoord2D ] : TNPC read GetBeing;
       property Items[ const aCoord2D : TCoord2D ] : TItem read GetItem;
       property TileFlags[ const aCoord2D : TCoord2D ] : TFlags read GetTileFlags;
       property TravelPoints : TTravelPoints read FTravelPoints;

       property WallColor      : TColor read FWallColor;
       property BaseWallColor  : DWord  read FBaseWallColor;
       property FloorColor     : TColor read FFloorColor;
       property BaseFloorColor : DWord  read FBaseFloorColor;
     published
       property name     : AnsiString  read FName write FName;
       property id       : AnsiString  read FID;
       property depth    : DWord       read FDepth;
       property music    : AnsiString  read FMusic;
     end;

implementation

uses sysutils,
     vluasystem, vluatools, vluadungen,
     rllua, rlui, rlgame;

{ TTravelPoint }

constructor TTravelPoint.Create ( aWhere : TCoord2D; aWhat : AnsiString ) ;
begin
  FWhere := aWhere;
  FWhat  := aWhat;
end;

constructor TTravelPoint.CreateFromStream ( aStream : TStream ) ;
begin
  inherited CreateFromStream ( aStream ) ;
  aStream.Read( FWhere, SizeOf( FWhere ) );
  FWhat := aStream.ReadAnsiString;
end;

procedure TTravelPoint.WriteToStream ( aStream : TStream ) ;
begin
  inherited WriteToStream ( aStream ) ;
  aStream.Write( FWhere, SizeOf( FWhere ) );
  aStream.WriteAnsiString( FWhat );
end;

procedure TLevel.Init;
begin
  with LuaSystem.GetTable( [ 'levels', id ] ) do
  try
    FMusic          := GetString('music','');
    FDepth          := GetInteger('depth');
    FName           := GetString('name');
    FWallColor      := NewColor( GetVec3b( 'wall_color' ) );
    FFloorColor     := NewColor( GetVec3b( 'floor_color' ) );
    FBaseWallColor  := GetInteger( 'wall_color_base' );
    FBaseFloorColor := GetInteger( 'floor_color_base' );
  finally
    Free;
  end;
end;

constructor TLevel.Create(const aLevelID : AnsiString);
begin
  inherited Create( aLevelID, MapSizeX, MapSizeY, 15 );
  UI.Mute();

  Init;
  Log('Created.');
  FTravelPoints := TTravelPoints.Create( True );

  ClearAll(CELL_FLOOR);

  RegisterDungen( FGenerator );

  RunHook( Hook_OnCreate, [] );
  UI.Unmute();

  Assert( efNoObstacles = EF_NOBLOCK );
  Assert( efNoMonsters  = EF_NOBEINGS );
  Assert( efNoItems     = EF_NOITEMS );
end;

procedure TLevel.OnMonsterDie(c : TCoord2D);
var iCount : DWord;
    iNode  : TNode;
begin
  BroadcastEvent(c,5,'death_nerby');
  iCount := 0;
  for iNode in Self do
    if iNode is TNPC then
      Inc( iCount );
  if iCount = 1 then
    RunHook( Hook_OnKillAll, [] );
end;

procedure TLevel.Explosion( c : TCoord2D; Color, Range : byte; DmgMin, DmgMax : word; DrawDelay: Word = 50; DamageType: byte = DAMAGE_GENERAL; Attacker: TNPC = nil; aDelay : DWord = 0);
var a : TCoord2D;
begin
  //Clear nfAffected flag
  for a in NewArea( c, Range ).Clamped( FArea ) do
    if NPCs[a] <> nil then
      NPCs[a].Flags[ nfAffected ] := (Attacker<>nil) and (Attacker.AI in AIMonster) and (NPCs[a].AI in AIMonster);
  //Draw the explosion
  UI.Explosion( c, Color, Range, DrawDelay, aDelay );

  //Deal damage to creatures
  for a in NewArea( c, range ).Clamped( FArea ) do
    if NPCs[a] <> nil then
      if (vrltools.Distance( a, c ) <= range) and (isEyeContact( c, a )) then
        if NPCs[a].Flags[ nfAffected ] or NPCs[a].Flags[ nfUnAffected ] then
            continue
        else
        begin
          NPCs[a].Flags[ nfAffected ] := True;
          NPCs[a].ApplyDamage(randrange(DmgMin, DmgMax), DamageType, Attacker);
        end;

  //Clear nfAffected flag
  for a in NewArea( c, range ).Clamped( FArea ) do
     if ( NPCs[a] <> nil ) then
       NPCs[a].Flags[ nfAffected ] := False;
end;

function TLevel.CellToID ( const aCell : Byte ) : AnsiString;
begin
  Exit( CellData[ aCell ].ID );
end;

function TLevel.GetPicture ( const aCoord : TCoord2D ) : Word;
const BlackCell = Ord(' ') + LightGray shl 8;
begin
  if not isProperCoord(aCoord) then Exit(BlackCell);
  if not isVisible(aCoord) then
    if Game.Player.Flags[ nfInfravision ] and (NPCs[aCoord] <> nil) then
      if not NPCs[aCoord].Flags[ nfInvisible ] then
        Exit(Ord(NPCs[aCoord].Picture) + LightRed shl 8);
  if not IsExplored(aCoord) then Exit(BlackCell);
  if isVisible(aCoord) then
  begin
    if (NPCs[aCoord] <> nil) then
      if not NPCs[aCoord].Flags[ nfInvisible ] then
        if NPCs[aCoord].Flags[ nfStatue ] then
          exit(Ord(NPCs[aCoord].Picture) + DarkGray shl 8)
        else
          exit(NPCs[aCoord].GetPicture);
    if (Items[aCoord] <> nil) then
      exit(Items[aCoord].getPicture);
    exit(Ord(CellData[Cell[aCoord]].Pic) + CellData[Cell[aCoord]].Color shl 8);
  end
  else
    exit(Ord(CellData[Cell[aCoord]].Pic) + DarkGray shl 8);
end;

procedure TLevel.PlacePortal( aPortalID : DWord; aWhere : TCoord2D );
var iCoord : TCoord2D;
begin
  RemovePortals( aPortalID );
  try
    iCoord := FMapArea.Drop(aWhere,[efNoMonsters,efNoObstacles,efNoItems,efNoChangeRes]);
    Cell[iCoord] := aPortalID;
    if isVisible(iCoord) then UI.Msg('A portal appears!');
    AddTravelPoint( iCoord, 'Town Portal' );
    Game.Player.PortalLevel := ID;
  except
  end;
end;

procedure TLevel.RemovePortals( aPortalID : DWord );
var iCoord : TCoord2D;
begin
  for iCoord in Area do
     if Cell[ iCoord ] = aPortalID then
     begin
       RemoveTravelPoint( iCoord );
       Cell[ iCoord ] := CELL_FLOOR;
     end;
end;

function TLevel.Find(const ThingID: string) : TNode;
begin
  if ThingID = '' then exit(nil);
  Exit( FindChild( ThingID, False ) );
end;

function TLevel.isPassable ( const c : TCoord2D ) : boolean;
begin
  Exit( not ( cfBlockMove in CellData[Cell[c]].Flags ) );
end;

function TLevel.isEmpty( const c : TCoord2D; cFlags : TFlags32 = [] ) : boolean;
var iCell : Byte;
begin
  if not inherited isEmpty( c, cFlags ) then Exit( False );
  iCell := Cell[c];
  if (efSpawnOk        in cFlags) and (cfNoSpawn in CellData[iCell].Flags) then Exit(False);
  if (efNoChangeRes    in cFlags) and (cfBlockChange in CellData[iCell].Flags) then Exit(False);
  if (efNoBlockMissile in cFlags) and (cfBlockMissile in CellData[iCell].Flags) then Exit(False);
  if (efCorpse in cFlags) and (not (cfBloodCorpse in CellData[iCell].Flags)) then Exit(False);
  if (efBones in cFlags)  and (not (cfBoneCorpse  in CellData[iCell].Flags)) then Exit(False);
  Exit(True);
end;

procedure TLevel.TimeFlow(time : LongInt);
var iScan : TNode;
begin
  // Do things.
  with Game.Player do
    if PortalCount > 0 then
       if PortalCount = 1 then
       begin
         PortalLevel := Game.Level.ID;
         PlacePortal(CELL_TOWN_PORTAL,Position);
         UI.PlaySound('sfx/misc/sentinel.wav',Position);
         PortalCount := 0;
       end else PortalCount:=PortalCount - 1;
  // Pass time flow to children:
  iScan := Child as TNode;
  if iScan <> nil then
  repeat
    FIterate := iScan.Next;
    if iScan is TNPC then (iScan as TNPC).TimeFlow(time);
    iScan := FIterate;
  until (iScan = nil) or (iScan = Child);
end;

procedure TLevel.ClearInit;
begin
  DestroyChildren;
end;

procedure TLevel.AddTravelPoint ( const aWhere : TCoord2D;
  const aWhat : AnsiString ) ;
begin
  RemoveTravelPoint( aWhere );
  FTravelPoints.Push( TTravelPoint.Create( aWhere, aWhat ) );
end;

procedure TLevel.RemoveTravelPoint ( const aWhere : TCoord2D ) ;
var iCount : DWord;
begin
  if FTravelPoints.Size = 0 then Exit;
  for iCount := 0 to FTravelPoints.Size-1 do
    if FTravelPoints[iCount].Where = aWhere then
    begin
      FTravelPoints.Delete( iCount );
      Exit;
    end;
end;

function TLevel.HasTravelPoint ( const aWhere : TCoord2D ) : Boolean;
var iCount : DWord;
begin
  if FTravelPoints.Size > 0 then
    for iCount := 0 to FTravelPoints.Size-1 do
      if FTravelPoints[iCount].Where = aWhere then
        Exit( True );
  Exit( False );
end;

function TLevel.blocksVision ( const coord : TCoord2D ) : boolean;
begin
  if not isProperCoord( coord ) then Exit( True );
  Exit( cfBlockVision in CellData[GetCell(coord)].Flags );
end;

procedure TLevel.BroadcastEvent(origin : TCoord2D; radius : Word; event : String);
var c   : TCoord2D;
begin
  for c in NewArea( origin, Radius ).Clamped( FArea ) do
    if NPCs[c] <> nil then
      NPCs[c].RunHook(Hook_OnBroadcast,[event]);
end;

destructor TLevel.Destroy;
begin
  // With TNode descendants ALWAYS call inherited Init and Done.
  FreeAndNil( FTravelPoints );
  inherited Destroy;
end;

constructor TLevel.CreateFromStream( aStream : TStream);
begin
  inherited CreateFromStream( aStream );
  Init;
  FTravelPoints := TTravelPoints.CreateFromStream( aStream );
end;

procedure TLevel.WriteToStream ( aStream : TStream ) ;
begin
  inherited WriteToStream ( aStream ) ;
  FTravelPoints.WriteToStream( aStream );
end;

function TLevel.EntityFromStream ( aStream : TStream; aEntityID : Byte ) : TLuaEntityNode;
begin
  case aEntityID of
    ENTITY_BEING : Exit( TNPC.CreateFromStream(aStream) );
    ENTITY_ITEM  : Exit( TItem.CreateFromStream(aStream) );
  end;
end;

function lua_level_drop_npc(L: Plua_State): Integer; cdecl;
var State : TRLLuaState;
    Level : TLevel;
    NPC   : TNPC;
    tid   : AnsiString;
    c     : TCoord2D;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  //tid, x, y
  if State.StackSize < 3 then Exit(0);
  tid:=State.ToString(2);
  NPC := nil;
  c := State.ToCoord(3);
  if tid = '' then
  begin
    NPC := Level.GetBeing(c);
    FreeAndNil( NPC );
    Level.SetBeing(c,nil);
  end
  else
  begin
    NPC := TNPC.Create(tid);
    Level.Drop(NPC, c);
  end;
  State.Push( NPC );
  Result := 1;
end;

function lua_level_drop_item(L: Plua_State): Integer; cdecl;
var State : TRLLuaState;
    Level : TLevel;
    Item  : TItem;
    Coord : TCoord2D;
    tid   : string;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  tid   := State.ToString(2);
  Coord := State.ToCoord(3);
  if tid = '' then
  begin
    Item := Level.GetItem( Coord );
    FreeAndNil( Item );
    Level.SetItem( Coord ,nil);
    exit(0);
  end;
  if State.StackSize = 4 then
    Item := TItem.Create(tid,State.ToInteger(4))
  else
    Item :=TItem.Create(tid);
  Level.Drop(Item, Coord);
  State.Push(Item);
  Result := 1;
end;

function lua_level_explosion (L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Level  : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  Level.Explosion(
    State.ToCoord(2),
    State.ToInteger(3,RED),
    State.ToInteger(4,1),
    State.ToInteger(5,0),
    State.ToInteger(6,0),
    State.ToInteger(7,50)
  );
  Result := 0;
end;

function lua_level_broadcast_event (L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  Level.BroadcastEvent(State.ToPosition(2),State.ToInteger(3),State.ToString(4));
  Result := 0;
end;

function lua_level_has_travel_point (L: Plua_State): Integer; cdecl;
var State : TRLLuaState;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  State.Push( Level.HasTravelPoint( State.ToPosition(2) ) );
  Result := 1;
end;

function lua_level_remove_travel_point (L: Plua_State): Integer; cdecl;
var State : TRLLuaState;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  Level.RemoveTravelPoint( State.ToPosition(2) );
  Result := 0;
end;

function lua_level_add_travel_point (L: Plua_State): Integer; cdecl;
var State : TRLLuaState;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  Level.AddTravelPoint(State.ToPosition(2),State.ToString(3));
  Result := 0;
end;


function lua_level_find(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  State.Push( Level.Find( State.ToString(2) ) );
  Result := 1;
end;

function lua_level_find_tile(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Level  : TLevel;
    iCoord : TCoord2D;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  if Level.FMapArea.TryFindCell( iCoord, [State.ToID(2)] ) then
  begin
    State.PushCoord( iCoord );
    Exit(1);
  end;
  Result := 0;
end;

function lua_level_find_nearest(L: Plua_State): Integer; cdecl;
var State : TRLLuaState;
    Level : TLevel;
    Flags : TFlags;
    Count : byte;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  Count := 3;
  Flags:=[];
  while Count <= State.StackSize do begin include(Flags,State.ToInteger(Count)); inc(Count); end;
  try
    State.PushCoord( Level.FMapArea.Drop(State.ToPosition(2), flags) );
    Result := 1;
  except
    Result := 0;
  end;
end;

function lua_level_find_empty_square(L: Plua_State): Integer; cdecl;
var State : TRLLuaState;
    Level : TLevel;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  try
    State.PushCoord( Level.FindEmptySquare );
    Result := 1;
  except
    Result := 0;
  end;
end;

function lua_level_find_empty_coord(L: Plua_State): Integer; cdecl;
var State : TRLLuaState;
    Level : TLevel;
    Flags : TFlags;
    Count : byte;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  Count := 3;
  Flags:=[];
  while Count <= State.StackSize do begin include(Flags,State.ToInteger(Count)); inc(Count); end;
  try
    State.PushCoord( Level.FMapArea.EmptyRanCoord([State.ToID(2)],flags) );
    Result := 1;
  except
    Result := 0;
  end;
end;



function lua_level_find_near_coord(L: Plua_State): Integer; cdecl;
var State : TRLLuaState;
    Level : TLevel;
    Flags : TFlags;
    Count : byte;
    Coord : TCoord2D;
begin
  State.Init(L);
  Level := State.ToObject(1) as TLevel;
  Count := 4;
  Flags:=[];
  while Count <= State.StackSize do begin include(Flags,State.ToInteger(Count)); inc(Count); end;
  Coord := State.ToCoord(2);
  if Level.FindNearSpace(Coord, State.ToInteger(3),flags) then
  begin
    State.PushCoord( Coord );
    Result := 1;
  end
  else
    Result := 0;
end;

const lua_level_lib : array[0..13] of luaL_Reg = (
      ( name : 'drop_npc';           func : @lua_level_drop_npc),
      ( name : 'drop_item';          func : @lua_level_drop_item),
      ( name : 'explosion';          func : @lua_level_explosion),
      ( name : 'broadcast_event';    func : @lua_level_broadcast_event),

      ( name : 'has_travel_point';   func : @lua_level_has_travel_point),
      ( name : 'add_travel_point';   func : @lua_level_add_travel_point),
      ( name : 'remove_travel_point';func : @lua_level_remove_travel_point),

      ( name : 'find';               func : @lua_level_find),
      ( name : 'find_tile';          func : @lua_level_find_tile),
      ( name : 'find_nearest';       func : @lua_level_find_nearest),
      ( name : 'find_empty_square';  func : @lua_level_find_empty_square),
      ( name : 'find_empty_coord';   func : @lua_level_find_empty_coord),
      ( name : 'find_near_coord';    func : @lua_level_find_near_coord),
      ( name : nil;                  func : nil; )
);

class procedure TLevel.RegisterLuaAPI;
begin
  TLuaMapNode.RegisterLuaAPI( 'level' );
  LuaSystem.Register( 'level', lua_level_lib );
end;

function TLevel.CellHook ( Hook : Byte; c : TCoord2D; const Params : array of const ) : Boolean;
var iCell : Byte;
begin
  iCell := Cell[c];
  if not (Hook in CellData[iCell].hooks) then Exit( false );
  LuaSystem.ProtectedCall([ 'cells',CellData[iCell].id,CellHookNames[ Hook ] ],ConcatConstArray([Self,LuaCoord(c)],Params) );
  Exit( True );
end;

procedure TLevel.Remove ( aNode : TNode ) ;
begin
  inherited Remove ( aNode ) ;
  if FIterate = aNode then FIterate := FIterate.Next;
  if FIterate = aNode then FIterate := nil;
end;

function TLevel.GetBeing ( const aCoord : TCoord2D ) : TNPC;
begin
  Exit( inherited GetBeing( aCoord ) as TNPC );
end;

function TLevel.GetItem ( const aCoord : TCoord2D ) : TItem;
begin
  Exit( inherited GetItem( aCoord ) as TItem );
end;

function TLevel.FindNearSpace(var Where: TCoord2D; Range: Byte; EmptyFlags: TFlags32): boolean;
const CriticalSize = 100;
var Critical : word;
    GC       : TCoord2D;
begin
  Critical := 0;
  repeat
    if Critical > CriticalSize then Exit(False);
    Inc(Critical);
    GC := Where.RandomShifted(Range);
  until isProperCoord(GC) and (GetCell(GC) = CELL_FLOOR) and (isEmpty(GC,EmptyFlags));
  Where := GC;
  Exit(true);
end;

function TLevel.FindEmptySquare: TCoord2D;
const CriticalSize = 6000;
var Critical : word;
begin
  Critical := 0;
  repeat
    Inc(Critical);
    Result := FMapArea.RanCoord( [CELL_FLOOR] );
  until (FMapArea.Around(Result,[CELL_FLOOR]) = 8) or (Critical > CriticalSize);
  if Critical > CriticalSize then
  begin
    Result := FMapArea.FindCell([CELL_FLOOR]);
    Log('FindBigEmptySpace -- Failed!');
  end;
end;

function TLevel.GetTileFlags ( const aCoord : TCoord2D ) : TFlags;
begin
  if not isProperCoord( aCoord ) then Exit([]);
  Exit( CellData[Cell[aCoord]].Flags );
end;


end.
