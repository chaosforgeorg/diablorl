{$include rl.inc}
// @abstract(NPC class for DiabloRL)
// @author(Kornel Kisielewicz <admin@chaosforge.org>)
// @created(January 17, 2005)

unit rlnpc;
interface
uses classes, sysutils, vmath, vpath, vrltools, rlthing, rlglobal;

type

{ TNPC }

TNPC = class(TThing, IPathQuery)
     protected
       FSpeedCount : Integer;
       FAI         : Byte;
       FCorpse     : Byte;
       FTarget     : TCoord2D;

       FRecovery   : Word;
       FRegenTick  : Word;
       FLifeSteal  : ShortInt;
       FActivated  : Boolean;
       FSound      : AnsiString;
       FPathfinder : TPathfinder;
     public
       property Target: TCoord2D read FTarget write FTarget;
       property SpeedCount: Integer read FSpeedCount write FSpeedCount;
       property Activated: boolean read FActivated;
     public
       // Overriden constructor -- sets x,y to (1,1).
       constructor Create(const thingID :string);
       procedure Action; virtual;
       // Opening doors/Closing doors/Opening Sacrophagus/etc...
       function ActivateCell(c : TCoord2D) : Boolean;
       // Attack NPC
       function Attack(NPC : TNPC; Ranged: Boolean = false; SpellID : Byte = 0) : boolean; virtual;
       // Spell
       function doSpell( SpellID, SpellLevel : DWord): boolean;
       // Block Attack
       function Block(npcAttacker : TNPC) : Boolean; virtual;
       // TimeFlow. See GameObject.
       procedure TimeFlow(time : LongInt);
       // returns resistance
       function getResist( aResStat : DWord ) : LongInt; virtual;
       // returns AC
       function getAC : LongInt; virtual;
       // returns ToHit
       function getToHit : LongInt; virtual;
       // returns HPMax
       function getLife : LongInt; virtual;
       // Returns NPC's name
       function GetName(outputType : TNameOutputType) : string; override;
       // Damage application.
       function applyDamage(aDamage : Integer; aDamageType: byte = DAMAGE_GENERAL; aAttacker: TNPC = nil) : Boolean;
       // Death procedure -- does all cleanup.
       procedure Die(Attacker: TNPC = nil); virtual;
       // Displays the message only if the given NPC is a Player.
       procedure PlayerMsg(const mstr : string);
       // Checks wether this given NPC is the player
       function IsPlayer : boolean;
       // Returns amount of experience gained by killer of killerLevel
       function getExpValue(killerLevel : Byte) : DWord;
       // Seeks given position; dst is for distance.
       //positive value = come closer, negatice = farther, zero = walk circle;
       procedure Seek( c : TCoord2D; dst : shortint = 1 );
       // Sends a missile
       procedure SendMissile( tg : TCoord2D; mtype : Byte; mid : DWord = 0; explosion : byte = 0);
       //Seek for target
       function ClosestTarget(AISet: TAITypeSet; Radius : Byte):TNPC;
       // Plays a sound
       procedure PlaySound(sID : char);
       // knockback
       procedure Knockback(dir: TDirection);
       // Check charge availability
       function CanCharge( c: TCoord2D ) : boolean;
       // Stream constructor
       constructor CreateFromStream( ISt : TStream ); override;
       // Stream writer
       procedure WriteToStream( OSt : TStream ); override;
       // Returns three letter (coded) string representing resistances
       function GetResistancesString : AnsiString;
       // Get amount of surrounding walls and special features
       function GetWallCount : byte;
       // Pathfinder function
       function MoveCost( const Start, Stop : TCoord2D ) : Single; virtual;
       // Pathfinder function
       function CostEstimate( const Start, Stop : TCoord2D ) : Single; virtual;
       // Pathfinder function
       function passableCoord( const Coord : TCoord2D ) : boolean; virtual;
       // Destructor
       destructor Destroy; override;
       // register lua functions
       class procedure RegisterLuaAPI;
     published
       property sound : AnsiString read FSound;
       property scount : LongInt read FSpeedCount write FSpeedCount;
       property ai     : Byte read FAI write FAI;
       property corpse : Byte read FCorpse write FCorpse;
       property hp     : LongInt read FStats[ STAT_HP ]       write FStats[ STAT_HP ];
       property hpmax  : LongInt read FStats[ STAT_HPMAX ]    write FStats[ STAT_HPMAX ] ;
       property expval : LongInt read FStats[ STAT_EXPVALUE ] write FStats[ STAT_EXPVALUE ];
       property recov  : Word read FRecovery write FRecovery;
       property active : Boolean read FActivated write FActivated;
       property lifesteal : ShortInt read FLifeSteal write FLifeSteal;
       property targetx   : Integer read ftarget.x write ftarget.x;
       property targety   : Integer read ftarget.y write ftarget.y;
     end;

implementation
uses vvision, vluaentitynode, vluasystem, vutil,
     rllua, rlgame, rllevel, rlplayer,
     rlui;

constructor TNPC.Create(const thingID :string);
var iTable  : AnsiString;
    iCorpse : AnsiString;
begin
  // Set other atributes and find given thingID
  inherited Create(thingID);
  FPathfinder := TPathfinder.Create( Self );
  FEntityID := ENTITY_BEING;
  fid := ThingID;

  if LuaSystem.Defined(['klasses',id]) then
    iTable := 'klasses'
  else if not LuaSystem.Defined(['npcs',id]) then
    Game.Lua.OnError('NPC "'+id+'" not found!')
  else
    iTable := 'npcs';

  ReadStatistics( iTable );

  with LuaSystem.GetTable( [ iTable, id ] ) do
  try
    FName        := GetString('name');
    FGylph.ASCII := GetChar('pic');
    FGylph.Color := GetInteger('color');

    FCorpse  := 0;
    iCorpse  := GetString('corpse');
    if iCorpse <> '' then  FCorpse := LuaSystem.Defines[iCorpse];
    FAI      := GetInteger('ai');
    FStats[ STAT_HPMAX ] := RandRange(GetInteger('hpmin'),GetInteger('hpmax'));
    if (nfUnique in FFlags) then FStats[ STAT_EXPVALUE ] *= 2;
    FSound   := GetString('sound','');
  finally
    Free;
  end;

  FStats[ STAT_HP ] := FStats[ STAT_HPMAX ];
  FSpeedCount := 90-Random(40);
  FActivated  := False;
  FRecovery := 0;

  if not isPlayer then RunHook( Hook_OnCreate, []  )
end;

//Find closest target matching AI
function TNPC.ClosestTarget(AISet: TAITypeSet; Radius : Byte):TNPC;
var t, ran : Word;
    sc : TCoord2D;
begin
  ran:=1000;
  for sc in NewArea( Position, Radius + 1 ).Clamped( TLevel(Parent).Area ) do
    if not (TLevel(Parent).isEmpty(sc, [efNoMonsters])) then
      if (TLevel(Parent).NPCs[sc].visible)and not(TLevel(Parent).NPCs[sc].Flags[ nfInvisible ]) then
        if (TLevel(Parent).NPCs[sc].AI in AISet) then
          begin
            t := Distance(sc,Position);
            if t <= ran then
            begin
              ran:=t;
              Target := sc;
            end;
          end;
  if ran = 1000 then
    exit(nil)
  else
    exit(TLevel(Parent).NPCs[Target]);
end;

// Returns NPC's name
function TNPC.GetName(outputType : TNameOutputType) : string;
begin
  if not Visible then Exit('someone');
  if (nfUnique in Fflags)or(isPlayer) then Exit(Name);
  exit(inherited GetName(outputType));
end;

function TNPC.getAC : LongInt;
begin
  Exit( FStats[ STAT_AC ] );
end;

function TNPC.getToHit : LongInt;
begin
  if nfCharge in Fflags then exit(500) else Exit(FStats[ STAT_TOHIT ]);
end;

function TNPC.getLife : LongInt;
begin
  Exit(HPMax);
end;


function TNPC.IsPlayer : boolean;
begin
  Exit(FAI = AIPlayer);
end;

// Attack Player
function TNPC.Attack(NPC : TNPC; Ranged: boolean = false; SpellID : Byte = 0) : Boolean;
var HitChance  : Integer;
    Damage     : Integer;
    DmgType    : byte;
begin
  if NPC = nil then Exit;
  Dec(FSpeedCount,FStats[ STAT_SPDATTACK ]);

  if not(NPC.flags[ nfStatue ]) then
  begin
    PlaySound('a');
    HitChance := 30+getToHit+2*Level;
    HitChance := HitChance-(NPC.getAC+2*NPC.Level);

    if HitChance < 15  then HitChance := 15;
    case TLevel(Parent).Depth of
      14 : if HitChance < 20  then HitChance := 20;
      15 : if HitChance < 25  then HitChance := 25;
      16 : if HitChance < 30  then HitChance := 30;
    end;

    if Random(100) >= HitChance then
    begin
      if NPC.isPlayer then
        UI.Msg(GetName(TheName)+' misses you.')
      else
        UI.Msg(GetName(TheName)+' misses '+NPC.GetName(TheName)+'.');
      Exit(false);
    end;

    if (NPC.Block(self)) then begin
       // Attack hit, but was blocked
       Exit(true);
    end;
  end;

  if NPC.isPlayer then
    UI.Msg(GetName(TheName)+' hits you.')
  else
    UI.Msg(GetName(TheName)+' hits '+NPC.GetName(TheName)+'.');

  Damage := RandRange(DmgMin,DmgMax);

  DmgType := DAMAGE_GENERAL;
  if spellID > 0 then
  begin
    DmgType:=LuaSystem.Get(['spells',SpellID,'type']);
  end;

  if NPC.isPlayer then
  begin
    // TODO : RESTORE
    //Damage+=TPlayer(NPC).GetItemStatBonus(PROP_DMGTAKEN);
    if Damage<1 then Damage:=1;
    TPlayer(NPC).durabilityCheck(SlotTorso);
  end;
  // Warning -- NPC may be invalid afterwards.

  RunHook( Hook_OnAttack, [NPC] );
  NPC.ApplyDamage(Damage, dmgtype, self);
  if ((not Ranged) and (SpellID=0)) then begin
     // FLifeSteal for melee attacks only
     if FLifeSteal>0 then
        FStats[ STAT_HP ] += max((Damage*FLifeSteal+500)div 1000,1);
  end;

  // Attacker hit
  Exit(true);
end;

function TNPC.Block(npcAttacker : TNPC) : Boolean;
begin
     npcAttacker := npcAttacker; // Suppress unused argument hint
     // Monsters can never block attacks against them. Jarulf 2.2.1
     Exit(false);
end;

function TNPC.ActivateCell( c : TCoord2D ) : Boolean;
var CellID : Byte;
    iLevel : TLevel;
begin
  iLevel := TLevel(Parent);
  cellID := iLevel.Cell[c];
  if (c<>position)and( not (cfBlockMove in CellData[CellID].Flags)) then
    if (iLevel.NPCs[c] <> nil) or (iLevel.Items[c] <> nil) then
    begin
      PlayerMsg('There''s something blocking the way.');
      Exit(false);
    end;
  //focus Lua on the cell activator and execute script
  if (CellHook_OnAct in CellData[CellID].Hooks) then
  begin
    iLevel.CellHook( CellHook_OnAct, c, [Self] );
  end
  else
  begin
    PlayerMsg('There''s nothing to act upon there.');
    Exit(false);
  end;
  Exit(true);
end;


function TNPC.applyDamage(aDamage : Integer; aDamageType: byte = DAMAGE_GENERAL; aAttacker: TNPC = nil) : Boolean;
var iResist : LongInt;
begin
  if HP <= 0 then exit( True );  //fix player's double death
  if FAI = AINPC then exit( False );
  if isPlayer and (aAttacker = nil) and (TPlayer(self).getItemFlag(ifTrapResist)) then
    aDamage := max(aDamage div 2, 1);

  iResist := 0;
  case aDamageType of
    DAMAGE_HOLY       : if (not (nfUndead in FFlags)) then iResist := 100;
    DAMAGE_FIRE       : iResist := getResist( STAT_RESFIRE );
    DAMAGE_LIGHTNING  : iResist := getResist( STAT_RESLIGHTNING );
    DAMAGE_MAGIC      : iResist := getResist( STAT_RESMAGIC );
  end;
  iResist := Min( iResist, 100 );
  if iResist >= 100 then
  begin
    if (Visible) and (not isPlayer) then UI.Msg(getName(TheName)+' is unaffected.');
    exit( False );
  end;
  aDamage := Max( (aDamage * (100-iResist)) div 100,1);

  if isPlayer then TPlayer(Self).Kills.DamageTaken;

  if nfManaShield in Fflags then
  begin
    aDamage:=(aDamage*77)div 100;
    if self is TPlayer then
      with self as TPlayer do
      begin
         if mp > aDamage then
         begin
           mp:=mp - aDamage;
           aDamage:=0;
         end
         else
         begin
           aDamage-=mp;
           mp:=0;
           exclude(Fflags, nfManaShield);
         end;
         dec(FStats[ STAT_HP ], aDamage);
         if (FStats[ STAT_SPDHIT ] > 0) and (hp > aDamage) and (aDamage>=Level) then
           FRecovery := FStats[ STAT_SPDHIT ];
           FSpeedCount := min(FSpeedCount, 100 - (SpdMov + SpdAtk)div 4);
      end;
  end
  else
  begin
    Dec(FStats[ STAT_HP ],aDamage);
    if aDamage > Level+3 then
    begin
      FRecovery := SpdHit;
      FSpeedCount := min(FSpeedCount, 100 - (SpdMov + SpdAtk)div 4);
    end;
  end;
  // warning, no access afterwards
  if HP <= 0 then begin Die(aAttacker); exit( True ); end
  else begin
    if (isPlayer) then
      with self as TPlayer do
      begin
           PlaySound('69'); // TODO: alternate 69b?
      end
    else
        PlaySound('h');
    if nfStatue in FFlags then
    begin
      exclude(FFlags, nfStatue);
      FRecovery := 20;
    end else RunHook(Hook_OnHit,[aAttacker]);
  end;
  Exit( False );
end;


function TNPC.getExpValue(killerLevel : Byte) : DWord;
var value : LongInt;
begin
  Value := Round(FStats[ STAT_EXPVALUE ]*(1.0+0.1*(Level-killerLevel)));
  if Value < 0 then Value := 0;
  Exit(Value);
end;

procedure TNPC.TimeFlow(time : LongInt);
begin
  if GameEnd then Exit;
  // Do your action
  if not (isPlayer()or (nfNoHeal in Fflags)) then
  begin
    FRegenTick += time;
    if (HP < HPMax) then
    begin
      if (FRegenTick*Level >= 640) then
      begin
        inc(FStats[ STAT_HP ]);
        dec(FRegenTick, 640 div Level)
      end;
    end
    else
      FRegenTick := 0;
  end;
  Inc(FSpeedCount,Max(0,time-FRecovery));
  FRecovery := Max(0,FRecovery-Time);
  if FRecovery = 0 then exclude( Fflags, nfStatue );
  while (FSpeedCount >= 100) and (GameEnd = False) do Action;
end;

function TNPC.getResist(aResStat: DWord): LongInt;
begin
  Exit( FStats[ aResStat ] );
end;

procedure TNPC.Die(Attacker: TNPC = nil);
begin
  if FAI in AIMonster then
    Game.Player.Kills.Add(ID);

  // technically not needed anymore
  if UID = Game.Player.Enemy then Game.Player.Enemy := 0;

  if Visible then UI.Msg(GetName(TheName)+' dies.');
  PlaySound('d');
  RunHook( Hook_OnDrop, [ Attacker ] );
  if FAI in AIMonster then
    UI.Msg('You gain '+IntToStr(getExpValue(Game.Player.Level))+' experience.');
  Game.Player.AddExp(getExpValue(Game.Player.Level));
  if FCorpse <> 0 then
    if not (cfBlockChange in CellData[TLevel(Parent).Cell[Position]].Flags) then
      TLevel(Parent).Cell[Position] := FCorpse;
  RunHook( Hook_OnDie, [Attacker] );
  Move(Game.Graveyard);
  if FAI in AIMonster then
    Game.Level.OnMonsterDie(Position);

end;

procedure TNPC.PlayerMsg(const mstr : string);
begin
  if IsPlayer then UI.Msg(mstr);
end;

procedure TNPC.KnockBack(dir : TDirection);
begin
  if TLevel(Parent).isEmpty(Position+Dir,[efNoMonsters, efNoObstacles]) then
    Displace(Position+Dir);
  FRecovery := SpdHit;
end;

function TNPC.CanCharge( c : TCoord2D ): boolean;
var Ray : TBresenhamRay;
begin
  CanCharge := false;
  Ray.Init(Position,c);
  repeat
    Ray.Next;
    if Ray.GetC = c then
      CanCharge := true;
  until not TLevel(Parent).isEmpty(Ray.GetC, [efNoMonsters, efNoObstacles]);
  FTarget:=Ray.GetC;
end;

procedure TNPC.Seek( c : TCoord2D; dst : shortint = 1);

var r : TCoord2D;
    m : TCoord2D;
    MoveResult  : byte;
    Dir         : TDirection;
  function TryMove(mv : TCoord2D) : Byte;
  begin with TLevel(Parent) do begin
    if NPCs[mv] <> nil then Exit(100);
    if cfBlockMove in CellData[Cell[mv]].Flags then Exit(100);
    r := mv;
    Exit(0);
  end; end;

begin
  if FPosition = c then Exit;
  MoveResult := 0;
  Dir.CreateSmooth(Position, c);
  m.Create(Sgn(dst*Dir.X),Sgn(dst*Dir.Y));
  if (dst = 1) and FPathfinder.QuickRun( FPosition, c,r, 20, 20 ) then
    m := r - FPosition;

  MoveResult := TryMove(Position+m);

  if nfCharge in Fflags then
    if MoveResult = 0 then
    begin
      Dec(FSpeedCount,SpdMov div 4);
      Displace(Position+m);
      Exit;
    end
    else
    begin
      if TLevel(Parent).NPCs[Position+m]<>nil then
        if not(TLevel(Parent).NPCs[Position+m].AI in AIMonster+[AINPC]) then
        begin
          Attack(TLevel(Parent).NPCs[Position+m]);
          exit;
        end;
      FRecovery := spdhit;
      dec(FSpeedcount, spdmov div 4);
      exclude(Fflags, nfCharge);
      exit;
    end;

  if MoveResult = 100 then
    if m.x = 0 then
      MoveResult := TryMove(NewCoord2D(Position.x+(Random(2)*2-1),Position.y+m.y))
    else
      MoveResult := TryMove(Position.IfIncX(m.x));
  if MoveResult = 100 then
    if m.y = 0 then
      MoveResult := TryMove(Position.IfInc(m.x,Random(2)*2-1))
    else
      MoveResult := TryMove(Position.IfIncY(m.y));

  if MoveResult = 0 then
  begin
    Dec(FSpeedCount,SpdMov);
    Displace(r);
    Exit;
  end;
end;

procedure TNPC.SendMissile( tg : TCoord2D; mtype : Byte; mid : DWord; explosion : byte = 0);
const HITDELAY  = 50;
var Ray       : TBresenhamRay;
    Old       : TCoord2D;
    DrawDelay : Word;
    iDuration : DWord;
    iAnimTgt  : TCoord2D;
    Pict      : Char;
    Col       : Byte;
    Dmin, DMax: Word;
    bHit      : Boolean;
    dmgtype   : byte;
begin
  dmgtype := DAMAGE_GENERAL;
  if not isPlayer then Dec(FSpeedCount, SpdAtk);

  DrawDelay := 10;
  case mtype of
    mt_Arrow :
      begin
        DrawDelay := 20;
        Pict      := '-';
        Col       := Brown;
      end;
    mt_Spell :
      begin
        with LuaSystem.GetTable(['spells',mid]) do
        try
          DrawDelay := 20;
          Pict      := getString('picture')[1];
          Col       := GetInteger('color');
          dmgtype   := GetInteger('type');
          if isPlayer then
            with self as TPlayer do
            begin
              if isFunction('dmin')
                then DMin := ProtectedCall('dmin',[spells[mid],Self])
                else DMin := GetInteger('dmin');
              if isFunction('dmax')
                then DMax := ProtectedCall('dmax',[spells[mid],Self])
                else DMax:= GetInteger('dmax');
            end
          else
          begin
            DMin   := dmgmin;
            DMax   := dmgmax;
          end
        finally
          Free;
        end;
      end;
  end;

  Ray.Init(Position,tg);
  iAnimTgt  := Position;
  iDuration := DrawDelay;
  repeat
    Old := Ray.GetC;
    Ray.Next;
    if TLevel(Parent).isVisible(Ray.GetC) then
    begin
      iAnimTgt  := Ray.GetC;
      iDuration += DrawDelay;
    end;
    //hit obstacle
    if not TLevel(Parent).isEmpty(Ray.GetC, [efNoBlockMissile]) then begin
      // Missile hits non-passable feature
      if (mtype = mt_Arrow) then
         UI.PlaySound('sfx/misc/arrowall.wav',Ray.GetC);
      if explosion > 0 then
      begin
        include(Fflags, nfUnAffected);
        TLevel(Parent).Explosion(Old, Col, explosion, DMin, DMax, 50, dmgtype, Self, iDuration );
        exclude(Fflags, nfUnAffected);
      end
      else if TLevel(Parent).isVisible(Ray.GetC) then
      begin
        UI.AddMarkAnimation( Ray.GetC, '*', LightGray, HITDELAY, iDuration );
      end;
      Break;
    end;
   //hit monster
   if not TLevel(Parent).isEmpty(Ray.GetC, [efNoMonsters]) then
    begin
        bHit := false;
        case mtype of
            mt_Arrow  : if isPlayer or (tg = ray.GetC)
                         then bHit := Attack(TLevel(Parent).NPCs[Ray.GetC], true);
            mt_Spell  : if isPlayer or (tg = ray.GetC) then
                          if explosion > 0 then
                          begin
                            bHit := true;
                            include(Fflags, nfUnAffected);
                            TLevel(Parent).Explosion(Ray.GetC, Col, explosion, DMin, DMax, 50, dmgtype, self);
                            exclude(Fflags, nfUnAffected);
                            break;
                          end
                          else
                            bHit := Attack(TLevel(Parent).NPCs[Ray.GetC], true, mid);
        end;
        if bHit and (explosion = 0) then
        begin
          if TLevel(Parent).isVisible(Ray.GetC) then
            UI.AddMarkAnimation( Ray.GetC, '*', Red, HITDELAY, iDuration );
          Break;
        end;
    end;
  until False;
  UI.AddBulletAnimation( Position, iAnimTgt, Pict, Col, iDuration, 0 );
end;

function TNPC.doSpell(SpellID, SpellLevel: DWord): boolean;
var Effect      : DWord;
    Col         : Byte;
    Dmin, DMax  : Word;
    SpellTarget : TThing;
begin
  Result := true;
  with LuaSystem.GetTable( ['spells',SpellID] ) do
  try
    if ( isPlayer ) then
		UI.Msg('You cast '+getString('name')+'.')
	else if ( Visible ) then
		UI.Msg(GetName(TheName)+' casts '+getString('name')+'.');
    if IsString('sound1') then UI.PlaySound('sfx/misc/' + getString('sound1') + '.wav');
    if IsString('sound2') then UI.PlaySound('sfx/misc/' + getString('sound2') + '.wav');
    if not ( isPlayer ) then
      if IsString('spdmag') then dec(FSpeedCount, getInteger('spdmag')) else dec(FSpeedCount, SpdAtk);
    Effect := GetInteger( 'effect' );
    if Effect = SPELL_SCRIPT then
    begin
      SpellTarget := nil;
      if GetInteger( 'target' ) = SPELL_TARGET then
        if TLevel(Parent).NPCs[Target]<>nil then
          SpellTarget := TLevel(Parent).NPCs[Target]
        else if TLevel(Parent).Items[Target]<>nil then
          SpellTarget := TLevel(Parent).Items[Target];
      Result := Call('script', [SpellLevel, Self, SpellTarget] );
    end;
  finally
    Free;
  end;
  case Effect of
    SPELL_BOLT  : SendMissile( Target, mt_Spell, SpellID ); // spell level is not passed -- will need a fix for cases like wands
    SPELL_BALL  : SendMissile( Target, mt_Spell, SpellID, 1);
    SPELL_BLAST : begin
                    with LuaSystem.GetTable( [ 'spells',SpellID ] ) do
                    try
                      Col  := GetInteger('color');
                      if isPlayer then
                      begin
                        DMin := Call('dmin',[spelllevel,Self]);
                        DMax := Call('dmax',[spelllevel,Self]);
                      end
                      else if isFunction('dminmlvl') then
                      begin
                        DMin := Call('dminmlvl',[Level],-1);
                        DMax := Call('dmaxmlvl',[Level],-1);
                      end
                      else
                      begin
                        DMin := DmgMin;
                        DMax := DmgMax;
                      end;
                      include(Fflags, nfUnAffected);
                      TLevel(Parent).Explosion(Target, Col, 1, DMin, DMax, 50, GetInteger('type'), self);
                      exclude(Fflags, nfUnAffected);
                    finally
                      Free;
                    end;
                  end;
  end;
end;

procedure TNPC.Action;
begin
  //OnSpot script
  if Visible then
  begin
    if (not FActivated) then begin
       RunHook(Hook_OnSpot,[]);
       FActivated := True;
    end;
  end else begin
      // Cause OnSpot to be called again when player moves back into view
      if (FAI = AINPC) then
         FActivated := False;
  end;

  //AI
  RunHook(Hook_OnAct,[]);

  //wait 0.05 seconds
  if FSpeedCount >= 100 then Dec(FSpeedCount,5);
end;

// PlaySound
// It is assumed that the Sound property is set to the base name
// sID is one of:
//     a - attack
//     h - hit
//     d - die
//     s - shout (war cry)
procedure TNPC.PlaySound(sID: char);
begin
     if (FSound = '') then exit;
     // There are two versions of each sound, pick one randomly
     UI.PlaySound(FSound + sID + IntToStr(Random(2) + 1) + '.wav',Position);
end;

constructor TNPC.CreateFromStream(ISt: TStream);
var iTable  : AnsiString;
    iCorpse : AnsiString;
begin
  inherited CreateFromStream(ISt);
  FPathfinder := TPathfinder.Create( Self );
  ISt.Read(FTarget,SizeOf(TCoord2D));
  FAI        := ISt.ReadByte;
  FRecovery  := ISt.ReadWord;
  FRegenTick := ISt.ReadWord;

  if LuaSystem.Defined(['klasses',id]) then
    iTable := 'klasses'
  else if not LuaSystem.Defined(['npcs',id]) then
    Game.Lua.OnError('NPC "'+id+'" not found!')
  else
    iTable := 'npcs';

  with LuaSystem.GetTable( [iTable, id] ) do
  try
    FCorpse  := 0;
    iCorpse  := GetString('corpse','');
    if iCorpse <> '' then  FCorpse := LuaSystem.Defines[iCorpse];
    FSound   := GetString('sound','');
  finally
    Free;
  end;
  Log('...Finished!');
end;

procedure TNPC.WriteToStream(OSt: TStream);
begin
  inherited WriteToStream(OSt);
  OSt.Write(Target,SizeOf(TCoord2D));
  OSt.WriteByte(FAI);
  OSt.WriteWord(FRecovery);
  OSt.WriteWord(FRegenTick);
end;

// TODO - resistances should be separate from flags!
function TNPC.GetResistancesString : AnsiString;
  function ResChar( aStat : DWord ) : Char;
  var iValue : LongInt;
  begin
    iValue := FStats[ aStat ];
    if iValue >= 100 then Exit('I');
    if iValue >= 25  then Exit('R');
    Exit('-');
  end;

begin
  GetResistancesString :=
    '@R'+ResChar( STAT_RESFIRE )+
    '@y'+ResChar( STAT_RESLIGHTNING )+
    '@B'+ResChar( STAT_RESMAGIC );
end;

function TNPC.GetWallCount : byte;
  procedure TestFlags( const aFlags : TFlags );
  begin
    if cfBlockMove in aFlags then
      Inc( GetWallCount );
  end;
var
  iLevel : TLevel;
begin
  iLevel     := Parent as TLevel;
  GetWallCount := 0;
  TestFlags( iLevel.TileFlags[FPosition.ifIncX( 1 )] );
  TestFlags( iLevel.TileFlags[FPosition.ifIncY( 1 )] );
  TestFlags( iLevel.TileFlags[FPosition.ifIncX( -1 )] );
  TestFlags( iLevel.TileFlags[FPosition.ifIncY( -1 )] );
end;

function TNPC.MoveCost ( const Start, Stop : TCoord2D ) : Single;
var Diff : TCoord2D;
begin
  Diff := Start - Stop;
  if Diff.x * Diff.y = 0
     then MoveCost := 1.0
     else MoveCost := 1.3;

  MoveCost := MoveCost * CellData[TLevel(Parent).Cell[ Stop ]].Cost;
  if TLevel(Parent).NPCs[ Stop ] <> nil then MoveCost := MoveCost * 5;
end;

function TNPC.CostEstimate ( const Start, Stop : TCoord2D ) : Single;
begin
  Exit( RealDistance( Start, Stop ) );
end;

function TNPC.passableCoord ( const Coord : TCoord2D ) : boolean;
begin
  Exit( (Parent as TLevel).isPassable(Coord) );
end;

destructor TNPC.Destroy;
begin
  FreeAndNil( FPathfinder );
  inherited Destroy;
end;

function lua_npc_is_active(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    npc     : TNPC;
begin
  State.Init(L);
  npc := State.ToObject(1) as TNPC;
  State.Push( npc.Activated );
  Result := 1;
end;

function lua_npc_die(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    npc     : TNPC;
begin
  State.Init(L);
  npc := State.ToObject(1) as TNPC;
  npc.die;
  Result := 0;
end;

function lua_npc_can_charge(L: Plua_State): Integer; cdecl;
var State   : TRLLuaState;
    npc     : TNPC;
begin
  State.Init(L);
  npc := State.ToObject(1) as TNPC;
  State.Push( npc.CanCharge( State.ToPosition(2) ) );
  Result := 1;
end;

function lua_npc_get_target(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    npc     : TNPC;
begin
  State.Init(L);
  npc := State.ToObject(1) as TNPC;
  State.PushCoord( npc.Target );
  Result := 1;
end;


function lua_npc_target_closest(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    npc     : TNPC;
    Target  : TNPC;
begin
  State.Init(L);
  npc := State.ToObject(1) as TNPC;
  if npc.AI in AIMonster then
    Target := npc.ClosestTarget([AIPlayer,AIGolem], State.toInteger(2,15) )
  else
    Target := npc.ClosestTarget(AIMonster, State.toInteger(2,15) );
  if Target <> nil then npc.Target := Target.Position;
  State.Push( Target );
  Result := 1;
end;

function lua_npc_attack(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    npc     : TNPC;
    c       : TCoord2D;
begin
  State.Init(L);
  npc := State.ToObject(1) as TNPC;
  c := State.ToPosition(2);
  if Game.Level.NPCs[c] = nil then Exit(0);
  npc.Attack(Game.Level.NPCs[c]);
  Result := 0;
end;

function lua_npc_seek(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    npc     : TNPC;
begin
  State.Init(L);
  npc := State.ToObject(1) as TNPC;
  npc.Seek( State.ToPosition(2), State.ToInteger(3,1) );
  Result := 0;
end;

function lua_npc_send_missile(L: Plua_State) : Integer; cdecl;
var State : TRLLuaState;
    npc   : TNPC;
begin
  State.Init(L);
  npc := State.ToObject(1) as TNPC;
  if State.StackSize < 3 then Exit(0);
  npc.SendMissile(State.ToPosition(3),State.ToInteger(2),State.toInteger(4));
  Result := 0;
end;

function lua_npc_cast_spell(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    npc     : TNPC;
    spellID : Integer;
    spellLvl: Integer;
begin
  State.Init(L);
  npc := State.ToObject(1) as TNPC;
  if State.IsString( 2 ) then
    spellID := LuaSystem.Get( [ 'spells',State.ToString( 2 ), 'nid' ] )
  else
    spellID := State.ToInteger( 2 );
  if ( State.StackSize < 3 ) then
    spellLvl := 0
  else
    spellLvl := State.ToInteger( 3 );
  npc.doSpell( spellID , spellLvl );

  Result := 0;
end;

function lua_npc_phasing(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    npc     : TNPC;
    Count: byte;
    aoe : TArea;
    pos : TCoord2D;
begin
  State.Init(L);
  npc := State.ToObject(1) as TNPC;
  aoe := NewArea(npc.Position,4);
  TLevel(npc.Parent).Area.Clamp(aoe);
  Count := 10;
  repeat
    pos := aoe.RandomEdgeCoord;
    dec(Count);
  until (Count = 0) or (TLevel(npc.Parent).isEmpty(pos,[efNoMonsters, efNoObstacles, efSpawnOk]));
  if Count = 0 then
  begin
    Pos := npc.position;
    if not TLevel(npc.Parent).FindNearSpace(pos, 6, [efNoMonsters, efNoObstacles, efSpawnOk]) then Exit(0);
  end;
  npc.Displace(pos);
  npc.SpeedCount:=npc.SpeedCount-1;
  Result := 0;
end;

function lua_npc_knockback(L: Plua_State) : Integer; cdecl;
var State   : TRLLuaState;
    npc     : TNPC;
begin
  State.Init(L);
  npc := State.ToObject(1) as TNPC;
  npc.Knockback( NewDirection( State.ToPosition(2), npc.Position) );
  Result := 0;
end;

const lua_npc_lib : array[0..11] of luaL_Reg = (
  ( name : 'is_active';     func : @lua_npc_is_active),
  ( name : 'die';           func : @lua_npc_die),
  ( name : 'can_charge';    func : @lua_npc_can_charge),
  ( name : 'get_target';    func : @lua_npc_get_target),
  ( name : 'target_closest';func : @lua_npc_target_closest),
  ( name : 'attack';        func : @lua_npc_attack),
  ( name : 'seek';          func : @lua_npc_seek),
  ( name : 'send_missile';  func : @lua_npc_send_missile),
  ( name : 'cast_spell';    func : @lua_npc_cast_spell),
  ( name : 'phasing';       func : @lua_npc_phasing),
  ( name : 'knockback';     func : @lua_npc_knockback),
  ( name : nil;             func : nil; )
);


class procedure TNPC.RegisterLuaAPI;
begin
  LuaSystem.Register( 'npc', lua_npc_lib );
end;

end.
