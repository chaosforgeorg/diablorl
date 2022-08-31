{$include rl.inc}
// @abstract(Thing class for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
// @created(January 17, 2005)
//
// This unit holds the TThing class. A TThing holds common data and
// methods for TItem and TNPC.

unit rlthing;
interface
uses classes, vluaentitynode, rlglobal;

// Generic Thing class -- ancestor to both TItem and TNPC.
type

{ TThing }

TThing = class(TLuaEntityNode)
     protected
       FStats : TStatistics;
     public
       // Overriden constructor -- sets x,y to (1,1).
       constructor Create( const aThingID : AnsiString );
       // Reads statistics from passed table
       procedure ReadStatistics( const aTableID : AnsiString );
       // Overriden destructor, does nothing (yet)
       destructor Destroy; override;
       // returns Picture (color + char)
       function GetPicture : Word;
       // GetName returns the name of the thing -- to be overridden
       // GetName output MAY include colors -- for plain name use Name
       // directly.
       function GetName(outputType : TNameOutputType) : string; virtual;

       // Stream constructor
       constructor CreateFromStream( ISt : TStream ); override;
       // Stream writer
       procedure WriteToStream( OSt : TStream ); override;
       // register lua functions
       class procedure RegisterLuaAPI;
     protected
       function GetStatistics ( aIndex : DWord ) : LongInt;
       procedure SetStatistics ( aIndex : DWord ; aValue : LongInt ) ;
     public
       property Statistics[ aIndex : DWord ] : LongInt read GetStatistics write SetStatistics;
     published
       property visible : Boolean read IsVisible;

       property level     : LongInt read FStats[ STAT_LEVEL ] write FStats[ STAT_LEVEL ];

       property dmgmin    : LongInt read FStats[ STAT_DMGMIN ] write FStats[ STAT_DMGMIN ];
       property dmgmax    : LongInt read FStats[ STAT_DMGMAX ] write FStats[ STAT_DMGMAX ];
       property dmgmod    : LongInt read FStats[ STAT_DMGMOD ]    write FStats[ STAT_DMGMOD ] ;
       property dmgmodprc : LongInt read FStats[ STAT_DMGMODPRC ] write FStats[ STAT_DMGMODPRC ] ;

       property spdatk : LongInt read FStats[ STAT_SPDATTACK ]write FStats[ STAT_SPDATTACK];
       property spdmov : LongInt read FStats[ STAT_SPDMOVE ]  write FStats[ STAT_SPDMOVE];
       property spdhit : LongInt read FStats[ STAT_SPDHIT ]   write FStats[ STAT_SPDHIT];
       property spdblk : LongInt read FStats[ STAT_SPDBLOCK ] write FStats[ STAT_SPDBLOCK];
       property spdmag : LongInt read FStats[ STAT_SPDMAGIC ] write FStats[ STAT_SPDMAGIC];

       property str    : LongInt read FStats[ STAT_STR ] write FStats[ STAT_STR ];
       property dex    : LongInt read FStats[ STAT_DEX ] write FStats[ STAT_DEX ];
       property mag    : LongInt read FStats[ STAT_MAG ] write FStats[ STAT_MAG ];
       property vit    : LongInt read FStats[ STAT_VIT ] write FStats[ STAT_VIT ];

       property ac     : LongInt read FStats[ STAT_AC ]    write FStats[ STAT_AC ];
       property tohit  : LongInt read FStats[ STAT_TOHIT ] write FStats[ STAT_TOHIT ];
end;

implementation
uses SysUtils, vluasystem, rllua;

function TThing.GetStatistics ( aIndex : DWord ) : LongInt;
begin
  Exit( FStats[ aIndex ] );
end;

procedure TThing.SetStatistics ( aIndex : DWord ; aValue : LongInt ) ;
begin
  FStats[ aIndex ] := aValue;
end;

constructor TThing.Create( const aThingID : AnsiString );
var iCount : DWord;
begin
  // With TNode descendants ALWAYS call inherited Init and Done.
  inherited Create( aThingID );
  // To be on the safe side we set x,y to 1, 'cause (0,0) is not
  // a valid map coordinate in this game.
  FPosition.Create( 1, 1 );

  for iCount := 0 to STAT_MAX do FStats[ iCount ] := 0;
end;

procedure TThing.ReadStatistics ( const aTableID : AnsiString ) ;
var iCount : DWord;
begin
  with LuaSystem.GetTable( [ aTableID, id ] ) do
  try
    for iCount := 0 to STAT_MAX do
      FStats[ iCount ] := GetInteger( StatisticsIDs[iCount], 0 );
  finally
    Free;
  end;
end;

function TThing.GetPicture : Word;
begin
  exit(FGylph.Color shl 8 + ord(FGylph.ASCII));
end;

destructor TThing.Destroy;
begin
  // With TNode descendants ALWAYS call inherited Init and Done.
  inherited Destroy;
end;

function TThing.GetName(outputType : TNameOutputType) : string;
begin
  case outputType of
    TheName    : Exit('the '+FName);
    AName      : Exit('a '+FName);
    else Exit(Fname);
  end;
end;

constructor TThing.CreateFromStream(ISt: TStream);
begin
  inherited CreateFromStream(ISt);
  ISt.Read( FStats, SizeOf(FStats) );
end;

procedure TThing.WriteToStream(OSt: TStream);
begin
  inherited WriteToStream(OSt);
  OSt.Write( FStats, SizeOf(FStats) );
end;

function lua_thing_get_name(L: Plua_State) : Integer; cdecl;
var State : TRLLuaState;
    th    : TThing;
begin
  State.Init(L);
  th := State.ToObject(1) as TThing;
  if State.StackSize = 0 then
      State.Push( th.GetName( PlainName ) )
  else
      State.Push( th.GetName( TNameOutputType(State.ToInteger(2)) ) );
  Result := 1;
end;

function lua_thing_get_stat(L: Plua_State) : Integer; cdecl;
var State : TRLLuaState;
    th    : TThing;
begin
  State.Init(L);
  th := State.ToObject(1) as TThing;
  State.Push( th.Statistics[ State.ToInteger(2) ] );
  Result := 1;
end;

const lua_thing_lib : array[0..2] of luaL_Reg = (
  ( name : 'get_stat';    func : @lua_thing_get_stat),
  ( name : 'get_name';    func : @lua_thing_get_name),
  ( name : nil;           func : nil; )
);

class procedure TThing.RegisterLuaAPI;
begin
  LuaSystem.Register('thing', lua_thing_lib );
end;

end.
