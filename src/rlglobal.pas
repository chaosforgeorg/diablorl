{$include rl.inc}
// @abstract(Globals for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
// @created(January 17, 2005)
//
// This unit holds global definiotions for the RL. No functions nor
// procedures should be here -- just constants and variables.

unit rlglobal;
interface
uses sysutils, vrltools, vutil, vnode;

const ConfigurationPath : AnsiString = '';
      DataPath          : AnsiString = '';
      SaveFilePath      : AnsiString = '';
      SoundPath         : AnsiString = '';

type TNameOutputType = (TheName,AName,PlainName);
type TPriceType  = (COST_NONE, COST_BUY, COST_SELL, COST_REPAIR, COST_RECHARGE, COST_IDENTIFY );

type TAITypeSet = set of byte;

type TTextAlign  = (AlignLeft, AlignCenter, AlignRight);

const STAT_LEVEL        = 0;
      STAT_HP           = 1;
      STAT_HPMAX        = 2;
      STAT_HPMOD        = 3;
      STAT_MP           = 4;
      STAT_MPMAX        = 5;
      STAT_MPMOD        = 6;
      STAT_EXPVALUE     = 7;

      STAT_SPDATTACK    = 8;
      STAT_SPDMOVE      = 9;
      STAT_SPDHIT       = 10;
      STAT_SPDBLOCK     = 11;
      STAT_SPDMAGIC     = 12;

      STAT_DMGMIN       = 13;
      STAT_DMGMAX       = 14;
      STAT_DMGMOD       = 15;
      STAT_DMGMODPRC    = 16;

      STAT_STR          = 17;
      STAT_DEX          = 18;
      STAT_MAG          = 19;
      STAT_VIT          = 20;

      STAT_MINSTR       = 21;
      STAT_MINDEX       = 22;
      STAT_MINMAG       = 23;
      STAT_MINVIT       = 24;

      STAT_MAXSTR       = 25;
      STAT_MAXDEX       = 26;
      STAT_MAXMAG       = 27;
      STAT_MAXVIT       = 28;

      STAT_AC           = 29;
      STAT_ACMODPRC     = 30;
      STAT_TOHIT        = 31;

      STAT_DUR          = 32;
      STAT_DURMOD       = 33;
      STAT_DURMAX       = 34;

      STAT_CHARGES      = 35;
      STAT_CHARGESMOD   = 36;
      STAT_CHARGESMAX   = 37;

      STAT_PRICE        = 38;
      STAT_PRICEMOD     = 39;
      STAT_PRICEMUL     = 40;

      STAT_SPELLLEVEL   = 41;
      STAT_LIGHTMOD     = 42;
      STAT_DMGTAKEN     = 43;

      STAT_LIFESTEALMIN = 44;
      STAT_LIFESTEALMAX = 45;
      STAT_MANASTEALMIN = 46;
      STAT_MANASTEALMAX = 47;

      STAT_VSUNDEAD     = 48;
      STAT_VSDEMON      = 49;
      STAT_VSANIMAL     = 50;

      STAT_RESFIRE      = 51;
      STAT_RESLIGHTNING = 52;
      STAT_RESMAGIC     = 53;

      STAT_DMGFIREMIN      = 54;
      STAT_DMGFIREMAX      = 55;
      STAT_DMGLIGHTNINGMIN = 56;
      STAT_DMGLIGHTNINGMAX = 57;

      STAT_MAX          = 57;

type TStatistics = array[0..STAT_MAX] of LongInt;
const StatisticsIDs : array[0..STAT_MAX] of AnsiString = (
      'level', 'hp','hpmax','hpmod','mp','mpmax','mpmod', 'expvalue', 'spdatk', 'spdmov', 'spdhit', 'spdblk', 'spdmag',
      'dmgmin', 'dmgmax', 'dmgmod', 'dmgmodprc',
      'str', 'dex', 'mag', 'vit',
      'minstr', 'mindex', 'minmag', 'minvit',
      'maxstr', 'maxdex', 'maxmag', 'maxvit',
      'ac', 'acmodprc', 'tohit',
      'durability', 'durmod', 'durmax',
      'charges', 'chargesmax', 'chargesmod',
      'price', 'pricemod', 'pricemul',
      'spelllevel','lightmod','dmgtaken',
      'lifestealmin','lifestealmax','manastealmin','manastealmax',
      'vsundead','vsdemon','vsanimal',
      'resfire','reslightning','resmagic',
      'dmgfiremin','dmgfiremax','dmglightningmin','dmglightningmax' );

      BaseStatistics : set of Byte = [ STAT_STR, STAT_DEX, STAT_MAG, STAT_VIT ];

const Hook_OnCreate     = 0;
      Hook_OnEnter      = 1;
      Hook_OnKillAll    = 2;
      Hook_OnAttack     = 3;
      Hook_OnBroadcast  = 4;
      Hook_OnUse        = 5;
      Hook_OnTalk       = 6;
      Hook_OnAct        = 7;
      Hook_OnSpot       = 8;
      Hook_OnHit        = 9;
      Hook_OnPickUp     = 10;
      Hook_OnDrop       = 11;
      Hook_OnDie        = 12;

const HookNameList : array[ 0..12 ] of AnsiString = ( 'OnCreate', 'OnEnter', 'OnKillAll', 'OnAttack',
                                                      'OnBroadcast', 'OnUse', 'OnTalk', 'OnAct', 'OnSpot', 'OnHit',
                                                      'OnPickUp', 'OnDrop', 'OnDie' );

const CLASSTYPE_GAME   = 1;
      CLASSTYPE_LEVEL  = 2;
      CLASSTYPE_ITEM   = 3;
      CLASSTYPE_NPC    = 4;
      CLASSTYPE_PLAYER = 5;

const // Properties
{$INCLUDE ../bin/const.inc}

const AIMonster = [AIZombie..AIMax];

const EquipableType = [TYPE_HELM,TYPE_ARMOR,TYPE_SHIELD,TYPE_STAFF,TYPE_BOW,TYPE_WEAPON,TYPE_RING,TYPE_AMULET];

const MapSizeX  = 100;
      MapSizeY  = 100;

      MapPosX   : byte = 1;
      MapPosY   = 2;

      MaxSpells = 40;
      MaxQuests = 64;
      MaxSpellLvl = 20;

      MaxQuickSkills = 4;

      GodMode           : Boolean = False;
      GameEnd           : Boolean = False;
      GameLoad          : Boolean = False;
      GameClass         : Byte = 0;
      GameName          : AnsiString = '';
      LevelChange       : Boolean = False;
      Option_WalkSound  : Boolean = True;
      Option_RunDelay   : DWord = 10;
      Option_TownReveal : Boolean = False;

const ExpTable : array[1..50] of DWord = (
      0,          2000,       4620,       8040,       12489,
      18258,      25712,      35309,      47622,      63364,
      83419,      108876,     141086,     181683,     231075,
      313656,     424068,     571190,     766597,     1025154,
      1366227,    1814568,    2401895,    3168651,    4166200,
      5459523,    7130496,    9281874,    12042092,   15571031,
      20066900,   25744405,   32994399,   42095202,   53525811,
      67831218,   85670061,   107834823,  135274799,  196122009,
      210720231,  261657253,  323800420,  399335440,  490808349,
      601170414,  733825617,  892680222,  1082908612, 1310707109
      );


const CellHook_OnStep        = 1;
      CellHook_OnAct         = 2;
      CellHook_OnTravelName  = 3;
const CellHookNames : array[ 1..3 ] of string = ( 'OnStep', 'OnAct', 'OnTravelName' );


type TCellData = record
       flags   : TFlags;
       hooks   : TFlags;
       color   : Byte;
       pic     : char;
       id      : AnsiString;
       name    : AnsiString;
       cost    : Single;
     end;


var CellData : array[1..255] of TCellData;

var
CELL_FLOOR         : Byte;
CELL_STAIR_UP      : Byte;

CELL_TOWN_PORTAL   : Byte;


function RandRange(RangeMin,RangeMax : LongInt) : LongInt;
function ModColor(aModifier : Integer): byte;

implementation

function ModColor(aModifier : Integer): byte;
begin
       if aModifier < 0 then Exit( LightRed )
  else if aModifier > 0 then Exit( LightBlue )
  else Exit( LightGray );
end;

function RandRange(RangeMin,RangeMax : LongInt) : LongInt;
begin
  if RangeMin > RangeMax then Exit(RangeMin)
                         else Exit(Random(RangeMax-RangeMin+1)+RangeMin);
end;

end.
