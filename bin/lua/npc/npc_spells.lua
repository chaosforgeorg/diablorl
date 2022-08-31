-- These algorithms (should be) based on Jarulf 5.5 Monster AI
-- especially 5.5.9 AI scripts
--
-- NOTE: LUA math.random(x) returns a number in the range 1 to x
-- Jarulf algorithms use Rnd[x] in the range 0 to x-1

core.declare("NPC_Spells", 
{
	hidden_fadein = function() end,
	
	hidden_fadeout = function() end,

	mage_fadein = function(self)
		if self.flags[nfInvisible] then
			self.flags[ nfInvisible ]    = false
			self.flags[ nfInvulnerable ] = false
			if self:is_visible() then
				ui.msg(self:get_name(0)..' appears.')
			end
			self.scount = self.scount - 100
		end
	end,

	mage_fadeout = function(self)
		if self.flags[nfInvisible] then return end
		if self:is_visible() then
			ui.msg(self:get_name(0)..' disappears.')
		end
		self.flags[nfInvisible]    = true
		self.flags[nfInvulnerable] = true
		self.scount = self.scount - 100
	end,

	leoric_revive = function(self)
		local level = self:get_level()
		local c = level:find_nearest(self,efBones)
		if c then
			local cell = cells[level:get_cell(c)]
			if cell.raiseto then
				level:drop_npc(cell.raiseto, c )
				level:set_cell(c,"floor")
				ui.msg("The Skeleton King revives one of his minions!")
			end
		end
		self.scount = self.scount - 30
	end,

})

