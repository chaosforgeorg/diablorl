{$include rl.inc}
// @abstract(UI base class for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)

unit rlui;

interface
uses {$IFDEF WINDOWS}Windows,{$ENDIF} Classes, SysUtils, vioevent, rlviews, rlgviews, vcolor, vuielement, viotypes, vioconsole, vuiconsole, vluastate,
  viorl, vrltools, rlglobal, rlthing, vconuirl,
  vutil, rlplayer, rlitem, rlconfig;

{type
  TItemWindow = class(TWindow)
    constructor Create(newParent: TUIElement; newItem: TItem; newTitle: ansistring = '');
    procedure Draw; override;
    procedure Run;
  private
    Item: TItem;
  end;}

{TGameUI}

type
  TGameUI = class(TIORL, IConUIASCIIMap)
  public
    constructor Create( aConfig : TDiabloConfig );
    function getGylph( const aCoord : TCoord2D ): TIOGylph;
    destructor Destroy; override;
    procedure Draw();
    procedure ShowMortem();
    procedure Prepare;
    procedure UnPrepare;
    // Adds a message for the message buffer
    procedure Msg( const aMessage : Ansistring); override;
    // Marks the given tile with specified glyph
    function Strip( const aInput : AnsiString ) : AnsiString;
    function CodedLength( const aInput : AnsiString ) : Word;
    //focuses onto the specified cell
    procedure Focus(c: TCoord2D);
    //creates a screenshot
    procedure ScreenShot(BBCode: boolean = False);
    //waits for Enter key
    procedure PressEnter();
    //front-end for TInput.GetCommand
    function GetCommand(valid: TCommandSet = []): byte;
    //Put a message onto status bar
    procedure UpdateStatus(c: TCoord2D);
    procedure UpdateStatus(STarget: TThing);
    //reviews last messages
    procedure ShowRecent;
    //shows game manual
    procedure ShowManual;
    procedure ShowHOF;
    //Plot text window
    procedure PlotText( const Text: ansistring );
    procedure ItemInfo( aItem : TItem );
    procedure Update( aMSec : DWord ); override;
    //Sound procedures wrapping
    procedure PlayMusic( const sID: ansistring );
    procedure PlaySound( const sID: ansistring; aSource : TCoord2D );
    procedure PlaySound( const sID: ansistring );
    procedure HaltSound();
    procedure Mute();
    procedure Unmute();
    procedure SetMusicVolume(Volume: byte);
    procedure SetSoundVolume(Volume: byte);
    function GetTravelDestination( out aWhere : TCoord2D ) : Boolean;
    function YesNoDialog( const aLine1 : AnsiString; const aLine2 : AnsiString = '' ) : Boolean;
    class procedure RegisterLuaAPI(State: TLuaState);
  private
    function ReadFromMPQ( const aFileName : AnsiString ) : TStream;
    procedure ReadConfig();
    function GetPlayer : TPlayer;
    function TranslateColor( aColor : Byte; aPosition : TCoord2D ) : Byte;
    function TranslateColorFull( aColor : Byte; aPosition : TCoord2D ) : TColor;
    function ScreenShotCallback( aEvent : TIOEvent ) : Boolean;
    function BBScreenShotCallback( aEvent : TIOEvent ) : Boolean;
  private
    FAnimTime      : DWord;
    FAnimCount     : DWord;
    FMainScreen    : TUIMainScreen;
    FUIConsole     : TUIConsole;
    FSizeX, FSizeY : Word;
    FGraphicsMode  : Boolean;
    FMPQHandle     : THandle;
    FLastSVolume   : Byte;
    FLastMVolume   : Byte;
    FLastMusic     : AnsiString;
  public
    property MainScreen : TUIMainScreen read FMainScreen;
    property SizeX : Word read FSizeX;
    property SizeY : Word read FSizeY;
    property Player : TPlayer read GetPlayer;
    property GraphicsMode : Boolean read FGraphicsMode;
  end;

function CommandDirection(Command: byte): TDirection;

var
  UI: TGameUI = nil;

implementation

uses DateUtils, variants, 
    {$IFDEF UNIX}vcursesio, vcursesconsole, {$ELSE}vtextio, vtextconsole, {$ENDIF}
    vuitypes, vluasystem, rlshop, rllua, rlgame, rlpersistence,
    vsystems, vstormlibrary,
    {$IFDEF BEARLIB}vbeario, vbearconsole,{$ELSE}vsdlio, vglulibrary, vglconsole,{$ENDIF}
    vlog, vdebug, vmath, rllevel, vsound, vfmodsound, vsdlsound;

function CommandDirection(Command: byte): TDirection;
begin
  case Command of
    COMMAND_WALKWEST, COMMAND_RUNWEST, COMMAND_ATKWEST : CommandDirection{%H-}.Create(4);
    COMMAND_WALKEAST, COMMAND_RUNEAST, COMMAND_ATKEAST : CommandDirection.Create(6);
    COMMAND_WALKNORTH,COMMAND_RUNNORTH,COMMAND_ATKNORTH: CommandDirection.Create(8);
    COMMAND_WALKSOUTH,COMMAND_RUNSOUTH,COMMAND_ATKSOUTH: CommandDirection.Create(2);
    COMMAND_WALKNW,   COMMAND_RUNNW,   COMMAND_ATKNW   : CommandDirection.Create(7);
    COMMAND_WALKNE,   COMMAND_RUNNE,   COMMAND_ATKNE   : CommandDirection.Create(9);
    COMMAND_WALKSW,   COMMAND_RUNSW,   COMMAND_ATKSW   : CommandDirection.Create(1);
    COMMAND_WALKSE,   COMMAND_RUNSE,   COMMAND_ATKSE   : CommandDirection.Create(3);
    COMMAND_WAIT: CommandDirection.Create(5);
    else
      CommandDirection.Create(0);
  end;
end;

{ TGameUI }

constructor TGameUI.Create( aConfig : TDiabloConfig );
var iStyle  : TUIStyle;
    {$IFDEF BEARLIB}
    iFlags  : TBearFlags;
    {$ELSE}
    iFlags  : TSDLIOFlags;
    {$ENDIF}
    iSound  : AnsiString;
    iMPQ    : AnsiString;
    i       : byte;
begin
  Log( LOGINFO, 'Creating game UI...' );

  Log( LOGINFO, 'Loading configuration file "'+ConfigurationPath+'"...' );

  FSizeX        := aConfig.Configure('console_x',80);
  FSizeY        := aConfig.Configure('console_y',25);
  FGraphicsMode := aConfig.Configure('graphics',False);
  FMPQHandle    := 0;

  for i := 1 to ParamCount do
  begin
    if ParamStr(i) = '-console' then
      FGraphicsMode := False;
  end;

  if FGraphicsMode then
  begin
    Log( LOGINFO, 'Setting up graphics mode...' );
    {$IFDEF WINDOWS}
    if not GodMode then
    begin
      FreeConsole;
      vdebug.DebugWriteln := nil;
    end
    else
    begin
      Logger.AddSink( TConsoleLogSink.Create( LOGDEBUG, true ) );
    end;
    {$ENDIF}

    FGraphicsMode := True;
    {$IFDEF BEARLIB}
    iFlags := [];
    if aConfig.Configure( 'fullscreen', false ) then
      Include( iFlags, Bear_Fullscreen );
    Log( LOGINFO, 'Initializing driver...' );
    FIODriver := TBearIODriver.Create( aConfig.Configure('screen_x',1024), aConfig.Configure('screen_y',768), iFlags );
    Log( LOGINFO, 'Creating renderer, using font file "'+DataPath+'font10x18.png"...' );
    FConsole := TBearConsoleRenderer.Create( FSizeX, FSizeY, [VIO_CON_CURSOR, VIO_CON_EXTCOLOR, VIO_CON_EXTOUT] );
    {$ELSE}
    iFlags := [ SDLIO_OpenGL, SDLIO_Resizable ];
    if aConfig.Configure( 'fullscreen', false ) then
      Include( iFlags, SDLIO_Fullscreen );
    Log( LOGINFO, 'Initializing driver...' );
    FIODriver := TSDLIODriver.Create( aConfig.Configure('screen_x',1024), aConfig.Configure('screen_y',768), 32, iFlags );
    Log( LOGINFO, 'Creating renderer, using font file "'+DataPath+'font10x18.png"...' );
    FConsole := TGLConsoleRenderer.Create( DataPath+'font10x18.png',32,256-32,32, FSizeX, FSizeY, 0, [VIO_CON_CURSOR, VIO_CON_EXTCOLOR] );
    Log( LOGINFO, 'Loading GLU' );
    LoadGLU;
    gluOrtho2D(0, FIODriver.GetSizeX, FIODriver.GetSizeY,0 );
    {$ENDIF}
  end
  else
  begin
    if not (FSizeY in [25,30,40,50]) then
      FSizeY := 30;
    Log( LOGINFO, 'Setting up console mode...' );
    FGraphicsMode := False;
    Log( LOGINFO, 'Initializing driver...' );
    {$IFDEF UNIX}
    FIODriver := TCursesIODriver.Create( FSizeX, FSizeY );
    {$ELSE}
    FIODriver := TTextIODriver.Create( FSizeX, FSizeY );
    {$ENDIF}
    Log( LOGINFO, 'Creating renderer...' );
    {$IFDEF UNIX}
    FConsole  := TCursesConsoleRenderer.Create( FSizeX, FSizeY, [VIO_CON_BGCOLOR, VIO_CON_CURSOR] );
    {$ELSE}
    FConsole  := TTextConsoleRenderer.Create( FSizeX, FSizeY, [VIO_CON_BGCOLOR, VIO_CON_CURSOR] );
    {$ENDIF}
    if (FIODriver.GetSizeX < FSizeX) or (FIODriver.GetSizeY < FSizeY) then
    begin
      Log( LOGERROR, 'Too small console available (%dx%d)!', [ FIODriver.GetSizeX, FIODriver.GetSizeY ] );
      raise EIOException.Create('Too small console available, resize your console to '+IntToStr(FSizeX)+'x'+IntToStr(FSizeY)+'!');
    end;
  end;
  Log( LOGINFO, 'IO driver and console initialized.' );
  FIODriver.SetTitle('DiabloRL','DiabloRL');

  iSound := aConfig.Configure('sound','NONE');
  if iSound <> 'NONE' then
  begin
    Log( LOGINFO, 'Sound mode requested, loading StormLib...' );
    LoadStorm;
    iMPQ := aConfig.Configure('mpq','DIABDAT.MPQ');
    if not SFileOpenArchive( PChar(iMPQ), 0, STREAM_FLAG_READ_ONLY, @FMPQHandle ) then
    begin
      Log('Failed to open MPQ!');
    end;
    if iSound = 'DEFAULT' then iSound := {$IFDEF WINDOWS}'FMOD'{$ELSE}'SDL'{$ENDIF};
    if iSound = 'FMOD'
      then Sound := Systems.Add(TFMODSound.Create) as TSound
      else Sound := Systems.Add(TSDLSound.Create) as TSound;
    Sound.SetMusicVolume( aConfig.Configure('music_volume',100) );
    Sound.SetSoundVolume( aConfig.Configure('sound_volume',100) );
  end;
  Log( LOGINFO, 'Loading default style...' );

  iStyle := TUIStyle.Create('default');
  iStyle.Add('','fore_color', LightGray );
  iStyle.Add('','selected_color', White );
  iStyle.Add('','inactive_color', Red );
  iStyle.Add('','selinactive_color', LightRed );
  iStyle.Add('menu','fore_color', DarkGray );
  iStyle.Add('','back_color', Black );
  iStyle.Add('','scroll_chars', '^v' );
  iStyle.Add('','icon_color', LightGray );
  iStyle.Add('','opaque', False );
  //iStyle.Add('','frame_chars', '-|-|/\\/-|^v' )
  iStyle.Add('','frame_chars', #196+#179+#196+#179+#218+#191+#192+#217+#196+#179+'^v' );
  iStyle.Add('window','fore_color', LightGray );
  iStyle.Add('full_window','fore_color', LightGray );
  iStyle.Add('','frame_color', DarkGray );
  iStyle.Add('full_window','title_color', LightGray );
  iStyle.Add('full_window','footer_color', LightGray );
  iStyle.Add('input','fore_color', White );
  iStyle.Add('input','back_color', Black );
  iStyle.Add('text','fore_color', LightGray );
  iStyle.Add('text','back_color', ColorNone );

  Log( LOGINFO, 'Initializing core driver...' );
  inherited Create( FIODriver, FConsole, iStyle );
  Log( LOGINFO, 'Configuring...' );
  Configure( aConfig );
  FUIConsole.Init( FConsole );
  ReadConfig;
  Log( LOGINFO, 'GameIO ready.' );
  FAnimCount := 0;
  TItem.InitColors( FGraphicsMode );
end;

procedure TGameUI.Draw;
begin
  FConsole.Clear;
  FMainScreen.Map.SetCenter(FPlayer.Position);
end;

function TGameUI.Strip ( const aInput : AnsiString ) : AnsiString;
begin
  Exit( StripEncoding( aInput ) );
end;

function TGameUI.CodedLength ( const aInput : AnsiString ) : Word;
begin
  Exit( Length( StripEncoding( aInput ) ) );
end;

procedure TGameUI.Focus(c: TCoord2D);
begin
  FMainScreen.Map.SetCenter( c );
end;

procedure TGameUI.ShowRecent;
begin
  UI.RunUILoop( TUIMessagesScreen.Create( Root, FMainScreen.Msg.Content ) );
end;

procedure TGameUI.ShowManual;
begin
  if not FileExists('manual.txt') then  Exit;
  UI.RunUILoop( TUIManualScreen.Create( Root ) );
end;

procedure TGameUI.UpdateStatus(c: TCoord2D);
begin
  FMainScreen.Status.Update(c);
end;

procedure TGameUI.UpdateStatus(STarget: TThing);
begin
  FMainScreen.Status.Update(STarget);
end;


function TGameUI.getGylph( const aCoord : TCoord2D ): TIOGylph;
var iPicture : Word;
    iChar    : Char;
    iLight   : Byte;
    iSingle  : Single;
    iColor   : TColor;
begin
  if not FLevel.isProperCoord( aCoord ) then Exit(IOGylph(' ',0));
  iPicture := Game.Level.GetPicture( aCoord );
  getGylph.ASCII := Chr(iPicture mod 256);
  if not FGraphicsMode then
  begin
    getGylph.Color := TranslateColor( iPicture div 256, aCoord );
    Exit;
  end;
  iColor   := TranslateColorFull( iPicture div 256, aCoord );
  iLight   := FLevel.Vision.GetLight( aCoord );
  iSingle  := Clampf((iLight+3) / 10, 0.3, 1.0 );
  getGylph.Color := ScaleColor( iColor, iSingle ).toIOColor;
end;

procedure TGameUI.Prepare;
begin
  FConsole.Clear;
  FMainScreen    := TUIMainScreen.Create( FUIRoot );
  FMessages      := FMainScreen.Msg;
  FMap           := FMainScreen.Map;
  FPlayer        := Game.Player;
end;

procedure TGameUI.UnPrepare;
begin
  FMessages := nil;
  FMap      := nil;
  FreeAndNil( FMainScreen );
end;

procedure TGameUI.Msg ( const aMessage : Ansistring ) ;
begin
  inherited Msg( Capitalized( aMessage ) );
end;

function TGameUI.GetCommand(valid: TCommandSet = []): byte;
begin
  Inc(FAnimCount);
  GetCommand := inherited WaitForCommand( valid );
  if TPlayer(FPlayer).SpeedCount >= 100 then FMainScreen.Msg.Update;
end;

{var Spec : Variant;
begin
    case GetCommand of
      COMMAND_SOUNDVOLUP: Sound.setSoundVolume(min(Sound.mySoundVolume div
          10 * 10 + 10, 100));
      COMMAND_SOUNDVOLDN: Sound.setSoundVolume(max(Sound.mySoundVolume div
          10 * 10 - 10, 0));
      COMMAND_MUSICVOLUP: Sound.setMusicVolume(min(Sound.myMusicVolume div
          10 * 10 + 10, 100));
      COMMAND_MUSICVOLDN: Sound.setMusicVolume(max(Sound.myMusicVolume div
          10 * 10 - 10, 0));
    end;

  until not (GetCommand in [COMMAND_SOUNDVOLUP, COMMAND_SOUNDVOLDN,
      COMMAND_MUSICVOLUP, COMMAND_MUSICVOLDN]);
  FMainScreen.Msg.Update;
end;}

procedure TGameUI.PressEnter;
begin
  WaitForKey([VKEY_ENTER]);
  PlaySound('sfx/items/titlslct.wav');
end;

destructor TGameUI.Destroy();
begin
  if Sound <> nil    then FreeAndNil( Sound );
  if FMPQHandle <> 0 then SFileCloseArchive( FMPQHandle );
  inherited Destroy;
end;

procedure TGameUI.PlotText(const Text: ansistring);
begin
  RunUILoop( TUIPlotWindow.Create( FUIRoot, Text ) );
  HaltSound();
end;

procedure TGameUI.ItemInfo( aItem: TItem );
begin
  RunUILoop( TUIItemInfo.Create( FUIRoot, aItem ) );
end;

procedure TGameUI.Update( aMSec : DWord );
begin
  FAnimTime := Driver.GetMs;
  inherited Update( aMSec );
end;

procedure TGameUI.ShowMortem;
begin
  if not FileExists('mortem.txt') then Exit;
  RunUILoop( TUIMortemScreen.Create( FUIRoot ) );
end;

procedure TGameUI.ShowHOF;
begin
  RunUILoop( TUIHighscoreViewer.Create( FUIRoot, Game.Persistence.ScoreList ) );
end;

procedure TGameUI.ReadConfig;
begin
  Config.LoadKeybindings('Keybindings');
  FIODriver.RegisterInterrupt( Config.GetKeyCode( COMMAND_SSHOT ), @ScreenShotCallback );
  FIODriver.RegisterInterrupt( Config.GetKeyCode( COMMAND_SSHOTBB ), @BBScreenShotCallback );
end;

function TGameUI.GetPlayer : TPlayer;
begin
  Exit( TPlayer(FPlayer) );
end;

function TGameUI.TranslateColor ( aColor : Byte; aPosition : TCoord2D ) : Byte;
begin
  if aColor < 16 then
    Exit( aColor );
  case aColor of
    ColorWall  : Exit( Game.Level.BaseWallColor );
    ColorFloor : Exit( Game.Level.BaseFloorColor );
    ColorPortal: case FAnimCount mod 4 of
        0: Exit(Blue);
        1, 3: Exit(LightBlue);
        2: Exit(White);
      end;
    ColorRedPortal: case FAnimCount mod 4 of
        0: Exit(Red);
        1, 3: Exit(LightRed);
        2: Exit(White);
      end;
    ColorFire: case FAnimCount mod 4 of
        0: Exit(Red);
        1, 3: Exit(LightRed);
        2: Exit(Yellow);
      end;
    ColorLava : if (aPosition.x + aPosition.y) mod 2 = 1 then Exit(LightRed) else Exit(Yellow);
    else
      Exit(Red)
  end;
end;

function TGameUI.TranslateColorFull ( aColor : Byte; aPosition : TCoord2D ) : TColor;
const
  PortalColors    : array[0..2] of Byte = ( Blue, White,  Blue );
  RedPortalColors : array[0..2] of Byte = ( Red,  White,  Red  );
  FireColors      : array[0..2] of Byte = ( Red,  Yellow, Red  );
var iValue : Single;
    iStep  : Byte;
    iCycle : Word;
begin
  case aColor of
    ColorLava :
    begin
      iValue := FAnimTime / 400.0;
      case (aPosition.x + aPosition.y) mod 3 of
        0 : Exit( ColorLerp( NewColor( Yellow ),   NewColor( LightRed ), ( Sin( iValue )          + 1.0 ) / 2.0 ) );
        1 : Exit( ColorLerp( NewColor( Yellow ),   NewColor( LightRed ), ( Sin( iValue + Pi / 2 ) + 1.0 ) / 2.0 ) );
        2 : Exit( ColorLerp( NewColor( Yellow ),   NewColor( LightRed ), ( Sin( iValue + Pi )     + 1.0 ) / 2.0 ) );
      end;
    end;
    ColorWall  : Exit( Game.Level.WallColor );
    ColorFloor : Exit( Game.Level.FloorColor );
    ColorPortal,
    ColorRedPortal,
    ColorFire:
    begin
      iCycle := FAnimTime mod 4000;
      iStep  := iCycle div 2000;
      iValue := (iCycle mod 2000) / 2000.0;
      case aColor of
        ColorPortal    : Exit( ColorLerp( NewColor( PortalColors[ iStep ] ),   NewColor( PortalColors[ iStep+1 ] ),    iValue ) );
        ColorRedPortal : Exit( ColorLerp( NewColor( RedPortalColors[ iStep ] ),NewColor( RedPortalColors[ iStep+1 ] ), iValue ) );
        ColorFire      : Exit( ColorLerp( NewColor( FireColors[ iStep ] ),     NewColor( FireColors[ iStep+1 ] ),      iValue ) );
      end;
    end;
  end;

  Exit( NewColor( TranslateColor( aColor, aPosition ) ) );
end;

function TGameUI.ScreenShotCallback(aEvent: TIOEvent): Boolean;
begin
  ScreenShot( False );
  Exit( True );
end;

function TGameUI.BBScreenShotCallback(aEvent: TIOEvent): Boolean;
begin
  ScreenShot( True );
  Exit( True );
end;

procedure TGameUI.ScreenShot(BBCode: boolean = False);
var
  key: word;
begin
  Key := 1;
  while FileExists( WritePath + 'DiabloRL' + IntToStr(Key) + '.txt' ) do
    Inc(Key);
  if BBCode then
    FUIConsole.ScreenShot( WritePath + 'DiabloRL' + IntToStr(Key) + '.txt', 1 )
  else
    FUIConsole.ScreenShot( WritePath + 'DiabloRL' + IntToStr(Key) + '.txt', 0 );
  if not FileExists( WritePath + 'DiabloRL' + IntToStr(Key) + '.txt' ) then
    exit;
  if BBCode then
    Msg( 'BB code screenshot "' + 'DiabloRL' + IntToStr(Key) + '.txt" created.' )
  else
    Msg( 'Screenshot "' + 'DiabloRL' + IntToStr(Key) + '.txt" created.' );
end;

procedure TGameUI.PlayMusic(const sID: ansistring);
var iStream : TStream;
begin
  if Sound = nil then Exit;
  if not Sound.MusicExists(sID) then
  if FileExists( SoundPath + sID ) then
    Sound.RegisterMusic( SoundPath + sID, sID )
  else
  begin
    iStream := ReadFromMPQ( sID );
    if iStream <> nil
      then Sound.RegisterMusic( iStream, iStream.Size, sID, '.wav' )
      else Exit;
  end;
  FLastMusic := sID;
  Sound.PlayMusic(sID);
end;

procedure TGameUI.PlaySound(const sID: ansistring; aSource : TCoord2D );
const MAXDISTANCE = 15;
var iStream   : TStream;
    iVolume   : Integer;
    iDelta    : Integer;
    iPan      : Integer;
begin
  if Sound = nil then Exit;
  if not Sound.SampleExists(sID) then
  if FileExists( SoundPath + sID ) then
    Sound.RegisterSample( SoundPath + sID, sID )
  else
  begin
    iStream := ReadFromMPQ( sID );
    if iStream <> nil
      then Sound.RegisterSample( iStream, iStream.Size, sID )
      else Exit;
  end;
  iVolume := 32 + Round((MAXDISTANCE - Min(Distance(Player.Position,aSource) - 1,MAXDISTANCE) * 96) / MAXDISTANCE);
  iDelta  := aSource.x - Player.Position.x;
  iPan    := Min( Abs( iDelta ) - 1, MAXDISTANCE) * Sgn( iDelta );
  iPan    := Round(((iPan + MAXDISTANCE) * 255) / ( 2 * MAXDISTANCE ) );
  Sound.PlaySample(sID,Clamp(iVolume,0,255),Clamp(iPan,-127,128));
end;

procedure TGameUI.PlaySound(const sID: ansistring);
var iStream : TStream;
begin
  if Sound = nil then Exit;
  if not Sound.SampleExists(sID) then
  if FileExists( SoundPath + sID ) then
    Sound.RegisterSample( SoundPath + sID, sID )
  else
  begin
    iStream := ReadFromMPQ( sID );
    if iStream <> nil
      then Sound.RegisterSample( iStream, iStream.Size, sID )
      else Exit;
  end;
  Sound.PlaySample(sID);
end;

procedure TGameUI.HaltSound();
begin
  if Sound = nil then Exit;
  Sound.StopSound;
end;

procedure TGameUI.Mute();
begin
  if Sound = nil then Exit;
  //Sound.SetSoundVolume(0);
  //Sound.SetMusicVolume(0);
end;

procedure TGameUI.Unmute();
begin
  if Sound = nil then Exit;
  //Sound.SetSoundVolume(FLastSVolume);
  //Sound.SetMusicVolume(FLastMVolume);
end;

procedure TGameUI.SetMusicVolume(Volume: byte);
var iResume : Boolean;
begin
  if Sound = nil then Exit;
  iResume := ( FLastMVolume = 0 );
  FLastMVolume := Volume;
  Sound.SetMusicVolume(Volume);
  if iResume and (Volume > 0) then Sound.PlayMusic( FLastMusic );
end;

procedure TGameUI.SetSoundVolume(Volume: byte);
begin
  if Sound = nil then Exit;
  FLastSVolume := Volume;
  Sound.SetSoundVolume(Volume);
end;

function TGameUI.GetTravelDestination ( out aWhere : TCoord2D ) : Boolean;
begin
  FUILoopResult := 0;
  RunUILoop( TUITravelWindow.Create( Root ) );
  if FUILoopResult <> 0 then
  begin
    aWhere := (UI.Player.Parent as TLevel).TravelPoints[ FUILoopResult-1 ].Where;
    Exit( True );
  end;
  Exit( False );
end;

function TGameUI.YesNoDialog ( const aLine1 : AnsiString; const aLine2 : AnsiString = '' ) : Boolean;
begin
  FUILoopResult := 0;
  RunUILoop( TUIConfirmDialog.Create( Root, aLine1, aLine2 ) );
  Exit( FUILoopResult > 0 );
end;

{ TItemWindow }

{constructor TItemWindow.Create(newParent: TUIElement;
  newItem: TItem; newTitle: ansistring = '');
begin
  inherited Create(newParent, NewRectXY(5, 9, 75, 15), newTitle);
  Item := newItem;
end;

procedure TItemWindow.Draw;
begin
  inherited Draw;
  Output.CenterDrawString(40, 11, Item.Color, Item.GetName(PlainName));
  if Item.GetName(Status1) = '' then
    Output.CenterDrawString(40, 12, Item.Color, Item.GetName(Status2))
  else
  begin
    Output.CenterDrawString(40, 12, Item.Color, Item.GetName(Status1));
    Output.CenterDrawString(40, 13, Item.Color, Item.GetName(Status2));
  end;
end;

procedure TItemWindow.Run;
begin
  Show;
  Draw;
  UI.GetKey;
end;}

{ TMainUIArea }

function lua_ui_get_key(L: Plua_State): integer; cdecl;
var
  State: TRLLuaState;
  KeyFilter: TKeySet = [];
  Count: byte;
begin
  State.Init(L);
  Count := State.StackSize;
  while Count > 0 do
  begin
    include(KeyFilter, State.ToInteger(Count));
    Dec(Count);
  end;
  State.Push(UI.WaitForKey(KeyFilter));
  Result := 1;
end;

function lua_ui_msg(L: Plua_State): integer; cdecl;
var
  State: TRLLuaState;
begin
  State.Init(L);
  if State.StackSize = 0 then
    Exit(0);
  UI.Msg(State.ToString(1));
  UI.Draw;
  Result := 0;
end;

function lua_ui_delay(L: Plua_State): integer; cdecl;
var
  State: TRLLuaState;
begin
  State.Init(L);
  UI.Delay(State.ToInteger(1));
  Result := 0;
end;

function lua_ui_plot_talk(L: Plua_State): integer; cdecl;
var
  State: TRLLuaState;
begin
  State.Init(L);
  UI.PlotText(State.ToString(1));
  Result := 0;
end;

function lua_ui_item_info(L: Plua_State): integer; cdecl;
var
  State: TRLLuaState;
begin
  State.Init(L);
  UI.ItemInfo(State.ToObject(1) as TItem);
  Result := 0;
end;



function lua_ui_talk_run(L: Plua_State): integer; cdecl;
var
  State       : TRLLuaState;
  iCount      : Word;
  iChoice     : Word;
  iValue      : AnsiString;
  iTalkWindow : TUITalkWindow;
begin
  State.Init(L);
  iCount := State.StackSize;
  if iCount < 2 then Exit(0);

  UI.MainScreen.ClearBoth;
  iTalkWindow := TUITalkWindow.Create( UI.MainScreen.Right, State.ToString(1) );
  UI.MainScreen.UpdateMap;

  for iChoice := 2 to iCount do
  begin
    iValue := State.ToString(iChoice);
    iTalkWindow.Add(iValue, (Length(iValue) > 0) and (iValue[1] <> '@'));
  end;
  iChoice := UI.RunUILoop( iTalkWindow );
  State.Push(iChoice);
  Result := 1;
end;

function lua_ui_shop_run(L: Plua_State): integer; cdecl;
var State       : TRLLuaState;
    iCount      : byte;
    iChoice     : byte;
    iSource     : AnsiString;
    iTitle      : AnsiString;
    iShop       : TShop;
    iShopMode   : byte;
    iShopWindow : TUIShopWindow;

begin
  State.Init(L);
  iCount := State.StackSize;
  if iCount < 1 then
    Exit(0);

  iSource := State.ToString(1);
  iTitle  := State.ToString(2);

  if iCount > 2
    then iShopMode := State.ToInteger(3)
    else iShopMode := SHOP_BUY;

  iShop := Game.FindChild( iSource ) as TShop;
  iShop.Resort;
  iShopWindow := TUIShopWindow.Create( UI.Root, iTitle );

  for iChoice := 1 to iShop.getCount do
  case iShopMode of
    SHOP_BUY      : iShopWindow.Add( iShop.FItems[iChoice], COST_BUY );
    SHOP_SELL     : iShopWindow.Add( iShop.FItems[iChoice], COST_SELL );
    SHOP_REPAIR   : iShopWindow.Add( iShop.FItems[iChoice], COST_REPAIR );
    SHOP_RECHARGE : iShopWindow.Add( iShop.FItems[iChoice], COST_RECHARGE );
    SHOP_IDENTIFY : iShopWindow.Add( iShop.FItems[iChoice], COST_IDENTIFY );
    SHOP_REPAIRFREE,
    SHOP_RECHARGEFREE,
    SHOP_IDENTIFYFREE: iShopWindow.Add( iShop.FItems[iChoice] );
  end;

  case iShopMode of
    SHOP_BUY          : iShopWindow.Close( 'I have nothing to sell.' );
    SHOP_SELL         : iShopWindow.Close( 'You have nothing to sell.' );
    SHOP_REPAIR,
    SHOP_REPAIRFREE   : iShopWindow.Close( 'You have nothing to repair.');
    SHOP_RECHARGE,
    SHOP_RECHARGEFREE : iShopWindow.Close( 'You have nothing to recharge.');
    SHOP_IDENTIFY,
    SHOP_IDENTIFYFREE : iShopWindow.Close( 'You have nothing to identify.');
  end;

  iChoice := UI.RunUILoop( iShopWindow );

  if iChoice = 0 then
    State.PushNil
  else
    State.Push(iShop.FItems[iChoice]);
  Result := 1;
end;

// ----------------------------- SOUND FUNCTIONS ---------------------- //

function lua_ui_play_music(L: Plua_State): integer; cdecl;
var
  State: TRLLuaState;
begin
  State.Init(L);
  if State.StackSize = 1 then
    UI.PlayMusic(State.ToString(1));
  Result := 0;
end;

function lua_ui_play_sound(L: Plua_State): integer; cdecl;
var
  State : TRLLuaState;
  nargs: integer;
begin
  State.Init(L);
  nargs := State.StackSize;
  if nargs >= 2 then
    UI.PlaySound(State.ToString(1), State.ToCoord(2))
  else if nargs >= 1 then
    UI.PlaySound(State.ToString(1));
  Result := 0;
end;



class procedure TGameUI.RegisterLuaAPI(State: TLuaState);
begin
  TIORL.RegisterLuaAPI( State, 'ui' );
  State.Register('ui', 'get_key', @lua_ui_get_key);
  State.Register('ui', 'talk_run', @lua_ui_talk_run);
  State.Register('ui', 'shop_run', @lua_ui_shop_run);
  State.Register('ui', 'plot_talk', @lua_ui_plot_talk);
  State.Register('ui', 'item_info', @lua_ui_item_info);

  State.Register('ui', 'play_music', @lua_ui_play_music);
  State.Register('ui', 'play_sound', @lua_ui_play_sound);
end;

type

{ TMPQStream }

 TMPQStream = class( TStream )
private
  FHandle : THandle;
  FSize   : Int64;
protected
  function  GetSize: Int64; override;
public
  constructor Create(AHandle: THandle);
  function Read(var Buffer; Count: Longint): Longint; override;
  function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
  destructor Destroy; override;
end;

{ TMPQStream }

function TMPQStream.GetSize: Int64;
begin
  Result := FSize;
end;

constructor TMPQStream.Create(AHandle: THandle);
begin
  FHandle := aHandle;
  FSize   := SFileGetFileSize(AHandle,nil);
end;

function TMPQStream.Read(var Buffer; Count: Longint): Longint;
var iBytesRead : Cardinal;
begin
  SFileReadFile(FHandle, @Buffer, Count, @iBytesRead, nil);
  Result:=iBytesRead;
end;

function TMPQStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  raise EStreamError.CreateFmt('Seek not implemented',[ClassName]);
  Seek := 0;
end;

destructor TMPQStream.Destroy;
begin
  SFileCloseFile( FHandle );
  inherited Destroy;
end;

function TGameUI.ReadFromMPQ(const aFileName: AnsiString): TStream;
var iHandle   : THandle;
begin
  if not SFileOpenFileEx( FMPQHandle, PChar(aFileName), 0, @iHandle ) then
  begin
    Log('Sound file "'+aFileName+'" not found!');
    Exit( nil );
  end;
  Exit( TMPQStream.Create( iHandle ) );
end;

end.

