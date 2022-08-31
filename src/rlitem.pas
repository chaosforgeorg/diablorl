{$include rl.inc}
// @abstract(Item class for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
// @created(January 17, 2005)

unit rlitem;
interface
uses classes, vnode, vutil, rlthing, rlglobal, viotypes;

type TItemColors = ( COLOR_NORMAL, COLOR_MAGIC, COLOR_UNIQUE, COLOR_RED );

type

{ TItem }

TItem = class(TThing)
     private
       FIType      : Byte;
       FVolume     : Byte;
       FAmount     : DWord;
       FSpell      : byte;
       FColors     : Array [TItemColors] of TIOColor; static;
       FSound2     : AnsiString;
       FSound1     : AnsiString;
     public
       property Sound1: AnsiString read FSound1;
       property Sound2: AnsiString read FSound2;
       property FlagsRaw : TFlags read FFlags;
     public
       // Overriden constructor. Passed ilvl is only for the OnCreate script
       constructor Create(const thingID :string; ilvl : Word = 0);
       // Identifies an item
       procedure Identify;
       // Color for inventory windows
       function InvColor: TIOColor;
       // Repair an item. RLevel is the repairer's level, 0 if ideal.
       procedure Repair( RLevel : Byte = 0 );
       // Recharge an item. RLevel is the recharger's level, 0 if ideal.
       procedure Recharge( RLevel : Byte = 0 );
       // Returns item name
       function GetName(outputType : TNameOutputType) : string; override;
       // Returns carried spell name
       function GetSpellName : AnsiString;
       // Returns status info line 1
       function GetStatusInfo1 : AnsiString;
       // Returns status info line 2
       function GetStatusInfo2 : AnsiString;
       // Returns item price
       function GetPrice(PriceType: TPriceType): LongInt;
       //Return Mag requirement for book
       function BookMagReq: Word;
       // Overriden Compare
       function Compare( aOther : TNode ) : Boolean; override;
       //Initialize before creation
       procedure Init;
       // Stream constructor
       constructor CreateFromStream( ISt : TStream ); override;
       // Stream writer
       procedure WriteToStream( OSt : TStream ); override;
       // register lua functions
       class procedure RegisterLuaAPI;
       // Checks if requirements met / also checks for ifUnknown and for the special Req = bonus case
       function ReqsMet( isWorn : Boolean ) : Boolean;
       // Init colors
       class procedure InitColors( aGraphicsMode : Boolean );
     published
       property acmodprc : LongInt read FStats[ STAT_ACMODPRC ] write FStats[ STAT_ACMODPRC ];

       property strreq : LongInt read FStats[ STAT_MINSTR ] write FStats[ STAT_MINSTR ];
       property dexreq : LongInt read FStats[ STAT_MINDEX ] write FStats[ STAT_MINDEX ];
       property magreq : LongInt read FStats[ STAT_MINMAG ] write FStats[ STAT_MINMAG ];
       property vitreq : LongInt read FStats[ STAT_MINVIT ] write FStats[ STAT_MINVIT ];

       property hpmod  : LongInt read FStats[ STAT_HPMOD ]  write FStats[ STAT_HPMOD ];
       property mpmod  : LongInt read FStats[ STAT_MPMOD ]  write FStats[ STAT_MPMOD ];

       property durmax : LongInt read FStats[ STAT_DURMAX ] write FStats[ STAT_DURMAX ];
       property dur    : LongInt read FStats[ STAT_DUR ]    write FStats[ STAT_DUR ];
       property durmod : LongInt read FStats[ STAT_DURMOD ] write FStats[ STAT_DURMOD ];

       property charges      : LongInt read FStats[ STAT_CHARGES ]    write FStats[ STAT_CHARGES ];
       property chargesmax   : LongInt read FStats[ STAT_CHARGESMAX ] write FStats[ STAT_CHARGESMAX ];
       property chargesmod   : LongInt read FStats[ STAT_CHARGESMOD ] write FStats[ STAT_CHARGESMOD ];

       property price        : LongInt read FStats[ STAT_PRICE ]    write FStats[ STAT_PRICE ];
       property pricemod     : LongInt read FStats[ STAT_PRICEMOD ] write FStats[ STAT_PRICEMOD ];
       property pricemul     : LongInt read FStats[ STAT_PRICEMUL ] write FStats[ STAT_PRICEMUL ];

       property spelllevel   : LongInt read FStats[ STAT_SPELLLEVEL ] write FStats[ STAT_SPELLLEVEL ];
       property lightmod     : LongInt read FStats[ STAT_LIGHTMOD ]   write FStats[ STAT_LIGHTMOD ];
       property dmgtaken     : LongInt read FStats[ STAT_DMGTAKEN ]   write FStats[ STAT_DMGTAKEN ];

       property lifestealmin : LongInt read FStats[ STAT_LIFESTEALMIN ] write FStats[ STAT_LIFESTEALMIN ];
       property lifestealmax : LongInt read FStats[ STAT_LIFESTEALMAX ] write FStats[ STAT_LIFESTEALMAX ];
       property manastealmin : LongInt read FStats[ STAT_MANASTEALMIN ] write FStats[ STAT_MANASTEALMIN ];
       property manastealmax : LongInt read FStats[ STAT_MANASTEALMAX ] write FStats[ STAT_MANASTEALMAX ];

       property vsundead     : LongInt read FStats[ STAT_VSUNDEAD ]   write FStats[ STAT_VSUNDEAD ];
       property vsdemon      : LongInt read FStats[ STAT_VSDEMON ]    write FStats[ STAT_VSDEMON ];
       property vsanimal     : LongInt read FStats[ STAT_VSANIMAL ]   write FStats[ STAT_VSANIMAL ];

       property resmagic     : LongInt read FStats[ STAT_RESMAGIC ]     write FStats[ STAT_RESMAGIC ];
       property resfire      : LongInt read FStats[ STAT_RESFIRE ]      write FStats[ STAT_RESFIRE ];
       property reslightning : LongInt read FStats[ STAT_RESLIGHTNING ] write FStats[ STAT_RESLIGHTNING ];

       property dmglightningmin : LongInt read FStats[ STAT_DMGLIGHTNINGMIN ] write FStats[ STAT_DMGLIGHTNINGMIN ];
       property dmglightningmax : LongInt read FStats[ STAT_DMGLIGHTNINGMAX ] write FStats[ STAT_DMGLIGHTNINGMAX ];
       property dmgfiremin : LongInt      read FStats[ STAT_DMGFIREMIN ]      write FStats[ STAT_DMGFIREMIN ];
       property dmgfiremax : LongInt      read FStats[ STAT_DMGFIREMAX ]      write FStats[ STAT_DMGFIREMAX ];

       property volume : Byte  read FVolume write FVolume;
       property amount : DWord read FAmount write FAmount;

       property itype     : Byte read FIType; //read-only

       property spell      : Byte read FSpell       write FSpell;
     end;

type TItemList = specialize TGNodeList< TItem >;

implementation

uses sysutils, vmath, vluaentitynode, vluasystem, rllua, rlgame, variants;

procedure TItem.Init;
begin
  FSpell  := 0;
  FSound2 := '';
  FSound1 := '';
  with LuaSystem.GetTable( ['items', id] ) do
  try
    FVolume := GetInteger('volume');
    FIType  := GetInteger('type');

    if IsNumber('spell')        then FSpell := LuaSystem.Get([ 'spells', getString('spell'), 'nid' ]);


    if IsString('sound1') then FSound1 := GetString('sound1');
    if IsString('sound2') then FSound2 := GetString('sound2');
  finally
    Free;
  end;
end;

// Overriden constructor.
constructor TItem.Create(const thingID :string; ilvl : Word = 0);
begin
  // Most importantly set the section of the database by inheritance of
  // TThing.
  inherited Create(thingID);
  FEntityID := ENTITY_ITEM;
  Init;
  FAmount := 1;

  if not LuaSystem.Defined(['items',thingID]) then raise Exception.Create('Item "'+thingID+'" not found!');

  ReadStatistics( 'items' );

  FStats[ STAT_DURMAX ] := FStats[ STAT_DUR ];
  FStats[ STAT_DUR ]    := RandRange(1+(FStats[ STAT_DURMAX ] div 4),(3*FStats[ STAT_DURMAX ] div 4));

  with LuaSystem.GetTable( ['items', thingID] ) do
  try
    FName        := GetString('name');
    FGylph.ASCII := GetChar('pic');
    FGylph.Color := GetInteger('color');

    if isString('spell') then
      FSpell := LuaSystem.Get(['spells', GetString('spell'), 'nid']);

    FStats[ STAT_AC ] := RandRange(GetInteger('acmin',0),GetInteger('acmax',0));
    if  flags[ ifUnique ] then Include( FFlags, ifUnknown );
  finally
    Free;
  end;

  if (ChargesMax > 0) and (Charges = 0) then Charges := ChargesMax;
  if (ChargesMod = 0) then ChargesMod := 1;

  if ilvl = 0 then ilvl := Level;
  RunHook( Hook_OnCreate, [ilvl]  )
end;

function TItem.BookMagReq : Word;
var i: word;
begin
  i := game.player.spells[FSpell];
  BookMagReq := MagReq;
  while i>0 do begin BookMagReq := (BookMagReq*12)div 10; dec(i); end;
  if BookMagReq > 213 then BookMagReq := 255;
end;

function TItem.InvColor: TIOColor;
begin
  if ReqsMet( False ) then
    if flags[ ifMagic ] then exit(FColors[COLOR_MAGIC])
    else if flags[ ifUnique ] then exit(FColors[COLOR_UNIQUE])
    else exit(FColors[COLOR_NORMAL])
  else exit(FColors[COLOR_RED]);
end;

procedure TItem.Identify;
var V : Variant;
begin
  if not Flags[ ifUnknown ] then Exit;

  Exclude( FFlags, ifUnknown );

  if ifIndest in Fflags then
  begin
    FStats[ STAT_DUR ]    := 0;
    FStats[ STAT_DURMAX ] := 0;
  end;

  if ifUnique in FFlags then Exit;

  if PriceMul=0 then PriceMul:=1;
  if PriceMul>0
    then Price := Price * PriceMul+PriceMod
    else Price := Price div abs(PriceMul)+PriceMod;
end;

function TItem.GetPrice(PriceType: TPriceType): LongInt;
var iChargeCost : LongInt;
begin
  if PriceType = COST_IDENTIFY then Exit( 100 );
  if ifUnknown in FFlags then
     getPrice := LuaSystem.Get([ 'items', id, 'price' ])
  else
    getPrice := Price;

  if (FSpell > 0) and ((ChargesMax div ChargesMod)> 0) then
  begin
    iChargeCost := LuaSystem.Get(['spells',FSpell,'staff','charge_cost'], 0);
    if PriceType = COST_RECHARGE then
    begin
      getPrice:=LuaSystem.Get(['items',id,'price']);
      if ifSpellBound in FFlags
        then getPrice += iChargeCost*5
        else getPrice += iChargeCost*(5+(ChargesMax div ChargesMod))
    end
    else
    begin
      if not (ifSpellBound in FFlags) then
        case sgn(pricemul) of
           1: getPrice:=getPrice+iChargeCost*(Charges div ChargesMod) * pricemul;
          -1: getPrice:=getPrice+iChargeCost*(Charges div ChargesMod) div abs(pricemul);
          else
            getPrice:=getPrice+iChargeCost*(Charges div ChargesMod);
        end;
    end;
  end;
  Case PriceType of
    COST_SELL: Result:= max(getPrice div 4,1);
    COST_REPAIR:
                begin
                  if (FStats[ STAT_DURMAX ] = FStats[ STAT_DUR ]) or (FStats[ STAT_DURMAX ] = 0) then exit(0) else
                  if (ifUnknown in Fflags)or ([ifMagic, ifUnique]*Fflags=[]) then
                    getPrice:=(((100*(FStats[ STAT_DURMAX ]-FStats[ STAT_DUR ])) div FStats[ STAT_DURMAX ])*getPrice(COST_BUY)) div 100
                  else  //unidentified or non-magic
                    getPrice:=((((100*(FStats[ STAT_DURMAX ]-FStats[ STAT_DUR ])) div FStats[ STAT_DURMAX ])*getPrice(COST_BUY)*3) div 1000); //magical or unique
                  if getPrice > 0 then exit(max(1,getPrice div 2))
                  else if ([ifMagic, ifUnique]*Fflags = []) or (ifUnknown in Fflags) then exit(1)
                  else exit(0);
                end;
    COST_RECHARGE: if ChargesMax = 0 then exit(0) else
                getPrice:=(((100*(ChargesMax-Charges)) div ChargesMax) * getPrice) div 200;
  end;
end;

procedure TItem.Repair(RLevel: Byte);
begin
  if RLevel > 0 then
  repeat
    FStats[ STAT_DUR ]    += RLevel + Random(RLevel);
    FStats[ STAT_DURMAX ] := Max( FStats[ STAT_DURMAX ] - Max(1, Round(FStats[ STAT_DURMAX ] / (RLevel + 9))), 1 );
  until FStats[ STAT_DUR ] >= FStats[ STAT_DURMAX ];
  FStats[ STAT_DUR ] := FStats[ STAT_DURMAX ];
end;

procedure TItem.Recharge(RLevel: Byte);
begin
  if RLevel > 0 then
  repeat
    FStats[ STAT_CHARGES ] += Random(RLevel div LuaSystem.Get(['spells',FSpell,'book','level'],0))+1;
    dec(FStats[ STAT_CHARGESMAX ] );
  until FStats[ STAT_CHARGES ] >= FStats[ STAT_CHARGESMAX ];
  FStats[ STAT_CHARGES ] := FStats[ STAT_CHARGESMAX ];
end;

function TItem.GetSpellName : AnsiString;
var iColor : AnsiString = '';
    iReq   : word;
begin
  if FSpell = 0 then Exit('');
  with LuaSystem.GetTable( ['spells',FSpell] ) do
  try
    GetSpellName := getString('name');
    if ifUnique in Fflags
      then iReq := 0
      else iReq := getInteger('magic');
  finally
    Free;
  end;
  if iReq > Game.Player.getMag then
  begin
    GetSpellName := '@r'+GetSpellName;
    iColor := '@r';
  end
  else
  if Chargesmax > 0 then
  begin
         if (Charges*100 div Chargesmax) <= 50 then iColor := '@y'
    else if (Charges*100 div Chargesmax) <= 10 then iColor := '@r';
    GetSpellName += ' {'+iColor+inttostr(Charges)+'@>'+'/'+iColor+inttostr(Chargesmax)+'@>}';
  end;
end;

function TItem.GetStatusInfo1 : AnsiString;
function VS(l : LongInt) : string;
begin if l > 0 then Exit('+'+IntToStr(l)) else Exit(IntToStr(l)); end;
begin
  if ifUnknown in FFlags then Exit('Unidentified');
  Result := '';
  case SpdAtk of
    SPD_QUICK   : Result += 'Quick Attack, ';
    SPD_FAST    : Result += 'Fast Attack, ';
    SPD_FASTER  : Result += 'Faster Attack, ';
    SPD_FASTEST : Result += 'Fastest Attack, ';
  end;
  case SpdHit of
    SPD_FAST    : Result += 'Fast Recovery, ';
    SPD_FASTER  : Result += 'Faster Recovery, ';
    SPD_FASTEST : Result += 'Fastest Recovery, ';
  end;
  case SpdBlk of
    SPD_FAST    : Result += 'Fast Blocking, ';
  end;
  if (Str = Dex) and (Dex = Mag) and
     (Mag = Vit) and (Vit <>0) then
     Result += ('All Stats '+VS(Str))+', '
  else
  begin
    if Str  <> 0 then Result += ('Strength '+VS(Str))+', ';
    if Mag  <> 0 then Result += ('Magic '+VS(Mag))+', ';
    if Vit  <> 0 then Result += ('Vitality '+VS(Vit))+', ';
    if Dex  <> 0 then Result += ('Dexterity '+VS(Dex))+', ';
  end;
  if FStats[ STAT_VSDEMON  ] > 150 then Result += '+'+IntToStr(FStats[ STAT_VSDEMON  ] - 100)+'% Dmg vs Demons,';
  if FStats[ STAT_VSUNDEAD ] > 150 then Result += '+'+IntToStr(FStats[ STAT_VSUNDEAD ] - 100)+'% Dmg vs Undead,';
  if FStats[ STAT_VSANIMAL ] > 150 then Result += '+'+IntToStr(FStats[ STAT_VSANIMAL ] - 100)+'% Dmg vs Animals,';
  if FStats[ STAT_HPMOD ] <> 0 then Result += ('Life '+VS(FStats[ STAT_HPMOD ]))+', ';
  if FStats[ STAT_MPMOD ] <> 0 then Result += ('Mana '+VS(FStats[ STAT_MPMOD ]))+', ';
  if (FStats[ STAT_AC ] <> 0) and not(FIType in [TYPE_ARMOR, TYPE_HELM, TYPE_SHIELD]) then Result += VS(FStats[STAT_AC])+' AC, ';
  if DmgMod  <> 0 then Result += ('Damage '+VS(DmgMod))+', ';
  if FStats[ STAT_ACMODPRC ] <> 0 then Result += ('AC '+VS(FStats[ STAT_ACMODPRC ])+'%, ');
  if FStats[ STAT_TOHIT ] <> 0 then Result += ('ToHit '+VS(FStats[ STAT_TOHIT ])+'%, ');
  if DmgModPrc <> 0 then Result += ('Damage '+VS(DmgModPrc)+'%, ');
  if FStats[ STAT_LIGHTMOD ] <> 0 then Result += ('Light '+VS(LightMod)+'%, ');
  if FStats[ STAT_DMGTAKEN ] <> 0 then Result += VS(DmgTaken)+' Damage Taken, ';
  if FStats[ STAT_DURMOD ]>0 then Result += ' High Durability, '
  else if FStats[ STAT_DURMOD ]<0 then Result += ' Low Durability, ';
  if FStats[ STAT_CHARGESMOD ]>1 then Result += ' Extra Charges, ';
  if FStats[ STAT_SPELLLEVEL ]>0 then Result += VS(FStats[ STAT_SPELLLEVEL ])+' Spell Level, ';
  if FStats[ STAT_LIFESTEALMAX ]>0 then
    if FStats[ STAT_LIFESTEALMIN ] <> FStats[ STAT_LIFESTEALMAX ]
      then Result += (' Life Steal '+IntToStr(FStats[ STAT_LIFESTEALMIN ] div 10)+'-'+IntToStr(FStats[ STAT_LIFESTEALMAX ] div 10)+'%, ')
      else Result += (' Life Steal '+IntToStr(FStats[ STAT_LIFESTEALMAX ] div 10)+'%, ');
  if FStats[ STAT_MANASTEALMAX ]>0 then
    if FStats[ STAT_MANASTEALMIN ] <> FStats[ STAT_MANASTEALMAX ]
      then Result += (' Mana Steal '+IntToStr(FStats[ STAT_MANASTEALMIN ] div 10)+'-'+IntToStr(FStats[ STAT_MANASTEALMAX ] div 10)+'%, ')
      else Result += (' Mana Steal '+IntToStr(FStats[ STAT_MANASTEALMAX ] div 10)+'%, ');

  if (FStats[ STAT_RESFIRE ] > 0) and (FStats[ STAT_RESFIRE ] = FStats[ STAT_RESLIGHTNING ]) and (FStats[ STAT_RESFIRE ] = FStats[ STAT_RESMAGIC ]) then
    Result += (' Resist All +'+IntToStr(FStats[ STAT_RESFIRE ])+'%, ')
  else
  begin
    if FStats[ STAT_RESFIRE ]  > 0     then Result += (' Resist Fire +'+IntToStr(FStats[ STAT_RESFIRE ])+'%, ');
    if FStats[ STAT_RESMAGIC ] > 0     then Result += (' Resist Magic +'+IntToStr(FStats[ STAT_RESMAGIC ])+'%, ');
    if FStats[ STAT_RESLIGHTNING ] > 0 then Result += (' Resist Lightning +'+IntToStr(FStats[ STAT_RESLIGHTNING ])+'%, ');
  end;

  if FStats[ STAT_DMGLIGHTNINGMAX ] > 0 then
    if FStats[ STAT_DMGLIGHTNINGMAX ] = FStats[ STAT_DMGLIGHTNINGMIN ]
      then Result += (' Lightning Damage +'+IntToStr(FStats[ STAT_DMGLIGHTNINGMAX ])+', ')
      else Result += (' Lightning Damage +'+IntToStr(FStats[ STAT_DMGLIGHTNINGMIN ])+'-'+IntToStr(FStats[ STAT_DMGLIGHTNINGMAX ])+', ');
  if FStats[ STAT_DMGFIREMAX ] > 0      then
    if FStats[ STAT_DMGFIREMAX ] = FStats[ STAT_DMGFIREMIN ]
      then Result += (' Fire Damage +'+IntToStr(FStats[ STAT_DMGFIREMAX ])+', ')
      else Result += (' Fire Damage +'+IntToStr(FStats[ STAT_DMGFIREMIN ])+'-'+IntToStr(FStats[ STAT_DMGFIREMAX ])+', ');

  if ifTrapResist in Fflags then Result += ' Half Trap Dmg, ';
  if ifKnockback in Fflags  then Result += ' Knockback, ';

  if (length(Result) > 0) and (Result[length(Result)-1]=',') then delete(Result, length(Result)-1, 2);
end;

function TItem.GetStatusInfo2 : AnsiString;
var iMagReq : word;
begin
  Result := '';

  if FIType in [TYPE_HELM, TYPE_WEAPON, TYPE_ARMOR, TYPE_SHIELD, TYPE_BOW, TYPE_STAFF] then
    if (ifIndest in Fflags) and ( not ( ifUnknown in FFlags ) )
    then Result := 'Indestructible '
    else Result := 'Durability: '+inttostr(FStats[ STAT_DUR ])+'/'+inttostr(FStats[ STAT_DURMAX ]);

  if FIType = TYPE_BOOK
    then iMagReq := BookMagReq
    else iMagReq := MagReq;

  if (StrReq<>0) or (DexReq<>0) or (iMagReq<>0) then
  begin
    if not reqsmet(false) then
      Result += '@r';
    Result += ' Requires ';
    if StrReq<>0 then
    begin
      if StrReq>Game.Player.GetStr then Result += '@r';
      Result += 'STR:'+inttostr(StrReq);
      if (iMagReq<>0) or (DexReq<>0) then Result += '@> ';
    end;
    if iMagReq<>0 then
    begin
      if iMagReq>Game.Player.GetMag then Result += '@r';
      Result += 'MAG:'+inttostr(iMagReq);
      if (DexReq<>0) then Result += '@> ';
    end;
    if DexReq<>0 then
    begin
      if DexReq>Game.Player.GetDex then Result += '@r';
      Result += 'DEX:'+inttostr(DexReq)
    end;
  end;
end;

function TItem.GetName(outputType : TNameOutputType) : string;
begin
  if ifUnknown in Fflags then
    Result := LuaSystem.Get([ 'items', id, 'name' ])
  else
    Result := name;

  if FAmount > 1 then
  case outputType of
    TheName    : Exit(IntToStr(FAmount)+' '+Result);
    AName      : Exit('a pile of '+IntToStr(FAmount)+' '+Result);
    PlainName  : Exit(IntToStr(FAmount)+' '+Result);
  end;

  if FIType in [TYPE_ARMOR, TYPE_HELM, TYPE_SHIELD] then Result += ' ['+IntToStr(FStats[ STAT_AC ])+']';
  if FIType in [TYPE_WEAPON, TYPE_BOW, TYPE_STAFF]  then Result += ' ('+IntToStr(DmgMin)+'-'+IntToStr(DmgMax)+')';

  if ifUnique in Fflags then Result := Capitalized(Result);

  if FStats[ STAT_CHARGESMAX ] > 0 then Result +=' {'+inttostr(FStats[ STAT_CHARGES ])+'/'+inttostr(FStats[ STAT_CHARGESMAX ])+'}';

  case outputType of
    TheName    : if not Flags[ifUnique] then Result := 'the '+Result;
    AName      : if not Flags[ifUnique] then Result := 'a '+Result;
  end;
end;

function TItem.Compare ( aOther : TNode ) : Boolean;
begin
  if Color > TItem(aOther).Color then Exit( True );
  if Color < TItem(aOther).Color then Exit( False );
  if Ord( Picture ) > Ord( TItem(aOther).Picture ) then Exit( False );
  if Ord( Picture ) < Ord( TItem(aOther).Picture ) then Exit( True );
  Exit( False );
end;

function TItem.ReqsMet( isWorn : Boolean ) : Boolean;
var Stat : DWord;
    Req  : Integer;
begin
  if ifUnknown in FFlags then Exit( False );
  for Stat in BaseStatistics do
    if (Stat = STAT_MAG) and (IType = TYPE_BOOK) then
    begin
      if BookMagReq > Game.Player.getMag then Exit(False);
    end
    else
    begin
      Req := 0;
      case Stat of
        STAT_STR : Req := FStats[ STAT_MINSTR ];
        STAT_DEX : Req := FStats[ STAT_MINDEX ];
        STAT_MAG : Req := FStats[ STAT_MINMAG ];
        STAT_VIT : Req := FStats[ STAT_MINVIT ];
      end;

      Include( FFlags, ifUnknown );
      if Req > Game.Player.Statistics[ Stat ] then
        if Req > Game.Player.getStat( Stat ) then
        begin
          Exclude( FFlags, ifUnknown);
          Exit( False );
        end;
      Exclude( FFlags, ifUnknown);
    end;
  Exit( True );
end;

class procedure TItem.InitColors(aGraphicsMode: Boolean);
begin
  if aGraphicsMode then
  begin
    FColors[COLOR_NORMAL] := IOColor($f7, $e9, $b7);
    FColors[COLOR_MAGIC] := IOColor($48, $50, $b8);
    FColors[COLOR_UNIQUE] := IOColor($90, $88, $58);
    FColors[COLOR_RED] := IOColor($e5, $28, $17);
    Exit;
  end;
  FColors[COLOR_NORMAL] := LightGray;
  FColors[COLOR_MAGIC] := LightBlue;
  FColors[COLOR_UNIQUE] := Yellow;
  FColors[COLOR_RED] := Red;
end;


constructor TItem.CreateFromStream(ISt: TStream);
begin
  inherited CreateFromStream(ISt);
  Init;
  FIType     := ISt.ReadByte;
  if FIType = TYPE_GOLD then
  begin
    FAmount := ISt.ReadDWord;
    FVolume := ((FAmount-1) div GoldVolume)+1;
  end
  else
  begin
    FAmount  := 1;
    FSpell   := ISt.ReadByte;
  end;
end;

procedure TItem.WriteToStream(OSt: TStream);
begin
  inherited WriteToStream(OSt);
  OSt.WriteByte(FIType);
  if FIType = TYPE_GOLD then
  begin
    OSt.WriteDWord(FAmount);
    exit;
  end;
  OSt.WriteByte(FSpell);
end;


function lua_item_new(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
begin
  State.Init(L);
  State.Push( TItem.Create( State.ToString(1), State.ToInteger(2,0) ) );
  Result := 1;
end;

function lua_item_identify(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    it      : TItem;
begin
  State.Init(L);
  it := State.ToObject(1) as TItem;
  it.Identify;
  Result := 0;
end;

function lua_item_get_price(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    it      : TItem;
begin
  State.Init(L);
  it := State.ToObject(1) as TItem;
  State.Push(it.getPrice(TPriceType(State.ToInteger(2))));
  Result := 1;
end;

function lua_item_reqs_met(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    it      : TItem;
begin
  State.Init(L);
  it := State.ToObject(1) as TItem;
  State.Push(it.ReqsMet(State.ToBoolean(2)));
  Result := 1;
end;


function lua_item_repair(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    it      : TItem;
begin
  State.Init(L);
  it := State.ToObject(1) as TItem;
  if State.StackSize > 1 then
    it.Repair(State.ToInteger(2))
  else
    it.Repair();
  Result := 0;
end;

function lua_item_recharge(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    it      : TItem;
begin
  State.Init(L);
  it := State.ToObject(1) as TItem;
  if State.StackSize > 1 then
    it.Recharge(State.ToInteger(2))
  else
    it.Recharge();
  Result := 0;
end;

const lua_item_lib : array[0..6] of luaL_Reg = (
  ( name : 'identify';    func : @lua_item_identify),
  ( name : 'new';         func : @lua_item_new),
  ( name : 'get_price';   func : @lua_item_get_price),
  ( name : 'reqs_met';    func : @lua_item_reqs_met),
  ( name : 'repair';      func : @lua_item_repair),
  ( name : 'recharge';    func : @lua_item_recharge),
  ( name : nil;           func : nil; )
);

class procedure TItem.RegisterLuaAPI;
begin
  LuaSystem.Register( 'item', lua_item_lib );
end;

end.
