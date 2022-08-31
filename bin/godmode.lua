sound     = "DEFAULT"
mpq       = "e:\\Games\\Diablo\\DIABDAT.MPQ"

godkey = {}
godkey["V"] = function()
	ui.msg( "Player name is "..player.name )
end

godkey["F2"] = function()
	player.hp = player.hpmax
	player.mp = player.mpmax
	player.scount = player.scount - 10
end

godkey["F3"] = function()
	cells["stairs_down"].OnAct(player:get_level())
end

godkey["F4"] = function()
	player:add_gold( 5000 )
	player:add_exp( 2000 )
	player.scount = player.scount - 10
end

godkey["SHIFT+F2"] = function()
	local level  = player:get_level()
	if level.depth > 0 then 
		for b in level:children("npc") do
			if b ~= player then 
				b:die()
			end
		end
	end
end

godkey["F11"] = function()
	local level  = player:get_level()
	local target 
	if level.depth == 0 then 
		target = level:find_empty_coord( "grass", efNoMonsters, efNoObstacles )
	else
		target = level:find_empty_coord( "floor", efNoMonsters, efNoObstacles )
	end
	if target then 
		player:displace( target )
	end
end

godkey["F12"] = function()
	player.flags[ nfInfravision ] = not player.flags[ nfInfravision ]
	player.scount = player.scount - 10
end

for k,_ in pairs(godkey) do
	Keybindings[k] = COMMAND_GODKEY
end