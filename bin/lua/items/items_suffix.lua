core.register_blueprint "suffix"
{
	id          = { true,  core.TSTRING },
	group		= { true,  core.TSTRING },
	name        = { true,  core.TSTRING },
	min         = { false, core.TNUMBER, 0 },
	max         = { false, core.TNUMBER, 0 },
	prefix      = false,
	level       = { false, core.TNUMBER, 1 },
	occurence   = { false, core.TFLAGS, { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_STAFF, TYPE_BOW, TYPE_RING, TYPE_AMULET } },
	flags       = { false, core.TFLAGS, {} },
	multiplier  = { false, core.TNUMBER, 1 },
	price_base  = { false, core.TNUMBER, 0 },
	price_max   = { false, core.TNUMBER, 0 },

	OnApply     = { false,  core.TFUNC },
}

--[[
TODO: Proper OnApply functions for the following Suffixes:
Corruption?, Piercing, Puncturing, Bashing, Ages?, Bear, Thieves, Thorns,
Devastation, Peril

Corruption, Ages may need editting.

Uncomment Flame and Lightning when game supports them
--]]

--== + Strength ==========================--

register_suffix "sfix_frailty"
{
	name       = " of Frailty",
	group	   = "str",
	min        = 6,
	max        = 10,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	flags      = { ifCursed },
	level      = 3,
	multiplier = -3,

	OnApply = function(item,value)
		item.str = item.str - value
	end,
}

register_suffix "sfix_weakness"
{
	name       = " of Weakness",
	group	   = "str",
	min        = 1,
	max        = 5,
	flags      = { ifCursed },
	multiplier = -2,

	OnApply = function(item,value)
		item.str = item.str - value
	end,
}

register_suffix "sfix_strength"
{
	name       = " of Strength",
	group	   = "str",
	min        = 1,
	max        = 5,
	multiplier = 2,
	price_base = 200,
	price_max  = 1000,

	OnApply = function(item,value)
		item.str = item.str + value
	end,
}

register_suffix "sfix_might"
{
	name       = " of Might",
	group	   = "str",
	min        = 6,
	max        = 10,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 5,
	multiplier = 3,
	price_base = 1200,
	price_max  = 2000,

	OnApply = function(item,value)
		item.str = item.str + value
	end,
}

register_suffix "sfix_power"
{
	name       = " of Power",
	group	   = "str",
	min        = 11,
	max        = 15,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 11,
	multiplier = 4,
	price_base = 2200,
	price_max  = 3000,

	OnApply = function(item,value)
		item.str = item.str + value
	end,
}

register_suffix "sfix_giants"
{
	name       = " of Giants",
	group	   = "str",
	min        = 16,
	max        = 20,
	occurence  = { TYPE_ARMOR, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 17,
	multiplier = 7,
	price_base = 3200,
	price_max  = 5000,

	OnApply = function(item,value)
		item.str = item.str + value
	end,
}

register_suffix "sfix_titans"
{
	name       = " of Titans",
	group	   = "str",
	min        = 21,
	max        = 30,
	occurence  = { TYPE_WEAPON, TYPE_RING, TYPE_AMULET },
	level      = 23,
	multiplier = 10,
	price_base = 5200,
	price_max  = 10000,

	OnApply = function(item,value)
		item.str = item.str + value
	end,
}

--== + Magic ==========================--

register_suffix "sfix_fool"
{
	name       = " of the Fool",
	group	   = "mag",
	min        = 6,
	max        = 10,
	flags      = { ifCursed },
	level      = 3,
	multiplier = -3,

	OnApply = function(item,value)
		item.mag = item.mag - value
	end,
}

register_suffix "sfix_dyslexia"
{
	name       = " of Dyslexia",
	group	   = "mag",
	min        = 1,
	max        = 5,
	flags      = { ifCursed },
	level      = 1,
	multiplier = -2,

	OnApply = function(item,value)
		item.mag = item.mag - value
	end,
}

register_suffix "sfix_magic"
{
	name       = " of Magic",
	group	   = "mag",
	min        = 1,
	max        = 5,
	level      = 1,
	multiplier = 2,
	price_base = 200,
	price_max  = 1000,

	OnApply = function(item,value)
		item.mag = item.mag + value
	end,
}

register_suffix "sfix_mind"
{
	name       = " of the Mind",
	group	   = "mag",
	min        = 6,
	max        = 10,
	level      = 5,
	multiplier = 3,
	price_base = 1200,
	price_max  = 2000,

	OnApply = function(item,value)
		item.mag = item.mag + value
	end,
}

register_suffix "sfix_brilliance"
{
	name       = " of Brilliance",
	group	   = "mag",
	min        = 11,
	max        = 15,
	level      = 11,
	multiplier = 4,
	price_base = 2200,
	price_max  = 3000,

	OnApply = function(item,value)
		item.mag = item.mag + value
	end,
}

register_suffix "sfix_sorcery"
{
	name       = " of Sorcery",
	group	   = "mag",
	min        = 16,
	max        = 20,
	occurence  = { TYPE_ARMOR, TYPE_WEAPON, TYPE_STAFF, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 17,
	multiplier = 7,
	price_base = 3200,
	price_max  = 5000,

	OnApply = function(item,value)
		item.mag = item.mag + value
	end,
}

register_suffix "sfix_wizardry"
{
	name       = " of Wizardry",
	group	   = "mag",
	min        = 21,
	max        = 30,
	occurence  = { TYPE_STAFF, TYPE_RING, TYPE_AMULET },
	level      = 23,
	multiplier = 10,
	price_base = 5200,
	price_max  = 10000,

	OnApply = function(item,value)
		item.mag = item.mag + value
	end,
}

--== + Dexterity ==========================--
register_suffix "sfix_paralysis"
{
	name       = " of Paralysis",
	group	   = "dex",
	min        = 6,
	max        = 10,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_RING, TYPE_BOW, TYPE_AMULET },
	flags      = { ifCursed },
	level      = 3,
	multiplier = -3,

	OnApply = function(item,value)
		item.dex = item.dex - value
	end,
}

register_suffix "sfix_atrophy"
{
	name       = " of Atrophy",
	group	   = "dex",
	min        = 1,
	max        = 5,
	flags      = { ifCursed },
	level      = 1,
	multiplier = -2,

	OnApply = function(item,value)
		item.dex = item.dex - value
	end,
}

register_suffix "sfix_dexterity"
{
	name       = " of Dexterity",
	group	   = "dex",
	min        = 1,
	max        = 5,
	level      = 1,
	multiplier = 2,
	price_base = 200,
	price_max  = 1000,

	OnApply = function(item,value)
		item.dex = item.dex + value
	end,
}

register_suffix "sfix_skill"
{
	name       = " of Skill",
	group	   = "dex",
	min        = 6,
	max        = 10,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 5,
	multiplier = 3,
	price_base = 1200,
	price_max  = 2000,

	OnApply = function(item,value)
		item.dex = item.dex + value
	end,
}

register_suffix "sfix_accuracy"
{
	name       = " of Accuracy",
	group	   = "dex",
	min        = 11,
	max        = 15,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 11,
	multiplier = 4,
	price_base = 2200,
	price_max  = 3000,

	OnApply = function(item,value)
		item.dex = item.dex + value
	end,
}

register_suffix "sfix_precision"
{
	name       = " of Precision",
	group	   = "dex",
	min        = 16,
	max        = 20,
	occurence  = { TYPE_ARMOR, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 17,
	multiplier = 7,
	price_base = 3200,
	price_max  = 5000,

	OnApply = function(item,value)
		item.dex = item.dex + value
	end,
}

register_suffix "sfix_perfection"
{
	name       = " of Perfection",
	group	   = "dex",
	min        = 21,
	max        = 30,
	occurence  = { TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 23,
	multiplier = 10,
	price_base = 5200,
	price_max  = 10000,

	OnApply = function(item,value)
		item.dex = item.dex + value
	end,
}

--== + Vitality ==========================--
register_suffix "sfix_illness"
{
	name       = " of Illness",
	group	   = "vit",
	min        = 6,
	max        = 10,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	flags      = { ifCursed },
	level      = 3,
	multiplier = -3,

	OnApply = function(item,value)
		item.vit = item.vit - value
	end,
}

register_suffix "sfix_disease"
{
    name       = " of Disease",
	group	   = "vit",
	min        = 1,
	max        = 5,
	flags      = { ifCursed },
	level      = 1,
	multiplier = -2,

	OnApply = function(item,value)
		item.vit = item.vit - value
	end,
}

register_suffix "sfix_vitality"
{
	name       = " of Vitality",
	group	   = "vit",
	min        = 1,
	max        = 5,
	level      = 1,
	multiplier = 2,
 	price_base = 200,
	price_max  = 1000,

	OnApply = function(item,value)
		item.vit = item.vit + value
	end,
}

register_suffix "sfix_zest"
{
	name       = " of Zest",
	group	   = "vit",
	min        = 6,
	max        = 10,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 5,
	multiplier = 3,
	price_base = 1200,
	price_max  = 2000,

	OnApply = function(item,value)
		item.vit = item.vit + value
	end,
}

register_suffix "sfix_vim"
{
	name       = " of Vim",
	group	   = "vit",
	min        = 11,
	max        = 15,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 11,
	multiplier = 4,
	price_base = 2200,
	price_max  = 3000,

	OnApply = function(item,value)
		item.vit = item.vit + value
	end,
}

register_suffix "sfix_vigor"
{
	name       = " of Vigor",
	group	   = "vit",
	min        = 16,
	max        = 20,
	occurence  = { TYPE_ARMOR, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 17,
	multiplier = 7,
	price_base = 3200,
	price_max  = 5000,

	OnApply = function(item,value)
		item.vit = item.vit + value
	end,
}

register_suffix "sfix_life"
{
	name       = " of Life",
	group	   = "vit",
	min        = 21,
	max        = 30,
	occurence  = { TYPE_RING, TYPE_AMULET },
	level      = 23,
	multiplier = 10,
	price_base = 5200,
	price_max  = 10000,

	OnApply = function(item,value)
		item.vit = item.vit + value
	end,
}

--== + All Atribytes ==========================--

register_suffix "sfix_trouble"
{
	name       = " of Trouble",
	group	   = "allstat",
	min        = 6,
	max        = 10,
	flags      = { ifCursed },
	level      = 12,
	multiplier = -10,

	OnApply = function(item,value)
		item.str = item.str - value
		item.mag = item.mag - value
		item.dex = item.dex - value
		item.vit = item.vit - value
	end,
}

register_suffix "sfix_pit"
{
	name       = " of the Pit",
	group	   = "allstat",
	min        = 1,
	max        = 5,
	flags      = { ifCursed },
	level      = 5,
	multiplier = -5,

	OnApply = function(item,value)
		item.str = item.str - value
		item.mag = item.mag - value
		item.dex = item.dex - value
		item.vit = item.vit - value
	end,
}

register_suffix "sfix_sky"
{
	name       = " of the Sky",
	group	   = "allstat",
	min        = 1,
	max        = 3,
	level      = 5,
	multiplier = 5,
	price_base = 800,
	price_max  = 4000,

	OnApply = function(item,value)
		item.str = item.str + value
		item.mag = item.mag + value
		item.dex = item.dex + value
		item.vit = item.vit + value
	end,
}

register_suffix "sfix_moon"
{
	name       = " of the Moon",
	group	   = "allstat",
	min        = 4,
	max        = 7,
	level      = 11,
	multiplier = 10,
	price_base = 4800,
	price_max  = 8000,

	OnApply = function(item,value)
		item.str = item.str + value
		item.mag = item.mag + value
		item.dex = item.dex + value
		item.vit = item.vit + value
	end,
}

register_suffix "sfix_stars"
{
	name       = " of the Stars",
	group	   = "allstat",
	min        = 8,
	max        = 11,
	occurence  = { TYPE_ARMOR, TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 17,
	multiplier = 15,
	price_base = 8800,
	price_max  = 12000,

	OnApply = function(item,value)
		item.str = item.str + value
		item.mag = item.mag + value
		item.dex = item.dex + value
		item.vit = item.vit + value
	end,
}

register_suffix "sfix_heavens"
{
	name       = " of the Heavens",
	group	   = "allstat",
	min        = 12,
	max        = 15,
	occurence  = { TYPE_WEAPON, TYPE_BOW, TYPE_RING, TYPE_AMULET },
	level      = 25,
	multiplier = 20,
	price_base = 12800,
	price_max  = 20000,

	OnApply = function(item,value)
		item.str = item.str + value
		item.mag = item.mag + value
		item.dex = item.dex + value
		item.vit = item.vit + value
	end,
}

register_suffix "sfix_zodiac"
{
	name       = " of the Zodiac",
	group	   = "allstat",
	min        = 16,
	max        = 20,
	occurence  = { TYPE_RING, TYPE_AMULET },
	level      = 30,
	multiplier = 30,
	price_base = 20800,
	price_max  = 40000,

	OnApply = function(item,value)
		item.str = item.str + value
		item.mag = item.mag + value
		item.dex = item.dex + value
		item.vit = item.vit + value
	end,
}

--== + Life ==========================--

register_suffix "sfix_vulture"
{
	name       = " of the Vulture",
	group	   = "hpmod",
	min        = 11,
	max        = 25,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
	flags      = { ifCursed },
	level      = 4,
	multiplier = -4,

	OnApply = function(item,value)
		item.hpmod = item.hpmod - value
	end,
}

register_suffix "sfix_jackal"
{
	name       = " of the Jackal",
	group	   = "hpmod",
	min        = 1,
	max        = 10,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
	flags      = { ifCursed },
	level      = 1,
	multiplier = -2,

	OnApply = function(item,value)
		item.hpmod = item.hpmod - value
	end,
}

register_suffix "sfix_fox"
{
	name       = " of the Fox",
	group	   = "hpmod",
	min        = 10,
	max        = 15,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
	level      = 1,
	multiplier = 2,
	price_base = 100,
	price_max  = 1000,

	OnApply = function(item,value)
		item.hpmod = item.hpmod + value
	end,
}

register_suffix "sfix_jaguar"
{
	name       = " of the Jaguar",
	group	   = "hpmod",
	min        = 16,
	max        = 20,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
	level      = 5,
	multiplier = 3,
	price_base = 1100,
	price_max  = 2000,

	OnApply = function(item,value)
		item.hpmod = item.hpmod + value
	end,
}

register_suffix "sfix_eagle"
{
	name       = " of the Eagle",
	group	   = "hpmod",
	min        = 21,
	max        = 30,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
	level      = 9,
	multiplier = 5,
	price_base = 2100,
	price_max  = 4000,

	OnApply = function(item,value)
		item.hpmod = item.hpmod + value
	end,
}

register_suffix "sfix_wolf"
{
	name       = " of the Wolf",
	group	   = "hpmod",
	min        = 31,
	max        = 40,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
	level      = 15,
	multiplier = 7,
	price_base = 4100,
	price_max  = 6000,

	OnApply = function(item,value)
		item.hpmod = item.hpmod + value
	end,
}

register_suffix "sfix_tiger"
{
	name       = " of the Tiger",
	group	   = "hpmod",
	min        = 41,
	max        = 50,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
	level      = 21,
	multiplier = 9,
	price_base = 6100,
	price_max  = 10000,

	OnApply = function(item,value)
		item.hpmod = item.hpmod + value
	end,
}

register_suffix "sfix_lion"
{
	name       = " of the Lion",
	group	   = "hpmod",
	min        = 51,
	max        = 60,
	occurence  = { TYPE_ARMOR, TYPE_RING, TYPE_AMULET },
	level      = 27,
	multiplier = 11,
	price_base = 10100,
	price_max  = 15000,

	OnApply = function(item,value)
		item.hpmod = item.hpmod + value
	end,
}

register_suffix "sfix_mammoth"
{
	name       = " of the Mammoth",
	group	   = "hpmod",
	min        = 61,
	max        = 80,
	occurence  = { TYPE_ARMOR },
	level      = 35,
	multiplier = 12,
	price_base = 15100,
	price_max  = 19000,

	OnApply = function(item,value)
		item.hpmod = item.hpmod + value
	end,
}

register_suffix "sfix_whale"
{
	name       = " of the Whale",
	group	   = "hpmod",
	min        = 81,
	max        = 100,
	occurence  = { TYPE_ARMOR },
	level      = 60,
	multiplier = 13,
	price_base = 19100,
	price_max  = 30000,

	OnApply = function(item,value)
		item.hpmod = item.hpmod + value
	end,
}

--== + Damage Done =====================--

register_suffix "sfix_quality"
{
	name       = " of Quality",
	group	   = "dmgmod",
	min        = 1,
	max        = 2,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_BOW, },
	level      = 2,
	multiplier = 2,
	price_base = 100,
	price_max  = 200,

	OnApply = function(item,value)
		item.dmgmod = item.dmgmod + value
	end,
}

register_suffix "sfix_maiming"
{
	name       = " of Maiming",
	group	   = "dmgmod",
	min        = 3,
	max        = 5,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_BOW, },
	level      = 7,
	multiplier = 3,
	price_base = 1300,
	price_max  = 1500,

	OnApply = function(item,value)
		item.dmgmod = item.dmgmod + value
	end,
}

register_suffix "sfix_slaying"
{
	name       = " of Slaying",
	group	   = "dmgmod",
	min        = 6,
	max        = 8,
	occurence  = { TYPE_WEAPON },
	level      = 15,
	multiplier = 5,
	price_base = 2600,
	price_max  = 3000,

	OnApply = function(item,value)
		item.dmgmod = item.dmgmod + value
	end,
}

register_suffix "sfix_gore"
{
	name       = " of Gore",
	group	   = "dmgmod",
	min        = 9,
	max        = 12,
	occurence  = { TYPE_WEAPON },
	level      = 25,
	multiplier = 8,
	price_base = 4100,
	price_max  = 5000,

	OnApply = function(item,value)
		item.dmgmod = item.dmgmod + value
	end,
}

register_suffix "sfix_carnage"
{
	name       = " of Carnage",
	group	   = "dmgmod",
	min        = 13,
	max        = 16,
	occurence  = { TYPE_WEAPON },
	level      = 35,
	multiplier = 10,
	price_base = 5100,
	price_max  = 10000,

	OnApply = function(item,value)
		item.dmgmod = item.dmgmod + value
	end,
}

register_suffix "sfix_slaughter"
{
	name       = " of Slaughter",
	group	   = "dmgmod",
	min        = 17,
	max        = 20,
	occurence  = { TYPE_WEAPON },
	level      = 60,
	multiplier = 13,
	price_base = 10100,
	price_max  = 15000,

	OnApply = function(item,value)
		item.dmgmod = item.dmgmod + value
	end,
}

--== + Damage Taken ==========================--

register_suffix "sfix_pain"
{
	name       = " of Pain",
	group	   = "dmgtaken",
	min        = 2,
	max        = 4,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
	flags      = { ifCursed },
	level      = 4,
	multiplier = -4,

	OnApply = function(self,value)
		self.dmgtaken = self.dmgtaken + value
	end,
}

register_suffix "sfix_tears"
{
	name       = " of Tears",
	group	   = "dmgtaken",
	min        = 1,
	max        = 1,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
	flags      = { ifCursed },
	level      = 2,
	multiplier = -2,

	OnApply = function(self,value)
		self.dmgtaken = self.dmgtaken + value
	end,
}

register_suffix "sfix_health"
{
	name       = " of Health",
	group	   = "dmgtaken",
	min        = 1,
	max        = 1,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
	level      = 2,
	multiplier = 2,
	price_base = 200,
	price_max  = 200,

	OnApply = function(self,value)
		self.dmgtaken = self.dmgtaken - value
	end,
}

register_suffix "sfix_protection"
{
	name       = " of Protection",
	group	   = "dmgtaken",
	min        = 2,
	max        = 2,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	level      = 6,
	multiplier = 4,
	price_base = 400,
	price_max  = 400,

	OnApply = function(self,value)
		self.dmgtaken = self.dmgtaken - value
	end,
}

register_suffix "sfix_absorption"
{
	name       = " of Absorption",
	group	   = "dmgtaken",
	min        = 3,
	max        = 3,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	level      = 12,
	multiplier = 10,
	price_base = 1000,
	price_max  = 1000,

	OnApply = function(self,value)
		self.dmgtaken = self.dmgtaken - value
	end,
}

register_suffix "sfix_deflection"
{
	name       = " of Deflection",
	group	   = "dmgtaken",
	min        = 4,
	max        = 4,
	occurence  = { TYPE_ARMOR },
	level      = 20,
	multiplier = 15,
	price_base = 2500,
	price_max  = 2500,

	OnApply = function(self,value)
		self.dmgtaken = self.dmgtaken - value
	end,
}

register_suffix "sfix_osmosis"
{
	name       = " of Osmosis",
	group	   = "dmgtaken",
	min        = 5,
	max        = 6,
	occurence  = { TYPE_ARMOR },
	level      = 50,
	multiplier = 20,
	price_base = 7500,
	price_max  = 10000,

	OnApply = function(self,value)
		self.dmgtaken = self.dmgtaken - value
	end,
}

--[[
--== + Mana ==========================--

register_suffix "sfix_corruption"
{
	name       = " of Corruption",
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON },
	flags      = { ifCorrupt },
	level      = 5,
	multiplier = 2,
	 price_base = -1000,
	price_max  = -1000,

	OnApply = function(self,value)
		self.dmgmod = item.dmgmod + value
	end,
}
--]]

--== + Fire Damage ==========================--
register_suffix "sfix_flame"
{
	name       = " of Flame",
	group	   = "dmgfire",
	min        = 1,
	max        = 3,
	occurence  = { TYPE_BOW },
	level      = 1,
	multiplier = 2,
    price_base = 2000,
	price_max  = 2000,

    OnApply = function(self,value)
		self.dmgfiremin        = self.dmgfiremin + value
		self.dmgfiremax        = self.dmgfiremax + value
    end,
}

register_suffix "sfix_fire"
{
	name       = " of Fire",
	group	   = "dmgfire",
	min        = 1,
	max        = 6,
	occurence  = { TYPE_BOW },
	level      = 11,
	multiplier = 4,
	price_base = 4000,
	price_max  = 4000,

	OnApply = function(self,value)
		self.dmgfiremin        = self.dmgfiremin + value
		self.dmgfiremax        = self.dmgfiremax + value
	end,
}

register_suffix "sfix_burning"
{
	name       = " of Burning",
	group	   = "dmgfire",
	min        = 1,
	max        = 16,
	occurence  = { TYPE_BOW },
	level      = 35,
	multiplier = 6,
	price_base = 6000,
	price_max  = 6000,

	OnApply = function(self,value)
		self.dmgfiremin        = self.dmgfiremin + value
		self.dmgfiremax        = self.dmgfiremax + value
	end,
}

--== + Lightning Damage ==========================--

register_suffix "sfix_shock"
{
	name       = " of Shock",
	group	   = "dmglightning",
	min        = 1,
	max        = 6,
	occurence  = { TYPE_BOW },
	level      = 13,
	multiplier = 2,
	price_base = 6000,
	price_max  = 6000,

	OnApply = function(self,value)
		self.dmglightningmin        = self.dmglightningmin + value
		self.dmglightningmax        = self.dmglightningmax + value
	end,
}

register_suffix "sfix_lightning"
{
	name       = " of Lightning",
	group	   = "dmglightning",
	min        = 1,
	max        = 10,
	occurence  = { TYPE_BOW },
	level      = 21,
	multiplier = 4,
	price_base = 8000,
	price_max  = 8000,

	OnApply = function(self,value)
		self.dmglightningmin        = self.dmglightningmin + value
		self.dmglightningmax        = self.dmglightningmax + value
	end,
}

register_suffix "sfix_thunder"
{
	name       = " of Thunder",
	group	   = "dmglightning",
	min        = 1,
	max        = 20,
	occurence  = { TYPE_BOW },
	level      = 60,
	multiplier = 6,
	price_base = 12000,
	price_max  = 12000,

	OnApply = function(self,value)
		self.dmglightningmin        = self.dmglightningmin + value
		self.dmglightningmax        = self.dmglightningmax + value
	end,
}

--== + Steal Life % ==========================--

register_suffix "sfix_leech"
{
	name       = " of the Leech",
	group	   = "lifesteal",
	min        = 30,
	max        = 30,
	occurence  = { TYPE_WEAPON },
	level      = 8,
	multiplier = 4,
	price_base = 7500,
	price_max  = 7500,

		OnApply = function(self,value)
			self.lifestealmin        = value
			self.lifestealmax        = value
		end,
}

register_suffix "sfix_blood"
{
	name       = " of Blood",
	group	   = "lifesteal",
	min        = 50,
	max        = 50,
	occurence  = { TYPE_WEAPON },
	level      = 19,
	multiplier = 3,
	price_base = 15000,
	price_max  = 15000,

	OnApply = function(self,value)
		self.lifestealmin        = value
		self.lifestealmax        = value
	end,
}

--== + Steal Mana % ==========================--

register_suffix "sfix_bat"
{
	name       = " of the Bat",
	group	   = "manasteal",
	min        = 30,
	max        = 30,
	occurence  = { TYPE_WEAPON },
	level      = 8,
	multiplier = 3,
	price_base = 7500,
	price_max  = 7500,

	OnApply = function(self,value)
		self.manastealmin        = value
		self.manastealmax        = value
	end,
}

register_suffix "sfix_vampires"
{
	name       = " of Vampires",
	group	   = "manasteal",
	min        = 50,
	max        = 50,
	occurence  = { TYPE_WEAPON },
	level      = 19,
	multiplier = 3,
	price_base = 15000,
	price_max  = 15000,

	OnApply = function(self,value)
		self.manastealmin        = value
		self.manastealmax        = value
	end,
}

--== + Damage / Penetrate Armor ==========================--
-- These should lower target's AC on hit.
--[[
register_suffix "sfix_piercing"
{
	name       = " of Piercing",
	min        = 2,
	max        = 6,
	occurence  = { TYPE_WEAPON, TYPE_BOW },
	level      = 1,
	multiplier = 3,
	price_base = 1000,
	price_max  = 1000,

	OnApply = function(item,value)
		item.dmgmod = item.dmgmod + value
	end,
}

register_suffix "sfix_puncturing"
{
	name       = " of Puncturing",
	min        = 4,
	max        = 12,
	occurence  = { TYPE_WEAPON, TYPE_BOW },
	level      = 9,
	multiplier = 6,
	price_base = 2000,
	price_max  = 2000,

	OnApply = function(item,value)
		item.dmgmod = item.dmgmod + value
	end,
}

register_suffix "sfix_bashing"
{
	name       = " of Bashing",
	min        = 8,
	max        = 24,
	occurence  = { TYPE_WEAPON },
	level      = 17,
	multiplier = 12,
	price_base = 4000,
	price_max  = 4000,

	OnApply = function(item,value)
		item.dmgmod = item.dmgmod + value
	end,
}
--]]

--== + Light Radius % ==========================--

register_suffix "sfix_dark"
{
	name       = " of the Dark",
	group	   = "lightmod",
	min        = 40,
	max        = 40,
	occurence  = { TYPE_ARMOR, TYPE_WEAPON, TYPE_AMULET, TYPE_RING },
	flags      = { ifCursed },
	level      = 6,
	multiplier = -3,

	OnApply = function(item,value)
		item.lightmod = item.lightmod - value
	end,
}

register_suffix "sfix_night"
{
	name       = " of the Night",
	group	   = "lightmod",
	min        = 20,
	max        = 20,
	occurence  = { TYPE_ARMOR, TYPE_WEAPON, TYPE_AMULET, TYPE_RING },
	flags      = { ifCursed },
	level      = 3,
	multiplier = -2,

	OnApply = function(item,value)
		item.lightmod = item.lightmod - value
	end,
}

register_suffix "sfix_light"
{
	name       = " of Light",
	group	   = "lightmod",
	min        = 20,
	max        = 20,
	occurence  = { TYPE_ARMOR, TYPE_WEAPON, TYPE_AMULET, TYPE_RING },
	level      = 4,
	multiplier = 2,
	price_base = 750,
	price_max  = 750,

	OnApply = function(item,value)
		item.lightmod = item.lightmod + value
	end,
}

register_suffix "sfix_radiance"
{
	name       = " of Radiance",
	group	   = "lightmod",
	min        = 40,
	max        = 40,
	occurence  = { TYPE_ARMOR, TYPE_WEAPON, TYPE_AMULET, TYPE_RING },
	level      = 8,
	multiplier = 3,
	price_base = 1500,
	price_max  = 1500,

	OnApply = function(item,value)
		item.lightmod = item.lightmod + value
	end,
}

--== Weapon Speed ==========================--

register_suffix "sfix_readiness"
{
	name       = " of Readiness",
	group	   = "spdatk",
	min        = SPD_QUICK,
	max        = SPD_QUICK,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_BOW },
	level      = 1,
	multiplier = 2,
	price_base = 2000,
	price_max  = 2000,

	OnApply = function(item,value)
		item.spdatk = item.spdatk + value
	end,
}

register_suffix "sfix_swiftness"
{
	name       = " of Swiftness",
	group	   = "spdatk",
	min        = SPD_FAST,
	max        = SPD_FAST,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_BOW },
	level      = 10,
	multiplier = 4,
	price_base = 4000,
	price_max  = 4000,

	OnApply = function(item,value)
		item.spdatk = item.spdatk + value
	end,
}

register_suffix "sfix_speed"
{
	name       = " of Speed",
	group	   = "spdatk",
	min        = SPD_FASTER,
	max        = SPD_FASTER,
	occurence  = { TYPE_WEAPON, TYPE_STAFF },
	level      = 19,
	multiplier = 8,
	price_base = 8000,
	price_max  = 8000,

	OnApply = function(item,value)
		item.spdatk = item.spdatk + value
	end,
}

register_suffix "sfix_haste"
{
	name       = " of Haste",
	group	   = "spdatk",
	min        = SPD_FASTEST,
	max        = SPD_FASTEST,
	occurence  = { TYPE_WEAPON, TYPE_STAFF },
	level      = 27,
	multiplier = 16,
	price_base = 16000,
	price_max  = 16000,

	OnApply = function(item,value)
		item.spdatk = item.spdatk + value
	end,
}

--== Hit Recovery Speed ==========================--

register_suffix "sfix_balance"
{
	name       = " of Balance",
	group	   = "spdhit",
	min        = SPD_FAST,
	max        = SPD_FAST,
	occurence  = { TYPE_ARMOR, TYPE_RING, TYPE_AMULET },
	level      = 1,
	multiplier = 2,
	price_base = 2000,
	price_max  = 2000,

	OnApply = function(item,value)
		item.spdhit = item.spdhit + value
	end,
}

register_suffix "sfix_stability"
{
	name       = " of Stability",
	group	   = "spdhit",
	min        = SPD_FASTER,
	max        = SPD_FASTER,
	occurence  = { TYPE_ARMOR, TYPE_RING, TYPE_AMULET },
	level      = 10,
	multiplier = 4,
	price_base = 4000,
	price_max  = 4000,

	OnApply = function(item,value)
		item.spdhit = item.spdhit + value
	end,
}

register_suffix "sfix_harmony"
{
	name       = " of Harmony",
	group	   = "spdhit",
	min        = SPD_FASTEST,
	max        = SPD_FASTEST,
	occurence  = { TYPE_ARMOR, TYPE_RING, TYPE_AMULET },
	level      = 20,
	multiplier = 8,
	price_base = 8000,
	price_max  = 8000,

	OnApply = function(item,value)
		item.spdhit = item.spdhit + value
	end,
}

--== + Durability ==========================--

register_suffix "sfix_fragility"
{
	name       = " of Fragility",
	group	   = "dur",
	min        = 1,
	max        = 1,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON },
	flags      = { ifCursed },
	level      = 3,
	multiplier = -4,

	OnApply = function(item,value)
			item.durmod = -1
			item.durmax        = value
	     item.dur = value
	end,
}

register_suffix "sfix_brittleness"
{
	name       = " of Brittleness",
	group	   = "dur",
	min        = 26,
	max        = 75,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON },
	flags      = { ifCursed },
	level      = 1,
	multiplier = -2,

	OnApply = function(item,value)
		item.dur = math.max(1,item.dur - (value*item.durmax)/100)
		item.durmax        = math.max(item.durmax - (value*item.durmax)/100)
		item.durmod = -1
	end,
}

register_suffix "sfix_sturdiness"
{
	name       = " of Sturdiness",
	group	   = "dur",
	min        = 26,
	max        = 75,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON },
	level      = 1,
	multiplier = 2,
	price_base = 100,
	price_max  = 100,

	OnApply = function(item,value)
		item.dur = item.dur + (value*item.durmax)/100
		item.durmax        = item.durmax + (value*item.durmax)/100
		item.durmod = 1
	end,
}

register_suffix "sfix_craftmanship"
{
	name       = " of Craftmanship",
	group	   = "dur",
	min        = 51,
	max        = 100,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON },
	level      = 6,
	multiplier = 2,
	price_base = 200,
	price_max  = 200,

	OnApply = function(item,value)
		item.dur = item.dur + (value*item.durmax)/100
		item.durmax        = item.durmax + (value*item.durmax)/100
		item.durmod = 1
	end,
}

register_suffix "sfix_structure"
{
	name       = " of Structure",
	group	   = "dur",
	min        = 101,
	max        = 200,
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON },
	level      = 12,
	multiplier = 2,
	price_base = 300,
	price_max  = 300,

	OnApply = function(item,value)
		item.dur = item.dur + (value*item.durmax)/100
		item.durmax        = item.durmax + (value*item.durmax)/100
		item.durmod = 1
	end,
}

register_suffix "sfix_many"
{
	name       = " of Many",
	group	   = "dur",
	min        = 100,
	max        = 100,
	occurence  = { TYPE_BOW },
	level      = 3,
	multiplier = 2,
	price_base = 750,
	price_max  = 750,

	OnApply = function(item,value)
		item.dur    = item.dur + (value*item.durmax)/100
		item.durmax = item.durmax + (value*item.durmax)/100
		item.durmod = 1
	end,
}

register_suffix "sfix_plenty"
{
	name       = " of Plenty",
	group	   = "dur",
	min        = 200,
	max        = 200,
	occurence  = { TYPE_BOW },
	level      = 7,
	multiplier = 3,
	price_base = 1500,
	price_max  = 1500,

	OnApply = function(item,value)
		item.dur    = item.dur + (value*item.durmax)/100
		item.durmax = item.durmax + (value*item.durmax)/100
		item.durmod = 1
	end,
}

register_suffix "sfix_ages"
{
	name       = " of the Ages",
	group	   = "dur",
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_WEAPON, TYPE_STAFF },
	flags      = { ifIndest },
	level      = 25,
	multiplier = 5,
	price_base = 600,
	price_max  = 600,
}

--== Miscelaneous effects ==========================--

register_suffix "sfix_bear"
{
	name       = " of the Bear",
	group	   = "misc",
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_BOW },
	flags      = { ifKnockback },
	level      = 5,
	multiplier = 2,
	price_base = 750,
	price_max  = 750,
}

register_suffix "sfix_blocking"
{
	name       = " of Blocking",
	group	   = "spdblk",
	min        = SPD_FAST,
	max        = SPD_FAST,
	occurence  = { TYPE_SHIELD },
	level      = 5,
	multiplier = 4,
	price_base = 4000,
	price_max  = 4000,

	OnApply = function(item,value)
		item.spdblk = item.spdblk + value
	end,
}

register_suffix "sfix_thieves"
{
	name       = " of Thieves",
	group	   = "misc",
	occurence  = { TYPE_ARMOR, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
	flags      = { ifTrapResist },
	level      = 11,
	multiplier = 2,
	price_base = 1500,
	price_max  = 1500,
}
--[[
register_suffix "sfix_thorns"
{
	name       = " of Thorns",
	group	   = "misc",
	min        = 1,
	max        = 3,
	flags      = {ifThorns},
	occurence  = { TYPE_ARMOR, TYPE_SHIELD },
	level      = 1,
	multiplier = 2,
	price_base = 500,
	price_max  = 500,

	OnApply = function(item,value)

	end,
}

register_suffix "sfix_devastation"
{
	name       = " of Devastation",
	group	   = "misc",
	min        = ,
	max        = ,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_BOW },
	level      = 1,
	multiplier = 3,
	price_base = 1200,
	price_max  = 1200,

	OnApply = function(item,value)
		--5% chance of doing x3 damage
	end,
}

register_suffix "sfix_peril"
{
	name       = " of Peril",
	min        = ,
	max        = ,
	occurence  = { TYPE_WEAPON, TYPE_STAFF, TYPE_BOW },
	level      = 5,
	multiplier = 2,
	price_base = 500,
	price_max  = 500,

	OnApply = function(item,value)
		--x2 damage to monster, x1 to user
		--something like +100% dmg -50% lifesteal, I think.
	end,
}
--]]
