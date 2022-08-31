-- main namespace --
DiabloRL = {}

-- skeletons --
skeletons = {}

core.register_blueprint "level"
{
	id          = { true,  core.TSTRING },
	name        = { true,  core.TSTRING },
	depth       = { true,  core.TNUMBER },
	up          = { false, core.TSTRING },
	down        = { false, core.TSTRING },
	special     = { false, core.TIDIN("levels") },
	map         = { false, core.TSTRING },
	map_key     = { false, core.TTABLE },
	music       = { true,  core.TSTRING },
	flags       = { false, core.TFLAGS, {} },
	is_special  = { false, core.TBOOL,  false },

	wall_color       = { false, core.TTABLE, { 128, 128, 128 } },
	floor_color      = { false, core.TTABLE, { 200, 200, 200 } },
	wall_color_base  = { false, core.TNUMBER, DARKGRAY },
	floor_color_base = { false, core.TNUMBER, LIGHTGRAY },

	OnCreate    = { true, core.TFUNC },
	OnEnter     = { false, core.TFUNC },
	OnKillAll   = { false, core.TFUNC },
}

register_level = core.register_storage( "levels", "level", function( l )
		if l.special then
			levels[l.special].special = l.id
			l.up    = l.up   or l.special
			l.down  = l.down or l.special
			l.is_special = true
		end
	end
)
register_achievement = core.register_storage( "achievements", "achievement" )
register_klass       = core.register_storage( "klasses", "klass" )
register_quest       = core.register_storage( "quests", "quest" )
register_generator   = core.register_storage( "generators", "generator" )
register_shop        = core.register_storage( "shops", "shop" )

register_suffix      = core.register_storage( "suffixes", "suffix" )
register_prefix      = core.register_storage( "prefixes", "prefix" )
register_unique		 = core.register_storage( "uniques", "unique", function(u)
		for _,v in pairs(u.base) do
			if items[v] then
				if not items[v].uniques then
					items[v].uniques = {}
				end
				table.insert( items[v].uniques, u.id )
			else
				error(u.name.." is missing base item " .. v)
			end
		end
	end
)

register_spell       = core.register_storage( "spells", "spell", function(s)
		if s.scroll then
			local scroll_flags = { ifNotInTown }
			if s.townsafe then scroll_flags = {} end
			register_item ( "scroll_"..s.id, "scroll" ) {
				name   = "scroll of "..string.lower(s.name),
				flags  = scroll_flags,
				color  = s.color,
				price  = s.scroll.price,
				level  = s.scroll.level or 1,
				minmag = s.scroll.mag or 0,
				spell  = s.id,
			}
		end
	end
)

register_cell       = core.register_storage( "cells", "cell", function(c) c.piclow = c.piclow or c.pic end )

register_item       = core.register_storage( "items", "item", function(i)
		i.piclow = i.piclow or i.pic
		i.flags[i.type] = true
		if items["level"..i.level] == nil then
			items["level"..i.level] = {}
		end
		table.insert(items["level"..i.level],i.id)
	end
)

register_npc       = core.register_storage( "npcs", "npc", function(b)

  -- this is a hack, but at least a clean one
  local old_act = b.OnAct
  b.OnAct = function(self)
	if old_act then
		old_act(self)
	else
		if ai_scripts[ self.ai ].OnAct then
			ai_scripts[ self.ai ].OnAct(self)
		end
	end
  end
  b.OnCreate = core.create_seq_function( ai_scripts[ b.ai ].OnCreate, b.OnCreate )

	if b.corpse == "bones" then
		b.corpse = register_cell ( "bones_" .. b.id, "bones" ) { raiseto = b.id }
	end

  -- rest is brutally copied
  for k,v in pairs(ai_scripts[ b.ai ]) do
	if not b[k] then
		b[k] = v
	end
  end

  if b.flags[nfUnique] then
	if b.mob then
		if npcs[b.base] == nil then
			error("missing base monster class " .. b.base)
		end
	end
	if b.base and b.expvalue == 0 then
		b.expvalue = npcs[b.base].expvalue * 2
	end
	if npcs["unique_list"] == nil then
		npcs["unique_list"] = {}
	end
	table.insert(npcs["unique_list"],b.id)
  else
	if b.group then
		for k,v in ipairs(b.group) do
			if npcs["level"..v] == nil then
				npcs["level"..v] = {}
			end
			table.insert(npcs["level"..v],b.id)
			-- separate list for skeletons
			if b.flags[nfSkeleton] then
				if skeletons[v] == nil then
					skeletons[v] = {}
				end
				table.insert(skeletons[v], b.id)
			end
			-- todo - this should be without duplicates
			if npcs["list"] == nil then
				npcs["list"] = {}
			end
			table.insert(npcs["list"],b.id)
		end
	end
  end

  b.group = b.group or {}
end
)


-- Metatable hack that disallows usage of undeclared variables --
setmetatable(_G, {
	__newindex = function (_, n)
		error("attempt to write to undeclared variable "..n, 2)
	end,
	__index = function (_, n)
		error("attempt to read undeclared variable "..n, 2)
	end,
})

npcs['warrior'] = {}
npcs['rogue'] = {}
npcs['mage'] = {}

table.merge( thing, game_object )

function thing:get_level()
	local this = self
	while this and this:get_type() ~= "level" do
		this = this:get_parent()
	end
	return this
end

setmetatable(thing,getmetatable(game_object))

shop.item = {}

setmetatable(shop.item, {
	__newindex = function (self, key, value)
		shop.item_set( self, key, value )
	end,
	__index = function (self, key)
		return shop.item_get( self, key )
	end,
})

function shop:add_item( it )
	local i = 0
	repeat
		i = i + 1
		if i > ITEMS_SHOP then return nil end
	until self:item_get( i ) == nil
	if type( it ) == "string" then it = item.new( it ) end
	self:item_set( i, it )
	self:sort()
	return it
end

function shop:clear()
	for i = 1, ITEMS_SHOP do
		self:item_set(i,nil)
	end
end

function shop:items()
	local i = 0
	return function ()
		while i < ITEMS_SHOP do
			i = i + 1
			local it = self:item_get( i )
			if it then return it end
		end
		return nil
	end
end

table.merge( shop, game_object )
setmetatable(shop,getmetatable(game_object))

function item:is_wearable()
	local itype = self.itype
	return  itype == TYPE_HELM   or itype == TYPE_ARMOR or
			itype == TYPE_SHIELD or itype == TYPE_WEAPON or
			itype == TYPE_RING   or itype == TYPE_AMULET or
			itype == TYPE_STAFF  or itype == TYPE_SSTAFF or
			itype == TYPE_BOW
end

function item:apply_fix( fix, value )
	if (not value) and type(fix.min) == "number" and type(fix.max) == "number" then
		value = math.random(fix.min,fix.max)
	end

	if fix.OnApply then fix.OnApply( self, value ) end
	for f,v in pairs(fix.flags) do
		self.flags[ f ] = v
	end

    if value and fix.min ~= fix.max then
      self.pricemod = self.pricemod + math.floor( ((value-fix.min) / (fix.max-fix.min))
	                                           * (fix.price_max-fix.price_base ) )
    end
    self.pricemod = self.pricemod + fix.price_base
	if math.abs(fix.multiplier) > 1 then
		self.pricemul = self.pricemul + fix.multiplier
	end

	local name = self.name
	if not (self.flags[ ifMagic ]) then
		if (items[self.id].iname) and (items[self.id].iname~="") then
			name = items[self.id].iname
		end
		self.flags[ ifMagic ]   = true
		self.flags[ ifUnknown ] = true
		self.color = LIGHTBLUE
	end

	if fix.prefix then
		self.name = fix.name..name
	else
		self.name = name..fix.name
	end

	return value or 0
end

function item:apply_unique( unique )
	if type( unique ) == "string" then
		unique = uniques[unique]
	end
	self.name	= unique.name
	self.price	= unique.price
	if unique.OnApply then
		unique.OnApply( self )
	end
	if unique.effect then
		for i,v in pairs ( unique.effect ) do
			self[i] = v
		end
	end
	self.flags[ ifUnique ]	= true
	self.flags[ ifUnknown ]	= true
	self.color	= YELLOW
	self.dur	= self.durmax
	if self.dur < items[self.id].durability then
		self.durmod = -1
	elseif self.dur > items[self.id].durability then
		self.durmod = 1
	end
end


table.merge( item, thing )
setmetatable(item,getmetatable(thing))

function npc:set_ai( new_ai )
	if new_ai ~= self.ai then
		self.ai = new_ai
		if ai_scripts[ new_ai ].OnCreate then
			ai_scripts[ new_ai ].OnCreate( self )
		end
	end
end

function npc:set_travel_point()
	local level = self:get_level()
	if level:has_travel_point( self ) then return end
	level:add_travel_point( self, self.name )
end

function npc:msg(message)
	if self:get_type() == "player" then
		ui.msg(message)
	end
end

function npc:seek_away(c)
	self:seek(c,-1)
end

function npc:circle(c)
	self:seek(c,0)
end

function npc:standard_drop()
	local level = self:get_level()
	-- The probability of being magical:
	-- Unique monster	: 100%
	-- Monster			: (11 + 0.89*(ilvl+1))%
	-- Jarulf 3.8.2 "Is it magical?"
	if self.flags[ nfUnique ] then
		-- Unique monsters always drop an item,
		-- and it can either be a book or an item
		-- that can take on a prefix and/or
		-- suffix (or be unique).
		-- Jarulf 3.8.1 "Unique monster"
		local mlvlitem = self.level
		if npcs[self.id].base and npcs[ npcs[self.id].base ] then
			mlvlitem = npcs[ npcs[self.id].base ].level
		end
		level:drop_random_item( self.position, mlvlitem, 100, true, 0 )
	else
		-- Normal monster
		-- Gold		: 30.3%
		-- Item		: 10.7%
		-- Nothing	: 59.0%
		-- Jarulf 3.8.1 "Normal monster"
		local roll = math.random(10)
		if roll < 7  then return end
		if roll < 10 then
			level:drop_gold( self.position )
		else
			level:drop_random_item( self.position, self.level )
		end
	end
end

table.merge( npc, thing )
setmetatable(npc,getmetatable(thing))

function player:pronoun()
	if klasses[self.klass].gender == "f" then
		return "She"
	else
		return "He"
	end
end

function player:salutation()
	if klasses[self.klass].gender == "f" then
		return "lass"
	else
		return "lad"
	end
end

function player:write_memorial( killer )
	local l = player:get_level()
	local victory = l.depth > 12 --victory condition
	local score       = self.exp / 100 + player.maxdepth * player.maxdepth * 1000
	local score_base  = score
	for i,v in ipairs(quests) do
		if v.enabled and self.quest[i] >= v.completed then
			score = score + v.score
		end
	end
	for i,v in ipairs(achievements) do
		if v.score > 0 and v.check( victory ) then
			score = score + score_base * v.score
		end
	end
	self:memorial_print("--------------------------------------------------------------")
	self:memorial_print("  DiabloRL "..VERSION.." roguelike postmortem character dump")
	self:memorial_print("--------------------------------------------------------------")
	self:memorial_print("")
	if victory then
		self:memorial_print("  "..self.Name..", level "..tostring(self.level).." "..klasses[self.klass].name..", reached Hell.")
	elseif killer then
		self:memorial_print("  "..self.Name..", level "..tostring(self.level).." "..klasses[self.klass].name..", killed by "..killer:get_name( 1 ).." in "..l.name..".")
	else
		self:memorial_print("  "..self.Name..", level "..tostring(self.level).." "..klasses[self.klass].name..", died in "..l.name..".")
	end
	self:memorial_print("  "..self:pronoun().." scored "..tostring(score).." points, killing "..tostring(self.kill_count).." hellspawn.")
	self:memorial_print("")
	self:memorial_print("  "..self:pronoun().." advanced to level "..tostring(self.level).." gaining "..tostring(self.exp).." experience.")
	self:memorial_print("  "..self:pronoun().." amassed "..tostring(self.gold).." gold coins.")
	for i,v in ipairs(quests) do
		if v.enabled and self.quest[i] >= v.completed then
			self:memorial_print("  "..self:pronoun().." "..v.message)
		end
	end
	for _,v in ipairs(achievements) do
		if v.check( victory ) then
			local bonus = ""
			if v.score > 0 then bonus = " (+"..math.floor( v.score * 100 ).."%)" end
			self:memorial_print("  "..self:pronoun().." "..v.message..bonus)
		end
	end
	self:memorial_print("")
	self:memorial_print("-- Statistics ------------------------------------------------")
	self:memorial_print("")
	self:memorial_print("  Strength   "..tostring(self.str_full).."/"..tostring(self.str))
	self:memorial_print("  Magic      "..tostring(self.mag_full).."/"..tostring(self.mag))
	self:memorial_print("  Dexterity  "..tostring(self.dex_full).."/"..tostring(self.dex))
	self:memorial_print("  Vitality   "..tostring(self.vit_full).."/"..tostring(self.vit))
	self:memorial_print("")
    self:memorial_print("  Life "..tostring(self.hpmax).."/"..tostring(self.hp).."  Mana "..tostring(self.mpmax).."/"..tostring(self.mp))
	self:memorial_print("  Armor "..tostring(self.ac).."  ToHit "..tostring(self.tohit))
	self:memorial_print("")
	self:memorial_print("-- Spells ----------------------------------------------------")
	self:memorial_print("")
	local count = 0
	for i,v in ipairs( spells ) do
		if ( self.spells[i] > 0 ) then
			self:memorial_print("  "..v.name.." level "..self.spells[i])
			count = count + 1
		end
	end
	if count == 0 then
		self:memorial_print("  < NONE >")
	end
	self:memorial_print("")
	self:memorial_print("-- Equipment -------------------------------------------------")
	self:memorial_print("")
	for i=1,ITEMS_EQ do
		local item = player.eq[i]
		if item then
			item:identify()
			self:memorial_print("  [ "..self:slot_name(i).." ] "..item:get_name( 2 ))
		else
			self:memorial_print("  [ "..self:slot_name(i).." ] nothing")
		end
	end
	self:memorial_print("")
	self:memorial_print("-- Quickslots ------------------------------------------------")
	self:memorial_print("")
	for i=1,ITEMS_QS do
		local item = player.qs[i]
		if item then
			self:memorial_print("  [ Slot"..tostring(i).." ] "..item:get_name( 2 ))
		end
	end
	self:memorial_print("")
	self:memorial_print("-- Inventory -------------------------------------------------")
	self:memorial_print("")
	count = 0
	for item in self:items() do
		if self:is_backpack( item ) then
			count = count + 1
			item:identify()
			self:memorial_print("  "..item:get_name( 2 ) )
		end
	end
	if count == 0 then
		self:memorial_print("  < EMPTY >")
	end
	self:memorial_print("")
	self:memorial_print("-- Kills -----------------------------------------------------")
	self:memorial_print("")
	count = 0
	for _,m in ipairs( npcs ) do
		if m.flags[ nfUnique ] and player:get_kills( m.id ) > 0 then
			self:memorial_print("  "..m.name)
			count = count + 1
		end
	end
	if count > 0 then self:memorial_print("") end

	count = 0
	for _,m in ipairs( npcs ) do
		if not m.flags[ nfUnique ]  then
			local kills = player:get_kills( m.id )
			if kills > 0 then
				self:memorial_print("  "..tostring(kills).." * "..m.name)
				count = count + 1
			end
		end
	end

	self:memorial_print("")
	self:memorial_print("-- Messages --------------------------------------------------")
	self:memorial_print("")
	self:memorial_dumpmsg(20)
	self:memorial_print("")
	self:memorial_print("--------------------------------------------------------------")
	self:memorial_print("")
	return score
end


player.eq  = {}
setmetatable(player.eq, {
	__newindex = function (_, key, value)
		if type(key) == "string" then key = _G["SLOT_"..string.upper(key)] end
		player:eq_set(key, value)
	end,
	__index = function (_, key)
		if type(key) == "string" then key = _G["SLOT_"..string.upper(key)] end
		return player:eq_get( key )
	end,
})

player.qs  = {}
setmetatable(player.qs, {
	__newindex = function (_, key, value)
		player:qs_set(key, value)
	end,
	__index = function (_, key)
		return player:qs_get( key )
	end,
})

player.quest = {}
setmetatable(player.quest, {
	__newindex = function ( _, key, value )
		if type(key) == "string" then key = quests[key].nid end
		player:quest_set( key, value )
	end,
	__index = function (_, key)
		if type(key) == "string" then key = quests[key].nid end
		return player:quest_get( key )
	end,
})

player.spells  = {}
setmetatable(player.spells, {
	__newindex = function (_, key, value)
		if type(key) == "string" then key = spells[key].nid end
		player:spell_set( key, value )
	end,
	__index = function (_, key)
		if type(key) == "string" then key = spells[key].nid end
		return player:spell_get( key )
	end,
})

function player:items()
	return self:children("item")
end

table.merge( player, npc )
setmetatable(player,getmetatable(npc))

function level:move_walls(s)
	if cells[s] then
		while true do
			local c = self:find_tile(s)
			if not c then break	end
			self:set_cell( c, "floor" )
		end
	end
end

function level:lever_action(c,n)
	ui.play_sound("sfx/items/lever.wav",c)
	self:move_walls("moving_wall_" .. n)
	self:move_walls("moving_grate_" .. n)
end

function level:random_shrine()
	local shrines = {}
	for _,n in ipairs(cells) do
		if n.is_shrine then
			if n.minl <= self.depth and n.maxl >= self.depth then
				table.insert( shrines, n.id )
			end
		end
	end
	return( table.random_pick( shrines ) )
end

function level:roll_monster( id, c )
	local m, cc
	if c then
		cc = self:find_near_coord(c, 2, efNoItems, efNoMonsters)
	else
		cc = self:find_empty_coord("floor", efNoItems, efNoMonsters)
	end
	if cc then
		m = self:drop_npc(id, cc )
		return cc,m
	end
end

function level:roll_gold( c )
	local cc
	if c then
		cc = self:find_near_coord( c, 2, efNoItems, efNoMonsters )
	else
		cc = self:find_empty_coord( "floor", efNoItems, efNoMonsters )
	end
	if cc then
		self:drop_gold( cc )
	end
	return cc
end

function level:drop_unique( id, c )
	local unique = uniques[id]
	local base = table.random_pick( unique.base )
	local item = self:drop_item( base, c )
	item:apply_unique( unique )
end

function level:drop_gold( c, drop_level )
	-- The amount of gold dropped or found on the dungeon floor
	-- is determined by the formulas below:
	-- Normal difficulty	: 5*dlvl to 15*dlvl - 1
	-- Nightmare difficulty	: 5*(16 + dlvl) to 15*(16 + dlvl) - 1
	-- Hell difficulty		: 5*(32 + dlvl) to 15*(32 + dlvl) - 1
	-- On any hell dungeon level (dlvl 13-16) the amount of gold
	-- is increased by amount * 1.125
	-- Jarulf 3.8.3 "Gold"
	drop_level = drop_level or self.depth
	local item = self:drop_item( "gold", c )
	item.amount = math.random( 5 * drop_level, 15 * drop_level ) - 1
	if drop_level > 12 then
		item.amount = item.amount * 1.125
	end
end

-- item drop rules described in Jarulf 3.8.1
function level:drop_random_base(id,c,ilvl,mag_chance,unique_drop, curse_chance)
	local item = self:drop_item( id, c, ilvl )
	local itype = items[id].type

	if (itype == TYPE_AMULET or itype == TYPE_RING) then
		mag_chance = 100
	elseif (itype == TYPE_SCROLL or itype == TYPE_POTION or itype == TYPE_BOOK) then
		mag_chance = 0
	elseif (not mag_chance) then
		mag_chance = math.min( 11+(ilvl+1)*0.89, 100 )
	end

	local bMagic = math.random(100) <= mag_chance
	if (bMagic) then
		-- The probability of being unique
		-- is listed below depending on source.
		-- Unique monster	: 16%
		-- Other			: 2%
		-- Jarulf 3.8.2 "Is it unique?"
		local unique_chance = 2
		if (unique_drop) then
			ilvl = ilvl + 4
			unique_chance = 16
		end
		if (math.random(100) <= unique_chance) then
			-- try to find unique item of selected base type
			local item_table = items[id].uniques
			if item_table then
				for _,unique_id in ipairs(item_table) do
					if uniques[unique_id].level < ilvl then
						-- TODO: If multiple matches found, choose highest qlvl item that hasn't been created yet
						item:apply_unique(unique_id)
						return
					end
				end
			end
		end
	end

	if (itype == TYPE_STAFF) then
		-- chance of staff carrying spell is 75% (Jarulf p. 43)
		if math.random(100) <= 75 then
			-- pick spell based on ilvl
			local spell_list = {}
			for _,spell in ipairs(spells) do
				if spell.staff and spell.staff.level and spell.staff.level > 0 and spell.staff.level <= ilvl then
					table.insert(spell_list,spell)
				end
			end
			local spell = table.random_pick( spell_list )
			-- apply spell
			item.name       = items[item.id].name.." of "..spell.name
			item.spell      = spell.nid
			item.magreq     = spell.magic
			item.chargesmax = math.random(spell.staff.charges_min, spell.staff.charges_max)
			item.charges    = item.chargesmax
		else
			-- Jarulf 3.8.2 "Staves are always magical if they have no spell"
			bMagic = true
		end
	end

	if (bMagic) then
		-- TODO: Enforce minimum [ilvl/2] for chosen prefix & suffix
		utils.roll_magic( item, ilvl, nil, curse_chance )
	end
end

function level:drop_random_item( c, ilvl, mag_chance, unique_drop, curse_chance )
	-- Determination of base item
	local id
	if unique_drop or mag_chance == 100 then
		-- unique monster always drops magical item
		id = utils.random_item_req(ilvl, { type = { TYPE_BOOK, TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_HELM, TYPE_SHIELD, TYPE_ARMOR, TYPE_RING, TYPE_AMULET } } )
	else
		id = utils.random_item_req(ilvl)
	end
	self:drop_random_base(id,c,ilvl,mag_chance,unique_drop, curse_chance )
end

function level:drop_special( c )
	-- "Special Items" Jarulf 3.8 footnote 6; 3.8.1; and 3.8.3
	local item_set = {"potion_healing","potion_mana","scroll_town_portal"}
	utils.validate_items(item_set,self.depth)
	if (#item_set > 0) then
		self:drop_item( table.random_pick(item_set), c )
	end
end

function level:chest_drop( c, maxitems, magic)
	-- Jarulf 3.8.1 "Chest"
	ui.msg("You open the chest.")
	ui.play_sound('sfx/items/chest.wav',c)
	local itemcount
	if (magic) then
		itemcount = maxitems
	else
		itemcount = math.random(0,maxitems)
	end
	-- For each chest the probability of the items
	-- in them being created with varying ilvl is:
	-- Special item (ilvl = dlvl): 12.5%
	-- Non special item (ilvl = 2*dlvl): 87.5%
	-- If the chest is determined to have special items,
	-- all possible items will drop as special items.
	if (not magic and (math.random(8) == 1)) then
		while (itemcount > 0) do
			self:drop_special( c )
			itemcount = itemcount - 1
		end
	else
	-- For each possible item in a chest without special items,
	-- the probability is then as follows:
	-- Gold : 75%
	-- Item : 25%
		while (itemcount > 0) do
			if (not magic and (math.random(4) ~= 1)) then
				self:drop_gold( c )
			else
				if (magic) then
					magic = 100
				end
				self:drop_random_item( c, self.depth * 2,magic)
			end
			itemcount = itemcount - 1
		end
	end
end

function level:drop_skeleton( c )
	if skeletons[self.depth] then
		local skel_table = skeletons[self.depth]
		if (#skel_table > 0) then
			local skeleton = self:drop_npc(table.random_pick(skel_table), c )
			skeleton.scount = 20
		end
	end
end

function level:barrel_drop( c )
	-- Skeleton	: 20%
	-- Gold		: 10%
	-- Special	: 6.7%
	-- Item		: 3.3%
	-- Nothing	: 60%
	-- Jarulf 3.8.1 "Barrels, pods and urns"
	local drop = math.random(30)
	if ( drop == 1 ) then
		self:drop_random_item( c, self.depth * 2)
	elseif ( drop <= 3 ) then
		self:drop_special( c )
	elseif ( drop <= 6 ) then
		self:drop_gold( c )
	elseif ( drop <= 12 ) then
		self:drop_skeleton( c )
	end
end

function level:sarcophagus_drop( c )
	-- Skeleton	: 20%
	-- Gold		: 22.5%
	-- Item		: 7.5%
	-- Nothing	: 50%
	-- Jarulf 3.8.1 "Sarcophagus"
	local drop = math.random(200)
	if drop <= 40 then
		self:drop_skeleton( c )
	elseif drop <= 85 then
		self:drop_gold( c )
	elseif drop <= 100 then
		self:drop_random_item( c, self.depth * 2)
	end
end

function level:decapitated_drop( c )
	-- Gold	: 75%
	-- Item	: 25%
	-- Jarulf 3.8.1 "Decapitated bodies"
	local drop = math.random(4)
	if drop <= 3 then
		self:drop_gold( c )
	else
		self:drop_random_item( c, self.depth * 2 )
	end
end

function level:weapon_rack_drop( c, drop_level )
	-- Axe		: 25%
	-- Bow		: 25%
	-- Club		: 25%
	-- Sword	: 25%
	-- Jarulf 3.8.1 "Weapon rack"
	--
	-- The probability of being magical:
	-- Weapon rack: 100%
	-- Jarulf 3.8.2 "Is it magical?"
	local itype = table.random_pick({"axe", "bow", "club", "sword"})
	local ilvl = self.depth*2
	local id = utils.random_item_req(ilvl,{ type = {TYPE_BOW,TYPE_WEAPON}, weapontype = itype })
	self:drop_random_base(id,c,ilvl,100,false,true)
end

function level:armor_rack_drop( c, drop_level )
	-- dlvl 5:		light armor
	-- dlvl 6-9:	medium armor
	-- dlvl 10-15:	heavy armor
	-- Jarulf 3.8.1 "Armor rack"
	--
	-- The probability of being magical:
	-- Armor rack on dlvl 5 and 13-15: 100%
	-- Armor rack on dlvl 6-9: (55.5 + 0.445*(ilvl+1))%
	-- Armor rack on dlvl 10-12: (11 + 0.89*(ilvl+1))%
	-- Jarulf 3.8.2 "Is it magical?"
	local itype = "light"
	local mag_chance = 100
	local curse_chance = 0
	local ilvl = self.depth*2
	if self.depth > 9 then
		itype = "heavy"
		mag_chance = math.min(math.floor(11+0.89*(ilvl+1)),100)
		curse_chance = 33
	elseif self.depth > 6 then
		itype = "medium"
		mag_chance = math.min(math.floor(55.5+0.445*(ilvl+1)),100)
		curse_chance = 17
	end
	local id = utils.random_item_req(ilvl,{ type = {TYPE_ARMOR}, armortype = itype })
	self:drop_random_base(id,c,ilvl,mag_chance,curse_chance)
end

function level:drop_random_book( c )
	self:drop_item( utils.random_item_req( self.depth * 2, { type = TYPE_BOOK } ),c )
end

function level:bookcase_drop( c )
	-- Book		: 100%
	-- Jarulf 3.8.1 "Bookcase"
	self:drop_random_book(c)
end

function level:book_drop( c )
	-- Book		: 20%
	-- Scroll	: 80%
	-- Jarulf 3.8.1 "Library book and skeleton tome"
	if (math.random(5) == 1) then
		self:drop_random_book(c)
	else
		-- Jarulf 3.8.1: scroll drops from library book and skeleton tome are limited to this set
		local scroll_set = {'scroll_apocalypse','scroll_healing','scroll_identify',
			'scroll_infravision','scroll_nova','scroll_mana_shield','scroll_phasing',
			'scroll_teleport','scroll_town_portal'}
		utils.validate_items(scroll_set,self.depth * 2)
		if (#scroll_set > 0) then
			self:drop_item( table.random_pick(scroll_set), c )
		end
	end
end

function level:drop_random_potion( c )
	local potion_set = {'potion_healing', 'potion_mana', 'potion_rejuvenation',
			'potion_full_healing', 'potion_full_mana', 'potion_full_rejuvenation'}
	utils.validate_items(potion_set,self.depth * 2)
	if (#potion_set > 0) then
		self:drop_item( table.random_pick(potion_set), c )
	end
end

table.merge( level, thing )
setmetatable( level, getmetatable(thing) )

function world.refresh_shops()
	for _,shop in ipairs(shops) do
		shop.OnRefill( world.get_shop( shop.id ) )
	end
end

function world.shop( id )
	return shops[id].OnEnter( world.get_shop( id ) )
end

function world.load_quest_maps()
	  -- Adjust level maps for applicable quests
	for _,q in ipairs(quests) do
		if (q.enabled and q.map) then
			local l = levels[q.level]
			l.map = q.map
			l.map_key = q.map_key
		end
	end
end

function ui.msg_confirm(msg)
	ui.msg(msg.." [y/n]")
	while true do
		local key = ui.get_key()
		if key == string.byte("y") or key == string.byte("Y") then return true end
		if key == string.byte("n") or key == string.byte("N") then return false end
	end
end

--TODO: remove randomness
function ui.gossip( id, topic )
  if not topic then
	if npcs[id] and npcs[id].gossip then
		local i = math.random(#npcs[id].gossip)
		if (npcs[id].gossip[i].wav) then
			ui.play_sound("sfx/towners/" .. npcs[id].gossip[i].wav)
		end
		ui.plot_talk( npcs[id].gossip[i].text )
	end
  else
	if quests[topic] and quests[topic].gossip and quests[topic].gossip[id] then
		if (quests[topic].gossipwav[id]) then
			ui.play_sound("sfx/towners/" .. quests[topic].gossipwav[id])
		end
		ui.plot_talk( quests[topic].gossip[id] )
	end
  end
end

function ui.shop( id, desc, mode )
	if mode ~= nil then
		return ui.shop_run( id, desc, mode )
	else
		return ui.shop_run( id, desc )
	end
end


function ui.talk( id, talk_table )
	local topics  = {}
	local actions = {}
	for _,v in ipairs(talk_table) do
		table.insert(topics,v[1])
		table.insert(actions,v[2])
	end
	while true do
		local result = ui.talk_run( npcs[id].name, unpack(topics) )
		if (result == 0) or (actions[result] == false) then break end
		ui.play_sound('sfx/items/titlslct.wav')
		actions[result]()
	end
end

function ui.talk_topics( id )
	local talk_table = {}
	if npcs[id].gossip then
		table.insert(talk_table,{ "Gossip", function() ui.gossip(id) end })
	end
	for _,q in ipairs(quests) do
		if q.gossip and q.gossip[id] then
			local qv = player.quest[q.id]
			if qv ~= 0 and qv < q.completed then
				table.insert(talk_table,{ q.name, function() ui.gossip(id,q.id) end })
			end
		end
	end
	table.insert(talk_table,{ "Back", false })
	ui.talk( id, talk_table )
end

core.declare("utils", {})

function utils.proto_reqs_met( proto, reqs )
	if not reqs then return true end
	for k,r in pairs( reqs ) do
		local pv   = proto[k]
		local rist = ( type(r) == "table" )
		local pist = ( type(pv) == "table" )

		if rist and r[1] and type( r[1] ) ~= "boolean" then
			r = table.toset( r )
			reqs[k] = r
		end

		if pist then
			if rist then
				for req,_ in pairs( r ) do
					if not pv[ req ] then return false end
				end
			else
				if not pv[ r ] then return false end
			end
		else
			if rist then
				if not r[ pv ] then return false end
			else
				if pv ~= r then return false end
			end
		end
	end
	return true
end

function utils.random_item_req(ilvl, reqs)
	local item_table = utils.random_item_table(ilvl)

	-- filter list
	local list = {}
	if reqs then
		for _,item_id in ipairs(item_table) do
			if utils.proto_reqs_met( items[item_id], reqs ) then
				table.insert(list,item_id)
			end
		end
	else
		list = item_table
	end

	-- sanity check
	if #list == 0 then
		error("random_item_reqs("..ilvl.."), generated an empty set!")
	end

	-- return random item
	return table.random_pick(list)
end

function utils.get_value( v, ... )
	local t = type(v)
	if t == "function" then
		return v(...)
	elseif t == "table" then
		local size = #t
		if size == 2 then
			return math.random(t[1],t[2])
		elseif size == 1 then
			return t[1]
		elseif size == 0 then
			return nil
		else
			return t[math.random(#t)]
		end
	else
		return t
	end
end

-- validate_items: remove invalid items from a list
-- item_list - table of item ids
-- ilvl - maximum item level
function utils.validate_items(item_list,ilvl)
	-- iterate in reverse so that remove doesn't mess it up
	for i = #item_list, 1, -1 do
		local id = item_list[i]
		if ((items[id] == nil) or (items[id].level > ilvl)) then
			table.remove(item_list,i)
		end
	end
end

function utils.random_item_table(ilvl)
	if ilvl <  1 then ilvl = 1  end
	if ilvl > 25 then ilvl = 25 end

	if items["__table"..ilvl] then
		return items["__table"..ilvl]
	end

	local result = {}
	for _,v in ipairs(items) do
		if v.level <= ilvl then
			for _ = 1, v.random_weight do
				table.insert( result, v.id )
			end
		end
	end

	items["__table"..ilvl] = result
	return result
end

function utils.random_fix(fixes, itype, minl, maxl, curse_chance, fix)
	local list = {}
	curse_chance = curse_chance or 33
	local no_curse = math.random(100) >= curse_chance
	for _,v in ipairs(fixes) do
		if v.level >= minl and v.level <= maxl then
			if v.occurence[ itype ] then
				local cursed = v.flags[ ifCursed ]
				if cursed == nil then cursed = false end
				if no_curse ~= cursed then
					local valid = true
					if fix and fix.incompat then
						for _,id in pairs(fix.incompat) do
							if id == v.id then
								valid = false
								break
							end
						end
					end
					if valid then
						table.insert(list,v)
						if v.dbl_chance then
							table.insert(list,v)
						end
					end
				end
			end
		end
	end
	if #list == 0 then
		if not no_curse then
			return utils.random_fix(fixes, itype, minl, maxl, 0)
		else
			return false
		end
	else
		return table.random_pick( list )
	end
end

function utils.roll_magic(it, minl, maxl, curse_chance)
	-- Below are the probabilities for an item having a prefix,
	-- a suffix, or both of them.
	-- Prefix only		: 20.8%
	-- Suffix only		: 62.5%
	-- Prefix and suffix: 16.7%
	-- Jarulf 3.8.3 "Magical item"
	if maxl == nil then
		maxl = minl
		minl = math.min(math.floor(maxl / 2),25)
	end

	local prefix = false
	local suffix = false
	local itype = items[it.id].type
	local roll = math.random(100)
	-- The chances for what type the staff will be is as follows:
	-- Chance for having spell: 75%
	-- Chance for having prefix if it has a spell: 10%
	--
	-- Staves that do not have a spell, are treated
	-- the same way as any other magical item.
	-- However, if they have a spell, they follow the ranges below:
	-- qlvl for prefix with spell from unique and special monster: 1 to ilvl+4
	-- qlvl for prefix with spell from all other sources: 1 to ilvl
	-- Jarulf 3.8.3 "Staff"
	if ( itype == TYPE_STAFF ) and ( it.spell ~= 0 ) then
		prefix = utils.random_fix( prefixes, TYPE_SSTAFF, minl, maxl, curse_chance )
	elseif roll <= 21 then
		prefix = utils.random_fix( prefixes, itype, minl, maxl, curse_chance )
	elseif roll <= 84 then
		suffix = utils.random_fix( suffixes, itype, minl, maxl, curse_chance )
	else
		prefix = utils.random_fix( prefixes, itype, minl, maxl, curse_chance )
		suffix = utils.random_fix( suffixes, itype, minl, maxl, curse_chance, prefix )
	end

	if prefix then it:apply_fix( prefix ) end
	if suffix then it:apply_fix( suffix ) end
end

function utils.try_roll_magic( item, ilvl, chance, curse_chance )
	local itype = items[item.id].type

	if itype == TYPE_STAFF and item.spell ~= 0 then
		chance = 10
	elseif itype == TYPE_AMULET or itype == TYPE_RING then
		chance = 100
	end
	if math.random(100) <= chance then
		utils.roll_magic( item, ilvl, nil, curse_chance )
	end
end
