register_level "level1"
{
	name  = "Church, level 1",
	depth = 1,
	up    = "town",
	down  = "level2",
	music = 'music/dlvla.wav',

	wall_color  = { 96, 128, 128 },
	floor_color = { 200, 160, 128 },

	OnCreate = function(self)
		generator.room_level( self, "church" )
	    if (math.random(2)==1) then
			ui.msg("@<\"The sanctity of this place has been fouled...\"@>")
			player:play_sound(97)
		else
			ui.msg("@<\"The smell of death surrounds me...\"@>")
			player:play_sound(96)
		end
	end,

}

register_level "level2"
{
	name  = "Church, level 2",
	depth = 2,
	up    = "level1",
	down  = "level3",
	music = 'music/dlvla.wav',

	wall_color  = { 96, 96, 128 },
	floor_color = { 180, 160, 128 },

	OnCreate = function(self)
		generator.room_level( self, "church" )
		if (quests["butcher"].enabled) then
			ui.msg("The smell of blood is everywhere!")
		end

		if (quests["water"].enabled) then
			self:set_cell(self:find_empty_square(),"stairs_down_special")
			player.quest["water"] = 1
		end
	end,
}


register_level "level3"
{
	name  = "Church, level 3",
	depth = 3,
	up    = "level2",
	down  = "level4",
	music = 'music/dlvla.wav',

	wall_color  = { 128, 96, 128 },
	floor_color = { 180, 180, 200 },

  	OnCreate = function(self)
		generator.room_level( self, "church")
		if (quests["leoric_quest"].enabled) then
			player.quest["leoric_quest"] = 1
		end
	end,
}

register_level "level4"
{
	name  = "Church, level 4",
	depth = 4,
	up    = "level3",
	down  = "level5",
	music = 'music/dlvla.wav',

	wall_color  = { 96, 128, 96 },
	floor_color = { 200, 128, 96 },

  	OnCreate = function(self)
		generator.room_level( self, "church" )
		if (quests["gharbad_quest"].enabled) then
			self:drop_npc( "gharbad", self:find_empty_square() )
			core.log("Gharbad placed.")
		end

		-- place a story tome
		local tomes = {"the_great_conflict","the_realms_beyond","dark_exile"}
		self:set_cell( self:find_empty_square(), tomes[player.quest["tomes"]])
	end,

	OnEnter = function(self)
		if quests["sign"].enabled then
			if player.quest["sign"] == 3 or player.quest["sign"] == 5 then
				self:move_walls("moving_wall_1")
				self:move_walls("moving_grate_1")
				local snot = self:find("snotspill")
				if snot then snot:set_ai( AIFallenOne ) end
				player.quest["sign"] = player.quest["sign"] + 1
			end
		end
	end,
}
