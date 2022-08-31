-- The Butcher ----------------------------------

register_item ( "cleaver", "axe" )
{
	name       = "cleaver",
	random_weight = 0,
	price      = 2000,
	minstr     = 22,
	dmgmin     = 2,
	dmgmax     = 12,
	durability = 20,
}


register_unique "the_butchers_cleaver"
{
	name = "The Butcher's Cleaver",
	base = {"cleaver"},
	price = 3650,
	-- +10 strength, unusual damage (4-24), altered durability (10)
	effect = {
		str		= 10,
		dmgmin	= 4,
		dmgmax	= 24,
		durmax	= 10
	}
}

-- Poisoned Water Supply ------------------------

register_item( "ringq", "ring" )
{
	random_weight = 0,
	price		= 1000
}

register_unique "ring_of_truth"
{
	name	= "ring of Truth",
	base	= {"ringq"},
	price	= 9100,
	-- +10 life, +10% resist all, -1 damage from enemies
	effect	= {
		hpmod      = 10,
		reslightning = 10,
		resfire      = 10,
		resmagic     = 10,
		dmgtaken     = -1
	}
}

-- The Curse of King Leoric ---------------------

register_item ( "undead_crown_base", "helm" )
{
	name       = "crown",
	random_weight = 0,
	acmin      = 8,
	acmax      = 12,
	durability = 50,
	price      = 10000
}

register_unique "the_undead_crown"
{
	name = "the Undead Crown",
	base = {"undead_crown_base"},
	price = 16650,
	-- AC 8, 0-12.5% steal life
	effect = {
		ac			 = 8,
		lifestealmin = 0,
		lifestealmax = 125
	}
}

-- Ogden's Sign ---------------------------------

register_item "tavern_sign"
{
	name       = "tavern sign",
	type       = TYPE_OTHER,
	random_weight = 0,
	color      = BROWN,
	price      = 0,
	volume     = 6,
	pic        = "\226",
    sound2     = "sfx/items/flipsign.wav",
    sound1     = "sfx/items/invsign.wav"
}

register_item ( "crest", "helm" )
{
	name       = "crest",
	random_weight = 0,
	acmin      = 0,
	acmax      = 0,
	durability = 15,
	price      = 2000
}

register_unique "harlequin_crest"
{
	name = "Harlequin Crest",
	base = {"crest"},
	price = 3650,
	-- AC -3, +2 all attributes, +7 mana, +7 life, -1 damage from enemies
	effect = {
		ac			= -3,
		str			= 2,
		dex			= 2,
		vit			= 2,
		mag			= 2,
		mpmod		= 7,
		hpmod		= 7,
		dmgtaken	= -1
	}
}

-- The Magic Rock -------------------------------

register_item "sky_rock"
{
	name       = "magic rock",
	type       = TYPE_OTHER,
	random_weight = 0,
	color      = BLUE,
	price      = 0,
	volume     = 4,
	pic        = "*",
    sound2     = "sfx/items/fliprock.wav",
    sound1     = "sfx/items/invrock.wav",

	OnPickUp = function()
		if player.quest["sky_rock_quest"] == 1 then
			player:play_sound('87')
			ui.msg("@<\"This must be what Griswold wanted.\"@>")
			player.quest["sky_rock_quest"] = 2
		end
	end,
}

register_unique "empyrean_band"
{
	name		= "Empyrean Band",
	base		= {"ringq"},
	price		= 8000,
	-- +2 all attributes, fast hit recovery, absorbs half of trap damage, +20% light radius
	effect = {
		str        = 2,
		dex        = 2,
		vit        = 2,
		mag        = 2,
		spdhit	   = SPD_FASTER,
		lightmod   = 20
	},
	OnApply = function ( item )
		item.flags[ ifTrapResist ] = true
	end
}

-- Valor ----------------------------------------

register_item "blood_stone"
{
	name       = "blood stone",
	type       = TYPE_OTHER,
	random_weight = 0,
	color      = RED,
	price      = 0,
	volume     = 1,
	pic        = "*",
    sound2     = "sfx/items/flipblst.wav",
    sound1     = "sfx/items/invblst.wav"
}

register_item ( "arkaines_valor_base", "harmor" )
{
	name       = "Arkaine's Valor",
	random_weight = 0,
	acmin      = 40,
	acmax      = 45,
	durability = 40,
	price      = 5800,

	OnPickUp = function()
		if player.quest["valor"] == 4 then
			player:play_sound('91')
			ui.msg("@<\"May the spirit of Arkaine protect me.\"@>")
			player.quest["valor"] = 5
		end
	end
}

register_unique "arkaines_valor"
{
	name	= "Arkaine's Valor",
	base	= {"arkaines_valor_base"},
	price	= 42000,
	-- AC 25, +10 vitality, -3 damage from enemies, fastest hit recovery
	effect	= {
		ac	= 25,
		vit	= 10,
		dmgtaken   = -3,
		spdhit     = SPD_FASTER
	}
}

-- Halls of Blind -------------------------------

register_item ( "amuletq", "amulet" )
{
	price = 1200,
	level = 8
}

register_unique "optic_amulet"
{
	name	= "optic amulet",
	base	= {"amuletq"},
	price      = 9750,
	-- +5 magic, +20% resist lightning, -1 damage from enemies, +20% light radius
	effect = {
		mag        = 5,
		dmgtaken   = -1,
		lightmod   = 20,
		reslightning = 20
	}
}

-- Black Mushroom -------------------------------

-- TODO: black mushroom, brain, spectral elixir

-- Anvil of Fury --------------------------------

register_item ( "griswolds_edge_base", "sword" )
{
	name       = "broad sword",
	random_weight = 0,
	dmgmin     = 4,
	dmgmax     = 12,
	durability = 50,
	price      = 750,
	minstr     = 40
}

register_unique "griswolds_edge"
{
	name = "Griswold's Edge",
	base = {"griswolds_edge_base"},
	price = 42000,
	-- -20 life, +20 mana, +25% to hit, 1-10 fire damage, fast attack, knocks target back
	effect = {
		hpmod		= -20,
		mpmod		= 20,
		tohit		= 25,
		dmgfiremin	= 1,
		dmgfiremax	= 10,
		spdatk		= SPD_FAST
	},
	OnApply = function ( item )
		item.flags[ifKnockback] = true
	end
}

-- Lachdanan ------------------------------------

-- TODO: Golden Elixir

register_item ( "veil_of_steel_base", "helm" )
{
	name		= "great helm",
	random_weight = 0,
	acmin		= 18,
	acmax		= 18,
	durability	= 60,
	price		= 400,
}

register_unique "veil_of_steel"
{
	name = "Veil of Steel",
	base = {"veil_of_steel_base"},
	price = 63800,
	-- +15 strength, +15 vitality, -30 mana, +60% armor, +50% resist all, -20% light radius
	effect = {
		str				= 15,
		vit				= 15,
		mpmod			= -30,
		acmodprc		= 60,
		resfire			= 50,
		reslightning	= 50,
		resmagic		= 50,
		lightmod		= -20
	}
}

-- Archbishop Lazarus ---------------------------

-- TODO: Staff of Lazarus



--[[
register_unique "bovine_plate"
{
	name = "Bovine Plate",
	base = {"bovine_plate_base"},
	level = 1,
	price = 400,
	-- AC 150, -50 mana, +30% resist all, -2 spell levels, +50% light radius, indestructible
	effect = {

	}
}
]]



--[[
register_unique "auric_amulet"
{
	name = "Auric Amulet",
	base = {"amuletq"},
	level = 1,
	price = 100,
	-- Allows you to carry piles of 10 000 gold
	effect = {

	}
}
]]




