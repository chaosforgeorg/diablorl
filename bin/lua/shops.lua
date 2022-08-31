core.register_blueprint "shop"
{
	id          = { true,  core.TSTRING },
	name        = { true,  core.TSTRING },
	size        = { true,  core.TNUMBER },

	OnRefill    = { true,  core.TFUNC },
	OnEnter     = { false, core.TFUNC },

	funcs       = { false, core.TTABLE }, -- hack
}


register_shop "griswold_shop"
{
	name = "Buying at Griswold",
	size = 10,

	OnRefill = function( self )
		local lvl = math.min( 16, math.max( 6, player.maxdepth ) )
		self:clear()
		local count = math.random(8,10)
		for i=1,count do
			local sitem
			repeat
				if sitem then sitem:destroy() end
				sitem = item.new( utils.random_item_req( lvl, { type = { TYPE_WEAPON, TYPE_STAFF, TYPE_HELM, TYPE_SHIELD, TYPE_ARMOR } } ) )
			until sitem.price > 0 and sitem.spell == 0
			self.item[i] = sitem
			sitem:identify()
			sitem.dur = sitem.durmax
		end
		count = math.random(2,4)
		for i=self.amount+1,self.amount+count do
			local sitem
			repeat
				if sitem then sitem:destroy() end
				sitem = item.new( utils.random_item_req( lvl, { type = TYPE_BOW } ) )
			until sitem.price > 0 and sitem.spell == 0
			self.item[i] = sitem
			sitem:identify()
			sitem.dur = sitem.durmax
		end
		self:sort()
	end,

	OnEnter = function( self )
		repeat
			if self.amount == 0 then
				ui.msg( 'Griswold says "Sorry '..player:salutation()..', got nothing to sell right now."')
				return true
			else
				local bitem = ui.shop( self.id, "Buying at Griswold ("..player.gold.." gold left)" )
				if not bitem then return true end

				if bitem.volume + player.volume > MaxVolume then
					ui.msg( 'Griswold says "Sorry '..player:salutation()..', you have no room for that."')
				elseif bitem.price > player.gold then
					ui.msg( 'Griswold says "Sorry '..player:salutation()..', you have not enough money."')
				else
					player:remove_gold( bitem.price )
					ui.msg( 'You buy a '..bitem.name..' for '..bitem.price..' gold pieces.')
					player:add_item( bitem )
					self:nil_item( bitem )
					self:sort()
				end
			end
		until false
		return true
	end,
}

register_shop "griswold_premium_shop"
{
	name = "Buying at Griswold",
	size = 6,

	OnRefill = function ( self )
		local lvl = player.level
		for i = 1, math.min(6,(player.level-self.level)*2) do
		  self.item[i] = "" end
		if lvl ~= self.level then self.item[1] = nil end
		self.level = lvl
		for i=1,6 do
			if i == 6 then lvl = lvl + 1 end
			if not self.item[i] ~= nil then
				local sitem
				repeat
					if sitem then sitem:destroy() end
					sitem = item.new( utils.random_item_req( lvl, { type = { TYPE_WEAPON, TYPE_BOW, TYPE_HELM, TYPE_SHIELD, TYPE_ARMOR, TYPE_RING, TYPE_AMULET } } ) )
					utils.roll_magic( sitem, lvl / 2, lvl, 0 )
				until sitem.level > lvl / 4 and
					sitem.price > 0 and
					sitem.spell == 0 and
					sitem.flags[ ifMagic ]
				self.item[i] = sitem
				sitem:identify()
				sitem.dur = sitem.durmax
			end
		end
		self:sort()
	end,

	OnEnter = function( self )
		repeat
			if self.amount == 0 then
				ui.msg( 'Griswold says "Sorry '..player:salutation()..', got nothing premium to sell right now."')
				return true
			else
				local bitem = ui.shop( self.id, "Buying at Griswold ("..player.gold.." gold left)" )
				if not bitem then return true end

				if bitem.volume + player.volume > MaxVolume then
					ui.msg( 'Griswold says "Sorry '..player:salutation()..', you have no room for that."')
				elseif bitem.price > player.gold then
					ui.msg( 'Griswold says "Sorry '..player:salutation()..', you have not enough money."')
				else
					player:remove_gold( bitem.price )
					ui.msg( 'You buy a '..bitem.name..' for '..bitem.price..' gold pieces.')
					player:add_item( bitem )
					self:nil_item( bitem )
					shops[self.id].OnRefill( world.get_shop(self.id) )
				end
			end
		until false
		return true
	end,
}

register_shop "pepin_shop"
{
	name = "Buying at Pepin",
	size = 12,

	OnRefill = function( self )
		self:clear()
		self:add_item( "potion_healing" )
		self:add_item( "potion_full_healing" )
		for i=1,5 do
			self:add_item( "potion_rejuvenation" )
		end
		for i=1,5 do
			self:add_item( "scroll_healing" )
		end
		self:sort()
	end,

	OnEnter = function( self )
		-- Pepin always has something to sell
		repeat
			local bitem = ui.shop( self.id, "Buying at Pepin ("..player.gold.." gold left)" )
			if not bitem then return true end

			if bitem.volume + player.volume > MaxVolume then
				ui.msg( 'Pepin says "Sorry '..player:salutation()..', you have no room for that."')
			elseif bitem.price > player.gold then
				ui.msg( 'Pepin says "Sorry '..player:salutation()..', you have not enough money."')
			else
				player:remove_gold( bitem.price )
				ui.msg( 'You buy a '..bitem.name..' for '..bitem.price..' gold pieces.')
				if bitem.id == "potion_healing" or bitem.id == "potion_full_healing" then
					player:add_item( bitem.id )
				else
					player:add_item( bitem )
					self:nil_item( bitem )
					self:sort()
				end
			end
		until false
		return true
	end,

}

register_shop "adria_shop"
{
	name = "Buying at Adria",
	size = 12,

	OnRefill = function( self )
		local lvl = math.min( 16, math.max( 6, player.maxdepth ) )
		self:clear()
		self:add_item("potion_mana")
		self:add_item("potion_full_mana")
		self:add_item("scroll_town_portal")
		local count = math.random(3)+6
		for i = 1,count do
			self:add_item( utils.random_item_req( lvl, { type = TYPE_SCROLL } ))
		end
		local count = math.random(5)-2
		if count > 0 then
			for i=1, count do
				self:add_item( utils.random_item_req( lvl, { type = TYPE_BOOK } ))
		end end
		count = math.random(5)-2
		if count > 0 then
			for i = self.amount +1, self.amount+count do
				local sitem
				repeat
					if sitem then sitem:destroy() end
					sitem = item.new( utils.random_item_req( lvl, { type = TYPE_STAFF } ) )
					if math.random(3) ~= 2 then
						utils.roll_magic( sitem, lvl / 2, lvl, 0 )
					end
				until sitem.level > lvl / 4 and sitem.price > 0 and
					(sitem.spell ~= 0 or sitem.flags[ ifMagic ])
				self.item[i] = sitem
				sitem:identify()
				sitem.dur = sitem.durmax
			end
		end
		self:sort()
	end,

	OnEnter = function( self )
		repeat
			local bitem = ui.shop( self.id, "Buying at Adria ("..player.gold.." gold left)" )
			if not bitem then return true end

			if bitem.volume + player.volume > MaxVolume then
				ui.msg( 'Adria says "Sorry '..player:salutation()..', you have no room for that."')
			elseif bitem.price > player.gold then
				ui.msg( 'Adria says "Sorry '..player:salutation()..', you have not enough money."')
			else
				player:remove_gold( bitem.price )
				ui.msg( 'You buy a '..bitem.name..' for '..bitem.price..' gold pieces.')
				if bitem.id == "potion_mana" or bitem.id == "potion_full_mana" or bitem.id == "scroll_town_portal" then
					player:add_item( bitem.id )
				else
					player:add_item( bitem )
					self:nil_item( bitem )
					self:sort()
				end
			end
		until false
		return true
	end,
}

register_shop "wirt_shop"
{
	name = "Buying at Wirt",
	size = 12,

	OnRefill = function( self )
		local wirt_filter = {
			KlassWarrior = {TYPE_WEAPON, TYPE_ARMOR, TYPE_HELM, TYPE_SHIELD, TYPE_RING, TYPE_AMULET },
			KlassRogue   = {TYPE_BOW, TYPE_ARMOR, TYPE_HELM, TYPE_RING, TYPE_AMULET},
			KlassSorceror= {TYPE_STAFF, TYPE_ARMOR, TYPE_HELM, TYPE_RING, TYPE_AMULET},
		}
		wirt_filter = wirt_filter[ player.klass ]

		local lvl = player.level
		if not self.item[1] ~= nil or lvl ~= self.level then
			local witem = nil
			repeat
				if witem then witem:destroy() end
				witem = item.new( utils.random_item_req( lvl, { type = wirt_filter } ) )
				utils.roll_magic( witem, math.min(lvl,25), 2*lvl, 0 )
			until witem.level > lvl / 4 and witem.price > 0 and
				witem.price <= 90000 and witem.spell == 0 and
				witem.flags[ ifMagic ] and not witem.flags[ ifCursed ]
			self.item[1] = witem
			witem:identify()
			witem.dur = witem.durmax
			self.level = lvl
		end
	end,

	OnEnter = function( self )
		if self.amount == 0 then
			ui.msg('Wirt says "Sorry '..player:salutation()..', come back later."')
		elseif player:remove_gold( 50 ) then
			local bitem = ui.shop( self.id, "Buying at Wirt ("..player.gold.." gold left)" )
			if not bitem then return true end

			if bitem.volume + player.volume > MaxVolume then
				ui.msg( 'Wirt says "Sorry '..player:salutation()..', you have no room for that."')
			elseif bitem.price > player.gold then
				ui.msg( 'Wirt says "Sorry '..player:salutation()..', you have not enough money."')
			else
				player:remove_gold( bitem.price )
				ui.msg( 'You buy a '..bitem.name..' for '..bitem.price..' gold pieces.')
				player:add_item( bitem )
				self:nil_item( bitem )
				self:sort()
			end
		else
			ui.msg('Wirt says "Sorry '..player:salutation()..', you have not enough money."')
		end
		return true
	end,
}

-- This is a hack, and probably should be cleaned up
register_shop "util"
{
	name = "",
	size = ITEMS_SHOP,

	OnRefill = function( self ) end,
	OnEnter  = function( self ) end,

	funcs = {
		GriswoldSell = function( self )
			repeat
				self:clear()
				for bitem in player:items() do
					if player:is_backpack( bitem ) then
						for _,j in pairs({TYPE_WEAPON, TYPE_ARMOR, TYPE_SHIELD, TYPE_HELM, TYPE_RING, TYPE_AMULET, TYPE_BOW}) do
							if j == bitem.itype then
								self:add_item(bitem)
							end
						end
					end
				end
				local bitem = ui.shop( self.id, "Selling items", SHOP_SELL )
				if not bitem then
					self:nil_item()
					return true
				end
				local price = bitem:get_price(2)
				ui.msg( 'You sold a '..bitem.name..' for '..price..' gold pieces.')
				bitem:destroy()
				self:nil_item()
				local leftover = player:add_gold( price )
				while leftover > 0 do
					local level = player:get_level()
					local gold_drop = level:drop_item( "gold", player.position )
					gold_drop.amount = math.min(leftover, 5000)
					leftover = leftover - 5000
				end
			until false
			return true
		end,

		GriswoldRepair = function( self )
			repeat
				self:clear()
				for bitem in player:items() do
					for _,j in pairs({TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_ARMOR, TYPE_HELM, TYPE_SHIELD}) do
						if j == bitem.itype then
							if bitem:get_price(3) > 0 then
								self:add_item(bitem)
							end
						end
					end
				end
				local bitem = ui.shop( self.id, "Repair an item ("..player.gold.." gold left)", SHOP_REPAIR )
				if not bitem then
					self:nil_item()
					return true
				end
				local price = bitem:get_price(3)
				if price > player.gold then
					ui.msg( 'Griswold says "Sorry '..player:salutation()..', you have not enough money."')
				else
					bitem:repair()
					ui.msg( 'Griswold repaired '..bitem.name..' for '..price..' gold pieces.')
					player:remove_gold( price )
				end
				self:nil_item()
			until false
			return true
		end,

		AdriaSell = function( self )
			repeat
				self:clear()
				for bitem in player:items() do
					for _,j in pairs({TYPE_POTION, TYPE_SCROLL, TYPE_STAFF, TYPE_BOOK}) do
						if player:is_backpack( bitem ) then
							if j == bitem.itype then
								self:add_item(bitem)
							end
						end
					end
				end
				local bitem = ui.shop( self.id, "Selling items", SHOP_SELL )
				if not bitem then
					self:nil_item()
					return true
				end
				local price = bitem:get_price(2)
				ui.msg( 'You sold a '..bitem.name..' for '..price..' gold pieces.')
				bitem:destroy()
				self:nil_item()
				local leftover = player:add_gold( price )
				while leftover > 0 do
					local level = player:get_level()
					local gold_drop = level:drop_item( "gold", player.position )
					gold_drop.amount = math.min(leftover, 5000)
					leftover = leftover - 5000
				end
			until false
			return true
		end,

		AdriaRecharge = function( self )
			repeat
				self:clear()
				for bitem in player:items() do
					if bitem.itype == TYPE_STAFF then
						if bitem:get_price(4) > 0 then
							self:add_item(bitem)
						end
					end
				end
				local bitem = ui.shop( self.id, "Recharge an item ("..player.gold.." gold left)", SHOP_RECHARGE )
				if not bitem then
					self:nil_item()
					return true
				end
				local price = bitem:get_price(4)
				if price > player.gold then
					ui.msg( 'Adria says "Sorry '..player:salutation()..', you have not enough money."')
				else
					bitem:recharge()
					player:remove_gold( price )
					ui.msg( 'Adria recharged '..bitem.name..' for '..price..' gold pieces.')
				end
				self:nil_item()
			until false
			return true
		end,

		CainIdentify = function( self )
			repeat
				self:clear()
				for bitem in player:items() do
					if bitem.flags[ifUnknown] then
						self:add_item(bitem)
					end
				end
				local bitem = ui.shop( self.id, "Identify an item ("..player.gold.." gold left)", SHOP_IDENTIFY )
				if not bitem then
					self:nil_item()
					return true
				end
				if player.gold < 100 then
					ui.msg( 'Cain says "Sorry '..player:salutation()..', you have not enough money."')
				else
					bitem:identify()
					player:remove_gold( 100 )
					ui.item_info(bitem)
				end
				self:nil_item()
			until false
			return true
		end,

		FreeRepair = function( self )
			self:clear()
			for bitem in player:items() do
				for _,j in pairs({TYPE_WEAPON, TYPE_BOW, TYPE_STAFF, TYPE_ARMOR, TYPE_HELM, TYPE_SHIELD}) do
					if j == bitem.itype then
						if bitem.dur < bitem.durmax then
							self:add_item(bitem)
						end
					end
				end
			end
			local bitem = ui.shop( self.id, "Repair an item", SHOP_REPAIRFREE )
			if not bitem then
				self:nil_item()
				return false
			end
			ui.play_sound( "sfx/misc/cast6.wav" )
			bitem:repair( player.level )
			ui.msg( 'You repaired '..bitem.name )
			player.scount = player.scount - klasses[player.klass].spdmag
			self:nil_item()
			return true
		end,

		FreeRecharge = function( self )
			ui.play_sound( "sfx/misc/cast6.wav" )
			self:clear()
			for bitem in player:items() do
				if bitem.itype == TYPE_STAFF then
					if bitem.charges < bitem.chargesmax then
						self:add_item(bitem)
					end
				end
			end
			local bitem = ui.shop( self.id, "Recharge an item", SHOP_RECHARGEFREE )
			if not bitem then
				self:nil_item()
				return false
			end
			bitem:recharge( player.level )
			if bitem.chargesmax > 0 then
				ui.msg( 'You recharged '..bitem.name )
			else
				ui.msg( 'You drained '..bitem.name )
			end
			player.scount = player.scount - klasses[player.klass].spdmag
			self:nil_item()
			return true
		end,

		FreeIdentify = function( self )
			self:clear()
			for bitem in player:items() do
				if bitem.flags[ifUnknown] then
					self:add_item(bitem)
				end
			end
			local bitem = ui.shop( self.id, "Identify an item", SHOP_IDENTIFYFREE )
			if not bitem then
				self:nil_item()
				return false
			end
			bitem:identify()
			ui.item_info(bitem)
			self:nil_item()
			return true
		end,
	}
}
