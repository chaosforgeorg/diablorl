{$INCLUDE rl.inc}
// @abstract(One-playthrough state and ownership for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
unit rlgame;
interface

uses classes, sysutils, vnode, vuid, vrandom, vrlapp, vlua, rllevel, rlglobal, rlplayer, rlnpc, rllua, rlshop,
     rlpersistence, rlui, rlconfiguration;

type
  TGameSessionResult = ( GSR_RETURN_TO_MENU, GSR_LOAD_FAILED );

type TGameSession = class;
     PGameSession = ^TGameSession;

// Owns one playthrough, including entities temporarily detached from levels.
// Runtime services are borrowed.
TGameSession = class( TNode )
  private
    FRuntime         : TRLRuntime;
    FUI              : TGameUI;
    FLua             : TGameLua;
    FConfiguration   : TGameConfiguration;
    FPersistence     : TPersistence;
    FUIDStore        : TUIDStore;
    FPlayer          : TPlayer;
    FLevel           : TLevel;
    FTravellingGolem : TNPC;
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
    function SaveFile : AnsiString;
    function MortemFile : AnsiString;
    function Prepare : Boolean;
    procedure Run;
    function Load : Boolean;
    procedure AttachPlayer;
    procedure PlayerTurn;
    procedure ExecuteCommand( aCommand : Byte );
    procedure PresentDeath;
    procedure RecordResult;
    // Run requests made by the world natives during an action.
    procedure EndGame;
    procedure ExitLevel( const aLevelID : AnsiString; aStairs : Byte );
    property RNG : TRNG read GetRNG;
  public
    constructor Create( aRuntime : TRLRuntime; aPersistence : TPersistence ); reintroduce;
    destructor Destroy; override;
    function Execute( aLoad : Boolean ) : TGameSessionResult;
    function CanSave : Boolean;
    procedure Save;
    // Registers the world natives. aActive is the owner's Session field; it must
    // outlive the Lua state and is nil between Sessions.
    class procedure RegisterLuaAPI( aLua : TLua; aActive : PGameSession );
    property Ended : Boolean read FEnded;
end;

implementation

uses zstream, vutil, vrltools, vlualibrary, vluatools, vtigio, rlconfig, rlviews;

constructor TGameSession.Create( aRuntime : TRLRuntime; aPersistence : TPersistence );
begin
  inherited Create( TNodeContext.Create( aRuntime.Lua, nil ) );
  FRuntime := aRuntime;
  FUI := TGameUI( aRuntime.IO );
  FLua := TGameLua( aRuntime.Lua );
  FConfiguration := TGameConfiguration( aRuntime.Configuration );
  FPersistence := aPersistence;
  FNextLevelID := 'town';
end;

function TGameSession.GetRNG : TRNG;
begin
  Result := FRuntime.GameRNG;
end;

function TGameSession.SaveFile : AnsiString;
begin
  Result := FRuntime.Paths.WritePath + 'save';
end;

function TGameSession.MortemFile : AnsiString;
begin
  Result := FRuntime.Paths.WritePath + 'mortem.txt';
end;

function TGameSession.Execute( aLoad : Boolean ) : TGameSessionResult;
begin
  FLua.BindNodeContext( FContext );
  FLua.Call( ['world', 'start_session'], [] );
  FLoading := aLoad;
  if not Prepare then Exit( GSR_LOAD_FAILED );
  Run;
  Result := GSR_RETURN_TO_MENU;
end;

procedure TGameSession.AttachPlayer;
begin
  FPlayer.BindPresentation( FUI );
  FLua.SetValue( 'player', FPlayer );
  RegisterKillsClass( FLua.Raw, FPlayer.Kills, 'kills' );
  RegisterStatisticsClass( FLua.Raw, FPlayer.Stats, 'stats' );
end;

function TGameSession.Prepare : Boolean;
var iCount : Word;
begin
  FUI.HideCursor;
  if FLoading then
  begin
    if not Load then Exit( False );
  end
  else
  begin
    FUIDStore := TUIDStore.Create;
    FContext.BindUIDs( FUIDStore );
    FContext.Lua.Context.BindUIDs( FUIDStore );
    FUID := FUIDStore.Register( Self );
    if FileExists( SaveFile ) then
      DeleteFile( SaveFile );
    FUI.RunLayer( TKlassScreen.Create( FLua, FPlayerClass ) );
    FPlayerName := FConfiguration.FixedPlayerName;
    if FPlayerName = '' then
      FUI.RunLayer( TNameScreen.Create( FPlayerName ) );

    FPlayer := TPlayer.Create( FContext, FLua.Get( ['klasses', FPlayerClass, 'id'] ) );
    AttachPlayer;
    FPlayer.RunHook( Hook_OnCreate, [] );
    if FPlayerName <> '' then FPlayer.Name := FPlayerName;

    for iCount := 1 to FLua.Get( ['shops', '__counter'] ) do
      Add( TShop.Create( FContext, FLua.Get( ['shops', iCount, 'id'] ) ) );
    FUI.HideCursor;
  end;
  FPrepared := True;
  Result := True;
end;

procedure TGameSession.Run;
var iStartPos : TCoord2D;
    iLevelID  : AnsiString;
    iPrevious : TLevel;
  function FindCell( aCell : DWord ) : TCoord2D;
  var iCoord : TCoord2D;
  begin
    for iCoord in FLevel.Area do
      if FLevel.GetCell( iCoord ) = aCell then
        Exit( iCoord );
    raise EException.Create('FindCell for stairs failed!');
  end;

begin
  if FEnded then Exit;
  AttachPlayer;
  FLua.SetValue( 'TOWN_REVEAL', FConfiguration.GetBoolean( 'reveal_town' ) );
  FUI.Prepare( FPlayer );
  repeat
    // The previous level keeps its borrowed player until the UI leaves it,
    // because a new level's OnCreate can still show windows over it.
    iPrevious := FLevel;
    FPlayer.Detach;
    iLevelID := FNextLevelID;
    FLevel := FindChild( iLevelID ) as TLevel;

    if FLevel = nil then
    begin
       // We create a new level
       FLevel := TLevel.Create( FContext, RNG, FUI, iLevelID );
       // Makes FLevel a child of TGameSession, so we don't have to dispose of it manualy.
       Add(FLevel);
       if FLevel.Depth > FPlayer.MaxDepth then
         FPlayer.MaxDepth := FLevel.Depth;
       FStairNumber := FLevel.Cells.StairsUp;
    end;

    if FStairNumber <> FLevel.Cells.TownPortal then
      if FStairNumber = 0
        then iStartPos := FPlayer.Position
        else iStartPos := FindCell(FStairNumber);

    FUI.SetLevel( FLevel );
    if iPrevious <> nil then iPrevious.Player := nil;
    // Attach to the active level; Session also owns the player while detached.
    FLevel.Player := FPlayer;
    FPlayer.Move(FLevel);

    FLevel.RunHook( Hook_OnEnter, [FLoading] );
    FLoading         := False;

    // If player came throgh portal, destroy portal
    if FStairNumber = FLevel.Cells.TownPortal then
    begin
      iStartPos := FindCell(FStairNumber);
      if FLevel.Flags[ lfTown ] then
      begin
        FLevel.AddTravelPoint( iStartPos, 'Portal to Dungeon' );
        Inc(iStartPos.Y)
      end
      else
      begin
        FLevel.RemovePortals( FLevel.Cells.TownPortal );
        FPlayer.PortalLevel := '';
      end;
    end;

    // If not portal level then destroy any portals on it.
    if (FLevel.ID <> FPlayer.PortalLevel)and(not FLevel.Flags[ lfTown ]) then
      FLevel.RemovePortals( FLevel.Cells.TownPortal );

    FUI.PlayMusic(FLevel.Music);

    // Now we can properly displace the player :D
    // GenX and GenY are taken from the generator
    FLevel.Drop( FPlayer, iStartPos );

    //drop player's golem here
    if FTravellingGolem <> nil then
    begin
      FLevel.Drop( FTravellingGolem, iStartPos );
      FTravellingGolem := nil;
    end;

    FLevelChange     := False;
    FPlayer.Enemy := 0;
    // A path planned on the previous level does not apply here.
    FPlayer.Travelling := False;
    if FPlayer.Flags[ nfManaShield ] then
      FUI.Msg('Your protection worn off.');
    FPlayer.Flags[ nfInfravision ] := False;
    FPlayer.Flags[ nfManaShield  ] := False;
    FPlayer.Flags[ nfReflect     ] := False;
    repeat
      // Every NPC acts, and the player gains speed; then the player's turns.
      FLevel.TimeFlow(10);
      while ( not FEnded ) and ( not FPlayer.Died ) and ( FPlayer.SpeedCount >= 100 ) do
        PlayerTurn;
      if FPlayer.Died then FEnded := True;
      Inc(FTurnCount);
      // No callback is running between steps.
      FContext.FlushDestroyed;
    until FEnded or FLevelChange;
    FTravellingGolem := nil;
    if FPlayer.Parent <> nil then
    begin
      FTravellingGolem := TLevel(FPlayer.Parent).Find('golem') as TNPC;
      if FTravellingGolem <> nil then FTravellingGolem.Detach;
    end;
  until FEnded;
  if FPlayer.Died then PresentDeath;
  if (FPlayer.HP <= 0) or (FLevel.Depth > 12) then
  begin
    RecordResult;
    FUI.UnPrepare;
    FUI.ShowMortem( MortemFile );
  end;
  FPlayer.Detach;
  // UnPrepare still redraws the map, which reads the level's player.
  FUI.UnPrepare;
  FLevel.Player := nil;
end;

procedure TGameSession.PlayerTurn;
var iCommand : Byte;
begin
  FPlayer.BeginTurn( FTurnCount );
  if FPlayer.Died then Exit;

  // Portal possibility; the remaining speed drains as the level changes.
  if FLevelChange then
  begin
    FPlayer.SpeedCount := FPlayer.SpeedCount - 50;
    Exit;
  end;

  FPlayer.ReviewSurroundings;

  if FPlayer.Travelling then
  begin
    if not FPlayer.TravelStep then Exit;
    FUI.Delay( FConfiguration.GetInteger( 'run_delay' ) );
    FUI.WaitForAnimationCompletion( True );
    Exit;
  end;

  if FPlayer.RunCommand <> 0 then
  begin
    if not FPlayer.ContinueRun then Exit;
    iCommand := FPlayer.RunCommand;
  end
  else
    iCommand := FUI.GetCommand;

  ExecuteCommand( iCommand );
  FUI.WaitForAnimationCompletion( True );
end;

procedure TGameSession.ExecuteCommand( aCommand : Byte );
var iMenu  : DWord;
    iWhere : TCoord2D;
begin
  if aCommand in COMMANDS_MOVE then
    FPlayer.ActionMove( CommandDirection( aCommand ) )
  else if aCommand in COMMANDS_RUN then
  begin
    FPlayer.StartRun( aCommand );
    FUI.Delay( FConfiguration.GetInteger( 'run_delay' ) );
    FPlayer.ActionMove( CommandDirection( aCommand ) )
  end
  else if aCommand in COMMANDS_ATTACK then
    FPlayer.ActionAttack( CommandDirection( aCommand ) )
  else case aCommand of
    0 :;
    COMMAND_ESCAPE     :
    begin
      FUI.RunLayer( TGameMenu.Create( iMenu ) );
      case iMenu of
        GAMEMENU_HELP : FUI.RunLayer( TManualScreen.Create( FUI.ManualPath ) );
        GAMEMENU_QUIT : begin
          if (GodMode) or FUI.YesNoDialog('If you quit without saving, your character will be lost!'#10'Are you sure?') then
          begin
            FEnded := True;
            FPlayer.SpeedCount := FPlayer.SpeedCount - 50;
          end;
        end;
        GAMEMENU_SAVE : begin FEnded := True; Save; FPlayer.SpeedCount := FPlayer.SpeedCount - 50; end;
      end;
    end;
    COMMAND_ACT        :
    begin
      FUI.Msg('Choose direction...');
      FUI.Draw;
      FPlayer.ActionAct( CommandDirection( FUI.GetCommand ) );
    end;
    COMMAND_SWITCHMODE :
      if FPlayer.CanTravel and FUI.GetTravelDestination( iWhere ) then
        FPlayer.StartTravel( iWhere );
    COMMAND_MESSAGES   : FUI.ShowRecent;
    COMMAND_CAST       : FPlayer.CastSpell();
    COMMAND_LOOK       : FUI.ChooseTarget( TM_LOOK, COMMAND_LOOK );
    COMMAND_FIRE       : FPlayer.doFire;
    COMMAND_WAIT       : FPlayer.ActionWait;
    COMMAND_PICKUP     : FPlayer.doPickUp;

    COMMAND_QUICKSLOT1..COMMAND_QUICKSLOT8 : FPlayer.UseQuickSlot(aCommand-COMMAND_QUICKSLOT1+1);
    else FUI.Msg( 'Unknown command. Press {!' + FUI.CommandKey( COMMAND_ESCAPE ) + '} for menu and help file!' );
  end;
end;

procedure TGameSession.PresentDeath;
begin
  FUI.MainScreen.ClearBoth;
  FUI.Msg( 'You die... Press <{!' + FUI.UIKey( VTIG_IE_CONFIRM ) + '}>...' );
  FUI.Draw;
  FUI.PressEnter;
end;

procedure TGameSession.RecordResult;
var iEnemy  : TNPC;
    iScore  : LongInt;
    iResult : AnsiString;
begin
  iEnemy := nil;
  if FPlayer.Enemy <> 0 then iEnemy := FUIDStore.Get( FPlayer.Enemy ) as TNPC;
  iScore := FPlayer.WriteMemorial( MortemFile, iEnemy );

  iResult := 'died in '+FLevel.Name;
  if iEnemy <> nil     then iResult := 'killed by '+iEnemy.GetName(AName);
  if FLevel.Depth > 12 then iResult := 'reached Hell';
  FPersistence.Add( iScore, FPlayer.Name, FPlayer.Level, FLevel.Name, FLua.Get( ['klasses',FPlayer.Klass,'name'] ), iResult );

  FUI.ShowHOF( FPersistence.ScoreList );
end;

procedure TGameSession.EndGame;
begin
  FEnded := True;
  FPlayer.SpeedCount := FPlayer.SpeedCount - 50;
end;

procedure TGameSession.ExitLevel( const aLevelID : AnsiString; aStairs : Byte );
begin
  FLevelChange := True;
  FNextLevelID := aLevelID;
  FStairNumber := aStairs;
  FPlayer.SpeedCount := FPlayer.SpeedCount - 50;
end;

destructor TGameSession.Destroy;
begin
  // Runtime has retired all views before releasing its Session. Lua and its UID store
  // remain alive until every owned entity (parented or detached) is gone.
  FreeAndNil( FTravellingGolem );
  FreeAndNil( FPlayer );
  inherited Destroy;
  FLevel := nil;
  FContext.Lua.Context.BindUIDs( nil );
  FreeAndNil( FUIDStore );
  FreeAndNil( FContext );
  FLua.BindNodeContext( nil );
end;

function TGameSession.Load : Boolean;
var iStream : TGZFileStream;
    iVersion : String;
    iType : Byte;
    iUID : TUID;
begin
  FUI.HideCursor;
  FStairNumber := 0;
  iStream := TGZFileStream.Create( SaveFile, gzOpenRead );
  try
    try
      iVersion := iStream.ReadAnsiString;
      if iVersion <> VERSION then raise Exception.Create( 'Wrong save file version!' );
      FUIDStore := TUIDStore.CreateFromStream( iStream );
      FContext.BindUIDs( FUIDStore );
      FContext.Lua.Context.BindUIDs( FUIDStore );
      iUID := iStream.ReadQWord;
      if ( iUID = 0 ) or ( iUID >= FUIDStore.Size ) then
        raise Exception.Create( 'Invalid Session UID in save file!' );
      FUID := iUID;
      FUIDStore.Register( Self, FUID );
      FPlayer := TPlayer.CreateFromStream( iStream, FContext );
      AttachPlayer;
      FNextLevelID := iStream.ReadAnsiString;
      FTurnCount := iStream.ReadDWord;
      repeat
        iType := iStream.ReadByte;
        case iType of
          1 : Add( TLevel.CreateFromStream( iStream, FContext, RNG, FUI ) );
          2 : Add( TShop.CreateFromStream( iStream, FContext ) );
        end;
      until iType = 0;
    except
      Log( 'save file corrupt!' );
      // Runtime releases this partial Session before returning to its menu.
      Exit( False );
    end;
  finally
    iStream.Free;
    DeleteFile( SaveFile );
  end;
  FLua.ProtectedCall( ['world', 'load_quest_maps'], [] );
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
  iStream := TGZFileStream.Create( SaveFile, gzOpenWrite );
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

function ActiveSession( L : PLua_State ) : TGameSession;
begin
  Result := PGameSession( lua_touserdata( L, lua_upvalueindex( 1 ) ) )^;
  if Result = nil then
    luaL_error( L, 'No active Session!' );
end;

function lua_world_end_game( L : PLua_State ) : Integer; cdecl;
begin
  ActiveSession( L ).EndGame;
  Result := 0;
end;

function lua_world_exit( L : PLua_State ) : Integer; cdecl;
var iState   : TGameLuaStack;
    iSession : TGameSession;
    iStairs  : Byte;
begin
  iState.Init( L );
  iSession := ActiveSession( L );
  iStairs := iState.ToID( iSession.FLua, 2 );
  if iStairs = 0 then raise EException.Create( 'Cell 0! at exit' );
  iSession.ExitLevel( iState.ToString( 1 ), iStairs );
  Result := 0;
end;

function lua_world_get_shop( L : PLua_State ) : Integer; cdecl;
var iState : TGameLuaStack;
    iID    : AnsiString;
begin
  iState.Init( L );
  iID := iState.ToString( 1 );
  if iID = '' then Exit( 0 );
  iState.Push( ActiveSession( L ).FindChild( iID ) as TShop );
  Result := 1;
end;

function lua_world_get_level( L : PLua_State ) : Integer; cdecl;
var iState : TGameLuaStack;
    iID    : AnsiString;
begin
  iState.Init( L );
  iID := iState.ToString( 1 );
  if iID = '' then Exit( 0 );
  iState.Push( ActiveSession( L ).FindChild( iID ) as TLevel );
  Result := 1;
end;

function lua_world_get_turn_count( L : PLua_State ) : Integer; cdecl;
var iState : TGameLuaStack;
begin
  iState.Init( L );
  iState.Push( LongInt( ActiveSession( L ).FTurnCount ) );
  Result := 1;
end;

const lua_world_lib : array[0..5] of luaL_Reg = (
    ( name : 'get_level';        func : @lua_world_get_level),
    ( name : 'get_shop';         func : @lua_world_get_shop),
    ( name : 'get_turn_count';   func : @lua_world_get_turn_count),
    ( name : 'end_game';         func : @lua_world_end_game),
    ( name : 'exit';             func : @lua_world_exit),
    ( name : nil;                func : nil; )
);

class procedure TGameSession.RegisterLuaAPI( aLua : TLua; aActive : PGameSession );
begin
  lua_pushlightuserdata( aLua.Raw, aActive );
  aLua.Register( 'world', lua_world_lib, 1 );
end;

end.
