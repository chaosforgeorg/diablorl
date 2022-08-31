core.register_blueprint( "shrine", "cell" )
{
	flags        = { false, core.TFLAGS, { cfBlockMove, cfBlockChange } },
	color        = { false, core.TNUMBER, WHITE },
	pic          = { false, core.TSTRING, "_" },
	minl         = { false, core.TNUMBER, 1 },
	maxl         = { false, core.TNUMBER, 15 },
	is_shrine    = true,
	OnAct        = { true,  core.TFUNC },
}

register_cell "visited_shrine"
{
	name  = "visited shrine",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "_",
	color = LIGHTGRAY,
}

register_cell( "abandoned_shrine", "shrine" )
{
	name = "abandoned shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<The hands of men may be guided by fate.@>")
		player.dex = math.min(player.dex + 2, klasses[player.klass].maxdex)
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "creepy_shrine", "shrine" )
{
	name = "creepy shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Strength is bolstered by heavenly faith.@>")
		player.str = math.min(player.str + 2, klasses[player.klass].maxstr)
		self:set_cell( c, "visited_shrine" )
	end,
}
--[[
register_cell( "cryptic_shrine", "shrine" )
{
	name = "cryptic shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Arcane power brings destruction.@>")
		player.mp = player.mpmax
		--To do:
		--cast Nova spell of level (dungeon_level div 4 + 2)
		self:set_cell( c, "visited_shrine" )
	end,
}
]]
register_cell( "divine_shrine", "shrine" )
{
	name = "divine shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Drink and be refreshed.@>")
		player.hp = player.hpmax
		player.mp = player.mpmax
		if self.depth < 4 then
			self:drop_item("potion_full_healing",c)
			self:drop_item("potion_full_mana",c)
		else
			self:drop_item("potion_full_rejuvenation",c)
			self:drop_item("potion_full_rejuvenation",c)
		end
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "eerie_shrine", "shrine" )
{
	name = "eerie shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Knowledge and wisdom at the cost of self.@>")
		player.mag = math.min(player.mag + 2,klasses[player.klass].maxmag)
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "eldritch_shrine", "shrine" )
{
	name = "eldritch shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Crimson and Azure become as the sun.@>")
		for i,pot in pairs({ 'healing', 'mana' }) do
			local pitem
			repeat
				pitem = player:get_item("potion_"..pot)
				if pitem then
					pitem:destroy()
					player:add_item( "potion_rejuvenation" )
				end
			until not pitem
			repeat
				pitem = player:get_item("potion_full_"..pot)
				if pitem then
					pitem:destroy()
					player:add_item( "potion_full_rejuvenation" )
				end
			until not pitem
		end
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "enchanted_shrine", "shrine" )
{
	name = "enchanted shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Magic is not always what it seems to be.@>")
		local _spells_ = {}

		for i = 1, #spells do
			if player.spells[i] > 0 then table.insert(_spells_, i) end
		end
		if #_spells_ == 0 then return end

		local _spell_ = math.random(#_spells_)
		local _loss_  = 1
		if self.depth > 14 then _loss_ = 2 end

		for i = 1, #_spells_ do
			if i == _spell_ then
				player.spells[_spells_[i]] = math.max(0,player.spells[_spells_[i]] - _loss_)
			else
				player.spells[_spells_[i]] = player.spells[_spells_[i]] + 1
			end
		end
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "fascinating_shrine", "shrine" )
{
	name = "fascinating shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Intensity comes at the cost of wisdom.@>")
		player.mpmod = player.mpmod - math.max(1,math.floor(player.mpmax / 10))
		player.spells["firebolt"] = player.spells["firebolt"] + 2
		self:set_cell( c, "visited_shrine" )
	end,
}

--this shrine appear only on dungeon_level 1-8
register_cell( "glimmering_shrine", "shrine" )
{
	name = "glimmering shrine",
	maxl = 8,

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Mysteries are revealed in the light of reason.@>")
		for item in player:items() do
			item:identify()
		end
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "gloomy_shrine", "shrine" )
{
	name = "gloomy shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Those who defend seldom attack.@>")
		for item in player:items() do
			if item.itype == TYPE_WEAPON then
				item.dmgmin = math.max(1,item.dmgmin-1)
				item.dmgmax = math.max(1,item.dmgmax-1)
			elseif item.itype == TYPE_ARMOR or item.itype == TYPE_SHIELD or item.itype == TYPE_HELM then
				item.ac = item.ac + 2
			end
		end
		self:set_cell( c, "visited_shrine" )
	end,
}
--[[
register_cell( "hidden_shrine", "shrine" )
{
	name = "hidden shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<New strength is forged through destruction.@>")
		local _items_ = {}
		for i = 1, ITEMS_EQ do
			if player.eq[i] and player.eq[i].durmax > 0 then
				table.insert(_items_, i)
			end
		end
		if #_items_ == 0 then return end

		local _item_ = math.random(#_items_)
		for i = 1, #_items_ do
			if i == _item_ then
				player.eq[ _items_[i] ].durmax = math.max(1, player.eq[_items_[i] ].durmax-20)
				player.eq[ _items_[i] ].dur = math.max(1, player.eq[_items_[i] ].dur-20)
			else
				player.eq[ _items_[i] ].durmax = player.eq[ _items_[i] ].durmax+10
				player.eq[ _items_[i] ].dur = player.eq[ _items_[i] ].dur+10
			end
		end
	end,
}
]]
register_cell( "holy_shrine", "shrine" )
{
	name = "holy shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic1.wav')
		ui.play_sound('sfx/misc/teleport.wav')
		ui.msg("@<Wherever you go, there you are.@>")
		player.mp = player.mpmax
		player:phasing()
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "magical_shrine", "shrine" )
{
	name = "magical shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.play_sound('sfx/misc/mshield.wav')
		ui.msg("@<While the spirit is vigilant, the body thrives.@>")
		player.mp = player.mpmax
		spells['mana_shield'].script(2*math.ceil(self.depth / 4), player )
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "mysterious_shrine", "shrine" )
{
	name = "mysterious shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Some are weakened as one grows strong.@>")
		local gain = math.random(4)
		for i,stat in pairs({'str','mag','dex','vit'}) do
			if i == gain then
				player[stat] = math.min(player[stat] + 5, klasses[player.klass]['max'..stat])
			else
				player[stat] = math.max(0, player[stat] - 1)
			end
		end
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "ornate_shrine", "shrine" )
{
	name = "ornate shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Salvation comes at the cost of wisdom.@>")
		player.mpmod = player.mpmod - math.max(1,math.floor(player.mpmax / 10))
		player.spells["holy_bolt"] = player.spells["holy_bolt"] + 2
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "quiet_shrine", "shrine" )
{
	name = "quiet shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<The essence of life flows from within.@>")
		player.vit = math.min(player.vit + 2, klasses[player.klass].maxvit)
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "religious_shrine", "shrine" )
{
	name = "religious shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Time cannot diminish the power of steel.@>")
		for item in player:items() do
			item.dur = item.durmax
		end
		self:set_cell( c, "visited_shrine" )
	end,
}
--[[
register_cell( "sacred_shrine", "shrine" )
{
	name = "sacred shrine",

	OnAct = function(c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Energy comes at the cost of wisdom.@>")
		player.mpmod = player.mpmod - math.max(1,math.floor(player.mpmax / 10))
		--To do:
		--player.spells["charged_bolt"] = player.spells["charged_bolt] + 2
		self:set_cell( c, "visited_shrine" )
	end,
}
]]
register_cell( "secluded_shrine", "shrine" )
{
	name = "secluded shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<The way is made clear when viewed from above.@>")
		self.light[ vlfExplored ] = true
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "spiritual_shrine", "shrine" )
{
	name = "spiritual shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<Riches abound when least expected.@>")
		local multiplier = math.ceil( self.depth / 4 )
		local amount = MaxVolume-player.volume
		if amount > 0 then
			for i=1,amount do
				player:add_gold(math.random(10*multiplier)+5*multiplier)
			end
		end
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "stone_shrine", "shrine" )
{
	name = "stone shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<The powers of mana refocused renews.@>")
		for item in player:items() do
			item.charges = item.chargesmax
		end
		self:set_cell( c, "visited_shrine" )
	end,
}
--[[
register_cell( "thaumaturgic_shrine", "shrine" )
{
	name = "thaumaturgic shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<What once was opened now is closed.@>")
	--To do:
    --refills all chests on the current level
		self:set_cell( c, "visited_shrine" )
	end,
}
]]
register_cell( "weird_shrine", "shrine" )
{
	name = "weird shrine",

	OnAct = function(self,c)
		ui.play_sound('sfx/items/magic.wav')
		ui.msg("@<The sword of justice is swift and sharp.@>")
		for item in player:items() do
			if item.itype == TYPE_WEAPON then
				item.dmgmax = item.dmgmax + 1
			end
		end
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "fountain_of_tears", "shrine" )
{
	name = "fountain of tears",
	color = LIGHTBLUE,

	OnAct = function(self,c)
		ui.play_sound('sfx/misc/fountain.wav')
		ui.msg("You drink from the fountain.")
		local stat1 = math.random(4)
		local stat2 = math.random(4)
		local stats = {'str','mag','dex','vit'}
		while stat1 == stat2 do stat2 = math.random(4) end
		player[stats[stat1]] = math.min(player[stats[stat1]] + 1, klasses[player.klass]['max'..stats[stat1]])
		player[stats[stat2]] = math.max(player[stats[stat2]] - 1, 0)
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "murky_pool", "shrine" )
{
	name = "murky pool",
	color = BROWN,

	OnAct = function(self,c)
		ui.play_sound('sfx/misc/fountain.wav')
		ui.play_sound('sfx/misc/infravis.wav')
		ui.msg("You drink from the pool.")
		spells['infravision'].script(2*math.ceil(self.depth / 4),player)
		self:set_cell( c, "visited_shrine" )
	end,
}

register_cell( "purifying_spring", "shrine" )
{
	name  = "purifying spring",
	color = BLUE,

	OnAct = function(self,c)
		ui.play_sound('sfx/misc/fountain.wav')
		ui.msg("You drink from the spring.")
		player.mp = math.min( player.mp+1, player.mpmax )
	end,
}

register_cell( "blood_fountain", "shrine" )
{
	name  = "blood fountain",
	color = RED,

	OnAct = function(self,c)
		ui.play_sound('sfx/misc/fountain.wav')
		ui.msg("You drink from the fountain.")
		player.hp = math.min( player.hp+1, player.hpmax )
	end,
}
