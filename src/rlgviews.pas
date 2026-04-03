{$include rl.inc}
// @abstract(Game views for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)

unit rlgviews;
interface

uses Classes, SysUtils,
     vuielement, viotypes, vuitypes, vioevent, vconui, vconuirl, vuielements,
     vtig, vtigio, vtigstyle,
     rlglobal, rlthing, rlitem, vrltools;

type


TStatus = class;

{ TUIMainScreen }

TUIMainScreen = class( TUIElement )
  constructor Create( aParent : TUIElement );
  function OnKeyDown( const event : TIOKeyEvent ) : Boolean; override;
  procedure UpdateMap;
  procedure OnRedraw; override;
  procedure ClearLeft;
  procedure ClearRight;
  procedure ClearBoth;
private
  FLeft    : TUIElement;
  FRight   : TUIElement;
  FMap     : TConUIMapArea;
  FStatus  : TStatus;
  FMsg     : TConUIMessages;
public
  property Left   : TUIElement     read FLeft;
  property Right  : TUIElement     read FRight;
  property Msg    : TConUIMessages read FMsg;
  property Map    : TConUIMapArea  read FMap;
  property Status : TStatus      read FStatus;
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

type TFinishableLayer = class( TIOLayer )
  procedure Finish;
  function IsFinished : Boolean; override;
protected
  FFinished : Boolean;
end;

type TStatusLine = object
  Text  : String;
  Color : TIOColor;
  procedure Init( aText : String; aColor : TIOColor = LightGray );
end;

{ TStatus }

type TStatus = class
  constructor Create;
  procedure Reset;
  procedure Update( c : TCoord2D );
  procedure Update( aThing : TThing );
  procedure Draw;
private
  FLine1 : TStatusLine;
  FLine2 : TStatusLine;
  FLine3 : TStatusLine;
end;

{ TPlotWindow }

type TPlotWindow = class( TFinishableLayer )
  constructor Create( const aText : AnsiString );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
protected
  FText      : AnsiString;
  FStartTime : DWord;
  FShift     : TIOPoint;
end;

{ TItemInfo }

type TItemInfo = class( TFinishableLayer )
  constructor Create( const aItem : TItem );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
protected
  FLine1    : AnsiString;
  FLine2    : AnsiString;
  FLine3    : AnsiString;
  FShift    : TIOPoint;
end;

{ TShopWindow }

type TShopItem = record
  Name      : AnsiString;
  Color     : TIOColor;
  Data      : TItem;
end;
type TShopItemArray = array of TShopItem;

type TShopWindow = class( TFinishableLayer )
  constructor Create( const aTitle : AnsiString );
  procedure Add( aItem : TItem; aPriceType : TPriceType = COST_NONE );
  procedure Close( const aEmptyLabel : AnsiString );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
  destructor Destroy; override;
protected
  FTitle      : AnsiString;
  FEmptyLabel : AnsiString;
  FItems      : TShopItemArray;
  FItemCount  : Integer;
  FClosed     : Boolean;
  FShift      : TIOPoint;
  class var FResult : Integer;
public
  class property Result : Integer read FResult;
end;

{ TSkillWindow }

type TSkillEntry = record
  Name : AnsiString;
  Data : DWord;
  Valid: Boolean;
end;
type TSkillEntryArray = array of TSkillEntry;

type TSkillWindow = class( TFinishableLayer )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
  destructor Destroy; override;
protected
  FEntries  : TSkillEntryArray;
  FCount    : Integer;
  class var FResult : DWord;
public
  class property Result : DWord read FResult;
end;

{ TQsWindow }

type TQsWindow = class( TFinishableLayer )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
  function HandleEvent( const aEvent : TIOEvent ) : Boolean; override;
protected
  FKeyAction : Byte;
end;

{ TTravelWindow }

type TTravelWindow = class( TFinishableLayer )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
protected
  class var FResult : Integer;
public
  class property Result : Integer read FResult;
end;

implementation

uses math, vutil, vuiconsole, vluasystem,
     rlgame, rlconfig, rllevel, rlui, rlnpc, rlplayer;

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
  FStatus := TStatus.Create;
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
    COMMAND_QUICKSKILL : begin UI.RunLayer( TSkillWindow.Create ); Exit( True ); end;
    COMMAND_QUICKSLOT  : if not (FRight.Child is TUIInventoryWindow) then begin UI.RunLayer( TQsWindow.Create ); Exit( True ); end else Exit( False );
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

procedure TUIMainScreen.OnRedraw; 
begin
  VTIG_Clear;
  inherited OnRedraw;
  FStatus.Draw;
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
    
    DrawStat( 1, 1, 'Name', Name );           DrawStat( 1, 2, 'Class', UpCase(AnsiString(LuaSystem.Get(['klasses',Klass,'name']))) );
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
                iMenu.Add(Format('%s (L:@<%d@>) @<%d-%d@> Cost: @<%d',
                  [Padded(Name, 13), slvl + iBonus, dmin, dmax, cost]), True, Pointer(iCount))
              else
                iMenu.Add(Format('%s (L:@<%d@>) Cost: @<%d',
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

{ ====================================================================== }
{ VTIG immediate mode UI implementations                                 }
{ ====================================================================== }

{ TFinishableLayer }

procedure TFinishableLayer.Finish;
begin
  FFinished := True;
end;

function TFinishableLayer.IsFinished : Boolean;
begin
  Exit( FFinished );
end;

{ TStatusLine }

procedure TStatusLine.Init( aText : String; aColor : TIOColor );
begin
  Text := aText;
  Color := aColor;
end;

{ TStatus }

constructor TStatus.Create;
begin
  Reset;
end;

procedure TStatus.Reset;
begin
  FLine1.Init('');
  FLine2.Init('');
  FLine3.Init('');
end;

procedure TStatus.Update( c : TCoord2D );
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
          FLine2.Init(CellData[Cell[c]].Name);
          if CellHook_OnTravelName in CellData[Cell[c]].hooks then
            FLine2.Init(LuaSystem.ProtectedCall([ 'cells',CellData[Cell[c]].id,CellHookNames[ CellHook_OnTravelName ] ], [Game.Level] ));
        end;
  end;
end;

procedure TStatus.Update( aThing : TThing );
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
      FLine1.Init('{R ' + StringOfChar( '#', iCount ) + '}{d ' + StringOfChar( '.', 10-iCount ) + '}');
      FLine2.Init( Name );
      iCount := Game.Player.Kills.Get( ID );
      if iCount > 0 then FLine3.Init('Total kills : ' + IntToStr( iCount ));
      if iCount > 15 then FLine3.Text += '   ('+GetResistancesString+')' ;
      if iCount > 30 then
        FLine3.Text += '   HP: ' +
          IntToStr(LuaSystem.Get(['npcs', id, 'hpmin'])) + '-' +
          IntToStr(LuaSystem.Get(['npcs', id, 'hpmax']));
    end
    else
      FLine2.Init( Name );
  end;

  if aThing is TItem then
  with aThing as TItem do
  begin
    iStatus := GetStatusInfo1;
    if iStatus = ''
      then FLine2.Init( GetName(PlainName), InvColor )
      else
      begin
        FLine1.Init( '[' + GetName(PlainName) + ']', InvColor );
        FLine2.Init( iStatus, InvColor );
      end;
    FLine3.Init( GetStatusInfo2, InvColor );
  end;
end;

procedure TStatus.Draw;
var iScreenSize : TIOPoint;
    iOrbStr     : AnsiString;

  procedure DurMark( aItem : TItem; p : TPoint; aVis : Char );
  var iColor : TUIColor;
  begin
    if aItem = nil then Exit;
    with aItem do
    begin
      if Dur >= (DurMax div 4) then Exit;
      if Dur <= Max(DurMax div 6, 1)
        then iColor := LightRed
        else iColor := Brown;
      VTIG_FreeChar( aVis, p, iColor );
    end;
  end;

  function FillChar( aEmpty : Byte; aValue : Byte ) : Char;
  begin
    if aValue <= aEmpty    then Exit('.');
    if aValue <= aEmpty+9  then Exit('-');
    if aValue <= aEmpty+17 then Exit('=');
    Exit('#');
  end;

  procedure DrawOrb( aValue, aMax : Integer; aColor : TIOColor; aX : Integer );
  var iPercent  : Integer;
      iY        : Integer;
  begin
    if (aMax <= 0) or (aValue <= 0)
      then iPercent := 0
      else iPercent := Min( (aValue * 100) div aMax, 100 );
    iY := iScreenSize.Y - 4;
    VTIG_FreeLabel( StringOfChar( FillChar( 80, iPercent ), 4 ), Point( aX+1, iY ), aColor );
    VTIG_FreeLabel( StringOfChar( FillChar( 55, iPercent ), 6 ), Point( aX, iY+1 ), aColor );
    VTIG_FreeLabel( StringOfChar( FillChar( 30, iPercent ), 6 ), Point( aX, iY+2 ), aColor );
    VTIG_FreeLabel( StringOfChar( FillChar( 5,  iPercent ), 4 ), Point( aX+1, iY+3 ), aColor );
  end;

  procedure CenterPrint( const aLine : AnsiString; aY : Integer; aColor : TIOColor );
  begin
    if aLine = '' then Exit;
    VTIG_FreeLabel( aLine, Point( (iScreenSize.X - VTIG_Length( aLine )) div 2, aY ), aColor );
  end;

var iCount    : DWord;
    iOrbColor : TIOColor;
begin
  iScreenSize := VTIG_GetIOState.Size;
  if UI.Player = nil then Exit;
  VTIG_FreeLabel( StringOfChar( '-', iScreenSize.X - 2 ), Point( 0, iScreenSize.Y - 3 ), DarkGray );
  with UI.Player do
  begin
    DrawOrb( HP, getLife, Red, 3 );
    if Flags[ nfManaShield ] then
      iOrbColor := LightBlue
    else
      iOrbColor := Blue;
    DrawOrb(MP, getMana, iOrbColor, iScreenSize.X-9);

    iOrbStr := TLevel(UI.Player.Parent).Name;
    VTIG_FreeLabel( ' ' + iOrbStr + ' ', Point( iScreenSize.X - 13 - Length(iOrbStr), iScreenSize.Y - 3 ), LightGray );

    if LevelUp then
    begin
      VTIG_FreeLabel( '[{y +}{R ]', Point( 4, iScreenSize.Y - 6 ), Red );
      VTIG_FreeLabel( 'Level Up!', Point( 2, iScreenSize.Y - 5 ), White );
    end;

    DurMark( Equipment[slotHead],  Point( UI.SizeX-2,UI.SizeY-11 ), #127 );
    DurMark( Equipment[slotTorso], Point( UI.SizeX-2,UI.SizeY-10 ), #219 );
    DurMark( Equipment[slotRHand], Point( UI.SizeX-3,UI.SizeY-11 ), #179 );
    DurMark( Equipment[slotLHand], Point( UI.SizeX-3,UI.SizeY-10 ), #197 );

    VTIG_FreeLabel( ' [' + StringOfChar('.', ITEMS_QS) + '] ', Point( 10, iScreenSize.Y - 3 ), DarkGray );
    for iCount := 1 to ITEMS_QS do
      if QuickSlot[iCount] <> nil then
        VTIG_FreeChar( QuickSlot[iCount].Picture, Point( 11 + iCount, iScreenSize.Y - 3 ), QuickSlot[iCount].Color );

    if Spell.Spell > 0 then
    case Spell.Source of
      CAST_STAFF : VTIG_FreeLabel( UI.Strip(Equipment[SlotRHand].getSpellName), Point(11, iScreenSize.Y-2), DarkGray );
      CAST_SCROLL: VTIG_FreeLabel( Spell.Name, Point(11, iScreenSize.Y-2), DarkGray );
      else
        VTIG_FreeLabel( Spell.Name, Point(11, iScreenSize.Y-2), DarkGray );
    end;

    CenterPrint( FLine1.Text, iScreenSize.Y - 3, FLine1.Color );
    CenterPrint( FLine2.Text, iScreenSize.Y - 2, FLine2.Color );
    CenterPrint( FLine3.Text, iScreenSize.Y - 1, FLine3.Color );
  end;
end;

{ TPlotWindow }

constructor TPlotWindow.Create( const aText : AnsiString );
var iSize : TIOPoint;
begin
  VTIG_EventClear;
  VTIG_ResetScroll( 'plot_scroll', 0 );
  FFinished  := False;
  FText      := aText;
  FStartTime := 0;
  iSize := VTIG_GetIOState.Size;
  FShift.Init( (iSize.X - 80) div 2, (iSize.Y - 25) div 2 );
end;

procedure TPlotWindow.Update( aDTime : Integer; aActive : Boolean );
var iSize    : TIOPoint;
    iScroll  : Integer;
    iPadding : Integer;
    i        : Integer;
begin
  FStartTime += aDTime;
  iSize := Point( 65, 18 );
  iPadding := iSize.Y - 4;
  iScroll := Min( FStartTime div 1100, iPadding );
  VTIG_PushStyle( @TIGFramedWindowStyle );
  VTIG_Begin( 'plot_scroll', iSize, Point(8, 4) + FShift );
  for i := 1 to iPadding do
    VTIG_Text( '' );
  VTIG_Text( FText, Point( iSize.X - 4, 0 ), Yellow );
  for i := 1 to iPadding do
    VTIG_Text( '' );
  VTIG_ResetScroll( 'plot_scroll', iScroll );
  VTIG_End;
  VTIG_PopStyle;
  VTIG_FreeLabel( ' Press <{!Enter}>, <{!Space}> or <{!Escape}> to skip...                 ', Point( 0, 0 ), DarkGray );
  if VTIG_EventConfirm or VTIG_EventCancel or VTIG_Event( VTIG_IE_SELECT ) then
  begin
    if iScroll < iPadding then
      FStartTime := iPadding * 1100
    else
      FFinished := True;
  end;
end;

function TPlotWindow.IsModal : Boolean;
begin
  Exit( True );
end;

{ TItemInfo }

constructor TItemInfo.Create( const aItem : TItem );
var iStatus : String;
    iSize   : TIOPoint;
begin
  VTIG_EventClear;
  FFinished := False;
  with aItem do
  begin
    iStatus := GetStatusInfo1;
    if iStatus = ''
      then FLine2 := '{'+ColorCodes[Color]+' ' + GetName(PlainName) + '}'
      else
      begin
        FLine1 := '{'+ColorCodes[Color]+' ' + GetName(PlainName) + '}';
        FLine2 := '{'+ColorCodes[Color]+' ' + iStatus + '}';
      end;
    FLine3 := '{'+ColorCodes[Color]+' ' + GetStatusInfo2 + '}';
  end;
  iSize := VTIG_GetIOState.Size;
  FShift.Init( (iSize.X - 80) div 2, (iSize.Y - 10) div 2 );
end;

procedure TItemInfo.Update( aDTime : Integer; aActive : Boolean );
var iSize : TIOPoint;
begin
  iSize := Point( 66, 7 );
  VTIG_PushStyle( @TIGFramedWindowStyle );
  VTIG_Begin( 'item_info', iSize, Point(8, 4) + FShift );

  if FLine1 <> '' then
    VTIG_Text( FLine1 );
  VTIG_Text( FLine2 );
  if FLine3 <> '' then
    VTIG_Text( FLine3 );

  VTIG_End;
  VTIG_PopStyle;
  VTIG_FreeLabel( ' Press <{!Enter}>, <{!Space}> or <{!Escape}> to continue...                 ', Point( 0, 0 ), DarkGray );
  if VTIG_EventConfirm or VTIG_EventCancel or VTIG_Event( VTIG_IE_SELECT ) then
    FFinished := True;
end;

function TItemInfo.IsModal : Boolean;
begin
  Exit( True );
end;

{ TShopWindow }

constructor TShopWindow.Create( const aTitle : AnsiString );
var iSize : TIOPoint;
begin
  VTIG_EventClear;
  FFinished   := False;
  FTitle      := aTitle;
  FEmptyLabel := '';
  FItems      := nil;
  FItemCount  := 0;
  FClosed     := False;
  FResult     := -1;
  iSize := VTIG_GetIOState.Size;
  FShift.Init( (iSize.X - 80) div 2, (iSize.Y - 25) div 2 );
end;

procedure TShopWindow.Add( aItem : TItem; aPriceType : TPriceType );
begin
  if FItemCount >= Length(FItems) then
    SetLength( FItems, FItemCount + 16 );
  FItems[FItemCount].Data  := aItem;
  FItems[FItemCount].Color := aItem.InvColor;
  if aPriceType <> COST_NONE
    then FItems[FItemCount].Name := Padded( aItem.GetName(PlainName), 55 ) + IntToStr( aItem.GetPrice(aPriceType) )
    else FItems[FItemCount].Name := aItem.GetName(PlainName);
  Inc( FItemCount );
end;

procedure TShopWindow.Close( const aEmptyLabel : AnsiString );
begin
  FEmptyLabel := aEmptyLabel;
  FClosed := True;
end;

procedure TShopWindow.Update( aDTime : Integer; aActive : Boolean );
var iSize  : TIOPoint;
    i      : Integer;
    iSel   : Integer;
begin
  iSize := Point( 66, 18 );
  VTIG_PushStyle( @TIGNarrowFramedWindowStyle );
  VTIG_BeginWindow( FTitle, 'shop', iSize, Point(8, 4) + FShift );

  if FItemCount > 0 then
    for i := 0 to FItemCount - 1 do
      VTIG_Selectable( FItems[i].Name, True, FItems[i].Color );

  VTIG_Selectable( StringOfChar(' ', 26) + 'Close' );

  if (FItemCount = 0) and (FEmptyLabel <> '') then
    VTIG_Text( FEmptyLabel );

  VTIG_Scrollbar;

  iSel := VTIG_Selected('shop');
  if iSel < FItemCount then
    UI.UpdateStatus( FItems[iSel].Data )
  else
    UI.UpdateStatus( nil );

  VTIG_End;
  VTIG_PopStyle;
  VTIG_FreeLabel( ' Press <{!Enter}> to buy, <{!Escape}> to exit...          ', Point( 0, 0 ), DarkGray );

  if VTIG_EventConfirm then
  begin
    UI.UpdateStatus( nil );
    if iSel < FItemCount then
      FResult := iSel
    else
      FResult := -1;
    FFinished := True;
  end;

  if VTIG_EventCancel then
  begin
    UI.UpdateStatus( nil );
    FResult := -1;
    FFinished := True;
  end;
end;

function TShopWindow.IsModal : Boolean;
begin
  Exit( True );
end;

destructor TShopWindow.Destroy;
begin
  FItems := nil;
  inherited Destroy;
end;

{ TSkillWindow }

constructor TSkillWindow.Create;
var iCount : Byte;
    iBonus : Integer;
    iItem  : TItem;

  function getQuick(ID: byte): string;
  var i: byte;
  begin
    for i := 1 to MaxQuickSkills do
      if UI.Player.QuickSkills[i] = ID then
        exit('('+inttostr(i)+')');
    exit('');
  end;

begin
  VTIG_EventClear;
  VTIG_ResetSelect('quick_skill');
  FFinished := False;
  FEntries  := nil;
  FCount    := 0;
  FResult   := 0;

  // Skill
  if UI.Player.Skill > 0 then
  begin
    SetLength( FEntries, FCount + 1 );
    FEntries[FCount].Name  := Padded('@ ' + AnsiString(LuaSystem.Get(['spells', UI.Player.Skill, 'name'])), 20) + getQuick(UI.Player.Skill);
    FEntries[FCount].Data  := UI.Player.Skill + ord(CAST_SKILL) shl 8;
    FEntries[FCount].Valid := True;
    Inc( FCount );
  end;
  iBonus := UI.Player.getItemSumBonus( STAT_SPELLLEVEL );

  // Spells
  for iCount := 1 to MaxSpells do
    if UI.Player.Spells[iCount] <> 0 then
      if LuaSystem.Defined(['spells', iCount]) then
      begin
        SetLength( FEntries, FCount + 1 );
        FEntries[FCount].Name  := Padded('@ ' + AnsiString(LuaSystem.Get(['spells', iCount, 'name'])) +
                                  ' lvl ' + IntToStr(UI.Player.Spells[iCount] + iBonus), 20) + getQuick(iCount);
        FEntries[FCount].Data  := iCount + ord(CAST_SPELL) shl 8;
        FEntries[FCount].Valid := True;
        Inc( FCount );
      end;

  // Scrolls
  for iCount := 1 to MaxSpells do
    if UI.Player.FindScroll(iCount) <> nil then
      if LuaSystem.Defined(['spells', iCount]) then
      begin
        SetLength( FEntries, FCount + 1 );
        FEntries[FCount].Name  := Padded('? ' + AnsiString(LuaSystem.Get(['spells', iCount, 'name'])), 20) + getQuick(iCount);
        FEntries[FCount].Data  := iCount + ord(CAST_SCROLL) shl 8;
        FEntries[FCount].Valid := True;
        Inc( FCount );
      end;

  // Staff
  iItem := UI.Player.Equipment[SlotRHand];
  if (iItem <> nil) then
    if (iItem.Spell <> 0) then
    begin
      SetLength( FEntries, FCount + 1 );
      FEntries[FCount].Name  := Padded('/ ' + iItem.getSpellName, 20) + getQuick(254);
      FEntries[FCount].Data  := iItem.Spell + ord(CAST_STAFF) shl 8;
      FEntries[FCount].Valid := (iItem.Charges > 0);
      Inc( FCount );
    end;
end;

procedure TSkillWindow.Update( aDTime : Integer; aActive : Boolean );
var iSize   : TIOPoint;
    i       : Integer;
    iSelect : Integer;
    iSource : TSpellSource;
    iSpell  : Byte;
    iLimit  : Integer;
begin
  iLimit := (UI.SizeY - 5) div 2 - 3;
  iSize := Point( 27, Min( 5 + FCount, iLimit ) );
  if iLimit = FCount + 4 then Inc( iSize.Y );

  VTIG_PushStyle( @TIGNarrowFramedWindowStyle );
  VTIG_Begin( 'quick_skill', iSize, Point( UI.SizeX - 30, iLimit + 3 ) );

  for i := 0 to FCount - 1 do
    VTIG_Selectable( FEntries[i].Name, FEntries[i].Valid );

  VTIG_Selectable( 'Close' );
  if iLimit < FCount + 4 then
    VTIG_Scrollbar;
  
  VTIG_End;
  VTIG_PopStyle;
  VTIG_FreeLabel( 'Press <{!Enter}> to select, <{!Escape}> to exit...', Point( 0, 0 ), DarkGray );

  if VTIG_EventConfirm then
  begin
    iSelect := VTIG_Selected('quick_skill');
    if iSelect < FCount then
    begin
      FResult := FEntries[iSelect].Data;
      iSource := TSpellSource( (FResult shr 8) and $ff );
      iSpell  := Byte(FResult and $ff);
      case iSource of
        CAST_SPELL  : UI.Player.Spell.Init(UI.Player, iSpell);
        CAST_SKILL  : UI.Player.Spell.Init(UI.Player, iSpell, true);
        CAST_STAFF  : UI.Player.Spell.Init(UI.Player.Equipment[SlotRHand]);
        CAST_SCROLL : UI.Player.Spell.Init(UI.Player.FindScroll(iSpell));
      end;
    end;
    FFinished := True;
  end;

  if VTIG_EventCancel then
    FFinished := True;
end;

function TSkillWindow.IsModal : Boolean;
begin
  Exit( True );
end;

destructor TSkillWindow.Destroy;
begin
  FEntries := nil;
  inherited Destroy;
end;

{ TQsWindow }

constructor TQsWindow.Create;
begin
  VTIG_EventClear;
  VTIG_ResetSelect( 'quickslots' );
  FFinished  := False;
  FKeyAction := 0;
end;

procedure TQsWindow.Update( aDTime : Integer; aActive : Boolean );
var iSize     : TIOPoint;
    iCount    : Byte;
    iSelected : Integer;
    iPicked   : Integer;
begin
  iSize := Point( 38, 13 );

  VTIG_PushStyle( @TIGNarrowFramedWindowStyle );
  VTIG_Begin( 'quickslots', iSize, Point( 3, 4 ) );

  iPicked := 0;
  for iCount := 1 to ITEMS_QS do
    if UI.Player.GetQsItem(iCount) <> nil then
    begin
      if VTIG_Selectable( ' ' + UI.Player.GetQsItem(iCount).GetName(PlainName) ) then
        iPicked := iCount;
    end
    else
      VTIG_Selectable( ' (empty)', False );

  if VTIG_Selectable( 'Close' ) then
    FFinished := True;

  iSelected := VTIG_Selected + 1;

  VTIG_End;
  VTIG_PopStyle;
  VTIG_FreeLabel( 'Press <{!Enter}> to use, <{!d}> to drop, <{!i}> to store, <{!Escape}> to exit...', Point( 0, 0 ), DarkGray );

  if VTIG_EventConfirm then
  begin
    if UI.Player.GetQsItem( iPicked ) <> nil then
      UI.Player.UseQuickSlot( iPicked );
    FFinished := True;
  end;

  if FKeyAction > 0 then
  begin 
    if UI.Player.GetQsItem( iSelected ) <> nil  then
    begin
      case FKeyAction of
        1 : if UI.Player.ActionDrop( UI.Player.GetQsItem( iSelected ) ) then
              FFinished  := True;
        2 : if UI.Player.ActionAddToBackPack( UI.Player.GetQsItem( iSelected ) ) then
              FFinished  := True;
      end;
    end;
    FKeyAction := 0;
  end;

  if VTIG_EventCancel then
    FFinished := True;
end;

function TQsWindow.IsModal : Boolean;
begin
  Exit( True );
end;

function TQsWindow.HandleEvent( const aEvent : TIOEvent ) : Boolean;
begin
  if aEvent.EType <> VEVENT_KEYDOWN then Exit( inherited HandleEvent( aEvent ) );
  if aEvent.Key.ModState <> [] then Exit( inherited HandleEvent( aEvent ) );
  case aEvent.Key.Code of
    VKEY_D : begin FKeyAction := 1;    Exit( True ); end;
    VKEY_I : begin FKeyAction := 2;    Exit( True ); end;
    VKEY_Q : begin FFinished := True ; Exit( True ); end;
  end;
  Exit( inherited HandleEvent( aEvent ) );
end;

{ TTravelWindow }

constructor TTravelWindow.Create;
begin
  VTIG_EventClear;
  FFinished := False;
  FResult   := -1;
end;

procedure TTravelWindow.Update( aDTime : Integer; aActive : Boolean );
var iPoints : TTravelPoints;
    iCount  : DWord;
    iSize   : TIOPoint;
begin
  iPoints := Game.Level.TravelPoints;
  iSize.X := 16;
  iSize.Y := iPoints.Size + 5;
  if iPoints.Size > 0 then
    for iCount := 0 to iPoints.Size - 1 do
      iSize.X := Max( iSize.X, Length( iPoints[ iCount ].What ) + 4 );

  VTIG_PushStyle( @TIGNarrowFramedWindowStyle );
  VTIG_BeginWindow( 'Fast travel', 'fast_travel', iSize, Point( 46, 13 ) );

  if iPoints.Size > 0 then
    for iCount := 0 to iPoints.Size - 1 do
      if VTIG_Selectable( iPoints[ iCount ].What ) then
      begin
        FResult := iCount;
        FFinished := True;
      end;

  if VTIG_Selectable( 'Cancel' ) or VTIG_EventCancel then
  begin
    FResult   := -1;
    FFinished := True;
  end;

  VTIG_End;
  VTIG_PopStyle;
  VTIG_FreeLabel( 'Press <{!Enter}> to select, <{!Escape}> to exit...', Point( 0, 0 ), DarkGray );
end;

function TTravelWindow.IsModal : Boolean;
begin
  Exit( True );
end;


end.

