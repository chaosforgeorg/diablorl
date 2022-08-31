--== POTIONS ===========================--

register_item ( "potion_healing", "potion" )
{
	name  = "potion of healing",
	color = RED,
	price = 50,

	OnUse = function(self,target)
		stats.inc("poitions_drank")
		target:msg("You feel better.")
		local temp = target.hpmax / 4
		target.hp = math.min(target.hp + math.random( temp, 3* temp ),target.hpmax)
	end,
}

register_item ( "potion_mana", "potion" )
{
	name  = "potion of mana",
	color = BLUE,
	price = 50,
	level = 1,

	OnUse = function(self,target)
		stats.inc("poitions_drank")
		target:msg("You feel megical energies restoring.")
		local temp = target.mpmax / 4
		target.mp = math.min(target.mp + math.random( temp, 3* temp ),target.mpmax)
	end,
}

register_item ( "potion_full_healing", "potion" )
{
	name  = "potion of full healing",
	color = LIGHTRED,
	price = 150,
	level = 1,

	OnUse = function(self,target)
		stats.inc("poitions_drank")
		target:msg("You feel like new.")
		target.hp = target.hpmax
	end,
}

register_item ( "potion_full_mana", "potion" )
{
	name  = "potion of full mana",
	color = LIGHTBLUE,
	price = 150,
	level = 1,

	OnUse = function(self,target)
		stats.inc("poitions_drank")
		target:msg("You feel magically fully restored.")
		target.mp = target.mpmax
	end,
}

register_item ( "potion_rejuvenation", "potion" )
{
	name  = "potion of rejuvenation",
	color = MAGENTA,
	price = 165,
	level = 3,

	OnUse = function(self,target)
		stats.inc("poitions_drank")
		target:msg("You feel better.")
		local temp = target.hpmax / 4
		target.hp = math.min(target.hp + math.random( temp, 3* temp ),target.hpmax)
		temp = target.mpmax / 4
		target.mp = math.min(target.mp + math.random( temp, 3* temp ),target.mpmax)
	end,
}

register_item ( "potion_full_rejuvenation", "potion" )
{
	name  = "potion of full rejuvenation",
	color = LIGHTMAGENTA,
	price = 375,
	level = 7,

	OnUse = function(self,target)
		stats.inc("poitions_drank")
		target:msg("You feel like new.")
		target.hp = target.hpmax
		target.mp = target.mpmax
	end,
}

--== BOOKS =============================--

register_item ( "book2", "book" )
{
	level = 2,
}

register_item ( "book8", "book" )
{
	level = 8,
}

register_item ( "book14", "book" )
{
	level = 14,
}

register_item ( "book20", "book" )
{
	level = 20,
}
