core.register_blueprint "item"
{
	id				= { true,  core.TSTRING },
	name			= { true,  core.TSTRING },
	iname			= { false, core.TSTRING, "" },
	pic				= { true,  core.TSTRING },
	piclow			= { false, core.TSTRING },
	type			= { true,  core.TNUMBER },
	color			= { false, core.TNUMBER, LIGHTGRAY },
	flags			= { false, core.TFLAGS, {} },
	price			= { false, core.TNUMBER, 0 },
	level			= { false, core.TNUMBER, 1 },
	volume			= { false, core.TNUMBER, 1 },

	sound1			= { false, core.TSTRING },
	sound2			= { false, core.TSTRING },

	random_weight	= { false, core.TNUMBER, 1 },
	uniques			= { false, core.TIDIN("uniques") },
	OnPickUp		= { false, core.TFUNC },
	OnCreate		= { false, core.TFUNC },
}

core.register_blueprint( "potion", "item" )
{
	type         = TYPE_POTION,
	pic          = "!",
	volume       = 1,
	sound2       = "sfx/items/flippot.wav",
	sound1       = "sfx/items/invpot.wav",
	OnUse        = { true, core.TFUNC },
}

core.register_blueprint( "scroll", "item" )
{
	type         = TYPE_SCROLL,
	pic          = "?",
	volume       = 1,
	sound2       = "sfx/items/flipscrl.wav",
	sound1       = "sfx/items/invscrol.wav",

	level        = { false, core.TNUMBER, 1 },
	minmag       = { false, core.TNUMBER, 0 },
	spell        = { true, core.TSTRING },
	price        = { true, core.TNUMBER },
	color        = { true, core.TNUMBER },
}

core.register_blueprint( "book", "item" )
{
	name         = "book",
	type         = TYPE_BOOK,
	pic          = "\"",
	volume       = 4,
	color        = LIGHTBLUE,
	sound2       = "sfx/items/flipbook.wav",
	sound1       = "sfx/items/invbook.wav",

	OnCreate     = function(self,ilvl)
		-- pick spell based on ilvl
		local spell_list = {}
		for _,spell in ipairs(spells) do
			if spell.book and spell.book.level and spell.book.level > 0 and spell.book.level <= ilvl then
				table.insert(spell_list,spell)
			end
		end
		local spell = table.random_pick( spell_list )

		-- apply spell
		self.name       = self.name.." of "..spell.name
		self.spell      = spell.nid
		self.magreq     = spell.magic
		self.price      = spell.book.price
	end,
}

core.register_blueprint( "equipment", "item" )
{
	acmin           = { false, core.TNUMBER },
	acmax           = { false, core.TNUMBER },
	minstr          = { false, core.TNUMBER },
	mindex          = { false, core.TNUMBER },
	minmag          = { false, core.TNUMBER },
	str             = { false, core.TNUMBER },
	dex             = { false, core.TNUMBER },
	mag             = { false, core.TNUMBER },
	vit             = { false, core.TNUMBER },
	dmgtaken        = { false, core.TNUMBER },
	reslightning    = { false, core.TNUMBER },
	resfire         = { false, core.TNUMBER },
	resmagic        = { false, core.TNUMBER },
	lifestealmin    = { false, core.TNUMBER },
	lifestealmax    = { false, core.TNUMBER },
	dmglightningmin = { false, core.TNUMBER },
	dmglightningmax = { false, core.TNUMBER },
	dmgfiremin      = { false, core.TNUMBER },
	dmgfiremax      = { false, core.TNUMBER },
	lightmod        = { false, core.TNUMBER },
	durmod          = { false, core.TNUMBER },
	dmgmod          = { false, core.TNUMBER },
	dmgmodprc       = { false, core.TNUMBER },
	tohit           = { false, core.TNUMBER },
	hpmod           = { false, core.TNUMBER },
	mpmod           = { false, core.TNUMBER },
	spdatk          = { false, core.TNUMBER },
	spdhit          = { false, core.TNUMBER },
	spdblk          = { false, core.TNUMBER },
	spelllevel      = { false, core.TNUMBER },
}

core.register_blueprint( "ring", "equipment" )
{
	type         = TYPE_RING,
	name         = "ring",
	pic          = "=",
	color        = BLUE,
	volume       = 1,
	sound2       = "sfx/items/flipring.wav",
	sound1       = "sfx/items/invring.wav",
}

core.register_blueprint( "amulet", "equipment" )
{
	type         = TYPE_AMULET,
	name         = "amulet",
	pic          = "'",
	color        = BLUE,
	volume       = 1,
	sound2       = "sfx/items/flipring.wav",
	sound1       = "sfx/items/invring.wav",
}

core.register_blueprint( "armor", "equipment" )
{
	acmin        = { true, core.TNUMBER },
	acmax        = { true, core.TNUMBER },
	durability   = { true, core.TNUMBER },
}

core.register_blueprint( "shield", "armor" )
{
	type         = TYPE_SHIELD,
	pic          = ")",
	sound2       = "sfx/items/flipshld.wav",
	sound1       = "sfx/items/invshiel.wav"
}

core.register_blueprint( "larmor", "armor" )
{
	type         = TYPE_ARMOR,
	pic          = "]",
	volume       = 6,
	sound2       = "sfx/items/fliplarm.wav",
	sound1       = "sfx/items/invlarm.wav",
	armortype    = "light",
}

core.register_blueprint( "marmor", "armor" )
{
	type         = TYPE_ARMOR,
	pic          = "]",
	volume       = 6,
	sound2       = "sfx/items/flipharm.wav",
	sound1       = "sfx/items/invharm.wav",
	armortype    = "medium",
}

core.register_blueprint( "harmor", "armor" )
{
	type         = TYPE_ARMOR,
	pic          = "]",
	volume       = 6,
	sound2       = "sfx/items/flipharm.wav",
	sound1       = "sfx/items/invharm.wav",
	armortype    = "heavy",
}

core.register_blueprint( "helm", "armor" )
{
	type         = TYPE_HELM,
	pic          = "[",
	volume       = 4,
	sound2       = "sfx/items/flipcap.wav",
	sound1       = "sfx/items/invcap.wav",
}

core.register_blueprint( "weapon", "equipment" )
{
	type       = TYPE_WEAPON,
	vsdemon    = { false, core.TNUMBER },
	vsanimal   = { false, core.TNUMBER },
	vsundead   = { false, core.TNUMBER },
	dmgmin     = { true, core.TNUMBER },
	dmgmax     = { true, core.TNUMBER },
	durability = { true, core.TNUMBER },
}

core.register_blueprint( "axe", "weapon" )
{
	volume     = { false, core.TNUMBER, 6 },
	flags      = { false, core.TFLAGS, { ifTwoHanded, ifAxe } },
	pic        = "+",
	weapontype = "axe",
	sound2     = "sfx/items/flipaxe.wav",
	sound1     = "sfx/items/invaxe.wav",
}

core.register_blueprint( "sword", "weapon" )
{
	volume     = { false, core.TNUMBER, 3 },
	vsundead   = 50,
	vsanimal   = 150,
	pic        = "/",
	weapontype = "sword",
	sound2     = "sfx/items/flipswor.wav",
	sound1     = "sfx/items/invsword.wav",
}

core.register_blueprint( "club", "weapon" )
{
	volume     = { false, core.TNUMBER, 3 },
	vsundead   = 150,
	vsanimal   = 50,
	pic        = "\\",
	weapontype = "club",
	sound2     = "sfx/items/flipswor.wav",
	sound1     = "sfx/items/invsword.wav",
}

core.register_blueprint( "bow", "weapon" )
{
	volume     = { false, core.TNUMBER, 6 },
	type       = TYPE_BOW,
	pic        = "{",
	weapontype = "bow",
	sound2     = "sfx/items/flipbow.wav",
	sound1     = "sfx/items/invbow.wav",
	flags      = { false, core.TFLAGS, { ifTwoHanded } },

	random_weight = 2,
}

core.register_blueprint( "staff", "weapon" )
{
	volume     = 6,
	type       = TYPE_STAFF,
	pic        = "|",
	weapontype = "staff",
	sound2     = "sfx/items/flipstaf.wav",
	sound1     = "sfx/items/invstaf.wav",
	spell      = { false, core.TSTRING },
	charges    = { false, core.TNUMBER },
	chargesmax = { false, core.TNUMBER },

	flags      = { false, core.TFLAGS, { ifTwoHanded } },
}

register_item "gold"
{
	name       = "gold coins",
	random_weight  = 0,
	type       = TYPE_GOLD,
	pic        = "$",
	price      = 1,
	level      = 1,
	color      = YELLOW,
	sound2     = "sfx/items/gold.wav"
}
