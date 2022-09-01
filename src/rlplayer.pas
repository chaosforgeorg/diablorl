{$include rl.inc}
// @abstract(Player class for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
// @created(January 17, 2005)

unit rlplayer;
interface
uses classes, vutil, vnode, rlglobal, rlnpc, rlconfig, rlitem, vrltools, vgenerics;

type TQuests = array[1..MaxQuests] of byte;
type TSpells = array[1..MaxSpells] of byte;
type TQuickSkills = array[1..MaxQuickSkills] of Byte;

const
  //Target mode for choosetarget - Look mode
  TM_LOOK = 1;
  //Target mode for choosetarget - Fire mode
  TM_FIRE = 2;

type TPlayerEnumerator = specialize TGNodeEnumerator<TItem>;

type

{ TQuickSkill }

TPlayer = class;

TSpellSource = ( CAST_SPELL, CAST_SKILL, CAST_SCROLL, CAST_STAFF );

TQuickSkill = object
  Name : string;
  Source : TSpellSource;
  Spell : byte;
  function getIcon(): char;
  procedure Init( aItem : TItem);
  procedure Init( aPlayer: TPlayer; aSpell : byte; isSkill: boolean = false);
  procedure Copy( aSource : TQuickSkill );
  procedure Reset();
  procedure InitFromStream( ISt : TStream );
  procedure WriteToStream( OSt : TStream );
end;

type

{ TPlayer }

TPlayer = class(TNPC)
     private
       FKlass   : byte;
       FEq      : TItemList;
       FExp     : DWord;
       FLevelUp : Boolean;
       FPoints  : Byte;
       FPortalLevel: AnsiString;
       FPortalCount: Byte;
       FPortalCell : Word;

       FSkill  : byte;
       // Current ready spell
       FSpell      : TQuickSkill;
       FSpellCost  : Byte;
       FSpells     : TSpells;
       FQuests     : TQuests;
       FQuickSlots : TItemList;
       FQuickSkills: TQuickSkills;
       //Selected Enemy
       FEnemy     : TUID;
       FTargetDir : TDirection;
       // Maximum depth reached
       FMaxDepth  : Byte;
       // Exact Kill counts:
       FKills      : TKillTable;
       FStatistics : TStatistics;

       FRunCommand   : Byte;
       FRunCount     : DWord;
       FRunWallCount : DWord;

       FTravelMode   : Boolean;
       FTravelTarget : TCoord2D;

       // Last shopping time
       FLastShop  : DWord;

       FVisibleEnemies : DWord;
       FLightStrength  : DWord;

       // if set to true, all Success, Emote and Fail messages are silent
       FSilentAction : Boolean;

     public
       property Stats : TStatistics read FStatistics;
       property Enemy : TUID read FEnemy write FEnemy;
       property LevelUp : boolean read FLevelUp write FLevelUp;
       property Spell: TQuickSkill read FSpell;
       property Kills : TKillTable read FKills;
       property Quests: TQuests read FQuests;
       property Skill: byte read FSkill write FSkill;
       property Spells: TSpells read FSpells;
       property SpellCost: byte read FSpellCost;
       property QuickSkills: TQuickSkills read FQuickSkills;
       property PortalCount: byte read FPortalCount write FPortalCount;
       property PortalCell: Word read FPortalCell write FPortalCell;
     public
       // Return enumerator
       function GetEnumerator : TPlayerEnumerator;
       // Overriden constructor
       constructor Create(const thingID :string);
       // Death procedure -- does all cleanup.
       procedure Die(iAttacker: TNPC = nil); override;
       procedure Displace( const new : TCoord2D ); override;
       // Command Act
       procedure doAct;
       // Command Travel;
       procedure doTravel;
       // QuickSlot view
       //procedure QsCallback(Choice: byte);
       //procedure doQuickSlot;
       //find the first free quickslot
       function  getFreeSlot : byte;
       // Command Pickup
       procedure doPickUp;
       // Spell menu
       //procedure doSpellBook;
       //procedure doQuickSkill;
       // perform firing
       procedure doFire;
       procedure FireArrow;
       // Cast spell
       function CastSpell() : Boolean;
       // Check if can cast the spell
       function CanCast(aSpell: byte; aSpellLevel: byte = 0; aSource : TSpellSource = CAST_SPELL ) : boolean;
       // Player action
       procedure Action; override;
       // Player Attack monster
       function Attack(NPC : TNPC; Ranged: boolean = false; SpellID : Byte = 0) : Boolean; override;
       // Block Attack
       function Block(npcAttacker : TNPC) : Boolean; override;
       // Block chance
       function  getBlock : LongInt;
       // Damage base
       function  getDmgBase : LongInt;
       // returns DmgMin of weapon {with Items and charbonus}
       function  getFullDmgMin : LongInt;
       // returns DmgMax of weapon  {with Items and charbonus}
       function  getFullDmgMax : LongInt;
       // returns AC {with Items}
       function  getAC : LongInt; override;
       // returns ToHit{with Items}
       function  getToHit : LongInt; override;
       // returns ToHit {with clvl and class bonus}
       function  getToHitMelee : LongInt;
       // returns ToHit {with clvl and class bonus}
       function  getToHitMagic : LongInt;
       // returns ToHit {with clvl and class bonus}
       function  getToHitRange(Distance : Integer) : LongInt;
       //returns attack speed with equipped weapon
       function getAtkSpeed : LongInt;
       // returns HPMax
       function  getLife : LongInt; override;
       function  getMana : LongInt;
       function  getStr : LongInt;
       function  getMag : LongInt;
       function  getDex : LongInt;
       function  getVit : LongInt;
       function  getStat( aStat : DWord ) : LongInt;
       function  getStatMax( aStat : DWord ) : LongInt;
       function  getGold : DWord;

       function  getItemFlag( aFlag : Byte ) : Boolean;
       function  getItemMaxBonus( aStat : DWord ) : LongInt;
       function  getItemSumBonus( aStat : DWord ) : LongInt;
       function  getLightStrength : Word;

       function getResist(aResStat: DWord): LongInt; override;

       procedure EquipmentHook( Hook : Byte; const aParams : array of const );
       // Takes care of the items.
       destructor Destroy; override;
       // Adds given amount of gold. Returns number of pieces that
       // didn't fit.
       function  addGold(Amount : DWord) : DWord;
       // Removes the given amount of gold if available, returns false if not
       function  removeGold(Amount : DWord) : Boolean;
       // Adds given amount of experience.
       procedure addExp(Amount : DWord);
       procedure durabilityCheck(Slot : Byte);
       procedure WriteMemorial;
       function  SlotName(slot : byte) : string;
       function  ItemToSlot(Item : TItem) : byte;
       function  ItemToEqSlot(Item : TItem) : byte;
       function  InvFull : Boolean;
       function  InvSize : Byte;
       function  InvVolume : Word;
       function  InvGold : TItem;
       // moves the item from anywhere to inventory
       function AddItem(aItem: TItem): byte;
       // Scrolls and Potions only -- uses the item and disposes of it.
       // Returns wether successful. If successful var argument set to nil.
       function  UseItem(item : TItem) : Boolean;
       //
       function CreateAutoTarget( aAISet : TAITypeSet; aRange : Integer ): TAutoTarget;
       //Targeting
       function  ChooseTarget( TargetMode : Byte = TM_LOOK; FireCmd : byte = COMMAND_LOOK ) : boolean;
       //Targeting
       function  ChooseDirection : boolean;
       //Targeting
       function ChooseSpellTarget(aSpell : byte) : boolean;
       procedure PlaySound(sID : string);
       //quick item slot handling
       procedure useQuickSlot( slot: byte );
       //quick skill slot handling
       procedure useQuickSkill( slot: byte );
       // Returns amount of visible enemies
       procedure ScanSurroundings( aRange : DWord );
       //Initialize before construction
       procedure Init;
       // Stream constructor
       constructor CreateFromStream( ISt : TStream ); override;
       // Stream writer
       procedure WriteToStream( OSt : TStream ); override;
       // Pathfinder function
       function passableCoord( const Coord : TCoord2D ) : boolean; override;

       // register lua functions
       class procedure RegisterLuaAPI;

       // Return a list of inventory items
       function GetInvList : TItemList;
       // Return a list of equipment items
       function GetEqList : TItemList;
       // Return a equipment item
       function GetEqItem( aSlot : Byte ) : TItem;
       // Return a quickslot item
       function GetQsItem( aSlot : Byte ) : TItem;

       // Always returns False.
       //
       // aText VFormatted with aParams is emoted. If Sound <> '' it is also played.
       function doFail( const aText : AnsiString; const aParams : array of Const; const aSound : AnsiString = '' ) : Boolean;

       // Always returns True.
       //
       // aText VFormatted with aParams is emoted. aCost is deducted from speedcount. If Sound <> '' it is also played.
       function Success( const aText : AnsiString; const aParams : array of Const; aCost : DWord = 0; const aSound : AnsiString = '' ) : Boolean;

       function TryWear( aItem : TItem ) : Boolean;
       function ActionAddToBackPack( aItem : TItem ) : Boolean;
       function ActionSwapToBackPack( aItem, bItem : TItem ) : Boolean;
       function ActionQuickslotItem( aItem : TItem; aSlot : Byte = 0 ) : Boolean;
       function ActionDrop( aItem : TItem ) : Boolean;
       function ActionWear( aItem : TItem; aSlot : Byte = 0  ) : Boolean;
       procedure Remove( aNode : TNode ); override;
       function IsQuickslot( aItem : TItem ) : Boolean;
       function IsEquipped( aItem : TItem ) : Boolean;
       function IsBackpack( aItem : TItem ) : Boolean;
       function GetAllKills : DWord;
       //Find a scroll with spell in inventory
       function FindScroll( aSpell: byte ): TItem;
       //Check if current spell is valid (has charges)
       procedure ValidateSpell();
     public
       property Equipment[ Slot : Byte ] : TItem read GetEqItem;
       property Quickslot[ Slot : Byte ] : TItem read GetQsItem;

     private
       FKillCount: DWord;
       // temporary
       function EqFindItem( aItem : TItem ) : Byte;
       // temporary
       function QsFindItem( aItem : TItem ) : Byte;
       // temporary
       function NilItem( aItem : TItem ) : Boolean;
       // temporary
       procedure SwapItem( var aItem1, aItem2 : TItem );
     published
       property dmgmin : LongInt read getFullDmgMin;
       property dmgmax : LongInt read getFullDmgMax;
       property ac     : LongInt read getAC;
       property tohit  : LongInt read getToHit;
       property hpmax  : LongInt read getLife;
       property str_full: LongInt read getStr;
       property mag_full: LongInt read getMag;
       property dex_full: LongInt read getDex;
       property vit_full: LongInt read getVit;

       property klass  : byte read FKlass;

       property exp    : DWord read FExp write FExp;
       property points : byte  read FPoints write FPoints;

       property mp     : LongInt read FStats[ STAT_MP ]    write FStats[ STAT_MP ];
       property mpmax  : LongInt read FStats[ STAT_MPMAX ] write FStats[ STAT_MPMAX ];

       property hpmod  : LongInt read FStats[ STAT_HPMOD ]  write FStats[ STAT_HPMOD ];
       property mpmod  : LongInt read FStats[ STAT_MPMOD ]  write FStats[ STAT_MPMOD ];

       property portallevel: AnsiString read FPortalLevel write FPortalLevel;
       property maxdepth   : byte read FMaxDepth    write FMaxDepth;
       property volume : Word  read InvVolume;
       property gold   : DWord read getGold;
       property kill_count: DWord read FKillCount;

     end;

const SlotNone       = 0;
      SlotFailHas2H  = 100;
      SlotFailWear2H = 101;
      SlotFailReq    = 102;
      SlotPotion     = 103;
      SlotScroll     = 104;
      SlotBook       = 105;
      SlotFailTown   = 106;

implementation
uses math, sysutils, vuid, vluasystem, rllevel, rlgame, vdebug, rllua, variants,
rlui, rlviews;

var
      MemorialText : Text;
      WritingMemorial: boolean = false;

{ TQuickSkill }

function TQuickSkill.getIcon: char;
begin
  case Source of
    CAST_SPELL, CAST_SKILL : Exit('@');
    CAST_SCROLL : Exit('?');
    CAST_STAFF : Exit('/');
  end;
end;

procedure TQuickSkill.Init(aItem : TItem);
begin
  Spell := aItem.Spell;
  case aItem.itype of
    TYPE_SCROLL : begin
                    Source := CAST_SCROLL;
                    Name := aItem.Name;
                  end;
    TYPE_STAFF : begin
                   Source := CAST_STAFF;
                   Name := aItem.GetSpellName();
                 end;
  end;
end;

procedure TQuickSkill.Init(aPlayer: TPlayer; aSpell: byte; isSkill: boolean = false);
begin
  Name := LuaSystem.Get(['spells', aSpell, 'name']);
  if isSkill then
    Source := CAST_SKILL
  else
  begin
    Source := CAST_SPELL;
    Name := Name + ' lvl ' + IntToStr(aPlayer.Spells[aSpell] + aPlayer.getItemSumBonus( STAT_SPELLLEVEL ));
  end;
  Spell := aSpell;
end;

procedure TQuickSkill.Copy(aSource: TQuickSkill);
begin
  Name := aSource.Name;
  Source := aSource.Source;
  Spell := aSource.Spell;
end;

procedure TQuickSkill.Reset;
begin
  Spell := 0;
end;

procedure TQuickSkill.InitFromStream(ISt: TStream);
begin
  Source := TSpellSource(ISt.ReadByte());
  Spell := ISt.ReadByte();
  Name := ISt.ReadAnsiString();
end;

procedure TQuickSkill.WriteToStream(OSt: TStream);
begin
  OSt.WriteByte(ord(Source));
  OSt.WriteByte(Spell);
  OSt.WriteAnsiString(Name);
end;

function TPlayer.ChooseTarget( TargetMode : Byte = TM_LOOK; FireCmd : byte = COMMAND_LOOK ) : boolean;
var Key : Byte;
    Dir : TDirection;
    iEnemy : TNPC;
    iAuto  : TAutoTarget;
begin
    FTarget := Position;
    iEnemy := nil;
    iAuto  := nil;
    if FEnemy <> 0 then iEnemy := UIDs.Get(FEnemy) as TNPC;

    if TargetMode <> TM_LOOK then
    begin
      iAuto := CreateAutoTarget( AIMonster, getLightStrength );
      if (iEnemy <> nil) and (iEnemy.Visible) and (not (iEnemy.AI in [AINPC, AIGolem])) then
        iAuto.PriorityTarget( iEnemy.Position );
      FTarget := iAuto.Current;
    end;
    if iEnemy = nil
      then FEnemy := 0
      else FEnemy := iEnemy.UID;

    UI.FocusCursor(Target);
    UI.ShowCursor;
  repeat
    UI.FocusCursor(Target);

    UI.UpdateStatus(Target);

    if TargetMode in [TM_FIRE] then
      if TLevel(Parent).isExplored(Target) then
        UI.MarkTile(Target, 'X', Red );
    Key := UI.GetCommand(COMMANDS_MOVE+[COMMAND_ESCAPE,COMMAND_SWITCHMODE,COMMAND_OK,FireCmd]);
    if Key in [COMMAND_ESCAPE, COMMAND_LOOK] then
    begin
      Target := ZeroCoord2D;
      UI.HideCursor;
      UI.MarkClear;
      FreeAndNil( iAuto );
      Exit(False);
    end;

    if (iAuto <> nil) and (Key = COMMAND_SWITCHMODE) then FTarget := iAuto.Next;

    if (Key in COMMANDS_MOVE) then
    begin
      Dir := CommandDirection(Key);
      if TLevel(Parent).isProperCoord(Target+Dir) then
        if ( TargetMode <> TM_FIRE ) or (Distance( FPosition, Target + Dir) < FLightStrength ) then
          FTarget += Dir;
    end;
    UI.MarkClear;
    if TargetMode = TM_LOOK then
      UI.Focus(Target);
  until Key in [FireCmd,COMMAND_OK];
  FreeAndNil( iAuto );

  if Position = Target then
  begin
    UI.Msg('Suicide? Too easy for you...');
    UI.HideCursor;
    exit(false);
  end;
  UI.HideCursor;
  Exit(True);
end;

function TPlayer.ChooseDirection: boolean;
var Key : Byte;
begin
  UI.Msg('Choose direction...');
  Key := UI.GetCommand(COMMANDS_MOVE+[COMMAND_ESCAPE]);
  if Key = COMMAND_ESCAPE
    then FTargetDir.code := 0
    else FTargetDir := CommandDirection(Key);
  Exit( FTargetDir.isProper );
end;

function TPlayer.ChooseSpellTarget(aSpell: byte): boolean;
var TargetType : Integer;
begin
  TargetType := LuaSystem.Get( ['spells',aSpell,'target'] );
  case TargetType of
    SPELL_DIRECTION : if not ChooseDirection then Exit(False);
    SPELL_TARGET    : if not ChooseTarget( TM_FIRE, COMMAND_CAST ) then Exit(False);
    else FTarget:=Position;
  end;
  Exit(True);
end;

//find the first free quickslot
function TPlayer.getFreeSlot: byte;
var Slot: byte;
begin
  for Slot:=1 to ITEMS_QS do
    if FQuickSlots[Slot] = nil then exit(Slot);
  exit(0);
end;

function TPlayer.SlotName(slot : byte) : string;
begin
  case Slot of
    SlotHead   : Exit('Head');
    SlotAmulet : Exit('Neck');
    SlotTorso  : Exit('Body');
    SlotRHand  : Exit('Wpn ');
    SlotLHand  : Exit('Shld');
    SlotRRing  : Exit('RRng');
    SlotLRing  : Exit('LRng');
  end;
end;

function TPlayer.ItemToSlot(Item : TItem) : byte;
begin
  if Item = nil then Exit(SlotNone);
  if not Item.ReqsMet( False ) then Exit(SlotFailReq);

  if Item.Flags[ ifTwoHanded ] then
    if (FEq[SlotLHand] = nil) then
      Exit(SlotRHand)
    else Exit(SlotFailWear2H);

  if Item.IType = TYPE_WEAPON then Exit(SlotRHand);
  if Item.IType = TYPE_BOW then Exit(SlotRHand);

  if Item.IType = TYPE_SHIELD then
    if FEq[SlotRHand] = nil then Exit(SlotLHand)
    else if FEq[SlotRHand].Flags[ifTwoHanded] then
      Exit(SlotFailHas2H)
    else Exit(SlotLHand);

  if Item.IType = TYPE_HELM   then Exit(SlotHead);
  if Item.IType = TYPE_ARMOR  then Exit(SlotTorso);
  if Item.IType = TYPE_AMULET then Exit(SlotAmulet);

  if Item.IType = TYPE_RING then
    if FEq[SlotRRing] = nil then Exit(SlotRRing) else
      if FEq[SlotLRing] = nil then Exit(SlotLRing) else
         Exit(SlotRRing);

  if Item.Flags[ifNotInTown] then
    if TLevel(Parent).Flags[ lfTown ] then Exit(SlotFailTown);
  if Item.IType = TYPE_SCROLL then Exit(SlotScroll);
  if Item.IType = TYPE_POTION then Exit(SlotPotion);
  if Item.IType = TYPE_BOOK   then Exit(SlotBook);
  Exit(SlotNone);
end;

function TPlayer.ItemToEqSlot ( Item : TItem ) : byte;
begin
  if Item = nil then Exit(SlotNone);
  if Item.Flags[ifTwoHanded] then
    Exit(SlotRHand);
  if Item.IType = TYPE_WEAPON then Exit(SlotRHand);
  if Item.IType = TYPE_BOW then Exit(SlotRHand);

  if Item.IType = TYPE_SHIELD then
    Exit(SlotLHand);
  if Item.IType = TYPE_HELM   then Exit(SlotHead);
  if Item.IType = TYPE_ARMOR  then Exit(SlotTorso);
  if Item.IType = TYPE_AMULET then Exit(SlotAmulet);

  if Item.IType = TYPE_RING then
    if FEq[SlotRRing] = nil then Exit(SlotRRing) else
      if FEq[SlotLRing] = nil then Exit(SlotLRing) else
         Exit(SlotRRing);
  Exit(SlotNone);
end;

function TPlayer.InvFull : Boolean;
begin
  Exit( InvSize >= ITEMS_INV );
end;

function TPlayer.InvSize : Byte;
var iItem : TItem;
begin
  InvSize := 0;
  for iItem in Self do
    if isBackpack( iItem ) then
      Inc( InvSize );
end;

function TPlayer.InvVolume : Word;
var iItem : TItem;
begin
  InvVolume := 0;
  for iItem in Self do
    if isBackpack( iItem ) then
      InvVolume += iItem.Volume;
end;

function TPlayer.InvGold : TItem;
var iItem : TItem;
begin
  for iItem in Self do
    if iItem.IType = TYPE_GOLD then
      Exit( iItem );
  Exit( nil );
end;

function TPlayer.getGold : DWord;
var slot : TItem;
begin
  slot := InvGold;
  if slot = nil then Exit(0) else Exit(slot.Amount);
end;


function TPlayer.getVit : LongInt;
begin
  Exit(getStat( STAT_VIT ));
end;

function TPlayer.getStr : LongInt;
begin
  Exit(getStat( STAT_STR ));
end;

function TPlayer.getMag : LongInt;
begin
  Exit(getStat( STAT_MAG ));
end;

function TPlayer.getDex : LongInt;
begin
  Exit(getStat( STAT_DEX ));
end;

function TPlayer.getStat( aStat : DWord ) : LongInt;
begin
  Exit(FStats[aStat]+getItemSumBonus(aStat));
end;

function TPlayer.getStatMax ( aStat : DWord ) : LongInt;
begin
  case aStat of
    STAT_VIT : Exit( FStats[ STAT_MAXVIT ] );
    STAT_STR : Exit( FStats[ STAT_MAXSTR ] );
    STAT_MAG : Exit( FStats[ STAT_MAXMAG ] );
    STAT_DEX : Exit( FStats[ STAT_MAXDEX ] );
  end;
  Exit(0);
end;

function TPlayer.getAC : LongInt;
var Count : DWord;
    Bonus : Integer;
    Value : Integer;
begin
  Value := 0;
  Bonus := 0;
  for Count := 1 to ITEMS_EQ do
    if FEq[Count] <> nil then
      if FEq[Count].ReqsMet( true ) then
      begin
        Value += FEq[Count].AC;
        Bonus += FEq[Count].ACModPrc;
      end;
  case FKlass of
    KlassWarrior,
    KlassRogue, KlassSorceror: Exit(max(0,(getDex div 5+Value*100+Bonus)div 100));
  end;
end;

// Block chance
function TPlayer.getBlock : LongInt;
begin
  case FKlass of
    KlassWarrior  : Exit(getDex+30);
    KlassRogue    : Exit(getDex+20);
    KlassSorceror : Exit(getDex+10);
  end;
end;


function TPlayer.getToHit : LongInt;
begin
  Exit(50 + getDex div 2);
end;

function TPlayer.getAtkSpeed : LongInt;
begin
  case FKlass of
    KlassWarrior : if FEq[SlotRHand]=nil then
                     if FEq[SlotLHand]=nil then
                       Exit(45)        //Bare hands
                     else Exit(45)      //Shield
                   else begin
                     if FEq[SlotRHand].flags[ifAxe] then exit(50);
                     if (TYPE_STAFF = FEq[SlotRHand].IType) then exit(55);
                     if (TYPE_BOW = FEq[SlotRHand].IType)then exit(55);
                     exit(45);
                   end;
    KlassRogue   : if FEq[SlotRHand]=nil then
                     if FEq[SlotLHand]=nil then
                       Exit(50)         //Bare hands
                     else Exit(50)      //Shield
                   else begin
                     if FEq[SlotRHand].flags[ifAxe] then exit(65);
                     if (TYPE_STAFF = FEq[SlotRHand].IType) then exit(55);
                     if (TYPE_BOW = FEq[SlotRHand].IType)then exit(35);
                     Exit(50);
                   end;
    KlassSorceror: if FEq[SlotRHand]=nil then
                     if FEq[SlotLHand]=nil then
                       Exit(45)     //Bare hands
                     else Exit(60)  //Shield
                   else begin
                     if FEq[SlotRHand].flags[ifAxe]   then exit(80);
                     if (TYPE_BOW = FEq[SlotRHand].IType)then exit(80);
                     Exit(60);
                   end;
  end;
end;

function TPlayer.getToHitMelee : LongInt;
begin
  case FKlass of
    KlassWarrior  : Exit(getToHit+Level+20+getItemSumBonus( STAT_TOHIT ) );
    KlassRogue    : Exit(getToHit+Level+getItemSumBonus( STAT_TOHIT ) );
    KlassSorceror : Exit(getToHit+Level+getItemSumBonus( STAT_TOHIT ) );
  end;
end;

function TPlayer.getToHitMagic : LongInt;
begin
  case FKlass of
    KlassWarrior  : Exit(50+getMag+getItemSumBonus( STAT_TOHIT ));
    KlassRogue    : Exit(50+getMag+getItemSumBonus( STAT_TOHIT ));
    KlassSorceror : Exit(50+getMag+getItemSumBonus( STAT_TOHIT )+20);
  end;
end;

function TPlayer.getToHitRange(Distance : Integer) : LongInt;
begin
  case FKlass of
    KlassWarrior  : Exit(Max(50+getDex+Level-((Distance*Distance) div 2)+10,0)+getItemSumBonus( STAT_TOHIT ));
    KlassRogue    : Exit(Max(50+getDex+Level-((Distance*Distance) div 2)+20,0)+getItemSumBonus( STAT_TOHIT ));
    KlassSorceror : Exit(Max(50+getDex+Level-((Distance*Distance) div 2)   ,0)+getItemSumBonus( STAT_TOHIT ));
  end;
end;

// returns HPMax
function TPlayer.getLife : LongInt;
begin
  getLife:= FStats[ STAT_HPMAX ];
  case FKlass of
    KlassWarrior  : FStats[ STAT_HPMAX ] := 2* FStats[ STAT_VIT ]
                                      + 2*getItemSumBonus(STAT_VIT)
                                      + getItemSumBonus( STAT_HPMOD )
                                      + 2*Level + 18;
    KlassRogue    : FStats[ STAT_HPMAX ] := 1*FStats[ STAT_VIT ]
                                      + Round(1.5*getItemSumBonus(STAT_VIT))
                                      + getItemSumBonus( STAT_HPMOD )
                                      + 2*Level+23;
    KlassSorceror : FStats[ STAT_HPMAX ] := 1*FStats[ STAT_VIT ]
                                      + getItemSumBonus( STAT_VIT )
                                      + getItemSumBonus( STAT_HPMOD )
                                      + Level+9;
  end;
  FStats[ STAT_HPMAX ] += FStats[ STAT_HPMOD ];
  if hp > 0 then
    FStats[ STAT_HP ]:=max(FStats[ STAT_HP ]+FStats[ STAT_HPMAX ]-getLife,1);
  Exit( FStats[ STAT_HPMAX ] );
end;

function TPlayer.getMana : LongInt;
begin
  getMana:=FStats[ STAT_MPMAX ];
  case FKlass of
    KlassWarrior  : FStats[ STAT_MPMAX ] := 1*FStats[ STAT_MAG ]
                                     + getItemSumBonus(STAT_MAG)
                                     + getItemSumBonus( STAT_MPMOD )
                                     + Level - 1;
    KlassRogue    : FStats[ STAT_MPMAX ] := 1*FStats[ STAT_MAG ]
                                     + Round(1.5*getItemSumBonus(STAT_MAG))
                                     + getItemSumBonus( STAT_MPMOD )
                                     + 2*Level + 5;
    KlassSorceror : FStats[ STAT_MPMAX ] := 2*FStats[ STAT_MAG ]
                                     + 2*getItemSumBonus(STAT_MAG)
                                     + getItemSumBonus( STAT_MPMOD )
                                     + 2*Level - 2;
  end;
  FStats[ STAT_MPMAX ] += FStats[ STAT_MPMOD ];
  FStats[ STAT_MP ]:=max(FStats[ STAT_MP ]+FStats[ STAT_MPMAX ]-getMana,1);
  Exit(FStats[ STAT_MPMAX ]);
end;

// returns Dmg
function TPlayer.getDmgBase : LongInt;
begin
  case FKlass of
     KlassWarrior   : if (FEq[SlotRHand]<>nil) and (TYPE_BOW = FEq[SlotRHand].IType) then
       exit(GetStr*level div 200) else exit(GetStr*level div 100);
     KlassSorceror  : if (FEq[SlotRHand]<>nil) and (TYPE_BOW = FEq[SlotRHand].IType) then
       exit(GetStr*level div 200) else exit(GetStr*level div 100);
     KlassRogue     : exit((GetStr+GetDex)*level div 200);
  end;
end;

function TPlayer.getFullDmgMin: LongInt;
var iMod  : LongInt;
    iBase : LongInt;
begin
  iBase := 1;
  if FEq[SlotRHand] <> nil then iBase := FEq[SlotRHand].dmgmin;
  iMod  := getItemSumBonus( STAT_DMGMODPRC );
  iBase := iBase + ( iBase * iMod ) div 100;
  Exit( getDmgBase + iBase + getItemSumBonus( STAT_DMGMOD ) );
end;

function TPlayer.getFullDmgMax: LongInt;
var iMod  : LongInt;
    iBase : LongInt;
begin
  iBase := 1;
  if FEq[SlotRHand] <> nil then iBase := FEq[SlotRHand].dmgmax;
  iMod  := getItemSumBonus( STAT_DMGMODPRC );
  iBase := iBase + ( iBase * iMod ) div 100;
  Exit( getDmgBase + iBase + getItemSumBonus( STAT_DMGMOD ) );
end;

function TPlayer.getItemFlag( aFlag : Byte ) : Boolean;
var iCount : DWord;
begin
  getItemFlag := False;
  for iCount := 1 to ITEMS_EQ do
    if FEq[iCount] <> nil then
      if FEq[iCount].ReqsMet( true ) then
        if FEq[iCount].Flags[ aFlag ] then Exit( True );
end;

function TPlayer.getItemMaxBonus ( aStat : DWord ) : LongInt;
var iCount : DWord;
begin
  getItemMaxBonus := 0;
  for iCount := 1 to ITEMS_EQ do
    if FEq[iCount] <> nil then
      if FEq[iCount].ReqsMet( true ) then
        getItemMaxBonus := Max(getItemMaxBonus, FEq[iCount].Statistics[aStat]);
end;

function TPlayer.getItemSumBonus ( aStat : DWord ) : LongInt;
var iCount : DWord;
begin
  getItemSumBonus := 0;
  for iCount := 1 to ITEMS_EQ do
    if FEq[iCount] <> nil then
      if (FEq[iCount].Statistics[aStat] <> 0) and FEq[iCount].ReqsMet( true ) then
        getItemSumBonus += FEq[iCount].Statistics[aStat];
end;

function TPlayer.getLightStrength : Word;
var Bonus : Integer;
begin
  Bonus := getItemSumBonus( STAT_LIGHTMOD );
  Exit( min( max(100 + Bonus, 40) div 10, 15 ) - 1 );
end;

function TPlayer.getResist(aResStat: DWord): LongInt;
begin
  Result:=inherited getResist(aResStat) + getItemSumBonus( aResStat );
  Exit( Min( Result, 75 ) );
end;

procedure TPlayer.EquipmentHook ( Hook : Byte; const aParams : array of const ) ;
var Count : DWord;
begin
  for Count := 1 to ITEMS_EQ do
    if FEq[Count] <> nil then
      if FEq[Count].HasHook( Hook ) and FEq[Count].ReqsMet( true ) then
        FEq[Count].RunHook( Hook, aParams )
end;

procedure TPlayer.Die(iAttacker: TNPC = nil);
begin
  UI.MainScreen.ClearBoth;
  PlaySound('71');
  UI.Msg('You die... Press <@<Enter@>>...');
  UI.Draw;
  UI.PressEnter;
  if iAttacker <> nil then
    FEnemy := iAttacker.UID;
  GameEnd := True;
end;

function TPlayer.UseItem(item : TItem) : Boolean;
begin

  if item.Flags[ ifNotInTown ] and TLevel(Parent).Flags[ lfTown ] then
  begin
    UI.Msg('Not in town!');
    Exit(False);
  end;
       if Item.IType = TYPE_POTION then UI.Msg('You drink '+item.GetName(TheName)+'.')
  else if Item.IType in [TYPE_SCROLL,TYPE_BOOK] then UI.Msg('You read '+item.GetName(TheName)+'.')
  else Exit(False);
       if Item.IType in [TYPE_SCROLL,TYPE_POTION] then UI.PlaySound(Item.Sound1)
  else UI.PlaySound('sfx/items/readbook.wav');

  case Item.IType of

    TYPE_BOOK   :
    begin
      with LuaSystem.GetTable( ['spells', Item.Spell] ) do
      try
        if FSpells[Item.Spell] < MaxSpellLvl then
        begin
          Inc( FSpells[Item.Spell] );
          FStats[ STAT_MP ] := Min( getMana, FStats[ STAT_MP ] + Call('cost',[1,Self]) );
        end;
      finally
        Free;
      end;
      Dec(FSpeedCount,SpdMov);
      FStatistics.Inc('books_used');
      FStatistics.Inc('items_used');
    end;

    TYPE_SCROLL :
    begin
      if not ChooseSpellTarget(Item.Spell) then
        Exit(False);
      if not doSpell( Item.Spell, Max(1,FSpells[Item.Spell]) ) then
        Exit(False);
      FStatistics.Inc('scrolls_used');
      FStatistics.Inc('items_used');
    end;

    TYPE_POTION :
    begin
      Item.RunHook( Hook_OnUse, [Self] );
      Dec(FSpeedCount,SpdMov);
      FStatistics.Inc('potions_used');
      FStatistics.Inc('items_used');
    end;

  end;
  item.Free;
  Exit(True);
end;

function TPlayer.CreateAutoTarget( aAISet : TAITypeSet; aRange: Integer ): TAutoTarget;
var iLevel : TLevel;
    iCoord : TCoord2D;
begin
  iLevel := TLevel(Parent);
  Result := TAutoTarget.Create( FPosition );
  for iCoord in NewArea( FPosition, aRange+1 ).Clamped( iLevel.Area ) do
    if iLevel.NPCs[ iCoord ] <> nil then
    with iLevel.NPCs[ iCoord ] do
      if (AI in aAISet) and (not Flags[ nfInvisible ]) and Visible then
        Result.AddTarget( iCoord );
end;


// Adds given amount of experience.
procedure TPlayer.addExp(Amount : DWord);
begin
  if Level = 50 then exit;
  FExp := FExp + Amount;
  if FExp >= ExpTable[Level+1] then
  begin
    UI.PlaySound('sfx/misc/levelup.wav');
    Inc( FStats[ STAT_LEVEL ] );
    if Level < 50 then Inc(FPoints,5);
    UI.Msg('You advance to @<level '+IntToStr(Level)+'@>!');
    FStats[ STAT_HP ] := getLife;
    FStats[ STAT_MP ] := getMana;
    FLevelUp := True;
  end;
end;

// Player Attack monster
function TPlayer.Attack(NPC : TNPC; Ranged : boolean = false; SpellID : Byte = 0) : Boolean;
var HitChance    : Integer;
    Damage       : Integer;
    aRanged      : boolean;
    iItem        : TItem;
    iDMin, iDMax : LongInt;
    iMax, iMin   : LongInt;
    iAmount      : LongInt;
    DmgType      : byte;
begin
  if NPC = nil then Exit;
  if NPC = self then Exit;
  aRanged:=Ranged;
  if not aRanged then
  begin
    if FEq[SlotRhand]<>nil then
      aRanged:=(TYPE_BOW = FEq[SlotRhand].IType);
    Dec(FSpeedCount,GetAtkSpeed- getItemMaxBonus( STAT_SPDATTACK ) );
  end;

  if NPC.Visible then
    FEnemy := NPC.UID;


  if not NPC.flags[ nfStatue ] then
  begin
    if aRanged then
      if SpellID = 0
        then HitChance := getToHitRange(Distance(Position, NPC.Position))
        else HitChance := getToHitMagic
    else begin
      HitChance := getToHitMelee;
      if (Random(2) = 0) then UI.PlaySound('sfx/misc/swing.wav')
      else UI.PlaySound('sfx/misc/swing2.wav');
    end;
    HitChance := HitChance-NPC.getAC;

    if HitChance < 5  then HitChance := 5;
    if HitChance > 95 then HitChance := 95;
    if Random(100) >= HitChance then
    begin
      if (NPC.Visible) then
        UI.Msg('You miss '+NPC.GetName(TheName)+'.');
      Exit(false);
    end;
  end;

  DmgType := DAMAGE_GENERAL;

  if SpellID = 0 then
  begin
    Damage := RandRange( getFullDmgMin, getFullDmgMax );
  end
  else // spell
  begin
    with LuaSystem.GetTable( ['spells',SpellID] ) do
    try
      DmgType:=getInteger('type');
      if isFunction('dmin')
        then iDMin := ProtectedCall('dmin',[FSpells[SpellID],Self])
        else iDMin := GetInteger('dmin');
      if isFunction('dmax')
        then iDMax := ProtectedCall('dmax',[FSpells[SpellID],Self])
        else iDMax:= GetInteger('dmax');

      Damage := RandRange( iDMin, iDMax );
    finally
      Free;
    end;
  end;
  // Critical hit
  if (not aRanged) and (FKlass = KlassWarrior) and (Random(100) < Level)
    then begin Damage := 2*Damage;
               UI.Msg('You criticaly hit '+NPC.GetName(TheName)+'.');
               end
    else UI.Msg('You hit '+NPC.GetName(TheName)+'.');

  if (SpellID = 0) and (FEq[SlotRHand] <> nil) then
  begin
    iItem := FEq[SlotRHand];
    if NPC.flags[nfUndead] and (iItem.Statistics[ STAT_VSUNDEAD ] <> 0)
      then Damage:= Damage * iItem.Statistics[ STAT_VSUNDEAD ] div 100;
    if NPC.flags[nfAnimal] and (iItem.Statistics[ STAT_VSANIMAL ] <> 0)
      then Damage:= Damage * iItem.Statistics[ STAT_VSANIMAL ] div 100;
    if NPC.flags[nfDemon] and (iItem.Statistics[ STAT_VSDEMON ] <> 0)
      then Damage:= Damage * iItem.Statistics[ STAT_VSDEMON ] div 100;
    Damage:=max(Damage,1);
  end;

  // Warning -- NPC may be invalid afterwards.
  if getItemFlag(ifKnockback) then
    NPC.Knockback(NewDirection(Position, NPC.Position));

  if NPC.ApplyDamage(Damage, DmgType,self) then NPC := nil;

  if (not aRanged) and (SpellID = 0) then
  begin
    iMax := getItemSumBonus( STAT_LIFESTEALMAX );
    if iMax > 0 then
    begin
      iMin := getItemSumBonus( STAT_LIFESTEALMIN );
      iAmount := RandRange( iMin, iMax );
      iAmount := Ceil((Damage*iAmount+500) / 1000 );
      if iAmount > 0
        then hp := min( hp + max( hp, 1 ), hpmax )
        else hp := max( hp - max( -hp, 1 ), 1 );
    end;

    iMax := getItemSumBonus( STAT_MANASTEALMAX );
    if iMax > 0 then
    begin
      iMin := getItemSumBonus( STAT_MANASTEALMIN );
      iAmount := RandRange( iMin, iMax );
      iAmount := Ceil((Damage*iAmount+500) / 1000 );
      if iAmount > 0
        then mp := min( mp + max( mp, 1 ), mpmax )
        else mp := max( mp - max( -mp, 1 ), 1 );
    end;
  end;

  if NPC <> nil then
  begin
    iMax  := getItemSumBonus( STAT_DMGFIREMAX );
    if iMax <> 0 then
    begin
      iMin := getItemSumBonus( STAT_DMGFIREMIN );
      if NPC.ApplyDamage( RandRange( iMin, iMax ), DAMAGE_FIRE, self ) then NPC := nil;
    end;
  end;

  if NPC <> nil then
  begin
    iMax := getItemSumBonus( STAT_DMGLIGHTNINGMAX );
    if iMax <> 0 then
    begin
      iMin := getItemSumBonus( STAT_DMGLIGHTNINGMIN );
      if NPC.ApplyDamage( RandRange( iMin, iMax ), DAMAGE_LIGHTNING, self ) then NPC := nil;
    end;
  end;

  if (not aRanged) and (SpellID = 0) then
  begin
    DurabilityCheck(SlotRHand);
  end;

  // Attack hit
  Exit(true);
end;

function TPlayer.Block(npcAttacker : TNPC) : Boolean;
var BlockChance : Word;
begin
    // If npcAttacker = nil this function returns the chance of blocking a trap
    // Rules for blocking: Jarulf 2.2.1
    // Note: "You can only block while standing still or while doing a melee attack."
    // TODO: Should we deny a fleeing player any chance to block?
    if (FRecovery = 0) then begin
      if ((FEq[SlotLhand] <> nil) and (FEq[SlotLhand].IType = TYPE_SHIELD)) then begin
        BlockChance := getBlock;
        if (npcAttacker <> nil) then
           BlockChance += 2*(Level-npcAttacker.Level);
        if (Random(100) < BlockChance) then begin
          UI.PlaySound('sfx/items/invsword.wav');
          if (npcAttacker = nil) then
              UI.Msg('You block the trap.')
          else
              UI.Msg('You block the blow of '+npcAttacker.GetName(TheName)+'.');
          FRecovery := 10;
          durabilityCheck(SlotLHand);
          Exit(true);
        end;
      end;
    end;
    // Attack was not blocked
    Exit(false);
end;

procedure TPlayer.durabilityCheck(Slot : Byte);
begin
  // Jarulf 3.7.1 - Losing durability
  // Special case for head/torso
  if Slot = slotTorso then begin
    if FEq[slotTorso] = nil then
      Slot := slotHead
    else if FEq[slotHead] <> nil then
      if Random(3)=0 then
        Slot := slotHead;
  end;
  if FEq[slot] = nil then Exit;
  if FEq[slot].flags[ ifIndest ] then exit;
  case slot of
    slotRHand : begin
                  if TYPE_BOW = FEq[Slot].IType then begin
                    if Random(40)=0 then FEq[slot].Dur:=FEq[slot].Dur-1;    //Bow
                  end else if Random(30)=0 then FEq[slot].Dur := FEq[slot].Dur - 1;
                  // If two weapons are wielded check both
                  if (FEq[slotLHand]<>nil)and(FEq[slotLHand].IType in [ TYPE_WEAPON, TYPE_STAFF ])
                    and (Random(30)=0) then FEq[slotLHand].Dur := FEq[slotLHand].Dur - 1;
                end;
    slotTorso, slotHead : if Random(4)<>0 then FEq[slot].Dur := FEq[slot].Dur - 1;
    slotLHand : if Random(10)=0 then FEq[slot].Dur := FEq[slot].Dur - 1;
  end;
  if FEq[slot].Dur = 0 then
  begin
    UI.Msg('Your '+FEq[slot].GetName(PlainName)+' breaks!');
    case FEq[slot].IType of
         TYPE_HELM: UI.PlaySound('sfx/items/hlmtfkd.wav');
         TYPE_ARMOR: UI.PlaySound('sfx/items/armrfkd.wav');
         TYPE_SHIELD: UI.PlaySound('sfx/items/shielfkd.wav');
    else
         UI.PlaySound('sfx/items/Swrdfkd.wav');
    end;
    FEq[slot].Free;
  end;
end;

procedure TPlayer.Init;
begin
  Game.Lua.RegisterPlayer(Self);

  with LuaSystem.GetTable( [ 'klasses', id ] ) do
  try
    FKlass := GetInteger('klassid');
    FStats[ STAT_SPDBLOCK ] := GetInteger('spdblk');
    FStats[ STAT_SPDMAGIC ] := GetInteger('spdmag');
    if IsNumber('spellcost') then FSpellCost:=GetInteger('spellcost') else FSpellCost:=100;
    if IsString('skill') then FSkill:=LuaSystem.Get(['spells',getString('skill'),'nid']) else FSkill := 0;
  finally
    Free;
  end;

  FTravelMode     := False;
  FTravelTarget   := NewCoord2D(1,1);
  FVisibleEnemies := 0;
  FLightStrength  := 0;
  FRunCommand     := 0;
  FRunCount       := 0;
  FRunWallCount   := 0;
  FTargetDir.code := 0;
  FLevelUp := (FPoints > 0);
end;

function TPlayer.GetEnumerator : TPlayerEnumerator;
begin
  GetEnumerator.Create(Self);
end;

constructor TPlayer.Create(const thingID :string);
var Count : byte;
begin
  Game.Player := Self;
  // Set other atributes and find given thingID
  inherited Create(thingID);

  FSilentAction := False;
  FSpell.Reset();
  FSkill := 0;
  FPoints := 0;
  FKills      := TKillTable.Create;
  FStatistics := TStatistics.Create;
  Init;
  FEq := TItemList.Create( ITEMS_EQ );
  FQuickSlots := TItemList.Create( ITEMS_QS );

  for Count := 1 to MaxSpells  do FSpells[Count] := 0;
  for Count := 1 to MaxQuests  do FQuests[Count] := 0;
  for Count := 1 to MaxQuickSkills do FQuickSkills[Count] := 0;

  with LuaSystem.GetTable( [ 'klasses', id ] ) do
  try
    FName := GetString('dname');
  finally
    Free;
  end;

  FStats[ STAT_HP ] := getLife;
  FStats[ STAT_MP ] := getMana;
  FSpell.Reset();

  FPortalLevel    := '';
  FPortalCount    := 0;
  FMaxDepth       := 0;
  FKillCount      := 0;
  FLastShop       := 0;
  FVisibleEnemies := 0;
  FLightStrength  := 0;
  FTravelMode     := False;
  FTravelTarget   := NewCoord2D(1,1);
  RunHook( Hook_OnCreate, [] );
end;

procedure TPlayer.doAct;
var Dir : TDirection;
begin
  UI.Msg('Choose direction...');
  UI.Draw;
  Dir := CommandDirection( UI.GetCommand );
  if Dir.isProper then
  begin
    if (ActivateCell(Position + Dir)) then
      Dec(FSpeedCount,SpdMov);
  end;
end;

procedure TPlayer.doTravel;
begin
  if FVisibleEnemies > 0 then
  begin
     UI.Msg('@<"I can''t do that while enemies are present!"@>');
     Exit;
  end;

  if UI.GetTravelDestination( FTravelTarget ) then
  begin
    if Distance( FPosition, FTravelTarget ) = 1 then
    begin
       UI.Msg('@<"I''m already here!"@>');
       Exit;
    end;

    if FPathfinder.Run( FPosition, FTravelTarget, 5000 ) then
      FTravelMode := True
    else
      UI.Msg('@<"I don''t know how to get there!"@>');
  end;
end;

procedure TPlayer.FireArrow;
begin
    UI.PlaySound('sfx/misc/bfire.wav');
    SendMissile(Target, mt_Arrow);
    Dec(FSpeedCount,GetAtkSpeed-getItemMaxBonus(STAT_SPDATTACK));
    DurabilityCheck(SlotRHand);
end;

procedure TPlayer.doFire;
begin
  if TLevel(Parent).Flags[ lfTown ] then
  begin
    UI.Msg('@<"That won''t work here"@>');
    PlaySound('41');
    Exit;
  end;

  if (FEq[SlotRhand] = nil) or ( not (TYPE_BOW = FEq[SlotRhand].IType) ) or ( not ( FEq[SlotRHand].ReqsMet( True ) ) ) then
  begin
    UI.Msg('You have no ranged weapon.');
    Exit;
  end;

  if ChooseTarget(TM_FIRE, COMMAND_FIRE) then FireArrow();
end;

function TPlayer.CastSpell(): Boolean;
var Cost       : DWord;
    slvl       : LongInt;
    TargetType : DWord;
    FromStaff  : boolean;
    SpellID    : byte;
    SpellLevel : byte;
    Item       : TItem;
begin
  SpellID := Spell.Spell;

  if (SpellID = 0) then Exit(false);

  if Spell.Source = CAST_SCROLL then
  begin
    Item := FindScroll(SpellID);
    if Item <> nil then
      Exit(UseItem(Item))
    else
    begin
      Spell.Reset();
      Exit(False);
    end;
  end;

  FromStaff := Spell.Source = CAST_STAFF;

  if FromStaff then
  begin
    SpellLevel := max(1, FSpells[SpellID]);
    Item := FEq[SlotRHand];
    if Item.Charges = 0 then
    begin
      Spell.Reset();
      Exit(false);
    end;
  end;

  if SpellLevel = 0 then
    slvl := FSpells[SpellID]
  else
    slvl := SpellLevel;
  slvl+=getItemSumBonus( STAT_SPELLLEVEL );

  if not CanCast(SpellID, slvl, Spell.Source) then Exit(False);

  with LuaSystem.GetTable( ['spells',SpellID] ) do
  try
    if FromStaff then
      if Item.flags[ ifUnique ] then
        Cost := 0
      else
        Cost := GetInteger( 'magic',0 )
    else
      Cost := max(LongInt(Call('cost',[20, Self])),(Call('cost',[slvl, Self])*FSpellCost)div 100);
    TargetType:= GetInteger( 'target' );
  finally
    Free;
  end;

  if not ChooseSpellTarget(SpellID) then Exit(False);

  if doSpell( SpellID, slvl ) then
  begin
    if SpellLevel = 0 then
      FStats[ STAT_MP ] -= Cost
    else if FromStaff then
    begin
      Item.Charges:=Item.Charges-1;
      if Item.Charges = 0 then
        Spell.Reset();
    end;
    Dec(FSpeedCount,FStats[ STAT_SPDMAGIC ]);
    Exit(True);
  end
  else
    Exit( False );
end;

function TPlayer.CanCast(aSpell: byte; aSpellLevel: byte = 0; aSource : TSpellSource = CAST_SPELL): boolean;
var TownSafe : boolean = false;
    ManaCost : Integer = 0;
    ReqMag   : Byte = 0;
begin
  if aSpell = 0 then
  begin
    UI.Msg('@<"I don''t have a spell ready."@>');
    PlaySound('34');
    Exit(False);
  end;

  with LuaSystem.GetTable( ['spells',aSpell] ) do
  try
    case aSource of
      // skill requires nothing
      // spell requires mana
      // scroll is checked when the item is used
      CAST_SPELL  : ManaCost := max(LongInt(Call('cost',[20, Self])),(Call('cost',[aSpellLevel, Self])*FSpellCost)div 100);
      CAST_STAFF  : if FEq[SlotRHand].flags[ ifUnique ] then
                      ReqMag := 0
                    else
                      ReqMag := GetInteger( 'magic',0 );
    end;
    TownSafe  := GetBoolean( 'townsafe' );
  finally
    Free;
  end;

  if (TLevel(Parent).Flags[ lfTown ]) and (not TownSafe) then
  begin
    UI.Msg('@<"I can''t cast that here."@>');
    PlaySound('27');
    Exit(False);
  end;

  if (ManaCost > FStats[ STAT_MP ]) then
  begin
    UI.Msg('@<"Not enough mana."@>');
    PlaySound('35');
    Exit(False);
  end;

  if (ReqMag > getMag) then
  begin
    UI.Msg('@<"I can''t cast that yet."@>');
    PlaySound('28');
    Exit(False);
  end;

  Exit(True);
end;

{
procedure TPlayer.QsCallback(Choice : Byte);
begin
  if not(Choice in [1..ITEMS_QS]) then exit;
  UI.UpdateStatus(FQuickSlots[Choice]);
end;
}
{
procedure TPlayer.doQuickSlot;
var Window: TQsWindow;
    Choice : word;

begin
  Window := TQsWindow.Create(UI.VUI);
  Choice :=Window.Run;
  FreeAndNil(Window);
  if Choice=0 then exit;
  case ItemToSlot(FQuickSlots[Choice]) of
    SlotPotion,
    SlotScroll    : begin
                      UseItem(FQuickSlots[Choice]);
                      exit;
                    end;
    SlotFailTown  : begin
                      UI.Msg('@<"I can''t cast that here"@>');
                      PlaySound('27');
                    end;
    else UI.Msg('What?');
  end;
  doQuickSlot;
end;
}
function TPlayer.addGold(Amount : DWord) : DWord;
var slot : TItem;
    rest : DWord;
begin
  slot := InvGold;
  if slot = nil then
  begin
    if InvVolume >= MaxVolume then Exit(Amount);
    if InvFull then Exit(Amount);
    slot := TItem.Create('gold');
    slot.Amount := Amount;
    Add( slot );
    exit(0);
  end;
  rest := GoldVolume-(slot.Amount mod GoldVolume);
  if rest = GoldVolume then rest := 0;
  if Amount <= rest then
  begin
    slot.Amount := slot.Amount + Amount;
    Exit(0);
  end;
  slot.Amount := slot.Amount + Rest;
  Dec(Amount,Rest);
  while Amount > 0 do
  begin
    if InvVolume >= MaxVolume then Exit(Amount);
    if Amount <= GoldVolume then
    begin
      slot.Amount := slot.Amount + Amount;
      slot.Volume := slot.Volume + 1;
      Exit(0);
    end;
    slot.Amount := slot.Amount + GoldVolume;
    slot.Volume := slot.Volume + 1;
    Dec(Amount,GoldVolume);
  end;
  Exit(0);
end;

function TPlayer.removeGold(Amount: DWord): Boolean;
var iGold : TItem;
begin
  if getGold < Amount then Exit(False);
  iGold := InvGold;
  iGold.Amount := iGold.Amount - Amount;
  if iGold.Amount = 0 then
      FreeAndNil( iGold )
  else
      iGold.Volume := ((iGold.Amount-1) div GoldVolume) + 1;
  Exit(True);
end;

//returns 0 if the item was placed into backpack
//1 if gold, 3 if quickslot, 255 if noroom, 254 if nil
function TPlayer.AddItem( aItem : TItem ) : byte;
var iGold : Word;
begin
  //check if the item is exist
  if aItem = nil then exit(254);
  //if it's gold
  if aItem.IType = TYPE_GOLD then
    begin
      igold := AddGold(aItem.Amount);
      if iGold = 0 then
      begin
        UI.Msg('You got '+aItem.GetName(TheName)+'.');
        Dec(FSpeedCount,SpdMov);
        FreeAndNil(aItem);
        Exit(1);
      end;
      Dec(FSpeedCount,SpdMov);
      aItem.Amount := igold;
      UI.Msg('You ran out of space in your backpack.');
      Result := 1;
    end
  //or it can be placed into quickslot
  else if (GetFreeSlot>0) and (aItem.IType in [TYPE_POTION, TYPE_SCROLL])and aItem.ReqsMet( False ) then
  begin
    Dec(FSpeedCount,SpdMov);
    Add( aItem );
    FQuickSlots[GetFreeSlot] := aItem;
    exit(2);
  end
//put it into backpack
  else if (InvSize < ITEMS_INV) and (InvVolume+aItem.Volume <= MaxVolume) then
    begin
      Add( aItem );
      Dec(FSpeedCount,SpdMov);
      Exit(0);
    end
  else Result := 255;
end;

procedure TPlayer.doPickUp;
var nItem: TItem;
var nSound: Byte;
begin
  nItem := TLevel(Parent).Items[Position];
  case AddItem(nItem) of
  0:    begin
          nItem.RunHook( Hook_OnPickUp, [] );
          UI.Msg('You put '+nItem.GetName(TheName)+' into your backpack.');
        end;
  2:    begin
          UI.Msg('You found '+nItem.GetName(AName)+'.');
        end;
  254:  UI.Msg('But there is nothing here!');
  255:  begin
          nSound := 14 + Random(3);
          case nSound of
          14: UI.Msg('@<"I can''t carry any more"@>');
          15: UI.Msg('@<"I have no room!"@>');
          16: UI.Msg('@<"Where would I put this?"@>');
          end;
          PlaySound(IntToStr(nSound));
        end;
  end;
end;

procedure TPlayer.Action;
var iKey   : Byte;
    iLevel : TLevel;
    iEnemy : TNPC;

   procedure TryMove( dir : TDirection );
   var NPC : TNPC;
   begin
     NPC := iLevel.NPCs[Position+dir];
     if NPC <> nil then
     begin
       FRunCommand := 0;
       if NPC.AI = AINPC then
       begin
         FStatistics.Inc('talk_count');
         NPC.RunHook( Hook_OnTalk, [] );
         FTravelMode := False;
       end else if NPC.AI = AIGolem then begin
         iLevel.Displace(Self,Position+Dir);
         Dec(FSpeedCount,SpdMov);
         NPC.Displace(Position+Dir.Reversed);
       end else if NPC.AI = AIGuardian then exit
       else if ((FEq[SlotRhand] <> nil) and (TYPE_BOW = FEq[SlotRhand].IType)) then begin
         Target := Position+dir;
         FireArrow();
       end else begin
         Dec(FSpeedCount,getAtkSpeed-getItemMaxBonus(STAT_SPDATTACK));
         Attack(NPC);
       end;
       Exit;
     end;

     if not (cfBlockMove in CellData[iLevel.Cell[Position+dir]].Flags) then
     begin
       iLevel.Displace(Self,Position+Dir); Dec(FSpeedCount,SpdMov);
       if (FRunCommand = 0) and (not FTravelMode) and Option_WalkSound then
         UI.PlaySound('sfx/misc/walk2.wav');
       Exit;
     end;
     FRunCommand := 0;
     if CellHook_OnAct in CellData[iLevel.Cell[Position+dir]].Hooks then
     begin
       ActivateCell(Position+Dir);
       Dec(FSpeedCount,SpdMov);
       if LevelChange then FTravelMode := False;
     end;
   end;

begin
  iLevel := TLevel(Parent);
  if FStats[ STAT_HP ]>GetLife then FStats[ STAT_HP ]:=GetLife;
  FLightStrength := getLightStrength;
  iLevel.RunVision(Position,FLightStrength);
  ScanSurroundings( FLightStrength );
  FKills.Update( Game.TurnCount );
  UI.Draw;
  iLevel.CellHook( CellHook_OnStep, Position, [] );

  // Portal possibility
  if LevelChange then
  begin
    Dec(FSpeedCount,50);
    Exit;
  end;

  iEnemy := nil;
  if FEnemy <> 0 then iEnemy := UIDs.Get(FEnemy) as TNPC;

  if (iEnemy <> nil) and ((not iEnemy.Visible) or iEnemy.Flags[ nfInvisible ]) then
  begin
    iEnemy := nil;
    FEnemy := 0;
  end;

  if iEnemy <> nil then
    UI.UpdateStatus(iEnemy)
  else if iLevel.Items[Position] <> nil then
  begin
    UI.Msg(iLevel.Items[Position].GetName(AName)+' is lying here.');
    UI.UpdateStatus(iLevel.Items[Position])
  end
  else
    UI.UpdateStatus(nil);

  ValidateSpell();

  UI.Draw;

  if FTravelMode and (FVisibleEnemies > 0) then FTravelMode := False;

  if FTravelMode then
  begin
    if FPathfinder.Start = FPathfinder.Stop then
    begin
      FTravelMode := False;
      if Distance( FPosition, FTravelTarget ) = 1 then
        TryMove( NewDirection( FPosition, FTravelTarget ) );
    end
    else
    begin
      FPathfinder.Start := FPathfinder.Start.Child;
      if FPathfinder.Start = nil then
        Exit;
      TryMove( NewDirection( FPosition, FPathfinder.Start.Coord ) );
    end;
    UI.Delay( Option_RunDelay );
    UI.WaitForAnimations;
    Exit;
  end;

  if FRunCommand <> 0 then
  begin
    if (GetWallCount <> FRunWallCount) or (FVisibleEnemies > 0) then
    begin
      FRunCommand := 0;
      Exit;
    end;
    iKey := FRunCommand;
  end
  else
    iKey := UI.GetCommand;

  if iKey in COMMANDS_MOVE then
    TryMove( CommandDirection( iKey ) )
  else if iKey in COMMANDS_RUN then
  begin
    if FRunCommand = 0 then
    begin
      FRunCommand   := iKey;
      FRunWallCount := GetWallCount;
    end;
    UI.Delay( Option_RunDelay );
    TryMove( CommandDirection( iKey ) )
  end
  else if iKey in COMMANDS_ATTACK then
  begin
    if iLevel.NPCs[ FPosition + CommandDirection( iKey ) ] <> nil then
      TryMove( CommandDirection( iKey ) )
    else
      Dec(FSpeedCount,SpdMov);
  end
  else case iKey of
    0 :;
    COMMAND_GODKEY     : if GodMode then TDiabloConfig(UI.Config).RunGodKey( UI.LastKeyCode );
    COMMAND_ESCAPE     :
      case UI.RunUILoop( TUIGameMenu.Create( UI.Root ) ) of
        GAMEMENU_HELP : UI.RunUILoop( TUIManualScreen.Create( UI.Root ) );
        GAMEMENU_QUIT : begin GameEnd := True; Dec(FSpeedCount,50); end;
        GAMEMENU_SAVE : begin GameEnd := True; Game.Save; Dec(FSpeedCount,50); end;
      end;
    COMMAND_ACT        : doAct;
    COMMAND_SWITCHMODE : doTravel;
    COMMAND_MESSAGES   : UI.ShowRecent;
    //COMMAND_SPELLS     : doQuickSkill;
    COMMAND_CAST       : CastSpell();
    COMMAND_LOOK       : ChooseTarget();
    COMMAND_FIRE       : doFire;
    COMMAND_WAIT       : Dec(FSpeedCount,SpdMov);
    COMMAND_PICKUP     : doPickUp;

    COMMAND_QUICKSLOT1..COMMAND_QUICKSLOT8 : UseQuickSlot(iKey-COMMAND_QUICKSLOT1+1);
{    COMMAND_QUICKSKILL1 ..
    COMMAND_QUICKSKILL4 : if QuickSkills[Key - COMMAND_QUICKSKILL1 + 1] > 0 then Spell:=QuickSkills[iKey - COMMAND_QUICKSKILL1 + 1];}
    else UI.Msg('Unknown command. Press @<Escape@> for menu and help file!');
  end;
  UI.WaitForAnimations;
end;

procedure TPlayer.WriteMemorial;
var iEnemy  : TNPC;
    iScore  : LongInt;
    iResult : AnsiString;
begin
  Assign( MemorialText, WritePath + 'mortem.txt' );
  Rewrite( MemorialText );
  WritingMemorial := true;
  iEnemy := nil;
  if FEnemy <> 0 then iEnemy := UIDs.Get( FEnemy ) as TNPC;
  iScore := LuaSystem.ProtectedCall([ 'player', 'write_memorial' ], [ Self, iEnemy ]);
  WritingMemorial := false;
  Close( MemorialText );

  iResult := 'died in '+Game.Level.Name;
  if iEnemy <> nil         then iResult := 'killed by '+iEnemy.GetName(AName);
  if Game.Level.Depth > 12 then iResult := 'reached Hell';
  Game.Persistence.Add( iScore, FName, Game.Player.Level, Game.Level.Name, LuaSystem.Get( ['klasses',FKlass,'name'] ), iResult );

  UI.ShowHOF;
end;

// Takes care of the items.
destructor TPlayer.Destroy;
begin
  FreeAndNil(FStatistics);
  FreeAndNil(FKills);
  inherited Destroy;
  FreeAndNil(FEq);
  FreeAndNil(FQuickSlots);
end;

procedure TPlayer.PlaySound(sID : string);
begin
     // TODO: Special case for wario/warior
     UI.PlaySound(FSound + sID + '.wav');
end;

procedure TPlayer.Displace( const new : TCoord2D );
begin
  inherited Displace(new);
end;

constructor TPlayer.CreateFromStream(ISt: TStream);
var Count : byte;
    iCount : DWord;
    tsob : set of byte; //temporary set of byte
  function ReadItem : TItem;
  begin
    if ISt.ReadByte = 0 then Exit( nil );
    ReadItem := TItem.CreateFromStream( ISt );
    Add( ReadItem );
  end;
begin
  inherited CreateFromStream(ISt);

  FEq := TItemList.Create( ITEMS_EQ );
  FQuickSlots := TItemList.Create( ITEMS_QS );
  FExp    := ISt.ReadDWord;
  FPoints := ISt.ReadByte;
  FEnemy  := ISt.ReadQWord;

  FSpell.InitFromStream( ISt );

  ISt.Read( FSpells,      SizeOf( FSpells ) );
  ISt.Read( FQuickSkills, SizeOf( FQuickSkills ) );

  ISt.Read(tsob, sizeof(tsob));
  for Count := 1 to LuaSystem.Get(['quests','__counter'])  do
    begin
      if Count in tsob then
        Game.Lua.SetValue( ['quests', Count, 'enabled'], true )
      else
        Game.Lua.SetValue( ['quests', Count, 'enabled'], false );
      FQuests[Count] := ISt.ReadByte;
    end;

  for iCount := 1 to ITEMS_EQ do FEq[ iCount ]         := ReadItem;
  for iCount := 1 to ITEMS_QS do FQuickSlots[ iCount ] := ReadItem;
  while ReadItem <> nil do;

  FKillCount     := ISt.ReadDWord;
  FMaxDepth      := ISt.ReadByte;
  FPortalLevel   := ISt.ReadAnsiString;
  FPortalCount   := ISt.ReadByte;
  FPortalCell    := ISt.ReadWord;
  FLastShop      := ISt.ReadDword;

  FKills      := TKillTable.CreateFromStream(ISt);
  FStatistics := TStatistics.CreateFromStream(ISt);
  Init;
end;

procedure TPlayer.WriteToStream(OSt: TStream);
var Count: byte;
    tsob : set of byte; //temporary set of byte
    iCount : DWord;
    iItem  : TItem;
  procedure WriteItem( aItem : TItem );
  begin
    if aItem = nil then
    begin
      Ost.WriteByte(0);
      Exit;
    end;
    Ost.WriteByte(1);
    aItem.WriteToStream( OSt );
  end;
begin
  inherited WriteToStream(OSt);

  OSt.WriteDWord(FExp);
  OSt.WriteByte(FPoints);
  OSt.WriteQWord(FEnemy);

  FSpell.WriteToStream(OSt);
  OSt.Write( FSpells,      SizeOf( FSpells ) );
  OSt.Write( FQuickSkills, SizeOf( FQuickSkills ) );

  tsob := [];
  for Count := 1 to LuaSystem.Get(['quests','__counter']) do
    if LuaSystem.Get(['quests', Count, 'enabled']) then
      include(tsob, Count);
  OSt.Write(tsob, sizeof(tsob));
  for Count := 1 to LuaSystem.Get(['quests','__counter']) do
      OSt.WriteByte(FQuests[Count]);

  for iCount := 1 to ITEMS_EQ do WriteItem( FEq[ iCount ] );
  for iCount := 1 to ITEMS_QS do WriteItem( FQuickSlots[ iCount ] );

  for iItem in Self do
    if isBackpack( iItem ) then
      WriteItem( iItem );
  WriteItem( nil );

  OSt.WriteDWord(FKillCount);
  OSt.WriteByte(FMaxDepth);
  OSt.WriteAnsiString(FPortalLevel);
  OSt.WriteByte(FPortalCount);
  OSt.WriteWord(FPortalCell);
  OSt.WriteDWord(FLastShop);

  FKills.WriteToStream(OSt);
  FStatistics.WriteToStream(OSt);
end;

function TPlayer.passableCoord ( const Coord : TCoord2D ) : boolean;
var iLevel : TLevel;
begin
  iLevel := Parent as TLevel;
  if not iLevel.isExplored( Coord ) then Exit( False );
  if (CellHook_OnAct in CellData[ iLevel.Cell[Coord] ].Hooks) and iLevel.HasTravelPoint( Coord ) then Exit( True );
  Result := inherited passableCoord ( Coord ) ;
end;

procedure TPlayer.useQuickSlot( slot: byte );
var iItem : TItem;
begin
  if not (slot in [1..8]) then exit;
  if FQuickSlots[slot] <> nil then
    UseItem(FQuickSlots[slot])
  else
    with TLevel(Parent) do
      if (Items[ Position ] <> nil) and (Items[ Position ].IType in [TYPE_POTION, TYPE_SCROLL]) then
      begin
        UI.Msg('You found '+Items[ Position ].GetName(AName)+'.');
        Dec(FSpeedCount,SpdMov);
        iItem := Items[ Position ];
        Add( iItem );
        FQuickSlots[slot] := iItem;
      end
      else
        UI.Msg('No quick item in slot '+IntToStr(slot)+'!');
end;

procedure TPlayer.useQuickSkill( slot: byte );
begin
{
  if not (slot in [1..4]) then exit;
  if FQuickSkills[slot] > 0 then
    FSpell:=FQuickSkills[slot];
}
end;

procedure TPlayer.ScanSurroundings( aRange : DWord );
var iCoord : TCoord2D;
    iLevel : TLevel;
    iCell  : DWord;
begin
  FVisibleEnemies := 0;
  iLevel := Parent as TLevel;
  if iLevel = nil then Exit;
  for iCoord in NewArea( FPosition, aRange ).Clamped( iLevel.Area ) do
    if iLevel.isVisible( iCoord ) then
    begin
      if iLevel.NPCs[iCoord] <> nil then
        with iLevel.NPCs[iCoord] do
           if (not isPlayer) and (AI in AIMonster) and Visible then
        Inc( FVisibleEnemies );
      if (cfTravelPoint in iLevel.GetTileFlags( iCoord ))
        and (not iLevel.HasTravelPoint( iCoord )) then
        begin
          iCell := iLevel.Cell[ iCoord ];
          if CellHook_OnTravelName in CellData[ iCell ].Hooks
            then iLevel.AddTravelPoint( iCoord, LuaSystem.ProtectedCall([ 'cells',CellData[iCell].id,CellHookNames[ CellHook_OnTravelName ] ], [iLevel] ) )
            else iLevel.AddTravelPoint( iCoord, CellData[ iCell ].Name );
        end;
    end;
end;

function TPlayer.GetInvList : TItemList;
var iItem  : TItem;
begin
  GetInvList := TItemList.Create( ITEMS_INV );
  for iItem in Self do
    if isBackpack( iItem ) then
      GetInvList.Push( iItem );
  GetInvList.Sort;
end;

function TPlayer.GetEqList : TItemList;
var aIndex : DWord;
begin
  GetEqList := TItemList.Create( ITEMS_EQ );
  for aIndex := 1 to ITEMS_EQ do
    GetEqList[ aIndex ] := FEq[ aIndex ];
end;

function TPlayer.GetEqItem ( aSlot : Byte ) : TItem;
begin
  if (aSlot > 0) and (aSlot <= ITEMS_EQ) then Exit( FEq[ aSlot ] );
  Exit( nil );
end;

function TPlayer.GetQsItem ( aSlot : Byte ) : TItem;
begin
  if (aSlot > 0) and (aSlot <= ITEMS_QS) then Exit( FQuickslots[ aSlot ] );
  Exit( nil );
end;

function TPlayer.doFail ( const aText : AnsiString; const aParams : array of const; const aSound : AnsiString ) : Boolean;
begin
  if FSilentAction then Exit( False );
  if aSound <> ''  then UI.PlaySound( aSound );
  if aText  <> ''  then UI.Msg( VFormat( aText, aParams ) );
  Exit( False );
end;

function TPlayer.Success ( const aText : AnsiString; const aParams : array of const; aCost : DWord; const aSound : AnsiString ) : Boolean;
begin
  if aCost <> 0    then Dec( FSpeedCount, aCost );
  if FSilentAction then Exit( True );
  if aSound <> ''  then UI.PlaySound( aSound );
  if aText <> ''   then UI.Msg( VFormat( aText, aParams ) );
  Exit( True );
end;

function TPlayer.TryWear ( aItem : TItem ) : Boolean;
var Slot : Byte;
begin
  Slot := ItemToSlot( aItem );
  case Slot of
    1..ITEMS_EQ    : Exit( True );
    SlotFailReq    : Exit( doFail( '@<"I can''t use this yet"@>', [], '13' ) );
    SlotFailHas2H  : Exit( doFail( 'Take off your two handed stuff first.', [] ) );
    SlotFailWear2H : Exit( doFail( 'You need two hands free for this.', [] ) );
    SlotFailTown   : Exit( doFail( '@<"I can''t use this here"@>', [], '27' ) );
  else
    Exit( doFail( 'What?', [] ) );
  end;
end;

function TPlayer.ActionAddToBackPack ( aItem : TItem ) : Boolean;
begin
  if aItem = nil then Exit( False );
  if InvFull or ( aItem.Volume + InvVolume > MaxVolume ) then Exit( doFail( 'You have no room in your inventory!',[] ) );
  Add( aItem );
  Exit( Success( 'You put @1 into your backpack.', [ aItem.GetName(TheName) ], SpdMov, aItem.Sound1 ) );
end;

function TPlayer.ActionSwapToBackPack( aItem, bItem : TItem ) : Boolean;
begin
  if bItem = nil then Exit( ActionAddToBackPack ( aItem ) );
  if aItem.Volume + InvVolume - bItem.Volume > MaxVolume then Exit( doFail( 'You have no room in your inventory!',[] ) );
  Exit( Success( 'You put @1 back into your backpack.', [ aItem.GetName(TheName) ], SpdMov, aItem.Sound1 ) );
end;

function TPlayer.ActionQuickslotItem ( aItem : TItem; aSlot : Byte = 0 ) : Boolean;
begin
  if aSlot > ITEMS_QS then Exit( False ); // throw?
  if aSlot = 0 then aSlot := GetFreeSlot;
  if aSlot = 0 then Exit( doFail( 'You have no free quickslots!',[] ) );
  if aItem <> nil then
  begin
    if not (aItem.IType in [TYPE_POTION, TYPE_SCROLL] ) then Exit( doFail( 'Not a quickslot item!',[] ) );
    if not aItem.ReqsMet( False ) then Exit( doFail( '@<"I can''t use this yet"@>', [], '13' ) );
  end;

  if FQuickSlots[aSlot] <> nil then
    if not ActionSwapToBackPack( FQuickSlots[aSlot], aItem ) then
      Exit;

  FQuickSlots[aSlot] := aItem;
  if aItem = nil then Exit( True );
  Exit( Success( 'You put @1 behind your belt.', [ aItem.GetName(TheName) ], SpdMov, aItem.Sound1 ) );
end;

function TPlayer.ActionDrop ( aItem : TItem ) : Boolean;
begin
  if (aItem = nil) then Exit( False );

  if aItem.Amount > 5000 then
  begin
    aItem.Amount := aItem.Amount - 5000;
    aItem.Volume := aItem.Volume - 1;
    aItem := TItem.Create('gold');
    aItem.Amount := 5000;
  end
  else
    NilItem( aItem );

  TLevel(Parent).Drop( aItem, FPosition );
  Exit( Success( 'You drop @1.', [ aItem.GetName(TheName) ], SpdMov ) );
end;

function TPlayer.ActionWear ( aItem : TItem; aSlot : Byte = 0 ) : Boolean;
begin
  if aSlot = 0 then
  begin
    aSlot := ItemToSlot( aItem );
    case aSlot of
      SlotFailReq   : Exit( doFail( '@<"I can''t use this yet"@>', [], '13' ) );
      SlotFailHas2H : Exit( doFail( 'Take off your two handed stuff first.', [] ) );
      SlotFailWear2H: Exit( doFail( 'You need two hands free for this.', [] ) );
      SlotFailTown  : Exit( doFail( '@<"I can''t use this here"@>', [], '27' ) );
      SlotPotion,
      SlotScroll,
      SlotBook      : Exit( UseItem( aItem ) );
      1..ITEMS_EQ   : ;
    else
      Exit( doFail( 'What?',[] ) );
    end;
  end;
  if aSlot > ITEMS_EQ then Exit( False ); // throw?
  if aSlot = 0 then Exit( doFail( 'What?',[] ) );
  if aItem <> nil then
    if not TryWear( aItem ) then Exit( False );

  if FEq[aSlot] <> nil then
    if not ActionSwapToBackPack( FEq[aSlot], aItem ) then
      Exit( False );

  NilItem( aItem );
  FEq[aSlot] := aItem;
  if aItem = nil then Exit( True );
  if aSlot in [SlotRHand, SlotLHand] then
    Exit( Success( 'You wield @1.', [ aItem.GetName(TheName) ], SpdMov, aItem.Sound1 ) )
  else
    Exit( Success( 'You wear @1.', [ aItem.GetName(TheName) ], SpdMov, aItem.Sound1 ) );
end;

procedure TPlayer.Remove ( aNode : TNode ) ;
var iCount : DWord;
begin
  for iCount := 1 to ITEMS_EQ do
    if FEq[ iCount ] = aNode then
      FEq[ iCount ] := nil;
  for iCount := 1 to ITEMS_QS do
    if FQuickSlots[ iCount ] = aNode then
      FQuickSlots[ iCount ] := nil;
  inherited Remove ( aNode );
end;

function TPlayer.IsQuickslot ( aItem : TItem ) : Boolean;
var iCount : Byte;
begin
  for iCount := 1 to ITEMS_QS do
    if FQuickSlots[ iCount ] = aItem then Exit( True );
  Exit( False );
end;

function TPlayer.IsEquipped ( aItem : TItem ) : Boolean;
var iCount : Byte;
begin
  for iCount := 1 to ITEMS_EQ do
    if FEq[ iCount ] = aItem then Exit( True );
  Exit( False );
end;

function TPlayer.IsBackpack ( aItem : TItem ) : Boolean;
begin
  Exit( not ( IsQuickSlot( aItem ) or IsEquipped( aItem ) ) );
end;

function TPlayer.GetAllKills: DWord;
begin
  Exit( FKills.Count );
end;

function TPlayer.FindScroll( aSpell: byte ): TItem;
var iItem: TItem;
begin
  for iItem in Self do
    if iItem.iType = TYPE_SCROLL then
      if iItem.spell = aSpell then Exit(iItem);
  Exit(nil);
end;

procedure TPlayer.ValidateSpell;
begin
  case Spell.Source of
    CAST_STAFF :
    begin
      if Equipment[SlotRHand] = nil
        then Spell.Reset()
      else if Equipment[SlotRHand].Charges = 0
        then Spell.Reset()
    end;
    CAST_SCROLL :
    begin
      if FindScroll(Spell.Spell) = nil then
        Spell.Reset();
    end;
  end;

end;

function TPlayer.EqFindItem ( aItem : TItem ) : Byte;
var iCount : Byte;
begin
  for iCount := 1 to ITEMS_EQ do
    if FEq[ iCount ] = aItem then Exit( iCount );
  Exit( 0 );
end;

function TPlayer.QsFindItem ( aItem : TItem ) : Byte;
var iCount : Byte;
begin
  for iCount := 1 to ITEMS_QS do
    if FQuickSlots[ iCount ] = aItem then Exit( iCount );
  Exit( 0 );
end;

function TPlayer.NilItem ( aItem : TItem ) : Boolean;
var Slot : Byte;
begin
  NilItem := False;
  Slot := EqFindItem( aItem );
  if Slot <> 0 then
  begin
    FEq[Slot] := nil;
    NilItem := True;
  end;
  Slot := QsFindItem( aItem );
  if Slot <> 0 then
  begin
    FQuickSlots[Slot] := nil;
    NilItem := True;
  end;
end;

procedure TPlayer.SwapItem ( var aItem1, aItem2 : TItem ) ;
var temp : TItem;
begin
  Temp   := aItem1;
  aItem1 := aItem2;
  aItem2 := Temp;
end;

function lua_player_spell_get(L: Plua_State): Integer; cdecl;
var iState  : TRLLuaState;
    iPlayer : TPlayer;
begin
  iState.Init(L);
  iPlayer := iState.ToObject(1) as TPlayer;
  iState.Push(iPlayer.Spells[iState.ToInteger(2)]);
  Result := 1;
end;

function lua_player_spell_set(L: Plua_State): Integer; cdecl;
var iState   : TRLLuaState;
    iPlayer  : TPlayer;
    iSpellID : DWord;
begin
  iState.Init(L);
  iPlayer  := iState.ToObject(1) as TPlayer;
  iSpellID := iState.ToInteger(2);
  iPlayer.FSpells[iSpellID] := iState.ToInteger(3);
  if iPlayer.Spells[iSpellID] = 0 then
    if iPlayer.FSpell.Spell = iSpellID then
      iPlayer.FSpell.Reset();
  Result := 0;
end;

function lua_player_add_gold(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  State.Push( LongInt( player.addGold( State.ToInteger(2) ) ) );
  Result := 1;
end;

function lua_player_add_exp(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  Player.addExp( State.ToInteger(2) );
  Result := 0;
end;


function lua_player_remove_gold(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  State.Push( player.removeGold( State.ToInteger(2) ) );
  Result := 1;
end;

function lua_player_quest_set(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  player.FQuests[State.ToInteger(2)] := State.ToInteger(3);
  Result := 0;
end;

function lua_player_quest_get(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  State.Push( player.Quests[ State.ToInteger(2) ] );
  Result := 1;
end;

function lua_player_summon_portal (L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  player.PortalCount := State.ToInteger(2);
  Result := 0;
end;

function lua_player_play_sound(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  player.PlaySound(State.ToString(2));
  Result := 0;
end;

function lua_player_add_item(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Player : TPlayer;
    Item   : TItem;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  if State.IsTable(2) then
    Item := State.ToObject(2) as TItem
  else
    Item := TItem.Create(State.ToString(2));
  State.Push( Player.AddItem(Item) < 254 );
  Result := 1;
end;

function lua_player_get_item(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Player : TPlayer;
    iItem  : TItem;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  iItem := Player.FindChild( State.ToString(2) ) as TItem;
  State.Push( iItem );
  Result := 1;
end;

function lua_player_eq_get(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  State.Push( Player.Equipment[State.ToInteger(2)] );
  Result := 1;
end;

function lua_player_eq_set(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Player : TPlayer;
    Item   : TItem;
    Slot   : Word;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  Slot := State.ToInteger(2);
  if Slot = 0 then exit(0);
  Item := State.ToNewItem(3);

  Player.FEq[slot].Free;
  if Item <> nil then
  begin
    Player.Add( Item );
    Player.FEq[slot] := Item;
  end;
  Result := 0;
end;

function lua_player_qs_get(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  State.Push( Player.QuickSlot[State.ToInteger(2)] );
  Result := 1;
end;

function lua_player_qs_set(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Player : TPlayer;
    Item   : TItem;
    Slot   : Word;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  Slot := State.ToInteger(2);
  if Slot = 0 then exit(0);
  Item := State.ToNewItem(3);

  Player.FQuickSlots[slot].Free;
  if Item <> nil then
  begin
    Player.Add( Item );
    Player.FQuickSlots[slot] := Item;
  end;
  Result := 0;
end;

function lua_player_exit(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  LevelChange := True;
  Game.NextLevelID := State.ToString(2);
  Game.StairNumber := State.ToID(3);
    if Game.StairNumber = 0 then raise EException.Create( 'Cell 0! at exit');

  Dec(Player.FSpeedCount,50);
  Result := 0;
end;

function lua_player_memorial_print(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
begin
  State.Init(L);
  if not WritingMemorial then
    raise Exception.Create('player:memorial_print called in wrong place!');
  WriteLn( MemorialText, UI.Strip( State.ToString( 2 ) ) );
  Result := 0;
end;

function lua_player_memorial_dumpmsg(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Count  : DWord;
begin
  State.Init(L);
  Count  := State.ToInteger(2);
  if not WritingMemorial then
    raise Exception.Create('player:memorial_dumpmsg called in wrong place!');
  UI.MsgDump( MemorialText, Count );
  Result := 0;
end;

function lua_player_slot_name(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  State.Push( Player.SlotName(State.ToInteger(2)) );
  Result := 1;
end;

function lua_player_is_backpack(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Player : TPlayer;
    Item   : TItem;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  Item := State.ToObject(2) as TItem;
  State.Push( Player.isBackpack( Item ) );
  Result := 1;
end;

function lua_player_get_kills(L: Plua_State): Integer; cdecl;
var State  : TRLLuaState;
    Player : TPlayer;
begin
  State.Init(L);
  Player := State.ToObject(1) as TPlayer;
  State.Push( LongInt( Player.Kills.Get( State.ToString( 2, '' ) ) ) );
  Result := 1;
end;

const lua_player_lib : array[0..21] of luaL_Reg = (
  ( name : 'get_item';         func : @lua_player_get_item),
  ( name : 'spell_get';        func : @lua_player_spell_get),
  ( name : 'spell_set';        func : @lua_player_spell_set),
  ( name : 'add_gold';         func : @lua_player_add_gold),
  ( name : 'add_exp';          func : @lua_player_add_exp),
  ( name : 'remove_gold';      func : @lua_player_remove_gold),
  ( name : 'quest_get';        func : @lua_player_quest_get),
  ( name : 'quest_set';        func : @lua_player_quest_set),
  ( name : 'summon_portal';    func : @lua_player_summon_portal),
  ( name : 'play_sound';       func : @lua_player_play_sound),
  ( name : 'add_item';         func : @lua_player_add_item),
  ( name : 'eq_get';           func : @lua_player_eq_get),
  ( name : 'eq_set';           func : @lua_player_eq_set),
  ( name : 'qs_get';           func : @lua_player_qs_get),
  ( name : 'qs_set';           func : @lua_player_qs_set),
  ( name : 'exit';             func : @lua_player_exit),
  ( name : 'slot_name';        func : @lua_player_slot_name),
  ( name : 'is_backpack';      func : @lua_player_is_backpack),
  ( name : 'memorial_print';   func : @lua_player_memorial_print),
  ( name : 'memorial_dumpmsg'; func : @lua_player_memorial_dumpmsg),
  ( name : 'get_kills';        func : @lua_player_get_kills),
  ( name : nil;                func : nil; )
);


class procedure TPlayer.RegisterLuaAPI;
begin
  LuaSystem.Register( 'player', lua_player_lib );
end;

end.
