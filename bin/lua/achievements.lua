core.register_blueprint "achievement"
{
	id          = { true,  core.TSTRING },
	name        = { true,  core.TSTRING },
	score       = { false, core.TNUMBER, 0 },
	message     = { true,  core.TSTRING },
	check       = { false, core.TFUNC },
}


register_achievement "ironman"
{
	name    = "ironman",
	score   = 0.7,
	message = "was made of iron.",

	check   = function( victory )
		return victory and stats.enter_town < 2 and stats.stairs_up > 0
	end
}

register_achievement "steelman"
{
	name    = "steelman",
	score   = 1.0,
	message = "was made of steel.",

	check   = function( victory )
		return victory and stats.stairs_up == 0
	end
}

register_achievement "titan"
{
	name    = "titan",
	score   = 0.1,
	message = "was a titan.",

	check   = function( victory )
		return victory and player.str > player.vit + player.dex + player.vit
	end
}

register_achievement "quicksilver"
{
	name    = "quicksilver",
	score   = 0.1,
	message = "was quicksilver.",

	check   = function( victory )
		return victory and player.dex >= player.str + player.mag + player.vit
	end
}

register_achievement "sage"
{
	name    = "sage",
	score   = 0.1,
	message = "was a sage.",

	check   = function( victory )
		return victory and player.mag >= player.str + player.dex + player.vit
	end
}

register_achievement "tank"
{
	name    = "tank",
	score   = 0.1,
	message = "was a tank.",

	check   = function( victory )
		return victory and player.vit >= player.str + player.dex + player.mag
	end
}

register_achievement "pointless"
{
	name    = "pointless",
	score   = 2.0,
	message = "was pointless.",

	check   = function( victory )
		return victory and stats.points_used == 0
	end
}

register_achievement "illiterate"
{
	name    = "illiterate",
	score   = 0.5,
	message = "was illiterate.",

	check   = function( victory )
		return victory and stats.books_used == 0 and stats.scrolls_used == 0
	end
}

register_achievement "dry_throat"
{
	name    = "dry throat",
	score   = 2.0,
	message = "keeped throat dry.",

	check   = function( victory )
		return victory and stats.potions_used == 0
	end
}

register_achievement "sociopath"
{
	name    = "sociopath",
	message = "was a socipath.",

	check   = function( victory )
		return stats.talk_count == 0 
	end
}

register_achievement "believer"
{
	name    = "believer",
	message = "believed in a secret cow level.",

	check   = function( victory )
		return stats.cow_talk >= 50
	end
}

register_achievement "hypohondriac"
{
	name    = "hypohondriac",
	message = "was a hypohondriac.",

	check   = function( victory )
		return stats.free_healing >= 10
	end
}
