{$include rl.inc}
// @abstract(Core Game class for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
// @created(January 17, 2005)
//
// This unit holds the game's main class : TGame.

unit rlgame;
interface
uses classes, zstream,
     vsystem, vnode,
     rllevel, rlglobal, rlplayer, rllua, rlui, rlshop, rlpersistence;

type

{ TGame }

TGame = class(TSystem)
       Player      : TPlayer;
       Persistence : TPersistence;
       Level       : TLevel;
       NextLevelID : AnsiString;
       StairNumber : Byte;
       Lua         : TRLLua;
       TurnCount   : DWord;
       GraveYard   : TNode;
       constructor Create; override;
       procedure Prepare;
       procedure Run;
       destructor Destroy; override;
       procedure Load;
       procedure Save;
       procedure LoadCells;
     end;

// TGame singleton.
const Game : TGame = nil;

implementation
uses sysutils, vutil, vuid, vioevent,
     rlviews, vrltools, vluasystem, vsystems, rlnpc;

constructor TGame.Create;
var i: byte;
begin
  inherited Create;
  Game := Self;
  NextLevelID := 'town';
  TurnCount   := 0;
  for i := 1 to ParamCount do
  begin
    if ParamStr(i) = '-god' then
      GodMode := True;
  end;
  UI := Systems.Add(TGameUI.Create) as TGameUI;
  Lua := TRLLua.Create;
  LuaSystem := Systems.Add(Lua) as TLuaSystem;
  if GodMode then
  begin
    UI.RegisterDebugConsole( VKEY_F1 );
  end;

  GraveYard:=TNode.Create;
  Add(GraveYard);

  Persistence := TPersistence.Create;
end;

procedure TGame.Prepare;
var Count  : Word;

begin
  UI.HideCursor;
  LoadCells;

  UI.PlayMusic('music/dintro.wav');
  UI.RunUILoop( TUIIntroScreen.Create( UI.Root ) );
  UI.RunUILoop( TUIMainMenuScreen.Create( UI.Root ) );
  if GameEnd then Exit;
  if GameLoad
    then Load
    else
    begin
      UIDs := Systems.Add( TUIDStore.Create ) as TUIDStore;
      FUID := UIDs.Register( Self );

      // We create a new player
      if FileExists( WritePath + 'save' ) then DeleteFile( WritePath + 'save' );
      UI.RunUILoop( TUIKlassScreen.Create( UI.Root ) );
      UI.RunUILoop( TUINameScreen.Create( UI.Root ) );
      Player := TPlayer.Create(LuaSystem.Get(['klasses', GameClass, 'id']));
      if GameName <> '' then
        Player.Name := GameName;

      for Count := 1 to LuaSystem.Get(['shops','__counter']) do
        Add( TShop.Create(LuaSystem.Get(['shops',Count,'id'])) );

      UI.HideCursor;
    end;
end;

procedure TGame.Run;
var iGolem    : TNPC;
    iStartPos : TCoord2D;
    iLevelID  : AnsiString;
begin
  if not GameEnd then
  begin
    Lua.RegisterPlayer(Player);
    Lua.SetValue( 'TOWN_REVEAL', Option_TownReveal );
    iGolem := nil;
    UI.Prepare;
    repeat
      Player.Detach;
      iLevelID := NextLevelID;
      Level := FindChild( iLevelID ) as TLevel;

      if Level = nil then
      begin
         // We create a new level
         Level := TLevel.Create(iLevelID);
         // Makes Level a child of TGame, so we don't have to dispose of it manualy.
         Add(Level);
         if Level.Depth > Player.MaxDepth then
           Player.MaxDepth := Level.Depth;
         StairNumber := CELL_STAIR_UP;
      end;

      if StairNumber <> CELL_TOWN_PORTAL then
        if StairNumber = 0
          then iStartPos := Player.Position
          else iStartPos := Level.MapArea.FindCell([StairNumber]);

      UI.SetLevel( Level );
      // Makes Player a child of TLevel. We don't have to dispose of it manualy.
      // And also it sets the player in his world ;-)
      Player.Move(Level);

      Level.RunHook( Hook_OnEnter, [GameLoad] );
      GameLoad := False;

      // If player came throgh portal, destroy portal
      if StairNumber = CELL_TOWN_PORTAL then
      begin
        iStartPos := Level.MapArea.FindCell([StairNumber]);
        if Level.Flags[ lfTown ] then
        begin
          Level.AddTravelPoint( iStartPos, 'Portal to Dungeon' );
          Inc(iStartPos.Y)
        end
        else
        begin
          Level.RemovePortals( CELL_TOWN_PORTAL );
          Player.PortalLevel := '';
        end;
      end;

      // If not portal level then destroy any portals on it.
      if (Level.ID <> Player.PortalLevel)and(not Level.Flags[ lfTown ]) then
        Level.RemovePortals( CELL_TOWN_PORTAL );

      UI.PlayMusic(Level.Music);

      // Now we can properly displace the player :D
      // GenX and GenY are taken from the generator
      Level.Drop( Player, iStartPos );

      //drop player's golem here
      if iGolem <> nil then Level.Drop( iGolem, iStartPos );

      LevelChange := False;
      Player.Enemy := 0;
      if Player.Flags[ nfManaShield ] then
        UI.Msg('Your protection worn off.');
      Player.Flags[ nfInfravision ] := False;
      Player.Flags[ nfManaShield  ] := False;
      Player.Flags[ nfReflect     ] := False;
      repeat
        Level.TimeFlow(10);
        Inc(TurnCount);
        Graveyard.DestroyChildren;
      until GameEnd or LevelChange;
      iGolem := nil;
      if Player.Parent <> nil then
      begin
        iGolem := TLevel(Player.Parent).Find('golem') as TNPC;
        if iGolem <> nil then iGolem.Detach;
      end;
    until GameEnd;
    if (Player.HP <= 0) or (Level.Depth > 12) then
    begin
      Game.Player.WriteMemorial;
      UI.UnPrepare;
      UI.ShowMortem;
    end;
    Player.Detach;
    UI.UnPrepare;
    UI.RunUILoop( TUIOutroScreen.Create( UI.Root ) );
  end;
  FreeAndNil(UI);
end;

destructor TGame.Destroy;
begin
  FreeAndNil( Persistence );
  inherited Destroy;
  Log('Destroyed.');
end;

procedure TGame.Load;
var ISt: TGZFileStream;
    ver : string;
    iType : Byte;
begin
  UI.HideCursor;
  LoadCells;
  StairNumber := 0;
  ISt := TGZFileStream.Create( WritePath + 'save', gzOpenRead );
  try
    try
      ver := ISt.ReadAnsiString;
      if ver <> VERSION then raise Exception.Create('Wrong save file version!');

      UIDs := Systems.Add( TUIDStore.CreateFromStream( ISt ) ) as TUIDStore;
      FUID := ISt.ReadQWord;

      Player := TPlayer.CreateFromStream(ISt);
      NextLevelID := ISt.ReadAnsiString;
      TurnCount := ISt.ReadDWord;

      repeat
        iType := ISt.ReadByte;
        case iType of
          1 : Add( TLevel.CreateFromStream(ISt) );
          2 : Add( TShop.CreateFromStream(ISt) );
        end;
      until iType = 0;

    except
      FreeAndNil(ISt);
      DeleteFile( WritePath + 'save' );
      Log('save file corrupt!');
      Prepare;
    end;
  finally
    FreeAndNil(ISt);
    DeleteFile( WritePath + 'save' );
  end;
  LuaSystem.ProtectedCall(['world','load_quest_maps'],[]);
end;

procedure TGame.Save;
var OSt: TGZFileStream;
    iChild : TNode;
begin
  OSt := TGZFileStream.Create( WritePath + 'save', gzOpenWrite );
  OSt.WriteAnsiString(VERSION);

  UIDs.WriteToStream( OSt );
  OSt.WriteQWord(FUID);


  Player.Detach;
  Player.WriteToStream(OSt);

  Ost.WriteAnsiString(NextLevelID);
  Ost.WriteDWord(TurnCount);

  for iChild in Self do
    if iChild is TShop then
    begin
      Ost.WriteByte(2);
      TShop(iChild).WriteToStream(OSt);
    end
    else if iChild is TLevel then
    begin
      Ost.WriteByte(1);
      TLevel(iChild).WriteToStream(OSt);
    end;
  Ost.WriteByte(0);

  FreeAndNil(OSt);
  Level.Add(Player);
  Log('Saving done!');
end;

procedure TGame.LoadCells;
var CellCount : Word;
    Count,C   : Word;
begin
  for Count := 1 to 255 do CellData[Count].id := '';

  CellCount := LuaSystem.Get(['cells','__counter']);

  for Count := 1 to CellCount do
  with LuaSystem.GetTable( ['cells', Count] ) do
  try
    with CellData[Count] do
    begin
      id      := GetString('id');

      flags   := GetFlags('flags');
      color   := GetInteger('color');
      pic     := GetString('pic')[1];
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

  CELL_FLOOR         := LuaSystem.Defines['floor'];
  CELL_STAIR_UP      := LuaSystem.Defines['stairs_up'];

  CELL_TOWN_PORTAL   := LuaSystem.Defines['shimmering_portal'];
end;

end.
