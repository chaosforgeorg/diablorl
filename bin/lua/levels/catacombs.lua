register_level "level5"
{
	name  = "Catacombs, level 5",
	depth = 5,
	up    = "level4",
	down  = "level6",
	music = 'music/dlvlb.wav',

	wall_color       = { 80, 96, 96 },
	floor_color_base = DARKGRAY,
	floor_color      = { 128, 96, 0 },

	OnCreate = function(self)
		generator.room_level( self, "catacombs" )
		--place shortcut to town
		self:set_cell( self:find_empty_square(), "stairs_up_catacombs")
		--prepare sky rock quest
		if quests["sky_rock_quest"].enabled then
			self:set_cell( self:find_empty_square(), "magic_rock")
		end
	end,
}

register_level "level6"
{
	name  = "Catacombs, level 6",
	depth = 6,
	up    = "level5",
	down  = "level7",
	music = 'music/dlvlb.wav',

	wall_color       = { 80, 80, 96 },
	floor_color      = { 96, 64, 62 },
	floor_color_base = DARKGRAY,

	OnCreate = function(self)
		generator.room_level( self, "catacombs" )
		-- place the Book of the Blind if needed
		if quests["bone_chamber"].enabled then
			self:set_cell( self:find_empty_square(), "mythical_book")
		end
	end,
}

register_level "level7"
{
	name  = "Catacombs, level 7",
	depth = 7,
	up    = "level6",
	down  = "level8",
	music = 'music/dlvlb.wav',

	wall_color       = { 96, 80, 96 },
	floor_color      = { 128, 96, 128 },
	floor_color_base = DARKGRAY,

  	OnCreate = function(self)
		generator.room_level( self, "catacombs" )
		-- place the Book of the Blind if needed
		if quests["halls_of_blind"].enabled then
			self:set_cell( self:find_empty_square(), "book_of_the_blind")
		end
	end,

}

register_level "level8"
{
	depth = 8,
	up    = "level7",
	down  = "level9",
	name  = "Catacombs, level 8",
	music = 'music/dlvlb.wav',

	wall_color       = { 80, 96, 80 },
	floor_color_base = DARKGRAY,
	floor_color      = { 96, 128, 96 },

  	OnCreate = function(self)
		generator.room_level( self, "catacombs" )
		-- place a story tome
		local tomes = {"wages_of_sin_are_war","tale_of_the_three","sin_war"}
		self:set_cell( self:find_empty_square(), tomes[player.quest["tomes"]])
	end,
}
