-- WEAPON TYPE - SWORD ------------------------------------

register_item ( "dagger", "sword" )
{
	name       = "dagger",
	dmgmin     = 1,
	dmgmax     = 4,
	durability = 16,
	price      = 60,
	level      = 1,
	volume     = 2
}

register_item ( "short_sword", "sword" )
{
	name       = "short sword",
	iname      = "sword",
	dmgmin     = 2,
	dmgmax     = 6,
	durability = 20,
	price      = 120,
	level      = 1,
	minstr     = 18
}

register_item ( "sword", "sword" )
{
	name       = "sword",
	random_weight = 0,
	dmgmin     = 1,
	dmgmax     = 5,
	durability = 8,
	price      = 50,
	level      = 1,
	minstr     = 15,
	mindex     = 20,
}

register_item ( "sabre", "sword" )
{
	name       = "sabre",
	dmgmin     = 1,
	dmgmax     = 8,
	durability = 45,
	price      = 170,
	level      = 1,
	minstr     = 17
}

register_item ( "scimitar", "sword" )
{
	name       = "scimitar",
	dmgmin     = 3,
	dmgmax     = 7,
	durability = 28,
	price      = 200,
	level      = 4,
	minstr     = 23,
	mindex     = 23
}

register_item ( "blade", "sword" )
{
	name       = "blade",
	dmgmin     = 2,
	dmgmax     = 8,
	durability = 30,
	price      = 280,
	level      = 4,
	minstr     = 25,
	mindex     = 30
}

register_item ( "falchion", "sword" )
{
	name       = "falchion",
	dmgmin     = 4,
	dmgmax     = 8,
	durability = 20,
	price      = 250,
	level      = 6,
	minstr     = 30
}

register_item ( "long_sword", "sword" )
{
	name       = "long sword",
	iname      = "sword",
	dmgmin     = 2,
	dmgmax     = 10,
	durability = 40,
	price      = 350,
	level      = 6,
	minstr     = 40
}

register_item ( "claymore", "sword" )
{
	name       = "claymore",
	dmgmin     = 1,
	dmgmax     = 12,
	durability = 36,
	price      = 450,
	level      = 5,
	minstr     = 35
}

register_item ( "broad_sword", "sword" )
{
	name       = "broad sword",
	iname      = "sword",
	dmgmin     = 4,
	dmgmax     = 12,
	durability = 50,
	price      = 750,
	level      = 8,
	minstr     = 45
}

register_item ( "bastard_sword", "sword" )
{
	name       = "bastard sword",
	iname      = "sword",
	dmgmin     = 6,
	dmgmax     = 15,
	durability = 60,
	price      = 1000,
	level      = 10,
	minstr     = 50
}

register_item ( "two_handed_sword", "sword" )
{
	name       = "two-handed sword",
	iname      = "sword",
	flags      = { ifTwoHanded },
	dmgmin     = 8,
	dmgmax     = 16,
	durability = 75,
	price      = 1800,
	level      = 14,
	minstr     = 65,
	volume     = 6
}

register_item ( "great_sword", "sword" )
{
	name       = "great sword",
	iname      = "sword",
	flags      = { ifTwoHanded },
	dmgmin     = 10,
	dmgmax     = 20,
	durability = 100,
	price      = 3000,
	level      = 17,
	minstr     = 75,
	volume     = 6
}

-- WEAPON TYPE - BOW --------------------------------------

register_item ( "short_bow", "bow" )
{
	name       = "short bow",
	dmgmin     = 1,
	dmgmax     = 4,
	durability = 30,
	price      = 100,
	level      = 1
}

register_item ( "long_bow", "bow" )
{
	name       = "long bow",
	dmgmin     = 1,
	dmgmax     = 6,
	durability = 35,
	price      = 250,
	level      = 5,
	minstr     = 25,
	mindex     = 30
}

register_item ( "hunters_bow", "bow" )
{
	name       = "hunter's bow",
	dmgmin     = 2,
	dmgmax     = 5,
	durability = 40,
	price      = 350,
	level      = 3,
	minstr     = 20,
	mindex     = 35
}

register_item ( "composite_bow", "bow" )
{
	name       = "composite bow",
	dmgmin     = 3,
	dmgmax     = 6,
	durability = 45,
	price      = 600,
	level      = 7,
	minstr     = 25,
	mindex     = 40
}

register_item ( "short_battle_bow", "bow" )
{
	name       = "short battle bow",
	dmgmin     = 3,
	dmgmax     = 7,
	durability = 45,
	price      = 750,
	level      = 9,
	minstr     = 30,
	mindex     = 50
}

register_item ( "long_battle_bow", "bow" )
{
	name       = "long battle bow",
	dmgmin     = 1,
	dmgmax     = 10,
	durability = 50,
	price      = 1000,
	level      = 11,
	minstr     = 30,
	mindex     = 60
}

register_item ( "short_war_bow", "bow" )
{
	name       = "short war bow",
	dmgmin     = 4,
	dmgmax     = 8,
	durability = 55,
	price      = 1500,
	level      = 15,
	minstr     = 35,
	mindex     = 70
}

register_item ( "long_war_bow", "bow" )
{
	name       = "long war bow",
	dmgmin     = 1,
	dmgmax     = 14,
	durability = 60,
	price      = 2000,
	level      = 19,
	minstr     = 45,
	mindex     = 80
}

-- WEAPON TYPE - CLUB -------------------------------------

register_item ( "club", "club" )
{
	name       = "club",
	dmgmin     = 1,
	dmgmax     = 6,
	durability = 20,
	price      = 20,
	level      = 1
}

register_item ( "spiked_club", "club" )
{
	name       = "spiked club",
	dmgmin     = 3,
	dmgmax     = 6,
	durability = 20,
	price      = 225,
	level      = 4,
	minstr     = 18
}

register_item ( "mace", "club" )
{
	name       = "mace",
	dmgmin     = 1,
	dmgmax     = 8,
	durability = 32,
	price      = 200,
	level      = 2,
	minstr     = 16
}

register_item ( "morning_star", "club" )
{
	name       = "morning star",
	dmgmin     = 1,
	dmgmax     = 10,
	durability = 40,
	price      = 300,
	level      = 3,
	minstr     = 26
}

register_item ( "flail", "club" )
{
	name       = "flail",
	dmgmin     = 2,
	dmgmax     = 12,
	durability = 36,
	price      = 500,
	level      = 7,
	minstr     = 30,
	volume     = 6
}

register_item ( "war_hammer", "club" )
{
	name       = "war hammer",
	dmgmin     = 5,
	dmgmax     = 9,
	durability = 50,
	price      = 600,
	level      = 5,
	minstr     = 40,
	volume     = 6
}

register_item ( "maul", "club" )
{
	name       = "maul",
	flags      = { ifTwoHanded },
	dmgmin     = 6,
	dmgmax     = 20,
	durability = 50,
	price      = 900,
	level      = 10,
	minstr     = 55,
	volume     = 6
}

-- WEAPON TYPE - STAFF ------------------------------------

register_item ( "short_staff", "staff" )
{
	name       = "short staff",
	dmgmin     = 2,
	dmgmax     = 4,
	durability = 25,
	price      = 30,
	level      = 1
}

register_item ( "long_staff", "staff" )
{
	name       = "long staff",
	dmgmin     = 4,
	dmgmax     = 8,
	durability = 35,
	price      = 100,
	level      = 4
}

register_item ( "composite_staff", "staff" )
{
	name       = "composite staff",
	dmgmin     = 5,
	dmgmax     = 10,
	durability = 45,
	price      = 500,
	level      = 6
}

register_item ( "quarter_staff", "staff" )
{
	name       = "quarter staff",
	dmgmin     = 6,
	dmgmax     = 12,
	durability = 55,
	price      = 1000,
	level      = 9,
	minstr     = 20
}

register_item ( "war_staff", "staff" )
{
	name       = "war staff",
	dmgmin     = 8,
	dmgmax     = 16,
	durability = 75,
	price      = 1500,
	level      = 12,
	minstr     = 30
}

-- WEAPON TYPE - AXE --------------------------------------

register_item ( "small_axe", "axe" )
{
	name       = "small axe",
	dmgmin     = 2,
	dmgmax     = 10,
	durability = 24,
	price      = 150,
	level      = 2
}

register_item ( "axe", "axe" )
{
	name       = "axe",
	dmgmin     = 4,
	dmgmax     = 12,
	durability = 32,
	price      = 450,
	level      = 4,
	minstr     = 22
}

register_item ( "large_axe", "axe" )
{
	name       = "large axe",
	dmgmin     = 6,
	dmgmax     = 16,
	durability = 40,
	price      = 750,
	level      = 6,
	minstr     = 30
}

register_item ( "broad_axe", "axe" )
{
	name       = "broad axe",
	dmgmin     = 8,
	dmgmax     = 20,
	durability = 50,
	price      = 1000,
	level      = 8,
	minstr     = 50
}

register_item ( "battle_axe", "axe" )
{
	name       = "battle axe",
	dmgmin     = 10,
	dmgmax     = 25,
	durability = 60,
	price      = 1500,
	level      = 10,
	minstr     = 65
}

register_item ( "great_axe", "axe" )
{
	name       = "great axe",
	dmgmin     = 12,
	dmgmax     = 30,
	durability = 75,
	price      = 2500,
	level      = 12,
	minstr     = 80
}
