generator.hotspots = {}

function generator.code_to_translation( code )
	local translation = {}
	for k,v in pairs(code) do
		translation[k] = v
		if type(v) == "table"  then translation[k] = cells[translation[k][1]].nid end
		if type(v) == "string" then translation[k] = cells[v].nid end
	end
	return translation
end

function generator.tile_place_raw( level, map, code, c )
	local tile_pos    = c or coord.new(1,1)
	local tile_object = generator.tile_new( map, generator.code_to_translation( code ), true )
	generator.tile_place_object( level, tile_object, code, tile_pos )
end

function generator.tile_place_object( level, tile_object, code, tile_pos )
	generator.tile_place_hotspots( level, tile_pos, tile_object )
	local tile_area   = tile_object:get_area()
	for c in tile_area() do
		local tile_entry = code[ string.char( tile_object:get_ascii(c) ) ]
		if type(tile_entry) == "table" then
			if tile_entry[2] then
				level:drop_npc( tile_entry[2], tile_pos + c - coord.UNIT )
			end
		end
	end
end

function generator.tile_place_hotspots( level, pos, tile )
	local cell_marker = cells["marker"].nid
	local cell_wall   = cells["stone_wall"].nid
	local place_area  = area.new( pos, pos - coord.UNIT + tile:get_size_coord() )
	generator.tile_place( pos, tile )

	for c in place_area() do
		if level:raw_get_cell( c ) == cell_marker then
			level:raw_set_cell( c, cell_wall )
			if area.FULL_SHRINKED:contains( c ) then
				table.insert( generator.hotspots, c:clone() )
			end
		end
	end
end

function generator.roll_monsters( self )
	local monster_size = 4000-386 -- golem
	local full_list = table.icopy( npcs["level"..self.depth] )

	if (levels[self.id].monsters_list == nil) then
		-- TODO: preload this list with base monster of any quest uniques appearing on the level
		levels[self.id].monsters_list = {}
	end

	if #full_list == 0 then
		error("Monster table for level "..self.id.." is empty!")
	end

	while #full_list > 0 do
		local roll = math.random(#full_list)
		if npcs[ full_list[roll] ].size <= monster_size then
			table.insert( levels[self.id].monsters_list, full_list[roll] )
			monster_size = monster_size - npcs[ full_list[roll] ].size
		end
		table.remove( full_list, roll )
	end

	if #levels[self.id].monsters_list == 0 then
		error("Monster table for level "..self.id.." generated empty!")
	end

	-- Jarulf 3.11
	-- "There are assumed to exist 185 monsters on all levels with the exception of level
	--  1 and 2 that are a bit smaller and thus has a somewhat less monsters."
	-- However observed counts are much lower e.g. level 1 = 123 monsters
	local count=0
	if (self.depth < 3) then
		count = 125
	else
		count = 150
	end

	-- spawn the random uniques Jarulf 5.3.2
	-- "8. If any monster type that was picked has a unique monster set to appear on the
	--  dlvl in question, that unique monster will always appear.
	for _, n in ipairs(npcs["unique_list"]) do
		if (npcs[n].random and npcs[n].dlvl == self.depth) then
			-- found a possible unique
			-- see if it's in the monster list
			for _, m in ipairs(levels[self.id].monsters_list) do
				if (npcs[n].base == m) then
					local c = self:roll_monster(n)
					count = count - 1
					if (npcs[n].mob) then
					-- Jarulf 5.4: "The monsters of that mob also have the same special
					-- ability (AI script) as their boss and have their HP doubled"
						for i=1,7+math.random(5) do
							local _, m = self:roll_monster( m, c )
							if m then
								m.hp    = m.hp * 2
								m.hpmax = m.hpmax * 2
								count = count - 1
							end
						end
					end
					break
				end
			end
		end
	end

	repeat
		local monster = npcs[ table.random_pick( levels[self.id].monsters_list ) ]
		local amount  = math.random( monster.amountmin, monster.amountmax )
		local c = self:roll_monster( monster.id)
		if c then
			if amount > 1 then
				for j=2,amount do
					self:roll_monster( monster.id,c)
					count = count - 1
				end
			end
		else
			error("no room to place monster!")
		end
	until count <= 0
end

function generator.roll_library( self )
	local x1,y1 = self:find_empty_square():get()
	local x2,y2 = x1,y1
	local cell_floor = cells['floor'].id
	while self:get_cell( coord.new( x1,y1-1 ) ) == cell_floor do y1 = y1 - 1 end
	while self:get_cell( coord.new( x2,y2+1 ) ) == cell_floor do y2 = y2 + 1 end
	while self:get_cell( coord.new( x1-1,y1 ) ) == cell_floor do x1 = x1 - 1 end
	while self:get_cell( coord.new( x2+1,y2 ) ) == cell_floor do x2 = x2 + 1 end
	if (x2-x1<2)or(y2-y1<2) then return end
	-- limit size of library
	local limit = math.random(2,6)
	if ((x2 - x1) > limit) then
		x2 = x1 + limit
	end
	if (limit < 4) then
		limit = 4
	else
		limit = math.random(2,6)
	end
	if ((y2 - y1) > limit) then
		y2 = y1 + limit
	end
	local bookshelf = true
	for y = y1+1,y2-1 do
		for x = x1+1, x2-1 do
			if ((y-y1)%2 == 1)and((x-x1)%2==1) then
				local c = coord.new(x,y)
				if self:get_cell(c) == cell_floor then
					if bookshelf then
						-- library always has one bookshelf
						self:set_cell(c,"bookshelf")
						bookshelf = false
					elseif math.random(10)<6 then
						self:set_cell(c,"library_book")
					else
						self:set_cell(c,"open_book")
	end end end end end
end

function generator.scatter_furniture( self, id, amount )
	for i=1,amount do
		self:set_cell( self:find_empty_square(), id )
	end
end

function generator.roll_barrels( self, amount, max )
	for i=1,amount do
		local c = self:find_empty_square()
		local count = math.random( max )
		for k=1,count do
			c = self:find_near_coord( c, 2, efNoItems, efNoMonsters )
			if c then
				self:set_cell( c, "barrel" )
			else
				break
			end
		end
	end
end

function generator:roll_treasure_room()
	local c = self:roll_gold()
	for i = 1, math.random(6,10) do
		c = self:roll_gold(c)
	end
end

function generator.roll_potions( self, amount )
	for i = 1, amount do
		local c = self:find_empty_coord("floor", efNoItems, efNoMonsters)
		if c then
			self:drop_random_potion( c )
		end
	end
end

function generator.roll_magic_items( self, amount )
	if amount <= 0 then return end
	for i = 1, amount do
		local c = self:find_empty_coord("floor", efNoItems, efNoMonsters)
		if c then
			self:drop_random_item( c, self.depth * 2, 100, false, 0 )
	end	end
end

function generator.roll_door()
	local n = math.random(12)
	if n < 8 then -- magic numbers here!
		return cells["closed_door"].nid
	elseif n < 10 then
		return cells["closed_door_2"].nid
	else
		return cells["floor"].nid
	end
end

function generator:clear_dead_ends()
	local area = self:get_area()
	local MapSizeX = 100
	local MapSizeY = 100
	for gen_x = 2, MapSizeX-1 do
		for gen_y = 2, MapSizeY-1 do
			if ( self:cross_around( coord.new( gen_x, gen_y), generator.CellWalls ) == 3 ) then
				self:set_cell( coord.new( gen_x, gen_y), cells["stone_wall"].nid )
	end	end	end
end

function generator.contd_drunkard_walks( amount, steps, cell, edges1, edges2, ignore, break_on_edge )
	if amount <= 0 then return end
	local drunk_area = area.FULL_SHRINKED
	local c
	for i=1,amount do
		repeat
			c = drunk_area:random_coord()
		until generator.cross_around( c, edges1 ) > 0 and
			generator.cross_around( c, edges2 ) > 0
		generator.run_drunkard_walk( drunk_area, c, steps, cell, ignore, break_on_edge )
	end
end

function generator.place_blob( self, start, size, cell )
	local floor_cell = cells["floor"].nid
	local cells = { cell, floor_cell }
	local visit = {}
	table.insert( visit, start )
	for j = 1,size do
		if #visit == 0 then break end
		local idx = math.random( #visit )
		local n   = visit[ idx ]
		table.remove( visit, idx )
		if generator.around( n, cells ) == 8 then
			self:raw_set_cell( n, cell )
			for c in n:cross_coords() do
				if self:raw_get_cell( c ) == floor_cell then
					table.insert( visit, c:clone() )
				end
			end
		end
	end
end

function generator.get_fence_endpoint( self, point, delta )
	local finish = { [cells["stone_wall"].nid] = true, [cells["grate2"].nid] = true }
	local p = point:clone()
	repeat
		p = p + delta
	until finish[ self:raw_get_cell( p ) ]
	return p - delta
end

function generator.place_stairs( self )
	-- todo: check for nil
	local tile
	tile = self:find_tile( "stairs_down" )
	if not tile then generator.set_cell( self:find_empty_square(), "stairs_down" ) end
	tile = self:find_tile( "stairs_up" )
	if not tile then generator.set_cell( self:find_empty_square(), "stairs_up" ) end
end


function generator.cave_level( self, gen_type )
	local floor_cell = cells["floor"].nid
	local grate      = cells["grate2"].nid
	local marker     = cells["marker"].nid
	local wall_cell  = cells["stone_wall"].nid
	local level_area = self:get_area()
	local w,h = level_area.b.x, level_area.b.y

	local amount = math.random(5)
	local step = math.random(50)+42
	local fluid = cells["lava"].nid

	local drunk = function( amount, step, cell )
		generator.contd_drunkard_walks( amount, step, cell, { floor_cell, fluid }, {wall_cell}, nil, true )
	end

	generator.fill( wall_cell )
	local sub_area = level_area:shrinked( math.floor( 20 ) )
	generator.fill( floor_cell, sub_area )
	sub_area:shrink( 4 )
	generator.fill( wall_cell, sub_area )

	--generator.run_drunkard_walk( area.FULL_SHRINKED, coord.new( math.floor(w/2), math.floor(h/2) ), math.random(100)+400, floor_cell, nil, true )
	drunk( 10, math.random(100)+400, floor_cell )
--	drunk( amount, step,   fluid )
	drunk( 50, math.random(100)+200, floor_cell )
--	drunk( amount, step+20, fluid )

	for c in level_area:shrinked()() do
		if self:raw_get_cell(c) == wall_cell and generator.around( c, wall_cell ) < 4 then
			self:raw_set_cell( c, floor_cell )
		end
	end

	for c in level_area:shrinked(2)() do
		if self:raw_get_cell(c) == floor_cell and generator.cross_around( c, wall_cell ) > 2 then
			for k in c:cross_coords() do
				self:raw_set_cell( k, marker )
			end
		end
	end

	generator.transmute( marker, floor_cell )

	local bcount = math.random(10) + 10
	for i = 1,bcount do
		local start = self:find_empty_square()
		local count = math.random( 50 ) + 20
		if math.random(5) == 1 then
			count = count * 3
		end
		generator.place_blob( self, start, count, marker )
	end

	generator.transmute( marker, wall_cell )

	local count = 0
	for i = 1,1000 do
		local dim = coord.new( math.random( 6, 8 ), math.random( 6, 8 ) )
		local a = area.FULL_SHRINKED:random_subarea( dim )
		if generator.scan( a, floor_cell, false ) == 0 then
			a:shrink()
			generator.fill( grate, a )
			generator.set_cell( a:random_inner_edge_coord(), generator.roll_door() )
			a:shrink()
			generator.fill( marker, a )
			count = count + 1
		end
		if count == 10 then break end
	end

	for i = 1,50 do
		local p = self:find_empty_square()
		local l, r
		if math.random(2) == 1 then
			l = coord.new(-1,0)
			r = coord.new( 1,0)
		else
			l = coord.new(0,-1)
			r = coord.new(0, 1)
		end
		local el = generator.get_fence_endpoint( self, p, l )
		local er = generator.get_fence_endpoint( self, p, r )
		local fa = area.new( el, er )
		local a = area.new( el - l, er - r ):expanded()
		if generator.scan( a, floor_cell, false ) == 0 then
			generator.fill( grate, fa )
			generator.set_cell( p, generator.roll_door() )
		end

	end

	local bcount = math.random(10) + 10
	for i = 1,bcount do
		local start = self:find_empty_square()
		local count = math.random( 50 ) + 20
		if math.random(5) == 1 then
			count = count * 3
		end
		generator.place_blob( self, start, count, fluid )
	end

	generator.transmute( marker, floor_cell )

	generators[ gen_type ].OnPlaceItems( self )
	generators[ gen_type ].OnPlaceMonsters( self )

	generator.place_stairs( self )
end


function generator.room_level( self, gen_type )
	generator.fill( "stone_wall" )
	if not generators[ gen_type ].tile_data then
		generators[ gen_type ].tile_data = generator.load_tile_data( generators[ gen_type ].tiles )
	end

	local count = 0
	local limit = 500
	local cell_marker = cells["marker"].nid
	local cell_floor  = cells["floor"].nid
	local cell_wall   = cells["stone_wall"].nid
	local level_area  = self:get_area()

	if self.__proto.map then
		self.__proto.map_key["*"] = "marker"
		local w,h         = level_area.b.x, level_area.b.y
		local tile_object = generator.tile_new( self.__proto.map, generator.code_to_translation( self.__proto.map_key ), true )
		local size        = tile_object:get_size_coord()
		local pos         = coord.new( math.floor( w / 2 - size.x / 2 ), math.floor( h / 2 - size.y / 2 ) )
		core.log("placing map at "..pos:tostring())
		generator.tile_place_object( self, tile_object, self.__proto.map_key, pos )
		count = 1
	end

	if #generator.hotspots == 0 then
		local w,h = level_area.b.x, level_area.b.y
		local c = coord.new( math.random( w/2) + w/4, math.random( h/2) + h/4)
		for i=1,20 do
			table.insert( generator.hotspots, c:clone() )
		end
	end

	repeat
		local tile = table.random_pick( generators[ gen_type ].tile_data )
		--check if tile fits
		local entry = table.random_pick( generator.hotspots )
		while generator.cross_around( entry, cell_floor ) > 1 do
			entry = table.random_pick( generator.hotspots )
		end

		local direction = "n"
		if self:raw_get_cell(entry.x, entry.y+1)==cell_floor then
			direction = "s"
		elseif self:raw_get_cell(entry.x, entry.y-1)==cell_floor then
			direction = "n"
		elseif self:raw_get_cell(entry.x+1, entry.y)==cell_floor then
			direction = "e"
		elseif self:raw_get_cell(entry.x-1, entry.y)==cell_floor then
			direction = "w"
		end
		local tile_entry = table.random_pick( tile.hotspots[ direction ] )

		local place_pos  = entry - tile_entry + coord.UNIT
		local place_area = area.new( place_pos, place_pos - coord.UNIT + tile.size )
		local gen_ok     = level_area:contains( place_area )

		if gen_ok then
			for c in tile.area() do
				--check if tile fits into level
				local place = entry - tile_entry + c
				--check if tile zone is occupied
				if ( tile.tile:raw_get( c ) ~= 0 ) and
					(self:raw_get_cell( place.x, place.y ) ~= cell_wall) then
					gen_ok = false
					break
				end
			end
		end

		if gen_ok then
			generator.tile_place_hotspots( self, place_pos, tile.tile )
			if count > 0 then
				local doorway_area_a = entry
				local doorway_area_b = entry
				local door_dir_x = 0
				local door_dir_y = 0

				if ( direction == "w" ) or ( direction == "e" ) then
					door_dir_x = coord.new( 0, 1 )
					door_dir_y = coord.new( 1, 0 )
				else
					door_dir_x = coord.new( 1, 0 )
					door_dir_y = coord.new( 0, 1 )
				end
				while ( self:raw_get_cell( doorway_area_a - door_dir_x - door_dir_y ) == cell_floor ) and
					( self:raw_get_cell( doorway_area_a - door_dir_x + door_dir_y ) == cell_floor ) do
					doorway_area_a = doorway_area_a - door_dir_x
				end
				while ( self:raw_get_cell( doorway_area_b + door_dir_x - door_dir_y ) == cell_floor ) and
					( self:raw_get_cell( doorway_area_b + door_dir_x + door_dir_y ) == cell_floor ) do
					doorway_area_b = doorway_area_b + door_dir_x
				end

				local doorway_area = area.new( doorway_area_a, doorway_area_b )
				local doorway = cells[ table.random_pick( generators[ gen_type ].doorways ) ].nid
				for c in doorway_area() do
					self:raw_set_cell( c, doorway )
				end
				--add door if doorway is unpassable
				if cells[ doorway ].flags[ cfBlockMove ] then
					entry = doorway_area:random_coord()
					self:raw_set_cell( entry, generator.roll_door() )
				end
			end
		end
		count = count + 1
	until count > limit

	for _,h in ipairs( generator.hotspots ) do
		if self:raw_get_cell( h ) == cell_wall and
			generator.cross_around( h, cell_floor ) == 2 and
			generator.cross_around( h, cell_wall  ) == 2 and
			self:raw_get_cell( h.x, h.y + 1 ) == self:raw_get_cell( h.x, h.y - 1 )
		then
			self:raw_set_cell( h, generator.roll_door() )
		end
	end

	generator.hotspots = {}

	generators[ gen_type ].OnPlaceItems( self )
	generators[ gen_type ].OnPlaceMonsters( self )

	-- todo: check for nil
	generator.place_stairs( self )
end

function generator.load_tile_data( tiles )
	local translation = {
		["#"] = "stone_wall",
		["."] = "floor",
		["+"] = "closed_door",
		["*"] = "marker",
	}
	local data = {}
	local marker = cells["marker"].nid
	for _,v in ipairs(tiles) do
		local tile     = generator.tile_new( v, translation )
		local tarea    = tile:get_area()
		local hotspots = { n = {}, s = {}, e = {}, w = {} }

		for c in tarea:edges() do
			if tile:raw_get( c ) == marker then
				if c.y == 1 then table.insert( hotspots["n"], c:clone() )
				elseif c.y == tarea.b.y then table.insert( hotspots["s"], c:clone() )
				elseif c.x == 1 then table.insert( hotspots["w"], c:clone() )
				elseif c.x == tarea.b.x then table.insert( hotspots["e"], c:clone() )
				end
			end
		end

		for i,v in pairs (hotspots) do
			if #v == 0 then
				error( "no exits in direction "..tostring( i ) )
			end
		end

		local entry = {}
		entry.tile = tile
		entry.area = tarea
		entry.size = tile:get_size_coord()
		entry.hotspots = hotspots

		table.insert( data, entry )
	end
	return data
end

core.register_blueprint "generator"
{
	id          = { true,  core.TSTRING },
	name        = { true,  core.TSTRING },
	tiles       = { false, core.TTABLE },
	doorways    = { false, core.TTABLE },

	OnPlaceItems    = { true,  core.TFUNC },
	OnPlaceMonsters = { true, core.TFUNC },
}

register_generator "church"
{
	name = "church",
	tiles = tiles_church,
	doorways = {"floor", "floor", "floor",
				"stone_wall", "stone_wall", "grate" },

	OnPlaceItems = function(self)
		for i=1,math.random(2,4) do
			generator.roll_library( self )
		end

		generator.scatter_furniture( self, "sarcophagus", 10 )

		-- Jarulf 3.1.1: Each level will average 7 small chests, 4 chests, 2.5 large chests
		generator.scatter_furniture( self, "small_chest",  math.random(6,8) )
		generator.scatter_furniture( self, "medium_chest", math.random(3,5) )
		generator.scatter_furniture( self, "large_chest",  math.random(2,3) )

		for i=1,math.random(-1,3) do
			self:set_cell( self:find_empty_square(), self:random_shrine() )
		end

		--treasure room
		if math.random(2) == 1 then
			generator.roll_treasure_room( self )
		end
		--random potions
		generator.roll_potions( self, math.random(2,4) )
		generator.roll_magic_items( self, math.random(0, math.ceil(self.depth / 4)) )
		generator.roll_barrels( self, 8, 5 )
	end,

	OnPlaceMonsters = generator.roll_monsters,
}

register_generator "catacombs"
{
	name = "catacombs",
	tiles = tiles_catacombs,
	doorways = { "floor", "floor", "floor",
				"stone_wall", "stone_wall" },

	OnPlaceItems = function( self )
		for i=1,math.random(2,4) do
			generator.roll_library( self )
		end

		-- Jarulf 3.1.1: Each level will average 7 small chests, 4 chests, 2.5 large chests
		generator.scatter_furniture( self, "sarcophagus", 10 )

		-- Jarulf 3.1.1: Each level will average 7 small chests, 4 chests, 2.5 large chests
		generator.scatter_furniture( self, "small_chest",  math.random(6,8) )
		generator.scatter_furniture( self, "medium_chest", math.random(3,5) )
		generator.scatter_furniture( self, "large_chest",  math.random(2,3) )
		generator.scatter_furniture( self, "weapon_rack", math.random(-1,3) )
		generator.scatter_furniture( self, "armor_rack",  math.random(-1,3) )

		for i=1,math.random(-1,3) do
			self:set_cell( self:find_empty_square(), self:random_shrine() )
		end

		--treasure room
		if math.random(2) == 1 then
			generator.roll_treasure_room( self )
		end

		generator.roll_potions( self, math.random(2,4) )
		generator.roll_magic_items( self, math.random(0, math.ceil(self.depth / 4)) )
		generator.roll_barrels( self, 8, 5 )
	end,

	OnPlaceMonsters = generator.roll_monsters,
}

register_generator "caves"
{
	name = "caves",

	OnPlaceItems = function( self )
		-- Jarulf 3.1.1: Each level will average 7 small chests, 4 chests, 2.5 large chests
		generator.scatter_furniture( self, "small_chest",  math.random(6,8) )
		generator.scatter_furniture( self, "medium_chest", math.random(3,5) )
		generator.scatter_furniture( self, "large_chest",  math.random(2,3) )
		generator.scatter_furniture( self, "weapon_rack", math.random(-1,3) )
		generator.scatter_furniture( self, "armor_rack",  math.random(-1,3) )

		for i=1,math.random(-1,3) do
			self:set_cell( self:find_empty_square(), self:random_shrine() )
		end

		generator.roll_potions( self, math.random(2,4) )
		generator.roll_magic_items( self, math.random(0, math.ceil(self.depth / 4)) )
		generator.roll_barrels( self, 3, 4 )
	end,

	OnPlaceMonsters = generator.roll_monsters,
}
