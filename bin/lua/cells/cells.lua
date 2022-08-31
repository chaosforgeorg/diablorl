core.register_blueprint "cell"
core.register_blueprint "cell"
{
	id           = { true,  core.TSTRING },
	name         = { true,  core.TSTRING },
	color        = { false, core.TNUMBER, LIGHTGRAY },
	flags        = { false, core.TFLAGS, {} },
	pic          = { true,  core.TSTRING },
	piclow       = { false, core.TSTRING },
	cost         = { false, core.TNUMBER, 1.0 },

	OnStep       = { false, core.TFUNC },
	OnAct        = { false, core.TFUNC },
	OnTravelName = { false, core.TFUNC },
}

core.register_blueprint( "stairs", "cell" )
{
	flags        = { false, core.TFLAGS, { cfBlockChange, cfBlockMove, cfTravelPoint } },
	color        = { false, core.TNUMBER, YELLOW },
	OnAct        = { true,  core.TFUNC },
	OnTravelName = { true,  core.TFUNC },
}

core.register_blueprint( "solid", "cell" )
{
	pic          = { false, core.TSTRING, "#" },
	flags        = { false, core.TFLAGS, { cfBlockMove, cfBlockVision, cfBlockMissile, cfBlockChange } },
	color        = { false, core.TNUMBER, ColorWall },
}

-- bones prototype only used to create implicit bones cells in npc_monster.lua
core.register_blueprint( "bones", "cell" )
{
	flags   = { false, core.TFLAGS, { cfBoneCorpse } },
	name    = "bones",
	pic     = "%",
	color   = LIGHTGRAY,
	raiseto = { true, core.TIDIN("npcs") }
}

core.register_blueprint( "chest", "cell" )
{
	flags   = { false, core.TFLAGS, { cfBlockMove, cfBlockChange } },
	pic     = "þ",
	piclow  = "?",
}

register_cell "floor"
{
	name  = "floor",
	pic   = ".",
	color = ColorFloor,
}

register_cell "floor_nospawn"
{
	name  = "floor",
	pic   = ".",
	color = ColorFloor,
	flags = { cfNoSpawn },
}

register_cell "bloody_floor"
{
	name  = "bloody floor",
	pic   = ".",
	color = RED
}

register_cell "marker"
{
	name  = "marker",
	pic   = ".",
	color = LIGHTGRAY
}


register_cell "shimmering_portal"
{
	name  = "shimmering portal",
	flags = { cfBlockChange, cfBlockMove },
	pic   = "0",
	color = ColorPortal,

	OnAct = function(self)
		ui.msg_enter("You feel yanked in a direction that never existed!")
		if self.flags[lfTown] then
			player:exit( player.portallevel, "shimmering_portal" )
		else
			player:exit( "town", "shimmering_portal" )
		end
	end,
}

register_cell "decapitated_body"
{
  	name  = "decapitated body",
	flags = { cfBlockMove },
	pic   = "%",
	color = LIGHTRED,

	OnAct = function(self,c)
		ui.msg("You search the body.")
		--TODO: ui.play_sound('sfx/?')
		self:decapited_drop( c )
		self:set_cell( c, "bloody_corpse" )
	end,
}

register_cell "bloody_corpse"
{
	name  = "bloody corpse",
	flags = { cfBloodCorpse },
	pic   = "%",
	color = RED,
}

register_cell "corpse"
{
	name  = "corpse",
	flags = { cfBloodCorpse },
	pic   = "%",
	color = BROWN,
}

register_cell "bones"
{
	name  = "bones",
	flags = { cfBoneCorpse },
	pic   = "%",
	color = LIGHTGRAY,
}

register_cell "barrel_fragments"
{
	name = "barrel fragments",
	pic = ",",
	color = BROWN
}


register_cell "barrel"
{
	name  = "barrel",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "0",
	color = BROWN,

  	OnAct = function(self, c)
		if not( player.flags[nfAffected] ) then
			ui.msg("You destroy the barrel.")
		end
		if math.random(100) <= 20 then
			self:set_cell( c, "floor" )
			ui.msg("The barrel explodes.")
			ui.play_sound('sfx/items/barlfire.wav',c)
			self:explosion( c, RED, 1, 8, 16, 50, DAMAGE_FIRE)
			for e in c:around_coords() do
				if self:get_cell(e) == 'barrel' then
					player.flags[nfAffected] = true
					cells['barrel'].OnAct(self,e)
					self:set_cell(e,'floor')
					player.flags[nfAffected] = false
				end
			end
		else
			ui.play_sound('sfx/items/barrel.wav',c)
			self:set_cell( c, "barrel_fragments" )
			self:barrel_drop( c )
		end
  end,
}

register_cell "open_sarcophagus"
{
	name   = "open sarcophagus",
	flags  = { cfBlockMove, cfBlockChange },
	pic    = "°",
	piclow = "?",
	color  = DARKGRAY,
}

register_cell "sarcophagus"
{
	name   = "sarcophagus",
	flags  = { cfBlockMove, cfBlockChange },
	pic    = "°",
	piclow = "?",
	color  = LIGHTGRAY,

	OnAct = function(self,c)
		ui.msg("You open the sarcophagus.")
		ui.play_sound('sfx/items/sarc.wav',c)
		self:sarcophagus_drop( c )
		self:set_cell( c, "open_sarcophagus" )
	end,
}

register_cell( "open_chest", "chest" )
{
	name   = "open chest",
	color  = DARKGRAY,
}

register_cell( "small_chest", "chest" )
{
	name  = "small chest",
	color = BROWN,

	OnAct = function(self,c)
		self:chest_drop( c, 1 )
		self:set_cell( c, "open_chest" )
	end,
}

register_cell( "small_chest_magic", "chest" )
{
	name  = "small chest",
	color = BROWN,

	OnAct = function(self,c)
		self:chest_drop( c, 1, true)
		self:set_cell( c, "open_chest" )
	end
}

register_cell( "medium_chest", "chest" )
{
	name  = "chest",
	color = LIGHTGRAY,

	OnAct = function(self,c)
		self:chest_drop( c, 2 )
		self:set_cell( c, "open_chest" )
	end,
}

register_cell( "medium_chest_magic", "chest" )
{
	name  = "chest",
	color = LIGHTGRAY,

	OnAct = function(self,c)
		self:chest_drop( c, 2, true)
		self:set_cell( c, "open_chest" )
	end
}

register_cell( "large_chest", "chest" )
{
	name  = "large chest",
	color = WHITE,

	OnAct = function(self,c)
		self:chest_drop( c, 3 )
		self:set_cell( c, "open_chest" )
	end,
}

register_cell( "large_chest_magic", "chest" )
{
	name  = "large chest",
	color = WHITE,

	OnAct = function(self,c)
		self:chest_drop( c, 3, true)
		self:set_cell( c, "open_chest" )
	end
}

register_cell "crucified_skeleton"
{
	name   = "crucified skeleton",
	flags  = { cfBlockMove, cfBlockChange },
	pic    = "î",
	piclow = "?",
	color  = BROWN,

	OnAct = function(self,c)
		ui.msg("You destroy the crucified skeleton.")
		self:set_cell( c, "open_crucified_skeleton" )
	end,
}

register_cell "open_crucified_skeleton"
{
	name   = "destroyed crucified skeleton",
	flags  = { cfBlockMove, cfBlockChange },
	pic    = "þ",
	piclow = "?",
	color  = DARKGRAY,
}

register_cell "empty_rack"
{
	name  = "empty rack",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "&",
}

register_cell "weapon_rack"
{
	name  = "weapon rack",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "&",
	color = BROWN,

	OnAct = function(self,c)
		self:weapon_rack_drop( c )
		self:set_cell( c, "empty_rack" )
	end,
}

register_cell "armor_rack"
{
	name  = "armor rack",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "&",
	color = BROWN,

	OnAct = function(self,c)
		self:armor_rack_drop( c )
		self:set_cell( c, "empty_rack" )
	end,
}

register_cell "empty_bookshelf"
{
	name  = "empty bookshelf",
	color = DARKGRAY,
	pic   = '"',
	flags = { cfBlockMove, cfBlockChange },
}

register_cell "bookshelf"
{
	name  = "bookshelf",
	color = BROWN,
	pic   = '"',
	flags = { cfBlockMove, cfBlockChange },

	OnAct = function(self,c)
		ui.msg("You search the bookshelf.")
		self:bookcase_drop(c)
		self:set_cell( c, "empty_bookshelf" )
	end,
}

register_cell "open_book"
{
	name  = "open book",
	flags = { cfBlockMove, cfBlockChange },
	pic   = '"',
	color = DARKGRAY,
}

register_cell "library_book"
{
	name = "library book",
	flags = { cfBlockMove, cfBlockChange },
	pic   = '"',
	color = BROWN,

	OnAct = function(self,c)
		ui.msg("You open the book.")
		self:book_drop( c )
		self:set_cell( c, "open_book" )
	end,
}

register_cell "skeleton_tome"
{
	name  = "skeleton tome",
	flags = { cfBlockMove, cfBlockChange },
	pic   = '"',
	color = BROWN,

	OnAct = function(self,c)
		ui.msg("You open the tome.")
		self:book_drop( c )
		self:set_cell( c, "open_book" )
	end,
}

register_cell "grass"
{
	name = "grass",
	pic = ".",
	color = GREEN
}

register_cell( "stairs_up", "stairs" )
{
	name = "stairs up",
	pic = "<",

	OnTravelName = function(self)
		local target = levels[self.id].up
		return "Stairs to "..levels[target].name
	end,

	OnAct = function(self,c)
		stats.inc("stairs_up")
		local target = levels[self.id].up
		if levels[self.id].is_special then
			player:exit( target, "stairs_down_special")
		else
			player:exit( target, "stairs_down")
		end
	end
}

register_cell( "stairs_down", "stairs" )
{
	name = "stairs down",
	pic  = ">",

	OnTravelName = function(self)
		local target = levels[self.id].down
		return "Stairs to "..levels[target].name
	end,

	OnAct = function(self,c)
		stats.inc("stairs_down")
		local target = levels[self.id].down
		if levels[self.id].is_special then
			player:exit( target, "stairs_up_special")
		else
			player:exit( target, "stairs_up")
		end
	end
}

register_cell( "stairs_up_special", "stairs" )
{
	name  = "stairs up",
	pic   = "<",
	color = BLUE,

	OnTravelName = function(self)
		local target = levels[self.id].special
		return "Stairs to "..levels[target].name
	end,

	OnAct = function(self,c)
		stats.inc("stairs_up")
		player:exit( levels[self.id].special, "stairs_down")
	end
}

register_cell( "stairs_down_special", "stairs" )
{
	name  = "stairs down",
	pic   = ">",
	color = BLUE,

	OnTravelName = function(self)
		local target = levels[self.id].special
		return "Stairs to "..levels[target].name
	end,

	OnAct = function(self,c)
		stats.inc("stairs_down")
		player:exit( levels[self.id].special, "stairs_up")
	end
}


register_cell( "stairs_up_catacombs", "stairs" )
{
	name = "stairs up to town",
	pic = "<",
	color = WHITE,

	OnTravelName = function(self)
		return "Stairs to Town"
	end,

	OnAct = function(self,c)
		stats.inc("stairs_up")
		player:exit( "town", "stairs_down_catacombs")
	end
}

register_cell( "stairs_down_catacombs", "stairs" )
{
	name  = "stairs down to catacombs",
	pic   = ">",
	color = WHITE,

	OnTravelName = function(self)
		return "Stairs to Catacombs"
	end,

	OnAct = function(self,c)
		stats.inc("stairs_down")
		player:exit( "level5", "stairs_up_catacombs")
	end
}

register_cell( "stairs_up_caves", "stairs" )
{
	name = "stairs up to town",
	pic = "<",
	color = WHITE,

	OnTravelName = function(self)
		return "Stairs to Town"
	end,

	OnAct = function(self,c)
		stats.inc("stairs_up")
		local town = world.get_level( "town" )
		local c    = town:find_tile( "heavy_stones_caves" )
		if c then
			town:set_cell( c, "floor" )
		end
		player:exit( "town", "stairs_down_caves")
	end
}

register_cell( "stairs_down_caves", "stairs" )
{
	name  = "stairs down to the caves",
	pic   = ">",
	color = WHITE,

	OnTravelName = function(self)
		return "Stairs down to caves"
	end,

	OnAct = function(self,c)
		stats.inc("stairs_down")
		player:exit( "level9", "stairs_up_caves")
	end
}

register_cell( "stairs_up_hell", "stairs" )
{
	name = "stairs up to town",
	pic = "<",
	color = WHITE,

	OnTravelName = function(self)
		return "Stairs to Town"
	end,

	OnAct = function(self,c)
		stats.inc("stairs_up")
		local town = world.get_level( "town" )
		local c    = town:find_tile( "muddy_grass_hell" )
		if c then
			town:set_cell( c, "stairs_down_hell" )
		end
		player:exit( "town", "stairs_down_hell")
	end
}

register_cell( "stairs_down_hell", "stairs" )
{
	name  = "rift down to hell",
	pic   = ">",
	color = ColorLava,

	OnTravelName = function(self)
		return "Rift down to hell"
	end,

	OnAct = function(self,c)
		stats.inc("stairs_down")
		player:exit( "level13", "stairs_up_hell")
	end
}


register_cell "statue"
{
	name  = "statue",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "8",
	color = WHITE
}

register_cell( "vault", "solid" )
{
	name  = "vault",
	color = LIGHTGRAY
}

register_cell "river"
{
	name  = "river",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "=",
	color = BLUE
}

register_cell "poisoned_river"
{
	name  = "poisoned river",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "=",
	color = YELLOW
}

register_cell "wooden_bridge"
{
	name  = "wooden bridge",
	flags = { cfBlockChange },
	pic   = ":",
	color = BROWN
}

register_cell "town_wall"
{
	name  = "town wall",
  	flags = { cfBlockMove, cfBlockChange },
	pic   = "%",
	color = DARKGRAY
}

register_cell "fountain"
{
	name  = "fountain",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "=",
	color = BLUE
}

register_cell "poison_fountain"
{
	name  = "poison fountain",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "=",
	color = YELLOW,
}

register_cell "muddy_grass"
{
	name  = "muddy grass",
	pic   = ".",
	color = BROWN
}

register_cell "muddy_grass_hell"
{
	name  = "muddy grass",
	pic   = ".",
	color = BROWN
}

register_cell "path"
{
	name  = "path",
	pic   = ":",
	color = BROWN,
	cost  = 0.6,
}

register_cell "sand"
{
	name  = "sand",
	pic   = ".",
	color = YELLOW,
}

register_cell "town_square"
{
	name  = "town square",
	pic   = ".",
	color = BROWN,
	cost  = 0.6,
}

register_cell( "deep_grass", "solid" )
{
	name  = "deep grass",
	pic   = ".",
	color = GREEN,
}

register_cell "stones"
{
	name  = "stones",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "^",
	color = LIGHTGRAY,
}

register_cell( "heavy_stones", "solid" )
{
	name  = "heavy stones",
	pic   = "^",
	color = DARKGRAY,
}

register_cell( "heavy_stones_caves", "solid" )
{
	name  = "heavy stones",
	pic   = "^",
	color = DARKGRAY,
}

register_cell "tomb_stone"
{
	name = "tomb stone",
	flags = { cfBlockMove, cfBlockChange },
	pic = "\241",
	piclow="+",
	color = DARKGRAY,
}

register_cell "town_barrel"
{
	name  = "town barrel",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "0",
	color = DARKGRAY,
}

register_cell( "tree", "solid" )
{
	name  = "tree",
	pic   = "T",
	color = BROWN,
}

register_cell( "closed_door", "solid" )
{
	name  = "closed door",
	pic   = "+",
	color = BROWN,

	OnAct = function(self,c)
		ui.msg("You open the door.")
		ui.play_sound('sfx/items/dooropen.wav',c)
		self:set_cell( c, "open_door" )
	end,
}

register_cell( "closed_door_2", "solid" )
{
	name  = "closed door",
	pic   = "+",
	color = BROWN,

	OnAct = function(self,c)
		ui.msg("You open the door. Click.")
		ui.play_sound('sfx/items/dooropen.wav',c)
		self:set_cell( c, "open_blocked_door" )
	end,
}

register_cell( "closed_door_catacombs", "solid" )
{
	name  = "closed door",
	pic   = "+",
	color = BROWN,

	OnAct = function(self,c)
		if self:get_cell( player.position ) == "floor" then
			self:set_cell( c, "open_blocked_door" )
			ui.msg("You open the door. Click.")
			ui.play_sound('sfx/items/dooropen.wav',c)
		else
			ui.msg("@<\"Maybe it's locked from the inside.\"@>")
		end
	end,
}

register_cell( "locked_door", "solid" )
{
	name  = "locked door",
	pic   = "+",
	color = BROWN
}

register_cell "open_door"
{
	name  = "open door",
	flags = { cfBlockChange },
	pic   = "'",
	color = DARKGRAY,

	OnAct = function(self,c)
		ui.msg("You close the door.")
		ui.play_sound('sfx/items/doorclos.wav',c)
		self:set_cell( c, "closed_door" )
	end,
}

register_cell "open_blocked_door"
{
	name  = "open blocked door",
	flags = { cfBlockChange },
	pic   = "'",
	color = LIGHTGRAY,

	OnAct = function(self,c)
		ui.msg("The door is blocked.")
		ui.play_sound('sfx/items/doorclos.wav',c)
	end,
}

register_cell "lava"
{
	name  = "lava",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "=",
	color = ColorLava,
}

register_cell( "stone_wall", "solid" )
{
	name = "stone wall",
}

register_cell( "bloody_stone_wall", "solid" )
{
	name = "bloody stone wall",
	color = RED,
}

register_cell( "moving_wall_1", "solid" )
{
	name = "stone wall",
}

register_cell( "moving_wall_2", "solid" )
{
	name = "stone wall",
}

register_cell( "moving_wall_3", "solid" )
{
	name = "stone wall",
}

register_cell "grate"
{
	name = "grate",
	flags = { cfBlockMove, cfBlockChange },
	pic = ":",
	color = WHITE,
}

register_cell "grate2"
{
	name = "grate",
	flags = { cfBlockMove, cfBlockChange },
	pic = ":",
	color = BROWN,
}

register_cell "moving_grate_1"
{
	name = "grate",
	flags = { cfBlockMove, cfBlockChange },
	pic = ":",
	color = WHITE,
}

register_cell "lever_done"
{
	name  = "lever",
	flags = { cfBlockMove, cfBlockChange },
	pic   = '/',
	color = DARKGRAY,
}

register_cell "lever1"
{
	name  = "lever",
	flags = { cfBlockMove, cfBlockChange },
	pic   = '\\',
	color = GREEN,

	OnAct = function(self,c)
		self:lever_action(c,1)
		self:set_cell( c, "lever_done" )
	end,
}

register_cell "lever2"
{
	name  = "lever",
	flags = { cfBlockMove, cfBlockChange },
	pic   = '\\',
	color = GREEN,

	OnAct = function(self,c)
		self:lever_action(c,2)
		self:set_cell( c, "lever_done" )
	end,
}

register_cell "lever3"
{
	name  = "lever",
	flags = { cfBlockMove, cfBlockChange },
	pic   = '\\',
	color = GREEN,

	OnAct = function(self,c)
		self:lever_action(c,3)
		self:set_cell( c, "lever_done" )
	end,
}
