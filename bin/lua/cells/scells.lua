core.register_blueprint( "story_tome", "cell" )
{
	flags        = { false, core.TFLAGS, { cfBlockMove, cfBlockChange } },
	pic          = { false, core.TSTRING, '"' },
	color        = { false, core.TNUMBER, YELLOW },
}

register_cell( "book_of_blood", "story_tome" )
{
	-- Catacombs, level 5
	name  = "Book of Blood",

	OnAct = function(self,c)
		player:play_sound(10)
		quests["valor"].OnJournal()
		if player.quest["valor"] == 0 then
			self:drop_item("blood_stone", c)
			self:drop_item("blood_stone", coord.new(c.x-6, c.y-11))
			self:drop_item("blood_stone", coord.new(c.x+6, c.y-11))
			player.quest["valor"] = 1
		end
	end,
}

register_cell( "mythical_book", "story_tome" )
{
	-- Catacombs, level 6
	name = "Mythical Book",

	OnAct = function(self,c)
		quests["bone_chamber"].OnJournal()
		if player.quest["bone_chamber"] == 0 then
			player.quest["bone_chamber"] = 1
			self:move_walls("moving_wall_1")
		end
	end,
}

register_cell( "ancient_tome", "story_tome" )
{
	-- Catacombs, level 6
	name = "Ancient Tome",

	OnAct = function(self,c)
		if player.quest["bone_chamber"] < 2 then
			player.quest["bone_chamber"] = 2
			player.spells["guardian_spell"] = math.min(15, player.spells["guardian_spell"] + 1)
			ui.msg_enter("Arcane Knowledge gained.")
			local hydra = self:drop_npc( 'hydra',coord.new( c.x,c.y-2 ) )
			hydra.hpmax = (8*player.spells["guardian_spell"]+4*player.level)
			hydra.hp 	= hydra.hpmax
			hydra.firebolt = player.spells['firebolt']
		end
	end,
}

register_cell( "book_of_the_blind", "story_tome" )
{
	-- Catacombs, level 7
	name = "Book of the Blind",

	OnAct = function(self,c)
		player:play_sound('11')
		quests["halls_of_blind"].OnJournal()
		if player.quest["halls_of_blind"] == 0 then
			player.quest["halls_of_blind"] = 1
			local cc = self:find_tile("blind_marker")
			self:drop_item( "optic_amulet", cc )
			self:set_cell( cc, "floor" )
			self:move_walls("moving_wall_1")
		end
	end,
}

register_cell( "steel_tome", "story_tome" )
{
	-- Hell, level 13
	name = "Steel Tome",

	OnAct = function(self,c)
		player:play_sound('12')
		ui.plot_talk("The armories of Hell are home to the Warlord of Blood. In his wake lay the mutilated bodies of thousands. Angels and man alike have been cut down to fulfill his endless sacrifices to the dark ones who scream for one thing - blood.")
		-- initiate Warlord of Blood quest
	end,
}

register_cell( "the_great_conflict", "story_tome" )
{
	-- Church, level 4
	name = "The Great Conflict",

	OnAct = function(self,c)
		ui.play_sound('sfx/narrator/nar01.wav')
		ui.plot_talk("Take heed and bear witness to the truths that lie herein, for they are the last legacy of the Horadrim. There is a war that rages on even now, beyond the fields that we know - between the Utopian Kingdoms of the High Heavens and the Chaotic Pits of the Burning Hells. This war is known as the Great Conflict, and it has raged and burned longer than any of the stars in the sky. Neither side ever gains sway for long as the forces of Light and Darkness constantly vie for control over all creation.")
	end,
}

register_cell( "wages_of_sin_are_war", "story_tome" )
{
	-- Catacombs, level 8
	name = "Wages of Sin are War",

	OnAct = function(self,c)
		ui.play_sound('sfx/narrator/nar02.wav')
		ui.plot_talk("Take heed and bear witness to the truths that lie herein, for they are the last legacy of the Horadrim. When the eternal conflict between the High Heavens and the Burning Hells falls upon mortal soil, it is called the Sin War. Angels and Demons walk amongst humanity in disguise, fighting in secret, away from the prying eyes of mortals. Some daring, powerful mortals have even allied themselves with either side, and helped to dictate the course of the Sin War.")
	end,
}

register_cell( "tale_of_the_horadrim", "story_tome" )
{
	-- Caves, level 12
	name = "Tale of the Horadrim",

	OnAct = function(self,c)
		ui.play_sound('sfx/narrator/nar06.wav')
		ui.plot_talk("Take heed and bear witness to the truths that lie herein, for they are the last legacy of the Horadrim. Nearly three hundred years ago, it came to be known that the three Prime Evils of the Burning Hells had mysteriously come to our world. The Three Brothers ravaged the lands of the East for decades, while humanity was left trembling in their wake. Our order - the Horadrim - was founded by a group of secretive Magi to hunt down and capture the three Evils once and for all. The original Horadrim captured two of the Three within powerful artifacts known as Soulstones and buried them deep beneath the desolate Eastern sands. The third Evil escaped capture and fled to the West with many of the Horadrim in pursuit. The third Evil - known as Diablo, the Lord of Terror - was eventually captured, his essence set in a Soulstone and buried within this Labyrinth. Be warned that the Soulstone must be kept from discovery by those not of the Faith. If Diablo were to be released, he would seek a body that would be easily controlled as he would be very weak - perhaps that of an old man or a child.")
	end,
}

register_cell( "the_realms_beyond", "story_tome" )
{
	-- Church, level 4
	name = "The Realms Beyond",

	OnAct = function(self,c)
		ui.play_sound('sfx/narrator/nar07.wav')
		ui.plot_talk("All praises to Diablo - Lord of Terror and survivor of the Dark Exile. When he awakened from his long slumber, my Lord and master spoke to me of secrets that few mortals know. He told me the kingdoms of the High Heavens and the pits of the Burning Hells engage in an eternal war. He revealed the powers that have brought this discord to the realms of man. My master has named the battle for this world and all who exist here the Sin War.")
	end,
}

register_cell( "tale_of_the_three", "story_tome" )
{
	-- Catacombs, level 8
	name = "Tale of the Three",

	OnAct = function(self,c)
		ui.play_sound('sfx/narrator/nar08.wav')
		ui.plot_talk("Glory and approbation to Diablo, Lord of Terror and leader of the Three. My lord spoke to me of his two brothers, Mephisto and Baal, who were banished to this world long ago. My lord wishes to bide his time and harness his awesome power so that he may free his captive brothers from their tombs beneath the sands of the east. Once my lord releases his brothers, The Sin War will once again know the fury of the three.")
	end,
}

register_cell( "the_black_king", "story_tome" )
{
	-- Caves, level 12
	name = "The Black King",

	OnAct = function(self,c)
		ui.play_sound('sfx/narrator/nar09.wav')
		ui.plot_talk("Hail and sacrifice to Diablo, Lord of Terror and Destroyer of Souls. When I awoke my Master from his sleep, he attempted to posses a mortal's form. Diablo attempted to claim the body of King Leoric, but my master was too weak from his imprisonment. My Lord required a simple and innocent anchor to this world, and so found the boy Albrecht perfect for the task. While the good King Leoric was left maddened by Diablo's unsuccessful possession, I kidnapped his son Albrecht and brought him before my Master. I now await Diablo's call and pray that I will be rewarded when he at last emerges as the Lord of this world.")
	end,
}

register_cell( "dark_exile", "story_tome" )
{
	-- Church, level 4
	name = "Dark Exile",

	OnAct = function(self,c)
		ui.play_sound('sfx/narrator/nar04.wav')
		ui.plot_talk("So it came to be that there was a great revolution within the Burning Hells known as the Dark Exile. The Lesser Evils overthrew the three Prime Evils and banished their spirit forms to the mortal realm. The Demons Belial (the Lord of Lies) and Azmodan (the Lord of Sin) fought to claim rulership of Hell during the abscence of the Three Brothers. All of Hell polarized between the factions of Belial and Azmodan while the forces of the High Heavens continually battered upon the very gates of Hell.")
	end,
}

register_cell( "sin_war", "story_tome" )
{
	-- Catacombs, level 8
	name = "Sin War",

	OnAct = function(self,c)
		ui.play_sound('sfx/narrator/nar05.wav')
		ui.plot_talk("Many Demons travelled to the mortal realm in search of the Three Brothers. These Demons were followed to the mortal plane by Angels who hunted them throughout the vast cities of the East. The Angels allied themselves with a secretive order of mortal Magi named the Horadrim, who quickly became adept at hunting Demons. They also made many dark enemies in the underworlds.")
	end,
}

register_cell( "binding_of_the_three", "story_tome" )
{
	-- Caves, level 12
	name = "Binding of the Three",

	OnAct = function(self,c)
		ui.play_sound('sfx/narrator/nar06.wav')
		ui.plot_talk("So it came to be that the Three Prime Evils were banished in spirit form to the mortal realm and after sewing chaos across the East for decades, they were hunted down by the cursed Order of the mortal Horadrim. The Horadrim used artifacts called Soulstones to contain the essence of Mephisto, the Lord of Hatred and his brother Baal, the Lord of Destruction. The youngest brother - Diablo, the Lord of Terror - escaped to the west. Eventually the Horadrim captured Diablo within a Soulstone as well, and buried him under an ancient, forgotten Cathedral. There, the Lord of Terror sleeps and awaits the time of his rebirth. Know ye that he will seek a body of youth and power to possess - one that is innocent and easily controlled. He will then arise to free his Brothers and once more fan the flames of the Sin War...")
	end,
}

-- Quest-related cells

register_cell "kings_sarcophagus"
{
	name   = "King's sarcophagus",
	flags  = { cfBlockMove, cfBlockChange },
	pic    = "°",
	piclow = "?",
	color  = LIGHTGRAY
}

register_cell "blind_marker"
{
	name = "blind_marker",
	pic = ".",
	color = LIGHTGRAY
}


register_cell "locked_chest"
{
	name   = "locked chest",
	flags  = { cfBlockMove, cfBlockChange },
	pic    = "þ",
	piclow = "?",
	color  = WHITE,

	OnAct = function(self,c)
		if player.quest["sign"] == 2 then
			self:drop_item("tavern_sign",c)
			self:set_cell(c,"open_chest")
		else
			ui.msg("@<\"I can't open this yet.\"@>")
			player:play_sound(24);
		end
	end,
}

register_cell "pedestal"
{
	name  = "pedestal",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "_",
	color = LIGHTGRAY,
}

register_cell "magic_rock"
{
	name  = "magic rock",
	flags = { cfBlockMove, cfBlockChange },
	color = BLUE,
	pic   = "*",

	OnAct = function(self,c)
		self:drop_item("sky_rock", c)
		self:set_cell( c, "pedestal" )
	end,
}

register_cell "pedestal_of_blood"
{
	name  = "pedestal of blood",
	flags = { cfBlockMove, cfBlockChange },
	pic   = "_",
	color = RED,

	OnAct = function(self,c)
		if player.quest["valor"] == 0 or player.quest["valor"] == 4 then return	end
		local qitem = player:get_item( "blood_stone" )
		if qitem then
			ui.msg("You put the blood stone onto the pedestal.")
			qitem:destroy()
			if player.quest["valor"] == 1 then
				self:set_cell( coord.new( c.x-9, c.y-4 ), "closed_door")
			elseif player.quest["valor"] == 2 then
				self:set_cell( coord.new( c.x+9, c.y-4 ), "closed_door")
			elseif player.quest["valor"] == 3 then
				self:move_walls("moving_wall_1")
				self:drop_item("arkaine's_valor", coord.new(c.x, c.y-10))
			end
			player.quest["valor"] = player.quest["valor"] + 1
		end
	end,
}

register_cell "zhar_bookshelf"
{
	name   	= "bookshelf",
	flags   = { cfBlockMove, cfBlockChange },
	pic     = '"',
	color  	= BROWN,

	OnAct = function(self,c)
		local zhar = self:find("zhar_the_mad")
		if zhar then
			ui.play_sound("sfx/monsters/zhar02.wav")
			ui.plot_talk("Arrrrgh! Your curiosity will be the death of you!!! (laughs) ")
			zhar:set_ai( AIMage )
		end
		self:drop_item( utils.random_item_req( self.depth * 2, { type = TYPE_BOOK } ),c )
		self:set_cell( c, "empty_bookshelf" )
	end,
}

