register_level "level9"
{
	name  = "Caves, level 9",
	depth = 9,
	up    = "level8",
	down  = "level10",
	music = 'music/dlvlc.wav',

	wall_color      = { 128, 96, 0 },
	wall_color_base = BROWN,
	floor_color     = { 160, 96, 0 },

	OnCreate = function( self )
		generator.cave_level( self, "caves" )
		self:set_cell( self:find_empty_square(), "stairs_up_caves")
	end,

}

register_level "level10"
{
	name  = "Caves, level 10",
	depth = 10,
	up    = "level9",
	down  = "level11",
	music = 'music/dlvlc.wav',

	wall_color  = { 96, 80, 0 },
	floor_color = { 96, 80, 0 },

	OnCreate = function( self )
		generator.cave_level( self, "caves" )
	end,
}

register_level "level11"
{
	name  = "Caves, level 11",
	depth = 11,
	up    = "level10",
	down  = "level12",
	music = 'music/dlvlc.wav',

	wall_color  = { 80, 128, 128 },
	floor_color = { 80, 128, 128 },

	OnCreate = function( self )
		generator.cave_level( self, "caves" )
	end,
}

register_level "level12"
{
	name  = "Caves, level 12",
	depth = 12,
	up    = "level11",
	down  = "level13",
	music = 'music/dlvlc.wav',

	wall_color  = { 128, 80, 0 },
	floor_color = { 160, 80, 0 },

	OnCreate = function( self )
		generator.cave_level( self, "caves" )
		-- place a story tome
		local tomes = {"tale_of_the_horadrim","the_black_king","binding_of_the_three"}
		self:set_cell( self:find_empty_square(), tomes[player.quest["tomes"]])
	end,
}
