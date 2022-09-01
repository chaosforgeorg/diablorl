{$include rl.inc}
// @abstract(Non-game views for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)

unit rlviews;
interface

uses Classes, SysUtils,
     vuielement, viotypes, vuitypes, vioevent, vconui, vconuirl, vconuiext, vuielements;

type TUIMenuScreen = class( TUIElement )
  constructor Create( aParent : TUIElement );
  procedure OnRedraw; override;
protected
  FShift : TUIPoint;
end;

type TUIFullScreen = class( TConUIFullWindow )
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
end;

type TUIManualScreen = class( TUIFullScreen )
  constructor Create( aParent : TUIElement );
end;

type TUIMortemScreen = class( TUIFullScreen )
  constructor Create( aParent : TUIElement );
end;

type TUIMessagesScreen = class( TUIFullScreen )
  constructor Create( aParent : TUIElement; aMessages : TUIChunkBuffer );
end;

type TUIHighscoreViewer = class( TConUIBarFullWindow )
  constructor Create( aParent : TUIElement; aContent : TUIStringArray );
end;

type TUIIntroScreen = class( TUIMenuScreen )
  constructor Create( aParent : TUIElement );
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
end;

type TUIOutroScreen = class( TUIElement )
  constructor Create( aParent : TUIElement );
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
end;

type TUIMainMenuScreen = class( TUIMenuScreen )
  constructor Create( aParent : TUIElement );
  function OnConfirm( aSender : TUIElement ) : Boolean;
  function OnSelect( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
private
  FCurrent : Byte;
  FMenu    : TConUIMenu;
end;

type TUIKlassScreen = class( TUIMenuScreen )
  constructor Create( aParent : TUIElement );
  function OnConfirm( aSender : TUIElement ) : Boolean;
  function OnSelect( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
private
  FCurrent : Byte;
  FMenu    : TConUIMenu;
  FStats   : TConUIText;
  FDesc    : TConUIText;
end;

type TUINameScreen = class( TUIMenuScreen )
  constructor Create( aParent : TUIElement );
  function OnConfirm( aSender : TUIElement ) : Boolean;
end;

type TUIConfirmDialog = class( TConUIWindow )
  constructor Create( aParent : TUIElement; const aQuery : AnsiString; const aQuery2 : AnsiString = '' );
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
end;



const GAMEMENU_CONT = 0;
      GAMEMENU_HELP = 2;
      GAMEMENU_SAVE = 3;
      GAMEMENU_QUIT = 4;

type TUIGameMenu = class( TConUIWindow )
  constructor Create( aParent : TUIElement );
  function OnCancel( aSender : TUIElement ) : Boolean;
  function OnConfirm( aSender : TUIElement ) : Boolean;
private
  FMenu  : TConUIMenu;
end;


implementation

uses vuiconsole, vluasystem, vutil, rlglobal, rlui, rlgame, math;

{ TUIHighscoreViewer }

constructor TUIHighscoreViewer.Create(aParent: TUIElement; aContent: TUIStringArray);
var iRect    : TUIRect;
    iContent : TConUIStringList;
begin
  inherited Create( aParent, 'DiabloRL Highscores', '@<Use arrows, PgUp, PgDown to scroll, Escape or Enter to exit@>' );
  iRect := aParent.GetDimRect.Shrinked(1,2);
  iContent := TConUIStringList.Create( Self, iRect, aContent, True );
  iContent.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  TConUIScrollableIcons.Create( Self, iContent, iRect, Point( FAbsolute.x2 - 7, FAbsolute.y ) );
end;

{ TUIConfirmDialog }

constructor TUIConfirmDialog.Create ( aParent : TUIElement; const aQuery : AnsiString; const aQuery2 : AnsiString = '' );
var iPos  : TPoint;
    iSize : TPoint;
begin
  iSize.Init( Length( aQuery )+6, 6 );
  if aQuery2 <> '' then
  begin
    iSize.X := Max( iSize.X, Length( aQuery2 ) + 6 );
    iSize.Y := iSize.Y + 1;
  end;
  iPos := aParent.AbsDim.GetCenter - Point( iSize.X div 2 + 1, iSize.Y div 2 + 2 );
  inherited Create( aParent, Rectangle( iPos, iSize ), '' );
  TConUILabel.Create( Self, Point( 1, 0 ), aQuery );
  if aQuery2 <> '' then TConUILabel.Create( Self, Point( 1, 1 ), aQuery2 );
  TConUILabel.Create( Self, Point( iSize.X div 2 - 4, iSize.Y-4 ), '@yy@> / @yn@>' );
  UI.Root.GrabInput( Self );
  FEventFilter := [ VEVENT_KEYDOWN ];
end;

function TUIConfirmDialog.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  case event.Code of
    VKEY_N,
    VKEY_ESCAPE : begin Free; UI.SetUILoopResult(0); Exit( True ); end;
    VKEY_Y      : begin Free; UI.SetUILoopResult(1); Exit( True ); end;
  else Exit( inherited OnKeyDown( event ) );
  end;
end;

{ TUIGameMenu }

constructor TUIGameMenu.Create ( aParent : TUIElement ) ;
var iPos  : TPoint;
    iSize : TPoint;
begin
  iSize.Init( 22, 8 );
  iPos := aParent.AbsDim.GetCenter - Point( iSize.X div 2, iSize.Y div 2 + 2 );
  inherited Create( aParent, Rectangle( iPos, iSize ), '' );
  EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  UI.Root.GrabInput( Self );

  FMenu := TConUIMenu.Create( Self, Point(2,1) );
  FMenu.Pos := FMenu.Pos + Point(1,0);
  FMenu.OnConfirmEvent := @OnConfirm;
  FMenu.OnCancelEvent  := @OnCancel;

  FMenu.Add(' Return to game');
  FMenu.Add('   Help file');
  FMenu.Add(' Save and quit');
  FMenu.Add('     Quit');
end;

function TUIGameMenu.OnCancel ( aSender : TUIElement ) : Boolean;
begin
  UI.SetUILoopResult( GAMEMENU_CONT );
  Free;
  Exit( True );
end;

function TUIGameMenu.OnConfirm ( aSender : TUIElement ) : Boolean;
begin
  if (FMenu.Selected = GAMEMENU_QUIT) and (not GodMode) then
    if not UI.YesNoDialog('If you quit without saving, your character will be lost!', 'Are you sure?') then
    begin
      UI.Root.GrabInput( Self );
      Exit( True );
    end;

  if FMenu.Selected = 1
    then UI.SetUILoopResult( GAMEMENU_CONT )
    else UI.SetUILoopResult( FMenu.Selected );
  Free;
  Exit( True );
end;

{ TUIMenuScreen }

constructor TUIMenuScreen.Create ( aParent : TUIElement ) ;
var iRect : TUIRect;
begin
  iRect := aParent.GetDimRect;
  inherited Create( aParent, iRect );
  FShift.Init( (iRect.Dim.X - 80) div 2, (iRect.Dim.Y - 25) div 2 );
end;

procedure TUIMenuScreen.OnRedraw;
var iCon : TUIConsole;
begin
  inherited OnRedraw;
  iCon.Init( TConUIRoot(FRoot).Renderer );
  iCon.ClearRect( FAbsolute, FBackColor );
  iCon.Print( Point(20,3)+FShift, Red, Black,
  '  ####                           ####   '#10+
  '  #####  #    ##    ###    #    ######  '#10+
  '  ## ##  #   #  #   #  #   #    ##  ##  '#10+
  '  ## ##  #   #  #   ###    #    ##  ##  '#10+
  '  #@y# #@r#  #   @y#@r##@y#   #  #   #    @y#@r#  #@y#  '#10+
  '  ####   #   #  #   ###    #### ######  '#10+
  '  ###           #                ####   @n', True);
  iCon.PrintEx( Point(20,10)+FShift, Point(0,0), 1, Brown, Black,'           R O G U E L I K E            '#10+
  '                '+VERSION+#10+
  #10+
  '         by Kornel Kisielewicz          '#10+
  ' Chris Johnson and Mel''nikova Anastasia', True);
end;

{ TUIFullScreen }

function TUIFullScreen.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if event.ModState <> [] then Exit( inherited OnKeyDown( event ) );
  case event.Code of
    VKEY_SPACE,
    VKEY_ESCAPE,
    VKEY_ENTER  : begin Free; Exit( True ); end;
  else Exit( inherited OnKeyDown( event ) );
  end;
end;

{ TUIManualScreen }

constructor TUIManualScreen.Create ( aParent : TUIElement ) ;
var iContent : TConUIStringList;
    iRect    : TUIRect;
begin
  inherited Create( aParent,
    ' @<DiabloRL@> Manual (@<manual.txt@>)',
    ' Use @<arrows@>, @<PgUp@>, @<PgDown@> to scroll, @<Escape@> or @<Enter@> to exit.'
  );
  EventFilter := [ VEVENT_KEYDOWN ];
  iRect := aParent.GetDimRect.Shrinked(1,2);
  iContent := TConUIStringList.Create( Self, iRect, TextFileToUIStringArray(DataPath+'manual.txt'), True );
  iContent.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  TConUIScrollableIcons.Create( Self, iContent, iRect, Point( FAbsolute.x2 - 7, FAbsolute.y ) );
end;

{ TUIMortemScreen }

constructor TUIMortemScreen.Create ( aParent : TUIElement ) ;
var iContent : TConUIStringList;
    iRect    : TUIRect;
begin
  inherited Create( aParent,
    ' @<DiabloRL@> PostMortem (@<mortem.txt@>)',
    ' Use @<arrows@>, @<PgUp@>, @<PgDown@> to scroll, @<Escape@> or @<Enter@> to exit.'
  );
  EventFilter := [ VEVENT_KEYDOWN ];
  iRect := aParent.GetDimRect.Shrinked(1,2);
  iContent := TConUIStringList.Create( Self, iRect, TextFileToUIStringArray( WritePath + 'mortem.txt' ), True );
  iContent.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  TConUIScrollableIcons.Create( Self, iContent, iRect, Point( FAbsolute.x2 - 7, FAbsolute.y ) );
end;

{ TUIMessagesScreen }

constructor TUIMessagesScreen.Create ( aParent : TUIElement;
  aMessages : TUIChunkBuffer ) ;
var iContent : TConUIChunkBuffer;
    iRect    : TUIRect;
begin
  inherited Create( aParent,
    ' @<DiabloRL@> Past messages viewer',
    ' Use @<arrows@>, @<PgUp@>, @<PgDown@> to scroll, @<Escape@> or @<Enter@> to exit.'
  );
  EventFilter := [ VEVENT_KEYDOWN ];
  iRect := aParent.GetDimRect.Shrinked(1,2);
  iContent := TConUIChunkBuffer.Create( Self, iRect, aMessages, False );
  iContent.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEDOWN ];
  TConUIScrollableIcons.Create( Self, iContent, iRect, Point( FAbsolute.x2 - 7, FAbsolute.y ) );
end;


{ TUIIntroScreen }

constructor TUIIntroScreen.Create ( aParent : TUIElement ) ;
begin
  inherited Create( aParent );
  EventFilter := [ VEVENT_KEYDOWN ];
  TConUIText.Create( Self, Rectangle( Point( 10, 15 ) + FShift, 60, 9 ),'@n'+
  'This is the 0.5 version of Diablo Roguelike, much features'#10+
  'are still missing, many more are planned. If you''d like to'#10+
  'see this project continued,  please drop by the ChaosForge'#10+
  'forums (@lhttp://forum.chaosforge.org@n),  and leave a comment'#10+
  'at the DiabloRL board to encourage further development!'#10+
  'encourage further development!                        '#10+
  ''#10+
  'To enable sound and music, edit the @<config.lua@n file.'#10+
  'Press <@LEnter@n> to continue...');
end;

function TUIIntroScreen.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if event.ModState <> [] then Exit( inherited OnKeyDown( event ) );
  case event.Code of
    VKEY_SPACE,
    VKEY_ESCAPE,
    VKEY_ENTER  : begin Free; Exit( True ); end;
  else Exit( inherited OnKeyDown( event ) );
  end;
end;

{ TUIOutroScreen }

constructor TUIOutroScreen.Create ( aParent : TUIElement ) ;
var iCon : TUIConsole;
begin
  inherited Create( aParent, aParent.GetDimRect );
  EventFilter := [ VEVENT_KEYDOWN ];
  iCon.Init( TConUIRoot(FRoot).Renderer );
  iCon.Clear;
  TConUIText.Create( Self, aParent.GetDimRect.Shrinked(1,1),
    'Thank you for playing Diablo Roguelike!'#10+
    'This is just a beta, keep your eyes open for the full release!'#10+
    #10+
    'Features planned for DiabloRL:'#10+
    ' -- the full range of Diablo items, monsters, uniques, prefixes and spells'#10+
    ' -- entering hell and missing caves content'#10+
    ' -- all the original Diablo quests with the original texts'#10+
    ' -- all the hidden quest locations and uniques'#10+
    ' -- additional quests by Blizzard that didn''t appear in Diablo'#10+
    ' -- missing spells and spell effects'#10+
    ' -- additional Hellfire classes -- Monk, Bard and Barbarian'#10+
    ' -- maybe additional Hellfire content -- spells, items, quests, uniques.'#10+
    ' -- Programmer''s edition -- how the author himself see''s the world of Diablo'#10+
    ' -- and special rooms in dungeons'#10+
    #10+
    #10+
    'Well, at least that would be if DiabloRL would be continued. It all depends'#10+
    'on @Lyou@>! If you want this project continued then drop me a note at'#10+
    '@Ladmin(at)chaosforge.org@>... Comments, suggestions, death threats all welcome.'#10+
    #10+
    'Again, thank you for your time spent playing DiabloRL.'#10+
    'Press @<Enter@> to quit...');

end;

function TUIOutroScreen.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if event.ModState <> [] then Exit( inherited OnKeyDown( event ) );
  case event.Code of
    VKEY_SPACE,
    VKEY_ESCAPE,
    VKEY_ENTER  : begin Free; Exit( True ); end;
  else Exit( inherited OnKeyDown( event ) );
  end;
end;

{ TUIMainMenuScreen }

constructor TUIMainMenuScreen.Create ( aParent : TUIElement ) ;
var iMenuWindow : TConUIWindow;
begin
  inherited Create( aParent );
  FCurrent := 1;
  EventFilter := [ VEVENT_KEYDOWN ];
  iMenuWindow := TConUIWindow.Create( Self, Rectangle( Point( 29, 16 ) + FShift, 21, 9 ), '' );
  iMenuWindow.Padding := Point(1,0);
  FMenu := TConUIMenu.Create( iMenuWindow, Point(1,1) );
  FMenu.SelectInactive := False;
  FMenu.Add('   New Game');
  FMenu.Add('   Load Game', FileExists( WritePath + 'save' ) );
  FMenu.Add('Show Highscores');
  FMenu.Add('  Show Manual');
  FMenu.Add('   Quit Game');

  FMenu.OnConfirmEvent := @OnConfirm;
  FMenu.OnSelectEvent  := @OnSelect;

end;

function TUIMainMenuScreen.OnConfirm ( aSender : TUIElement ) : Boolean;
begin
  case FMenu.Selected of
    1 : if FileExists('save') then if not UI.YesNoDialog( 'This will erase your previously saved game.','Are you sure?' ) then Exit( True );
    2 : GameLoad := True;
    3 : begin UI.RunUILoop( TUIHighscoreViewer.Create( UI.Root, Game.Persistence.ScoreList ) ); Exit( True ); end;
    4 : begin UI.RunUILoop( TUIManualScreen.Create( UI.Root ) ); Exit( True ); end;
    5 : GameEnd := True;
  end;
  Free;
  UI.PlaySound('sfx/items/titlslct.wav');
  Exit( True );
end;

function TUIMainMenuScreen.OnSelect ( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
begin
  if FCurrent <> FMenu.Selected then
    UI.PlaySound('sfx/items/titlemov.wav');
  FCurrent := FMenu.Selected;
  Exit( True );
end;

{ TUIKlassScreen }

constructor TUIKlassScreen.Create ( aParent : TUIElement ) ;
var iLeftWindow  : TConUIWindow;
    iRightWindow : TConUIWindow;
    iSep         : TConUISeparator;
    iCount, i    : Byte;
begin
  inherited Create( aParent );
  iLeftWindow  := TConUIWindow.Create( Self, Rectangle( Point(0, 14)+FShift, 29, 11 ), 'Choose class' );
  iRightWindow := TConUIWindow.Create( Self, Rectangle( Point(29, 14)+FShift, 51, 11 ), 'Description' );
  iSep := TConUISeparator.Create(iLeftWindow,VORIENT_VERTICAL,10);

  FCurrent := 1;
  FMenu  := TConUIMenu.Create( iSep.Left, Point(1,1) );
  FMenu.OnConfirmEvent := @OnConfirm;
  FMenu.OnSelectEvent  := @OnSelect;

  FStats := TConUIText.Create( iSep.Right, '');
  FDesc  := TConUIText.Create( iRightWindow, '');
  iCount := 3;
  for i := 1 to iCount do
  begin
    FMenu.Add(LuaSystem.Get(['klasses', i, 'name']));
  end;
end;

function TUIKlassScreen.OnConfirm ( aSender : TUIElement ) : Boolean;
begin
  GameClass := FMenu.Selected;
  UI.PlaySound('sfx/items/titlslct.wav');
  Free;
  Exit( True );
end;

function TUIKlassScreen.OnSelect ( aSender : TUIElement; aIndex : DWord;
  aItem : TUIMenuItem ) : Boolean;
begin
  if FCurrent <> FMenu.Selected then
    UI.PlaySound('sfx/items/titlemov.wav');
  FCurrent := FMenu.Selected;

  with LuaSystem.GetTable(['klasses', FCurrent ]) do
  try
    FStats.Text :=
      Format( ' Level     : %d'#10, [ GetInteger('level') ] )+
      #10+
      Format( ' Strength  : %d'#10, [ GetInteger('str') ] )+
      Format( ' Magic     : %d'#10, [ GetInteger('mag') ] )+
      Format( ' Dexterity : %d'#10, [ GetInteger('dex') ] )+
      Format( ' Vitality  : %d',    [ GetInteger('vit') ] );
    FDesc.Text := GetString('desc');
  finally
    Free;
  end;
  Exit( True );
end;

{ TUINameScreen }

constructor TUINameScreen.Create ( aParent : TUIElement ) ;
var iWindow : TConUIWindow;
    iInput  : TConUIInputLine;
begin
  inherited Create( aParent );
  iWindow := TConUIWindow.Create( Self, Rectangle( Point(29, 16)+FShift, 18, 5 ), 'Enter name' );
  iInput  := TConUIInputLine.Create( iWindow, Point(1,0), 12 );
  iInput.BackColor := Red;
  iInput.OnConfirmEvent := @OnConfirm;
end;

function TUINameScreen.OnConfirm ( aSender : TUIElement ) : Boolean;
begin
  GameName := Trim( TConUIInputLine( aSender ).Input );
  UI.PlaySound('sfx/items/titlslct.wav');
  Free;
  Exit( True );
end;

end.

