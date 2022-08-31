{$include rl.inc}
// @abstract(Game views for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)

unit rlgviews;
interface

uses Classes, SysUtils,
     vuielement, viotypes, vuitypes, vioevent, vconui, vconuirl, vuielements,
     rlglobal, rlthing, rlitem, vrltools;

type

{ TUIStatusLine }

TUIStatusLine = object
  Text : String;
  Color : TIOColor;
  procedure Init( aText : String; aColor : TIOColor = LightGray );
end;

{ TUIStatus }

TUIStatus = class( TUIElement )
  constructor Create( aParent : TUIElement );
  procedure OnRedraw; override;
  procedure Reset;
  procedure Update( c : TCoord2D );
  procedure Update( aThing : TThing );
private
  procedure DrawOrb( aValue, aMax : Integer; aColor : TIOColor; aX : byte );
private
  FLine1 : TUIStatusLine;
  FLine2 : TUIStatusLine;
  FLine3 : TUIStatusLine;
end;

{ TUIMainScreen }

TUIMainScreen = class( TUIElement )
  constructor Create( aParent : TUIElement );
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  procedure UpdateMap;
  procedure ClearLeft;
  procedure ClearRight;
  procedure ClearBoth;
private
  FLeft    : TUIElement;
  FRight   : TUIElement;
  FMap     : TConUIMapArea;
  FStatus  : TUIStatus;
  FMsg     : TConUIMessages;
public
  property Left   : TUIElement     read FLeft;
  property Right  : TUIElement     read FRight;
  property Msg    : TConUIMessages read FMsg;
  property Map    : TConUIMapArea  read FMap;
  property Status : TUIStatus      read FStatus;
end;

{ TUIPlotWindow }

TUIPlotWindow = class(TConUIWindow)
  constructor Create( aParent: TUIElement; const aText : TUIString );
  procedure OnRedraw; override;
  procedure OnUpdate( aTime : DWord ); override;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  destructor Destroy; override;
private
  FText      : TUIChunkList;
  FStartTime : DWord;
end;

{ TUIItemInfo }

TUIItemInfo = class(TConUIWindow)
  constructor Create( aParent: TUIElement; const aItem : TItem );
  procedure OnRedraw; override;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  destructor Destroy; override;
private
  FLine1 : TUIString;
  FLine2 : TUIString;
  FLine3 : TUIString;
end;

{ TUIShopWindow }

TUIShopWindow = class(TConUIWindow)
  constructor Create( aParent: TUIElement; const aTitle : TUIString );
  procedure Add( aItem : TItem; aPriceType : TPriceType = COST_NONE ); reintroduce;
  procedure Close( const aEmptyLabel : AnsiString );
  function OnConfirm( aSender : TUIElement ) : Boolean;
  function OnCancel( aSender : TUIElement ) : Boolean;
  function OnSelect( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
private
  FMenu : TConUIMenu;
end;

{ TUIPanel }

TUIPanel = class( TConUIWindow )
  constructor Create( aParent : TUIElement; const aTitle : AnsiString );
  function Close : Boolean;
  function CloseAll : Boolean;
end;

{ TUICharWindow }

TUICharWindow = class( TUIPanel )
  constructor Create( aParent : TUIElement );
  procedure OnRedraw; override;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
end;

{ TUIJournalWindow }

TUIJournalWindow = class( TUIPanel )
  constructor Create( aParent : TUIElement );
  function OnConfirm( aSender : TUIElement ) : Boolean;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  destructor Destroy; override;
end;

{ TUITalkWindow }

TUITalkWindow = class( TUIPanel )
  constructor Create( aParent : TUIElement; const aIntro : AnsiString );
  procedure Add( const aOption : AnsiString; aActive : Boolean = True ); reintroduce;
  function OnConfirm( aSender : TUIElement ) : Boolean;
  function OnCancel( aSender : TUIElement ) : Boolean;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  destructor Destroy; override;
private
  FMenu  : TConUIMenu;
end;

{ TUIInventoryWindow }
// TODO - handle cases when equipment gets destroyed or
//        mutated (shrines/magic) when viewing
// TODO - Quickslot marking in inventory
TUIInventoryWindow = class( TUIPanel )
  constructor Create( aParent : TUIElement );
  procedure UpdateMenus;
  function OnInvConfirm( aSender : TUIElement ) : Boolean;
  function OnEqConfirm( aSender : TUIElement ) : Boolean;
  function OnSelect( aSender : TUIElement; aIndex : DWord; aItem : TUIMenuItem ) : Boolean;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  procedure SwitchMode;
  function CurrentItem : TItem;
  destructor Destroy; override;
private
  FCurrent : Byte;
  FMode    : ( UIInvMode, UIEqMode );
  FInvMenu : TConUIMenu;
  FEqMenu  : TConUIMenu;
  FVolume  : TConUILabel;
  FEqEmpty : Boolean;
end;

{ TUISpellWindow }

TUISpellWindow = class( TUIPanel )
  constructor Create( aParent : TUIElement );
  function OnConfirm( aSender : TUIElement ) : Boolean;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  destructor Destroy; override;
end;

{ TUIQsWindow }

TUIQsWindow = class( TConUIWindow )
  constructor Create( aParent : TUIElement );
  function OnConfirm( aSender : TUIElement ) : Boolean;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  destructor Destroy; override;
private
  FMenu : TConUIMenu;
end;

{ TUISkillWindow }

type TUISkillWindow = class( TConUIWindow )
  constructor Create( aParent : TUIElement );
  function OnConfirm( aSender : TUIElement ) : Boolean;
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  destructor Destroy; override;
end;

type TUITravelWindow = class( TConUIWindow )
  constructor Create( aParent : TUIElement );
  function OnConfirm( aSender : TUIElement ) : Boolean;
  function OnCancel( aSender : TUIElement ) : Boolean;
  destructor Destroy; override;
end;

implementation

uses math, vutil, vuiconsole, vluasystem,
     rlgame, rlconfig, rllevel, rlui, rlnpc, rlplayer;

{ TUIStatusLine }

procedure TUIStatusLine.Init(aText: String; aColor: TIOColor);
begin
  Text := aText;
  Color := aColor;
end;

function UIStatusLine(aText: String; aColor: TIOColor = LightGray) : TUIStatusLine;
begin
  UIStatusLine.Text := aText;
  UIStatusLine.Color := aColor;
end;

{ TUIMainScreen }

constructor TUIMainScreen.Create ( aParent : TUIElement ) ;
begin
  inherited Create( aParent, aParent.GetDimRect );
  FMsg    := TConUIMessages.Create( Self, Rectangle( 1,0,UI.SizeX-2,2), nil, 1000 );
  FMsg.ForeColor := DarkGray;
  EventFilter := [ VEVENT_KEYDOWN ];
  FMap    := TConUIMapArea.Create( TUIElement.Create( Self, Rectangle( 0,2,UI.SizeX,UI.SizeY-5) ), UI );
  FLeft   := TUIElement.Create( Self,Rectangle( 0, 2, UI.SizeX div 2, UI.SizeY-5 ) );
  FRight  := TUIElement.Create( Self,Rectangle( UI.SizeX div 2, 2, UI.SizeX div 2, UI.SizeY-5 ) );
  FStatus := TUIStatus.Create( Self );
end;

function TUIMainScreen.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if UI.Player.HP <= 0 then Exit( False );
  case UI.IOKeyCodeToCommand(event.Code) of
    COMMAND_CWIN       : begin ClearBoth; Exit( True ) end;
    COMMAND_JOURNAL    : if FLeft.Child  is TUIJournalWindow   then begin ClearLeft;  Exit( True ) end else begin ClearLeft; TUIJournalWindow.Create( FLeft ); UpdateMap; Exit( True ); end;
    COMMAND_PLAYERINFO : if FLeft.Child  is TUICharWindow      then begin ClearLeft;  Exit( True ) end else begin ClearLeft; TUICharWindow.Create( FLeft ); UpdateMap; Exit( True ); end;
    COMMAND_INVENTORY  : if FRight.Child is TUIInventoryWindow then begin ClearRight; Exit( True ) end else begin ClearRight; TUIInventoryWindow.Create( FRight ); UpdateMap; Exit( True ); end;
    COMMAND_SPELLBOOK  : if FRight.Child is TUISpellWindow     then begin ClearRight; Exit( True ) end else begin ClearRight; TUISpellWindow.Create( FRight ); UpdateMap; Exit( True ); end;
    COMMAND_QUICKSKILL : begin UI.RunUILoop( TUISkillWindow.Create( FRoot ) ); Exit( True ); end;
    COMMAND_QUICKSLOT  : if not (FRight.Child is TUIInventoryWindow) then begin UI.RunUILoop( TUIQsWindow.Create( FRoot ) ); Exit( True ); end else Exit( False );
  else Exit( inherited OnKeyDown ( event ) );
  end;
end;

procedure TUIMainScreen.ClearLeft;
begin
  if FLeft.Child <> nil then FLeft.Child.Free;
  UpdateMap;
end;

procedure TUIMainScreen.ClearRight;
begin
  if FRight.Child <> nil then FRight.Child.Free;
  UpdateMap;
end;

procedure TUIMainScreen.ClearBoth;
begin
  if FLeft.Child <> nil then FLeft.Child.Free;
  if FRight.Child <> nil then FRight.Child.Free;
  UpdateMap;
end;

procedure TUIMainScreen.UpdateMap;
begin
  if (FLeft.Child = nil) and (FRight.Child = nil) then
    FMap.SetArea( Rectangle( 0, 0, UI.SizeX, UI.SizeY - 5 ) )
  else
  if FLeft.Child = nil then
    FMap.SetArea( Rectangle( 0, 0, UI.SizeX div 2, UI.SizeY - 5 ) )
  else
    FMap.SetArea( Rectangle( UI.SizeX div 2, 0, UI.SizeX div 2, UI.SizeY - 5 ) );
  UI.Focus(UI.Player.Position);
  FMap.ClearMarks;
  FMap.OnRedraw;
end;

{ TUIStatus }

constructor TUIStatus.Create ( aParent : TUIElement ) ;
begin
  inherited Create( aParent, Rectangle( 0,UI.SizeY-3,UI.SizeX,3 ) );
  Reset;
end;

procedure TUIStatus.OnRedraw;
var iCon     : TUIConsole;
    iString  : AnsiString;
    iCount   : DWord;
  procedure DurMark( aItem : TItem; p : TPoint; const aVis : AnsiString );
  var iColor : TUIColor;
  begin
    if aItem = nil then Exit;
    with aItem do
    begin
      if Dur >= (DurMax div 4) then Exit;
      if Dur <= Max(DurMax div 6, 1)
        then iColor := LightRed
        else iColor := Brown;
      iCon.RawPrint( p, iColor, aVis );
    end;
  end;

  procedure CenterPrint( const aLine : AnsiString; aPos : Byte; aColor : TUIColor );
  begin
    if aLine = '' then Exit;
    iCon.PrintEx(
    Point( (FAbsolute.w div 2) - Length( StripEncoding( aLine ) ) div 2, aPos ),
    Point(0,0), 1, aColor, Black, aLine, True );
  end;

begin
  inherited OnRedraw;
  iCon.Init( TConUIRoot(FRoot).Renderer );
  iCon.ClearRect( FAbsolute );
  iCon.RawPrint( Point( 1, UI.SizeY-2 ), DarkGray, StringOfChar( '-',GetDimRect().w) );
  if UI.Player = nil then Exit;
  with UI.Player do
  begin
    DrawOrb( HP, getLife, Red, 4 );
    if Flags[ nfManaShield ] then
      DrawOrb(MP, getMana, LightBlue, UI.SizeX-8)
    else
      DrawOrb(MP, getMana, Blue, UI.SizeX-8);
    iString := TLevel(UI.Player.Parent).Name;
    iCon.PrintEx( Point( UI.SizeX-12-Length(iString), UI.SizeY-2 ), Point(0,0), 1, LightGray, Black, ' ' + iString + ' ', True);
    if LevelUp then
    begin
      iCon.Print( Point(5, UI.SizeY-5), Red, Black, '[@y+@r]', True );
      iCon.PrintEx( Point(3, UI.SizeY-4), Point(0,0), 1, White, Black, 'Level Up!', True);
    end;
    DurMark( Equipment[slotHead],  Point( UI.SizeX-1,UI.SizeY-10 ), #127 );
    DurMark( Equipment[slotTorso], Point( UI.SizeX-1,UI.SizeY-9  ), #219 );
    DurMark( Equipment[slotRHand], Point( UI.SizeX-2,UI.SizeY-10 ), #179 );
    DurMark( Equipment[slotLHand], Point( UI.SizeX-2,UI.SizeY-9  ), #197 );

    iCon.Print( Point( 11, UI.SizeY-2 ), DarkGray, Black, ' [@<'+StringOfChar('.', ITEMS_QS)+'@>] ', True);
    for iCount := 1 to ITEMS_QS do
      if QuickSlot[iCount] <> nil then
        iCon.DrawChar( Point( 12+iCount, UI.SizeY-2 ), QuickSlot[iCount].Color, QuickSlot[iCount].Picture );

    if Spell.Spell > 0 then
    case Spell.Source of
      CAST_STAFF : iCon.PrintEx( Point(12, UI.SizeY-1), Point(0,0), 1, DarkGray, Black, UI.Strip(Equipment[SlotRHand].getSpellName), True);
      CAST_SCROLL: iCon.PrintEx( Point(12, UI.SizeY-1), Point(0,0), 1, DarkGray, Black, Spell.Name, True);
      else
        iCon.PrintEx( Point(12, UI.SizeY-1), Point(0,0), 1, DarkGray, Black, Spell.Name, True);
    end;

    CenterPrint( FLine1.Text, UI.SizeY-2, FLine1.Color );
    CenterPrint( FLine2.Text, UI.SizeY-1, FLine2.Color );
    CenterPrint( FLine3.Text, UI.SizeY  , FLine3.Color );
  end;
end;

procedure TUIStatus.Reset;
begin
  FDirty := True;
  FLine1 := UIStatusLine('');
  FLine2 := UIStatusLine('');
  FLine3 := UIStatusLine('');
end;

procedure TUIStatus.Update ( c : TCoord2D ) ;
begin
  Reset;
  with Game.Level do
  begin
    if not isVisible( c ) then Exit;
    if (not isEmpty( c, [efNoMonsters])) and (not (NPCs[c].Flags[nfInvisible]))
      then Update( NPCs[c] )
      else if not isEmpty(c, [efNoItems])
        then Update( Items[c] )
        else
        begin
          FLine2 := UIStatusLine(CellData[Cell[c]].Name);
          if CellHook_OnTravelName in CellData[Cell[c]].hooks then
            FLine2 := UIStatusLine(LuaSystem.ProtectedCall([ 'cells',CellData[Cell[c]].id,CellHookNames[ CellHook_OnTravelName ] ], [Game.Level] ));
        end;

  end;
end;

procedure TUIStatus.Update ( aThing : TThing ) ;
var iCount  : Byte;
    iStatus : AnsiString;
begin
  Reset;
  if aThing = nil then Exit;

  if aThing is TNPC then
  with aThing as TNPC do
  begin
    if isPlayer then Exit;
    if AI in AIMonster + [AIGolem] then
    begin
      iCount := Max( 0, Min( 10, (HP * 10) div HPMax ) );
      FLine1 := UIStatusLine('[@r' + StringOfChar( '#', iCount ) + '@d' + StringOfChar( '.', 10-iCount ) + ']');
      FLine2 := UIStatusLine( Name );
      iCount := Game.Player.Kills.Get( ID );
      if iCount > 0 then FLine3 := UIStatusLine('Total kills : ' + IntToStr( iCount ));
      if iCount > 15 then FLine3.Text += '   ('+GetResistancesString+'@>)';

      if iCount > 30 then
        FLine3.Text += '   HP: ' +
          IntToStr(LuaSystem.Get(['npcs', id, 'hpmin'])) + '-' +
          IntToStr(LuaSystem.Get(['npcs', id, 'hpmax']));
    end
    else
      FLine2 := UIStatusLine( Name );
  end;

  if aThing is TItem then
  with aThing as TItem do
  begin
    iStatus := GetStatusInfo1;
    if iStatus = ''
      then FLine2 := UIStatusLine( GetName(PlainName), InvColor )
      else
      begin
        FLine1 := UIStatusLine( '[' + GetName(PlainName) + ']', InvColor );
        FLine2 := UIStatusLine( iStatus, InvColor );
      end;
    FLine3 := UIStatusLine( GetStatusInfo2, InvColor );
  end;

end;

procedure TUIStatus.DrawOrb ( aValue, aMax : Integer; aColor : TIOColor; aX : byte ) ;
var iPercent : Integer;
    iCon     : TUIConsole;
  function FillChar( aEmpty : Byte; aValue : Byte ) : Char;
  begin
    if aValue <= aEmpty    then Exit('.');
    if aValue <= aEmpty+9  then Exit('-');
    if aValue <= aEmpty+17 then Exit('=');
    Exit('#');
  end;

begin
  iCon.Init( TConUIRoot(FRoot).Renderer );
  if (aMax <= 0) or (aValue <= 0)
    then iPercent := 0
    else iPercent := Min( (aValue * 100) div aMax, 100 );

  iCon.RawPrint( Point( aX+1, UI.SizeY-3), aColor, StringOfChar( FillChar( 80, iPercent ), 4 ) );
  iCon.RawPrint( Point( aX  , UI.SizeY-2), aColor, StringOfChar( FillChar( 55, iPercent ), 6 ) );
  iCon.RawPrint( Point( aX  , UI.SizeY-1), aColor, StringOfChar( FillChar( 30, iPercent ), 6 ) );
  iCon.RawPrint( Point( aX+1, UI.SizeY  ), aColor, StringOfChar( FillChar( 5,  iPercent ), 4 ) );

end;

{ TUIPlotWindow }

constructor TUIPlotWindow.Create ( aParent : TUIElement; const aText : TUIString ) ;
var iCon   : TUIConsole;
    iShift : TUIPoint;
    iRect  : TUIRect;
begin
  iRect := aParent.GetDimRect;
  iShift.Init( (iRect.Dim.X - 80) div 2, (iRect.Dim.Y - 25) div 2 );
  inherited Create( aParent, Rectangle( Point(7, 3)+iShift, 65, 18 ), '' );
  TConUILabel.Create( Self, Point( -9,-5 )-iShift,'@d Press <@<Enter@>>, <@<Space@>> or <@<Escape@>> to skip...                     ' );
  EventFilter := [ VEVENT_KEYDOWN ];
  iCon.Init( TConUIRoot(FRoot).Renderer );
  FText := iCon.Chunkify( aText, Point( FAbsolute.w-4, 1000 ), Yellow );
  FStartTime := 0;
  FRoot.GrabInput( Self );
  OnUpdate(0);
end;

procedure TUIPlotWindow.OnRedraw;
var iCon : TUIConsole;
    iDelay: Integer;
    iCellH: Integer;
begin
  inherited OnRedraw;
  iCon.Init( TConUIRoot(FRoot).Renderer );
  iCellH := 18;
  //causes glitches when console grid size does not match windows size
  //iCellH := UI.Driver.GetSizeY div iCon.Raw.SizeY;
  iDelay := (1100 div iCellH) * iCellH;
  iCon.PrintEx( Point( FAbsolute.Pos.x+2, FAbsolute.pos.y + FAbsolute.h - 2 - FStartTime div iDelay ),
                Point(0, -FStartTime mod iDelay div ( iDelay div iCellH)), 1, FText, Yellow, Black, FAbsolute.Shrinked(2) );
end;

procedure TUIPlotWindow.OnUpdate ( aTime : DWord ) ;
begin
  FStartTime += aTime;
  TConUIRoot( FRoot ).NeedRedraw := True;
end;

function TUIPlotWindow.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if event.ModState <> [] then Exit( True );
  case event.Code of
    VKEY_SPACE,
    VKEY_ESCAPE,
    VKEY_ENTER  : begin Free; Exit( True ); end;
  else Exit( True );
  end;
end;

destructor TUIPlotWindow.Destroy;
begin
  FRoot.GrabInput( nil );
  inherited Destroy;
end;

{ TUIItemInfo }

constructor TUIItemInfo.Create ( aParent : TUIElement; const aItem : TItem ) ;
var iCon   : TUIConsole;
    iShift : TUIPoint;
    iRect  : TUIRect;
    iStatus: String;
begin
  with aItem do
  begin
    iStatus := GetStatusInfo1;
    if iStatus = ''
      then FLine2 := '@'+ColorCodes[Color] + GetName(PlainName)
      else
      begin
        FLine1 := '@'+ColorCodes[Color] + GetName(PlainName);
        FLine2 := '@'+ColorCodes[Color] + iStatus;
      end;
    FLine3 := '@'+ColorCodes[Color] + GetStatusInfo2;
  end;
  iRect := aParent.GetDimRect;
  iShift.Init( (iRect.Dim.X - 80) div 2, (iRect.Dim.Y - 10) div 2 );
  inherited Create( aParent, Rectangle( Point(7, 3)+iShift, 65, 7 ), '' );
  TConUILabel.Create( Self, Point( -9,-5 )-iShift,'@d Press <@<Enter@>>, <@<Space@>> or <@<Escape@>> to continue...                 ' );
  EventFilter := [ VEVENT_KEYDOWN ];
  iCon.Init( TConUIRoot(FRoot).Renderer );
  FRoot.GrabInput( Self );
  OnUpdate(0);
end;

procedure TUIItemInfo.OnRedraw;
var iCon : TUIConsole;
begin
  inherited OnRedraw;
  iCon.Init( TConUIRoot(FRoot).Renderer );
  iCon.Print(Point( FAbsolute.Pos.x + (FAbsolute.w - length(StripEncoding(FLine1))) div 2, FAbsolute.pos.y+2 ), White, Black, FLine1, true );
  iCon.Print(Point( FAbsolute.Pos.x + (FAbsolute.w - length(StripEncoding(FLine2))) div 2, FAbsolute.pos.y+3 ), White, Black, FLine2, true );
  iCon.Print(Point( FAbsolute.Pos.x + (FAbsolute.w - length(StripEncoding(FLine3))) div 2, FAbsolute.pos.y+4 ), White, Black, FLine3, true );
end;

function TUIItemInfo.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if event.ModState <> [] then Exit( True );
  case event.Code of
    VKEY_SPACE,
    VKEY_ESCAPE,
    VKEY_ENTER  : begin Free; Exit( True ); end;
  else Exit( True );
  end;
end;

destructor TUIItemInfo.Destroy;
begin
  FRoot.GrabInput( nil );
  inherited Destroy;
end;

{ TUIShopWindow }

constructor TUIShopWindow.Create ( aParent : TUIElement;
  const aTitle : TUIString ) ;
var
  iShift : TUIPoint;
  iRect  : TUIRect;
begin
  iRect := aParent.GetDimRect;
  iShift.Init( (iRect.Dim.X - 80) div 2, (iRect.Dim.Y - 25) div 2 );
  inherited Create( aParent, Rectangle( Point(7, 3)+iShift, 65, 18 ), aTitle );
  TConUILabel.Create( Self, Point( -9,-5 ),'@d Press <@<Enter@>> to buy, <@<Escape@>> to exit...                          ' );
  UI.MainScreen.Msg.Update;
  EventFilter := [ VEVENT_KEYDOWN ];
  FRoot.GrabInput( Self );

  FMenu := TConUIMenu.Create( Self, Rectangle( Point(0,0), Self.GetAvailableDim.Dim ) );
  FMenu.OnConfirmEvent := @OnConfirm;
  FMenu.OnCancelEvent  := @OnCancel;
  FMenu.OnSelectEvent  := @OnSelect;
end;

procedure TUIShopWindow.Add ( aItem : TItem; aPriceType : TPriceType ) ;
begin
  if aPriceType <> COST_NONE
    then FMenu.Add( Padded( aItem.GetName(PlainName), 55 ) + IntToStr( aItem.GetPrice(aPriceType) ), True, aItem, aItem.InvColor )
    else FMenu.Add( aItem.GetName(PlainName), True, aItem, aItem.InvColor );
  if FMenu.Count = 1 then UI.UpdateStatus( aItem );
end;

procedure TUIShopWindow.Close( const aEmptyLabel : AnsiString );
begin
  FMenu.Add( StringOfChar(' ', 26 ) + 'Close' );
  if FMenu.Count = 1 then TConUILabel.Create( Self, FAbsolute.Pos + Point( 5,15 ), aEmptyLabel );
end;

function TUIShopWindow.OnConfirm ( aSender : TUIElement ) : Boolean;
begin
  UI.UpdateStatus( nil );
  if FMenu.Selected = FMenu.Count then Exit( OnCancel( aSender ) );
  UI.SetUILoopResult(FMenu.Selected);
  Free;
  Exit( True );
end;

function TUIShopWindow.OnCancel ( aSender : TUIElement ) : Boolean;
begin
  UI.UpdateStatus( nil );
  UI.SetUILoopResult(0);
  Free;
  Exit( True );
end;

function TUIShopWindow.OnSelect ( aSender : TUIElement; aIndex : DWord;
  aItem : TUIMenuItem ) : Boolean;
begin
  UI.UpdateStatus( nil );
  if (aIndex = 0) or (aIndex = FMenu.Count) then Exit( True );
  UI.UpdateStatus( TItem(aItem.Data) );
  Exit( True );
end;

{ TUIPanel }

constructor TUIPanel.Create ( aParent : TUIElement; const aTitle : AnsiString ) ;
begin
  inherited Create( aParent, aParent.GetDimRect, aTitle );
end;

function TUIPanel.Close : Boolean;
var iMain : TUIMainScreen;
begin
  iMain := TUIMainScreen(Parent.Parent);
  Free;
  iMain.UpdateMap;
  Exit( True );
end;

function TUIPanel.CloseAll : Boolean;
var iMain : TUIMainScreen;
begin
  iMain := TUIMainScreen(Parent.Parent);
  iMain.ClearBoth;
  Exit( True );
end;

{ TUICharWindow }

constructor TUICharWindow.Create ( aParent : TUIElement ) ;
begin
  inherited Create( aParent, 'Character' );
  EventFilter := [ VEVENT_KEYDOWN ];
end;

procedure TUICharWindow.OnRedraw;
var iCon : TUIConsole;

    procedure DrawStat( aLine, aColumn : Byte; aName, aValue : AnsiString );
    var iPointName  : TUIPoint;
        iPointValue : TUIPoint;
        iColWidth   : Integer;
    begin
      iColWidth := FAbsolute.w div 2;
      iPointName  := Point( (aColumn-1) * iColWidth, aLine ) + FAbsolute.Pos + Point(2,1);
      iPointValue := iPointName + Point( iColWidth - 4 - UI.CodedLength(aValue), 0 );
      iCon.Print( iPointName,  DarkGray, Black, aName, True );
      iCon.Print( iPointValue, LightGray, Black, aValue, True );
    end;

    procedure DrawUpStat( aLine : Byte; aName : AnsiString; aBase, aCurrent : Integer; aUpgrade : Char = ' '; aDrawUpgrade : Boolean = False );
    var iPointName  : TUIPoint;
        iPointValue : TUIPoint;
        iValue      : TUIString;
        iColWidth   : Integer;
    begin
      iColWidth := FAbsolute.w div 2;
      iPointName  := Point( 0, aLine ) + FAbsolute.Pos + Point(2,1);
      iValue      := IntToStr(aBase)+'@d|';
      if aDrawUpgrade
        then iValue += '@r[@y'+aUpgrade+'@r]'
        else iValue += '@'+ColorCodes[ ModColor( aCurrent - aBase ) ]+IntToStr( aCurrent );
      iPointValue := iPointName + Point( iColWidth - 4 - UI.CodedLength(iValue), 0 );
      iCon.Print( iPointName,  DarkGray, Black, aName, True );
      iCon.Print( iPointValue, LightGray, Black, iValue, True );
    end;

    function ResistStr( aResist : DWord ) : AnsiString;
    var iValue : LongInt;
    begin
      iValue := UI.Player.GetResist( aResist );
      if iValue >= 75 then Exit( 'MAX' );
      Exit( IntToStr( iValue ) );
    end;

begin
  inherited OnRedraw;
  iCon.Init( TConUIRoot(FRoot).Renderer );
  with UI.Player do
  begin
    LevelUp := False;
    DrawStat( 1, 1, 'Name', Name );            DrawStat( 1, 2, 'Class', UpCase(LuaSystem.Get(['klasses',Klass,'name'])) );
    DrawStat( 2, 1, 'Level', IntToStr(Level) );DrawStat( 2, 2, 'Exp', IntToStr(Exp) );
    if Level < 50 then                         DrawStat( 3, 2, 'NextLev', IntToStr(ExpTable[Level + 1]) )
                  else                         DrawStat( 3, 2, 'NextLev', 'MAX' );
    DrawUpStat( 5, 'Strength',  Str, getStr, 's', (Points > 0) and ( Str < getStatMax( STAT_STR ) ) );
    DrawUpStat( 6, 'Magic',     Mag, getMag, 'm', (Points > 0) and ( Mag < getStatMax( STAT_MAG ) ) );
    DrawUpStat( 7, 'Dexterity', Dex, getDex, 'd', (Points > 0) and ( Dex < getStatMax( STAT_DEX ) ) );
    DrawUpStat( 8, 'Vitality',  Vit, getVit, 'v', (Points > 0) and ( Vit < getStatMax( STAT_VIT ) ) );

    DrawUpStat( 8, 'Vitality',  Vit, getVit, 'v', (Points > 0) and ( Vit < getStatMax( STAT_VIT ) ) );
    DrawStat( 9, 1, 'Points', IntToStr(Points) );

    DrawUpStat( 11, 'Life', getLife, HP );
    DrawUpStat( 12, 'Mana', getMana, MP );

    DrawStat( 5, 2, 'Gold', IntToStr(getGold) );
    DrawStat( 6, 2, 'Armor', IntToStr(getAC) );
    DrawStat( 7, 2, 'ToHit', IntToStr(getToHitMelee)+'%' );

    DrawStat( 8, 2, 'Damage', IntToStr(getFullDmgMin)+'-'+IntToStr(getFullDmgMax) );

    DrawStat( 10, 2, 'ResMagic', ResistStr( STAT_RESMAGIC ) );
    DrawStat( 11, 2, 'ResFire', ResistStr( STAT_RESFIRE ) );
    DrawStat( 12, 2, 'ResLight', ResistStr( STAT_RESLIGHTNING ) );
  end;
end;

function TUICharWindow.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  if event.ModState <> [] then Exit( False );
  if event.Code = VKEY_ESCAPE then Exit( Close );
  if UI.Player.Points = 0 then Exit( False );
  with UI.Player do
  case event.Code of
    VKEY_S : if Str < getStatMax( STAT_STR ) then Str := Str + 1 else Exit( False );
    VKEY_M : if Mag < getStatMax( STAT_MAG ) then Mag := Mag + 1 else Exit( False );
    VKEY_D : if Dex < getStatMax( STAT_DEX ) then Dex := Dex + 1 else Exit( False );
    VKEY_V : if Vit < getStatMax( STAT_VIT ) then Vit := Vit + 1 else Exit( False );
  else Exit( False );
  end;
  UI.Player.Stats.Inc('points_used');
  UI.Player.Points := UI.Player.Points - 1;
  Exit( True );
end;


{ TUIJournalWindow }

constructor TUIJournalWindow.Create ( aParent : TUIElement ) ;
var iMenu  : TConUIMenu;
    iCount : Byte;
begin
  inherited Create( aParent, 'Journal' );
  EventFilter := [ VEVENT_KEYDOWN ];
  FRoot.GrabInput( UI.MainScreen );
  TConUILabel.Create( Self, Point( -2,-4 ),'@d Press <@<Enter@>> to view, <@<Escape@>> to exit...                          ' );
  iMenu := TConUIMenu.Create( Self, Point(1,1) );
  with UI.Player do
  for iCount := 1 to LuaSystem.Get(['quests', '__counter']) do
    if ( Quests[ iCount ] > 0 ) and ( Quests[iCount] < LuaSystem.Get(['quests',iCount,'completed']) ) then
      iMenu.Add( LuaSystem.Get(['quests', iCount, 'name']), True, Pointer(iCount) );
  iMenu.Add('Close');
  if iMenu.Count = 1 then
    TConUIText.Create( Self, Rectangle(1,3,35,3),'Currently, You are not involved in any quests.');
  iMenu.OnConfirmEvent := @OnConfirm;
end;

function TUIJournalWindow.OnConfirm ( aSender : TUIElement ) : Boolean;
begin
  if TConUIMenu( aSender ).Selected = TConUIMenu( aSender ).Count
    then TUIMainScreen(Parent.Parent).ClearLeft
    else
    begin
      FRoot.GrabInput(nil);
      LuaSystem.ProtectedCall(['quests', Byte(TConUIMenu( aSender ).SelectedItem.Data), 'OnJournal'], [] );
      FRoot.GrabInput(Self);
    end;
  Exit( True );
end;

function TUIJournalWindow.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  case UI.IOKeyCodeToCommand(event.Code) of
    COMMAND_JOURNAL,
    COMMAND_ESCAPE : Exit( Close );
    COMMAND_CWIN   : Exit( CloseAll );
  else Exit( inherited OnKeyDown( event ) );
  end;
end;

destructor TUIJournalWindow.Destroy;
begin
  FRoot.GrabInput( nil );
  inherited Destroy;
end;

{ TUITalkWindow }

constructor TUITalkWindow.Create ( aParent : TUIElement; const aIntro : AnsiString ) ;
var iSep   : TConUISeparator;
begin
  inherited Create( aParent, '' );
  EventFilter := [ VEVENT_KEYDOWN ];
  FRoot.GrabInput( Self );
  TConUILabel.Create( Self, Point( -42,-4 ),'@d Press <@<Enter@>> to choose, <@<Escape@>> to exit...                          ' );
  iSep := TConUISeparator.Create( Self,VORIENT_HORIZONTAL,3 );
  TConUILabel.Create( iSep.Top, Point(( FAbsolute.w - Length( aIntro ) ) div 2 - 2,0), aIntro );
  FMenu := TConUIMenu.Create( iSep.Bottom, Rectangle(0,1,aParent.GetDimRect.w,16) );
  FMenu.OnConfirmEvent := @OnConfirm;
  FMenu.OnCancelEvent  := @OnCancel;
  FMenu.SelectInactive := False;
  UI.SetUILoopResult( 0 );
end;

procedure TUITalkWindow.Add ( const aOption : AnsiString; aActive : Boolean ) ;
begin
  FMenu.Add( StringOfChar( ' ', ( FAbsolute.w - Length( aOption ) ) div 2 - 2 ) + aOption, aActive );
end;

function TUITalkWindow.OnConfirm ( aSender : TUIElement ) : Boolean;
begin
  UI.SetUILoopResult( FMenu.Selected );
  Exit( Close );
end;

function TUITalkWindow.OnCancel ( aSender : TUIElement ) : Boolean;
begin
  UI.SetUILoopResult( 0 );
  Exit( Close );
end;

function TUITalkWindow.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
begin
  case UI.IOKeyCodeToCommand(event.Code) of
    COMMAND_ESCAPE : Exit( Close );
    COMMAND_CWIN   : Exit( CloseAll );
  else Exit( inherited OnKeyDown( event ) );
  end;
end;

destructor TUITalkWindow.Destroy;
begin
  FRoot.GrabInput( nil );
  inherited Destroy;
end;

{ TUIInventoryWindow }

constructor TUIInventoryWindow.Create ( aParent : TUIElement ) ;
var iSep   : TConUISeparator;
    iSlots : AnsiString;
    iIndex : DWord;
begin
  inherited Create( aParent, 'Inventory' );
  TConUILabel.Create( Self, Point(-1,-1)-aParent.Pos,'@d Inventory: @>[@lTAB@>] switch, [@lENTER@>] equip/use, [@ld@>] drop, [@<q@>] quickslot, [@lESC@>] exit.' );
  EventFilter := [ VEVENT_KEYDOWN ];
  FRoot.GrabInput( UI.MainScreen );
  Padding := Point(-1,-1);
  iSep := TConUISeparator.Create( Self,VORIENT_HORIZONTAL,8 );
  iSlots := '';
  for iIndex := 1 to ITEMS_EQ do
    iSlots += '@d' + UI.Player.SlotName(iIndex) + ' :@>'#10;
  TConUIText.Create( iSep.Top, iSlots );

  FEqMenu  := TConUIMenu.Create( iSep.Top, Rectangle( 7, 0, 8, FAbsolute.w - 6 ) );
  FInvMenu := TConUIMenu.Create( iSep.Bottom, iSep.Bottom.GetDimRect );
  FEqMenu.SelectInactive := False;
  FEqMenu.SetSelected(0);
  FEqMenu.EventFilter := [];

  FEqMenu.OnSelectEvent := @OnSelect;
  FInvMenu.OnSelectEvent := @OnSelect;
  FEqMenu.OnConfirmEvent := @OnEqConfirm;
  FInvMenu.OnConfirmEvent := @OnInvConfirm;
  FMode := UIInvMode;
  FVolume := nil;
  FCurrent := 1;

  UpdateMenus;
end;

procedure TUIInventoryWindow.UpdateMenus;
var iInvList : TItemList;
    iEqList  : TItemList;
    iItem    : TItem;
    iIndex   : Word;
    iVolume  : TUIString;
begin
  FInvMenu.Clear;
  FEqMenu.Clear;
  iInvList := UI.Player.GetInvList;
  iEqList  := UI.Player.GetEqList;

  for iItem in iInvList do
    FInvMenu.Add( Padded(iItem.GetName(PlainName),FAbsolute.w-5)+' '+IntToStr(iItem.Volume), True, iItem, iItem.InvColor );

  FEqEmpty := True;
  for iIndex := 1 to ITEMS_EQ do
    if iEqList[ iIndex ] = nil
      then FEqMenu.Add( '---', False, nil, DarkGray )
      else begin
        FEqMenu.Add( iEqList[ iIndex ].GetName(PlainName), True, iEqList[ iIndex ], iEqList[ iIndex ].InvColor );
        FEqEmpty := False;
      end;

  FreeAndNil( iInvList );
  FreeAndNil( iEqList );

  FreeAndNil( FVolume );
  iVolume := Format('@d[@<%d@>/%d]',[UI.Player.InvVolume, MaxVolume]);
  FVolume := TConUILabel.Create( Self, Point( FAbsolute.Dim.X - UI.CodedLength(iVolume) - 10, FAbsolute.Dim.Y-2 ), iVolume );

  if FMode = UIInvMode
    then begin FInvMenu.SetSelected(FCurrent); FEqMenu.SetSelected(0); end
    else begin FInvMenu.SetSelected(0); FEqMenu.SetSelected(FCurrent); end;

  if ( ( FMode = UIEqMode ) and FEqEmpty ) or
     ( ( FMode = UIInvMode ) and ( FInvMenu.Count = 0 ) and ( not FEqEmpty ) ) then
     SwitchMode;
end;

function TUIInventoryWindow.OnInvConfirm ( aSender : TUIElement ) : Boolean;
var iItem : TItem;
begin
  iItem := nil;
  if FInvMenu.SelectedItem.Data <> nil then iItem := TItem( FInvMenu.SelectedItem.Data );
  UI.MainScreen.Msg.Update;
  Close;
  if iItem <> nil then UI.Player.ActionWear( iItem );
  UI.BreakKeyLoop;
  Exit( True );
end;

function TUIInventoryWindow.OnEqConfirm ( aSender : TUIElement ) : Boolean;
begin
  if FEqMenu.SelectedItem.Data <> nil then
  begin
    UI.MainScreen.Msg.Update;
    UI.Player.ActionWear(nil, FEqMenu.Selected);
    UpdateMenus;
  end;
  Exit( True );
end;

function TUIInventoryWindow.OnSelect ( aSender : TUIElement; aIndex : DWord;
  aItem : TUIMenuItem ) : Boolean;
begin
  if (aItem <> nil) and (aItem.Data <> nil) then
  begin
    UI.UpdateStatus( TItem( aItem.Data ) );
    if FCurrent <> aIndex then UI.PlaySound('sfx/items/invgrab.wav');
    FCurrent := aIndex;
  end;
  Exit( True );
end;

function TUIInventoryWindow.OnKeyDown ( const event : TIOKeyEvent ) : Boolean;
var iItem : TItem;
begin
  case UI.IOKeyCodeToCommand(event.Code) of
    COMMAND_INVENTORY,
    COMMAND_ESCAPE     : Exit( Close );
    COMMAND_CWIN       : Exit( CloseAll );
    COMMAND_SWITCHMODE : SwitchMode;
    COMMAND_DROP       :
      begin
        iItem := CurrentItem;
        UI.Player.ActionDrop( iItem );
        UpdateMenus;
        Exit( True );
      end;
    COMMAND_QUICKSLOT :
      begin
        iItem := CurrentItem;
        UI.Player.ActionQuickslotItem( iItem );
        UpdateMenus;
        Exit( True );
      end;
  else Exit( inherited OnKeyDown( event ) );
  end;
  Exit( True );
end;

procedure TUIInventoryWindow.SwitchMode;
begin
  if FMode = UIInvMode then
  begin
    if FEqEmpty then Exit;
    FEqMenu.SetSelected(1);
    FEqMenu.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEMOVE, VEVENT_MOUSEDOWN ];
    FInvMenu.SetSelected(0);
    FInvMenu.EventFilter := [];
    FMode := UIEqMode;
  end
  else
  begin
    if FInvMenu.Count = 0 then Exit;
    FInvMenu.SetSelected(1);
    FInvMenu.EventFilter := [ VEVENT_KEYDOWN, VEVENT_MOUSEMOVE, VEVENT_MOUSEDOWN ];
    FEqMenu.SetSelected(0);
    FEqMenu.EventFilter := [];
    FMode := UIInvMode;
  end;
end;

function TUIInventoryWindow.CurrentItem : TItem;
begin
  CurrentItem := nil;
  if (FMode = UIInvMode) and ( FInvMenu.Count > 0 ) and ( FInvMenu.Selected > 0 ) then
    Exit( TItem( FInvMenu.SelectedItem.Data ) );
  if (FMode = UIEqMode) and ( not FEqEmpty ) and ( FEqMenu.Selected > 0 ) then
    Exit( TItem( FEqMenu.SelectedItem.Data ) );
end;

destructor TUIInventoryWindow.Destroy;
begin
  UI.UpdateStatus( nil );
  FRoot.GrabInput( nil );
  inherited Destroy;
end;

{ TUISpellWindow }

constructor TUISpellWindow.Create( aParent : TUIElement );
var iMenu  : TConUIMenu;
    iCount : Byte;
    iBonus : Integer;

    Name: ansistring;
    Page: byte;
    Slvl: byte;
    Cost: DWord;
    DMin: DWord;
    DMax: DWord;

begin
  inherited Create( aParent, 'Spells' );
  EventFilter := [ VEVENT_KEYDOWN ];
  FRoot.GrabInput( UI.MainScreen );

  TConUILabel.Create( Self, Point(-1,-1)-aParent.Pos,'@d Press <@<Enter@>> to view, <@<Escape@>> to exit...                          ' );
  iMenu := TConUIMenu.Create( Self, Point(1,1) );
  iBonus := UI.Player.getItemSumBonus( STAT_SPELLLEVEL );

  for iCount := 1 to MaxSpells do
    if LuaSystem.Defined(['spells', iCount]) then
      with LuaSystem.GetTable(['spells', iCount]) do
        try
          Slvl := UI.Player.Spells[iCount];
          Page := getInteger('page');
          if Page <> 0 then // ignore unlisted
          begin
            if slvl <> 0 then
            begin
              Name := getString('name');
//              Effect := getInteger('effect');
//              SType := getInteger('type');
              Cost := max(Integer(LuaSystem.ProtectedCall(['spells', iCount, 'cost'], [20, UI.Player])),
                (LuaSystem.ProtectedCall(['spells', iCount, 'cost'], [slvl, UI.Player]) * UI.Player.SpellCost) div 100);

              if isFunction('dmin')
                then DMin := ProtectedCall('dmin',[slvl, UI.Player])
                else DMin := GetInteger('dmin');
              if isFunction('dmax')
                then DMax := ProtectedCall('dmax',[slvl, UI.Player])
                else DMax := GetInteger('dmax');

              if (dmax > 0) then
                iMenu.Add(VFormat('@1 (L:@<@2@>) @<@3-@4@> Cost: @<@5',
                  [Padded(Name, 13), slvl + iBonus, dmin, dmax, cost]), True, Pointer(iCount))
              else
                iMenu.Add(VFormat('@1 (L:@<@2@>) Cost: @<@3',
                  [Padded(Name, 13), slvl + iBonus, cost]), True, Pointer(iCount));
            end;
          end;
        finally
          Free;
        end;

  iMenu.Add('Close');
  iMenu.OnConfirmEvent := @OnConfirm;
end;

function TUISpellWindow.OnConfirm( aSender : TUIElement ) : Boolean;
begin
  if TConUIMenu( aSender ).Selected <> TConUIMenu( aSender ).Count then
      UI.Player.Spell.Init(UI.Player, Byte(TConUIMenu( aSender ).SelectedItem.Data));
  TUIMainScreen(Parent.Parent).ClearRight;
  Exit( True );
end;

function TUISpellWindow.OnKeyDown( const event : TIOKeyEvent ) : Boolean;
begin
  case UI.IOKeyCodeToCommand(event.Code) of
    COMMAND_SPELLBOOK,
    COMMAND_ESCAPE : Exit( Close );
    COMMAND_CWIN   : Exit( CloseAll );
  else Exit( inherited OnKeyDown( event ) );
  end;
  Exit(True);
end;

destructor TUISpellWindow.Destroy;
begin
  FRoot.GrabInput( nil );
  inherited Destroy;
end;

{ TUISkillWindow }

constructor TUISkillWindow.Create( aParent : TUIElement );
var iMenu  : TConUIMenu;
    iCount : Byte;
    iSpells: Byte;
    iBonus : Integer;
    iItem  : TItem;

  function getQuick(ID: byte): string;
  var
    i: byte;
  begin
    for i := 1 to MaxQuickSkills do
      if UI.Player.QuickSkills[i] = ID then
        exit('('+inttostr(i){+Input.CommandToString(COMMAND_QUICKSKILL1+i-1)} + ')');
    exit('');
  end;

begin
  inherited Create( aParent, Rectangle(aParent.getDimRect.w - 30, aParent.getDimRect().h div 2, 26, 5 ), '' );
  EventFilter := [ VEVENT_KEYDOWN ];
  FRoot.GrabInput( Self );

  TConUILabel.Create( Self, Point( -48,-15 ),'@d Press <@<Enter@>> to select, <@<Escape@>> to exit...                          ' );
  iMenu := TConUIMenu.Create( Self, Rectangle( Point(0, 0), GetAvailableDim().Dim ));
  // Skill
  if UI.Player.Skill > 0 then
    iMenu.Add(Padded('@@ ' + LuaSystem.Get(['spells', UI.Player.Skill, 'name']), 20) +
      getQuick(UI.Player.Skill), True, Pointer(UI.Player.Skill + ord(CAST_SKILL) shl 8));

  iBonus := UI.Player.getItemSumBonus( STAT_SPELLLEVEL );
  // Spells
  for iCount := 1 to MaxSpells do
    if UI.Player.Spells[iCount] <> 0 then
      if LuaSystem.Defined(['spells', iCount]) then
        iMenu.Add(Padded('@@ ' + LuaSystem.Get(['spells', iCount, 'name']) +
                         ' lvl ' + IntToStr((UI.Player.Spells[iCount] + iBonus)), 20) +
                         getQuick(iCount), True, Pointer(iCount + ord(CAST_SPELL) shl 8));
  // Scrolls
  for iCount := 1 to MaxSpells do
    if UI.Player.FindScroll(iCount) <> nil then
      if LuaSystem.Defined(['spells', iCount]) then
        iMenu.Add(Padded('? ' + LuaSystem.Get(['spells', iCount, 'name']), 20) +
                         getQuick(iCount), True, Pointer(iCount + ord(CAST_SCROLL) shl 8));
  // Staff
  iItem := UI.Player.Equipment[SlotRHand];
  if (iItem <> nil) then
    if (iItem.Spell <> 0) then
    begin
      iCount := 20 + length(iItem.getSpellName) -
        length(UI.Strip(iItem.getSpellName));
      if (iItem.Charges > 0) then
        iMenu.Add(Padded('/ ' + iItem.getSpellName, iCount) + getQuick(254), True, Pointer(iItem.Spell + ord(CAST_STAFF) shl 8))
      else
        iMenu.Add(Padded('/ ' + iItem.getSpellName, iCount) + getQuick(254), False, Pointer(iItem.Spell + ord(CAST_STAFF) shl 8));
    end;

  iMenu.Add('Close');
  SetDim(Point(Dim.x, min( 4 + iMenu.GetCount(), aParent.getDimRect().h div 2 - 4)));
  iMenu.SetDim(GetAvailableDim().Dim);
  iMenu.OnConfirmEvent := @OnConfirm;
end;

function TUISkillWindow.OnConfirm( aSender : TUIElement ) : Boolean;
var Source : TSpellSource;
    Spell  : Byte;
begin
  if TConUIMenu( aSender ).Selected <> TConUIMenu( aSender ).Count then
  begin
    Source := TSpellSource( (Integer(TConUIMenu( aSender ).SelectedItem.Data) shr 8) and $ff );
    Spell  := Byte(Integer(TConUIMenu( aSender ).SelectedItem.Data) and $ff);
    case source of
      CAST_SPELL  : UI.Player.Spell.Init(UI.Player, Spell);
      CAST_SKILL  : UI.Player.Spell.Init(UI.Player, Spell, true);
      CAST_STAFF  : UI.Player.Spell.Init(UI.Player.Equipment[SlotRHand]);
      CAST_SCROLL : UI.Player.Spell.Init(UI.Player.FindScroll(Spell));
    end;
  end;
  Free;
  Exit( True );
end;

function TUISkillWindow.OnKeyDown( const event : TIOKeyEvent ) : Boolean;
begin
  case UI.IOKeyCodeToCommand(event.Code) of
    COMMAND_QUICKSKILL,
    COMMAND_ESCAPE : begin Free; Exit( True ); end;
  else Exit( inherited OnKeyDown( event ) );
  end;
end;

destructor TUISkillWindow.Destroy;
begin
  FRoot.GrabInput( nil );
  inherited Destroy;
end;


{ TUITravelWindow }

constructor TUITravelWindow.Create ( aParent : TUIElement ) ;
var iPoints : TTravelPoints;
    iMenu   : TConUIMenu;
    iCount  : DWord;
    iSize   : TUIPoint;
begin
  iPoints := Game.Level.TravelPoints;
  iSize.Y := iPoints.Size;
  iSize.X := 12;
  if iPoints.Size > 0 then
  for iCount := 0 to iPoints.Size - 1 do
    iSize.X := Max( iSize.X, Length( iPoints[ iCount ].What ) );

  inherited Create( aParent, Rectangle(46, 13, 4+iSize.X, 5+iSize.Y), 'Fast travel' );
  EventFilter := [ VEVENT_KEYDOWN ];
  FRoot.GrabInput( Self );

  TConUILabel.Create( Self, Point( -48,-15 ),'@d Press <@<Enter@>> to select, <@<Escape@>> to exit...                          ' );
  iMenu := TConUIMenu.Create( Self, Point(1,1) );
  iMenu.OnConfirmEvent := @OnConfirm;
  iMenu.OnCancelEvent  := @OnCancel;

  if iPoints.Size > 0 then
    for iCount := 0 to iPoints.Size - 1 do
      iMenu.Add( iPoints[ iCount ].What );

  iMenu.Add('Cancel');
end;

function TUITravelWindow.OnConfirm ( aSender : TUIElement ) : Boolean;
begin
  with TConUIMenu( aSender ) do
  if Selected <> Count then
    UI.SetUILoopResult( Selected );
  Free;
  Exit( True );
end;

function TUITravelWindow.OnCancel ( aSender : TUIElement ) : Boolean;
begin
  Free;
  Exit( True );
end;

destructor TUITravelWindow.Destroy;
begin
  FRoot.GrabInput( nil );
  inherited Destroy;
end;


{ TUIQsWindow }

constructor TUIQsWindow.Create( aParent : TUIElement );
var iCount : Byte;
begin
  inherited Create( aParent, Rectangle(2, 3, 38, 13), '' );
  EventFilter := [ VEVENT_KEYDOWN ];
  FRoot.GrabInput( Self );

  TConUILabel.Create( Self, Point( -4,-5 ),'@d Press <@<Enter@d> to use, <@<d@d> to drop, <@<i@d> to store, <@<Escape@d> to exit...' );
  FMenu := TConUIMenu.Create( Self, Point(1,1) );

  for iCount := 1 to ITEMS_QS do
    if UI.Player.GetQsItem(iCount) <> nil then
      FMenu.Add({Config.CommandToString(COMMAND_QUICKSLOT1+iCount-1)+}
      ' '+UI.Player.GetQsItem(iCount).GetName(PlainName), true, Pointer(iCount))
    else
      FMenu.Add({Input.CommandToString(COMMAND_QUICKSLOT1+iCount-1)+}
      ' (empty)', false, nil);

  FMenu.Add('Close',true, nil);
  FMenu.OnConfirmEvent := @OnConfirm;
end;

function TUIQsWindow.OnConfirm( aSender : TUIElement ) : Boolean;
begin
  if FMenu.Selected <> TConUIMenu( aSender ).Count then
      UI.Player.UseQuickSlot( Byte(FMenu.SelectedItem.Data) );
  Free;
  Exit( True );
end;

function TUIQsWindow.OnKeyDown( const event : TIOKeyEvent ) : Boolean;
begin
  case UI.IOKeyCodeToCommand(event.Code) of
    COMMAND_DROP   :
      if UI.Player.ActionDrop( UI.Player.Quickslot[ Byte(FMenu.SelectedItem.Data) ] ) then
      begin
        Free;
        Exit( True );
      end;
    COMMAND_INVENTORY   :
      if UI.Player.ActionAddToBackPack( UI.Player.Quickslot[ Byte(FMenu.SelectedItem.Data) ] ) then
      begin
        Free;
        Exit( True );
      end;
    COMMAND_QUICKSLOT,
    COMMAND_ESCAPE : begin Free; Exit( True ); end;
  else Exit( inherited OnKeyDown( event ) );
  end;
end;

destructor TUIQsWindow.Destroy;
begin
  FRoot.GrabInput( nil );
  inherited Destroy;
end;


end.

