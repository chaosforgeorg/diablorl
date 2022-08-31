Keybindings = {
	-- Movement
	["LEFT"]        = COMMAND_WALKWEST,
	["RIGHT"]       = COMMAND_WALKEAST,
	["UP"]          = COMMAND_WALKNORTH,
	["DOWN"]        = COMMAND_WALKSOUTH,
	["PGUP"]        = COMMAND_WALKNE,
	["PGDOWN"]      = COMMAND_WALKSE,
	["HOME"]        = COMMAND_WALKNW,
	["END"]         = COMMAND_WALKSW,
	["CENTER"]      = COMMAND_WAIT,
	["PERIOD"]      = COMMAND_WAIT,

	-- Attack in place
	["CTRL+LEFT"]   = COMMAND_ATKWEST,
	["CTRL+RIGHT"]  = COMMAND_ATKEAST,
	["CTRL+UP"]     = COMMAND_ATKNORTH,
	["CTRL+DOWN"]   = COMMAND_ATKSOUTH,
	["CTRL+PGUP"]   = COMMAND_ATKNE,
	["CTRL+PGDOWN"] = COMMAND_ATKSE,
	["CTRL+HOME"]   = COMMAND_ATKNW,
	["CTRL+END"]    = COMMAND_ATKSW,

	-- Running
	["SHIFT+LEFT"]  = COMMAND_RUNWEST,
	["SHIFT+RIGHT"] = COMMAND_RUNEAST,
	["SHIFT+UP"]    = COMMAND_RUNNORTH,
	["SHIFT+DOWN"]  = COMMAND_RUNSOUTH,
	["SHIFT+PGUP"]  = COMMAND_RUNNE,
	["SHIFT+PGDOWN"]= COMMAND_RUNSE,
	["SHIFT+HOME"]  = COMMAND_RUNNW,
	["SHIFT+END"]   = COMMAND_RUNSW,

	-- Meta (note that SWITCHMODE is also FASTTRAVEL)
	["ESCAPE"]      = COMMAND_ESCAPE,
	["BACKSPACE"]   = COMMAND_CWIN,
	["TAB"]         = COMMAND_SWITCHMODE,
	["F10"]         = COMMAND_SSHOT,
	["F9"]          = COMMAND_SSHOTBB,

	["M"]           = COMMAND_MESSAGES,
	["D"]           = COMMAND_DROP,
	["G"]           = COMMAND_PICKUP,
	["I"]           = COMMAND_INVENTORY,
	["B"]		    = COMMAND_SPELLBOOK,
	["SPACE"]       = COMMAND_ACT,
	["L"]           = COMMAND_LOOK,
	["F"]           = COMMAND_FIRE,    -- function() command.fire() end,
	["Z"]		    = COMMAND_CAST,    -- function() command.fire(true) end,
	["C"]	        = COMMAND_PLAYERINFO,
	["J"]		    = COMMAND_JOURNAL,
	["ENTER"]	    = COMMAND_OK,

	-- These are unimplemented as for now
	["LBRACKET"]    = COMMAND_SOUNDVOLUP,
	["RBRACKET"]    = COMMAND_SOUNDVOLDN,
	["SHIFT+LBRACKET"] = COMMAND_MUSICVOLUP,
	["SHIFT+RBRACKET"] = COMMAND_MUSICVOLDN,

	-- QuickKeys
	["Q"]           = COMMAND_QUICKSLOT,
	["1"]           = COMMAND_QUICKSLOT1,
	["2"]           = COMMAND_QUICKSLOT2,
	["3"]           = COMMAND_QUICKSLOT3,
	["4"]           = COMMAND_QUICKSLOT4,
	["5"]           = COMMAND_QUICKSLOT5,
	["6"]           = COMMAND_QUICKSLOT6,
	["7"]           = COMMAND_QUICKSLOT7,
	["8"]           = COMMAND_QUICKSLOT8,

	["S"]           = COMMAND_QUICKSKILL,
	["F5"]          = COMMAND_SPELLSLOT1,
	["F6"]          = COMMAND_SPELLSLOT2,
	["F7"]          = COMMAND_SPELLSLOT3,
	["F8"]          = COMMAND_SPELLSLOT4,

}
