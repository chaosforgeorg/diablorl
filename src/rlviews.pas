{$include rl.inc}
// @abstract(Non-game views for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
//
// TODO:     UI.PlaySound('sfx/items/titlemov.wav'); on

unit rlviews;
interface

uses Classes, SysUtils,
     vuitypes, // TUIChunkBuffer
     viotypes, vtigstyle;

const GAMEMENU_CONT = 0;
      GAMEMENU_HELP = 2;
      GAMEMENU_SAVE = 3;
      GAMEMENU_QUIT = 4;

type TMenuScreen = class( TIOLayer )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished : Boolean;
  FShift   : TIOPoint;
end;

type TFullScreenLayer = class( TIOLayer )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished : Boolean;
  FHeader   : Ansistring;
  FFooter   : Ansistring;
end;

type TScrollingLayer = class( TFullScreenLayer )
  constructor Create( aContent : TIOStringArray );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  destructor Destroy; override;
protected
  FContent    : TIOStringArray;
  FScrollDown : Boolean;
  FStyle      : TTIGStyle;
end;

type TManualScreen = class( TScrollingLayer )
  constructor Create;
end;

type TMortemScreen = class( TScrollingLayer )
  constructor Create;
end;

type TMessagesScreen = class( TScrollingLayer )
  constructor Create( aMessages : TUIChunkBuffer );
end;

type THighscoreViewer = class( TScrollingLayer )
  constructor Create( aContent : TIOStringArray );
end;

type TIntroScreen = class( TMenuScreen )
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
end;

type TOutroScreen = class( TIOLayer )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished : Boolean;
end;

type TMainMenuScreen = class( TMenuScreen )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
protected
  FCanLoad : Boolean;
end;

type TKlassInfo = record
  Name  : AnsiString;
  Desc  : AnsiString;
  Level : Integer;
  Str   : Integer;
  Mag   : Integer;
  Dex   : Integer;
  Vit   : Integer;
end;

type TKlassScreen = class( TMenuScreen )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
protected
  FKlasses : array of TKlassInfo;
  FCount   : Integer;
end;

type TNameScreen = class( TMenuScreen )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
protected
  FName : array[0..32] of Char;
end;

type TConfirmDialog = class( TIOLayer )
  constructor Create( const aQuery : AnsiString );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished : Boolean;
  FQuery    : AnsiString;
  class var FResult   : DWord;
public
  class property Result : DWord read FResult;
end;

type TGameMenu = class( TIOLayer )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsFinished : Boolean; override;
  function IsModal : Boolean; override;
protected
  FFinished : Boolean;
  class var FResult   : DWord;
public
  class property Result : DWord read FResult;
end;

implementation

uses vluasystem, vutil, vtig, vtigio, rlglobal, rlui, rlgame, math;

{ TMenuScreen }

constructor TMenuScreen.Create;
var iSize : TIOPoint;
begin
  VTIG_EventClear;
  FFinished := False;
  iSize  := VTIG_GetIOState.Size;
  FShift := Point( (iSize.X - 80) div 2, (iSize.Y - 25) div 2 );
end;

procedure TMenuScreen.Update( aDTime : Integer; aActive : Boolean );
begin
  VTIG_Clear;
  VTIG_Begin( 'menu_logo', Point( 44, 13 ), Point( 19, 1 ) + FShift );
  VTIG_Text( '{r  ####                           ####   }');
  VTIG_Text( '{r  #####  #    ##    ###    #    ######  }');
  VTIG_Text( '{r  ## ##  #   #  #   #  #   #    ##  ##  }');
  VTIG_Text( '{r  ## ##  #   #  #   ###    #    ##  ##  }');
  VTIG_Text( '{r  #}{y# #}{r#  #   }{y#}{r##}{y#   #  #   #    }{y#}{r#  #}{y#  }');
  VTIG_Text( '{y  ####   #   #  #   ###    #### ######  }');
  VTIG_Text( '{y  ###           #                ####   }');
  VTIG_Text( '{L           R O G U E L I K E            }');
  VTIG_Text( '{L                '+VERSION+'}' );
  VTIG_Text( '' );
  VTIG_Text( '         by {!Kornel Kisielewicz}          ' );
  VTIG_Text( ' {!Chris Johnson} and {!Mel''nikova Anastasia}' );
  VTIG_End;
end;

function TMenuScreen.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TMenuScreen.IsModal : Boolean;
begin
  Exit( True );
end;

{ TFullScreenLayer }

constructor TFullScreenLayer.Create;
begin
  VTIG_EventClear;
  VTIG_Clear;
  FFinished := False;
  FHeader   := '';
  FFooter   := ' Use {!arrows}, {!PgUp}, {!PgDown} to scroll, {!Escape} or {!Enter} to exit.';
end;

procedure TFullScreenLayer.Update( aDTime : Integer; aActive : Boolean );
begin
end;

function TFullScreenLayer.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TFullScreenLayer.IsModal : Boolean;
begin
  Exit( True );
end;

{ TScrollingLayer }

constructor TScrollingLayer.Create( aContent : TIOStringArray );
begin
  inherited Create;
  VTIG_ResetScroll( 'scrolling_view' );
  FContent    := aContent;
  FScrollDown := False;
  FStyle      := VTIGDefaultStyle;
  FStyle.Padding[ VTIG_WINDOW_PADDING ] := Point( 0,1 );
  FStyle.Frame[ VTIG_BORDER_FRAME ]     := #196+#196+'  '+#196+#196+#196+#196;
end;

procedure TScrollingLayer.Update( aDTime : Integer; aActive : Boolean );
var i : Integer;
begin
  VTIG_PushStyle( @FStyle );
  VTIG_BeginWindow( FHeader, 'scrolling_view', VTIG_GetIOState.Size, Point( 1, 1 ) );
  if FContent.Size > 0 then
    for i := 0 to FContent.Size - 1 do
      VTIG_Text( FContent[i] );
  if FContent.Size > 22 then
    VTIG_Scrollbar( FScrollDown );
  FScrollDown := False;
  VTIG_End( FFooter );
  VTIG_PopStyle;
  if VTIG_EventConfirm or VTIG_EventCancel then FFinished := True;
  inherited Update( aDTime, aActive );
end;

destructor TScrollingLayer.Destroy;
begin
  FreeAndNil( FContent );
  inherited Destroy;
end;

{ TManualScreen }

constructor TManualScreen.Create;
begin
  inherited Create( TextFileToIOStringArray( DataPath + 'manual.txt' ) );
  FHeader := ' {!DiabloRL} Manual ({!manual.txt})';
end;

{ TMortemScreen }

constructor TMortemScreen.Create;
begin
  inherited Create( TextFileToIOStringArray( WritePath + 'mortem.txt' ) );
  FHeader := ' {!DiabloRL} PostMortem ({!mortem.txt})';
end;

{ TMessagesScreen }

constructor TMessagesScreen.Create( aMessages : TUIChunkBuffer );
var iChunkList : TUIChunkList;
begin
  inherited Create( nil );
  FHeader  := ' {!DiabloRL} Past messages viewer';
  FContent := TIOStringArray.Create;
  for iChunkList in aMessages do
    FContent.Push( ChunkListToString( iChunkList ) );
  FScrollDown := True;
  FStyle.Padding[ VTIG_WINDOW_PADDING ] := Point(-1,1 );
end;

{ THighscoreViewer }

constructor THighscoreViewer.Create( aContent : TIOStringArray );
begin
  inherited Create( aContent );
  FHeader := ' {!DiabloRL} Highscores';
end;

{ TIntroScreen }

procedure TIntroScreen.Update( aDTime : Integer; aActive : Boolean );
begin
  inherited Update( aDTime, aActive );
  VTIG_Begin( 'intro_text', Point( 60, 10 ), Point( 10, 15 ) + FShift );
  VTIG_Text( 'This is the 0.5 version of Diablo Roguelike, much features' );
  VTIG_Text( 'are still missing, many more are planned. If you''d like to' );
  VTIG_Text( 'see this project continued,  please drop by the ChaosForge' );
  VTIG_Text( 'forums ({!http://forum.chaosforge.org}),  and leave a comment' );
  VTIG_Text( 'at the DiabloRL board to encourage further development!' );
  VTIG_Text( 'encourage further development!' );
  VTIG_Text( '' );
  VTIG_Text( 'To enable sound and music, edit the {!config.lua} file.' );
  VTIG_Text( 'Press <{!Enter}> to continue...' );
  VTIG_End;
  if VTIG_EventConfirm or VTIG_EventCancel then FFinished := True;
end;

{ TOutroScreen }

constructor TOutroScreen.Create;
begin
  VTIG_EventClear;
  VTIG_Clear;
  FFinished := False;
end;

procedure TOutroScreen.Update( aDTime : Integer; aActive : Boolean );
begin
  VTIG_Begin( 'outro_text', VTIG_GetIOState.Size - Point( 2, 2 ), Point( 1, 1 ) );
  VTIG_Text( 'Thank you for playing Diablo Roguelike!' );
  VTIG_Text( 'This is just a beta, keep your eyes open for the full release!' );
  VTIG_Text( '' );
  VTIG_Text( 'Features planned for DiabloRL:' );
  VTIG_Text( ' -- the full range of Diablo items, monsters, uniques, prefixes and spells' );
  VTIG_Text( ' -- entering hell and missing caves content' );
  VTIG_Text( ' -- all the original Diablo quests with the original texts' );
  VTIG_Text( ' -- all the hidden quest locations and uniques' );
  VTIG_Text( ' -- additional quests by Blizzard that didn''t appear in Diablo' );
  VTIG_Text( ' -- missing spells and spell effects' );
  VTIG_Text( ' -- additional Hellfire classes -- Monk, Bard and Barbarian' );
  VTIG_Text( ' -- maybe additional Hellfire content -- spells, items, quests, uniques.' );
  VTIG_Text( ' -- Programmer''s edition -- how the author himself see''s the world of Diablo' );
  VTIG_Text( ' -- and special rooms in dungeons' );
  VTIG_Text( '' );
  VTIG_Text( '' );
  VTIG_Text( 'Well, at least that would be if DiabloRL would be continued. It all depends' );
  VTIG_Text( 'on {!you}! If you want this project continued then drop me a note at' );
  VTIG_Text( '{!epyon(at)chaosforge.org}... Comments, suggestions, death threats all welcome.' );
  VTIG_Text( '' );
  VTIG_Text( 'Again, thank you for your time spent playing DiabloRL.' );
  VTIG_Text( 'Press {!Enter} to quit...' );
  VTIG_End;
  if VTIG_EventConfirm or VTIG_EventCancel then FFinished := True;
end;

function TOutroScreen.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TOutroScreen.IsModal : Boolean;
begin
  Exit( True );
end;

{ TMainMenuScreen }

constructor TMainMenuScreen.Create;
begin
  inherited Create;
  FCanLoad := FileExists( WritePath + 'save' );
end;

procedure TMainMenuScreen.Update( aDTime : Integer; aActive : Boolean );
begin
  inherited Update( aDTime, aActive );
  VTIG_PushStyle( @TIGNarrowFramedWindowStyle );
  VTIG_Begin( 'main_menu', Point( 21, 9 ), Point( 29, 15 ) + FShift );
  VTIG_PopStyle;

  if VTIG_Selectable( '   New Game' ) then
  begin
    UI.PlaySound('sfx/items/titlslct.wav');
    FFinished := True;
  end;
  if VTIG_Selectable( '   Load Game', FCanLoad ) then
  begin
    GameLoad := True;
    UI.PlaySound('sfx/items/titlslct.wav');
    FFinished := True;
  end;
  if VTIG_Selectable( 'Show Highscores' ) then
  begin
    UI.PushLayer( THighscoreViewer.Create( Game.Persistence.ScoreList ) );
    UI.WaitForLayer;
  end;
  if VTIG_Selectable( '  Show Manual' ) then
  begin
    UI.PushLayer( TManualScreen.Create );
    UI.WaitForLayer;
  end;
  if VTIG_Selectable( '   Quit Game' ) then
  begin
    GameEnd := True;
    UI.PlaySound('sfx/items/titlslct.wav');
    FFinished := True;
  end;
  VTIG_End;
end;

{ TKlassScreen }

constructor TKlassScreen.Create;
var i : Integer;
begin
  inherited Create;
  FCount := LuaSystem.GetTableSize('klasses');
  SetLength( FKlasses, FCount );
  for i := 0 to FCount - 1 do
    with LuaSystem.GetTable(['klasses', i + 1 ]) do
    try
      FKlasses[i].Name  := GetString('name');
      FKlasses[i].Desc  := GetString('desc');
      FKlasses[i].Level := GetInteger('level');
      FKlasses[i].Str   := GetInteger('str');
      FKlasses[i].Mag   := GetInteger('mag');
      FKlasses[i].Dex   := GetInteger('dex');
      FKlasses[i].Vit   := GetInteger('vit');
    finally
      Free;
    end;
end;

procedure TKlassScreen.Update( aDTime : Integer; aActive : Boolean );
var iSelected : Integer;
    i         : Integer;
begin
  inherited Update( aDTime, aActive );
  VTIG_PushStyle( @TIGNarrowFramedWindowStyle );
  VTIG_BeginWindow( 'Choose class', 'klass_menu', Point( 29, 11 ), Point( 1, 15 ) + FShift );
    VTIG_BeginGroup( 9 );
      for i := 0 to FCount - 1 do
        if VTIG_Selectable( FKlasses[i].Name ) then
        begin
          GameClass := i + 1;
          UI.PlaySound('sfx/items/titlslct.wav');
          FFinished := True;
        end;
    VTIG_EndGroup();
    VTIG_BeginGroup;
      iSelected := VTIG_Selected( 'klass_menu' );
      if ( iSelected >= 0 ) and ( iSelected < FCount ) then
      begin
        VTIG_Text( Format( ' Level     : {!%d}', [ FKlasses[iSelected].Level ] ) );
        VTIG_Text( '' );
        VTIG_Text( Format( ' Strength  : {!%d}', [ FKlasses[iSelected].Str ] ) );
        VTIG_Text( Format( ' Magic     : {!%d}', [ FKlasses[iSelected].Mag ] ) );
        VTIG_Text( Format( ' Dexterity : {!%d}', [ FKlasses[iSelected].Dex ] ) );
        VTIG_Text( Format( ' Vitality  : {!%d}', [ FKlasses[iSelected].Vit ] ) );
      end;
    VTIG_EndGroup();
  VTIG_End;
  VTIG_BeginWindow( 'Description', 'klass_menu', Point( 51, 11 ), Point( 30, 15 ) + FShift );
    if ( iSelected >= 0 ) and ( iSelected < FCount ) then
      VTIG_Text( FKlasses[iSelected].Desc );
  VTIG_End;
  VTIG_PopStyle;
end;

{ TNameScreen }

constructor TNameScreen.Create;
begin
  inherited Create;
  FName[0] := #0;
  UI.Driver.StartTextInput;
end;

procedure TNameScreen.Update( aDTime : Integer; aActive : Boolean );
begin
  inherited Update( aDTime, aActive );
  VTIG_PushStyle( @TIGNarrowFramedWindowStyle );
  VTIG_BeginWindow( 'Enter name', 'name_input', Point( 18, 5 ), Point( 30, 16 ) + FShift );
  VTIG_PopStyle;
  if VTIG_Input( @FName[0], 12 ) then
  begin
    GameName := AnsiString( FName );
    UI.PlaySound('sfx/items/titlslct.wav');
    UI.Driver.StopTextInput;
    FFinished := True;
  end;
  VTIG_End;
end;

{ TConfirmDialog }

constructor TConfirmDialog.Create( const aQuery : AnsiString );
begin
  VTIG_EventClear;
  VTIG_ResetSelect( 'confirm_dialog' );
  FFinished := False;
  FResult   := 0;
  FQuery    := aQuery;
end;

procedure TConfirmDialog.Update( aDTime : Integer; aActive : Boolean );
var iWidth : Integer;
begin
  VTIG_PushStyle( @TIGFramedWindowStyle );
  VTIG_Begin( 'confirm_dialog', Point( 40, 10 ) );
  VTIG_Text( FQuery, LightGray );
  VTIG_Text( '' );
  if VTIG_Selectable( 'Cancel' )  then begin FResult := 0; FFinished := True; end;
  if VTIG_Selectable( 'Confirm' ) then begin FResult := 1; FFinished := True; end;
  VTIG_End;
  VTIG_PopStyle;
  if VTIG_EventCancel then begin FResult := 0; FFinished := True; end;
end;

function TConfirmDialog.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TConfirmDialog.IsModal : Boolean;
begin
  Exit( True );
end;

{ TGameMenu }

constructor TGameMenu.Create;
begin
  VTIG_EventClear;
  FFinished := False;
  FResult   := GAMEMENU_CONT;
end;

procedure TGameMenu.Update( aDTime : Integer; aActive : Boolean );
begin
  VTIG_PushStyle( @TIGFramedWindowStyle );
  VTIG_Begin( 'game_menu', Point( 22, 8 ) );
  if VTIG_Selectable( 'Return to game' ) then
  begin
    FResult   := GAMEMENU_CONT;
    FFinished := True;
  end;
  if VTIG_Selectable( '  Help file' ) then
  begin
    FResult   := GAMEMENU_HELP;
    FFinished := True;
  end;
  if VTIG_Selectable( 'Save and quit' ) then
  begin
    FResult   := GAMEMENU_SAVE;
    FFinished := True;
  end;
  if VTIG_Selectable( '    Quit' ) then
  begin
    FResult   := GAMEMENU_QUIT;
    FFinished := True;
  end;
  VTIG_End;
  VTIG_PopStyle;
  if VTIG_EventCancel then
  begin
    FResult   := GAMEMENU_CONT;
    FFinished := True;
  end;
end;

function TGameMenu.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

function TGameMenu.IsModal : Boolean;
begin
  Exit( True );
end;

end.

