core.register_blueprint ( "townperson", "npc" )
{
	ai      = AINPC,
	pic     = { false, core.TSTRING, "@" },
	color   = { false, core.TNUMBER, LIGHTGRAY },
	hpmin   = 1,
	hpmax   = 2,
	dmgmin  = 1,
	dmgmax  = 4,

	gossip   = { false, core.TTABLE },
	waypoint = { false, core.TBOOL },
}

register_npc( "ogden", "townperson" )
{
	name     = "Ogden, the tavern owner",
	waypoint = true,
	color    = BROWN,

	gossip = {
		{topic="Weapons",wav="tavown37.wav",text="Many adventurers have graced the tables of my tavern, and ten times as many stories have been told over as much ale. The only thing that I ever heard any of them agree on was this old axiom. Perhaps it will help you. You can cut the flesh, but you must crush the bone."},
		{topic="Griswold",wav="tavown38.wav",text="Griswold the blacksmith is extremely knowledgeable about weapons and armor. If you ever need work done on your gear, he is definitely the man to see."},
		{topic="Farnham",wav="tavown39.wav",text="Farnham spends far too much time here, drowning his sorrows in cheap ale. I would make him leave, but he did suffer so during his time in the Labyrinth."},
		{topic="Adria",wav="tavown40.wav",text="Adria is wise beyond her years, but I must admit - she frightens me a little. Well, no matter. If you ever have need to trade in items of sorcery, she maintains a strangely well-stocked hut just across the river."},
		{topic="Decard Cain",wav="tavown41.wav",text="If you want to know more about the history of our village, the storyteller Cain knows quite a bit about the past."},
		{topic="Wirt",wav="tavown43.wav",text="Wirt is a rapscallion and a little scoundrel. He was always getting into trouble, and it's no surprise what happened to him. He probably went fooling about someplace that he shouldn't have been. I feel sorry for the boy, but I don't abide the company that he keeps."},
		{topic="Pepin",wav="tavown44.wav",text="Pepin is a good man - and certainly the most generous in the village. He is always attending to the needs of others, but trouble of some sort or another does seem to follow him wherever he goes..."},
		{topic="Gillian",wav="tavown45.wav",text="Gillian, my Barmaid? If it were not for her sense of duty to her grand-dam, she would have fled from here long ago. Goodness knows I begged her to leave, telling her that I would watch after the old woman, but she is too sweet and caring to have done so."},
	},

	OnCreate = function( self )
		self:add_property("greeting",true)
	end,

	OnTalk = function( self )
		self:set_travel_point()
		local qitem = player:get_item("tavern_sign")
		if self.greeting then
			ui.play_sound("sfx/towners/Tavown00.wav")
			ui.plot_talk("Thank goodness you've returned! Much has changed since you lived here, my friend. All was peaceful until the dark riders came and destroyed our village. Many were cut down where they stood, and those who took up arms were slain or dragged away to become slaves - or worse. The church at the edge of town has become desecrated, and is being used for dark rituals. The screams that echo in the night are inhuman, but some of our townsfolk may yet survive. Follow the path that runs between my tavern and the blacksmith’s shop to find the church and save who you can. Perhaps I can tell you more if we speak again. Good luck.")
			self.greeting = false
		elseif player.quest["leoric_quest"] == 1 then
			quests["leoric_quest"].OnJournal()
			player.quest["leoric_quest"] = 2
		elseif player.quest["leoric_quest"] == 3 then
			ui.play_sound("sfx/towners/tavown23.wav")
			ui.plot_talk("The curse of our King has passed, but I fear that it was only part of a greater Evil at work. However, we may yet be saved from the Darkness that consumes our land, for your victory is a good omen. May Light guide you on your way, Good Master.")
			player.quest["leoric_quest"] = 4
		elseif quests["sign"].enabled and player.quest["sign"] == 0 and player.maxdepth > 2 then
			quests["sign"].OnJournal()
			player.quest["sign"] = 1
		elseif player.quest["sign"] == 2 and qitem then
			player.quest["sign"] = 3
			ui.play_sound("sfx/towners/tavown25.wav")
			ui.plot_talk("Oh, you didn't have to bring back my sign, but I suppose that it does save me the expense of having another one made. Well, let me see. What could I give you as a fee for finding it? Hmmm. What have we here... Ah, yes! This cap was left in one of the rooms by a magician who stayed here some time ago. Perhaps it may be of some value to you.")
			qitem:destroy()
			player:get_level():drop_unique("harlequin_crest",player.position)
		else
			ui.play_sound("sfx/towners/tavown36.wav")
			ui.msg("Ogden says : \"Greetings good master. Welcome to the Tavern of the Rising Sun.\"")
			ui.talk( "ogden", {
				{ "Talk to Ogden", function() ui.talk_topics("ogden") end },
				{ "Leave the Tavern", false }
			})
		end
	end

}

register_npc( "griswold", "townperson" )
{
	name     = "Griswold, the blacksmith",
	waypoint = true,
	color    = LIGHTGRAY,

	gossip = {
		{topic="Mace",wav="bsmith45.wav",text="If you're looking for a good weapon, let me show this to you. Take your basic blunt weapon, such as a mace. Works like a charm against most of those undying horrors down there, and there's nothing better to shatter skinny little skeletons!"},
		{topic="Axe",wav="bsmith46.wav",text="The axe? Aye, that's a good weapon, balanced against any foe. Look how it cleaves the air, and then imagine a nice fat demon head in its path. Keep in mind, however, that it is slow to swing - but talk about dealing a heavy blow!"},
		{topic="Sword",wav="bsmith47.wav",text="Look at that edge, that balance. A sword in the right hands, and against the right foe, is the master of all weapons. Its keen blade finds little to hack or pierce on the undead, but against a living, breathing enemy, a sword will better slice their flesh!"},
		{topic="Repair",wav="bsmith48.wav",text="Your weapons and armor will show the signs of your struggles against the Darkness. If you bring them to me, with a bit of work and a hot forge, I can restore them to top fighting form."},
		{topic="Adria",wav="bsmith49.wav",text="While I have to practically smuggle in the metals and tools I need from caravans that skirt the edges of our damned town, that witch, Adria, always seems to get whatever she needs. If I knew even the smallest bit about how to harness magic as she did, I could make some truly incredible things."},
		{topic="Decard Cain",wav="bsmith51.wav",text="Sometimes I think that Cain talks too much, but I guess that is his calling in life. If I could bend steel as well as he can bend your ear, I could make a suit of court plate good enough for an Emperor!"},
		{topic="Gillian",wav="bsmith50.wav",text="Gillian is a nice lass. Shame that her gammer is in such poor health or I would arrange to get both of them out of here on one of the trading caravans."},
		{topic="Farnham",wav="bsmith52.wav",text="I was with Farnham that night that Lazarus led us into Labyrinth. I never saw the Archbishop again, and I may not have survived if Farnham was not at my side. I fear that the attack left his soul as crippled as, well, another did my leg. I cannot fight this battle for him now, but I would if I could."},
		{topic="Pepin",wav="bsmith53.wav",text="A good man who puts the needs of others above his own. You won't find anyone left in Tristram - or anywhere else for that matter - who has a bad thing to say about the healer."},
		{topic="Wirt",wav="bsmith55.wav",text="That lad is going to get himself into serious trouble... or I guess I should say, again. I've tried to interest him in working here and learning an honest trade, but he prefers the high profits of dealing in goods of dubious origin. I cannot hold that against him after what happened to him, but I do wish he would at least be careful."},
		{topic="Ogden",wav="bsmith56.wav",text="The Innkeeper has little business and no real way of turning a profit. He manages to make ends meet by providing food and lodging for those who occasionally drift through the village, but they are as likely to sneak off into the night as they are to pay him. If it weren't for the stores of grains and dried meats he kept in his cellar, why, most of us would have starved during that first year when the entire countryside was overrun by demons."},
	},

	OnTalk = function(self)
		self:set_travel_point()
		local qitem = player:get_item("sky_rock_quest")
		if (quests["sky_rock_quest"].enabled) and (player.maxdepth >= 4)
										and (player.quest["sky_rock_quest"] == 0) then
			quests["sky_rock_quest"].OnJournal()
			player.quest["sky_rock_quest"] = 1
		elseif player.quest["sky_rock_quest"] == 2 and qitem then
			ui.play_sound('bsmith26.wav')
			ui.plot_talk("Let me see that - aye... Aye, it is as I believed. Give me a moment.\n\nAh, here, you are. I arranged pieces of the Stone within a silver ring that my father left me. I hope it serves you well.")
			player:remove( qitem )
			player:get_level():drop_unique("empyrean_band", player.position)
			player.quest["sky_rock_quest"] = 3
		else
			ui.play_sound("sfx/towners/Bsmith44.wav")
			ui.msg( "Griswold says : \"What can I do for you?\"" )
			ui.talk( "griswold", {
				{ "Talk to Griswold", function() ui.talk_topics("griswold") end },
				{ "Buy basic items", function() world.shop( "griswold_shop" ) end },
				{ "Buy premium items", function() world.shop( "griswold_premium_shop" ) end },
				{ "Sell items", function() shops.util.OnEnter = shops.util.funcs.GriswoldSell; world.shop( "util" ) end },
				{ "Repair items", function() shops.util.OnEnter = shops.util.funcs.GriswoldRepair; world.shop( "util" ) end },
				{ "Repair equipment", 	function()
											local price = 0
											for i=1,ITEMS_EQ do
												local item = player.eq[i]
												if item then
													price = price + item:get_price(3)
												end
											end
											if price > 0 then
												if ui.msg_confirm("Repair all equipment for "..tostring(price).."?") then
													if price > player.gold then
														ui.msg( 'Griswold says "Sorry '..player:salutation()..', you have not enough money."')
													else
														player:remove_gold( price )
														for i=1,ITEMS_EQ do
															local item = player.eq[i]
															if item then
																item:repair()
																ui.msg( 'Griswold repaired your equipment for '..price..' gold pieces.')
															end
														end
													end
												end
											else
												ui.msg("You have nothing to repair")
											end
										end },
				{ "Leave the shop", false }
			})
		end
	end,
}

register_npc( "adria", "townperson" )
{
	name     = "Adria, the witch",
	color    = DARKGRAY,
	waypoint = true,

	gossip = {
		{topic="Books",wav="witch39.wav",text="Wisdom is earned, not given. If you discover a tome of knowledge, devour its words. Should you already have knowledge of the arcane mysteries scribed within a book, remember - that level of mastery can always increase."},
		{topic="Scrolls",wav="witch40.wav",text="The greatest power is often the shortest lived. You may find ancient words of power written upon scrolls of parchment. The strength of these scrolls lies in the ability of either apprentice or adept to cast them with equal ability. Their weakness is that they must first be read aloud and can never be kept at the ready in your mind. Know also that these scrolls can be read but once, so use them with care."},
		{topic="Recharge",wav="witch41.wav",text="Though the heat of the sun is beyond measure, the mere flame of a candle is of greater danger. No energies, no matter how great, can be used without the proper focus. For many spells, ensorcelled Staves may be charged with magical energies many times over. I have the ability to restore their power - but know that nothing is done without a price."},
		{topic="Help",wav="witch42.wav",text="The sum of our knowledge is in the sum of its people. Should you find a book or scroll that you cannot decipher, do not hesitate to bring it to me. If I can make sense of it I will share what I find."},
		{topic="Griswold",wav="witch43.wav",text="To a man who only knows Iron, there is no greater magic than Steel. The blacksmith Griswold is more of a sorcerer than he knows. His ability to meld fire and metal is unequaled in this land."},
		{topic="Gillian",wav="witch44.wav",text="Corruption has the strength of deceit, but innocence holds the power of purity. The young woman Gillian has a pure heart, placing the needs of her matriarch over her own. She fears me, but it is only because she does not understand me."},
		{topic="Decard Cain",wav="witch45.wav",text="A chest opened in darkness holds no greater treasure than when it is opened in the light. The storyteller Cain is an enigma, but only to those who do not look. His knowledge of what lies beneath the cathedral is far greater than even he allows himself to realize."},
		{topic="Farnham",wav="witch46.wav",text="The higher you place your faith in one man, the farther it has to fall. Farnham has lost his soul, but not to any demon. It was lost when he saw his fellow townspeople betrayed by the Archbishop Lazarus. He has knowledge to be gleaned, but you must separate fact from fantasy."},
		{topic="Pepin",wav="witch47.wav",text="The hand, the heart and the mind can perform miracles when they are in perfect harmony. The healer Pepin sees into the body in a way that even I cannot. His ability to restore the sick and injured is magnified by his understanding of the creation of elixirs and potions. He is as great an ally as you have in Tristram."},
		{topic="Wirt",wav="witch49.wav",text="There is much about the future we cannot see, but when it comes it will be the children who wield it. The boy Wirt has a blackness upon his soul, but he poses no threat to the town or its people. His secretive dealings with the urchins and unspoken guilds of nearby towns gain him access to many devices that cannot be easily found in Tristram. While his methods may be reproachful, Wirt can provide assistance for your battle against the encroaching Darkness."},
		{topic="Ogden",wav="witch50.wav",text="Earthen walls and thatched canopy do not a home create. The innkeeper Ogden serves more of a purpose in this town than many understand. He provides shelter for Gillian and her matriarch, maintains what life Farnham has left to him, and provides an anchor for all who are left in the town to what Tristram once was. His tavern, and the simple pleasures that can still be found there, provide a glimpse of a life that the people here remember. It is that memory that continues to feed their hopes for your success."},
	},

	OnTalk = function(self)
		self:set_travel_point()
		ui.play_sound("sfx/towners/Witch38.wav")
		ui.msg("Adria says : \"I sense a soul in search of answers.\"")
		ui.talk( "adria", {
			{ "Talk to Adria", function() ui.talk_topics("adria") end },
			{ "Buy items", function() world.shop( "adria_shop" ) end },
			{ "Sell items", function() shops.util.OnEnter = shops.util.funcs.AdriaSell; world.shop( "util" ) end },
			{ "Recharge staves", function() shops.util.OnEnter = shops.util.funcs.AdriaRecharge; world.shop( "util" ) end },
			{ "Leave the shack", false }
		})
	end,
}

register_npc( "pepin", "townperson" )
{
	name     = "Pepin, the healer",
	color    = WHITE,
	waypoint = true,

	gossip = {
		{topic="Regeneration",wav="healer38.wav",text="I have made a very interesting discovery. Unlike us, the creatures in the Labyrinth can heal themselves without the aid of potions or magic. If you hurt one of the monsters, make sure it is dead or it very well may regenerate itself."},
		{topic="Books",wav="healer39.wav",text="Before it was taken over by, well, whatever lurks below, the Cathedral was a place of great learning. There are many books to be found there. If you find any, you should read them all, for some may hold secrets to the workings of the Labyrinth."},
		{topic="Griswold",wav="healer40.wav",text="Griswold knows as much about the art of war as I do about the art of healing. He is a shrewd merchant, but his work is second to none. Oh, I suppose that may be because he is the only blacksmith left here."},
		{topic="Decard Cain",wav="healer41.wav",text="Cain is a true friend and a wise sage. He maintains a vast library and has an innate ability to discern the true nature of many things. If you ever have any questions, he is the person to go to."},
		{topic="Farnham",wav="healer42.wav",text="Even my skills have been unable to fully heal Farnham. Oh, I have been able to mend his body, but his mind and spirit are beyond anything I can do."},
		{topic="Adria",wav="healer43.wav",text="While I use some limited forms of magic to create the potions and elixirs I store here, Adria is a true sorceress. She never seems to sleep, and she always has access to many mystic tomes and artifacts. I believe her hut may be much more than the hovel it appears to be, but I can never seem to get inside the place."},
		{topic="Wirt",wav="healer45.wav",text="Poor Wirt. I did all that was possible for the child, but I know he despises that wooden peg that I was forced to attach to his leg. His wounds were hideous. No one - and especially such a young child - should have to suffer the way he did."},
		{topic="Ogden",wav="healer46.wav",text="I really don't understand why Ogden stays here in Tristram. He suffers from a slight nervous condition, but he is an intelligent and industrious man who would do very well wherever he went. I suppose it may be the fear of the many murders that happen in the surrounding countryside, or perhaps the wishes of his wife that keep him and his family where they are."},
		{topic="Gillian",wav="healer47.wav",text="Ogden's barmaid is a sweet girl. Her grandmother is quite ill, and suffers from delusions. She claims that they are visions, but I have no proof of that one way or the other."},
	},

	OnTalk = function(self)
		self:set_travel_point()
		if (quests["water"].enabled) then
			if player.quest["water"] == 1 then
				quests["water"].OnJournal()
				player.quest["water"] = 2
				return
			elseif player.quest["water"] == 4 then
				ui.play_sound("sfx/towners/Healer22.wav")
				ui.plot_talk("What's that you say - the mere presence of the Demons had caused the water to become tainted? Oh, truly a great Evil lurks beneath our town, but your perseverance and courage gives us hope. Please take this ring - perhaps it will aid you in the destruction of such vile creatures.")
				player:get_level():drop_unique("ring_of_truth", player.position )
				player.quest["water"] = 5
				return
			end
		end

		ui.play_sound("sfx/towners/Healer37.wav")
		ui.msg("Pepin says : \"What ails you, my friend?\"")
		ui.talk( "pepin", {
			{ "Talk to Pepin", function() ui.talk_topics("pepin") end },
			{ "Receive healing",function()
									player.hp = player.hpmax
									stats.inc("free_healing")
								end },
			{ "Buy items", function() world.shop("pepin_shop") end },
			{ "Leave healer's home", false }
		})
	end,
}

register_npc( "farnham", "townperson" )
{
	name     = "Farnham, the drunk",
	color    = DARKGRAY,
	waypoint = true,

	gossip = {
		{topic="Treasures",wav="drunk24.wav",text="No one ever lis... listens to me. Somewhere - I ain't too sure - but somewhere under the church is a whole pile o' gold. Gleamin' and shinin' and just waitin' for someone to get it."},
		{topic="Unique Items",wav="drunk25.wav",text="I know you gots your own ideas, and I know you're not gonna believe this, but that weapon you got there - it just ain't no good against those big brutes! Oh, I don't care what Griswold says, they can't make anything like they used to in the old days..."},
		{topic="Wirt",wav="drunk26.wav",text="If I was you... and I ain't... but if I was, I'd sell all that stuff you got and get out of here. That boy out there... He's always got somethin good, but you gotta give him some gold or he won't even show you what he's got."},
		{topic="Gillian",wav="drunk28.wav",text="The gal who brings the drinks? Oh, yeah, what a pretty lady. So nice, too."},
		{topic="Adria",wav="drunk29.wav",text="Why don't that old crone do somethin' for a change. Sure, sure, she's got stuff, but you listen to me... she's unnatural. I ain't never seen her eat or drink - and you can't trust somebody who doesn't drink at least a little."},
		{topic="Decard Cain",wav="drunk30.wav",text="Cain isn't what he says he is. Sure, sure, he talks a good story... some of 'em are real scary or funny... but I think he knows more than he knows he knows."},
		{topic="Griswold",wav="drunk31.wav",text="Griswold? Good old Griswold. I love him like a brother! We fought together, you know, back when... we... Lazarus... Lazarus... Lazarus!!!"},
		{topic="Pepin",wav="drunk32.wav",text="Hehehe, I like Pepin. He really tries, you know. Listen here, you should make sure you get to know him. Good fella like that with people always wantin' help. Hey, I guess that would be kinda like you, huh hero? I was a hero too..."},
		{topic="Wirt",wav="drunk34.wav",text="Wirt is a kid with more problems than even me, and I know all about problems. Listen here - that kid is gotta sweet deal, but he's been there, you know? Lost a leg! Gotta walk around on a piece of wood. So sad, so sad..."},
		{topic="Ogden",wav="drunk35.wav",text="Ogden is the best man in town. I don't think his wife likes me much, but as long as she keeps tappin' kegs, I'll like her just fine. Seems like I been spendin' more time with Ogden than most, but he's so good to me..."},
	},

	OnTalk = function(self)
		self:set_travel_point()
		ui.play_sound("sfx/towners/Drunk27.wav")
		ui.msg("Farnham says : \"Can't a fella drink in peace?\"")
		ui.talk( "farnham", {
			{ "Talk to Farnham", function() ui.talk_topics("farnham") end },
			{ "Say goodbye", false }
		})
	end,
}

register_npc( "wirt", "townperson" )
{
	name     = "Wirt, the peg-legged boy",
	color    = GREEN,
	waypoint = true,

	gossip = {
		{topic="Treasures",wav="pegboy33.wav",text="Not everyone in Tristram has a use - or a market - for everything you will find in the labyrinth. Not even me, as hard as that is to believe. Sometimes, only you will be able to find a purpose for some things."},
		{topic="Farnham",wav="pegboy34.wav",text="Don't trust everything the drunk says. Too many ales have fogged his vision and his good sense."},
		{topic="Selling items",wav="pegboy35.wav",text="In case you haven't noticed, I don't buy anything from Tristram. I am an importer of quality goods. If you want to peddle junk, you'll have to see Griswold, Pepin or that witch, Adria. I'm sure that they will snap up whatever you can bring them..."},
		{topic="Griswold",wav="pegboy36.wav",text="I guess I owe the blacksmith my life - what there is of it. Sure, Griswold offered me an apprenticeship at the smithy, and he is a nice enough guy, but I'll never get enough money to... well, let's just say that I have definite plans that require a large amount of gold."},
		{topic="Gillian",wav="pegboy37.wav",text="If I were a few years older, I would shower her with whatever riches I could muster, and let me assure you I can get my hands on some very nice stuff. Gillian is a beautiful girl who should get out of Tristram as soon as it is safe. Hmmm... maybe I'll take her with me when I go..."},
		{topic="Decard Cain",wav="pegboy38.wav",text="Cain knows too much. He scares the life out of me - even more than that woman across the river. He keeps telling me about how lucky I am to be alive, and how my story is foretold in legend. I think he's off his crock."},
		{topic="Farnham",wav="pegboy39.wav",text="Farnham - now there is a man with serious problems, and I know all about how serious problems can be. He trusted too much in the integrity of one man, and Lazarus led him into the very jaws of death. Oh, I know what it's like down there, so don't even start telling me about your plans to destroy the evil that dwells in that Labyrinth. Just watch your legs..."},
		{topic="Pepin",wav="pegboy40.wav",text="As long as you don't need anything reattached, old Pepin is as good as they come. If I'd have had some of those potions he brews, I might still have my leg..."},
		{topic="Adria",wav="pegboy42.wav",text="Adria truly bothers me. Sure, Cain is creepy in what he can tell you about the past, but that witch can see into your past. She always has some way to get whatever she needs, too. Adria gets her hands on more merchandise than I've seen pass through the gates of the King's Bazaar during High Festival."},
		{topic="Ogden",wav="pegboy43.wav",text="Ogden is a fool for staying here. I could get him out of town for a very reasonable price, but he insists on trying to make a go of it with that stupid tavern. I guess at the least he gives Gillian a place to work, and his wife Garda does make a superb Shepherd's pie..."},
	},

	OnTalk = function(self)
		self:set_travel_point()
		ui.play_sound("sfx/towners/Pegboy32.wav")
		ui.msg("Wirt says : \"Pssst... Over here...\"")
		if not world.get_shop("wirt_shop").item[1] then
			ui.talk( "wirt", {
				{ "Talk to Wirt", function() ui.talk_topics("wirt") end },
				{ "Say goodbye", false }
			})
		else
			ui.talk( "wirt", {
				{ "@dI have something to sale,", false },
				{ "@dbut it will cost @y50 gold@d", false },
				{ "@djust to have a look", false },
				{ "@d", false },
				{ "Talk to Wirt", function() ui.talk_topics("wirt") end },
				{ "What have you got?", function() world.shop("wirt_shop") end },
				{ "Say goodbye", false }
			})
		end
	end,
}

register_npc( "cain", "townperson" )
{
	name     = "Cain, the storyteller",
	color    = LIGHTBLUE,
	waypoint = true,

	gossip = {
		{topic="Books",wav="storyt26.wav",text="While you are venturing deeper into the Labyrinth you may find tomes of great knowledge hidden there. Read them carefully for they can tell you things that even I cannot."},
		{topic="Help",wav="storyt27.wav",text="I know of many myths and legends that may contain answers to questions that may arise in your journeys into the Labyrinth. If you come across challenges and questions to which you seek knowledge, seek me out and I will tell you what I can."},
		{topic="Griswold",wav="storyt28.wav",text="Griswold - a man of great action and great courage. I bet he never told you about the time he went into the Labyrinth to save Wirt, did he? He knows his fair share of the dangers to be found there, but then again - so do you. He is a skilled craftsman, and if he claims to be able to help you in any way, you can count on his honesty and his skill."},
		{topic="Ogden",wav="storyt29.wav",text="Ogden has owned and run the Rising Sun Inn and Tavern for almost four years now. He purchased it just a few short months before everything here went to hell. He and his wife Garda do not have the money to leave as they invested all they had in making a life for themselves here. He is a good man with a deep sense of responsibility."},
		{topic="Farnham",wav="storyt30.wav",text="Poor Farnham. He is a disquieting reminder of the doomed assembly that entered into the Cathedral with Lazarus on that dark day. He escaped with his life, but his courage and much of his sanity were left in some dark pit. He finds comfort only at the bottom of his tankard nowadays, but there are occasional bits of truth buried within his constant ramblings."},
		{topic="Adria",wav="storyt31.wav",text="The witch, Adria, is an anomaly here in Tristram. She arrived shortly after the Cathedral was desecrated while most everyone else was fleeing. She had a small hut constructed at the edge of town, seemingly overnight, and has access to many strange and arcane artifacts and tomes of knowledge that even I have never seen before."},
		{topic="Wirt",wav="storyt33.wav",text="The story of Wirt is a frightening and tragic one. He was taken from the arms of his mother and dragged into the labyrinth by the small, foul demons that wield wicked spears. There were many other children taken that day, including the son of King Leoric. The Knights of the palace went below, but never returned. The Blacksmith found the boy, but only after the foul beasts had begun to torture him for their sadistic pleasures."},
		{topic="Pepin",wav="storyt34.wav",text="Ah, Pepin. I count him as a true friend - perhaps the closest I have here. He is a bit addled at times, but never a more caring or considerate soul has existed. His knowledge and skills are equaled by few, and his door is always open."},
		{topic="Gillian",wav="storyt35.wav",text="Gillian is a fine woman. Much adored for her high spirits and her quick laugh, she holds a special place in my heart. She stays on at the tavern to support her elderly grandmother who is too sick to travel. I sometimes fear for her safety, but I know that any man in the village would rather die than see her harmed."},
	},

	OnTalk = function(self)
		self:set_travel_point()
		ui.play_sound("sfx/towners/storyt25.wav")
		ui.msg("Cain says : \"Hello, my friend! Stay a while, and listen!\"")
		ui.talk( "cain", {
			{ "Talk to Cain", function() ui.talk_topics("cain") end },
			{ "Identify an item", function() shops.util.OnEnter = shops.util.funcs.CainIdentify; world.shop( "util" ) end },
			{ "Say goodbye", false }
		})
	end,
}

register_npc( "gillian", "townperson" )
{
	name     = "Gillian, the barmaid",
	color    = LIGHTGREEN,
	waypoint = true,

    gossip = {
		{topic="Adria",wav="bmaid33.wav",text="The woman at the edge of town is a witch! She seems nice enough, and her name, Adria, is very pleasing to the ear, but I am very afraid of her. It would take someone quite brave, like you, to see what she is doing out there."},
		{topic="Visions",wav="bmaid32.wav",text="My grandmother had a dream that you would come and talk to me. She has visions, you know and can see into the future."},
		{topic="Griswold",wav="bmaid34.wav",text="Our Blacksmith is a point of pride to the people of Tristram. Not only is he a master craftsman who has won many contests within his guild, but he received praises from our King Leoric himself - may his soul rest in peace. Griswold is also a great hero; just ask Cain."},
		{topic="Decard Cain",wav="bmaid35.wav",text="Cain has been the storyteller of Tristram for as long as I can remember. He knows so much, and can tell you just about anything about almost everything."},
		{topic="Farnham",wav="bmaid36.wav",text="Farnham is a drunkard who fills his belly with ale and everyone else's ears with nonsense. I know that both Pepin and Ogden feel sympathy for him, but I get so frustrated watching him slip farther and farther into a befuddled stupor every night. "},
		{topic="Pepin",wav="bmaid37.wav",text="Pepin saved my grandmother's life, and I know that I can never repay him for that. His ability to heal any sickness is more powerful than the mightiest sword and more mysterious than any spell you can name. If you ever are in need of healing, Pepin can help you."},
		{topic="Wirt",wav="bmaid39.wav",text="I grew up with Wirt's mother, Canace. Although she was only slightly hurt when those hideous creatures stole him, she never recovered. I think she died of a broken heart. Wirt has become a mean-spirited youngster, looking only to profit from the sweat of others. I know that he suffered and has seen horrors that I cannot even imagine, but some of that darkness hangs over him still."},
		{topic="Ogden",wav="bmaid40.wav",text="Ogden and his wife have taken me and my grandmother into their home and have even let me earn a few gold pieces by working at the inn. I owe so much to them, and hope one day to leave this place and help them start a grand hotel in the east."},
	},

	OnTalk = function(self)
		self:set_travel_point()
		ui.play_sound("sfx/towners/Bmaid31.wav")
		ui.msg("Gillian says : \"Good day! How may I serve You?\"")
		ui.talk( "gillian", {
			{ "Talk to Gillian", function() ui.talk_topics( "gillian" ) end },
			{ "Say goodbye"    , false }
		})
	end,
}

register_npc( "cow", "townperson" )
{
	name  = "cow",
	pic   = "C",
	color = BROWN,

	OnCreate = function(self)
		self:add_property("talk_count",0)
	end,

	OnTalk = function(self)
		local travel_point = coord.new(63, 26)
		local level = self:get_level()
		if not ( level:has_travel_point( self ) ) then
			level:add_travel_point( travel_point, 'Cows' )
		end
		stats.inc("cow_talk")
		self.talk_count = self.talk_count + 1
		-- Alternate between two cow sounds
		ui.play_sound("sfx/towners/cow" .. ((self.talk_count % 2) + 1) .. ".wav")
		-- unused wavs
		-- 53: "Too Heavy!"
		if self.talk_count == 4 then
			ui.plot_talk("MOO!!!")
		elseif self.talk_count == 8 then
			ui.msg("@<\"Yes, that is a cow all right!\"@>")
			player:play_sound(52)
		elseif self.talk_count == 12 then
			ui.msg("@<\"I am not thirsty!\"@>")
			player:play_sound(49)
		elseif self.talk_count == 16 then
			ui.msg("@<\"I am no milkmaid!\"@>")
			player:play_sound(50)
		elseif self.talk_count >= 20 then
			ui.msg("@<\"Got milk?\"@>")
			player:play_sound(48)
			self.talk_count = 4
		else
			ui.plot_talk("Moo!")
		end
	end,
}

register_npc( "dying", "townperson" )
{
	name  = "dying townsman",
	color = RED,

	OnTalk = function(self)
		if player.quest["butcher"] == 0 then
			quests['butcher'].OnJournal()
			player.quest["butcher"] = 1
			self.name    = "slain townsman"
			self.picture = string.byte( "%" )
		elseif player.quest["butcher"] == 1 then
			ui.msg("@<\"Your death will be avenged.\"@>")
			player:play_sound('08')
		elseif player.quest["butcher"] == 2 then
			ui.msg("@<\"Rest in peace my friend.\"@>")
			player:play_sound('09')
			player.quest["butcher"] = 3
		end
	end,
}
