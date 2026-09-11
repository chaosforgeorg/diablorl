{$include rl.inc}
// @abstract(Game views for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)

unit rlgviews;
interface

uses Classes, SysUtils,
     viotypes, vioevent, 
     vtig, vtigio, vtigstyle, vtextmap, vmessages, 
     rlglobal, rlthing, rlitem, vrltools;

type TMainScreen = class;

type TPanel = class( TIOLayer )
  constructor Create( aOwner : TMainScreen = nil );
  destructor Destroy; override;
protected
  FOwner : TMainScreen;
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

{ TMainScreen }

type TMainScreen = class( TIOLayer )
  constructor Create( aMap : TTextMap; aMessages : TMessages );
  destructor Destroy; override;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
  function HandleEvent( const aEvent : TIOEvent ) : Boolean; override;
  function HandleCommand( aCommand : Byte ) : Boolean;
  procedure RemovePanel( aPanel : TPanel );
  procedure ClearLeft;
  procedure ClearRight;
  procedure ClearBoth;
  procedure UpdateMap;
private
  FLeft    : TPanel;
  FRight   : TPanel;
  FMap     : TTextMap;
  FMessages: TMessages;
  FStatus  : TStatus;
public
  property Left   : TPanel read FLeft  write FLeft;
  property Right  : TPanel read FRight write FRight;
  property Status     : TStatus  read FStatus;
end;

{ TPlotWindow }

type TPlotWindow = class( TIOLayer )
  constructor Create( const aText : AnsiString );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
protected
  FText      : AnsiString;
  FStartTime : DWord;
  FShift     : TIOPoint;
end;

{ TItemInfo }

type TItemInfo = class( TIOLayer )
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

type TShopWindow = class( TPanel )
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

{ TCharWindow }

type TCharWindow = class( TPanel )
  constructor Create( aOwner : TMainScreen );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
  function HandleEvent( const aEvent : TIOEvent ) : Boolean; override;
protected
  FShift     : TIOPoint;
  FKeyAction : Byte;
end;

{ TJournalWindow }

type TJournalWindow = class( TPanel )
  constructor Create( aOwner : TMainScreen );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
protected
  FShift    : TIOPoint;
end;

{ TTalkWindow }

type TTalkOption = record
  Text   : AnsiString;
  Active : Boolean;
end;

type TTalkWindow = class( TPanel )
  constructor Create( aOwner : TMainScreen; const aIntro : AnsiString );
  procedure Add( const aOption : AnsiString; aActive : Boolean = True );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
  destructor Destroy; override;
protected
  FIntro       : AnsiString;
  FOptions     : array of TTalkOption;
  FOptionCount : Integer;
  FShift       : TIOPoint;
  class var FResult : Integer;
public
  class property Result : Integer read FResult;
end;

// TODO - handle cases when equipment gets destroyed or
//        mutated (shrines/magic) when viewing
// TODO - Quickslot marking in inventory

{ TInventoryWindow }

type TInventoryWindow = class( TPanel )
  constructor Create( aOwner : TMainScreen );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
  function HandleEvent( const aEvent : TIOEvent ) : Boolean; override;
  destructor Destroy; override;
protected
  FShift     : TIOPoint;
  FMode      : ( InvMode, EqMode );
  FKeyAction : Byte;
end;

{ TSpellWindow }

type TSpellWindow = class( TPanel )
  constructor Create( aOwner : TMainScreen );
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
protected
  FShift    : TIOPoint;
end;

{ TSkillWindow }

type TSkillEntry = record
  Name : AnsiString;
  Data : DWord;
  Valid: Boolean;
end;
type TSkillEntryArray = array of TSkillEntry;

type TSkillWindow = class( TIOLayer )
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

type TQsWindow = class( TIOLayer )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
  function HandleEvent( const aEvent : TIOEvent ) : Boolean; override;
protected
  FKeyAction : Byte;
end;

{ TTravelWindow }

type TTravelWindow = class( TIOLayer )
  constructor Create;
  procedure Update( aDTime : Integer; aActive : Boolean ); override;
  function IsModal : Boolean; override;
protected
  class var FResult : Integer;
public
  class property Result : Integer read FResult;
end;

implementation

uses math, vutil, vluasystem,
     rlgame, rlconfig, rllevel, rlui, rlnpc, rlplayer;

{ TPanel }

constructor TPanel.Create( aOwner : TMainScreen );
begin
  VTIG_EventClear;
  FOwner := aOwner;
end;

destructor TPanel.Destroy;
begin
  if FOwner <> nil then
    FOwner.RemovePanel( Self );
  inherited Destroy;
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
  var iColor : TIOColor;
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

{ TMainScreen }

constructor TMainScreen.Create( aMap : TTextMap; aMessages : TMessages );
begin
  FLeft    := nil;
  FRight   := nil;
  FMap        := aMap;
  FMessages   := aMessages;
  FStatus     := TStatus.Create;
end;

destructor TMainScreen.Destroy;
begin
  FreeAndNil( FStatus );
  inherited Destroy;
end;

procedure TMainScreen.Update( aDTime : Integer; aActive : Boolean );
var i       : Integer;
    iColor  : DWord;
begin
  VTIG_Clear;
  if FMap <> nil then
  begin
    FMap.Update( aDTime );
    FMap.OnRedraw;
  end;
  if FMessages <> nil then
    for i := 1 to 2 do
    begin
      if i > FMessages.Size then Continue;
      if i <= FMessages.Active
        then iColor := LightGray
        else iColor := DarkGray;
      VTIG_FreeLabel( FMessages.Content[ -i ], Point(2, 2-i), iColor );
    end;
  FStatus.Draw;
end;

function TMainScreen.IsModal : Boolean;
begin
  Exit( False );
end;

function TMainScreen.HandleEvent( const aEvent : TIOEvent ) : Boolean;
var iAction : Integer;
begin
  if aEvent.EType <> VEVENT_KEYDOWN then Exit( inherited HandleEvent( aEvent ) );
  iAction := UI.GameBindings.ResolveKey( IOKeyEventToIOKeyCode( aEvent.Key ) );
  if (iAction >= 0) and (iAction <= High( Byte )) and HandleCommand( Byte( iAction ) ) then
    Exit( True );
  Exit( inherited HandleEvent( aEvent ) );
end;

function TMainScreen.HandleCommand( aCommand : Byte ) : Boolean;
begin
  if UI.Player.HP <= 0 then Exit( False );
  case aCommand of
    COMMAND_CWIN       : begin ClearBoth; Exit( True ) end;
    COMMAND_JOURNAL    : if FLeft  is TJournalWindow   then begin ClearLeft;  Exit( True ) end else begin ClearLeft;  FLeft  := UI.PushLayer( TJournalWindow.Create( Self ) ) as TPanel;   UpdateMap; Exit( True ); end;
    COMMAND_PLAYERINFO : if FLeft  is TCharWindow      then begin ClearLeft;  Exit( True ) end else begin ClearLeft;  FLeft  := UI.PushLayer( TCharWindow.Create( Self ) ) as TPanel;      UpdateMap; Exit( True ); end;
    COMMAND_INVENTORY  : if FRight is TInventoryWindow then begin ClearRight; Exit( True ) end else begin ClearRight; FRight := UI.PushLayer( TInventoryWindow.Create( Self ) ) as TPanel; UpdateMap; Exit( True ); end;
    COMMAND_SPELLBOOK  : if FRight is TSpellWindow     then begin ClearRight; Exit( True ) end else begin ClearRight; FRight := UI.PushLayer( TSpellWindow.Create( Self ) ) as TPanel;     UpdateMap; Exit( True ); end;
    COMMAND_QUICKSKILL : begin UI.RunLayer( TSkillWindow.Create ); Exit( True ); end;
    COMMAND_QUICKSLOT  : if not (FRight is TInventoryWindow) then begin UI.RunLayer( TQsWindow.Create ); Exit( True ); end else Exit( False );
  end;
  // When any panel is open, Escape closes all panels
  if (FLeft <> nil) or (FRight <> nil) then
    if aCommand = COMMAND_ESCAPE then begin ClearBoth; Exit( True ); end;
  // When right panel (inventory/spellbook) is open, consume commands that
  // map to VTIG widget navigation (arrows, enter, tab, drop, switchmode)
  if FRight <> nil then
    case aCommand of
      COMMAND_OK,
      COMMAND_SWITCHMODE,
      COMMAND_DROP,
      COMMAND_WALKNORTH, COMMAND_WALKSOUTH,
      COMMAND_WALKEAST, COMMAND_WALKWEST,
      COMMAND_WALKNE, COMMAND_WALKSE,
      COMMAND_WALKNW, COMMAND_WALKSW : Exit( True );
    end;
  Exit( False );
end;

procedure TMainScreen.RemovePanel( aPanel : TPanel );
begin
  if FLeft = aPanel then
    FLeft := nil
  else if FRight = aPanel then
    FRight := nil
  else
    Exit;
  UpdateMap;
end;

procedure TMainScreen.ClearLeft;
begin
  if FLeft <> nil then
  begin
    FLeft.FOwner := nil;
    FLeft.Finish;
    FLeft := nil;
  end;
  UpdateMap;
end;

procedure TMainScreen.ClearRight;
begin
  if FRight <> nil then
  begin
    FRight.FOwner := nil;
    FRight.Finish;
    FRight := nil;
  end;
  UpdateMap;
end;

procedure TMainScreen.ClearBoth;
begin
  if FLeft <> nil then
  begin
    FLeft.FOwner := nil;
    FLeft.Finish;
    FLeft := nil;
  end;
  if FRight <> nil then
  begin
    FRight.FOwner := nil;
    FRight.Finish;
    FRight := nil;
  end;
  UpdateMap;
end;

procedure TMainScreen.UpdateMap;
begin
  if FMap <> nil then
  begin
    if (FLeft = nil) and (FRight = nil) then
      FMap.SetArea( Rectangle( 1, 3, UI.SizeX, UI.SizeY - 5 ) )
    else
    if FLeft = nil then
      FMap.SetArea( Rectangle( 1, 3, UI.SizeX div 2, UI.SizeY - 5 ) )
    else
      FMap.SetArea( Rectangle( UI.SizeX div 2 + 1, 3, UI.SizeX div 2, UI.SizeY - 5 ) );
    FMap.ClearMarks;
    FMap.OnRedraw;
  end;
  UI.Focus(UI.Player.Position);
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
  iSize := VTIG_GetIOState.Size;
  FShift.Init( (iSize.X - 80) div 2, (iSize.Y - 25) div 2 );
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
  VTIG_FreeLabel( ' Press <{!' + UI.UIKey( VTIG_IE_CONFIRM ) + '}>, <{!' + UI.UIKey( VTIG_IE_SELECT ) + '}> or <{!' + UI.UIKey( VTIG_IE_CANCEL ) + '}> to skip...                 ', Point( 0, 0 ), DarkGray );
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
  iSize := VTIG_GetIOState.Size;
  FShift.Init( (iSize.X - 80) div 2, (iSize.Y - 10) div 2 );
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
  VTIG_FreeLabel( ' Press <{!' + UI.UIKey( VTIG_IE_CONFIRM ) + '}>, <{!' + UI.UIKey( VTIG_IE_SELECT ) + '}> or <{!' + UI.UIKey( VTIG_IE_CANCEL ) + '}> to continue...                 ', Point( 0, 0 ), DarkGray );
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
  inherited Create;
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
  iSize := VTIG_GetIOState.Size;
  FShift.Init( (iSize.X - 80) div 2, (iSize.Y - 25) div 2 );
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
  VTIG_FreeLabel( ' Press <{!' + UI.UIKey( VTIG_IE_CONFIRM ) + '}> to buy, <{!' + UI.UIKey( VTIG_IE_CANCEL ) + '}> to exit...          ', Point( 0, 0 ), DarkGray );

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

{ TCharWindow }

constructor TCharWindow.Create( aOwner : TMainScreen );
begin
  inherited Create( aOwner );
  FKeyAction := 0;
end;

procedure TCharWindow.Update( aDTime : Integer; aActive : Boolean );
var iSize     : TIOPoint;
    iColWidth : Integer;

  procedure DrawStat( aLine, aColumn : Byte; const aName, aValue : AnsiString );
  begin
    VTIG_FreeLabel( aName, Point( (aColumn-1) * iColWidth, aLine - 1 ), DarkGray );
    VTIG_FreeLabel( aValue, Point( aColumn * iColWidth - 4 - VTIG_Length( aValue ), aLine - 1 ), LightGray );
  end;

  procedure DrawUpStat( aLine : Byte; const aName : AnsiString; aBase, aCurrent : Integer; aUpgrade : Char = ' '; aDrawUpgrade : Boolean = False );
  var iValue : AnsiString;
  begin
    VTIG_FreeLabel( aName, Point( 0, aLine - 1 ), DarkGray );
    iValue := IntToStr(aBase) + '{d|}';
    if aDrawUpgrade
      then iValue += '{R[{y' + aUpgrade + '}]}'
      else iValue += '{' + ColorCodes[ ModColor( aCurrent - aBase ) ] + IntToStr( aCurrent ) + '}';
    VTIG_FreeLabel( iValue, Point( iColWidth - 4 - VTIG_Length( iValue ), aLine - 1 ), LightGray );
  end;

  function ResistStr( aResist : DWord ) : AnsiString;
  var iValue : LongInt;
  begin
    iValue := UI.Player.GetResist( aResist );
    if iValue >= 75 then Exit( 'MAX' );
    Exit( IntToStr( iValue ) );
  end;

begin
  iSize := Point( UI.SizeX div 2, UI.SizeY - 5 );
  iColWidth := iSize.X div 2;

  VTIG_PushStyle( @TIGNarrowFramedWindowStyle );
  VTIG_BeginWindow( 'Character', 'char', iSize, Point( 1, 3 ) );

  with UI.Player do
  begin
    LevelUp := False;

    DrawStat( 1, 1, 'Name', Name );               DrawStat( 1, 2, 'Class', UpCase(AnsiString(LuaSystem.Get(['klasses',Klass,'name']))) );
    DrawStat( 2, 1, 'Level', IntToStr(Level) );    DrawStat( 2, 2, 'Exp', IntToStr(Exp) );
    if Level < 50 then                             DrawStat( 3, 2, 'NextLev', IntToStr(ExpTable[Level + 1]) )
                  else                             DrawStat( 3, 2, 'NextLev', 'MAX' );
    DrawUpStat( 5, 'Strength',  Str, getStr, 's', (Points > 0) and ( Str < getStatMax( STAT_STR ) ) );
    DrawUpStat( 6, 'Magic',     Mag, getMag, 'm', (Points > 0) and ( Mag < getStatMax( STAT_MAG ) ) );
    DrawUpStat( 7, 'Dexterity', Dex, getDex, 'd', (Points > 0) and ( Dex < getStatMax( STAT_DEX ) ) );
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

    // Handle stat upgrade from HandleEvent
    if (FKeyAction > 0) and (Points > 0) then
    begin
      case FKeyAction of
        1 : if Str < getStatMax( STAT_STR ) then begin Str := Str + 1; Stats.Inc('points_used'); Points := Points - 1; end;
        2 : if Mag < getStatMax( STAT_MAG ) then begin Mag := Mag + 1; Stats.Inc('points_used'); Points := Points - 1; end;
        3 : if Dex < getStatMax( STAT_DEX ) then begin Dex := Dex + 1; Stats.Inc('points_used'); Points := Points - 1; end;
        4 : if Vit < getStatMax( STAT_VIT ) then begin Vit := Vit + 1; Stats.Inc('points_used'); Points := Points - 1; end;
      end;
      FKeyAction := 0;
    end
    else
      FKeyAction := 0;
  end;

  VTIG_End;
  VTIG_PopStyle;
  VTIG_FreeLabel( ' Press <{!' + UI.UIKey( VTIG_IE_CANCEL ) + '}> to exit...', Point( 0, 0 ), DarkGray );

  if VTIG_EventCancel then
    Finish;
end;

function TCharWindow.IsModal : Boolean;
begin
  Exit( False );
end;

function TCharWindow.HandleEvent( const aEvent : TIOEvent ) : Boolean;
begin
  if aEvent.EType <> VEVENT_KEYDOWN then Exit( inherited HandleEvent( aEvent ) );
  if aEvent.Key.ModState <> [] then Exit( inherited HandleEvent( aEvent ) );
  case aEvent.Key.Code of
    VKEY_S : begin FKeyAction := 1; Exit( True ); end;
    VKEY_M : begin FKeyAction := 2; Exit( True ); end;
    VKEY_D : begin FKeyAction := 3; Exit( True ); end;
    VKEY_V : begin FKeyAction := 4; Exit( True ); end;
  end;
  Exit( inherited HandleEvent( aEvent ) );
end;

{ TJournalWindow }

constructor TJournalWindow.Create( aOwner : TMainScreen );
begin
  inherited Create( aOwner );
end;

procedure TJournalWindow.Update( aDTime : Integer; aActive : Boolean );
var iSize    : TIOPoint;
    iCount   : Byte;
    iQuestID : Integer;
begin
  iSize := Point( UI.SizeX div 2, UI.SizeY - 5 );

  VTIG_PushStyle( @TIGNarrowFramedWindowStyle );
  VTIG_BeginWindow( 'Journal', 'journal', iSize, Point( 1, 3 ) );

  iQuestID := 0;
  with UI.Player do
  for iCount := 1 to LuaSystem.Get(['quests', '__counter']) do
    if ( Quests[ iCount ] > 0 ) and ( Quests[iCount] < LuaSystem.Get(['quests',iCount,'completed']) ) then
      if VTIG_Selectable( AnsiString(LuaSystem.Get(['quests', iCount, 'name'])) ) then
        iQuestID := iCount;

  if VTIG_Selectable( 'Close' ) then
    Finish;

  if iQuestID = 0 then
    VTIG_Text( 'Currently, You are not involved in any quests.' );

  VTIG_Scrollbar;

  VTIG_End;
  VTIG_PopStyle;
  VTIG_FreeLabel( ' Press <{!' + UI.UIKey( VTIG_IE_CONFIRM ) + '}> to view, <{!' + UI.UIKey( VTIG_IE_CANCEL ) + '}> to exit...', Point( 0, 0 ), DarkGray );

  if iQuestID > 0 then
    LuaSystem.ProtectedCall(['quests', iQuestID, 'OnJournal'], [] );

  if VTIG_EventCancel then
    Finish;
end;

function TJournalWindow.IsModal : Boolean;
begin
  Exit( False );
end;

{ TTalkWindow }

constructor TTalkWindow.Create( aOwner : TMainScreen; const aIntro : AnsiString );
var iSize : TIOPoint;
begin
  inherited Create( aOwner );
  FIntro       := aIntro;
  FOptions     := nil;
  FOptionCount := 0;
  FResult      := -1;
  iSize := VTIG_GetIOState.Size;
  FShift.Init( (iSize.X - 80) div 2, (iSize.Y - 25) div 2 );
end;

procedure TTalkWindow.Add( const aOption : AnsiString; aActive : Boolean );
begin
  if FOptionCount >= Length(FOptions) then
    SetLength( FOptions, FOptionCount + 8 );
  FOptions[FOptionCount].Text   := aOption;
  FOptions[FOptionCount].Active := aActive;
  Inc( FOptionCount );
end;

procedure TTalkWindow.Update( aDTime : Integer; aActive : Boolean );
var iSize : TIOPoint;
    i     : Integer;
begin
  iSize := Point( UI.SizeX div 2, UI.SizeY - 5 );

  VTIG_PushStyle( @TIGFramedWindowStyle );
  VTIG_Begin( 'talk_panel', iSize, Point( UI.SizeX div 2 + 1, 3 ) );

  VTIG_SetAlignment( VTIG_ALIGN_CENTER );
  VTIG_Text( FIntro, LightGray );
  VTIG_Ruler;

  for i := 0 to FOptionCount - 1 do
    if VTIG_Selectable( FOptions[i].Text, FOptions[i].Active ) then
    begin
      FResult := i;
      FFinished := True;
    end;
  VTIG_SetAlignment( VTIG_ALIGN_LEFT );

  VTIG_End;
  VTIG_PopStyle;
  VTIG_FreeLabel( ' Press <{!' + UI.UIKey( VTIG_IE_CONFIRM ) + '}> to choose, <{!' + UI.UIKey( VTIG_IE_CANCEL ) + '}> to exit...                    ', Point( 0, 0 ), DarkGray );

  if VTIG_EventCancel then
  begin
    FResult := -1;
    FFinished := True;
  end;
end;

function TTalkWindow.IsModal : Boolean;
begin
  Exit( True );
end;

destructor TTalkWindow.Destroy;
begin
  FOptions := nil;
  inherited Destroy;
end;

{ TInventoryWindow }

constructor TInventoryWindow.Create( aOwner : TMainScreen );
begin
  inherited Create( aOwner );
  FMode      := InvMode;
  FKeyAction := 0;
end;

procedure TInventoryWindow.Update( aDTime : Integer; aActive : Boolean );
var iSize     : TIOPoint;
    iInvList  : TItemList;
    iEqList   : TItemList;
    iItem     : TItem;
    iIndex    : Word;
    iSel      : Integer;
    iEqEmpty  : Boolean;
    iEqCount  : Integer;
    iEqSelMap : array[0..ITEMS_EQ-1] of Word;
    iCurrent  : TItem;
    iVolume   : AnsiString;
    iConfirmItem : TItem;
    iConfirmSlot : Integer;
begin
  iSize := Point( UI.SizeX div 2, UI.SizeY - 5 );

  VTIG_PushStyle( @TIGNarrowFramedWindowStyle );
  VTIG_BeginWindow( 'Inventory', 'inv', iSize, Point( UI.SizeX div 2 + 1, 3 ) );

  iInvList := UI.Player.GetInvList;
  iEqList  := UI.Player.GetEqList;
  iConfirmItem := nil;
  iConfirmSlot := 0;
  iEqEmpty := True;
  iEqCount := 0;

  // Equipment section (normal cursor flow, no group)
  for iIndex := 1 to ITEMS_EQ do
  begin
    if iEqList[ iIndex ] <> nil then iEqEmpty := False;
    VTIG_Text( UI.Player.SlotName(iIndex) + ' : ', DarkGray );
    VTIG_SameLine;
    if iEqList[ iIndex ] = nil then
      VTIG_Text( '---', Red )
    else
    begin
      if FMode = EqMode then
      begin
        iEqSelMap[iEqCount] := iIndex;
        Inc(iEqCount);
        if VTIG_Selectable( iEqList[ iIndex ].GetName(PlainName), True, iEqList[ iIndex ].InvColor ) then
          iConfirmSlot := iIndex;
      end
      else
        VTIG_Text( iEqList[ iIndex ].GetName(PlainName), iEqList[ iIndex ].InvColor );
    end;
  end;

  VTIG_Ruler;

  // Inventory section
  if FMode = InvMode then
  begin
    // Embedded sub-window for independent scroll in InvMode
    VTIG_PushStyle( @TIGEmbeddedStyle );
    VTIG_Begin( 'inv_items', Point( iSize.X - 4, iSize.Y - ITEMS_EQ - 5 ), VTIG_PositionResolve( Point( 0, ITEMS_EQ + 2 ) ) );
    for iItem in iInvList do
      if VTIG_Selectable( Padded(iItem.GetName(PlainName), iSize.X - 7) + ' ' + IntToStr(iItem.Volume), True, iItem.InvColor ) then
        iConfirmItem := iItem;
    VTIG_Scrollbar;
    VTIG_End;
    VTIG_PopStyle;
  end
  else
  begin
    // Plain text in parent window for EqMode
    for iItem in iInvList do
      VTIG_Text( Padded(iItem.GetName(PlainName), iSize.X - 7) + ' ' + IntToStr(iItem.Volume), iItem.InvColor );
  end;


  // Update status for selected item
  iCurrent := nil;
  if FMode = InvMode then
  begin
    iSel := VTIG_Selected('inv_items');
    if (iSel >= 0) and (iSel < Integer(iInvList.Size)) then
      iCurrent := TItem( iInvList[ iSel + 1 ] );
  end
  else
  begin
    iSel := VTIG_Selected('inv');
    if (iSel >= 0) and (iSel < iEqCount) then
      iCurrent := iEqList[ iEqSelMap[iSel] ];
  end;
  if iCurrent <> nil then
    UI.UpdateStatus( iCurrent )
  else
    UI.UpdateStatus( nil );

  iVolume := Format('{!%d}/%d', [UI.Player.InvVolume, MaxVolume]);
  VTIG_End( iVolume );
  VTIG_PopStyle;

  VTIG_FreeLabel( ' Inventory: <{!TAB}> switch, <{!' + UI.UIKey( VTIG_IE_CONFIRM ) + '}> equip/use, <{!d}> drop, <{!q}> quickslot, <{!' + UI.UIKey( VTIG_IE_CANCEL ) + '}> exit.',
    Point( 0, 0 ), DarkGray );

  // Handle confirm via selectable return value
  if iConfirmItem <> nil then
  begin
    UI.UpdateStatus( nil );
    Finish;
    FreeAndNil( iInvList );
    FreeAndNil( iEqList );
    UI.Player.ActionWear( iConfirmItem );
    Exit;
  end;
  if iConfirmSlot > 0 then
    UI.Player.ActionWear( nil, iConfirmSlot );

  // Handle tab
  if FKeyAction = 3 then
  begin
    if FMode = InvMode then
    begin
      if not iEqEmpty then
      begin
        FMode := EqMode;
        VTIG_ResetSelect('inv', 0);
      end;
    end
    else
    begin
      if iInvList.Size > 0 then
      begin
        FMode := InvMode;
        VTIG_ResetSelect('inv', 0);
      end;
    end;
    UI.PlaySound('sfx/items/invgrab.wav');
  end;

  // Handle key actions from HandleEvent
  if FKeyAction > 0 then
  begin
    case FKeyAction of
      1 : // Drop
        begin
          if iCurrent <> nil then
          begin
            UI.Player.ActionDrop( iCurrent );
            VTIG_ResetSelect('inv', 0);
          end;
        end;
      2 : // Quickslot
        begin
          if iCurrent <> nil then
          begin
            UI.Player.ActionQuickslotItem( iCurrent );
            VTIG_ResetSelect('inv', 0);
          end;
        end;
    end;
    FKeyAction := 0;
  end;

  if VTIG_EventCancel then
  begin
    UI.UpdateStatus( nil );
    Finish;
  end;

  FreeAndNil( iInvList );
  FreeAndNil( iEqList );
end;

function TInventoryWindow.IsModal : Boolean;
begin
  Exit( False );
end;

function TInventoryWindow.HandleEvent( const aEvent : TIOEvent ) : Boolean;
begin
  if aEvent.EType <> VEVENT_KEYDOWN then Exit( inherited HandleEvent( aEvent ) );
  if aEvent.Key.ModState <> [] then Exit( inherited HandleEvent( aEvent ) );
  case aEvent.Key.Code of
    VKEY_D : begin FKeyAction := 1; Exit( True ); end;
    VKEY_Q : begin FKeyAction := 2; Exit( True ); end;
    VKEY_TAB : begin FKeyAction := 3; Exit( True ); end;
  end;
  Exit( inherited HandleEvent( aEvent ) );
end;

destructor TInventoryWindow.Destroy;
begin
  UI.UpdateStatus( nil );
  inherited Destroy;
end;

{ TSpellWindow }

constructor TSpellWindow.Create( aOwner : TMainScreen );
begin
  inherited Create( aOwner );
end;

procedure TSpellWindow.Update( aDTime : Integer; aActive : Boolean );
var iSize  : TIOPoint;
    iCount : Byte;
    iBonus : Integer;
    iSpellCount : Integer;
    iSpellPicked : Integer;
    Name   : AnsiString;
    Slvl   : Byte;
    Cost   : DWord;
    DMin   : DWord;
    DMax   : DWord;
begin
  iSize := Point( UI.SizeX div 2, UI.SizeY - 5 );

  VTIG_PushStyle( @TIGNarrowFramedWindowStyle );
  VTIG_BeginWindow( 'Spells', 'spells', iSize, Point( UI.SizeX div 2 + 1, 3 ) );

  iBonus := UI.Player.getItemSumBonus( STAT_SPELLLEVEL );
  iSpellCount := 0;
  iSpellPicked := 0;

  for iCount := 1 to MaxSpells do
    if LuaSystem.Defined(['spells', iCount]) then
      with LuaSystem.GetTable(['spells', iCount]) do
        try
          Slvl := UI.Player.Spells[iCount];
          if getInteger('page') <> 0 then
          begin
            if slvl <> 0 then
            begin
              Name := getString('name');
              Cost := max(Integer(LuaSystem.ProtectedCall(['spells', iCount, 'cost'], [20, UI.Player])),
                (LuaSystem.ProtectedCall(['spells', iCount, 'cost'], [slvl, UI.Player]) * UI.Player.SpellCost) div 100);

              if isFunction('dmin')
                then DMin := ProtectedCall('dmin',[slvl, UI.Player])
                else DMin := GetInteger('dmin');
              if isFunction('dmax')
                then DMax := ProtectedCall('dmax',[slvl, UI.Player])
                else DMax := GetInteger('dmax');

              Inc( iSpellCount );

              if (dmax > 0) then
              begin
                if VTIG_Selectable(Format('%s (L:{!%d}) {!%d-%d}  Cost: {!%d}',
                  [Padded(Name, 13), slvl + iBonus, dmin, dmax, cost]), True, DarkGray) then
                  iSpellPicked := iCount;
              end
              else
                if VTIG_Selectable(Format('%s (L:{!%d}) Cost: {!%d}',
                  [Padded(Name, 13), slvl + iBonus, cost]), True, DarkGray) then
                  iSpellPicked := iCount;
            end;
          end;
        finally
          Free;
        end;

  if VTIG_Selectable( 'Close' ) then
    Finish;
  VTIG_Scrollbar;

  VTIG_End;
  VTIG_PopStyle;
  VTIG_FreeLabel( ' Press <{!' + UI.UIKey( VTIG_IE_CONFIRM ) + '}> to select, <{!' + UI.UIKey( VTIG_IE_CANCEL ) + '}> to exit...', Point( 0, 0 ), DarkGray );

  if iSpellPicked > 0 then
  begin
    UI.Player.Spell.Init(UI.Player, iSpellPicked);
    Finish;
  end;

  if VTIG_EventCancel then
    Finish;
end;

function TSpellWindow.IsModal : Boolean;
begin
  Exit( False );
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
  VTIG_FreeLabel( 'Press <{!' + UI.UIKey( VTIG_IE_CONFIRM ) + '}> to select, <{!' + UI.UIKey( VTIG_IE_CANCEL ) + '}> to exit...', Point( 0, 0 ), DarkGray );

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
  VTIG_FreeLabel( 'Press <{!' + UI.UIKey( VTIG_IE_CONFIRM ) + '}> to use, <{!d}> to drop, <{!i}> to store, <{!' + UI.UIKey( VTIG_IE_CANCEL ) + '}> to exit...', Point( 0, 0 ), DarkGray );

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
  VTIG_BeginWindow( 'Fast travel', 'fast_travel', iSize );

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
  VTIG_FreeLabel( 'Press <{!' + UI.UIKey( VTIG_IE_CONFIRM ) + '}> to select, <{!' + UI.UIKey( VTIG_IE_CANCEL ) + '}> to exit...', Point( 0, 0 ), DarkGray );
end;

function TTravelWindow.IsModal : Boolean;
begin
  Exit( True );
end;


end.

