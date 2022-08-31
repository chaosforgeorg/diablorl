-- Data in this file comes from Jarulf:
--	5.4 Unique monsters

-- TODO - AC Values for unique monsters are probably not correct!

-- Random Unique NPCs

-- Zombie --

register_npc( "rotfeast", "zombie" )
{
	base   = "zombie",
	name   = "Rotfeast the Hungry",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = { nfUnique, nfUndead },
	ai     = AISkeleton,
	intf   = 3,
	mob    = true,
	dlvl   = 2,
	level  = 4,
	hpmin  = 85,
	hpmax  = 85,
	dmgmin = 4,
	dmgmax = 12,
}

register_npc( "soulpus", "zombie" )
{
	base   = "zombie",
	name   = "Soulpus",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfUndead},
	intf   = 0,
	mob    = false,
	dlvl   = 2,
	level  = 4,
	hpmin  = 133,
	hpmax  = 133,
	dmgmin = 4,
	dmgmax = 8,

	resfire      = 75,
	reslightning = 75,
}

register_npc( "rotcarnage", "zombie" )
{
	base   = "ghoul",
	name   = "Rotcarnage",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfUndead},
	intf   = 3,
	mob    = true,
	dlvl   = 3,
	level  = 6,
	hpmin  = 102,
	hpmax  = 102,
	dmgmin = 9,
	dmgmax = 24,
	ac     = 45,

	reslightning = 75,
}

register_npc( "goretongue", "zombie" )
{
	base   = "rotting_carcass",
	name   = "Goretongue",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = { nfUnique, nfUndead },
	ai     = AISkeleton,
	intf   = 1,
	mob    = false,
	dlvl   = 3,
	level  = 6,
	hpmin  = 156,
	hpmax  = 156,
	dmgmin = 15,
	dmgmax = 30,
}

-- Fallen --

register_npc( "pukerat_the_unclean", "fallen_spear" )
{
	base   = "fallen_one_spear",
	name   = "Pukerat the Unclean",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal},
	resfire= 75,
	intf   = 3,
	mob    = false,
	dlvl   = 2,
	level  = 4,
	hpmin  = 51,
	hpmax  = 51,
	dmgmin = 6,
	dmgmax = 18,
}

register_npc( "bongo", "fallen_spear" )
{
	base   = "devil_kin_spear",
	name   = "Bongo",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal},
	intf   = 3,
	mob    = true,
	dlvl   = 3,
	level  = 6,
	hpmin  = 178,
	hpmax  = 178,
	dmgmin = 9,
	dmgmax = 21,
}

register_npc( "bladeskin_the_slasher", "fallen_sword" )
{
	base   = "fallen_one_sword",
	name   = "Bladeskin the Slasher",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal},
	resfire= 75,
	intf   = 0,
	mob    = false,
	dlvl   = 2,
	level  = 4,
	hpmin  = 77,
	hpmax  = 77,
	dmgmin = 1,
	dmgmax = 5,
	ac     = 45,
}

register_npc( "gutshank_the_quick", "fallen_sword" )
{
	base   = "carver_sword",
	name   = "Gutshank the Quick",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal},
	resfire= 75,
	ai     = AIWingedFiend,
	intf   = 2,
	mob    = true,
	dlvl   = 3,
	level  = 6,
	hpmin  = 66,
	hpmax  = 66,
	dmgmin = 6,
	dmgmax = 16,
}

register_npc( "shadowcrow", "fallen_sword" )
{
	base   = "dark_one_sword",
	name   = "Shadowcrow",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal, nfInvisible},
	ai     = AIHidden,
	intf   = 2,
	mob    = true,
	dlvl   = 5,
	level  = 10,
	hpmin  = 270,
	hpmax  = 270,
	dmgmin = 12,
	dmgmax = 25,
}

-- Skeleton --

register_npc( "boneripper", "skeleton" )
{
	base   = "skeleton_axe",
	name   = "Boneripper",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfUndead, nfSkeleton},
	ai     = AIWingedFiend, --??????
	intf   = 0,
	mob    = true,
	dlvl   = 2,
	level  = 4,
	hpmin  = 54,
	hpmax  = 54,
	dmgmin = 6,
	dmgmax = 15,

	resfire = 100,
}

register_npc( "bonehead_keenaxe", "skeleton" )
{
	base   = "corpse_axe",
	name   = "Bonehead Keenaxe",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfUndead, nfSkeleton},
	intf   = 2,
	mob    = true,
	dlvl   = 2,
	level  = 4,
	hpmin  = 91,
	hpmax  = 91,
	dmgmin = 4,
	dmgmax = 10,
	tohit  = 100,
}

register_npc( "madeye_the_dead", "skeleton" )
{
	base   = "burning_dead",
	name   = "Madeye the Dead",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfUndead, nfSkeleton},
	ai     = AIWingedFiend, -- ?????
	intf   = 0,
	mob    = true,
	dlvl   = 4,
	level  = 84,
	hpmin  = 75,
	hpmax  = 75,
	dmgmin = 21,
	dmgmax = 24,

	resfire = 100,
}

register_npc( "brokenhead_bangshield", "skeleton_captain" )
{
	base   = "corpse_captain",
	name   = "Brokenhead Bangshield",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfUndead, nfSkeleton},
	intf   = 3,
	mob    = true,
	dlvl   = 4,
	level  = 6,
	hpmin  = 108,
	hpmax  = 108,
	dmgmin = 12,
	dmgmax = 20,

	reslightning = 75,
}

register_npc( "shadowdrinker", "skeleton_captain" )
{
	base   = "horror_captain",
	name   = "Shadowdrinker",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = { nfUnique, nfUndead, nfSkeleton },
	ai     = AIHidden,
	intf   = 1,
	mob    = true,
	dlvl   = 5,
	level  = 10,
	hpmin  = 300,
	hpmax  = 300,
	dmgmin = 18,
	dmgmax = 26,
	ac     = 45,

	resfire      = 75,
	reslightning = 75,
}

-- Scavenger --

register_npc( "shadowbite", "scavenger" )
{
	base   = "scavenger",
	name   = "Shadowbite",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal},
	ai     = AISkeleton,
	intf   = 3,
	mob    = true,
	dlvl   = 2,
	level  = 4,
	hpmin  = 60,
	hpmax  = 60,
	dmgmin = 3,
	dmgmax = 20,
	resfire = 100,
}

register_npc( "el_chupacabras", "scavenger" )
{
	base   = "plague_eater",
	name   = "El Chupacabras",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal},
	ai     = AIGoat,
	intf   = 0,
	mob    = true,
	dlvl   = 3,
	level  = 6,
	hpmin  = 120,
	hpmax  = 120,
	dmgmin = 10,
	dmgmax = 18,
	resfire = 75,
}

register_npc( "pulsecrawler", "scavenger" )
{
	base   = "shadow_beast",
	name   = "Pulsecrawler",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal},
	intf   = 0,
	mob    = true,
	dlvl   = 4,
	level  = 8,
	hpmin  = 150,
	hpmax  = 150,
	dmgmin = 16,
	dmgmax = 20,
	ac     = 45,
	resfire      = 100,
	reslightning = 75,
}

register_npc( "spineeater", "scavenger" )
{
	base   = "bone_gasher",
	name   = "Spineeater",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal},
	intf   = 1,
	mob    = true,
	dlvl   = 4,
	level  = 8,
	hpmin  = 180,
	hpmax  = 180,
	dmgmin = 18,
	dmgmax = 25,
	reslightning = 100,
}

-- Winged Fiend --

register_npc( "moonbender", "winged_fiend" )
{
	base   = "blink",
	name   = "Moonbender",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal},
	intf   = 0,
	mob    = true,
	dlvl   = 4,
	level  = 8,
	hpmin  = 135,
	hpmax  = 135,
	dmgmin = 9,
	dmgmax = 27,
	resfire = 100,
}

register_npc( "wrathraven", "winged_fiend" )
{
	base   = "blink",
	name   = "Wrathraven",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal},
	intf   = 2,
	mob    = true,
	dlvl   = 5,
	level  = 10,
	hpmin  = 135,
	hpmax  = 135,
	dmgmin = 9,
	dmgmax = 22,
	resfire = 100,
}

register_npc( "foulwing", "winged_fiend" )
{
	base   = "gloom",
	name   = "Foulwing",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfAnimal},
-- TODO
--	ai     =AIHornedDemon,
	intf   = 3,
	mob    = true,
	dlvl   = 5,
	level  = 10,
	hpmin  = 246,
	hpmax  = 246,
	dmgmin = 12,
	dmgmax = 28,
	resfire = 75,
}

-- Hidden --

register_npc ( "warpskull", "hidden" )
{
	base   = "hidden",
	name   = "Warpskull",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 2,
	mob    = true,
	dlvl   = 3,
	level  = 6,
	hpmin  = 117,
	hpmax  = 117,
	dmgmin = 6,
	dmgmax = 18,
	resfire      = 75,
	reslightning = 75,
}

-- Goat --

register_npc( "deathshade_fleshmaul", "goat" )
{
	base   = "stone_clan",
	name   = "Deathshade Fleshmaul",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	-- TODO
--	ai     = AIHornedDemon,
	intf   = 0,
	dlvl   = 6,
	level  = 10,
	hpmin  = 276,
	hpmax  = 276,
	dmgmin = 12,
	dmgmax = 24,

	resmagic = 100,
	resfire  = 75,
}

register_npc( "bloodgutter", "goat" )
{
	base   = "fire_clan",
	name   = "Bloodgutter",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	-- TODO
	ai     = AIWingedFiend,
	intf   = 1,
	dlvl   = 6,
	level  = 12,
	hpmin  = 315,
	hpmax  = 315,
	dmgmin = 24,
	dmgmax = 34,
	resfire = 100,
}

register_npc( "blighthorn_steelmace", "goat" )
{
	base   = "night_clan",
	name   = "Blighthorn Steelmace",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	-- TODO
--	ai     =AIHornedDemon,
	intf   = 0,
	dlvl   = 7,
	level  = 10,
	hpmin  = 250,
	hpmax  = 250,
	dmgmin = 20,
	dmgmax = 28,
	ac     = 55,

	reslightning = 75,
}


register_npc( "bloodskin_darkbow", "goat_archer" )
{
	base   = "flesh_clan_archer",
	name   = "Bloodskin Darkbow",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 0,
	mob    = true,
	dlvl   = 5,
	level  = 10,
	hpmin  = 207,
	hpmax  = 207,
	dmgmin = 3,
	dmgmax = 16,

	resfire      = 75,
	reslightning = 75
}

register_npc( "blightfire", "goat_archer" )
{
	base   = "fire_clan_archer",
	name   = "Blightfire",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 2,
	mob    = true,
	dlvl   = 7,
	level  = 14,
	hpmin  = 321,
	hpmax  = 321,
	dmgmin = 13,
	dmgmax = 21,
	resfire = 100
}

register_npc( "gorestone", "goat_archer" )
{
	base   = "night_clan_archer",
	name   = "Gorestone",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	reslightning = 75,
	intf   = 1,
	mob    = true,
	dlvl   = 7,
	level  = 14,
	hpmin  = 303,
	hpmax  = 303,
	dmgmin = 15,
	dmgmax = 28,
	tohit = 70
}

-- Overlord --

register_npc( "bilefroth", "overlord" )
{
	base   = "overlord",
	name   = "Bilefroth the Pit Master",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = true,
	ai     = AIWingedFiend,
	dlvl   = 6,
	level  = 12,
	hpmin  = 210,
	hpmax  = 210,
	dmgmin = 16,
	dmgmax = 23,
	resmagic     = 100,
	resfire      = 100,
	reslightning = 75
}

register_npc( "baron_sludge", "overlord" )
{
	base   = "mud_man",
	name   = "Baron Sludge",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = true,
	ai     = AIHidden,
	dlvl   = 8,
	level  = 16,
	hpmin  = 315,
	hpmax  = 315,
	dmgmin = 24,
	dmgmax = 35,
	resmagic     = 100,
	resfire      = 75,
	reslightning = 75
}


register_npc( "oozedrool", "overlord" )
{
	base   = "toad_demon",
	name   = "Oozedrool",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = true,
	dlvl   = 9,
	level  = 18,
	hpmin  = 483,
	hpmax  = 483,
	dmgmin = 25,
	dmgmax = 30,
	reslightning = 75
}

-- Gargoyle --

register_npc ( "nightwing_of_the_cold", "gargoyle" )
{
	base   = "gargoyle",
	name   = "Nightwing of the Cold",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = true,
	ai     = AIWingedFiend,
	dlvl   = 7,
	level  = 14,
	hpmin  = 342,
	hpmax  = 342,
	dmgmin = 18,
	dmgmax = 26,
	reslightning = 75,
}

register_npc ( "goblight_of_the_flame", "gargoyle" )
{
	base   = "blood_claw",
	name   = "Goblight of the Flame",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 0,
	mob    = true,
	dlvl   = 10,
	level  = 20,
	hpmin  = 405,
	hpmax  = 405,
	dmgmin = 20,
	dmgmax = 40,
	resfire = 100,
}

register_npc ( "viletouch", "gargoyle" )
{
	base   = "death_wing",
	name   = "Viletouch",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = true,
	dlvl   = 12,
	level  = 24,
	hpmin  = 525,
	hpmax  = 525,
	dmgmin = 20,
	dmgmax = 40,
	reslightning = 100,
}

-- Magma Demon --

register_npc ( "firewound_the_grim", "magma" )
{
	base   = "magma_demon",
	name   = "Firewound the Grim",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 0,
	mob    = true,
	dlvl   = 8,
	level  = 16,
	hpmin  = 303,
	hpmax  = 303,
	dmgmin = 18,
	dmgmax = 22,
	resfire = 75,
}

register_npc ( "breakspine", "magma" )
{
	base   = "mud_runner",
	name   = "Breakspine",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 0,
	mob    = true,
	dlvl   = 9,
	level  = 18,
	hpmin  = 351,
	hpmax  = 351,
	dmgmin = 25,
	dmgmax = 34,
	resfire = 75,
}

-- Horned Demon --

register_npc ( "blackstorm", "horned" )
{
	base   = "obsidian_lord",
	name   = "Blackstorm",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = true,
	dlvl   = 10,
	level  = 20,
	hpmin  = 525,
	hpmax  = 525,
	dmgmin = 20,
	dmgmax = 40,
	ac     = 90,
	resmagic     = 100,
	reslightning = 100,
}

register_npc ( "bluehorn", "horned" )
{
	base   = "frost_charger",
	name   = "Bluehorn",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = true,
	dlvl   = 11,
	level  = 22,
	hpmin  = 477,
	hpmax  = 477,
	dmgmin = 25,
	dmgmax = 30,
	ac     = 90,
	resmagic     = 100,
	reslightning = 75,
}

-- Acid Beast --

register_npc ( "deathspit", "spitting" )
{
	base   = "acid_beast",
	name   = "Deathspit",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 0,
	mob    = true,
	--ai     =AIFastSpit,
	dlvl   = 6,
	level  = 12,
	hpmin  = 303,
	hpmax  = 303,
	dmgmin = 12,
	dmgmax = 32,
	resfire      = 75,
	reslightning = 75,
}

register_npc ( "chaoshowler", "spitting" )
{
	base   = "poison_spitter",
	name   = "Chaoshowler",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 0,
	mob    = true,
	--ai     =AIFastSpit,
	dlvl   = 8,
	level  = 16,
	hpmin  = 240,
	hpmax  = 240,
	dmgmin = 12,
	dmgmax = 20,
}

register_npc ( "plaguewrath", "spitting" )
{
	base   = "poison_spitter",
	name   = "Plaguewrath",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 2,
	mob    = true,
	--ai     =AIFastSpit,
	dlvl   = 10,
	level  = 20,
	hpmin  = 450,
	hpmax  = 450,
	dmgmin = 20,
	dmgmax = 30,
	resmagic = 100,
	resfire  = 75,
}

-- Lightning Demon --

register_npc ( "brokenstorm", "lightning" )
{
	base   = "red_storm",
	name   = "Plaguewrath",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 2,
	mob    = true,
	--ai     =AIMagma,
	dlvl   = 9,
	level  = 18,
	hpmin  = 411,
	hpmax  = 411,
	dmgmin = 25,
	dmgmax = 36,
	reslightning  = 100
}

register_npc ( "the_flayer", "lightning" )
{
	base   = "storm_rider",
	name   = "The Flayer",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = true,
	--ai     =AIMagma,
	dlvl   = 10,
	level  = 20,
	hpmin  = 501,
	hpmax  = 501,
	dmgmin = 20,
	dmgmax = 35,
	resmagic = 75,
	resfire = 75,
	reslightning  = 100
}

register_npc ( "doomcloud", "lightning" )
{
	base   = "maelstorm",
	name   = "Doomcloud",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = false,
	--ai     =AIMagma,
	dlvl   = 13,
	level  = 24,
	hpmin  = 612,
	hpmax  = 612,
	dmgmin = 1,
	dmgmax = 60,
	resfire = 75,
	reslightning  = 100
}

-- Balrog --

register_npc ( "windspawn", "balrog" )
{
	base   = "vortex_lord",
	name   = "Windspawn",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = true,
	ai     = AISkeleton,
	dlvl   = 12,
	level  = 24,
	hpmin  = 711,
	hpmax  = 711,
	dmgmin = 35,
	dmgmax = 40,
	resmagic = 100
}

register_npc ( "gorefeast", "balrog" )
{
	base   = "vortex_lord",
	name   = "Gorefeast",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = false,
	ai     = AISkeleton,
	dlvl   = 13,
	level  = 24,
	hpmin  = 771,
	hpmax  = 771,
	dmgmin = 20,
	dmgmax = 55,
	resfire = 75
}

register_npc ( "blackskull", "balrog" )
{
	base   = "balrog",
	name   = "Blackskull",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = true,
	ai     = AISkeleton,
	dlvl   = 13,
	level  = 26,
	hpmin  = 750,
	hpmax  = 750,
	dmgmin = 25,
	dmgmax = 40,
	resmagic = 100,
	reslightning = 75
}

-- viper

register_npc ( "fangspeir", "viper" )
{
	base   = "cave_viper",
	name   = "Fangspeir",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = true,
	ai     = AISkeleton,
	dlvl   = 11,
	level  = 21,
	hpmin  = 444,
	hpmax  = 444,
	dmgmin = 15,
	dmgmax = 32,
	resfire = 100
}

register_npc ( "viperflame", "viper" )
{
	base   = "fire_drake",
	name   = "Viperflame",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = true,
	ai     = AISkeleton,
	dlvl   = 12,
	level  = 23,
	hpmin  = 570,
	hpmax  = 570,
	dmgmin = 25,
	dmgmax = 35,
	resfire = 100,
	reslightning = 75
}

register_npc ( "fangskin", "viper" )
{
	base   = "gold_viper",
	name   = "Fangskin",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 2,
	mob    = true,
	ai     = AISkeleton,
	dlvl   = 14,
	level  = 25,
	hpmin  = 681,
	hpmax  = 681,
	dmgmin = 15,
	dmgmax = 50,
	resmagic = 100,
	reslightning = 75
}

-- Succubus --

register_npc ( "witchfire", "succubus" )
{
	base   = "succubus",
	name   = "Witchfire the Unholy",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = true,
	ai     = AIGoatArcher,
	dlvl   = 12,
	level  = 24,
	hpmin  = 444,
	hpmax  = 444,
	dmgmin = 10,
	dmgmax = 20,
	resmagic = 100,
	resfire = 100,
	reslightning = 75
}

register_npc ( "witchmoon", "succubus" )
{
	base   = "snow_witch",
	name   = "Witchmoon",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = false,
	ai     = AIGoatArcher,
	dlvl   = 13,
	level  = 26,
	hpmin  = 310,
	hpmax  = 310,
	dmgmin = 30,
	dmgmax = 40,
	reslightning = 75
}

register_npc ( "stareye", "succubus" )
{
	base   = "hell_spawn",
	name   = "Stareye the Witch",
	color  = LIGHTMAGENTA,
	random = false,
	flags  = {nfUnique, nfDemon},
	intf   = 2,
	mob    = false,
	ai     = AIGoatArcher,
	dlvl   = 14,
	level  = 28,
	hpmin  = 726,
	hpmax  = 726,
	dmgmin = 30,
	dmgmax = 50,
	resfire = 100
}

-- knight --

register_npc ( "lionskull", "knight" )
{
	base   = "black_knight",
	name   = "Lionskull the Bent",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 2,
	mob    = true,
	ai     = AISkeleton,
	dlvl   = 12,
	level  = 24,
	hpmin  = 525,
	hpmax  = 525,
	dmgmin = 25,
	dmgmax = 25,
	resmagic = 100,
	resfire = 100,
	reslightning = 100
}

register_npc ( "rustweaver", "knight" )
{
	base   = "doom_guard",
	name   = "Rustweaver",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = false,
	ai     = AISkeleton,
	dlvl   = 13,
	level  = 26,
	hpmin  = 400,
	hpmax  = 400,
	dmgmin = 1,
	dmgmax = 60,
	resmagic = 100,
	resfire = 100,
	reslightning = 100
}

register_npc ( "graywar", "knight" )
{
	base   = "doom_guard",
	name   = "Graywar the Hunter",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = false,
	ai     = AISkeleton,
	dlvl   = 14,
	level  = 26,
	hpmin  = 672,
	hpmax  = 672,
	dmgmin = 30,
	dmgmax = 50,
	reslightning = 75
}

register_npc ( "steelskull", "knight" )
{
	base   = "steel_lord",
	name   = "Steelskull the Hunter",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = false,
	ai     = AISkeleton,
	dlvl   = 14,
	level  = 28,
	hpmin  = 831,
	hpmax  = 831,
	dmgmin = 40,
	dmgmax = 50,
	reslightning = 75
}

-- mage --

register_npc ( "dreadjudge", "mage" )
{
	base   = "magistrate",
	name   = "Dreadjudge",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = true,
	ai     = AIMage,
	dlvl   = 14,
	level  = 27,
	hpmin  = 540,
	hpmax  = 540,
	dmgmin = 30,
	dmgmax = 40,
	resmagic = 100,
	resfire  = 75,
	reslightning = 75
}

register_npc ( "vizier", "mage" )
{
	base   = "cabalist",
	name   = "The Vizier",
	color  = LIGHTMAGENTA,
	random = true,
	flags  = {nfUnique, nfDemon},
	intf   = 2,
	mob    = true,
	ai     = AIMage,
	dlvl   = 15,
	level  = 29,
	hpmin  = 850,
	hpmax  = 850,
	dmgmin = 25,
	dmgmax = 40,
	resfire  = 100
}

-- Quest Unique NPCs --
-----------------------

--== Butcher ========================================================--

register_npc ( "the_butcher", "npc" )
{
	name   = "the Butcher",
	ai     = AIButcher,
	pic    = "B",
	intf   = 3,
	corpse = "bloody_corpse",
	color  = LIGHTMAGENTA,
	flags  = {nfUnique, nfDemon},
	level  = 6,
	hpmin  = 110,
	hpmax  = 110,
	size   = 2000,
	tohit  = 50,
	ac     = 50,
	spdmov = 40,
	spdhit = 30,
	spdatk = 60,
	dmgmin = 6,
	dmgmax = 12,
	sound  = "monsters/fatc/fatc",
	expvalue = 710,

	OnSpot = function()
		ui.msg("Butcher exclaims \"Ahh...fresh meat!\"")
		ui.play_sound("sfx/monsters/butcher.wav")
	end,

	OnDrop = function(self)
		self:get_level():drop_unique('cleaver', self.position )
	end,

	OnDie = function()
		player:play_sound(80);
		ui.msg_enter("@<\"The spirits of the dead are now avenged\"@>")
		player.quest["butcher"] = 2
	end,
}

--== Leoric =========================================================--

register_npc ( "leoric", "npc" )
{
	name   = "Skeleton King",
	ai     = AILeoric,
	pic    = "K",
	corpse = "bones",
	color  = LIGHTMAGENTA,
	intf   = 3,
	flags  = {nfUnique, nfUndead, nfOpenDoors},
	size   = 1010,
	level  = 14,
	hpmin  = 120,
	hpmax  = 120,
	ac     = 70,
	tohit  = 60,
	dmgmin = 6,
	dmgmax = 16,
	spdmov = 30,
	spdhit = 30,
	spdatk = 80,
	sound  = "monsters/sking/sking",

	resmagic     = 100,
	resfire      = 75,
	reslightning = 75,
	expvalue     = 570,

	OnDrop = function(self)
		self:get_level():drop_unique('undead_crown', self.position )
	end,

	OnDie = function()
		player:play_sound("82")
		ui.msg_enter("@<\"Rest well Leoric. I'll find your son.\"@>")
		player.quest["leoric_quest"] = 3
	end,
}

register_npc( "snotspill", "fallen_spear" )
{
	base   = "dark_one_spear",
	name   = "Snotspill",
	color  = LIGHTMAGENTA,
	flags  = {nfUnique, nfAnimal},
	ai     = AINPC,
	level  = 8,
	hpmin  = 220,
	hpmax  = 220,
	tohit  = 30,
	dmgmin = 10,
	dmgmax = 18,
	expvalue    = 510,
	reslightning = 75,

	OnTalk = function()
		local qitem = player:get_item("tavern_sign")
		if player.quest["sign"] < 2 then
			ui.play_sound("sfx/monsters/snot01.wav")
			ui.plot_talk("Hey - you that one that kill all! You get me magic banner or we attack! You no leave with Life! You kill big uglies and give back magic. Go past corner and door. Find uglies. You give, you go!")
			player.quest["sign"] = 2
		elseif qitem then
			ui.play_sound("sfx/monsters/snot03.wav")
			ui.plot_talk("You give! Yes, good! Go now, we strong! We kill all with big magic! (laughs) ")
			qitem:destroy()
			player.quest["sign"] = 5
			levels["level4"].OnEnter(player:get_level())
		else
			ui.play_sound("sfx/monsters/snot02.wav")
			ui.plot_talk("You kill uglies, get banner. You bring to me, or else...")
		end
	end,
}

register_npc( "gharbad", "goat" )
{
	name   = "Gharbad",
	ai     = AINPC,
	intf   = 3,
	color  = LIGHTMAGENTA,
	flags  = {nfUnique, nfDemon, nfOpenDoors},
	level  = 7,
	hpmin  = 120,
	hpmax  = 120,
	tohit  = 50,
	ac     = 40,
	dmgmin = 6,
	dmgmax = 16,

	expvalue     = 460,
	reslightning = 75,

	OnTalk = function(self)
		local state = player.quest["gharbad_quest"]
		if state < 2 then
			quests["gharbad_quest"].OnJournal()
			player.quest["gharbad_quest"] = 1
		elseif state < 4 then
			ui.play_sound("sfx/monsters/garbud02.wav");
			ui.plot_talk("Something for you I am making. Again, not kill Gharbad, live and give good.@/@/You take this as proof I keep word...")
			if (state == 2) then
				self:get_level():drop_random_item( player.position, 7, 100, 0)
			end
			player.quest["gharbad_quest"] = 3
		elseif state < 6 then
			ui.play_sound("sfx/monsters/garbud03.wav");
			ui.plot_talk("Nothing yet! Almost done.@/@/Very powerful, very strong. Live! Live!@/@/No pain and promise I keep!")
			player.quest["gharbad_quest"] = 5
		elseif state == 6 then
			ui.play_sound("sfx/monsters/garbud04.wav");
			ui.plot_talk("This too good for you. Very powerful! You want - you take!")
			self:set_ai( AIGoat )
		end
	end,

	OnSpot = function()
		local state = player.quest["gharbad_quest"]
		if (state % 2 == 1) then
			-- inc from odd to even state
			player.quest["gharbad_quest"] = state + 1
		end
	end,

	OnDie = function()
		player:play_sound(61);
		ui.msg_enter("@<\"I'm not impressed.\"@>")
		player.quest["gharbad_quest"] = 7
	end,

	OnDrop = function(self)
		local id = utils.random_item_req(7, { type = TYPE_WEAPON, pic = "\\" } )
		self:get_level():drop_random_base(id,self.position,7,100,0)
	end,
}

register_npc( "zhar_the_mad", "mage" )
{
	base    = "counselor",
	name 	= "Zhar the mad",
	ai   	= AINPC,
	intf 	= 3,
	color 	= LIGHTMAGENTA,
	flags 	= {nfUnique, nfDemon, nfOpenDoors},
	level 	= 16,
	hpmin 	= 360,
	hpmax 	= 360,
	tohit 	= 90,
	dmgmin 	= 16,
	dmgmax 	= 40,
	expvalue= 3876,

	resmagic     = 100,
	resfire      = 75,
	reslightning = 75,

	OnTalk = function()
		if player.quest["mad_mage"] == 0 then
			player.quest["mad_mage"] = 1
			local level  = self:get_level()
			level:drop_item( utils.random_item_req( level.depth * 2, { type = TYPE_BOOK } ), player.position )
		end
		quests["mad_mage"].OnJournal()
	end,

	OnDie = function()
		player:play_sound(62);
		ui.msg_enter("@<\"I'm sorry, did I break your concentration?\"@>")
		player.quest["mad_mage"] = 2
	end
}

register_npc ( "bloodlust", "succubus" )
{
	base   = "hell_spawn",
	name   = "Bloodlust",
	color  = LIGHTMAGENTA,
	random = false,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = false,
	ai     = AIGoatArcher,
	dlvl   = 15,
	level  = 28,
	hpmin  = 825,
	hpmax  = 825,
	dmgmin = 20,
	dmgmax = 55,
	resmagic = 100,
	reslightning = 100
}

register_npc ( "blackjade", "succubus" )
{
	base   = "hell_spawn",
	name   = "Blackjade",
	color  = LIGHTMAGENTA,
	random = false,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = false,
	ai     = AIGoatArcher, --AISuccubus
	dlvl   = 15,
	level  = 28,
	hpmin  = 400,
	hpmax  = 400,
	dmgmin = 30,
	dmgmax = 50,
	resmagic = 100,
	reslightning = 75
}

register_npc ( "red_vex", "succubus" )
{
	base   = "hell_spawn",
	name   = "Red Vex",
	color  = LIGHTMAGENTA,
	random = false,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = false,
	ai     = AIGoatArcher, --AISuccubus
	dlvl   = 15,
	level  = 28,
	hpmin  = 400,
	hpmax  = 400,
	dmgmin = 30,
	dmgmax = 50,
	resmagic = 100,
	resfire = 75
}

register_npc ( "warlord_of_blood", "knight" )
{
	base   = "steel_lord",
	name   = "Warlord of Blood",
	color  = LIGHTMAGENTA,
	random = false,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = false,
	ai     = AISkeleton, --AIWarlord
	dlvl   = 13,
	level  = 28,
	hpmin  = 850,
	hpmax  = 850,
	dmgmin = 35,
	dmgmax = 50,
	resmagic = 100,
	resfire = 100,
	reslightning = 100
}

register_npc ( "lachdanan_ghost", "knight" )
{
	base   = "blood_knight",
	name   = "Lachdanan",
	color  = LIGHTMAGENTA,
	random = false,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = false,
	ai     = AINPC, --AIWarlord
	dlvl   = 14,
	level  = 30,
	hpmin  = 500,
	hpmax  = 500,
	dmgmin = 0,
	dmgmax = 0
}

register_npc ( "gorash", "knight" )
{
	base   = "blood_knight",
	name   = "Sir Gorash",
	color  = LIGHTMAGENTA,
	random = false,
	flags  = {nfUnique, nfDemon},
	intf   = 1,
	mob    = false,
	ai     = AISkeleton, --AIWarlord
	dlvl   = 16,
	level  = 30,
	hpmin  = 1050,
	hpmax  = 1050,
	dmgmin = 20,
	dmgmax = 60
}

register_npc ( "traitor_lazarus", "mage" )
{
	base   = "advocate",
	name   = "Arch-Bishop Lazarus",
	color  = LIGHTMAGENTA,
	random = false,
	flags  = {nfUnique, nfDemon},
	intf   = 3,
	mob    = false,
	ai     = AIMage, --AILazarus
	dlvl   = 15,
	level  = 30,
	hpmin  = 600,
	hpmax  = 600,
	dmgmin = 30,
	dmgmax = 50,
	resmagic = 100,
	resfire  = 75,
	reslightning = 75
}

--== Diablo ==========================================================--

--[[
register_npc( "diablo", "npc" )
{
	name   = 'Diablo',
	ai     = AISkeleton,
	flags  = {nfUndead, nfDemon, nfOpenDoors},
	pic    = "D",
	size   = 2000,
	corpse = "corpse",
	spdmov = 30,
	spdhit = 30,
	spdatk = 80,
	sound  = "monsters/diablo/diablo",
}
--]]


--Spell summoned NPCs --
------------------------

--== Golem ==========================================================--

register_npc( "golem", "npc" )
{
	name   = 'golem',
	ai     = AIGolem,
	pic    = "y",
	flags  = {},
	size   = 386,
	intf   = 0,
	color  = BROWN,
	level  = 12,
	hpmin  = 12,
	hpmax  = 12,
	tohit  = 40,
	ac     = 25,
	dmgmin = 8,
	dmgmax = 16,
	spdmov = 80,
	spdatk = 60,
	spdhit = 0,
	corpse = "corpse",
	sound  = "monsters/golem/golem",
	expvalue = 0,

	OnDrop = function() end,
}

--== Guardian =======================================================--

register_npc( "hydra", "npc" )
{
	name   = 'guardian',
	ai     = AIGuardian,
	flags  = {nfInvulnerable},
	intf   = 0,
	pic    = "Y",
	color  = BROWN,
	level  = 12,
	hpmin  = 12,
	hpmax  = 12,
	tohit  = 40,
	ac     = 25,
	dmgmin = 8,
	dmgmax = 16,
	size   = 386,
	corpse = "",
	spdmov = 0,
	spdatk = 80,
	spdhit = 0,
	sound  = "",
	expvalue = 0,

	OnDrop = function() end,
}
