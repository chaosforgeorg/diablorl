-- Data in this file comes from Jarulf:
--	5.2 Monster data
--	5.3.1 Monster size
--	5.3.4 Timing information
------------------------------
-- monster is the base prototype for all monsters
-- it is mostly used to
-- the default properties should all be overridden

core.register_blueprint "npc"
{
	id           = { true,  core.TSTRING },
	base         = { false, core.TIDIN("npcs") },
	name         = { true,  core.TSTRING },
	pic          = { true,  core.TSTRING },
	ai           = { true,  core.TNUMBER },
	color        = { false, core.TNUMBER, LIGHTGRAY },
	level        = { false, core.TNUMBER, 1 },
	intf         = { false, core.TNUMBER, 0 },
	dlvl         = { false, core.TNUMBER },
	flags        = { false, core.TFLAGS, {} },
	corpse       = { false, core.TSTRING, "bloody_corpse" },

	hpmin        = { true,  core.TNUMBER },
	hpmax        = { true,  core.TNUMBER },
	dmgmin       = { true,  core.TNUMBER },
	dmgmax       = { true,  core.TNUMBER },
	amountmin    = { false, core.TNUMBER, 1 },
	amountmax    = { false, core.TNUMBER, 1 },
	size         = { false, core.TNUMBER, 500 },
	group        = { false, core.TTABLE },
	tohit        = { false, core.TNUMBER, 0 },
	ac           = { false, core.TNUMBER, 0 },
	spdmov       = { false, core.TNUMBER, 100 },
	spdatk       = { false, core.TNUMBER, 100 },
	spdhit       = { false, core.TNUMBER, 100 },
	expvalue     = { false, core.TNUMBER, 0 },

	sound        = { false, core.TSTRING },

	resmagic     = { false, core.TNUMBER },
	resfire      = { false, core.TNUMBER },
	reslightning = { false, core.TNUMBER },

	--is_unique    = { false, core.TBOOL, false },
	--no_random    = { false, core.TBOOL, false },
	random       = { false, core.TBOOL },
	mob          = { false, core.TBOOL },

	OnDrop       = { false, core.TFUNC, npc.standard_drop },
	OnAttack     = { false, core.TFUNC },
	OnCreate     = { false, core.TFUNC },
	OnTalk       = { false, core.TFUNC },
	OnSpot       = { false, core.TFUNC },
	OnHit        = { false, core.TFUNC },
	OnDie        = { false, core.TFUNC }
}

--== ZOMBIES ========================================================--

core.register_blueprint ( "zombie", "npc" )
{
	flags    = { false, core.TFLAGS, {nfUndead} },
	ai       = { false, core.TNUMBER, AIZombie },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "z",
	size     = 799,
	corpse   = "corpse",
	resmagic = 100,
	spdmov   = 120,
	spdhit   = 30,
	spdatk   = 60,
	sound    = "monsters/zombie/zombie"
}

register_npc( "zombie", "zombie" )
{
	name     = "zombie",
	intf     = 0,
	color    = LIGHTGRAY,
	level    = 1,
	group    = {1,2},
	hpmin    = 2,
	hpmax    = 3,
	tohit    = 10,
	ac       = 5,
	dmgmin   = 2,
	dmgmax   = 5,
	expvalue = 54
}

register_npc( "ghoul", "zombie" )
{
	name     = "ghoul",
	intf     = 1,
	color    = LIGHTBLUE,
	level    = 2,
	group    = {2,3},
	hpmin    = 3,
	hpmax    = 5,
	tohit    = 10,
	ac       = 10,
	dmgmin   = 3,
	dmgmax   = 10,
	expvalue = 58
}

register_npc( "rotting_carcass", "zombie" )
{
	name     = "rotting carcass",
	intf     = 2,
	color    = DARKGRAY,
	level    = 4,
	group    = {2,3,4},
	hpmin    = 7,
	hpmax    = 12,
	tohit    = 25,
	ac       = 15,
	dmgmin   = 5,
	dmgmax   = 15,
	expvalue = 136
}

register_npc( "black_death", "zombie" )
{
	name      = "black death",
	intf      = 3,
	color     = YELLOW,
	level     = 6,
	group     = {3,4,5},
	hpmin     = 12,
	hpmax     = 20,
	tohit     = 25,
	ac        = 20,
	dmgmin    = 6,
	dmgmax    = 22,
	expvalue  = 240,
	amountmin = 1,
	amountmax = 1,

	OnAttack = function(self,tgt)
	  tgt.hpmod = tgt.hpmod - 1
	end
}

--== SKELETONS ======================================================--

-- normal skeletons --

core.register_blueprint ( "skeleton", "npc" )
{
	flags    = { false, core.TFLAGS, {nfUndead,nfSkeleton} },
	ai       = { false, core.TNUMBER, AISkeleton },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 5 },
	pic      = "s",
	size     = 553,
	corpse   = "bones",
	resmagic = 100,
	spdmov   = 100,
	spdhit   = 30,
	spdatk   = 65,
	sound    = "monsters/skelaxe/sklax"
}

register_npc( "skeleton_axe", "skeleton" )
{
	name     = "skeleton",
	intf     = 0,
	color    = LIGHTGRAY,
	level    = 1,
	group    = {1,2},
	hpmin    = 1,
	hpmax    = 2,
	tohit    = 20,
	dmgmin   = 1,
	dmgmax   = 4,
	expvalue = 64
}

register_npc( "corpse_axe", "skeleton" )
{
	name     = "corpse axe",
	intf     = 1,
	color    = BROWN,
	level    = 4,
	group    = {2,3,4},
	hpmin    = 2,
	hpmax    = 3,
	tohit    = 25,
	dmgmin   = 3,
	dmgmax   = 5,
	expvalue = 68
}

register_npc( "burning_dead", "skeleton" )
{
	name     = "burning dead",
	intf     = 2,
	color    = LIGHTRED,
	level    = 4,
	group    = {2,3,4},
	hpmin    = 4,
	hpmax    = 6,
	tohit    = 30,
	ac       = 5,
	dmgmin   = 3,
	dmgmax   = 7,
	expvalue = 154,
	resfire  = 75
}

register_npc( "horror", "skeleton" )
{
	name     = "horror",
	intf     = 3,
	color    = DARKGRAY,
	level    = 6,
	group    = {4,5,6},
	hpmin    = 6,
	hpmax    = 10,
	tohit    = 35,
	ac       = 15,
	dmgmin   = 4,
	dmgmax   = 9,
	expvalue = 264,

	reslightning = 75
}

-- skeleton captains --

core.register_blueprint ( "skeleton_captain", "npc" )
{
	flags    = { false, core.TFLAGS, {nfUndead,nfSkeleton} },
	ai       = { false, core.TNUMBER, AISkeleton },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "S",
	size     = 575,
	corpse   = "bones",
	resmagic = 100,
	spdmov   = 100,
	spdhit   = 35,
	spdatk   = 60,
	sound    = "monsters/skelaxe/sklax"
}

register_npc( "skeleton_captain", "skeleton_captain" )
{
	name     = "skeleton captain",
	intf     = 0,
	color    = LIGHTGRAY,
	level    = 2,
	group    = {1,2,3},
	hpmin    = 1,
	hpmax    = 3,
	tohit    = 20,
	ac       = 10,
	dmgmin   = 2,
	dmgmax   = 7,
	expvalue = 90
}

register_npc( "corpse_captain", "skeleton_captain" )
{
	name     = "corpse captain",
	intf     = 1,
	color    = BROWN,
	level    = 4,
	group    = {2,3,4},
	hpmin    = 6,
	hpmax    = 10,
	tohit    = 30,
	ac       = 5,
	dmgmin   = 3,
	dmgmax   = 9,
	expvalue = 200
}

register_npc( "burning_dead_captain", "skeleton_captain" )
{
	name     = "burning dead captain",
	intf     = 2,
	color    = LIGHTRED,
	level    = 6,
	group    = {3,4,5},
	hpmin    = 8,
	hpmax    = 15,
	tohit    = 35,
	ac       = 15,
	dmgmin   = 4,
	dmgmax   = 10,
	expvalue = 393,
	resfire  = 75
}

register_npc( "horror_captain", "skeleton_captain" )
{
	name     = "horror captain",
	intf     = 3,
	color    = DARKGRAY,
	level    = 8,
	group    = {4,5,6},
	hpmin    = 17,
	hpmax    = 25,
	tohit    = 40,
	ac       = 30,
	dmgmin   = 5,
	dmgmax   = 14,
	expvalue = 604,

	reslightning = 75
}


-- skeleton archers --

core.register_blueprint ( "skeleton_archer", "npc" )
{
	flags    = { false, core.TFLAGS, {nfUndead,nfSkeleton} },
	ai       = { false, core.TNUMBER, AISkelArcher },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "a",
	size     = 567,
	corpse   = "bones",
	resmagic = 100,
	sound    = "monsters/skelbow/sklbw"
}

register_npc ( "skeleton_archer", "skeleton_archer" )
{
	name     = "skeleton archer",
	intf     = 0,
	color    = LIGHTGRAY,
	level    = 3,
	group    = {2,3},
	hpmin    = 1,
	hpmax    = 2,
	tohit    = 15,
	dmgmin   = 1,
	dmgmax   = 2,
	expvalue = 110
}

register_npc ( "corpse_bow", "skeleton_archer" )
{
	name     = "corpse bow",
	intf     = 1,
	color    = BROWN,
	level    = 5,
	group    = {2,3,4},
	hpmin    = 4,
	hpmax    = 8,
	tohit    = 25,
	dmgmin   = 1,
	dmgmax   = 4,
	expvalue = 210
}

register_npc ( "burning_dead_archer", "skeleton_archer" )
{
	name     = "burning dead archer",
	intf     = 2,
	color    = LIGHTRED,
	level    = 7,
	group    = {3,4,5},
	hpmin    = 5,
	hpmax    = 12,
	tohit    = 30,
	ac       = 5,
	dmgmin   = 1,
	dmgmax   = 6,
	expvalue = 364,
	resfire  = 75
}

register_npc ( "horror_archer", "skeleton_archer" )
{
	name     = "horror archer",
	intf     = 3,
	color    = DARKGRAY,
	level    = 9,
	group    = {4,5,6},
	hpmin    = 7,
	hpmax    = 22,
	tohit    = 35,
	ac       = 15,
	dmgmin   = 2,
	dmgmax   = 9,
	expvalue = 594,
	reslightning = 75
}

--== SCAVENGERS =====================================================--

core.register_blueprint ( "scavenger", "npc" )
{
	flags    = { false, core.TFLAGS, {nfAnimal} },
	ai       = { false, core.TNUMBER, AIScavenger },
	amountmin= { false, core.TNUMBER, 3 },
	amountmax= { false, core.TNUMBER, 7 },
	pic      = "v",
	size     = 410,
	corpse   = "bloody_corpse",
	spdmov   = 40,
	spdatk   = 60,
	spdhit   = 30,
	sound    = "monsters/scav/scav"
}

register_npc ( "scavenger", "scavenger" )
{
	name     = "scavenger",
	intf     = 0,
	color    = RED,
	level    = 2,
	group    = {1,2,3},
	hpmin    = 1,
	hpmax    = 3,
	tohit    = 20,
	ac       = 10,
	dmgmin   = 1,
	dmgmax   = 5,
	expvalue = 80
}

register_npc ( "plague_eater", "scavenger" )
{
	name     = "plague eater",
	intf     = 1,
	color    = BROWN,
	level    = 4,
	group    = {2,3,4},
	hpmin    = 6,
	hpmax    = 12,
	tohit    = 30,
	ac       = 20,
	dmgmin   = 1,
	dmgmax   = 8,
	expvalue = 188
}

register_npc ( "shadow_beast", "scavenger" )
{
	name     = "shadow beast",
	intf     = 2,
	color    = BLUE,
	level    = 6,
	group    = {3,4,5},
	hpmin    = 12,
	hpmax    = 18,
	tohit    = 35,
	ac       = 25,
	dmgmin   = 3,
	dmgmax   = 12,
	expvalue = 375
}

register_npc ( "bone_gasher", "scavenger" )
{
	name     = "bone gasher",
	intf     = 3,
	color    = WHITE,
	level    = 8,
	group    = {4,5,6},
	hpmin    = 14,
	hpmax    = 20,
	tohit    = 35,
	ac       = 30,
	dmgmin   = 5,
	dmgmax   = 15,
	expvalue = 552,
	resmagic = 75
}

--== FALLEN ONES ====================================================--

core.register_blueprint ( "fallen_spear", "npc" )
{
	flags    = { false, core.TFLAGS, {nfAnimal} },
	ai       = { false, core.TNUMBER, AIFallenOne },
	amountmin= { false, core.TNUMBER, 2 },
	amountmax= { false, core.TNUMBER, 5 },
	pic      = "o",
	size     = 543,
	corpse   = "bloody_corpse",
	resmagic = 100,
	spdhit   = 55,
	spdatk   = 65,
	spdmov   = 55,
	--spdatk2 = 65,
	sound    = "monsters/falspear/phall",
	retreatdistance = { false, core.TNUMBER, 4 },
	warcrydistance  = { false, core.TNUMBER, 7 },
	warcrytime      = { false, core.TNUMBER, 525 }
}

core.register_blueprint ( "fallen_sword", "npc" )
{
	flags    = { false, core.TFLAGS, {nfAnimal} },
	ai       = { false, core.TNUMBER, AIFallenOne },
	amountmin= { false, core.TNUMBER, 2 },
	amountmax= { false, core.TNUMBER, 5 },
	pic      = "o",
	size     = 623,
	corpse   = "bloody_corpse",
	resmagic = 100,
	spdhit   = 55,
	spdatk   = 65,
	spdmov   = 60,
	--spdatk2 = 75,
	sound    = "monsters/falsword/fall",
	retreatdistance = { false, core.TNUMBER, 7 },
	warcrydistance  = { false, core.TNUMBER, 4 },
	warcrytime      = { false, core.TNUMBER, 525 }
}

register_npc( "fallen_one_spear", "fallen_spear" )
{
	name     = "fallen one",
	intf     = 0,
	color    = BROWN,
	level    = 1,
	group    = {1,2,3},
	hpmin    = 1,
	hpmax    = 2,
	tohit    = 15,
	ac       = 0,
	dmgmin   = 1,
	dmgmax   = 3,
	expvalue = 46,
	retreatdistance = 7,
	warcrydistance  = 4,
	warcrytime      = 525
}

register_npc( "fallen_one_sword", "fallen_sword" )
{
	name     = "fallen one",
	intf     = 0,
	color    = BROWN,
	group    = {1,2,3},
	level    = 1,
	hpmin    = 1,
	hpmax    = 2,
	tohit    = 15,
	ac       = 10,
	dmgmin   = 1,
	dmgmax   = 4,
	expvalue = 52,
	retreatdistance = 7,
	warcrydistance  = 4,
	warcrytime      = 525
}

register_npc( "carver_spear", "fallen_spear" )
{
	name     = "carver",
	intf     = 2,
	color    = BLUE,
	group    = {2,3},
	level    = 3,
	hpmin    = 2,
	hpmax    = 4,
	ac       = 5,
	tohit    = 20,
	dmgmin   = 2,
	dmgmax   = 5,
	expvalue = 80,
	retreatdistance = 5,
	warcrydistance  = 5,
	warcrytime      = 675
}

register_npc( "carver_sword", "fallen_sword" )
{
	name     = "carver",
	intf     = 1,
	color    = BLUE,
	level    = 3,
	group    = {2,3},
	hpmin    = 2,
	hpmax    = 4,
	ac       = 15,
	tohit    = 20,
	dmgmin   = 2,
	dmgmax   = 7,
	expvalue = 90,
	retreatdistance = 5,
	warcrydistance  = 5,
	warcrytime      = 675
}

register_npc( "devil_kin_spear", "fallen_spear" )
{
	name     = "devil kin",
	intf     = 2,
	color    = LIGHTRED,
	group    = {2,3,4},
	level    = 5,
	hpmin    = 6,
	hpmax    = 12,
	ac       = 10,
	tohit    = 25,
	dmgmin   = 3,
	dmgmax   = 7,
	expvalue = 155,
	resfire  = 75,
	retreatdistance = 3,
	warcrydistance  = 6,
	warcrytime      = 825
}

register_npc( "devil_kin_sword", "fallen_sword" )
{
	name     = "devil kin",
	intf     = 2,
	color    = LIGHTRED,
	group    = {2,3,4},
	level    = 5,
	hpmin    = 8,
	hpmax    = 12,
	ac       = 20,
	tohit    = 25,
	dmgmin   = 4,
	dmgmax   = 10,
	expvalue = 180,
	resfire  = 75,
	retreatdistance = 3,
	warcrydistance  = 6,
	warcrytime      = 825
}

register_npc( "dark_one_spear", "fallen_spear" )
{
	name     = "dark one",
	intf     = 3,
	color    = LIGHTBLUE,
	group    = {3,4,5},
	level    = 7,
	hpmin    = 10,
	hpmax    = 18,
	ac       = 15,
	tohit    = 30,
	dmgmin   = 4,
	dmgmax   = 8,
	expvalue = 255,
	reslightning    = 75,
	retreatdistance = 2,
	warcrydistance  = 7,
	warcrytime      = 975
}

register_npc( "dark_one_sword", "fallen_sword" )
{
	name     = "dark one",
	intf     = 3,
	color    = LIGHTBLUE,
	group    = {3,4,5},
	level    = 7,
	hpmin    = 12,
	hpmax    = 18,
	ac       = 25,
	tohit    = 30,
	dmgmin   = 4,
	dmgmax   = 12,
	expvalue = 280,
	reslightning    = 75,
	retreatdistance = 2,
	warcrydistance  = 7,
	warcrytime      = 975
}

--== WINGED FIENDS ==================================================--

core.register_blueprint ( "winged_fiend", "npc" )
{
	flags    = { false, core.TFLAGS, {nfAnimal} },
	ai       = { false, core.TNUMBER, AIWingedFiend },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "b",
	size     = 364,
	corpse   = "",
	spdhit   = 45,
	spdatk   = 50,
	spdmov   = 65,
	sound    = "monsters/bat/bat",

	-- Jarulf 3.8.1: "Some monster types (Winged Fiends and Hork Spawns) never drop items."
	OnDrop = function(self)
		if (self.flags[nfUnique]) then
			npc.standard_drop(self)
		end
	end
}


register_npc( "fiend", "winged_fiend" )
{
	name     = "fiend",
	intf     = 0,
	color    = RED,
	level    = 3,
	group    = {2,3},
	hpmin    = 1,
	hpmax    = 3,
	tohit    = 35,
	ac       = 0,
	dmgmin   = 1,
	dmgmax   = 6,
	expvalue = 102
}

register_npc( "blink", "winged_fiend" )
{
	name     = "blink",
	intf     = 1,
	color    = BLUE,
	level    = 7,
	group    = {3,4,5},
	hpmin    = 6,
	hpmax    = 14,
	tohit    = 45,
	ac       = 15,
	dmgmin   = 1,
	dmgmax   = 8,
	expvalue = 340,

	OnHit = function(self,tgt)
		local x, y
		if tgt then
			x, y = tgt.x, tgt.y
		else
			x, y = self.x, self.y
		end
		local level    = self:get_level()
		self.targetx, self.targety = level:find_nearest( coord.new(x, y), efNoMonsters, efNoObstacles):get()
		if self:is_visible() then
			ui.msg(self:get_name(0)..' teleports.')
		end
		self:displace( self:get_target() )
		self.scount = self.scount - self.spdmov
	end
}

register_npc( "gloom", "winged_fiend" )
{
	name     = "gloom",
	intf     = 2,
	color    = DARKGRAY,
	level    = 9,
	group    = {4,5,6},
	hpmin    = 14,
	hpmax    = 18,
	tohit    = 35,
	ac       = 35,
	dmgmin   = 4,
	dmgmax   = 12,
	expvalue = 509,
	resmagic = 75
}

register_npc( "familiar", "winged_fiend" )
{
	name     = "familiar",
	flags    = {nfDemon},
	intf     = 3,
	color    = YELLOW,
	level    = 13,
	group    = {6,7,8},
	hpmin    = 10,
	hpmax    = 17,
	tohit    = 50,
	ac       = 35,
	dmgmin   = 4,
	dmgmax   = 16,
	expvalue = 448,

	resmagic     = 75,
	reslightning = 100
}

--== GOATS ==========================================================--

core.register_blueprint ( "goat", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon, nfOpenDoors} },
	ai       = { false, core.TNUMBER, AIGoat },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "g",
	size     = 1030,
	corpse   = "corpse",
	spdhit   = 30,
	spdatk   = 60,
	spdmov   = 40,
	sound    = "monsters/goatmace/goat"
}

register_npc ( "flesh_clan", "goat" )
{
	name     = "flesh clan",
	intf     = 0,
	color    = BROWN,
	level    = 1,
	group    = {4,5,6},
	hpmin    = 15,
	hpmax    = 22,
	tohit    = 50,
	ac       = 40,
	dmgmin   = 4,
	dmgmax   = 10,
	expvalue = 460
}

register_npc ( "stone_clan", "goat" )
{
	name     = "stone clan",
	intf     = 1,
	color    = LIGHTGRAY,
	level    = 10,
	group    = {5,6,7},
	hpmin    = 20,
	hpmax    = 27,
	tohit    = 60,
	ac       = 40,
	dmgmin   = 6,
	dmgmax   = 12,
	expvalue = 685,
	resmagic = 75
}

register_npc ( "fire_clan", "goat" )
{
	name     = "fire clan",
	intf     = 2,
	color    = RED,
	level    = 12,
	group    = {6,7,8},
	hpmin    = 25,
	hpmax    = 32,
	tohit    = 70,
	ac       = 45,
	dmgmin   = 8,
	dmgmax   = 16,
	expvalue = 906,
	resfire  = 75
}

register_npc ( "night_clan", "goat" )
{
	name     = "night clan",
	intf     = 3,
	color    = DARKGRAY,
	level    = 14,
	group    = {7,8,9},
	hpmin    = 27,
	hpmax    = 35,
	tohit    = 80,
	ac       = 50,
	dmgmin   = 10,
	dmgmax   = 20,
	expvalue = 1190,
	resmagic = 75
}

-- goat archers --

core.register_blueprint ( "goat_archer", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon, nfOpenDoors} },
	ai       = { false, core.TNUMBER, AIGoatArcher },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "A",
	size     = 1040,
	corpse   = "corpse",
	spdhit   = 30,
	spdatk   = 80,
	spdmov   = 40,
	sound    = "monsters/goatbow/goatb"
}

register_npc ( "flesh_clan_archer", "goat_archer" )
{
	name     = "flesh clan archer",
	intf     = 0,
	color    = BROWN,
	level    = 8,
	group    = {4,5,6},
	hpmin    = 10,
	hpmax    = 17,
	tohit    = 35,
	ac       = 35,
	dmgmin   = 1,
	dmgmax   = 7,
	expvalue = 448
}

register_npc ( "stone_clan_archer", "goat_archer" )
{
	name     = "stone clan archer",
	intf     = 1,
	color    = LIGHTGRAY,
	level    = 8,
	group    = {5,6,7},
	hpmin    = 15,
	hpmax    = 20,
	tohit    = 40,
	ac       = 35,
	dmgmin   = 2,
	dmgmax   = 9,
	expvalue = 645,
	resmagic = 75
}

register_npc ( "fire_clan_archer", "goat_archer" )
{
	name     = "fire clan archer",
	intf     = 2,
	color    = RED,
	level    = 8,
	group    = {6,7,8},
	resfire  = 75,
	hpmin    = 20,
	hpmax    = 25,
	tohit    = 45,
	ac       = 35,
	dmgmin   = 3,
	dmgmax   = 11,
	expvalue = 822
}

register_npc ( "night_clan_archer", "goat_archer" )
{
	name     = "night clan archer",
	intf     = 3,
	color    = DARKGRAY,
	level    = 8,
	group    = {7,8,9},
	hpmin    = 25,
	hpmax    = 32,
	tohit    = 50,
	ac       = 40,
	dmgmin   = 4,
	dmgmax   = 13,
	expvalue = 1092,
	resmagic = 75
}


--== HIDDENS ========================================================--

core.register_blueprint ( "hidden", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon, nfInvisible} },
	ai       = { false, core.TNUMBER, AIHidden },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "n",
	size     = 992,
	corpse   = "corpse",
	spdhit   = 40,
	spdatk   = 60,
	spdmov   = 40,
	sound    = "monsters/sneak/sneak"
}

register_npc ( "hidden", "hidden" )
{
	name     = "hidden",
	intf     = 0,
	color    = DARKGRAY,
	level    = 5,
	group    = {2,3,4,5},
	hpmin    = 4,
	hpmax    = 12,
	tohit    = 35,
	ac       = 25,
	dmgmin   = 3,
	dmgmax   = 6,
	expvalue = 278
}

register_npc ( "stalker", "hidden" )
{
	name     = "stalker",
	intf     = 1,
	color    = MAGENTA,
	level    = 9,
	group    = {5,6,7},
	hpmin    = 4,
	hpmax    = 15,
	tohit    = 40,
	ac       = 30,
	dmgmin   = 8,
	dmgmax   = 16,
	expvalue = 630
}

register_npc ( "unseen", "hidden" )
{
	name     = "unseen",
	intf     = 2,
	color    = LIGHTGRAY,
	level    = 11,
	group    = {6,7,8},
	hpmin    = 4,
	hpmax    = 17,
	tohit    = 45,
	ac       = 30,
	dmgmin   = 12,
	dmgmax   = 20,
	expvalue = 935,
	resmagic = 75
}

register_npc ( "illusion_weaver", "hidden" )
{
	name     = "illusion weaver",
	intf     = 3,
	color    = YELLOW,
	level    = 13,
	group    = {8,9,10},
	flags    = {nfDemon, nfInvisible, nfInvulnerable},
	hpmin    = 20,
	hpmax    = 30,
	tohit    = 60,
	ac       = 30,
	dmgmin   = 16,
	dmgmax   = 24,
	expvalue = 1500,
	resmagic = 75,
	resfire  = 75
}

--== Overlords ======================================================--

core.register_blueprint ( "overlord", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon} },
	ai       = { false, core.TNUMBER, AIOverlord },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "O",
	size     = 1130,
	corpse   = "corpse",
	spdhit   = 30,
	spdatk   = 75,
	spdmov   = 50,
	sound    = "monsters/fat/fat"
}

register_npc ( "overlord", "overlord" )
{
	name     = "overlord",
	intf     = 0,
	color    = RED,
	level    = 10,
	group    = {5,6,7},
	hpmin    = 30,
	hpmax    = 40,
	tohit    = 55,
	ac       = 55,
	dmgmin   = 6,
	dmgmax   = 12,
	expvalue = 635
}

register_npc ( "mud_man", "overlord" )
{
	name     = "mud man",
	intf     = 1,
	color    = BLUE,
	level    = 14,
	group    = {7,8,9},
	hpmin    = 50,
	hpmax    = 62,
	tohit    = 60,
	ac       = 60,
	dmgmin   = 8,
	dmgmax   = 16,
	expvalue = 1165
}

register_npc ( "toad_demon", "overlord" )
{
	name     = "toad demon",
	intf     = 2,
	color    = BROWN,
	level    = 16,
	group    = {8,9,10},
	hpmin    = 67,
	hpmax    = 80,
	tohit    = 70,
	ac       = 65,
	dmgmin   = 8,
	dmgmax   = 16,
	expvalue = 1380,
	resmagic = 100
}

register_npc ( "flayed_one", "overlord" )
{
	name     = "flayed one",
	intf     = 3,
	color    = LIGHTRED,
	level    = 20,
	group    = {10,11,12},
	hpmin    = 80,
	hpmax    = 100,
	tohit    = 85,
	ac       = 70,
	dmgmin   = 10,
	dmgmax   = 20,
	expvalue = 2058,
	resmagic = 75,
	resfire  = 100
}

--== Horned Demons ==================================================--

core.register_blueprint ( "horned", "npc" )
{
	flags    = { false, core.TFLAGS, {nfAnimal, nfOpenDoors} },
	ai       = { false, core.TNUMBER, AIHornedDemon },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "J",
	size     = 1630,
	corpse   = "corpse",
	spdhit   = 30,
	spdatk   = 70,
	spdmov   = 40,
	sound    = "monsters/rhino/rhino"
}

register_npc ( "horned_demon", "horned" )
{
	name     = "horned demon",
	intf     = 0,
	color    = LIGHTGRAY,
	level    = 13,
	group    = {7,8,9},
	hpmin    = 20,
	hpmax    = 40,
	tohit    = 60,
	ac       = 40,
	dmgmin   = 2,
	dmgmax   = 16,
	expvalue = 1172
}

register_npc ( "mud_runner", "horned" )
{
	name     = "mud runner",
	intf     = 0,
	color    = BROWN,
	level    = 15,
	group    = {8,9,10},
	hpmin    = 25,
	hpmax    = 45,
	tohit    = 60,
	ac       = 40,
	dmgmin   = 2,
	dmgmax   = 16,
	expvalue = 1404
}

register_npc ( "frost_charger", "horned" )
{
	name     = "frost charger",
	intf     = 0,
	color    = BLUE,
	level    = 17,
	group    = {9,10,11},
	hpmin    = 30,
	hpmax    = 50,
	tohit    = 60,
	ac       = 40,
	dmgmin   = 2,
	dmgmax   = 16,
	expvalue = 1720,
	resmagic     = 100,
	reslightning = 75
}

register_npc ( "obsidian_lord", "horned" )
{
	name     = "obsidian lord",
	intf     = 0,
	color    = DARKGRAY,
	level    = 19,
	group    = {10,11,12},
	hpmin    = 35,
	hpmax    = 55,
	tohit    = 60,
	ac       = 40,
	dmgmin   = 2,
	dmgmax   = 16,
	expvalue = 1809,
	resmagic     = 100,
	reslightning = 75
}

--== Magma Demons ===================================================--

core.register_blueprint ( "magma", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon, nfOpenDoors} },
	ai       = { false, core.TNUMBER, AIOverlord },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "M",
	size     = 1680,
	corpse   = "corpse",
	spdhit   = 35,
	spdatk   = 70,
	spdmov   = 50,
	sound    = "monsters/magma/magma",
	resmagic = 100,
	resfire  = { false, core.TNUMBER, 100 }
}

register_npc ( "magma_demon", "magma" )
{
	name     = "magma demon",
	intf     = 0,
	color    = RED,
	level    = 13,
	group    = {8,9},
	hpmin    = 25,
	hpmax    = 35,
	tohit    = 45,
	ac       = 45,
	dmgmin   = 2,
	dmgmax   = 10,
	expvalue = 1076,
	resfire  = 75
}

register_npc ( "bloodstone", "magma" )
{
	name     = "blood stone",
	intf     = 1,
	color    = YELLOW,
	level    = 14,
	group    = {8,9,10},
	hpmin    = 28,
	hpmax    = 37,
	tohit    = 50,
	ac       = 45,
	dmgmin   = 2,
	dmgmax   = 12,
	expvalue = 1309
}

register_npc ( "hell_stone", "magma" )
{
	name     = "hell stone",
	intf     = 2,
	color    = BLUE,
	level    = 16,
	group    = {9,10,11},
	hpmin    = 30,
	hpmax    = 40,
	tohit    = 60,
	ac       = 50,
	dmgmin   = 2,
	dmgmax   = 20,
	expvalue = 1680
}

register_npc ( "lava_lord", "magma" )
{
	name     = "lava lord",
	intf     = 3,
	color    = LIGHTBLUE,
	level    = 18,
	group    = {9,10,11},
	hpmin    = 35,
	hpmax    = 42,
	tohit    = 75,
	ac       = 60,
	dmgmin   = 4,
	dmgmax   = 24,
	expvalue = 2124
}

--== Gargoyles ======================================================--

core.register_blueprint ( "gargoyle", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon, nfOpenDoors} },
	ai       = { false, core.TNUMBER, AIScavenger },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "G",
	size     = 1650,
	corpse   = "corpse",
	spdhit   = 50,
	spdatk   = 70,
	spdmov   = 70,
	sound    = "monsters/gargoyle/gargoyle",
	resmagic     = 100
}

register_npc ( "winged_demon", "gargoyle" )
{
	name     = "winged demon",
	intf     = 0,
	color    = RED,
	level    = 9,
	group    = {5,6,7},
	hpmin    = 22,
	hpmax    = 30,
	tohit    = 50,
	ac       = 45,
	dmgmin   = 10,
	dmgmax   = 16,
	expvalue = 662,
	resfire  = 75
}

register_npc ( "gargoyle", "gargoyle" )
{
	name     = "gargoyle",
	intf     = 1,
	color    = BROWN,
	level    = 13,
	group    = {7,8,9},
	hpmin    = 30,
	hpmax    = 45,
	tohit    = 60,
	ac       = 45,
	dmgmin   = 10,
	dmgmax   = 16,
	expvalue = 1205,
	reslightning = 75
}

register_npc ( "blood_claw", "gargoyle" )
{
	name     = "blood claw",
	intf     = 2,
	color    = LIGHTRED,
	level    = 19,
	group    = {9,10,11},
	hpmin    = 37,
	hpmax    = 62,
	tohit    = 80,
	ac       = 50,
	dmgmin   = 14,
	dmgmax   = 22,
	expvalue = 1873,
	resfire  = 100
}

register_npc ( "death_wing", "gargoyle" )
{
	name     = "death wing",
	intf     = 3,
	color    = BLUE,
	level    = 23,
	group    = {10,11,12},
	hpmin    = 45,
	hpmax    = 75,
	tohit    = 95,
	ac       = 60,
	dmgmin   = 16,
	dmgmax   = 28,
	expvalue = 2278,
	reslightning = 100
}

--== Spitting Terrors ===============================================--

core.register_blueprint ( "spitting", "npc" )
{
	flags    = { false, core.TFLAGS, {nfAnimal} },
	ai       = { false, core.TNUMBER, AISkeleton },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "d",
	size     = 716,
	corpse   = "corpse",
	spdhit   = 40,
	spdatk   = 60,
	spdmov   = 40,
	sound    = "monsters/acid/acid",
	resmagic = { false, core.TNUMBER, 100 } -- confim?
}

register_npc ( "acid_beast", "spitting" )
{
	name     = "acid beast",
	intf     = 0,
	color    = BROWN,
	level    = 11,
	group    = {6,7,8},
	hpmin    = 20,
	hpmax    = 33,
	tohit    = 40,
	ac       = 30,
	dmgmin   = 4,
	dmgmax   = 12,
	expvalue = 846
}

register_npc ( "poison_spitter", "spitting" )
{
	name     = "poison spitter",
	intf     = 1,
	color    = DARKGRAY,
	level    = 15,
	group    = {8,9,10},
	hpmin    = 30,
	hpmax    = 42,
	tohit    = 45,
	ac       = 30,
	dmgmin   = 4,
	dmgmax   = 16,
	expvalue = 1248
}

register_npc ( "pit_beast", "spitting" )
{
	name     = "pit beast",
	intf     = 2,
	color    = BLUE,
	level    = 21,
	group    = {10,11,12},
	hpmin    = 40,
	hpmax    = 55,
	tohit    = 55,
	ac       = 35,
	dmgmin   = 8,
	dmgmax   = 18,
	expvalue = 2060,
	resmagic = 75
}

register_npc ( "lava_maw", "spitting" )
{
	name     = "lava maw",
	intf     = 3,
	color    = RED,
	level    = 25,
	group    = {12,13,14},
	hpmin    = 50,
	hpmax    = 75,
	tohit    = 65,
	ac       = 35,
	dmgmin   = 10,
	dmgmax   = 20,
	expvalue = 2940,
	resmagic = 75,
	resfire  = 100
}

--== Mages ==========================================================--

core.register_blueprint ( "mage", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon, nfOpenDoors} },
	ai       = { false, core.TNUMBER, AIMage },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "m",
	size     = 2000,
	corpse   = "corpse",
	spdmov   = 5,
	spdatk   = 100,
	spdhit   = 40,
	sound    = "monsters/mage/mage",
	ac       = 0
}

register_npc ( "counselor", "mage" )
{
	name     = "counselor",
	intf     = 0,
	color    = RED,
	level    = 25,
	group    = {13,14},
	hpmin    = 35,
	hpmax    = 35,
	tohit    = 90,
	dmgmin   = 8,
	dmgmax   = 20,
	expvalue = 3876,
	resmagic = 75,
	resfire  = 75,
	reslightning = 75
}

register_npc ( "magistrate", "mage" )
{
	name     = "magistrate",
	intf     = 1,
	color    = RED,
	level    = 27,
	group    = {14,15},
	hpmin    = 42,
	hpmax    = 42,
	tohit    = 100,
	dmgmin   = 10,
	dmgmax   = 24,
	expvalue = 4478,
	resmagic = 75,
	resfire  = 100,
	reslightning = 75
}

register_npc ( "cabalist", "mage" )
{
	name     = "cabalist",
	intf     = 2,
	color    = RED,
	level    = 29,
	group    = {15},
	hpmin    = 60,
	hpmax    = 60,
	tohit    = 110,
	dmgmin   = 14,
	dmgmax   = 30,
	expvalue = 4929,
	resmagic = 75,
	resfire  = 75,
	reslightning = 100
}

register_npc ( "advocate", "mage" )
{
	name     = "cabalist",
	intf     = 2,
	color    = RED,
	level    = 29,
	group    = {15},
	hpmin    = 72,
	hpmax    = 72,
	tohit    = 120,
	dmgmin   = 15,
	dmgmax   = 25,
	expvalue = 4968,
	resmagic = 100,
	resfire  = 75,
	reslightning = 100
}

--== Balrogs ========================================================--

core.register_blueprint ( "balrog", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon, nfOpenDoors} },
	ai       = { false, core.TNUMBER, AISkeleton },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "W",
	size     = 2200,
	corpse   = "corpse",
	spdmov   = 35,
	spdatk   = 70,
	spdhit   = 5,
	sound    = "monsters/mega/mega",
	resmagic = { false, core.TNUMBER, 75 },
	resfire  = { false, core.TNUMBER, 100 }
}

register_npc ( "slayer", "balrog" )
{
	name     = "slayer",
	intf     = 0,
	color    = RED,
	level    = 20,
	group    = {10,11,12},
	hpmin    = 60,
	hpmax    = 70,
	tohit    = 100,
	ac       = 60,
	dmgmin   = 12,
	dmgmax   = 20,
	expvalue = 2300
}

register_npc ( "guardian", "balrog" )
{
	name     = "guardian",
	intf     = 1,
	color    = RED,
	level    = 22,
	group    = {11,12,13},
	hpmin    = 70,
	hpmax    = 80,
	tohit    = 110,
	ac       = 65,
	dmgmin   = 14,
	dmgmax   = 22,
	expvalue = 2714
}

register_npc ( "vortex_lord", "balrog" )
{
	name     = "vortex lord",
	intf     = 2,
	color    = RED,
	level    = 24,
	group    = {12,13,14},
	hpmin    = 80,
	hpmax    = 90,
	tohit    = 120,
	ac       = 70,
	dmgmin   = 18,
	dmgmax   = 24,
	expvalue = 3252
}

register_npc ( "balrog", "balrog" )
{
	name     = "balrog",
	intf     = 3,
	color    = RED,
	level    = 26,
	group    = {13,14,15},
	hpmin    = 90,
	hpmax    = 100,
	tohit    = 130,
	ac       = 75,
	dmgmin   = 22,
	dmgmax   = 30,
	expvalue = 3643
}

--== Lightning Demons ===============================================--

core.register_blueprint ( "lightning", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon, nfOpenDoors} },
	ai       = { false, core.TNUMBER, AISkeleton },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "L",
	size     = 1740,
	corpse   = "corpse",
	spdmov   = 40,
	spdatk   = 90,
	spdhit   = 20,
	sound    = "monsters/thin/thin",
}

register_npc ( "red_storm", "lightning" )
{
	name     = "red storm",
	intf     = 0,
	color    = RED,
	level    = 18,
	group    = {9,10,11},
	hpmin    = 27,
	hpmax    = 55,
	tohit    = 80,
	ac       = 30,
	dmgmin   = 8,
	dmgmax   = 18,
	expvalue = 2160,
	resmagic = 100,
	reslightning  = 75
}

register_npc ( "storm_rider", "lightning" )
{
	name     = "storm rider",
	intf     = 1,
	color    = RED,
	level    = 20,
	group    = {10,11,12},
	hpmin    = 30,
	hpmax    = 60,
	tohit    = 80,
	ac       = 30,
	dmgmin   = 8,
	dmgmax   = 18,
	expvalue = 2391,
	resmagic = 75,
	reslightning  = 100
}

register_npc ( "storm_lord", "lightning" )
{
	name     = "storm lord",
	intf     = 2,
	color    = RED,
	level    = 22,
	group    = {11,12,13},
	hpmin    = 37,
	hpmax    = 67,
	tohit    = 85,
	ac       = 35,
	dmgmin   = 12,
	dmgmax   = 24,
	expvalue = 2775,
	resmagic = 75,
	reslightning  = 50
}

register_npc ( "maelstorm", "lightning" )
{
	name     = "maelstorm",
	intf     = 3,
	color    = RED,
	level    = 22,
	group    = {12,13,14},
	hpmin    = 45,
	hpmax    = 75,
	tohit    = 90,
	ac       = 40,
	dmgmin   = 12,
	dmgmax   = 28,
	expvalue = 3117,
	resmagic = 75,
	reslightning  = 50
}

--== Vipers =========================================================--

core.register_blueprint ( "viper", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon} },
	ai       = { false, core.TNUMBER, AISkeleton },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "V",
	size     = 1270,
	corpse   = "corpse",
	spdmov   = 55,
	spdatk   = 65,
	spdhit   = 25,
	sound    = "monsters/snake/snake",
}

register_npc ( "cave_viper", "viper" )
{
	name     = "cave viper",
	intf     = 0,
	color    = RED,
	level    = 21,
	group    = {11,12,13},
	hpmin    = 50,
	hpmax    = 75,
	tohit    = 90,
	ac       = 60,
	dmgmin   = 8,
	dmgmax   = 20,
	expvalue = 2725,
	resmagic = 100
}

register_npc ( "fire_drake", "viper" )
{
	name     = "fire drake",
	intf     = 1,
	color    = RED,
	level    = 23,
	group    = {12,13,14},
	hpmin    = 60,
	hpmax    = 85,
	tohit    = 105,
	ac       = 65,
	dmgmin   = 12,
	dmgmax   = 24,
	expvalue = 3139,
	resmagic = 100,
	resfire  = 75
}

register_npc ( "gold_viper", "viper" )
{
	name     = "gold viper",
	intf     = 2,
	color    = RED,
	level    = 25,
	group    = {13,14},
	hpmin    = 70,
	hpmax    = 80,
	tohit    = 120,
	ac       = 70,
	dmgmin   = 15,
	dmgmax   = 26,
	expvalue = 3484,
	resmagic = 100,
	reslightning = 75
}

register_npc ( "azure_drake", "viper" )
{
	name     = "azure drake",
	intf     = 3,
	color    = RED,
	level    = 27,
	group    = {15},
	hpmin    = 80,
	hpmax    = 100,
	tohit    = 120,
	ac       = 75,
	dmgmin   = 18,
	dmgmax   = 30,
	expvalue = 3791,
	resfire = 75,
	reslightning = 75
}

--== Succubi ========================================================--

core.register_blueprint ( "succubus", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon, nfOpenDoors} },
	ai       = { false, core.TNUMBER, AISkeleton },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "f",
	size     = 980,
	corpse   = "corpse",
	spdmov   = 40,
	spdatk   = 80,
	spdhit   = 35,
	sound    = "monsters/succ/succ",
}

register_npc ( "succubus", "succubus" )
{
	name     = "succubus",
	intf     = 0,
	color    = RED,
	level    = 24,
	group    = {12,13,14},
	hpmin    = 60,
	hpmax    = 75,
	tohit    = 100,
	ac       = 60,
	dmgmin   = 1,
	dmgmax   = 20,
	expvalue = 3696,
	resmagic = 75
}

register_npc ( "snow_witch", "succubus" )
{
	name     = "snow witch",
	intf     = 1,
	color    = RED,
	level    = 26,
	group    = {13,14,15},
	hpmin    = 67,
	hpmax    = 87,
	tohit    = 110,
	ac       = 65,
	dmgmin   = 1,
	dmgmax   = 24,
	expvalue = 4084,
	reslightning = 75
}

register_npc ( "hell_spawn", "succubus" )
{
	name     = "hell spawn",
	intf     = 2,
	color    = RED,
	level    = 28,
	group    = {14,15},
	hpmin    = 75,
	hpmax    = 100,
	tohit    = 115,
	ac       = 75,
	dmgmin   = 1,
	dmgmax   = 30,
	expvalue = 4480,
	resmagic = 75,
	reslightning = 100
}

register_npc ( "soul_burner", "succubus" )
{
	name     = "soul burner",
	intf     = 3,
	color    = RED,
	level    = 30,
	group    = {15},
	hpmin    = 70,
	hpmax    = 112,
	tohit    = 120,
	ac       = 85,
	dmgmin   = 1,
	dmgmax   = 35,
	expvalue = 4644,
	resmagic = 75,
	resfire  = 100,
	reslightning = 75
}

--== Knights ========================================================--

core.register_blueprint ( "knight", "npc" )
{
	flags    = { false, core.TFLAGS, {nfDemon, nfOpenDoors} },
	ai       = { false, core.TNUMBER, AISkeleton },
	amountmin= { false, core.TNUMBER, 1 },
	amountmax= { false, core.TNUMBER, 4 },
	pic      = "k",
	size     = 2120,
	corpse   = "corpse",
	spdmov   = 40,
	spdatk   = 80,
	spdhit   = 20,
	sound    = "monsters/dark/dark",
}

register_npc ( "black_knight", "knight" )
{
	name     = "black knight",
	intf     = 0,
	color    = RED,
	level    = 24,
	group    = {12,13,14},
	hpmin    = 75,
	hpmax    = 75,
	tohit    = 110,
	ac       = 75,
	dmgmin   = 15,
	dmgmax   = 20,
	expvalue = 3360,
	resmagic = 75,
	reslightning = 75
}

register_npc ( "doom_guard", "knight" )
{
	name     = "doom guard",
	intf     = 1,
	color    = RED,
	level    = 26,
	group    = {13,14,15},
	hpmin    = 82,
	hpmax    = 82,
	tohit    = 130,
	ac       = 75,
	dmgmin   = 18,
	dmgmax   = 25,
	expvalue = 3650,
	resmagic = 75,
	resfire = 75
}

register_npc ( "steel_lord", "knight" )
{
	name     = "steel lord",
	intf     = 2,
	color    = RED,
	level    = 28,
	group    = {14,15},
	hpmin    = 90,
	hpmax    = 90,
	tohit    = 120,
	ac       = 80,
	dmgmin   = 20,
	dmgmax   = 30,
	expvalue = 4252,
	resmagic = 75,
	resfire  = 100,
	reslightning = 75
}

register_npc ( "blood_knight", "knight" )
{
	name     = "blood knight",
	intf     = 3,
	color    = RED,
	level    = 30,
	group    = {13,14},
	hpmin    = 130,
	hpmax    = 130,
	tohit    = 130,
	ac       = 85,
	dmgmin   = 25,
	dmgmax   = 35,
	expvalue = 5130,
	resmagic = 100,
	resfire  = 75,
	reslightning = 100
}
