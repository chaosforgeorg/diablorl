register_level "level13"
{
	name  = "Hell, level 13",
	depth = 13,
	up    = "level12",
	down  = "level14",
	music = 'music/dlvld.wav',

	OnCreate = function( self )
		generator.cave_level( self, "caves" )
	end,
	
	OnEnter = function(self)
	    ui.msg_enter("Congratulations! You have won the Demo version!")
		world.end_game()
	end,
}

register_level "level14"
{
	name  = "Hell, level 14",
	depth = 14,
	up    = "level15",
	down  = "level16",
	music = 'music/dlvld.wav',

	OnCreate = function( self ) end,
}

register_level "level15"
{
	name  = "Hell, level 15",
	depth = 15,
	up    = "level14",
	down  = "level16",
	music = 'music/dlvld.wav',

	OnCreate = function( self ) end,
}

register_level "level16"
{
	name  = "Hell, level 16",
	depth = 16,
	up    = "level15",
	music = 'music/dlvld.wav',

	OnCreate = function( self ) end,
}
