core.register_blueprint "unique"
{
	id          = { true,  core.TSTRING },
	name        = { true,  core.TSTRING },
	base		= { true,  core.TTABLE },
	level		= { false,  core.TNUMBER, 1 },
	price		= { true,  core.TNUMBER },
	effect		= { false, core.TTABLE },
	OnApply		= { false,  core.TFUNC }
}

--------------------------------------------------------
--                    WEAPONS
--------------------------------------------------------

-- axes ------------------------------------------------

register_unique "the_mangler"
{
	name = "The Mangler",
	base = {"large_axe"},
	level = 2,
	price = 2850,
	-- -5 magic, -5 dexterity, -10 mana, +200% damage
	effect = {
		mag        = -5,
		dex        = -5,
		mpmod      = -10,
		dmgmodprc  = 200,
	}
}

register_unique "sharp_beak"
{
	name = "Sharp Beak",
	base = {"large_axe"},
	level = 2,
	price = 2850,
	-- -10 magic, +20 life, -10 mana
	effect = {
		mag        = -10,
		hpmod      = 20,
		mpmod      = -10
	}
}

register_unique "bloodslayer"
{
	name = "Bloodslayer",
	base = {"broad_axe"},
	level = 3,
	price = 2500,
	-- -5 all attributes, +100% damage, +200% damage versus demons, -1 spell level
	effect = {
		str        = -5,
		mag        = -5,
		dex        = -5,
		vit        = -5,
		dmgmodprc  = 100,
		vsdemon    = 300,
		spelllevel = -1
	}
}

register_unique "the_celestial_axe"
{
	name = "The Celestial Axe",
	base = {"battle_axe"},
	level = 4,
	price = 14100,
	-- -15 strength, +15 life, +15% to hit, no strength requirements
	effect = {
		str		= -15,
		hpmod	= 15,
		tohit	= 15,
		strreq	= 0
	}
}

register_unique "wicked_axe"
{
	name = "Wicked Axe",
	base = {"large_axe"},
	level = 5,
	price = 31150,
	-- +10 dexterity, -10 vitality, +30% to hit, -1- -6 damage from enemies, indestructible
	effect = {
		dex        = 10,
		vit        = -10,
		tohit      = 30
	},
	OnApply = function( item )
		item.flags[ifIndest]	= true
		item.dmgtaken 			= -math.random(1,6)
	end,
}

register_unique "stonecleaver"
{
	name = "Stonecleaver",
	base = {"broad_axe"},
	level = 7,
	price = 23900,
	-- +30 life, +20% to hit, +50% damage, +40% resist lightning
	effect = {
		hpmod        = 30,
		tohit        = 20,
		dmgmodprc    = 50,
		reslightning = 40
	}
}

register_unique "aguinaras_hatchet"
{
	name = "Aguinara's Hatchet",
	base = {"small_axe"},
	level = 12,
	price = 24800,
	-- +10 magic, +75% resist magic, +1 spell level,
	effect = {
		mag        = 10,
		resmagic   = 75,
		spelllevel = 1
	}
}

register_unique "hellslayer"
{
	name = "Hellslayer",
	base = {"battle_axe"},
	level = 15,
	price = 26200,
	-- +8 strength, +8 vitality, +25 life, -25 mana, +100% damage
	effect = {
		str        = 8,
		vit        = 8,
		hpmod      = 25,
		mpmod      = -25,
		dmgmodprc  = 100
	}
}

register_unique "messerschmidts_reaver"
{
	name = "Messerschmidt's Reaver",
	base = {"great_axe"},
	level = 25,
	price = 58000,
	-- +5 all attributes, -50 life, +15 damage, +200% damage, 2-12 fire damage
	effect = {
		str        = 5,
		mag        = 5,
		dex        = 5,
		vit        = 5,
		hpmod      = -50,
		dmgmod     = 15,
		dmgmodprc  = 200,
		dmgfiremin = 2,
		dmgfiremax = 12,
	}
}

-- bows ------------------------------------------------

register_unique "the_rift_bow"
{
	name = "The Rift Bow",
	base = {"short_bow"},
	level = 1,
	price = 1800,
	-- -3 dexterity, +2 damage, random speed arrows
	effect = {
		-- TODO: random speed arrows
		dex        = -3,
		dmgmod     = 2
	}
}

register_unique "the_celestial_bow"
{
	name = "The Celestial Bow",
	base = {"long_bow"},
	level = 2,
	price = 1200,
	-- AC 5, +2 damage, no strength requirement
	effect = {
		ac		= 5,
		dmgmod	= 2,
		strreq	= 0
	}
}

register_unique "the_needler"
{
	name = "The Needler",
	base = {"short_bow"},
	level = 2,
	price = 8900,
	-- +50% to hit, unusual item damage (1-3), fast attack
	effect = {
		tohit	= 50,
		dmgmax 	= 3,
		spdatk	= SPD_FAST
	}
}

register_unique "deadly_hunter"
{
	name = "Deadly Hunter",
	base = {"composite_bow"},
	level = 3,
	price = 8750,
	-- -5 magic, +20% to hit, +200% damage versus demons
	effect = {
		mag        = -5,
		tohit      = 20,
		vsdemon    = 300
	}
}

register_unique "bow_of_the_dead"
{
	name = "Bow of the Dead",
	base = {"composite_bow"},
	level = 5,
	price = 2500,
	-- -3 vitality, +4 dexterity, +10% to hit, -20% light radius, altered durability (30)
	effect = {
		vit        = -3,
		dex        = 4,
		tohit      = 10,
		lightmod   = -20,
		durmax     = 30
	}
}

register_unique "the_blackoak_bow"
{
	name = "The Blackoak Bow",
	base = {"long_bow"},
	level = 5,
	price = 2500,
	-- +10 dexterity, -10 vitality, +50% damage, -10% light radius
	effect = {
		dex        = 10,
		vit        = -10,
		dmgmodprc  = 50,
		lightmod   = -10
	}
}

register_unique "flamedart"
{
	name = "Flamedart",
	base = {"hunters_bow"},
	level = 10,
	price = 14250,
	-- +20% to hit, +40% resist fire, 1-6 fire arrows
	effect = {
		tohit		= 20,
		resfire		= 40,
		dmgfiremin	=	1,
		dmgfiremax	=	6
	}
}
--[[
register_unique "flambeau"
{
	name = "Flambeau",
	base = {"composite_bow"},
	level = 11,
	price = 30000,
	-- Fireball damage 15-204, unusual item damage (0), indestructible
	OnApply = function( item )
		--todo: make it fire fireballs
		item.flags[ifIndest]	= true
	end
}

register_unique "blitzen"
{
	name = "Blitzen",
	base = {"composite_bow"},
	level = 13,
	price = 30000,
	-- Lightning damage 10-153, unusual item damage (0), indestructible
	OnApply = function( item )
		--todo: make it fire lightnings
		item.flags[ifIndest]	= true
	end
}
]]
register_unique "fleshstinger"
{
	name = "Fleshstinger",
	base = {"long_bow"},
	level = 13,
	price = 16500,
	-- +15 dexterity, +40% to hit, +80% damage, high durability (37)
	effect = {
		dex			= 15,
		tohit		= 40,
		dmgmodprc	= 80,
		durmax		= 37
	}
}
--[[
register_unique "gnat_sting"
{
	name = "Gnat Sting",
	base = {"hunters_bow"},
	level = 15,
	price = 30000,
	-- multiple arrows, unusual item damage (1-2), quick attack, indestructible
	OnApply = function( item )
		--todo: make it fire 3 arrows
		item.flags[ifIndest]	= true
	end
}
]]
register_unique "windforce"
{
	name = "Windforce",
	base = {"long_war_bow"},
	level = 17,
	price = 37750,
	-- +5 strength, +200% damage, knocks target back
	effect = {
		str        = 5,
		dmgmodprc  = 200
	},
	OnApply = function( item )
		item.flags[ifKnockback]	= true
	end
}

register_unique "eaglehorn"
{
	name = "Eaglehorn",
	base = {"long_battle_bow"},
	level = 26,
	price = 42500,
	-- +20 dexterity, +50% to hit, +100% damage, indestructible
	effect = {
		dex        = 20,
		tohit      = 50,
		dmgmodprc  = 100
	},
	OnApply = function( item )
		item.flags[ifIndest]	= true
	end
}

-- clubs -----------------------------------------------

register_unique "civerbs_cudgel"
{
	name = "Civerb's Cudgel",
	base = {"mace"},
	level = 1,
	price = 2000,
	-- -2 magic, -5 dexterity, +200% damage versus demons
	effect = {
		mag		= -2,
		dex		= -5,
		vsdemon	= 300
	}
}

register_unique "crackrust"
{
	name = "Crackrust",
	base = {"mace"},
	level = 1,
	price = 11375,
	-- +2 all attributes, +15% resist all, +50% damage, -1 spell level, indestructible
	effect = {
		str          = 2,
		mag          = 2,
		dex          = 2,
		vit          = 2,
		resfire      = 15,
		reslightning = 15,
		resmagic     = 15,
		dmgmodprc    = 50,
		spelllevel   = -1
	},
	OnApply = function( item )
		item.flags[ifIndest]	= true
	end
}
--[[
--TODO : make it extremely rare
register_unique "lightforge"
{
	name = "Lightforge",
	base = {"mace"},
	level = 1,
	price = 26675,
	-- +8 all attributes, +25% to hit, +150% damage, +10-20 fire damage, +40% light radius, indestructible
	effect = {
		str			= 8,
		mag			= 8,
		dex			= 8,
		vit			= 8,
		tohit		= 25,
		dmgmodprc	= 150,
		dmgfiremin	= 10,
		dmgfiremax	= 20,
		lightmod	= 40
	},
	OnApply = function( item )
		item.flags[ifIndest]	= true
	end
}
]]
register_unique "hammer_of_jholm"
{
	name = "Hammer of Jholm",
	base = {"maul"},
	level = 1,
	price = 8700,
	-- +3 strength, +4-10% damage, +15% to hit, indestructible
	effect = {
		str        = 3,
		tohit      = 15
	},
	OnApply = function( item )
		item.flags[ifIndest]	= true
		item.dmgmodprc = math.random(4,10)
	end
}

register_unique "the_celestial_star"
{
	name = "The Celestial Star",
	base = {"flail"},
	level = 2,
	price = 7810,
	-- AC -8, +10 damage, +20% light radius, no strength requirement
	effect = {
		ac			= -8,
		dmgmod		= 10,
		lightmod	= 20,
		strreq		= 0
	}
}

register_unique "baranars_star"
{
	name = "Baranar's Star",
	base = {"morning_star"},
	level = 5,
	price = 6850,
	-- -4 dexterity, +4 vitality, +12% to hit, +80% damage, quick attack, altered durability (60)
	effect = {
		dex			= -4,
		vit			= 4,
		tohit		= 12,
		dmgmodprc	= 80,
		spdatk		= SPD_QUICK,
		durmax		= 60
	}
}

register_unique "gnarled_root"
{
	name = "Gnarled Root",
	base = { "club", "spiked_club" },
	level = 9,
	price = 9820,
	-- AC -10, +5 magic, +10 dexterity, +20% to hit, +10% resist all, +300% damage
	effect = {
		ac           = -10,
		mag          = 5,
		dex          = 10,
		tohit        = 20,
		resfire      = 10,
		reslightning = 10,
		resmagic     = 10,
		dmgmodprc    = 300
	}
}

register_unique "the_cranium_basher"
{
	name = "The Cranium Basher",
	base = {"maul"},
	level = 12,
	price = 36500,
	-- +15 strength, -150 mana, +20 damage, +5% resist all, indestructible
	effect = {
		str          = 15,
		mpmod        = -150,
		dmgmod       = 20,
		resfire      = 5,
		reslightning = 5,
		resmagic     = 5
	},
	OnApply = function( item )
		item.flags[ifIndest]	= true
	end
}

register_unique "thunderclap"
{
	name = "Thunderclap",
	base = {"war_hammer"},
	level = 13,
	price = 30000,
	-- +20 strength, +30% resist lightning, charged bolt (3-6 damage), +20% light radius, indestructible
	effect = {
		--TODO: cast charged bolt instead of direct lightning damage
		str				= 20,
		reslightning	= 30,
		dmglightningmin = 3,
		dmglightningmax = 6,
		lightmod		= 20
	},
	OnApply = function( item )
		item.flags[ifIndest]	= true
	end
}

register_unique "schaefers_hammer"
{
	name = "Schaefer's Hammer",
	base = {"war_hammer"},
	level = 16,
	price = 56125,
	-- +50 life, +75% resist lightning, +30% to hit, -100% damage, 1-50 lightning damage, +10% light radius
	effect = {
		hpmod           = 50,
		reslightning    = 75,
		tohit           = 30,
		dmgmodprc       = -100,
		dmglightningmin = 1,
		dmglightningmax = 50,
		lightmod        = 10
	}
}

register_unique "dreamflange"
{
	name = "Dreamflange",
	base = {"mace"},
	level = 26,
	price = 26450,
	-- +30 magic, +50 mana, +50% resist magic, +1 spell levels, +20% light radius
	effect = {
		mag        = 30,
		mpmod      = 50,
		resmagic   = 50,
		spelllevel = 1,
		lightmod   = 20
	}
}

-- swords ----------------------------------------------

register_unique "black_razor"
{
	name	= "Black Razor",
	base	= {"dagger"},
	level	= 1,
	price	= 2000,
	-- +2 vitality, +150% damage, altered durability (5)
	effect = {
		vit			= 2,
		dmgmodprc	= 150,
		durmax		= 5
	}
}

register_unique "gonnagals_dirk"
{
	name	= "Gonnagal's Dirk",
	base	= {"dagger"},
	level	= 1,
	price	= 7040,
	-- -5 dexterity, +4 damage, +25% resist fire, fast attack
	effect = {
		dex		= -5,
		dmgmod	= 4,
		resfire	= 25,
		spdhit	= SPD_FAST
	}
}

register_unique "the_defender"
{
	name	= "The Defender",
	base	= {"sabre"},
	level	= 1,
	price	= 2000,
	-- AC 5, +5 vitality, -5% to hit
	effect	= {
		ac		= 5,
		vit		= 5,
		tohit	= -5
	}
}

register_unique "gryphons_claw"
{
	name = "Gryphons Claw",
	base = {"falchion"},
	price = 1000,
	level = 1,
	-- -2 magic, -5 dexterity, +100% damage"
	effect = {
		mag			= -2,
		dex			= -5,
		dmgmodprc	= 100
	}
}

register_unique "gibbous_moon"
{
	name = "Gibbous Moon",
	base = {"broad_sword"},
	level = 2,
	price = 6660,
	-- +2 all attributes, +15 mana, +25% damage, -30% light radius
	effect = {
		str			= 2,
		mag			= 2,
		dex			= 2,
		vit			= 2,
		mpmod		= 15,
		dmgmodprc	= 25,
		lightmod	= -30
	}
}

register_unique "the_executioners_blade"
{
	name = "The Executioner's Blade",
	base = {"falchion"},
	level = 3,
	price = 7080,
	-- -10 life, +150% damage, -10% light radius, high durability (60)
	effect = {
		hpmod		= -10,
		dmgmodprc	= 150,
		lightmod	= -10,
		durmax		= 60
	}
}


register_unique "ice_shank"
{
	name = "Ice Shank",
	base = {"long_sword"},
	level = 3,
	price = 5250,
	-- +5-10 strength, +40% resist fire, altered durability (15)
	effect = {
		resfire		= 40,
		durmax		= 15
	},

	OnApply = function( item )
		item.str = math.random(5,10)
	end
}

register_unique "the_bonesaw"
{
	name = "The Bonesaw",
	base = {"claymore"},
	level = 6,
	price = 4400,
	-- +10 strength, -5 dexterity, -5 magic, +10 life, -10 mana, +10 damage
	effect = {
		str        = 10,
		dex        = -5,
		mag        = -5,
		hpmod      = 10,
		mpmod      = -10,
		dmgmod     = 10,
	}
}

register_unique "shadowhawk"
{
	name = "Shadowhawk",
	base = {"broad_sword"},
	level = 8,
	price = 13750,
	-- +15% to hit, +5% resist all, 5% steal life, -20% light radius
	effect = {
		tohit			= 15,
		resfire			= 15,
		reslightning	= 15,
		resmagic		= 15,
		lightmod		= -20,
		lifestealmin	= 50,
		lifestealmax	= 50
	}
}

register_unique "wizardspike"
{
	name = "Wizardspike",
	base = {"dagger"},
	level = 11,
	price = 12920,
	-- +15 magic, +35 mana, +25% to hit, +15% resist all
	effect = {
		mag          = 15,
		mpmod        = 35,
		tohit        = 25,
		resfire      = 15,
		reslightning = 15,
		resmagic     = 15
	}
}


register_unique "lightsabre"
{
	name = "Lightsabre",
	base = {"sabre"},
	level = 13,
	price = 19150,
	-- +20% to hit, +50% resist lightning, 1-10 lightning damage, +20% light radius
	effect = {
		tohit           = 20,
		reslightning    = 50,
		dmglightningmin = 1,
		dmglightningmax = 10,
		lightmod        = 20
	}
}


register_unique "the_falcons_talon"
{
	name = "The Falcon's Talon",
	base = {"scimitar"},
	level = 15,
	price = 7867,
	-- +10 dexterity, +20% to hit, -33% damage, fastest attack
	effect = {
		dex        = 10,
		tohit      = 20,
		dmgmodprc  = -33,
		spdatk     = SPD_FASTEST,
	}
}

register_unique "inferno"
{
	name = "Inferno",
	base = {"long_sword"},
	level = 17,
	price = 34600,
	-- +20 mana, +75% resist fire, 2-12 fire damage, +30% light radius
	effect = {
		mpmod      = 20,
		resfire    = 75,
		dmgfiremin = 2,
		dmgfiremax = 13,
		lightmod   = 30
	}
}

register_unique "diamondedge"
{
	name = "Diamondedge",
	base = {"long_sword"},
	level = 17,
	price = 42000,
	-- AC 10, +50% resist lightning, +50% to hit, +100% damage, altered durability (10)
	effect = {
		ac				= 10,
		reslightning	= 50,
		tohit			= 50,
		dmgmodprc		= 100,
		durmax			= 10,
	}
}

register_unique "doombringer"
{
	name = "Doombringer",
	base = {"bastard_sword"},
	level = 19,
	price = 18250,
	-- -5 all attributes, -25 life, +25% to hit, +250% damage, -20% light radius
	effect = {
		str        = -5,
		mag        = -5,
		dex        = -5,
		vit        = -5,
		hpmod      = -25,
		tohit      = 25,
		dmgmodprc  = 250,
		lightmod   = -20,
	}
}

register_unique "shirotachi"
{
	name = "Shirotachi",
	base = {"great_sword"},
	level = 21,
	price = 36000,
	-- +6 lightning damage, penetrates target's armor (half AC), fastest attack, one-handed
	effect = {
		dmglightningmin = 6,
		dmglightningmax = 6,
		spdatk     		= SPD_FASTEST,
	},
	OnApply = function( item )
		-- TODO: add armor penetration
		item.flags[ifTwoHanded] = false
	end
}

register_unique "the_grizzly"
{
	name = "The Grizzly",
	base = {"two_handed_sword"},
	level = 23,
	price = 50000,
	-- +20 strength, -5 vitality, +200% damage, knocks target back, high durability (150)
	effect = {
		str			= 20,
		vit			= -5,
		dmgmodprc	= 200,
		durmax		= 150
	},
	OnApply = function ( item )
		item.flags[ifKnockback] = true
	end
}

register_unique "eater_of_souls"
{
	name = "Eater of Souls",
	base = {"two_handed_sword"},
	level = 23,
	price = 42000,
	-- +50 life, 5% steal life, 5% steal mana, causes continuous damage when worn, indestructible
	effect = {
		hpmod	= 50,
		manastealmin	= 50,
		manastealmax	= 50
	},
	OnApply = function ( item )
		--TODO: make it drain wearer's hp each turn
		item.flags[ifIndest] = true
	end
}

register_unique "the_grandfather"
{
	name = "The Grandfather",
	base = {"great_sword"},
	level = 27,
	price = 119800,
	-- +5 all attributes, +20 life, +20% to hit, +70% damage, only requires one hand
	effect = {
		str        = 5,
		mag        = 5,
		dex        = 5,
		vit        = 5,
		hpmod      = 20,
		tohit      = 20,
		dmgmodprc  = 70
	},
	OnApply = function( item )
		-- TODO: add armor penetration
		item.flags[ifTwoHanded] = false
	end
}

-- staves ----------------------------------------------

register_unique "staff_of_shadows"
{
	name = "Staff of Shadows",
	base = {"long_staff"},
	level = 2,
	price = 1250,
	-- -10 magic +10% to hit, +60% damage, -20% light radius, quick attack
	effect = {
		mag        = -10,
		tohit      = 10,
		dmgmodprc  = 60,
		lightmod   = -20,
		spdatk     = SPD_QUICK
	}
}

register_unique "immolator"
{
	name = "Immolator",
	base = {"long_staff"},
	level = 4,
	price = 3900,
	-- +10 mana, -5 vitality, +20% resist fire, 4 fire damage
	effect = {
		mpmod      = 10,
		vit        = -5,
		resfire    = 20,
		dmgfiremin = 4,
		dmgfiremax = 4
	}
}

register_unique "gleamsong"
{
	name = "Gleamsong",
	base = {"short_staff"},
	level = 8,
	price = 6520,
	-- +25 mana, -3 strength, -3 vitality, 76 Phasing charges
	effect = {
		mpmod      = 25,
		str        = -3,
		vit        = -3,
	},
	OnApply = function ( item )
		item.spell      = spells["phasing"].nid
		item.charges    = 10
		item.chargesmax = 76
	end
}

register_unique "storm_spire"
{
	name = "Storm Spire",
	base = {"war_staff"},
	level = 8,
	price = 22500,
	-- +10 strength, -10 to magic, +50% resist lightning, 2-8 lightning damage
	effect = {
		str             = 10,
		mag             = -10,
		reslightning    = 50,
		dmglightningmin = 2,
		dmglightningmax = 8
	}
}

register_unique "thundercall"
{
	name = "Thundercall",
	base = {"composite_staff"},
	level = 14,
	price = 22250,
	-- +35% to hit, 1-10 lightning damage, +30% resist lightning, +20% light radius, 76 Lightning charges
	effect = {
		tohit           = 35,
		dmglightningmin = 1,
		dmglightningmax = 10,
		reslightning    = 30,
		lightmod        = 20
	},
	OnApply = function ( item )
		item.spell      = spells["lightning"].nid
		item.charges    = 3
		item.chargesmax = 76
	end
}

register_unique "the_protector"
{
	name = "The Protector",
	base = {"short_staff"},
	level = 16,
	price = 17240,
	-- AC 40, +5 vitality, -5 damage from enemies, 1-3 damage to attacker, 86 Healing charges
	-- TODO: damage to attacker (thorns)
	effect = {
		ac			= 40,
		vit			= 5,
		dmgtaken	= -5,
	},
	OnApply = function ( item )
		item.spell      = spells["healing"].nid
		item.charges    = 2
		item.chargesmax = 86
	end
}

register_unique "najs_puzzler"
{
	name = "Naj's Puzzler",
	base = {"long_staff"},
	level = 18,
	price = 34000,
	-- +20 magic, +10 dexterity, +20% resist all, -25 life, 57 Teleport charges
	effect = {
		mag          = 20,
		dex          = 10,
		resfire      = 20,
		reslightning = 20,
		resmagic     = 20,
		hpmod        = -25
	},
	OnApply = function ( item )
		item.spell      = spells["teleport"].nid
		item.charges    = 23
		item.chargesmax = 57
	end
}

register_unique "mindcry"
{
	name = "Mindcry",
	base = {"quarter_staff"},
	level = 20,
	price = 41500,
	-- +15 magic, +15% resist all, +1 spell level , 69 Guardian charges
	effect = {
		mag          = 15,
		resfire      = 15,
		reslightning = 15,
		resmagic     = 15,
		spelllevel   = 1,
	},
	OnApply = function ( item )
		item.spell      = spells["guardian"].nid
		item.charges    = 13
		item.chargesmax = 69
	end
}

register_unique "rod_of_onan"
{
	name = "Rod of Onan",
	base = {"war_staff"},
	level = 22,
	price = 44167,
	-- +5 all attributes, +100% damage, 50 Golem charges
	effect = {
		str        = 5,
		mag        = 5,
		dex        = 5,
		vit        = 5,
		dmgmodprc  = 100
	},
	OnApply = function ( item )
		item.spell      = spells["golem"].nid
		item.charges    = 21
		item.chargesmax = 50
	end
}

--------------------------------------------------------
--                     ARMOR
--------------------------------------------------------

register_unique "the_rainbow_cloak"
{
	name = "The Rainbow Cloak",
	base = {"cloak"},
	level = 2,
	price = 4900,
	-- AC 10, +1 all attributes, +5 life, +10% resist all, high durability (27)
	effect = {
		ac				= 10,
		str				= 1,
		mag				= 1,
		dex				= 1,
		vit				= 1,
		hpmod			= 5,
		resfire			= 10,
		reslightning	= 10,
		resmagic		= 10,
		durmax			= 27
	}
}

register_unique "torn_flesh_of_souls"
{
	name = "Torn Flesh of Souls",
	base = {"rags"},
	level = 2,
	price = 4825,
	-- AC 8, +10 vitality, -1 damage from enemies, indestructible
	effect = {
		ac			= 8,
		vit        	= 10,
		dmgtaken	= -1
	},
	OnApply = function ( item )
		item.flags[ifIndest] = true
	end
}

register_unique "leather_of_aut"
{
	name = "Leather of Aut",
	base = {"leather_armor"},
	level = 4,
	price = 10550,
	-- AC 15, +5 strength, -5 magic, +5 dexterity, indestructible
	effect = {
		str        = 5,
		mag        = -5,
		dex        = 5
	},
	OnApply = function ( item )
		item.ac      = 15
		item.flags[ifIndest] = true
	end
}

register_unique "wisdoms_wrap"
{
	name = "Wisdom's Wrap",
	base = {"robe"},
	level = 5,
	price = 6200,
	-- AC 15, +5 magic, +10 mana, +25% resist lightning, -1 damage from enemies
	effect = {
		mag          = 5,
		mpmod        = 10,
		reslightning = 25,
		dmgtaken     = -1
	},
	OnApply = function ( item )
		item.ac      = 15
	end
}

register_unique "the_gladiators_bane"
{
	name = "The Gladiator's Bane",
	base = {"studded_armor"},
	level = 6,
	price = 3450,
	-- AC 25, -3 all attributes, -2 damage from enemies, high durability (135)
	effect = {
		str        = -3,
		mag        = -3,
		dex        = -3,
		vit        = -3,
		dmgtaken   = -2,
		durmax     = 90
	},
	OnApply = function ( item )
		item.ac      = 25
	end
}

register_unique "sparking_mail"
{
	name = "Sparking Mail",
	base = {"chain_mail"},
	level = 9,
	price = 15750,
	-- AC 30, 1-10 lightning damage
	effect = {
		dmglightningmin = 1,
		dmglightningmax = 10
	},
	OnApply = function ( item )
		item.ac      = 30
	end
}

register_unique "scavenger_carapace"
{
	name = "Scavenger Carapace",
	base = {"breast_plate"},
	level = 13,
	price = 14000,
	-- AC -6 - -10, +5 dexterity, +40% resist lightning, -15 damage from enemies
	effect = {
		dex          = 5,
		reslightning = 40,
		dmgtaken     = -15
	},
	OnApply = function ( item )
		item.ac      = -math.random(6,10)
	end
}
--[[
register_unique "bone_chain_armor"
{
	name = "Bone Chain Armor",
	base = {"chain_mail"},
	level = 13,
	price = 36000,
	-- AC 40, AC 60 vs. Undead
	--TODO: 150% AC vs Undead
	OnApply = function ( item )
		item.ac      = 40
	end
}
]]
register_unique "nightscape"
{
	name = "Nightscape",
	base = {"cape"},
	level = 16,
	price = 11600,
	-- AC 15, +3 dexterity, +20% resist all, faster hit recovery, -40% light radius
	effect = {
		ac			 = 15,
		dex          = 3,
		resfire      = 20,
		reslightning = 20,
		resmagic     = 20,
		spdhit       = SPD_FASTER,
		lightmod     = -40
	}
}

register_unique "najs_light_plate"
{
	name = "Naj's Light Plate",
	base = {"plate_mail"},
	level = 19,
	price = 78700,
	-- +5 magic, +20 mana, +20% resist all, +1 spell level, no strength requirements
	effect = {
		mag         = 5,
		mpmod       = 20,
		resfire     = 20,
		reslightning= 20,
		resmagic    = 20,
		spelllevel  = 1,
		strreq		= 0
	}
}

register_unique "demonspike_coat"
{
	name = "Demonspike Coat",
	base = {"full_plate_mail"},
	level = 25,
	price = 251175,
	-- AC 100, +10 strength, +50% resist fire, -6 damage from enemies, indestructible
	effect = {
		ac			= 100,
		str			= 10,
		resfire		= 50,
		dmgtaken	= -6,
	},
	OnApply = function ( item )
		item.flags[ifIndest] = true
	end
}
--[[
register_unique "armor_of_gloom"
{
	name = "Armor of Gloom",
	base = {"full_plate_mail"},
	level = 25,
	price = 200000,
	-- AC 225, all resistances=0%, -20% light radius, no strength requirements
	effect = {
		-- TODO: disable resistances
		ac			= 225,
		lightmod	= -20
	}
}

register_unique "demon_plate_armor"
{
	name = "Demon Plate Armor",
	base = {"full_plate_mail"},
	level = 25,
	price = 80000,
	-- AC 80, AC 120 vs. Demons
	effect = {
		-- TODO: 150% AC vs demons
		ac	= 80
	}
}
]]

-- helms -----------------------------------------------

register_unique "helm_of_sprits"
{
	name = "Helm of Sprits",
	base = {"helm"},
	level = 1,
	price = 7525,
	-- 5% steal life
	effect = {
		lifestealmin = 50,
		lifestealmax = 50
	}
}

register_unique "thinking_cap"
{
	name = "Thinking Cap",
	base = {"skull_cap"},
	level = 6,
	price = 2020,
	-- +30 mana, +20% resist all, +2 spell levels, altered durability (1)
	effect = {
		mpmod        = 30,
		resfire      = 20,
		reslightning = 20,
		resmagic     = 20,
		spelllevel   = 2,
		durmax		 = 1
	}
}

register_unique "overlords_helm"
{
	name = "Overlord's Helm",
	base = {"helm"},
	level = 7,
	price = 12500,
	-- +20 strength, -20 magic, +15 dexterity, +5 vitality, altered durability (15)
	effect = {
		str        = 20,
		mag        = -20,
		dex        = 15,
		vit        = 5,
		durmax     = 15
	}
}

register_unique "fools_crest"
{
	name = "Fool's Crest",
	base = {"helm"},
	level = 12,
	price = 10150,
	-- -4 all attributes, +100 life, +1- +6 damage from enemies, 1-3 damage to attacker
	-- TODO: damage to attackers
	effect = {
		str        = -4,
		mag        = -4,
		dex        = -4,
		vit        = -4,
		hpmod      = 100,
	},
	OnApply = function( item )
		item.dmgtaken = math.random(1,6)
	end
}

register_unique "gotterdamerung"
{
	name = "Gotterdamerung",
	base = {"great_helm"},
	level = 21,
	price = 54900,
	-- AC 60, +20 all attributes, all resistances=0%, -4 damage from enemies, -40% light radius
	-- TODO: disable all resistances
	effect = {
		ac			= 60,
		str			= 20,
		mag			= 20,
		dex			= 20,
		vit			= 20,
		dmgtaken	= -4,
		lightmod	= -40
	}
}

register_unique "royal_circlet"
{
	name = "Royal Circlet",
	base = {"crown"},
	level = 27,
	price = 24875,
	-- AC 40, +10 all attributes, +40 mana, +10% light radius
	effect = {
		str        = 10,
		mag        = 10,
		dex        = 10,
		vit        = 10,
		mpmod      = 40,
		lightmod   = 10
	}
}

-- shields ---------------------------------------------

register_unique "blackoak_shield"
{
	name = "Blackoak Shield",
	base = {"small_shield"},
	level = 4,
	price = 5725,
	-- AC 18, +10 dexterity, -10 vitality, -10% light radius, high durability (60)
	effect = {
		ac			= 18,
		dex			= 10,
		vit			= -10,
		lightmod	= -10,
		durmax		= 60
	}
}

register_unique "the_deflector"
{
	name = "The Deflector",
	base = {"buckler"},
	level = 1,
	price = 1500,
	-- AC 7, +10% resist all, -20% damage, -5% to hit
	effect = {
		ac			 = 7,
		resfire      = 10,
		reslightning = 10,
		resmagic     = 10,
		dmgmodprc    = -20,
		tohit        = -5
	}
}

register_unique "dragons_breach"
{
	name = "Dragon's Breach",
	base = {"kite_shield"},
	level = 2,
	price = 19200,
	-- AC 20, +5 strength, -5 magic, +25% resist fire, indestructible
	effect = {
		ac			= 20,
		str         = 5,
		mag         = -5,
		resfire     = 25
	},
	OnApply = function ( item )
		item.flags[ifIndest] = true
	end
}

register_unique "holy_defender"
{
	name = "Holy Defender",
	base = {"large_shield"},
	level = 10,
	price = 13800,
	-- AC 15, -2 damage from enemies, +20% resist fire, fast block, high durability (96)
	effect = {
		ac			= 15,
		dmgtaken    = -2,
		resfire     = 20,
		spdblk      = SPD_FAST,
		durmax      = 96
	}
}

register_unique "split_skull_shield"
{
	name = "Split Skull Shield",
	base = {"buckler"},
	level = 1,
	price = 2025,
	-- AC 10, +10 life, +2 strength, -10% light radius, altered durability (15)
	effect = {
		ac		 = 10,
		hpmod    = 10,
		str      = 2,
		lightmod = -10,
		durmax   = 15
	}
}

register_unique "stormshield"
{
	name = "Stormshield",
	base = { "gothic_shield", "tower_shield" },
	level = 24,
	price = 49000,
	-- AC 40, +4 damage from enemies, +10 strength, fast block, indestructible
	effect = {
		ac			= 40,
		dmgtaken    = 4,
		str         = 10,
		spdblk      = SPD_FAST
	},
	OnApply = function ( item )
		item.flags[ifIndest] = true
	end
}

--------------------------------------------------------
--                    JEWELRY
--------------------------------------------------------

-- Amulets ---------------------------------------------

--[[
register_unique "acolytes_amulet"
{
	name = "Acolytes Amulet",
	base = {"amulet"},
	level = 10,
	price = 10000,
	-- 50% of base mana moved to life
	effect = {

	}
}
]]
register_unique "amulet_of_warding"
{
	name = "Amulet of Warding",
	base = {"amulet8", "amulet16"},
	level = 12,
	price = 30000,
	-- -100 life, +40% resist all
	effect = {
		hpmod			= -100,
		resfire			= 40,
		reslightning	= 40,
		resmagic	 	= 40
	}
}


-- Rings -----------------------------------------------

register_unique "bramble"
{
	name = "Bramble",
	base = {"ring5"},
	level = 1,
	price = 1000,
	-- -2 all attributes, +10 mana, +3 damage
	effect = {
		str    = -2,
		mag    = -2,
		dex    = -2,
		vit    = -2,
		mpmod  = 10,
		dmgmod = 3
	}
}

register_unique "ring_of_regha"
{
	name = "Ring of Regha",
	base = {"ring5"},
	level = 1,
	price = 4175,
	-- -3 strength, +10 magic, -3 dexterity, +10% resist magic, +10% light radius
	effect = {
		str      = -3,
		mag      = 10,
		dex      = -3,
		resmagic = 10,
		lightmod = 10
	}
}

register_unique "the_bleeder"
{
	name = "The Bleeder",
	base = {"ring5"},
	level = 2,
	price = 8500,
	-- +30 mana, -10 life, +20% resist magic
	effect = {
		mpmod    = 30,
		hpmod    = -10,
		resmagic = 20
	}
}
--[[
register_unique "constricting_ring"
{
	name = "Constricting Ring",
	base = {"ring5"},
	level = 5,
	price = 62000,
	-- +75% resist all, causes continuous damage when worn (1.25 life/sec2)
	effect = {

	}
}

register_unique "giants_knuckle"
{
	name = "Giant's Knuckle",
	base = {"ring5","ring10"},
	level = 8,
	price = 8000,
	-- +60 strength, -30 dexterity
	effect = {

	}
}

register_unique "kariks_ring"
{
	name = "Karik's Ring",
	base = {"ring5","ring10"},
	level = 8,
	price = 8000,
	-- -30 magic, +60 vitality
	effect = {

	}
}

register_unique "mercurial_ring"
{
	name = "Mercurial Ring",
	base = {"ring5","ring10"},
	level = 8,
	price = 8000,
	-- -30 strength, +60 dexterity
	effect = {

	}
}

register_unique "ring_of_magma"
{
	name = "Ring of Magma",
	base = {"ring5","ring10"},
	level = 8,
	price = 8000,
	-- -30% resist magic, +60% resist fire, -30% resist lightning
	effect = {

	}
}

register_unique "ring_of_the_mystics"
{
	name = "Ring of the Mystics",
	base = {"ring5","ring10"},
	level = 8,
	price = 8000,
	-- +60% resist magic, -30% resist fire, -30% resist lightning
	effect = {

	}
}

register_unique "ring_of_thunder"
{
	name = "Ring of Thunder",
	base = {"ring5","ring10"},
	level = 8,
	price = 8000,
	-- -30% resist magic, -30% resist fire, +60% resist lightning
	effect = {

	}
}

register_unique "xorines_ring"
{
	name = "Xorine's Ring",
	base = {"ring5","ring10"},
	level = 8,
	price = 8000,
	-- -30 strength, +60 magic
	effect = {

	}
}

register_unique "gladiators_ring"
{
	name = "Gladiators Ring",
	base = {"ring10"},
	level = 10,
	price = 10000,
	-- 40% of base life moved to mana
	effect = {

	}
}

register_unique "ring_of_engagement"
{
	name = "Ring of Engagement",
	base = {"ring10","ring15"},
	level = 11,
	price = 12476,
	-- AC 5, -1 or -2 damage from enemies, 1-3 damage to attacker, damages target's armor
	-- Has the effect equivalent to of Puncturing, that is, adds 4-12 to To Hit in Diablo.
	-- In Hellfire it reduces the AC by 87.5% (+12.5% if Barbarian making any AC of a monster equal 0)
	-- and is thus better than any of the suffixes with the same property.
	effect = {

	}
}
]]
