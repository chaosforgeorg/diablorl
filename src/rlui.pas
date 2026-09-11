{$INCLUDE rl.inc}
// @abstract(UI base class for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)

unit rlui;

interface
uses {$IFDEF WINDOWS}Windows,{$ENDIF} Classes, SysUtils,
  vioevent, vcolor, viotypes, vioconsole, vluastate,
  viorl, vrltools, vtig, vtigstyle, vtextmap, vmessages, 
  vutil, vbindings, vtigio, rlconfiguration,
  rlviews, rlgviews, rlglobal, rlthing, rlplayer, rlitem, rlconfig, rlaudio;

var TIGFramedWindowStyle       : TTIGStyle;
    TIGNarrowFramedWindowStyle : TTIGStyle;
    TIGEmbeddedStyle           : TTIGStyle;

{TGameUI}

type
  TGameUI = class(TIORL, ITextMap)
  public
    constructor Create( aConfig : TGameConfiguration );
    function getGylph( const aCoord : TCoord2D ): TIOGylph;
    destructor Destroy; override;
    procedure Draw();
    procedure ShowMortem();
    procedure Prepare( aPlayer : TPlayer );
    procedure UnPrepare;
    // Adds a message for the message buffer
    procedure Msg( const aMessage : Ansistring); override;
    // Marks the given tile with specified glyph
    function Strip( const aInput : AnsiString ) : AnsiString;
    //focuses onto the specified cell
    procedure Focus(c: TCoord2D);
    //waits for Enter key
    procedure PressEnter();
    // Gameplay input requires the active Session and its prepared main screen.
    function GetCommand( aValid : TCommandSet = [] ) : Byte;
    function CommandKey( aCommand : TBindingAction ) : AnsiString;
    function UIKey( aAction : TBindingAction ) : AnsiString;
    //Put a message onto status bar
    procedure UpdateStatus(c: TCoord2D);
    procedure UpdateStatus(STarget: TThing);
    //reviews last messages
    procedure ShowRecent;
    //shows game manual
    procedure ShowHOF;
    //Plot text window
    procedure PlotText( const Text: ansistring );
    procedure ItemInfo( aItem : TItem );
    procedure Update( aMSec : DWord ); override;
    procedure Reconfigure;
    procedure ShowSettings;
    procedure ReconfigureDisplay;
    procedure FitDisplay;
    procedure SaveWindowGeometry;
    procedure PostUpdate; override;
    procedure SetAudio( aAudio : TGameAudio );
    function OnEvent( const aEvent : TIOEvent ) : Boolean; override;
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
    function YesNoDialog( const aQuery : AnsiString ) : Boolean;
    class procedure RegisterLuaAPI(State: TLuaState);
  private
    function GetPlayer : TPlayer;
    function TranslateColor( aColor : Byte; aPosition : TCoord2D ) : Byte;
    function TranslateColorFull( aColor : Byte; aPosition : TCoord2D ) : TColor;
  private
    FConfiguration : TGameConfiguration; // borrowed from Runtime
    FAnimTime      : DWord;
    FAnimCount     : DWord;
    FMainScreen    : TMainScreen;
    FSizeX, FSizeY : Word;
    FGraphicsMode  : Boolean;
    FTargetMode    : Byte;
    FDisplaySize   : TIOPoint;
    FWindowSize    : TIOPoint;
    FRequestedSize : TIOPoint;
    FFontMultiplier : Integer;
    FAudio         : TGameAudio; // borrowed from Runtime
  public
    property MainScreen : TMainScreen read FMainScreen;
    property SizeX : Word read FSizeX;
    property SizeY : Word read FSizeY;
    property Player : TPlayer read GetPlayer;
    property GraphicsMode : Boolean read FGraphicsMode;
    property TargetMode : Byte read FTargetMode write FTargetMode;
  end;

function CommandDirection(Command: byte): TDirection;

var
  UI: TGameUI = nil;

implementation

uses DateUtils, variants, 
    {$IFDEF UNIX}vcursesio, vcursesconsole, {$ELSE}vtextio, vtextconsole, {$ENDIF}
    vluasystem, rlshop, rllua, rlgame, rlpersistence,
    vsdlio, vglconsole,
    vlog, vdebug, vmath, rllevel, rlsettingsview;

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

constructor TGameUI.Create( aConfig : TGameConfiguration );
var iFlags : TSDLIOFlags;
    iWidth, iHeight : Word;
begin
  Log( LOGINFO, 'Creating game UI...' );

  Log( LOGINFO, 'Loading configuration file "'+ConfigurationPath+'"...' );

  FConfiguration := aConfig;
  FSizeX        := aConfig.GetInteger( 'ascii_width' );
  FSizeY        := aConfig.GetInteger( 'ascii_height' );
  FGraphicsMode := Option_Graphics;

  if FGraphicsMode then
  begin
    Log( LOGINFO, 'Setting up graphics mode...' );
    {$IFDEF WINDOWS}
    if not GodMode then
    begin
      FreeConsole;
    end
    else
    begin
      Logger.AddSink( TConsoleLogSink.Create( LOGDEBUG, true ) );
    end;
    {$ENDIF}

    FGraphicsMode := True;
    iFlags := [ SDLIO_OpenGL, SDLIO_Resizable ];
    iWidth := aConfig.GetInteger( 'screen_width' );
    iHeight := aConfig.GetInteger( 'screen_height' );
    if Option_FullScreen then
    begin
      Include( iFlags, SDLIO_DesktopFullScreen );
      iWidth := 0;
      iHeight := 0;
    end;
    Log( LOGINFO, 'Initializing driver...' );
    FIODriver := TSDLIODriver.Create( iWidth, iHeight, 32, iFlags );
    Log( LOGINFO, 'Creating renderer, using font file "'+DataPath+'font10x18.png"...' );
    FConsole := TGLConsoleRenderer.Create( DataPath+'font10x18.png',32,256-32,32, FSizeX, FSizeY, 0, [VIO_CON_CURSOR, VIO_CON_EXTCOLOR] );
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

  Log( LOGINFO, 'Loading default style...' );

  TIGFramedWindowStyle := VTIGDefaultStyle;
  TIGFramedWindowStyle.Color[ VTIG_TEXT_COLOR ]                := DarkGray;
  TIGFramedWindowStyle.Color[ VTIG_INPUT_TEXT_COLOR ]          := White;
  TIGFramedWindowStyle.Color[ VTIG_SELECTED_DISABLED_COLOR ]   := LightRed;
  TIGFramedWindowStyle.Color[ VTIG_DISABLED_COLOR ]            := Red;
  TIGFramedWindowStyle.Color[ VTIG_FOOTER_COLOR ]              := DarkGray;
  TIGFramedWindowStyle.Padding[ VTIG_WINDOW_PADDING ]          := Point( 2, 1 );

  TIGNarrowFramedWindowStyle := TIGFramedWindowStyle;
  TIGNarrowFramedWindowStyle.Padding[ VTIG_WINDOW_PADDING ]     := Point( 1, 1 );
  TIGNarrowFramedWindowStyle.Padding[ VTIG_SELECTABLE_PADDING ] := Point( 0,0 );
  TIGNarrowFramedWindowStyle.Padding[ VTIG_GROUP_PADDING ]      := Point( 1,0 );
  TIGNarrowFramedWindowStyle.Padding[ VTIG_GROUP_FRAME_PADDING ]:= Point( 0,1 );

  TIGEmbeddedStyle := TIGNarrowFramedWindowStyle;
  TIGEmbeddedStyle.Frame[ VTIG_BORDER_FRAME ] := '';
  TIGEmbeddedStyle.Padding[ VTIG_WINDOW_PADDING ] := Point( 0, 1 );

  VTIGDefaultStyle.Color[ VTIG_TEXT_COLOR ]                := DarkGray;
  VTIGDefaultStyle.Color[ VTIG_INPUT_TEXT_COLOR ]          := White;
  VTIGDefaultStyle.Color[ VTIG_INPUT_BACKGROUND_COLOR ]    := Black;
  VTIGDefaultStyle.Color[ VTIG_SELECTED_BACKGROUND_COLOR ] := Black;
  VTIGDefaultStyle.Color[ VTIG_SELECTED_DISABLED_COLOR ]   := LightRed;
  VTIGDefaultStyle.Color[ VTIG_DISABLED_COLOR ]            := Red;

  VTIGDefaultStyle.Frame[ VTIG_BORDER_FRAME ] := '';
  VTIGDefaultStyle.Frame[ VTIG_GROUP_FRAME ]  := '';
  VTIGDefaultStyle.Frame[ VTIG_GROUP_FRAME ]  := '';

  Log( LOGINFO, 'Initializing core driver...' );
  inherited Create( FIODriver, FConsole );
  Log( LOGINFO, 'Configuring...' );
  Configure( aConfig.LuaConfig );
  Reconfigure;
  HideCursor;
  Log( LOGINFO, 'GameIO ready.' );
  FAnimCount := 0;
  TItem.InitColors( FGraphicsMode );
end;

procedure TGameUI.Draw;
begin
  FConsole.Clear;
  if FTMap <> nil then FTMap.SetCenter( NewCoord2D( FPlayer.Position.X, FPlayer.Position.Y - 1 ) );
end;

function TGameUI.Strip ( const aInput : AnsiString ) : AnsiString;
begin
  Exit( VTIG_StripTags( aInput ) );
end;

procedure TGameUI.Focus(c: TCoord2D);
begin
  if FTMap <> nil then FTMap.SetCenter( NewCoord2D( c.X, c.Y - 1 ) );
end;

procedure TGameUI.ShowRecent;
begin
  if FMessages <> nil then
    UI.RunLayer( TMessagesScreen.Create( FMessages.Content ) );
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

procedure TGameUI.Prepare( aPlayer : TPlayer );
begin
  FConsole.Clear;
  FMessages     := TMessages.Create( 2, FSizeX - 2, nil, 1000 );
  FTMap         := TTextMap.Create( FConsole, Rectangle( 1, 3, FSizeX, FSizeY - 5 ), Self );
  FMainScreen   := TMainScreen.Create( FTMap, FMessages );
  PushLayer( FMainScreen );
  FPlayer        := aPlayer;
end;

procedure TGameUI.UnPrepare;
begin
  if FMainScreen <> nil then
  begin
    FMainScreen.ClearBoth;
    // Panel destructors still update the main screen's status line.
    ClearFinishedLayers;
    FMainScreen.Finish;
    FMainScreen := nil;
    ClearFinishedLayers;
  end;
  FreeAndNil( FTMap );
  FreeAndNil( FMessages );
  FPlayer := nil;
  FLevel := nil;
end;

procedure TGameUI.Msg ( const aMessage : Ansistring ) ;
begin
  inherited Msg( Capitalized( aMessage ) );
end;

function TGameUI.GetCommand( aValid : TCommandSet ) : Byte;
var iEvent : TIOEvent;
    iAction : TBindingAction;
    iValue : Variant;
begin
  Inc( FAnimCount );
  repeat
    if not WaitForKeyEvent( iEvent ) then Exit( 0 );
    if (iEvent.EType = VEVENT_SYSTEM) and
       (iEvent.System.Code = VIO_SYSEVENT_QUIT) then Exit( COMMAND_SYSQUIT );
    if IsModal then Continue;
    FKeyCode := IOKeyEventToIOKeyCode( iEvent.Key );
    iAction := GameBindings.ResolveKey( FKeyCode );
    if iAction = BINDING_FORWARD_LUA then
    begin
      iValue := FConfiguration.LuaConfig.RunBinding( FKeyCode );
      if VarIsOrdinal( iValue ) and not VarIsType( iValue, varBoolean )
        then iAction := Integer( iValue )
        else iAction := 0;
    end;
    if (iAction < 0) or (iAction > High( Byte )) then Continue;
    if (aValid <> []) and not (Byte( iAction ) in aValid) then Continue;
    if FMainScreen.HandleCommand( Byte( iAction ) ) then Continue;
    Result := Byte( iAction );
    if Player.SpeedCount >= 100 then FMessages.Update;
    Exit;
  until False;
end;

function TGameUI.CommandKey( aCommand : TBindingAction ) : AnsiString;
begin
  if GameBindings.GetKey( aCommand ) = 0 then Exit( 'Unbound' );
  Result := IOKeyCodeToStringShort( GameBindings.GetKey( aCommand ) );
end;

function TGameUI.UIKey( aAction : TBindingAction ) : AnsiString;
begin
  if UIBindings.GetKey( aAction ) = 0 then Exit( 'Unbound' );
  Result := IOKeyCodeToStringShort( UIBindings.GetKey( aAction ) );
end;

procedure TGameUI.PressEnter;
begin
  WaitForKey( [ UIBindings.GetKey( VTIG_IE_CONFIRM ) ] );
  PlaySound('sfx/items/titlslct.wav');
end;

destructor TGameUI.Destroy();
begin
  UI := nil;
  inherited Destroy;
end;

procedure TGameUI.PlotText(const Text: ansistring);
begin
  RunLayer( TPlotWindow.Create( Text ) );
  HaltSound();
end;

procedure TGameUI.ItemInfo( aItem: TItem );
begin
  RunLayer( TItemInfo.Create( aItem ) );
end;

procedure TGameUI.Update( aMSec : DWord );
begin
  FAnimTime := Driver.GetMs;
  if FGraphicsMode and SDLIO.RefreshWindowSize then
  begin
    if FDisplaySize <> Point( SDLIO.Width, SDLIO.Height ) then FitDisplay;
    if not SDLIO.FullScreen then FWindowSize := Point( SDLIO.Width, SDLIO.Height );
  end;
  inherited Update( aMSec );
  // Restore Look after VTIG releases the string-entry cursor.
  if (FTargetMode = TM_LOOK) and not IsModal then ShowCursor;
end;

procedure TGameUI.ShowMortem;
begin
  if not FileExists('mortem.txt') then Exit;
  RunLayer( TMortemScreen.Create );
end;

procedure TGameUI.ShowHOF;
begin
  RunLayer( THighscoreViewer.Create( Game.Persistence.ScoreList ) );
end;

procedure TGameUI.ShowSettings;
begin
  PushLayer( TGameSettingsView.Create( FConfiguration, @Reconfigure ) );
end;

procedure TGameUI.PostUpdate;
begin
  inherited PostUpdate;
  if not FLayers.IsEmpty then
    if FLayers.Top is TGameSettingsView then
      TGameSettingsView( FLayers.Top ).ApplyPending;
end;

procedure TGameUI.FitDisplay;
var iMinimum : TIOPoint;
begin
  with TGLConsoleRenderer( FConsole ).Font.GylphSize do
    iMinimum := Point( X, Y );
  if (SDLIO.Width < DWord( iMinimum.X * 80 )) or
     (SDLIO.Height < DWord( iMinimum.Y * 25 )) then Exit;
  FDisplaySize := Point( SDLIO.Width, SDLIO.Height );
  TGLConsoleRenderer( FConsole ).FitToDevice( Point( 80, 25 ),
    FFontMultiplier );
  // Resizing the renderer sets its cursor type and makes it visible.
  HideCursor;
  FSizeX := FConsole.SizeX;
  FSizeY := FConsole.SizeY;
  if FMessages <> nil then FMessages.Resize( 2, FSizeX - 2 );
  if FMainScreen <> nil then
  begin
    FMainScreen.UpdateMap;
    if FTargetMode <> 0 then
    begin
      if FTargetMode = TM_LOOK then Focus( Player.Target );
      FocusCursor( Player.Target );
      if (FTargetMode = TM_FIRE) and Game.Level.isExplored( Player.Target ) then
        MarkTile( Player.Target, 'X', Red );
    end;
  end;
end;

procedure TGameUI.ReconfigureDisplay;
var iFlags, iOldFlags : TSDLIOFlags;
    iSize, iOldSize, iMinimum : TIOPoint;
    iFullscreen : Boolean;
begin
  if not FGraphicsMode then Exit;
  with TGLConsoleRenderer( FConsole ).Font.GylphSize do
    iMinimum := Point( X, Y );
  if not SDLIO.SetMinimumSize( Point( iMinimum.X * 80, iMinimum.Y * 25 ) ) then
    raise EIOException.Create( 'Could not set the minimum window size.' );
  iFullscreen := FConfiguration.GetBoolean( 'fullscreen' );
  if FConfiguration.FullscreenOverride >= 0 then
    iFullscreen := FConfiguration.FullscreenOverride = 1;
  iFlags := [SDLIO_OpenGL, SDLIO_Resizable];
  iSize := Point( FConfiguration.GetInteger( 'screen_width' ),
    FConfiguration.GetInteger( 'screen_height' ) );
  if (iSize = FRequestedSize) and (FWindowSize.X > 0) then iSize := FWindowSize;
  iOldFlags := SDLIO.Flags;
  if not SDLIO.RefreshWindowSize then
    raise EIOException.Create( 'Could not read the current window size.' );
  iOldSize := Point( SDLIO.Width, SDLIO.Height );
  if iFullscreen then Include( iFlags, SDLIO_DesktopFullScreen );
  if not SDLIO.ResetVideoMode( iSize.X, iSize.Y, SDLIO.BPP, iFlags ) or
     not SDLIO.SynchronizeWindow then
  begin
    if not SDLIO.ResetVideoMode( iOldSize.X, iOldSize.Y, SDLIO.BPP, iOldFlags ) or
       not SDLIO.SynchronizeWindow then
      raise EIOException.Create( 'Display change and restoration both failed.' );
    SDLIO.RefreshWindowSize;
    FitDisplay;
    raise EIOException.Create( 'Could not apply the display mode; previous mode restored.' );
  end;
  FRequestedSize := Point( FConfiguration.GetInteger( 'screen_width' ),
    FConfiguration.GetInteger( 'screen_height' ) );
  SDLIO.RefreshWindowSize;
  if iFullscreen then FWindowSize := iSize
  else FWindowSize := Point( SDLIO.Width, SDLIO.Height );
  FFontMultiplier := FConfiguration.GetInteger( 'font_multiplier' );
  FitDisplay;
end;

procedure TGameUI.SaveWindowGeometry;
begin
  if not FGraphicsMode or (FWindowSize.X <= 0) or (FWindowSize.Y <= 0) then Exit;
  FConfiguration.AccessInteger( 'screen_width' )^ := FWindowSize.X;
  FConfiguration.AccessInteger( 'screen_height' )^ := FWindowSize.Y;
  FRequestedSize := FWindowSize;
end;

procedure TGameUI.Reconfigure;
begin
  ReconfigureDisplay;
  FConfiguration.ApplyLiveSettings;
  FConfiguration.LoadBindings( GameBindings, UIBindings );
  SetSoundVolume( FConfiguration.GetInteger( 'sound_volume' ) );
  SetMusicVolume( FConfiguration.GetInteger( 'music_volume' ) );
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



function TGameUI.OnEvent( const aEvent : TIOEvent ) : Boolean;
begin
  // Title/child menus have no Session to abandon. Gameplay retains its existing
  // system-event routing; this does not invent a close/save policy for a run.
  if ( Game = nil ) and ( aEvent.EType = VEVENT_SYSTEM ) and
     ( aEvent.System.Code = VIO_SYSEVENT_QUIT ) then
    raise EGameProcessQuit.Create( 'System quit requested' );
  if not FLayers.IsEmpty then
    if FLayers.Top is TGameSettingsView then
      if TGameSettingsView( FLayers.Top ).HandleCaptureEvent( aEvent ) then Exit( True );
  Result := inherited OnEvent( aEvent );
end;

procedure TGameUI.SetAudio( aAudio : TGameAudio );
begin
  FAudio := aAudio;
  SetSoundVolume( FConfiguration.GetInteger( 'sound_volume' ) );
  SetMusicVolume( FConfiguration.GetInteger( 'music_volume' ) );
end;

procedure TGameUI.PlayMusic( const sID : AnsiString );
begin
  if FAudio <> nil then FAudio.PlayMusic( sID );
end;

procedure TGameUI.PlaySound( const sID : AnsiString; aSource : TCoord2D );
begin
  if FAudio <> nil then FAudio.PlaySound( sID, aSource, Player.Position );
end;

procedure TGameUI.PlaySound( const sID : AnsiString );
begin
  if FAudio <> nil then FAudio.PlaySound( sID );
end;

procedure TGameUI.HaltSound;
begin
  if FAudio <> nil then FAudio.HaltSound;
end;

procedure TGameUI.Mute;
begin
  // Legacy no-op; generation never changed the backend volumes here.
end;

procedure TGameUI.Unmute;
begin
end;

procedure TGameUI.SetMusicVolume( Volume : Byte );
begin
  if FAudio <> nil then FAudio.SetMusicVolume( Volume );
end;

procedure TGameUI.SetSoundVolume( Volume : Byte );
begin
  if FAudio <> nil then FAudio.SetSoundVolume( Volume );
end;

function TGameUI.GetTravelDestination ( out aWhere : TCoord2D ) : Boolean;
begin
  RunLayer( TTravelWindow.Create );
  if TTravelWindow.Result >= 0 then
  begin
    aWhere := (UI.Player.Parent as TLevel).TravelPoints[ TTravelWindow.Result ].Where;
    Exit( True );
  end;
  Exit( False );
end;

function TGameUI.YesNoDialog ( const aQuery : AnsiString ) : Boolean;
begin
  RunLayer( TConfirmDialog.Create( aQuery ) );
  Exit( TConfirmDialog.Result > 0 );
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
  State: TGameLuaState;
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
  State: TGameLuaState;
begin
  State.Init(L);
  if State.StackSize = 0 then
    Exit(0);
  UI.Msg(State.ToString(1));
  UI.Draw;
  Result := 0;
end;

function lua_ui_msg_enter( L : Plua_State ) : Integer; cdecl;
var iState : TGameLuaState;
begin
  iState.Init( L );
  UI.Msg( iState.ToString( 1 ) + ' Press <{!' + UI.UIKey( VTIG_IE_CONFIRM ) + '}>...' );
  UI.WaitForKey( [ UI.UIBindings.GetKey( VTIG_IE_CONFIRM ) ] );
  UI.MsgUpdate;
  Result := 0;
end;

function lua_ui_delay(L: Plua_State): integer; cdecl;
var
  State: TGameLuaState;
begin
  State.Init(L);
  UI.Delay(State.ToInteger(1));
  Result := 0;
end;

function lua_ui_plot_talk(L: Plua_State): integer; cdecl;
var
  State: TGameLuaState;
begin
  State.Init(L);
  UI.PlotText(State.ToString(1));
  Result := 0;
end;

function lua_ui_item_info(L: Plua_State): integer; cdecl;
var
  State: TGameLuaState;
begin
  State.Init(L);
  UI.ItemInfo(State.ToObject(1) as TItem);
  Result := 0;
end;



function lua_ui_talk_run(L: Plua_State): integer; cdecl;
var
  State       : TGameLuaState;
  iCount      : Word;
  iChoice     : Word;
  iValue      : AnsiString;
  iWindow     : TTalkWindow;
begin
  State.Init(L);
  iCount := State.StackSize;
  if iCount < 2 then Exit(0);

  UI.MainScreen.ClearBoth;
  iWindow := TTalkWindow.Create( UI.MainScreen, State.ToString(1) );
  UI.MainScreen.Right := iWindow;
  UI.MainScreen.UpdateMap;

  for iChoice := 2 to iCount do
  begin
    iValue := State.ToString(iChoice);
    iWindow.Add(iValue, (Length(iValue) > 0) and (iValue[1] <> '@'));
  end;
  UI.RunLayer( iWindow );
  State.Push( Integer( TTalkWindow.Result + 1 ) );
  Result := 1;
end;

function lua_ui_shop_run(L: Plua_State): integer; cdecl;
var State       : TGameLuaState;
    iCount      : byte;
    iChoice     : Integer;
    iSource     : AnsiString;
    iTitle      : AnsiString;
    iShop       : TShop;
    iShopMode   : byte;
    iShopWindow : TShopWindow;

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
  iShopWindow := TShopWindow.Create( iTitle );

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

  UI.RunLayer( iShopWindow );
  iChoice := TShopWindow.Result;

  if iChoice < 0 then
    State.PushNil
  else
    State.Push(iShop.FItems[iChoice+1]);
  Result := 1;
end;

// ----------------------------- SOUND FUNCTIONS ---------------------- //

function lua_ui_play_music(L: Plua_State): integer; cdecl;
var
  State: TGameLuaState;
begin
  State.Init(L);
  if State.StackSize = 1 then
    UI.PlayMusic(State.ToString(1));
  Result := 0;
end;

function lua_ui_play_sound(L: Plua_State): integer; cdecl;
var
  State : TGameLuaState;
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
  State.Register( 'ui', 'msg_enter', @lua_ui_msg_enter );
  State.Register('ui', 'get_key', @lua_ui_get_key);
  State.Register('ui', 'talk_run', @lua_ui_talk_run);
  State.Register('ui', 'shop_run', @lua_ui_shop_run);
  State.Register('ui', 'plot_talk', @lua_ui_plot_talk);
  State.Register('ui', 'item_info', @lua_ui_item_info);

  State.Register('ui', 'play_music', @lua_ui_play_music);
  State.Register('ui', 'play_sound', @lua_ui_play_sound);
end;

end.
