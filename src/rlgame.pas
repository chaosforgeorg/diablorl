{$INCLUDE rl.inc}
// @abstract(One-playthrough state and ownership for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
unit rlgame;
interface

uses Classes, vnode, vuid, vrandom, vrlapp,
     rllevel, rlglobal, rlplayer, rlnpc, rllua, rlshop, rlpersistence;

// Owns one playthrough, including entities temporarily detached from levels.
// Runtime services are borrowed; Game is only the current Session alias.
type TGameSession = class( TNode )
  private
    FRuntime         : TRLRuntime;
    FPersistence     : TPersistence;
    FUIDStore        : TUIDStore;
    FPlayer          : TPlayer;
    FLevel           : TLevel;
    FTravellingGolem : TNPC;
    FGraveYard       : TNode;
    FNextLevelID     : AnsiString;
    FStairNumber     : Byte;
    FTurnCount       : DWord;
    FEnded           : Boolean;
    FLoading         : Boolean;
    FPlayerClass     : Byte;
    FPlayerName      : AnsiString;
    FLevelChange     : Boolean;
    FPrepared        : Boolean;
    function GetRNG : TRNG;
    function GetLua : TGameLua;
  public
    constructor Create( aRuntime : TRLRuntime; aPersistence : TPersistence ); reintroduce;
    destructor Destroy; override;
    function Prepare : Boolean;
    procedure Run;
    function Load : Boolean;
    procedure Save;
    function CanSave : Boolean;
    property Player : TPlayer read FPlayer;
    property Level : TLevel read FLevel;
    property RNG : TRNG read GetRNG;
    property Lua : TGameLua read GetLua;
    property Persistence : TPersistence read FPersistence;
    property GraveYard : TNode read FGraveYard;
    property NextLevelID : AnsiString read FNextLevelID write FNextLevelID;
    property StairNumber : Byte read FStairNumber write FStairNumber;
    property TurnCount : DWord read FTurnCount;
    property Ended : Boolean read FEnded write FEnded;
    property Loading : Boolean read FLoading write FLoading;
    property PlayerClass : Byte read FPlayerClass write FPlayerClass;
    property PlayerName : AnsiString read FPlayerName write FPlayerName;
    property LevelChange : Boolean read FLevelChange write FLevelChange;
end;

var Game : TGameSession = nil;

implementation

uses SysUtils, zstream, vutil, vrltools, vluasystem, rlui, rlviews;

constructor TGameSession.Create( aRuntime : TRLRuntime; aPersistence : TPersistence );
begin
  inherited Create;
  FRuntime := aRuntime;
  FPersistence := aPersistence;
  FNextLevelID := 'town';
  FGraveYard := TNode.Create;
  Add( FGraveYard );
end;

function TGameSession.GetRNG : TRNG;
begin
  Result := FRuntime.GameRNG;
end;

function TGameSession.GetLua : TGameLua;
begin
  Result := TGameLua( FRuntime.Lua );
end;

function TGameSession.Prepare : Boolean;
var iCount : Word;
begin
  UI.HideCursor;
  UI.PlayMusic( 'music/dintro.wav' );
  UI.RunLayer( TIntroScreen.Create );
  UI.RunLayer( TMainMenuScreen.Create );
  if FEnded then Exit( True );
  if FLoading then
  begin
    if not Load then Exit( False );
  end
  else
  begin
    FUIDStore := TUIDStore.Create;
    UIDs := FUIDStore;
    FUID := FUIDStore.Register( Self );
    if FileExists( FRuntime.Paths.WritePath + 'save' ) then
      DeleteFile( FRuntime.Paths.WritePath + 'save' );
    UI.RunLayer( TKlassScreen.Create );
    if Option_AlwaysName = '' then
      UI.RunLayer( TNameScreen.Create )
    else
      FPlayerName      := Option_AlwaysName;

    FPlayer := TPlayer.Create( Lua.Get( ['klasses', FPlayerClass, 'id'] ) );
    Lua.RegisterPlayer( FPlayer );
    FPlayer.RunHook( Hook_OnCreate, [] );
    if FPlayerName <> '' then FPlayer.Name := FPlayerName;

    for iCount := 1 to Lua.Get( ['shops', '__counter'] ) do
      Add( TShop.Create( Lua.Get( ['shops', iCount, 'id'] ) ) );
    UI.HideCursor;
  end;
  FPrepared := True;
  Result := True;
end;

procedure TGameSession.Run;
var iStartPos : TCoord2D;
    iLevelID  : AnsiString;
  function FindCell( aCell : DWord ) : TCoord2D;
  var iCoord : TCoord2D;
  begin
    for iCoord in FLevel.Area do
      if FLevel.GetCell( iCoord ) = aCell then
        Exit( iCoord );
    raise EException.Create('FindCell for stairs failed!');
  end;

begin
  if not FEnded then
  begin
    Lua.RegisterPlayer(FPlayer);
    Lua.SetValue( 'TOWN_REVEAL', Option_TownReveal );
    UI.Prepare( FPlayer );
    repeat
      FPlayer.Detach;
      iLevelID := FNextLevelID;
      FLevel := FindChild( iLevelID ) as TLevel;

      if FLevel = nil then
      begin
         // We create a new level
         FLevel := TLevel.Create(iLevelID);
         // Makes FLevel a child of TGameSession, so we don't have to dispose of it manualy.
         Add(FLevel);
         if FLevel.Depth > FPlayer.MaxDepth then
           FPlayer.MaxDepth := FLevel.Depth;
         FStairNumber := CELL_STAIR_UP;
      end;

      if FStairNumber <> CELL_TOWN_PORTAL then
        if FStairNumber = 0
          then iStartPos := FPlayer.Position
          else iStartPos := FindCell(FStairNumber);

      UI.SetLevel( FLevel );
      // Attach to the active level; Session also owns the player while detached.
      FPlayer.Move(FLevel);

      FLevel.RunHook( Hook_OnEnter, [FLoading] );
      FLoading         := False;

      // If player came throgh portal, destroy portal
      if FStairNumber = CELL_TOWN_PORTAL then
      begin
        iStartPos := FindCell(FStairNumber);
        if FLevel.Flags[ lfTown ] then
        begin
          FLevel.AddTravelPoint( iStartPos, 'Portal to Dungeon' );
          Inc(iStartPos.Y)
        end
        else
        begin
          FLevel.RemovePortals( CELL_TOWN_PORTAL );
          FPlayer.PortalLevel := '';
        end;
      end;

      // If not portal level then destroy any portals on it.
      if (FLevel.ID <> FPlayer.PortalLevel)and(not FLevel.Flags[ lfTown ]) then
        FLevel.RemovePortals( CELL_TOWN_PORTAL );

      UI.PlayMusic(FLevel.Music);

      // Now we can properly displace the player :D
      // GenX and GenY are taken from the generator
      FLevel.Drop( RNG, FPlayer, iStartPos );

      //drop player's golem here
      if FTravellingGolem <> nil then
      begin
        FLevel.Drop( RNG, FTravellingGolem, iStartPos );
        FTravellingGolem := nil;
      end;

      FLevelChange     := False;
      FPlayer.Enemy := 0;
      if FPlayer.Flags[ nfManaShield ] then
        UI.Msg('Your protection worn off.');
      FPlayer.Flags[ nfInfravision ] := False;
      FPlayer.Flags[ nfManaShield  ] := False;
      FPlayer.Flags[ nfReflect     ] := False;
      repeat
        FLevel.TimeFlow(10);
        Inc(FTurnCount);
        FGraveYard.DestroyChildren;
      until FEnded or FLevelChange;
      FTravellingGolem := nil;
      if FPlayer.Parent <> nil then
      begin
        FTravellingGolem := TLevel(FPlayer.Parent).Find('golem') as TNPC;
        if FTravellingGolem <> nil then FTravellingGolem.Detach;
      end;
    until FEnded;
    if (FPlayer.HP <= 0) or (FLevel.Depth > 12) then
    begin
      FPlayer.WriteMemorial;
      UI.UnPrepare;
      UI.ShowMortem;
    end;
    FPlayer.Detach;
    UI.UnPrepare;
    UI.RunLayer( TOutroScreen.Create );
  end;
end;

destructor TGameSession.Destroy;
begin
  // Runtime has retired all views before releasing its Session. Lua and UIDs
  // remain alive until every owned entity (parented or detached) is gone.
  if FRuntime <> nil then Lua.RegisterPlayer( nil );
  FreeAndNil( FTravellingGolem );
  FreeAndNil( FPlayer );
  inherited Destroy;
  FLevel := nil;
  FreeAndNil( FUIDStore );
  Game := nil;
end;

function TGameSession.Load : Boolean;
var iStream : TGZFileStream;
    iVersion : String;
    iType : Byte;
    iUID : TUID;
begin
  UI.HideCursor;
  FStairNumber := 0;
  iStream := TGZFileStream.Create( FRuntime.Paths.WritePath + 'save', gzOpenRead );
  try
    try
      iVersion := iStream.ReadAnsiString;
      if iVersion <> VERSION then raise Exception.Create( 'Wrong save file version!' );
      FUIDStore := TUIDStore.CreateFromStream( iStream );
      UIDs := FUIDStore;
      iUID := iStream.ReadQWord;
      if ( iUID = 0 ) or ( iUID >= FUIDStore.Size ) then
        raise Exception.Create( 'Invalid Session UID in save file!' );
      FUID := iUID;
      FUIDStore.Register( Self, FUID );
      FPlayer := TPlayer.CreateFromStream( iStream );
      Lua.RegisterPlayer( FPlayer );
      FNextLevelID := iStream.ReadAnsiString;
      FTurnCount := iStream.ReadDWord;
      repeat
        iType := iStream.ReadByte;
        case iType of
          1 : Add( TLevel.CreateFromStream( iStream ) );
          2 : Add( TShop.CreateFromStream( iStream ) );
        end;
      until iType = 0;
    except
      Log( 'save file corrupt!' );
      // Stage 2 returns a failed Session outcome; menu re-entry is Stage 3.
      Exit( False );
    end;
  finally
    iStream.Free;
    DeleteFile( FRuntime.Paths.WritePath + 'save' );
  end;
  Lua.ProtectedCall( ['world', 'load_quest_maps'], [] );
  Result := True;
end;

function TGameSession.CanSave : Boolean;
begin
  Result := FPrepared and ( FPlayer <> nil ) and ( FLevel <> nil ) and
    ( FUIDStore <> nil );
end;

procedure TGameSession.Save;
var iStream : TGZFileStream;
    iChild : TNode;
    iParent : TNode;
begin
  iStream := TGZFileStream.Create( FRuntime.Paths.WritePath + 'save', gzOpenWrite );
  try
    iStream.WriteAnsiString( VERSION );
    FUIDStore.WriteToStream( iStream );
    iStream.WriteQWord( FUID );
    iParent := FPlayer.Parent;
    FPlayer.Detach;
    try
      FPlayer.WriteToStream( iStream );
      iStream.WriteAnsiString( FNextLevelID );
      iStream.WriteDWord( FTurnCount );
      for iChild in Self do
        if iChild is TShop then
        begin
          iStream.WriteByte( 2 );
          TShop( iChild ).WriteToStream( iStream );
        end
        else if iChild is TLevel then
        begin
          iStream.WriteByte( 1 );
          TLevel( iChild ).WriteToStream( iStream );
        end;
      iStream.WriteByte( 0 );
    finally
      FPlayer.Move( iParent );
    end;
  finally
    iStream.Free;
  end;
  Log( 'Saving done!' );
end;

end.
