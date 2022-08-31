core.register_blueprint "prefix"
{
	id          = { true,  core.TSTRING },
	group		= { true,  core.TSTRING },
	name        = { true,  core.TSTRING },
	min         = { false, core.TNUMBER, 0 },
	max         = { false, core.TNUMBER, 0 },
	prefix      = true,
	level       = { false, core.TNUMBER, 1 },
	occurence   = { false, core.TFLAGS, { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_STAFF, TYPE_BOW, TYPE_RING, TYPE_AMULET } },
	incompat	= { false, core.TTABLE },
	dbl_chance  = { false, core.TBOOL, false },
	flags       = { false, core.TFLAGS, {} },
	multiplier  = { false, core.TNUMBER, 1 },
	price_base  = { false, core.TNUMBER, 0 },
	price_max   = { false, core.TNUMBER, 0 },

	OnApply     = { false,  core.TFUNC },
}


--TODO: Unformatted items need pricing data and checking of occurence.

--== +Mana ==========================--

register_prefix "pfix_hyena"
{
	name       = "Hyena's ",
	group	   = "mpmod",
	min        = 11,
	max        = 25,
	flags      = { ifCursed },
	occurence  = { TYPE_STAFF, TYPE_SSTAFF, TYPE_RING, TYPE_AMULET },
	level      = 4,
	multiplier = -2,

	OnApply = function(item,value)
		item.mpmod = item.mpmod - value
	end,
}

register_prefix "pfix_frog"
{
	name       = "Frog's ",
	group	   = "mpmod",
	min        = 1,
	max        = 10,
	flags      = { ifCursed },
	occurence  = { TYPE_STAFF, TYPE_SSTAFF, TYPE_RING, TYPE_AMULET },
	incompat   = {"sfix_vitality"},
	level      = 1,
	multiplier = -2,

	OnApply = function(item,value)
		item.mpmod = item.mpmod - value
	end,
}

register_prefix "pfix_spider"
{
	name       = "Spider's ",
	group	   = "mpmod",
	min        = 10,
	max        = 15,
	level      = 1,
	occurence  = { TYPE_STAFF, TYPE_SSTAFF, TYPE_RING, TYPE_AMULET },
	incompat   = {"sfix_vitality"},
	multiplier = 2,
	price_base = 500,
	price_max  = 1000,

	OnApply = function(item,value)
		item.mpmod = item.mpmod + value
	end,
}

register_prefix "pfix_raven"
{
	name       = "Raven's ",
	group	   = "mpmod",
	min        = 16,
	max        = 20,
	level      = 5,
	occurence  = { TYPE_STAFF, TYPE_SSTAFF, TYPE_RING, TYPE_AMULET },
	multiplier = 3,
	price_base = 1100,
	price_max  = 2000,

	OnApply = function(item,value)
		item.mpmod = item.mpmod + value
	end,
}

register_prefix "pfix_snake"
{
	name       = "Snake's ",
	group	   = "mpmod",
	min        = 21,
	max        = 30,
	level      = 9,
	occurence  = { TYPE_STAFF, TYPE_SSTAFF, TYPE_RING, TYPE_AMULET },
	multiplier = 5,
	price_base = 2100,
	price_max  = 4000,

	OnApply = function(item,value)
		item.mpmod = item.mpmod + value
	end,
}

register_prefix "pfix_serpent"
{
	name       = "Serpent's ",
	group	   = "mpmod",
	min        = 31,
	max        = 40,
	level      = 15,
	occurence  = { TYPE_STAFF, TYPE_SSTAFF, TYPE_RING, TYPE_AMULET },
	multiplier = 7,
	price_base = 4100,
	price_max  = 6000,

	OnApply = function(item,value)
		item.mpmod = item.mpmod + value
	end,
}

register_prefix "pfix_drake"
{
	name       = "Drake's ",
	group	   = "mpmod",
	min        = 41,
	max        = 50,
	level      = 21,
	occurence  = { TYPE_STAFF, TYPE_SSTAFF, TYPE_RING, TYPE_AMULET },
	multiplier = 9,
	price_base = 6100,
	price_max  = 10000,

	OnApply = function(item,value)
		item.mpmod = item.mpmod + value
	end,
}

register_prefix "pfix_dragon"
{
	name       = "Dragon's ",
	group	   = "mpmod",
	min        = 51,
	max        = 60,
	level      = 27,
	occurence  = { TYPE_STAFF, TYPE_SSTAFF, TYPE_RING, TYPE_AMULET },
	multiplier = 11,
	price_base = 10100,
	price_max  = 15000,

	OnApply = function(item,value)
		item.mpmod = item.mpmod + value
	end,
}

register_prefix "pfix_wyrm"
{
	name       = "Wyrm's ",
	group	   = "mpmod",
	min        = 61,
	max        = 80,
	level      = 35,
	occurence  = { TYPE_STAFF, TYPE_SSTAFF },
	multiplier = 12,
	price_base = 15100,
	price_max  = 19000,

	OnApply = function(item,value)
		item.mpmod = item.mpmod + value
	end,
}

register_prefix "pfix_hydra"
{
	name       = "Hydra's ",
	group	   = "mpmod",
	min        = 81,
	max        = 100,
	level      = 60,
	occurence  = { TYPE_STAFF, TYPE_SSTAFF },
	multiplier = 13,
	price_base = 19100,
	price_max  = 30000,

	OnApply = function(item,value)
		item.mpmod = item.mpmod + value
	end,
}

--== +AC% =============================--

register_prefix "pfix_vulnerable"
{
	name       = "Vulnerable ",
	group	   = "acmodprc",
	min        = 51,
	max        = 100,
	flags      = { ifCursed },
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	dbl_chance = true,
	level      = 3,
	multiplier = -3,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc - value
	end,
}

register_prefix "pfix_rusted"
{
	name       = "Rusted ",
	group	   = "acmodprc",
	min        = 25,
	max        = 50,
	flags      = { ifCursed },
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	dbl_chance = true,
	level      = 1,
	multiplier = -2,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc - value
	end,
}

register_prefix "pfix_fine"
{
	name       = "Fine ",
	group	   = "acmodprc",
	min        = 20,
	max        = 30,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	dbl_chance = true,
	level      = 1,
	multiplier = 2,
	price_base = 20,
	price_max  = 100,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc + value
	end,
}

register_prefix "pfix_strong"
{
	name       = "Strong ",
	group	   = "acmodprc",
	min        = 31,
	max        = 40,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	dbl_chance = true,
	level      = 3,
	multiplier = 3,
	price_base = 120,
	price_max  = 200,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc + value
	end,
}

register_prefix "pfix_grand"
{
	name       = "Grand ",
	group	   = "acmodprc",
	min        = 41,
	max        = 55,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	dbl_chance = true,
	level      = 6,
	multiplier = 5,
	price_base = 220,
	price_max  = 300,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc + value
	end,
}

register_prefix "pfix_valiant"
{
	name       = "Valiant ",
	group	   = "acmodprc",
	min        = 56,
	max        = 70,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	dbl_chance = true,
	level      = 10,
	multiplier = 7,
	price_base = 320,
	price_max  = 400,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc + value
	end,
}

register_prefix "pfix_glorious"
{
	name       = "Glorious ",
	group	   = "acmodprc",
	min        = 71,
	max        = 90,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	incompat   = {"sfix_trouble"},
	dbl_chance = true,
	level      = 14,
	multiplier = 9,
	price_base = 420,
	price_max  = 600,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc + value
	end,
}

register_prefix "pfix_blessed"
{
	name       = "Blessed ",
	group	   = "acmodprc",
	min        = 91,
	max        = 110,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	incompat   = {"sfix_trouble"},
	dbl_chance = true,
	level      = 19,
	multiplier = 11,
	price_base = 620,
	price_max  = 800,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc + value
	end,
}

register_prefix "pfix_saintly"
{
	name       = "Saintly ",
	group	   = "acmodprc",
	min        = 111,
	max        = 130,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	dbl_chance = true,
	level      = 24,
	multiplier = 2,
	price_base = 820,
	price_max  = 1200,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc + value
	end,
}

register_prefix "pfix_awesome"
{
	name       = "Awesome ",
	group	   = "acmodprc",
	min        = 131,
	max        = 150,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	dbl_chance = true,
	level      = 28,
	multiplier = 15,
	price_base = 1220,
	price_max  = 2000,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc + value
	end,
}

register_prefix "pfix_holy"
{
	name       = "Holy ",
	group	   = "acmodprc",
	min        = 151,
	max        = 170,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	dbl_chance = true,
	level      = 35,
	multiplier = 17,
	price_base = 5200,
	price_max  = 6000,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc + value
	end,
}

register_prefix "pfix_godly"
{
	name       = "Godly ",
	group	   = "acmodprc",
	min        = 171,
	max        = 200,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	dbl_chance = true,
	level      = 60,
	multiplier = 20,
	price_base = 6200,
	price_max  = 7000,

	OnApply = function(item,value)
		item.acmodprc = item.acmodprc + value
	end,
}

--== +To Hit% ==========================--

register_prefix "pfix_tin"
{
	name       = "Tin ",
	group	   = "tohit",
	min        = 6,
	max        = 10,
	flags      = { ifCursed },
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_AMULET, TYPE_RING },
	dbl_chance = true,
	level      = 3,
	multiplier = -3,

	OnApply = function(item,value)
		item.tohit = item.tohit - value
	end,
}

register_prefix "pfix_brass"
{
	name       = "Brass ",
	group	   = "tohit",
	min        = 1,
	max        = 5,
	flags      = { ifCursed },
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_AMULET, TYPE_RING },
	dbl_chance = true,
	level      = 1,
	multiplier = -2,

	OnApply = function(item,value)
		item.tohit = item.tohit - value
	end,
}

register_prefix "pfix_bronze"
{
	name       = "Bronze ",
	group	   = "tohit",
	min        = 1,
	max        = 5,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_AMULET, TYPE_RING },
	dbl_chance = true,
	level      = 1,
	multiplier = 2,
	price_base = 100,
	price_max  = 500,

	OnApply = function(item,value)
		item.tohit = item.tohit + value
	end,
}

register_prefix "pfix_iron"
{
	name       = "Iron ",
	group	   = "tohit",
	min        = 6,
	max        = 10,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_AMULET, TYPE_RING },
	dbl_chance = true,
	level      = 4,
	multiplier = 3,
	price_base = 600,
	price_max  = 1000,

	OnApply = function(item,value)
		item.tohit = item.tohit + value
	end,
}

register_prefix "pfix_steel"
{
	name       = "Steel ",
	group	   = "tohit",
	min        = 11,
	max        = 15,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_AMULET, TYPE_RING },
	dbl_chance = true,
	level      = 6,
	multiplier = 5,
	price_base = 1100,
	price_max  = 1500,

	OnApply = function(item,value)
		item.tohit = item.tohit + value
	end,
}

register_prefix "pfix_silver"
{
	name       = "Silver ",
	group	   = "tohit",
	min        = 16,
	max        = 20,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_AMULET, TYPE_RING },
	incompat   = {"sfix_pit","sfix_vulture","sfix_corruption","sfix_pain","sfix_dark","sfix_bear"},
	dbl_chance = true,
	level      = 9,
	multiplier = 7,
	price_base = 1600,
	price_max  = 2000,

	OnApply = function(item,value)
		item.tohit = item.tohit + value
	end,
}

register_prefix "pfix_gold"
{
	name       = "Gold ",
	group	   = "tohit",
	min        = 21,
	max        = 30,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_AMULET, TYPE_RING },
	incompat   = {"sfix_pit","sfix_vulture","sfix_corruption","sfix_pain","sfix_dark","sfix_bear"},
	dbl_chance = true,
	level      = 12,
	multiplier = 9,
	price_base = 2100,
	price_max  = 3000,

	OnApply = function(item,value)
		item.tohit = item.tohit + value
	end,
}

register_prefix "pfix_platinum"
{
	name       = "Platinum ",
	group	   = "tohit",
	min        = 31,
	max        = 40,
	occurence  = { TYPE_WEAPON, TYPE_BOW },
	incompat   = {"sfix_trouble"},
	dbl_chance = true,
	level      = 16,
	multiplier = 11,
	price_base = 3100,
	price_max  = 4000,

	OnApply = function(item,value)
	item.tohit = item.tohit + value
	end,
}

register_prefix "pfix_mithril"
{
	name       = "Mithril ",
	group	   = "tohit",
	min        = 41,
	max        = 50,
	occurence  = { TYPE_WEAPON, TYPE_BOW },
	incompat   = {"sfix_trouble"},
	dbl_chance = true,
	level      = 20,
	multiplier = 13,
	price_base = 4100,
	price_max  = 6000,

	OnApply = function(item,value)
		item.tohit = item.tohit + value
	end,
}

register_prefix "pfix_meteoric"
{
	name       = "Meteoric ",
	group	   = "tohit",
	min        = 61,
	max        = 80,
	occurence  = { TYPE_WEAPON, TYPE_BOW },
	dbl_chance = true,
	level      = 23,
	multiplier = 15,
	price_base = 6100,
	price_max  = 10000,

	OnApply = function(item,value)
		item.tohit = item.tohit + value
	end,
}

register_prefix "pfix_weird"
{
	name       = "Weird ",
	group	   = "tohit",
	min        = 81,
	max        = 100,
	occurence  = { TYPE_WEAPON, TYPE_BOW },
	dbl_chance = true,
	level      = 35,
	multiplier = 17,
	price_base = 10100,
	price_max  = 14000,

	OnApply = function(item,value)
		item.tohit = item.tohit + value
	end,
}

register_prefix "pfix_strange"
{
	name       = "Strange ",
	group	   = "tohit",
	min        = 101,
	max        = 150,
	occurence  = { TYPE_WEAPON, TYPE_BOW },
	dbl_chance = true,
	level      = 60,
	multiplier = 20,
	price_base = 14100,
	price_max  = 20000,

	OnApply = function(item,value)
		item.tohit = item.tohit + value
	end,
}

--== +% To Hit, +% Damage Done =============--

register_prefix "pfix_clumsy"
{
	name       = "Clumsy ",
	group	   = "tohitdmgmodprc",
	min        = 50,
	max        = 75,
	flags      = { ifCursed },
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	level      = 5,
	multiplier = -7,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc - value
		local amin = 50
		local amax = 75
		local bmin = 6
		local bmax = 10
		item.tohit = item.tohit - bmin - (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}

register_prefix "pfix_dull"
{
	name       = "Dull ",
	group	   = "tohitdmgmodprc",
	min        = 25,
	max        = 45,
	flags      = { ifCursed },
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	level      = 1,
	multiplier = -5,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc - value
		local amin = 25
		local amax = 45
		local bmin = 1
		local bmax = 5
		item.tohit = item.tohit - bmin - (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}

register_prefix "pfix_sharp"
{
	name       = "Sharp ",
	group	   = "tohitdmgmodprc",
	min        = 20,
	max        = 35,
	-- Is treated by the game as a cursed item during item creation so you will,
	-- for example, not be able to buy it in town.
	flags      = { ifCursed },
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 5,
	multiplier = 5,
	price_base = 350,
	price_max  = 950,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
		local amin = 20
		local amax = 35
		local bmin = 1
		local bmax = 5
		item.tohit = item.tohit + bmin + (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}

register_prefix "pfix_fine3"
{
	name       = "Fine ",
	group	   = "tohitdmgmodprc",
	min        = 36,
	max        = 50,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 6,
	multiplier = 7,
	price_base = 1100,
	price_max  = 1700,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
		local amin = 20
		local amax = 35
		local bmin = 1
		local bmax = 5
		item.tohit = item.tohit + bmin + (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}

register_prefix "pfix_warriors"
{
	name       = "Warrior's ",
	group	   = "tohitdmgmodprc",
	min        = 51,
	max        = 65,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 10,
	multiplier = 13,
	price_base = 1850,
	price_max  = 2450,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
		local amin = 51
		local amax = 65
		local bmin = 11
		local bmax = 15
		item.tohit = item.tohit + bmin + (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}

register_prefix "pfix_soldiers"
{
	name       = "Soldier's ",
	group	   = "tohitdmgmodprc",
	min        = 66,
	max        = 80,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 15,
	multiplier = 17,
	price_base = 2600,
	price_max  = 3950,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
		local amin = 66
		local amax = 80
		local bmin = 16
		local bmax = 20
		item.tohit = item.tohit + bmin + (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}

register_prefix "pfix_lords"
{
	name       = "Lord's ",
	group	   = "tohitdmgmodprc",
	min        = 81,
	max        = 95,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 19,
	multiplier = 21,
	price_base = 4100,
	price_max  = 5950,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
		local amin = 81
		local amax = 95
		local bmin = 21
		local bmax = 30
		item.tohit = item.tohit + bmin + (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}

register_prefix "pfix_knights"
{
	name       = "Knight's ",
	group	   = "tohitdmgmodprc",
	min        = 96,
	max        = 110,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 23,
	multiplier = 26,
	price_base = 6100,
	price_max  = 8450,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
		local amin = 96
		local amax = 110
		local bmin = 31
		local bmax = 40
		item.tohit = item.tohit + bmin + (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}

register_prefix "pfix_masters"
{
	name       = "Master's ",
	group	   = "tohitdmgmodprc",
	min        = 111,
	max        = 125,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 28,
	multiplier = 30,
	price_base = 8600,
	price_max  = 13000,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
		local amin = 111
		local amax = 125
		local bmin = 41
		local bmax = 50
		item.tohit = item.tohit + bmin + (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}

register_prefix "pfix_champions"
{
	name       = "Champion's ",
	group	   = "tohitdmgmodprc",
	min        = 126,
	max        = 150,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 40,
	multiplier = 33,
	price_base = 15200,
	price_max  = 24000,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
		local amin = 126
		local amax = 150
		local bmin = 51
		local bmax = 75
		item.tohit = item.tohit + bmin + (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}

register_prefix "pfix_kings"
{
	name       = "King's ",
	group	   = "tohitdmgmodprc",
	min        = 151,
	max        = 175,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 28,
	multiplier = 38,
	price_base = 24100,
	price_max  = 35000,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
		local amin = 151
		local amax = 175
		local bmin = 76
		local bmax = 100
		item.tohit = item.tohit + bmin + (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}
--[[
register_prefix "pfix_doppelgangers"
{
	name       = "Doppelganger's ",
	group	   = "tohitdmgmodprc",
	min        = 81,
	max        = 95,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_SSTAFF },
	level      = 11,
	multiplier = 10,
	price_base = 2000,
	price_max  = 2400,
	-- Has 10% chance of duplicating any monster hit except Diablo and unique monsters.
	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
		local amin = 81
		local amax = 95
		local bmin = 21
		local bmax = 30
		item.tohit = item.tohit + bmin + (value-amin)/(amax-amin)*(bmax-bmin)
	end,
}
]]
--== +Damage% ===============================--

register_prefix "pfix_useless"
{
	name       = "Useless ",
	group	   = "dmgmodprc",
	min        = 100,
	max        = 100,
	flags      = { ifCursed },
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 5,
	multiplier = -8,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc - value
	end,
}

register_prefix "pfix_bent"
{
	name       = "Bent ",
	group	   = "dmgmodprc",
	min        = 50,
	max        = 75,
	flags      = { ifCursed },
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 3,
	multiplier = -4,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc - value
	end,
}

register_prefix "pfix_weak"
{
	name       = "Weak ",
	group	   = "dmgmodprc",
	min        = 25,
	max        = 45,
	flags      = { ifCursed },
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 1,
	multiplier = -3,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc - value
	end,
}

register_prefix "pfix_jagged"
{
	name       = "Jagged ",
	group	   = "dmgmodprc",
	min        = 20,
	max        = 35,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 4,
	multiplier = 3,
	price_base = 250,
	price_max  = 450,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
	end,
}

register_prefix "pfix_deadly"
{
	name       = "Deadly ",
	group	   = "dmgmodprc",
	min        = 36,
	max        = 50,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 4,
	multiplier = 3,
	price_base = 500,
	price_max  = 700,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
	end,
}

register_prefix "pfix_heavy"
{
	name       = "Heavy ",
	group	   = "dmgmodprc",
	min        = 51,
	max        = 65,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 9,
	multiplier = 5,
	price_base = 750,
	price_max  = 950,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
	end,
}

register_prefix "pfix_vicious"
{
	name       = "Vicious ",
	group	   = "dmgmodprc",
	min        = 66,
	max        = 80,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	incompat   = {"sfix_vim","sfix_vigor","sfix_radiance"},
	dbl_chance = true,
	level      = 12,
	multiplier = 8,
	price_base = 1000,
	price_max  = 1450,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
	end,
}

register_prefix "pfix_brutal"
{
	name       = "Brutal ",
	group	   = "dmgmodprc",
	min        = 81,
	max        = 95,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 16,
	multiplier = 10,
	price_base = 1500,
	price_max  = 1950,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
	end,
}

register_prefix "pfix_massive"
{
	name       = "Massive ",
	group	   = "dmgmodprc",
	min        = 96,
	max        = 110,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 20,
	multiplier = 13,
	price_base = 2000,
	price_max  = 2450,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
	end,
}

register_prefix "pfix_savage"
{
	name       = "Savage ",
	group	   = "dmgmodprc",
	min        = 111,
	max        = 125,
	occurence  = { TYPE_WEAPON, TYPE_BOW },
	dbl_chance = true,
	level      = 23,
	multiplier = 15,
	price_base = 2500,
	price_max  = 3000,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
	end,
}

register_prefix "pfix_ruthless"
{
	name       = "Ruthless ",
	group	   = "dmgmodprc",
	min        = 126,
	max        = 150,
	occurence  = { TYPE_WEAPON, TYPE_BOW },
	dbl_chance = true,
	level      = 35,
	multiplier = 17,
	price_base = 10100,
	price_max  = 15000,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
	end,
}

register_prefix "pfix_merciless"
{
	name       = "Merciless ",
	group	   = "dmgmodprc",
	min        = 151,
	max        = 175,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_SSTAFF },
	dbl_chance = true,
	level      = 60,
	multiplier = 20,
	price_base = 15000,
	price_max  = 20000,

	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
	end,
}
--[[
register_prefix "pfix_decay"
{
	name       = "Decay ",
	group	   = "dmgmodprc",
	min        = 151,
	max        = 250,
	occurence  = { TYPE_WEAPON, TYPE_BOW },
	level      = 1,
	multiplier = 2,
	price_base = 200,
	price_max  = 200,
	-- Bonus decreases by 5% each hit. When reaching -100%, the item is destroyed
	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
	end,
}

register_prefix "pfix_crystalline"
{
	name       = "Crystalline ",
	group	   = "dmgmodprc",
	min        = 151,
	max        = 175,
	occurence  = { TYPE_WEAPON },
	level      = 5,
	multiplier = 3,
	price_base = 1000,
	price_max  = 3000,
	-- Also has from -30 to -70% lower durability
	OnApply = function(item,value)
		item.dmgmodprc = item.dmgmodprc + value
	end,
}
]]
--== +Resist Magic ==========================--

register_prefix "pfix_white"
{
	name       = "White ",
	group	   = "resmagic",
	min        = 10,
	max        = 20,
	level      = 4,
	multiplier = 2,
	price_base = 500,
	price_max  = 1500,

	OnApply = function(item,value)
		item.resmagic = item.resmagic + value
	end,
}

register_prefix "pfix_pearl"
{
	name       = "Pearl ",
	group	   = "resmagic",
	min        = 21,
	max        = 30,
	level      = 10,
	multiplier = 2,
	price_base = 2100,
	price_max  = 3000,

	OnApply = function(item,value)
		item.resmagic = item.resmagic + value
	end,
}

register_prefix "pfix_ivory"
{
	name       = "Ivory ",
	group	   = "resmagic",
	min        = 31,
	max        = 40,
	level      = 16,
	multiplier = 2,
	price_base = 3100,
	price_max  = 4000,

	OnApply = function(item,value)
		item.resmagic = item.resmagic + value
	end,
}

register_prefix "pfix_crystal"
{
	name       = "Crystal ",
	group	   = "resmagic",
	min        = 41,
	max        = 50,
	level      = 20,
	multiplier = 3,
	price_base = 8200,
	price_max  = 12000,

	OnApply = function(item,value)
		item.resmagic = item.resmagic + value
	end,
}

register_prefix "pfix_diamond"
{
	name       = "Diamond ",
	group	   = "resmag",
	min        = 51,
	max        = 60,
	level      = 26,
	multiplier = 5,
	price_base = 17100,
	price_max  = 20000,

	OnApply = function(item,value)
		item.resmagic = item.resmagic + value
	end,
}

--== +Resist Fire ==========================--

register_prefix "pfix_red"
{
	name       = "Red ",
	group	   = "resfire",
	min        = 10,
	max        = 20,
	level      = 4,
	multiplier = 2,
	price_base = 500,
	price_max  = 1500,

	OnApply = function(item,value)
		item.resfire = item.resfire + value
	end,
}

register_prefix "pfix_crimson"
{
	name       = "Crimson ",
	group	   = "resfire",
	min        = 21,
	max        = 30,
	level      = 10,
	multiplier = 2,
	price_base = 2100,
	price_max  = 3000,

	OnApply = function(item,value)
		item.resfire = item.resfire + value
	end,
}

register_prefix "pfix_crimson3"
{
	name       = "Crimson ",
	group	   = "resfire",
	min        = 31,
	max        = 40,
	level      = 16,
	multiplier = 2,
	price_base = 3100,
	price_max  = 4000,

	OnApply = function(item,value)
		item.resfire = item.resfire + value
	end,
}

register_prefix "pfix_garnet"
{
	name       = "Garnet ",
	group	   = "resfire",
	min        = 41,
	max        = 50,
	level      = 20,
	multiplier = 3,
	price_base = 8200,
	price_max  = 12000,

	OnApply = function(item,value)
		item.resfire = item.resfire + value
	end,
}

register_prefix "pfix_ruby"
{
	name       = "Ruby ",
	group	   = "resfire",
	min        = 51,
	max        = 60,
	level      = 26,
	multiplier = 5,
	price_base = 17100,
	price_max  = 20000,

	OnApply = function(item,value)
		item.resfire = item.resfire + value
	end,
}

--== +Resist Lightning ==========================--

register_prefix "pfix_blue"
{
	name       = "Blue ",
	group	   = "reslightning",
	min        = 10,
	max        = 20,
	level      = 4,
	multiplier = 2,
	price_base = 500,
	price_max  = 1500,

	OnApply = function(item,value)
		item.reslightning = item.reslightning + value
	end,
}

register_prefix "pfix_azure"
{
	name       = "Azure ",
	group	   = "reslightning",
	min        = 21,
	max        = 30,
	level      = 10,
	multiplier = 2,
	price_base = 2100,
	price_max  = 3000,

	OnApply = function(item,value)
		item.reslightning = item.reslightning + value
	end,
}

register_prefix "pfix_lapis"
{
	name       = "Lapis ",
	group	   = "reslightning",
	min        = 31,
	max        = 40,
	level      = 16,
	multiplier = 2,
	price_base = 3100,
	price_max  = 4000,

	OnApply = function(item,value)
		item.reslightning = item.reslightning + value
	end,
}

register_prefix "pfix_cobalt"
{
	name       = "Cobalt ",
	group	   = "reslightning",
	min        = 41,
	max        = 50,
	level      = 20,
	multiplier = 3,
	price_base = 8200,
	price_max  = 12000,

	OnApply = function(item,value)
		item.reslightning = item.reslightning + value
	end,
}

register_prefix "pfix_sapphire"
{
	name       = "Sapphire ",
	group	   = "reslightning",
	min        = 51,
	max        = 60,
	level      = 26,
	multiplier = 5,
	price_base = 17100,
	price_max  = 20000,

	OnApply = function(item,value)
		item.reslightning = item.reslightning + value
	end,
}

--== +Resist All ==========================--

register_prefix "pfix_topaz"
{
	name       = "Topaz ",
	group	   = "resall",
	min        = 10,
	max        = 20,
	level      = 4,
	multiplier = 3,
	price_base = 2000,
	price_max  = 5000,

	OnApply = function(item,value)
		item.reslightning = item.reslightning + value
		item.resfire      = item.resfire + value
		item.resmagic     = item.resmagic + value
	end,
}

register_prefix "pfix_amber"
{
	name       = "Amber ",
	group	   = "resall",
	min        = 21,
	max        = 30,
	level      = 10,
	multiplier = 3,
	price_base = 7400,
	price_max  = 10000,

	OnApply = function(item,value)
		item.reslightning = item.reslightning + value
		item.resfire      = item.resfire + value
		item.resmagic     = item.resmagic + value
	end,
}

register_prefix "pfix_jade"
{
	name       = "Jade ",
	group	   = "resall",
	min        = 31,
	max        = 40,
	level      = 16,
	multiplier = 3,
	price_base = 11000,
	price_max  = 15000,

	OnApply = function(item,value)
		item.reslightning = item.reslightning + value
		item.resfire      = item.resfire + value
		item.resmagic     = item.resmagic + value
	end,
}

register_prefix "pfix_obsidian"
{
	name       = "Obsidian ",
	group	   = "resall",
	min        = 41,
	max        = 50,
	level      = 20,
	multiplier = 4,
	price_base = 24000,
	price_max  = 40000,

	OnApply = function(item,value)
		item.reslightning = item.reslightning + value
		item.resfire      = item.resfire + value
		item.resmagic     = item.resmagic + value
	end,
}

register_prefix "pfix_emerald"
{
	name       = "Emerald ",
	group	   = "resall",
	min        = 51,
	max        = 60,
	level      = 26,
	occurence  = { TYPE_SHIELD, TYPE_WEAPON, TYPE_STAFF, TYPE_SSTAFF, TYPE_BOW },
	multiplier = 7,
	price_base = 61000,
	price_max  = 75000,

	OnApply = function(item,value)
		item.reslightning = item.reslightning + value
		item.resfire      = item.resfire + value
		item.resmagic     = item.resmagic + value
	end,
}

--== +Spell Level ==========================--

register_prefix "pfix_angel"
{
	name       = "Angel's ",
	group	   = "spelllevel",
	min        = 1,
	max        = 1,
	occurence  = { TYPE_STAFF, TYPE_SSTAFF },
	incompat   = {"sfix_trouble"},
	level      = 15,
	multiplier = 2,
	price_base = 25000,
	price_max  = 25000,

	OnApply = function(item,value)
		item.spelllevel      = item.spelllevel + value
	end,
}

register_prefix "pfix_archangel"
{
	name       = "Arch-angel's ",
	group	   = "spelllevel",
	min        = 2,
	max        = 2,
	occurence  = { TYPE_STAFF, TYPE_SSTAFF },
	incompat   = {"sfix_trouble"},
	level      = 25,
	multiplier = 3,
	price_base = 50000,
	price_max  = 50000,

	OnApply = function(item,value)
		item.spelllevel      = item.spelllevel + value
	end,
}

--== +Charges ==========================--

register_prefix "pfix_plentiful"
{
	name       = "Plentiful ",
	group	   = "chargesmod",
	min        = 2,
	max        = 2,
	occurence  = { TYPE_SSTAFF },
	level      = 4,
	multiplier = 2,
	price_base = 2000,
	price_max  = 2000,

	OnApply = function(item,value)
		item.chargesmod = value
		item.charges    = item.charges+item.chargesmax*(value-1)
		item.chargesmax = item.chargesmax*value
	end,
}

register_prefix "pfix_bountiful"
{
	name       = "Bountiful ",
	group	   = "chargesmod",
	min        = 3,
	max        = 3,
	occurence  = { TYPE_SSTAFF },
	level      = 9,
	multiplier = 3,
	price_base = 3000,
	price_max  = 3000,

	OnApply = function(item,value)
		item.chargesmod = value
		item.charges    = item.charges+item.chargesmax*(value-1)
		item.chargesmax = item.chargesmax * value
	end,
}

