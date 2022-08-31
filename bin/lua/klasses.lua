core.register_blueprint "klass"
{
	id        = { true,  core.TSTRING },
	name      = { true,  core.TSTRING },
	dname     = { true,  core.TSTRING },
	gender    = { true,  core.TSTRING },
	klassid   = { true,  core.TNUMBER },
	flags     = { false, core.TFLAGS, {} },
	ai        = AIPlayer,
	str       = { true,  core.TNUMBER },
	maxstr    = { true,  core.TNUMBER },
	mag       = { true,  core.TNUMBER },
	maxmag    = { true,  core.TNUMBER },
	dex       = { true,  core.TNUMBER },
	maxdex    = { true,  core.TNUMBER },
	vit       = { true,  core.TNUMBER },
	maxvit    = { true,  core.TNUMBER },
	life      = { true,  core.TNUMBER },--unused
	mana      = { true,  core.TNUMBER },--unused
	lifelev   = { true,  core.TNUMBER },--unused
	manalev   = { true,  core.TNUMBER },--unused
	pic       = { false, core.TSTRING, "@" },
	color     = { true,  core.TNUMBER },
	level     = { false, core.TNUMBER, 1 },
	corpse    = { false, core.TSTRING, "bloody_corpse" },
	hpmin     = { true,  core.TNUMBER },
	hpmax     = { true,  core.TNUMBER },
	spdmov    = { false, core.TNUMBER, 40 },
	spdatk    = { false, core.TNUMBER, 45 },
	spdhit    = { true,  core.TNUMBER },
	spdblk    = { true,  core.TNUMBER },
	spdmag    = { true,  core.TNUMBER },
	spellcost = { true,  core.TNUMBER },
	skill     = { false, core.TSTRING },
	sound     = { true,  core.TSTRING },
	desc      = { true,  core.TSTRING },

	OnCreate  = { true,  core.TFUNC },
}

register_klass "warrior"
{
	name      = "Warrior",
	dname     = "Alucard",
	gender    = "m",
	klassid   = KlassWarrior,
	str       = 30,
	maxstr    = 250,
	mag       = 10,
	maxmag    = 50,
	dex       = 20,
	maxdex    = 60,
	vit       = 25,
	maxvit    = 100,
	life      = 70,--unused
	mana      = 10,--unused
	lifelev   = 2,--unused
	manalev   = 2,--unused
	color     = BLUE,
	hpmin     = 70,
	hpmax     = 70,
	spdhit    = 30,
	spdblk    = 10,
	spdmag    = 70,
	spellcost = 100,
	skill     = "repair_items",
	sound     = "sfx/Warrior/warior",
	desc      = "The warrior is a powerful melee fighter. Seeking fortune and glory, warriors come to Tristram every day to challenge the dark unknown in the subterranean labyrinth. They are not necessarily of any particular clan or group and range from barbarians from the northern highlands to noble paladins.",

	OnCreate = function( self )
		self.eq.rhand = "short_sword"
		self.eq.rhand.dur = self.eq.rhand.durmax
		self.eq.lhand = "buckler"
		self.eq.lhand.dur = self.eq.lhand.durmax
		self:add_gold(100)
		local club = item.new( "club" )
		club.dur = club.durmax
		self:add_item( club )
		self:add_item( "potion_healing" )
		self:add_item( "potion_healing" )
	end
}

register_klass "rogue"
{
	name      = "Rogue",
	dname     = "Shana",
	gender    = "f",
	klassid   = KlassRogue,
	str       = 20,
	maxstr    = 55,
	mag       = 15,
	maxmag    = 70,
	dex       = 30,
	maxdex    = 250,
	vit       = 25,
	maxvit    = 80,
	life      = 45,--unused
	mana      = 22,--unused
	lifelev   = 2,--unused
	manalev   = 2,--unused
	color     = GREEN,
	hpmin     = 70,
	hpmax     = 70,
	spdhit    = 35,
	spdblk    = 20,
	spdmag    = 60,
	spellcost = 75,
	sound     = "sfx/rogue/rogue",
	desc      = "The Sisters of the Sightless Eye are the best archers in the world of Sanctuary and the rogue therefore is master of killing enemies from a distance. Willing to test their skills against the evil in the labyrinth, where untold riches are rumored to be stashed, rogues have come from the far east to Tristram.",

	OnCreate = function( self )
		self.eq.rhand = "short_bow"
		self.eq.rhand.dur = self.eq.rhand.durmax
		self:add_gold(100)
		self:add_item("potion_healing")
		self:add_item("potion_healing")
	end
}

register_klass "sorcerer"
{
	name      = "Sorcerer",
	dname     = "Rezo",
	gender    = "m",
	klassid   = KlassSorceror,
	str       = 15,
	maxstr    = 45,
	mag       = 35,
	maxmag    = 250,
	dex       = 15,
	maxdex    = 85,
	vit       = 20,
	maxvit    = 80,
	life      = 30,--unused
	mana      = 70,--unused
	lifelev   = 1,--unused
	manalev   = 2,--unused
	color     = RED,
	hpmin     = 30,
	hpmax     = 30,
	spdhit    = 40,
	spdblk    = 30,
	spdmag    = 40,
	spellcost = 100,
	skill     = "recharge_staves",
	sound     = "sfx/sorceror/mage",
	desc      = "The Brotherhood of the Vizjerei, one of the eldest mage-clans of the East, has sent many of its acolytes to observe the dark events unfolding in Khanduras. The Vizjerei, known for their brightly colored  spirit-robes, have taken a keen interest in both gathering knowledge of demons and seeing them slain.",

	OnCreate = function( self )
		self.eq.rhand				= "short_staff"
		local staff = self.eq.rhand
		staff.spell			= spells["firebolt"].nid
		staff.name = "staff of Firebolt"
		staff.flags[ifSpellBound] = true
		staff.chargesmax	= 40
		staff.charges		= staff.chargesmax
		staff.dur			= staff.durmax
		self:add_gold(100)
		self:add_item("potion_mana")
		self:add_item("potion_mana")
		self.spells["firebolt"] = 2
	end
}
