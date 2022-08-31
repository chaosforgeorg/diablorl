-- These algorithms (should be) based on Jarulf 5.5 Monster AI
-- especially 5.5.9 AI scripts
--
-- NOTE: LUA math.random(x) returns a number in the range 1 to x
-- Jarulf algorithms use Rnd[x] in the range 0 to x-1

core.declare("ai_scripts")
ai_scripts = {}

core.declare("AI")
function AI(id,props)
	ai_scripts[id] = props
end

AI(AINPC,{
	-- Default NPC AI does nothing
	-- Override OnAct in the NPC class
	OnAct = function()
	end,
})

AI(AIZombie,{
	OnAct = function(self)
		local intf = self.__proto.intf
		local roll = math.random(100) - 1
		local chance = 2*intf+10
		local dist_max = 2*intf+3

		if roll < chance then
			local target = self:target_closest( dist_max )
			if target then
				local dist = self:distance_to( target )
				if dist == 1 then
					self:attack( target )
				else
					self:seek( target )
				end
			else
				roll = math.random(100) - 1
				if roll < chance then
					local level = self:get_level()
					self.targetx, self.targety = level:find_nearest( self, efNoMonsters, efNoObstacles):get()
					if self.targetx*self.targety ~= 0 then
						self:seek( self:get_target() )
					end
				end
			end
		end
	end,
})

AI(AIFallenOne,{
	-- aistate
	--	0: general
	--	1: last action was delay
	--  2: war cry mode
	--	3: retreat mode
	-- aistate2
	--	retreat mode: distance left to walk
	--	war cry mode: time remaining
	OnCreate = function(self)
		self:add_property( "ai_state", "normal" )
		self:add_property( "ai_timer", 0 )
	end,
	OnAct = function(self)
		if self:is_active() then
			local target = self:target_closest(15)
			if not target then return end
			local npc = npcs[self.id]
			local intf = self.__proto.intf
			local scount = self.scount
			local roll
			if self.ai_state == "normal" or self.ai_state == "delay" then
				if scount == 100 then
					if math.random(4) == 1 then
						local level = self:get_level()
						-- Begin war cry
						-- TODO: self.play_sound to avoid repeating sound name formulation code from tnpc.play_sound
						ui.play_sound(npc.sound .. "s" .. math.random(2) .. ".wav",self.position)
						ui.msg(self:get_name(0)..' shouts!')
						-- activate all fallen within range (including self)
						level:broadcast_event(self,npc.warcrydistance,"war_cry")
						return
					end
				end
				roll = math.random(100) - 1
			elseif self.ai_state == "retreat" then
				-- retreat
				-- TODO: improve seek_away. it currently gives up when a wall is reached
				self:seek_away(target)
				self.ai_timer = self.ai_timer - 1
				if self.ai_timer == 0 then
					-- retreated enough, go back to normal
					self.ai_state = "normal"
				end
				return
			end

			local dist = self:distance_to( target )
			if dist <= 1 then
				if self.ai_state ~= "normal" or roll < 2*intf + 20 then
					-- attack target
					self:attack( target )
					if (self.ai_state == "delay") then
						self.ai_state = "normal"
					end
				else
					-- do delay
					self.ai_state = "delay"
					self.scount = scount - ((math.random(10) + 9 - 2*intf) * 5)
				end
			else
				if self.ai_state ~= "normal" or roll < 4*intf + 65 then
					-- move toward target
					self:seek(target)
					if self.ai_state == "delay" then
						self.ai_state = "normal"
					end
				else
					-- do delay
					self.ai_state = "delay"
					self.scount = scount - ((math.random(10) + 14 - 2*intf) * 5)
				end
			end

			if self.ai_state == "war_cry" then
				-- scount is the elapsed time of 1 tick + current action if any
				scount = 10 + (scount - self.scount)
				if (self.ai_timer <= scount) then
					-- war cry expired
					self.ai_state = "normal"
					self.ai_timer = 0
				else
					self.ai_timer = self.ai_timer - scount
				end
			end
		end
	end,

	OnBroadcast = function( self, event )
		if event == "war_cry" then
			if self.ai_state ~= "war_cry" then
				-- Enter war cry state
				self.ai_state = "war_cry"
				self.hp = math.min(self.hpmax,self.hp + 2*self.__proto.intf + 2)
				self.ai_timer = npcs[self.id].warcrytime
			end
		elseif event == "death_nerby" then
			if self.ai_state ~= "retreat" then
				-- Enter retreat state
				self.ai_state = "retreat"
				self.ai_timer = math.max( npcs[self.id].retreatdistance or 3, 3 )
			end
		end
	end,
})

AI(AISkeleton,{
	OnCreate = function(self)
		self:add_property( "ai_state", 0 )
	end,
	OnAct = function(self)
		if self:is_active() then
			local target = self:target_closest(15)
			if not target then return end
			local roll = math.random(100) - 1
			local intf = self.__proto.intf
			local dist = self:distance_to( target )
			if dist <= 1 and (self.ai_state == 1 or roll < 2*intf+20) then
				self:attack( target )
				self.ai_state = 0
				return
			end
			if dist > 1 and (self.ai_state == 1 or roll < 2*intf+65) then
				self:seek( target )
				self.ai_state = 0
				return
			end
			self.ai_state = 1
			self.scount = self.scount - ((math.random(10) + 9 - 2*intf) * 5)
		end
	end,
})

AI(AISkelArcher,{
	OnCreate = function(self)
		self:add_property( "ai_state", 0 )
	end,
	OnAct = function(self)
		if self:is_active() then
			local target = self:target_closest(15)
			if not target then return end
			local roll = math.random(100) - 1
			local intf = self.__proto.intf
			local dist = self:distance_to( target )
			local chance = 2 * intf + 13
			if dist <= 3 then
				if (self.ai_state == 0 and roll < chance + 50) or
					(self.ai_state > 1 and roll < chance) then
					self:seek_away( target )
					self.ai_state = 0
				end
				self.ai_state = math.min( self.ai_state + 1, 2 )
			elseif roll < chance then
				self:send_missile( MT_ARROW, target )
			end
		end
	end,
})

AI(AIScavenger,{
	-- aistate
	--	0: general
	--	1: last action was delay
	--	2: eating/digging
	-- aistate2: boolean true = carcass not found
	OnCreate = function(self)
		self:add_property( "ai_state", "normal" )
		self:add_property( "ai_corpse_found", false )
	end,
	OnAct = function(self)
		local intf = self.__proto.intf
		if self:is_active() then
			local target = self:target_closest(15)
			if not target then return end
			if self.ai_state == "normal" or self.ai_state == "delay" then
				-- general
				if ( 2 * self.hp < self.hpmax ) then
					if self.ai_corpse_found then
						self.ai_state = "scavenge"
						return
					end
				end
				self.ai_corpse_found = false
				local dist = self:distance_to( target )
				local roll = math.random(100) - 1
				if (dist <= 1) then
					if self.ai_state ~= "normal" or roll < (2*intf + 20) then
						-- attack target
						self:attack( target )
						self.ai_state = "normal"
					else
						-- do delay
						self.ai_state = "delay"
						self.scount = self.scount - ((math.random(10) + 9 - 2*intf) * 5)
					end
				else
					if (self.ai_state ~= "normal" or roll < (4*intf + 65)) then
						-- move toward target
						self:seek(target)
						self.ai_state = "normal"
					else
						-- do delay
						self.ai_state = "delay"
						self.scount = self.scount - ((math.random(10) + 14 - 2*intf) * 5)
					end
				end
			else
				local level = self:get_level()
				-- eating/digging
				local cell = cells[level:get_cell(self.position)]
				if cell.flags[ cfBloodCorpse ] then
					-- standing on a carcass, feed
					self.flags[nfNoHeal] = true
					ui.play_sound(npcs[self.id].sound .. "a" .. math.random(2) .. ".wav",self.position)
					self.hp = self.hp + 1
					if 4 * self.hp > 3 * self.hpmax then
						-- healed enough, go back to normal mode
						self.ai_state = "normal"
						-- remove carcass
						level:set_cell(self.position,"bloody_floor")
					end
					-- do delay
					-- regeneration speed: 1.82 seconds per hit point (Jarulf 5.1)
					self.scount = self.scount - 182
				else
					-- seek nearest carcass
					self.flags[nfNoHeal] = false
					local c = level:find_nearest(self,efCorpse)
					if c then
						self:seek( c )
						self.ai_corpse_found = true
					else
						-- no carcass found
						-- fall back to general AI for a turn
						self.ai_state = "delay"
						self.ai_corpse_found = false
					end
				end
			end
		end
	end,
})

AI(AIWingedFiend,{
	OnCreate = function(self)
		self:add_property( "ai_state", 0 )
	end,
	OnAct = function(self)
		if self:is_active() then
			local target = self:target_closest(15)
			if not target then return end
			local roll = math.random(100) - 1
			local intf = self.__proto.intf
			local dist = self:distance_to( target )
			if dist == 1 then
				if self.ai_state == 2 then
					self:seek_away( target )
					self.ai_state = 1
				elseif roll < 4*intf + 8 then
					self:attack( target )
					self.ai_state = 2
				else
					self.ai_state = 0
				end
			--[[elseif dist > 3 and intf == 2 then
				self.flags[ nfCharge ] = true ]]
			elseif ( self.ai_state < 2 ) and ( roll <= 13 + intf + 50 * self.ai_state ) then
				self:seek( target )
				self.ai_state = 1
			else
				self.ai_state = 0
			end
		end
	end,
})

AI(AIHidden,{
	OnCreate = function(self)
		self:add_property( "ai_state", 0 )
	end,

	OnHit = function(self)
	  self.ai_state = 2
	end,

	OnAct = function(self)
		local target = self:target_closest(15)
		if target then
			local roll = math.random(100) - 1
			local intf = self.__proto.intf
			local dist = self:distance_to( target )

			if dist + intf < 5 and self.flags[ nfInvisible ] then
				if self:is_visible() then
					ui.msg(self:get_name(0)..' appears.')
				end
				self.flags[ nfInvisible ]    = false
				self.flags[ nfInvulnerable ] = false
				self.scount = self.scount - 55
			elseif dist + intf > 5 and not self.flags[ nfInvisible ] then
				if self:is_visible() then
					ui.msg(self:get_name(0)..' disappears.')
				end
				self.flags[ nfInvisible ] = true
				if intf == 3 then
					self.flags[ nfInvulnerable ] = true
				end
				self.scount = self.scount - 55
			elseif self.ai_state == 2 then
				if dist + intf < 8  then
					self:seek_away( target )
				end
				if self.hp == self.hpmax then
					self.ai_state = 0
				end
			elseif ( dist == 1 ) and ( roll < 4 * intf + 10 ) then
				self:attack( target )
				self.ai_state = 0
			elseif ( dist > 1 ) and ( roll < intf + 14 + self.ai_state * 50 ) then
				self:seek( target )
				self.ai_state = 1
			else
				self.ai_state = 0
			end
		end
	end,
})

AI(AIGoat,{
	OnCreate = function(self)
		self:add_property( "ai_state", 0 )
	end,

	OnAct = function(self)
		if self:is_active() then
			local target = self:target_closest(15)
			if not target then return end
			local roll = math.random(100) - 1
			local intf = self.__proto.intf
			local dist = self:distance_to( target )
			if dist == 1 then
				if roll < 2 * intf + 23 then
					if 2 * self.hp >= self.hpmax or math.random(2) == 1 then
						self:attack( target )
					else
						ui.msg(self:get_name(0)..' spins.')
						-- TODO: Special attack has different to-hit and dmg
--[[ Jarulf: "Goat Men have a second spinning attack. They will only perform this attack once their HP gets low (see chapter 5.5.9). Flesh,
Stone and Fire Clan have a base To Hit of 0, 85 and 120 for the three difficulty levels while the damage is 0-0, 4-4 and 6-6.
Night Clan have a base To Hit of 15, 100 and 135 while the damage is 30-30, 64-64 and 126-126." --]]
					end
					self.scount = self.scount - self.spdatk
				end
			elseif dist <= 3 or math.random(4) > 1 or not self:is_visible() then
				if roll < intf + 28 + self.ai_state * 50 then
					self.ai_state = 1
					self:seek( target )
				else
					self.ai_state = 0
				end
			else
				self:circle( target )
			end
		end
	end,
})

AI(AIGoatArcher,{
	OnAct = function(self)
		if self:is_active() then
			local target = self:target_closest(15)
			if target then
				if self:is_visible() then
					local roll = math.random(100) - 1
					local intf = self.__proto.intf
					local dist = self:distance_to( target )
					if dist <= 3 and roll < 2*intf+70 then
						self:seek_away( target )
					else
						self:send_missile( MT_ARROW, target )
					end
					return
				end
			end
			self:seek( self:get_target() )
		end
	end,
})

AI(AIOverlord,{
	OnCreate = function(self)
		self:add_property( "ai_state", 0 )
	end,

	OnAct = function(self)
		if self:is_active() then
			local target = self:target_closest(15)
			if not target then return end
			local roll = math.random(100) - 1
			local intf = self.__proto.intf
			local dist = self:distance_to( target )
			if dist <= 1 and (self.ai_state == 1 or roll < 2*intf+20) then
				self:attack( target )
				self.ai_state = 0
				return
			end
			if dist > 1 and (self.ai_state == 1 or roll < 2*intf+65) then
				self:seek( target )
				self.ai_state = 0
				return
			end
			self.ai_state = 1
			self.scount = self.scount - ((math.random(10) + 9 - 2*intf) * 5)
		end
	end,
})

AI(AIHornedDemon, {
	OnCreate = function(self)
		self:add_property( "ai_state", 0 )
	end,

	OnAct = function(self)
		if self:is_active() then
			local target = self:target_closest(15)
			local dist = self:distance_to( target )
			if self.flags[nfCharge] then
				if dist == 1 then
					self:attack( target )
					self.flags[nfCharge] = false
					self.ai_state = 0
				else
					self:seek( self:get_target() )
				end
			elseif target then
				local roll = math.random(100)-1
				local intf = self.__proto.intf
				if dist == 1 then
					if roll < 2 * intf + 28 then
						self:attack( target )
						self.ai_state = 0
					else
						self.ai_state = self.ai_state + 1
					end
				elseif dist < 4 then
					if self.ai_state == 0 and roll < 2 * intf + 33 then
						self:seek( target )
						self.ai_state = 0
					elseif self.ai_state > 0 and roll < 2 * intf + 83 then
						self:seek( target )
						self.ai_state = 0
					else
						self.scount = self.scount - ((math.random(10) + 10) * 5)
						self.ai_state = self.ai_state + 1
					end
				else
					if math.random(4) > 2 then
						self:circle( target )
						self.ai_state = 0
						return
					end
					if self.ai_state == 0 and roll < 2 * intf + 33 then
						if self:can_charge( target ) then
							self.flags[nfCharge] = true
							self.ai_state = 0
						end
						self:seek( self )
					elseif self.ai_state > 0 and roll < 2 * intf + 83 then
						self:seek( target )
						self.ai_state = 0
					else
						self.scount = self.scount - ((math.random(10) + 10) * 5)
						self.ai_state = self.ai_state + 1
					end

				end
			end
		end
	end,

	OnAttack = function(self, tgt)
		if self.flags[nfCharge] then
			tgt:knockback( self )
		end
	end
})

AI(AIMage, {
	-- aistate
	--	0: general
	--	1: last action was delay
	--  2: retreat mode

	OnCreate = function(self)
		self:add_property( "ai_state", "normal" )
	end,

	OnAct = function(self)
		if self:is_active() then
			local target = self:target_closest(15)
			if not target then return end
			local dist = self:distance_to( target )
			local roll = math.random(100) - 1
			local intf = self.__proto.intf

			if self.ai_state == "retreat" then
			--retreat mode
				if dist < 3 then
					self:seek_away( target )
					NPC_Spells["mage_fadeout"](self)
					return
				else
					self.ai_state = "normal"
					NPC_Spells["mage_fadein"](self)
					return
				end
			end
			if dist == 1 then
				if self.flags[nfInvisible] then
					NPC_Spells["mage_fadein"](self)
					return
				elseif self.hp*2 < self.hpmax then
					self.ai_state = "retreat"
				elseif self.ai_state == "delay" then
					self:cast_spell('flash')
					self.ai_state = "normal"
				elseif roll < 2 * intf + 20  then
					self:cast_spell('flash')
					self.ai_state = "normal"
				else
					self.ai_state = "delay"
					self.scount = self.scount - math.random(5) + 5 - intf
					return
				end
			else
				if self:is_visible() and roll < 5 * intf + 50 then
					if self.flags[nfInvisible] then
						NPC_Spells["mage_fadein"](self)
						return
					end
					self:cast_spell('fireball')
					self.ai_state = "normal"
					return
				else
					if math.random(100) > 30 then
						NPC_Spells["mage_fadein"](self)
						self.ai_state = "delay"
						self.scount = self.scount - math.random(5) + 5 - intf
						return
					else
						NPC_Spells["mage_fadeout"](self)
						self:circle( target )
						self.ai_state = "normal"
						return
					end
				end
			end
		end
	end,
})

--== Unique AI scripts ==--

AI(AIButcher,{
	OnAct = function(self)
		if self:is_active() then
			local target = self:target_closest(15)
			if target then
				if self:distance_to( target ) <= 1 then
					self:attack( target )
				else
					self:seek( target )
				end
			else
				self:seek( self:get_target() )
			end
		end
	end,
})

AI(AIGolem,{
	OnAct = function(self)
		if self:is_active() then
			local target = self:target_closest(15)
			if target then
				if self:distance_to( target ) <= 1 then
					self:attack( target )
				else
					self:seek( target )
				end
			else
				self:seek( player )
			end
		end
	end,
})

AI(AIGuardian,{
	OnCreate = function(self)
		self:add_property( "firebolt", 0 )
	end,

	OnAct = function(self)
		local target = self:target_closest(15)
		if target then
			self:cast_spell( spells[ 'firebolt' ].nid, self.firebolt )
			self.hp = math.max( self.hp - 80, 0 )
		else
			self.hp = math.max( self.hp - 5, 0 )
		end
		if self.hp == 0 then
			self.scount = 0
			self:die()
		end
	end,
})

AI(AILeoric,{
	OnCreate = function(self)
		self:add_property( "ai_state", "normal" )
		self:add_property( "ai_timer", 0 )
	end,

	OnAct = function(self)
	-- aistate
		--	0: general
		--	1: last action was delay
		--	2: circle walk
		if not self:is_active() then
			return
		end

		local roll = math.random(100) - 1
		local intf = self.__proto.intf
		if self:is_visible() then
			local target = self:target_closest(15)
			if not target then return end
			local dist = self:distance_to( target )
			if dist <= 2 then
				if roll < 5 then
					NPC_Spells["leoric_revive"](self)
					return
				elseif dist == 1 then
					if roll < 2*intf + 20 then
						-- attack target
						self:attack( target )
						self.ai_state = "normal"
					end
					return
				end
			else
				if self.ai_state ~= "circle" and math.random(4) == 1 then
					-- start circle walk
					self.ai_state = "circle"
					self.ai_timer = 2 * dist
					self:circle(self:get_target())
					return
				elseif roll < 4*intf + 35 then
					NPC_Spells["leoric_revive"](self)
					return
				end
			end
		end
		if self.ai_state == "normal" then
			if roll < intf + 75 then
				self:seek(self:get_target())
			end
		elseif self.ai_state == "delay" then
			if roll < (intf + 25) then
				self:seek(self:get_target())
				self.ai_state = "normal"
			end
		elseif self.ai_state == "circle" then
			self.ai_timer = self.ai_timer - 1
			if self.ai_timer == 0 then
				-- enough circling, go back to normal
				self.ai_state = "normal"
			end
			self:circle(self:get_target())
		else
			self.ai_state = "delay"
			self.scount = scount - ((math.random(10) + 9) * 5)
		end
	end,
})
