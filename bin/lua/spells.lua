core.register_blueprint "spell_book"
{
	level        = { true, core.TNUMBER },
	price        = { true, core.TNUMBER },
}

core.register_blueprint "spell_staff"
{
	level        = { false, core.TNUMBER },
	charge_cost  = { false, core.TNUMBER, 10 },
	charges_min  = { true,  core.TNUMBER },
	charges_max  = { true,  core.TNUMBER },
}

core.register_blueprint "spell_scroll"
{
	price        = { true,  core.TNUMBER },
	level        = { false, core.TNUMBER, 1 },
	mag          = { false, core.TNUMBER, 0 },
}

core.register_blueprint "spell"
{
	id           = { true,  core.TSTRING },
	name         = { true,  core.TSTRING },
	page         = { false, core.TNUMBER, 0 },
	type         = { false, core.TNUMBER, 0 },
	target       = { false, core.TNUMBER, 0 },
	cost         = { false, core.TFUNC,   function() return 0 end },
	dmin         = { false, core.TANY,    0 },
	dmax         = { false, core.TANY,    0 },
	dminmlvl     = { false, core.TANY },
	dmaxmlvl     = { false, core.TANY },
	magic        = { false, core.TNUMBER },
	picture      = { false, core.TSTRING },

	color        = { false, core.TNUMBER, LIGHTGRAY },
	sound1       = { false, core.TSTRING },
	sound2       = { false, core.TSTRING },

	effect       = { false, core.TNUMBER, SPELL_SCRIPT },
	townsafe     = { false, core.TBOOL,   false },

	script       = { false,  core.TFUNC },

	book         = { false, "spell_book" },
	scroll       = { false, "spell_scroll" },
	staff        = { false, "spell_staff" },
}

-- Skills --

register_spell "repair_items"
{
	name     = "Repair Items",
	townsafe = true,

	script   = function(slvl)
	    shops.util.OnEnter = shops.util.funcs.FreeRepair
		return world.shop( "util" )
	end,
}

register_spell "recharge_staves"
{
	name     = "Recharge Staves",
	townsafe = true,

	script   = function(slvl)
	    shops.util.OnEnter = shops.util.funcs.FreeRecharge
		return world.shop( "util" )
	end,
}

-- Scroll only spells --

register_spell "identify"
{
	name     = "Identify",
	cost     = function(slvl) return math.max(13 - 2 * (slvl-1),1) end,
	magic	 = 23,
	townsafe = true,
	sound1   = 'cast6',

	script   = function(slvl)
	    shops.util.OnEnter = shops.util.funcs.FreeIdentify
		return world.shop( "util" )
	end,

	scroll       = { price = 100 },
	staff        = { charges_min = 8, charges_max  = 12 },
}

register_spell "infravision"
{
	name     = "Infravision",
	cost     = function(slvl) return math.max(40 - 5 * (slvl-1),1) end,
	magic	 = 36,
	color    = LIGHTMAGENTA,
	sound1   = 'cast8',
	sound2   = 'infravis',

	script   = function(slvl, caster, target)
		caster.flags[ nfInfravision ] = true
		ui.msg('Your senses were magically enhanced.')
		--TODO:
		--this spell should last { 7920*math.floor((9/8)^slvl) } game ticks
		return true
	end,

	scroll       = { price = 600, level = 8, mag = 23 },
}

-- Page 1 spells

register_spell "firebolt"
{
	name     = "Firebolt",
	page     = 1,
	type     = DAMAGE_FIRE,
	dmin     = function(slvl, caster) return 1 + slvl + math.floor(caster.mag / 8) end,
	dmax     = function(slvl, caster) return 10 + slvl + math.floor(caster.mag / 8) end,
	cost     = function(slvl) return math.max(6 - math.floor((slvl-1)*0.5),3) end,
	magic    = 15,
	target   = SPELL_TARGET,
	effect   = SPELL_BOLT,
	color    = LIGHTRED,
	picture  = "*",
	sound1   = 'cast2',
	sound2   = 'fbolt1',

	book     = { level = 1, price = 1000 },
	staff    = { level = 1, charge_cost = 10, charges_min = 40, charges_max = 80 },
}
--[[
-- this is going to be a real bitch to code, asynch TAnimation code needed
register_spell "charged_bolt"
{
	name     = "Charged Bolt",
	page     = 1,
	type     = DAMAGE_LIGHTNING,
	dmin     = function(slvl) return 1 end,
	dmax     = function(slvl, caster) return 1 + math.floor(caster.mag / 4) end,
	count    = function(slvl) return 4 + math.floor(slvl / 2) end,
	cost     = function(slvl) ,
	magic    = 25,
	color    = YELLOW,
	target   = SPELL_DIRECTION,
	effect   = SPELL_CHARGED,
	picture  = "*",
	sound1   = 'cast2',
	sound2   = 'cbolt',

	book     = { level = 1, price = 1000 },
	staff    = { level = 1, charge_cost = 10, charges_min = 40, charges_max = 80 },
}
]]--

register_spell "holy_bolt"
{
	name     = "Holy Bolt",
	page     = 1,
	type     = DAMAGE_HOLY,
	dmin     = function(slvl, caster) return 9 + caster.level end,
	dmax     = function(slvl, caster) return 18 + caster.level end,
	cost     = function(slvl) return math.max(8 - slvl,3) end,
	magic    = 20,
	target   = SPELL_TARGET,
	effect   = SPELL_BOLT,
	color    = WHITE,
	picture  = "*",
	sound1   = 'cast2',
	sound2   = 'holybolt',

	book     = { level = 1, price = 1000 },
	staff    = { level = 1, charge_cost = 10, charges_min = 40, charges_max = 80 },
}

register_spell "healing"
{
	name     = "Healing",
	page     = 1,
	dmin     = function(slvl, caster) return (1 + caster.level + slvl) end,
	dmax     = function(slvl, caster) return (10 + 4*caster.level + 6*slvl) end,
	cost     = function(slvl, caster) return math.max(8 + 2*caster.level - 3*slvl,0) end,
	magic    = 17,
	color    = WHITE,
	townsafe = true,
	sound1   = 'cast8',

	script   = function(slvl, caster)
		ui.play_sound('sfx/misc/cast8.wav')
		caster.hp = math.min(caster.hpmax, (caster.hp + math.random( 1 + caster.level + slvl, 10 + 4*caster.level + 6*slvl )))
		return true
	end,

	book     = { level = 1, price = 1000 },
	scroll   = { price = 50 },
	staff    = { level = 1, charge_cost = 10, charges_min = 20, charges_max = 40 },
}

--[[
-- This will have to wait until fire-layer is implemented
register_spell "inferno"
{
	name     = "Inferno",
	page     = 1,
	type     = DAMAGE_FIRE,
	dmin     = function(slvl, caster) return 3 end,
	dmax     = function(slvl, caster) return 6 + (3*caster.level)/2 end,
	cost     = function(slvl) return math.max(12 - slvl,6) end,
	magic    = 20,
	target   = SPELL_DIRECTION,
	effect   = SPELL_BLAST,
	color    = RED,
	picture  = "*",
	range    = 3,
	sound1   = 'cast2',
	sound2   = '', // TODO

	book     = { level = 1, price = 1000 },
	scroll   = { price = 100, mag = 19 },
	staff    = { level = 1, charge_cost = 10, charges_min = 20, charges_max = 40 },
}
]]--

-- Page 2 spells

--[[
-- This will have to wait until fire-layer is implemented
register_spell "fire_wall"
{
	name     = "Fire Wall",
	page     = 1,
	type     = DAMAGE_FIRE,
	dmin     = function(slvl, caster) return 4 + (2*caster.level) end,
	dmax     = function(slvl, caster) return 40 + (2*caster.level) end,
	cost     = function(slvl) return math.max(30 - 2*slvl,16) end,
	magic    = 27,
	color    = RED,
	sound1   = 'cast2',
	sound2   = '', // TODO

	book     = { level = 3, price = 6000 },
	scroll   = { level = 4, price = 400, mag = 17 },
	staff    = { level = 2, charge_cost = 80, charges_min = 8, charges_max = 16 },
}
]]--

--[[
register_spell "telekinesis"
{
	name     = "Telekinesis",
	page     = 1,
	cost     = function(slvl) return math.max(17 - 2*slvl,8) end,
	magic    = 33,
	color    = BLUE,
	target   = SPELL_TARGET,
	sound1   = 'cast2',
	sound2   = '', // TODO

	script   = function(slvl, caster)
		return true
	end,

	book     = { level = 2, price = 2500 },
	staff    = { level = 2, charge_cost = 40, charges_min = 20, charges_max = 40 },
}
]]--

--[[
register_spell "lightning"
{
	name     = "Lightning",
	page     = 1,
	type     = DAMAGE_LIGHTNING,
	dmin     = function(slvl) return 4 end,
	dmax     = function(slvl, caster) return 4 + (2 * caster.level) end,
	count    = function(slvl) return math.floor(((slvl/2)+6)/20) end,
	cost     = function(slvl) return math.max(11-slvl,6) end,
	magic    = 20,
	color    = LIGHTCYAN,
	target   = SPELL_TARGET,
	effect   = SPELL_BOLT,
	picture  = "*",
	sound1   = 'cast4',
	sound2   = '', -- secondary sound moves with bolt ltning or ltning1

	book     = { level = 4, price = 3000 },
	scroll   = { level = 3, price = 150 },
	staff    = { level = 3, charge_cost = 30, charges_min = 20, charges_max = 40 },
}
]]

register_spell "town_portal"
{
	name     = "Town Portal",
	page     = 1,
	cost     = function(slvl) return math.max(35 - ((slvl-1)*3),18) end,
	magic    = 20,
	sound1   = 'cast6',
-- special case sound2 is played in TLevel.TimeFlow (rllevel.pas)
--	sound2   = 'sentinel',

	color    = LIGHTBLUE,

	script   = function(slvl)
		ui.msg("You feel the presence of strong magic around you...")
		player:summon_portal( 6 + math.random(20) )
		return true
	end,

	book     = { level = 3, price = 3000 },
	scroll   = { level = 3, price = 200 },
	staff    = { level = 3, charge_cost = 40, charges_min = 8, charges_max = 12 },
}

register_spell "flash"
{
	name     = "Flash",
	page     = 1,
	type     = DAMAGE_MAGIC,
	dmin     = function(slvl, caster) return math.floor(((9/ 8)^slvl)*math.floor(3 * caster.level / 2)) end,
	dminmlvl = function(mlvl) return math.ceil(mlvl/32) end,
	dmax     = function(slvl, caster) return math.floor(((9/ 8)^slvl)*(3 * caster.level)) end,
	dmaxmlvl = function(mlvl) return math.floor(19*mlvl/32) end,
	cost     = function(slvl) return math.max(30 - 2 * (slvl - 1), 16) end,
	magic    = 33,
	effect   = SPELL_BLAST,
	color    = RED,
	picture  = "*",
	sound1   = 'cast4',
	sound2   = 'nova',

	book     = { level = 5, price = 7500 },
	scroll   = { level = 6, price = 500, mag = 21 },
	staff    = { level = 4, charge_cost = 100, charges_min = 20, charges_max = 40 },
}

register_spell "stone_curse"
{
	name     = "Stone Curse",
	page     = 1,
	type     = DAMAGE_MAGIC,
	cost     = function(slvl) return math.max(60 - 3 * (slvl - 1), 40) end,
	magic    = 51,
	target   = SPELL_TARGET,
	color    = DARKGRAY,
	sound1   = 'cast2',
	sound2   = 'scurse',

	script =  function( slvl, caster, target )
		if not target then return false end
		if not target:get_type() == "npc" then return false end
		if target.flags[ nfStatue ] then return false end
		target.flags[ nfStatue ] = true
		target.recov = math.max(480 + 80 * slvl, 1200)
		ui.msg(target:get_name(0)..' turned into stone.')
		return true
	end,

	book     = { level = 6, price = 12000 },
	scroll   = { level = 6, price = 800, mag = 33 },
	staff    = { level = 5, charge_cost = 160, charges_min = 8, charges_max = 16 },
}

-- Page 3 spells

register_spell "phasing"
{
	name     = "Phasing",
	page     = 1,
	type     = DAMAGE_MAGIC,
	cost     = function(slvl) return math.max(12 - 2 * (slvl-1),4) end,
	magic    = 39,
	color    = CYAN,
	sound1   = 'cast2',
	sound2   = 'teleport',

	script   = function( slvl, caster )
		caster:phasing()
		return true
	end,

	book     = { level = 7, price = 3500 },
	scroll   = { level = 6, price = 200, mag = 25 },
	staff    = { level = 6, charge_cost = 40, charges_min = 40, charges_max = 80 },
}

register_spell "mana_shield"
{
	name     = "Mana Shield",
	page     = 1,
	type     = DAMAGE_MAGIC,
	cost     = function(slvl) return 33 end,
	magic    = 25,
	color    = BLUE,
	sound1   = 'cast2',
	sound2   = 'mshield',

	script =  function( slvl, caster, target )
		if caster.mp > 0 then
			caster.flags[ nfManaShield ] = true
			ui.msg('You feel magical protection.')
			return true
		else
			return false
		end

	end,

	book     = { level = 6, price = 16000 },
	scroll   = { level = 8, price = 1200, },
	staff    = { level = 5, charge_cost = 240, charges_min = 4, charges_max = 10 },
}

--[[
register_spell "elemental"
{
	name     = "Elemental",
	page     = 1,
	type     = DAMAGE_FIRE,
	dmin     = function(slvl, caster) return math.floor(((9/ 8)^slvl)*(4 + 2 * caster.level)) end,
	dmax     = function(slvl, caster) return math.floor(((9/ 8)^slvl)*(40 + 2 * caster.level)) end,
	cost     = function(slvl) return math.max(37 - 2*slvl,10) end,
	magic    = 68,
	target   = SPELL_TARGET,
	effect   = SPELL_SCRIPT,
	color    = LIGHTRED,
	picture  = "*",
	sound1   = 'cast2',
	sound2   = 'fbolt2',

	book     = { level = 8, price = 10500 },
	staff    = { level = 6, charge_cost = 140, charges_min = 20, charges_max = 60 },
}
]]

register_spell "fireball"
{
	name     = "Fireball",
	page     = 1,
	type     = DAMAGE_FIRE,
	dmin     = function(slvl, caster) return math.floor(((9/ 8)^slvl)*(4 + 2 * caster.level)) end,
	dmax     = function(slvl, caster) return math.floor(((9/ 8)^slvl)*(40 + 2 * caster.level)) end,
	cost     = function(slvl) return math.max(16 - (slvl-1),10) end,
	magic    = 48,
	target   = SPELL_TARGET,
	effect   = SPELL_BALL,
	color    = LIGHTRED,
	picture  = "*",
	sound1   = 'cast2',
	sound2   = 'fbolt2',

	book     = { level = 8, price = 8000 },
	scroll   = { level = 8, price = 300, mag = 31 },
	staff    = { level = 7, charge_cost = 60, charges_min = 40, charges_max = 80 },
}

--[[
register_spell "flame_wave"
{
	name     = "Flame Wave",
	page     = 1,
	type     = DAMAGE_FIRE,
	dmin     = function(slvl, caster) return (6 + 6 * caster.level) end,
	dmax     = function(slvl, caster) return (60 + 6 * caster.level) end,
	cost     = function(slvl) return math.max(38 - 3*slvl,20) end,
	magic    = 54,
	target   = SPELL_TARGET,
	--5 + slvl/2 flames
	effect   = SPELL_BALL,
	color    = LIGHTRED,
	picture  = "*",
	sound1   = 'cast2',
	sound2   = 'fbolt2',

	book     = { level = 9,  price = 10000 },
	scroll   = { level = 10, price = 650, mag = 29 },
	staff    = { level = 8,  charge_cost = 130, charges_min = 20, charges_max = 40 },
}
]]

--[[
register_spell "chain_lightning"
{
	name     = "Chain Lightning",
	page     = 1,
	type     = DAMAGE_LIGHTNING,
	dmin     = function(slvl) return 4 end,
	dmax     = function(slvl, caster) return 4 + (2 * caster.level) end,
	count    = function(slvl) return math.floor(((slvl/2)+6)/20) end,
	cost     = function(slvl) return math.max(31-slvl,18) end,
	magic    = 54,
	color    = LIGHTCYAN,
	target   = SPELL_TARGET,
	--number of bolts = 1 + number of monsters on screen
	--range = math.max( 2 + slvl , 18 )
	effect   = SPELL_BOLT,
	picture  = "*",
	sound1   = 'cast4',
	sound2   = '', -- secondary sound moves with bolt ltning or ltning1

	book     = { level = 4, price = 3000 },
	scroll   = { level = 3, price = 150, mag = 35 },
	staff    = { level = 3, charge_cost = 30, charges_min = 20, charges_max = 40 },
}
]]

register_spell "guardian_spell"
{
	name     = "Guardian",
	page     = 1,
	cost     = function(slvl) return math.max(50 - 2 * (slvl-1),30) end,
	magic    = 81,
	target   = SPELL_TARGET,
	color    = BROWN,

	script   =  function( slvl, caster )
		local level = caster:get_level()
		local hydra = level:drop_npc( 'hydra', caster:get_target() )
		hydra.hpmax = math.min( math.max( 80, 80*slvl + 40*caster.level ), 2400 )
		hydra.hp = hydra.hpmax
		hydra.firebolt = math.max( player.spells[ 'firebolt' ], 1 )
		return true
	end,

	book     = { level = 9,  price = 14000 },
	scroll   = { level = 12, price = 920, mag = 51 },
	staff    = { level = 8,  charge_cost = 290, charges_min = 16, charges_max = 32 },
}

-- Page 4 Spells

--[[

register_spell "nova"
{
	name     = "Nova",
	page     = 1,
	type     = DAMAGE_LIGHTNING,
	dmin     = function(slvl, caster) return math.floor(((9/ 8)^slvl)*5 * (2 + caster.level / 2)) end,
	dmax     = function(slvl, caster) return math.floor(((9/ 8)^slvl)*5 * (15 * caster.level / 2)) end,
	cost     = function(slvl) return math.max(30 - 2 * (slvl - 1), 16) end,
	magic    = 33,
	--92 bolts
	effect   = SPELL_BLAST,
	color    = RED,
	picture  = "*",
	sound1   = 'cast4',
	sound2   = 'nova',

	book     = { level = 14, price = 21000 },
	scroll   = { level = 14, price = 1300, mag = 21 },
	staff    = { level = 10, charge_cost = 260, charges_min = 16, charges_max = 32 },
}

]]

register_spell "golem_spell"
{
	name     = "Golem",
	page     = 1,
	cost     = function(slvl) return math.max(100 - 6 * (slvl-1),60) end,
	magic    = 81,
	color    = BROWN,

	script   =  function( slvl, caster )
		local level = caster:get_level()
		local golem = level:find('golem')
		if golem then level:drop_npc( '', golem.position ) end
		golem = level:drop_npc( 'golem', caster.position )
		golem.hpmax = math.floor(caster.mpmax*2/3 + 10*slvl)
		golem.hp = golem.hpmax
		golem.tohit = 40 + 2 * caster.level + 5 * slvl
		golem.dmgmin = 8 + 2 * slvl
		golem.dmgmax = 16 + 2 * slvl
		golem.scount = 0
		return true
	end,

	book     = { level = 11, price = 18000 },
	scroll   = { level = 10, price = 1100,  mag = 51 },
	staff    = { level = 9, charge_cost = 220, charges_min = 16, charges_max = 32 },
}

register_spell "teleport"
{
	name     = "Teleport",
	page     = 1,
	type     = DAMAGE_MAGIC,
	cost     = function(slvl) return math.max(35 - 3 * (slvl-1),15) end,
	magic    = 105,
	target   = SPELL_TARGET,
	color    = LIGHTCYAN,

	script   =  function( slvl, caster )
		local level = caster:get_level()
		caster.targetx, caster.targety = level:find_nearest( caster:get_target(), efNoMonsters, efNoObstacles, efSpawnOk ):get()
		caster:displace( caster:get_target() )
		return true
	end,

	book     = { level = 14, price = 20000 },
	scroll   = { level = 14, price = 3000, mag = 81 },
	staff    = { level = 12, charge_cost = 250, charges_min = 16, charges_max = 32 },
}


--[[

register_spell "apocalypse"
{
	name     = "Apocalypse",
	page     = 1,
	type     = DAMAGE_NORMAL,
	dmin     = function(slvl, caster) return ( caster.level ) end,
	dmax     = function(slvl, caster) return ( 6 * caster.level ) end,
	cost     = function(slvl) return math.max(156 - 6 * slvl, 90) end,
	--no req to cast from uniq staff
	magic    = 149,
	target   = SPELL_TARGET
	effect   = SPELL_BOLT,
	color    = RED,
	picture  = "*",
	sound1   = 'cast4',
	sound2   = 'nova',

	--book does not drop
	--book     = { level = 19, price = 30000 },
	scroll   = { level = 22, price = 2000, mag = 117 },
	staff    = { level = 15, charge_cost = 400, charges_min = 8, charges_max = 12 },
}

]]


--[[

register_spell "bone_spirit"
{
	name     = "Bone Spirit",
	page     = 1,
	type     = DAMAGE_MAGIC,
	--costs life to cast
	cost     = function(slvl) return 6 end,
	magic    = 149,
	target   = SPELL_TARGET
	effect   = SPELL_SCRIPT,
	--inflicts damage = target.hp / 3
	color    = RED,
	picture  = "*",
	sound1   = 'cast4',
	sound2   = 'nova',

	book     = { level = 9, price = 11500 },
	staff    = { level = 7, charge_cost = 160, charges_min = 20, charges_max = 60 },
}

]]

--[[

register_spell "blood_star"
{
	name     = "Blood Star",
	page     = 1,
	type     = DAMAGE_MAGIC,
	dmin     = function(slvl, caster) return ( 3 * slvl + caster.mag / 2 - caster.mag / 8 ) end,
	dmax     = function(slvl, caster) return ( 3 * slvl + caster.mag / 2 - caster.mag / 8 ) end,
	--costs life to cast
	cost     = function(slvl) return 5 end,
	magic    = 149,
	target   = SPELL_TARGET
	effect   = SPELL_BOLT,
	color    = RED,
	picture  = "*",
	sound1   = 'cast4',
	sound2   = 'nova',

	book     = { level = 14, price = 27500 },
	staff    = { level = 13, charge_cost = 360, charges_min = 20, charges_max = 60 },
}

]]
