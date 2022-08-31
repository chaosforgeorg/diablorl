core.register_blueprint "quest"
{
	id          = { true,  core.TSTRING },
	name        = { true,  core.TSTRING },
	message     = { true,  core.TSTRING },
	level       = { false, core.TIDIN("levels") },
	completed   = { true,  core.TNUMBER },
	failed      = { false, core.TNUMBER, 255 },
	score       = { false, core.TNUMBER, 0 },
	enabled     = { false, core.TBOOL,  true },

	map         = { false, core.TSTRING },
	map_key     = { false, core.TTABLE },
	gossip      = { false, core.TTABLE },
	gossipwav   = { false, core.TTABLE },

	OnJournal   = { true,  core.TFUNC },
	OnCreate    = { false, core.TFUNC },
	OnEnter     = { false, core.TFUNC },
	OnKillAll   = { false, core.TFUNC },
}
-- TODO: gossip and gossipwav should be in one table!

register_quest "tomes"
{
	-- this "quest" is just a place to store tome info
	-- it is never displayed
	name      = "",
	enabled   = false,
	completed = 1,
	message   = "",

	OnJournal = function() end,
}

register_quest "butcher"
{
	name      = "The Butcher",
	level     = "level2",
	completed = 2, -- 1 = initiated, 2 = killed butcher
	score     = 20000,
	message   = "killed the Butcher.",
	map       = [[
####*##*##*####
#.............#
#.............#
#.............#
*...%%%%%%%...*
#...%,:,:,%...#
#...%,,:,:%...#
*...%B:,,:+...*
#...%:,::,%...#
#...%,:,,,%...#
*...%%%%%%%...*
#.............#
#.............#
#.............#
####*##*##*####
]],
	map_key = {
		["#"] = "stone_wall",
		["."] = "floor",
		["+"] = "closed_door",
		['B'] = {"bloody_floor","the_butcher"},
		['%'] = "bloody_stone_wall",
		[','] = "bloody_floor",
		[':'] = "bloody_corpse",
	},

	gossip = {
		ogden = "Yes, Farnham has mumbled something about a hulking brute who wielded a fierce weapon. I believe he called him a butcher.",
		gillian = "When Farnham said something about a butcher killing people, I immediately discounted it. But since You brought it up, maybe it is true.",
		griswold = "I saw what Farnham calls the Butcher as it swathed a path through the bodies of my friends. He swung a cleaver as large as an axe, hewing limbs and cutting down brave men  where they stood. I was separated  from the fray by a host of small screeching demons and somehow found the stairway leading out. I never saw that hideous beast again, but his blood-stained visage haunts me to this day.",
		pepin = "By the light, I know of this vile demon. There were many that bore the scars of his wrath upon their bodies when the few survivors of the charge led by Lazarus crawled from the cathedral. I don't know what he used to slice open his victims, but it could not have been of this world. It left wounds festering with disease and even I found them almost impossible to treat. Beware if you plan to battle this fiend...",
		cain = "It seems that the Archbishop Lazarus goaded many of the townsmen into venturing into the labyrinth to find the king's missing son. He played upon their fears and whipped them into a frenzied mob. None of them  were prepared for what lay within the cold earth... Lazarus abandoned them down there - left in the clutches of unspeakable horrors - to die.",
		farnham = "Big! Big cleaver killing all my friends. Couldn't stop him, had to run away, couldn't save them. Trapped in a room with so many bodies... so many friends... noooooooooo!",
		adria = "The Butcher is a sadistic creature that delights in the torture and pain of others. You have seen his handiwork in the drunkard Farnham. His destruction will do much to ensure the safety of this village.",
		wirt = "I know more than you'd think about that grisly fiend. His little friends got a hold of me and managed to get my leg before Griswold pulled me out of that hole.\n\nI'll put it bluntly - kill him before he kills you and adds your corpse to his collection."
	},

	gossipwav = {
		adria = "witch10.wav",
		cain = "storyt10.wav",
		farnham = "drunk10.wav",
		gillian = "bmaid08.wav",
		griswold = "bsmith10.wav",
		ogden = "tavown08.wav",
		wirt = "pegboy10.wav",
		pepin = "healer08.wav",
	},

	OnJournal = function()
		ui.play_sound("sfx/towners/wound01.wav");
		ui.plot_talk("Please, listen to me. The Archbishop Lazarus, he led us down here to find the lost prince. The bastard led us into a trap! Now everyone is dead... Killed by a demon he called the Butcher. Avenge us! Find this Butcher and slay him so that our souls may finally rest...")
	end,
}

register_quest "water"
{
	name      = "Poisoned Water Supply",
	level     = "level2",
	completed = 3, 	-- 1 = initiated, 2 = talked to pepin, 3 = cleaned water cave,
					-- 4 = fountain refreshed, 5 = got reward
	score     = 20000,
	message   = "purified the town water supply.",

	gossip = {
		cain = "Hmm, I don't know what I can really tell you about this that will be of any help. The water that fills our wells comes from an underground spring. I have heard of a tunnel that leads to a great lake - perhaps they are one and the same. Unfortunately, I do not know what would cause our water supply to be tainted.",
		griswold = "Pepin has told you the truth. We will need fresh water badly, and soon. I have tried to clear one of the smaller wells, but it reeks of stagnant filth. It must be getting clogged at the source.",
		adria = "The people of Tristram will die if you cannot restore fresh water to their wells.\n\nKnow this - Demons are at the heart of this matter, but they remain ignorant of what they have spawned.",
		pepin = "Please, you must hurry. Every hour that passes brings us closer to having no water to drink.\n\nWe cannot survive for long without your help.",
		wirt = "For once, I'm with you. My business runs dry - so to speak - if I have no market to sell to. You better find out what is going on, and soon!",
		gillian = "My grandmother is very weak, and Garda says that we cannot drink the water from the wells. Please, can you do something to help us?",
		farnham = "(scoffs) You drink water?",
		ogden = "I have always tried to keep a large supply of foodstuffs and drink in our storage cellar, but with the entire town having no source of fresh water, even our stores will soon run dry.\n\nPlease, do what you can or I don't know what we will do."
	},

	gossipwav = {
		adria = "witch04.wav",
		cain = "storyt04.wav",
		farnham = "drunk04.wav",
		gillian = "bmaid04.wav",
		griswold = "bsmith04.wav",
		ogden = "tavown02.wav",
		wirt = "pegboy04.wav",
		pepin = "healer21.wav",
	},

	OnJournal = function()
		ui.play_sound("sfx/towners/healer20.wav")
		ui.plot_talk("I'm glad I caught up to you in time! Our wells have become brackish and stagnant and some of the townspeople have become ill from drinking them. Our reserves of fresh water are quickly running dry. I believe that there is a passage that leads to the springs that serve our town. Please find what has caused this calamity, or we all will surely perish.")
	end,
}

register_quest "leoric_quest"
{
	name      = "The Curse of King Leoric",
	level     = "level3",
	completed = 3, -- 1 = got quest, 2 = talked to Ogden, 3 = killed Leoric, 4 = reported back to Ogden
	score     = 30000,
	message   = "granted eternal rest to the Skeleton King.",
	map       = [[
####*####*####*#####
#..................#
#..................#
#..................#
*...8@@@@@@@@@8....#
#...@@@@@@@@@@@....#
#...@@@@@@@@@@@....#
#...@@@@@@@@@@88...#
#...@@@@@@@@@@@....*
*...@@@@@@@@@@>....*
#...@@@@@@@@@@@....*
#...@@@@@@@@@@88...#
#...@@@@@@@@@@@....#
#...@@@@@@@@@@@....#
*...8@@@@@@@@@8....#
#..................#
#..................#
#..................#
####*####*####*#####
]],
	map_key = {
		["#"] = "stone_wall",
		["."] = "floor",
		["+"] = "closed_door",
		['8'] = "statue",
		['@'] = "vault",
		['>'] = "stairs_down_special",
	},

	gossip = {
		cain = "Ahh, the story of our King, is it? The tragic fall of Leoric was a harsh blow to this land. The people always loved the King, and now they live in mortal fear of him. The question that I keep asking myself is how he could have fallen so far from the Light, as Leoric had always been the holiest of men. Only the vilest powers of Hell could so utterly destroy a man from within...",
		griswold = "I made many of the weapons and most of the armor that King Leoric used to outfit his knights. I even crafted a huge two-handed sword of the finest mithril for him, as well as a field crown to match. I still cannot believe how he died. But it must have been some sinister force that drove him insane!",
		adria = "The dead who walk among the living follow the cursed King. He holds the power to raise yet more warriors for an ever-growing army of the Undead. If you do not stop his reign, he will surely march across this land and slay all who still live here.",
		pepin = "The loss of his son was too much for King Leoric. I did what I could to ease his madness, but in the end it overcame him. A black curse has hung over this kingdom from that day forward, but perhaps if you were to free his spirit from his Earthly prison, the curse would be lifted...",
		wirt = "Look, I'm running a business here. I DON'T sell information, and I DON'T care about some King that's been dead longer than I've been alive. If you need something to use against this King of the Undead, then I can help you out...",
		gillian = "I don't like to think about how the King died. I like to remember him for the kind and just ruler that he was. His death was so sad and seemed very wrong, somehow.",
		farnham = "I don't care about that. Listen, no skeleton is gonna be MY king. Leoric is King. King, so you hear me? HAIL TO THE KING!",
		ogden = "As I told you, Good Master, the King was entombed three levels below. He's down there, waiting in the putrid darkness for his chance to destroy this land..."
	},

	gossipwav = {
		adria = "witch01.wav",
		cain = "storyt01.wav",
		farnham = "drunk01.wav",
		gillian = "bmaid01.wav",
		griswold = "bsmith01.wav",
		ogden = "tavown22.wav",
		wirt = "pegboy01.wav",
		pepin = "healer01.wav",
	},

	OnJournal = function()
		ui.play_sound("sfx/towners/tavown21.wav")
		ui.plot_talk("The village needs your help, Good Master! Some months ago King Leoric's son, Prince Albrecht, was kidnapped. The King went into a rage and scoured the village for his missing child. With each passing day, Leoric seemed to slip deeper into madness. He sought to blame innocent townsfolk for the boy's disappearance and had them brutally executed. Less than half of us survived his insanity...\n\nThe King's knights and priests tried to placate him, but he turned against them and sadly, they were forced to kill him. With his dying breath the King called down a terrible curse upon his former followers. He vowed that they would serve him in darkness forever...\n\nThis is where things take an even darker twist than I thought possible! Our former King has risen from his eternal sleep and now commands a legion of Undead Minions within the labyrinth. His body was buried in a tomb three levels beneath the Cathedral. Please, good Master, put his soul at ease by destroying his now cursed form...")
	end,
}

register_quest "gharbad_quest"
{
	name      = "Gharbad the Weak",
	level     = "level4",
	score     = 5000,
	message   = "was patient with Gharbad the Weak.",
	completed = 7, -- see Gharbad in npc_unique.lua

	-- no gossip for this quest

	OnJournal = function()
		ui.play_sound("sfx/monsters/garbud01.wav");
		ui.plot_talk("Pleeeease, no hurt, no kill. Keep alive and next time good bring to you.")
	end,
}

register_quest "sign"
{
	name      = "Ogden's sign",
	level     = "level4",
	completed = 3, -- 1 = initiated, 2 = Snotspill, 3,4 = completed, 5 = Snotspill|sign, 6 = failed,
	failed    = 5,
	score     = 40000,
	message   = "retrieved Ogden's tavern sign.",
	map       = [[
####*##*##*####
#.............#
#.............#
#..#########..#
*..,OO#,,,,#..*
#..#OO,,,%,#..#
#..#########..#
*..#,#ooooo#..*
#..#,:ooooo#..#
#..#,#@#@#@#..#
*..#>:S,,,,,..*
#..#########..#
#.............#
#.............#
####*##*##*####
]],
	map_key = {
		["#"] = "stone_wall",
		["."] = "floor",
		[","] = "floor_nospawn",
		["+"] = "closed_door",
		['>'] = "stairs_down",
		[':'] = "moving_grate_1",
		['@'] = "moving_wall_1",
		['%'] = "locked_chest",
		['S'] = {"floor_nospawn", "snotspill"},
		['O'] = {"floor_nospawn", "overlord"},
		['o'] = {"floor_nospawn", "dark_one_spear"},
	},

	gossip = {
		cain = "I see that this strange behavior puzzles you as well. I would surmise that since many Demons fear the Light of the Sun and believe that it holds great power, it may be that the Rising Sun depicted on the sign you speak of has led them to believe that it too holds some arcane powers. Hmm, perhaps they are not all as smart as we had feared...",
		griswold = "Demons stole Ogden's Sign, you say? That doesn't sound much like the atrocities I've heard of - or seen.\n\nDemons are concerned with ripping out your heart, not your signpost.",
		adria = "No Mortal can truly understand the mind of the Demon.\n\nNever let their erratic actions confuse you, as that too may be their plan.",
		pepin = "My goodness, Demons running about the village at night, pillaging our homes - is nothing sacred? I hope that Ogden and Garda are all right. I suppose that they would come to see me if they were hurt...",
		wirt = "What - is he saying I took that? I suppose that Griswold is on his side, too.\n\nLook, I got over simple sign stealing months ago. You can't turn a profit on a piece of wood.",
		gillian = "Oh, my! Is that where the sign went? My grandmother and I must have slept right through the whole thing. Thank the Light that those monsters didn't attack the Inn.",
		farnham = "You know what I think? Somebody took that sign, and they gonna want lots of money for it. If I was Ogden... and I'm not, but if I was... I'd just buy a new sign with some pretty drawing on it. Maybe a nice mug of ale or a piece of cheese..."
	},

	gossipwav = {
		adria = "witch02.wav",
		cain = "storyt02.wav",
		farnham = "drunk02.wav",
		gillian = "bmaid02.wav",
		griswold = "bsmith02.wav",
--		ogden = "",
		wirt = "pegboy02.wav",
		pepin = "healer02.wav",
	},

	OnJournal = function()
		ui.play_sound("sfx/towners/tavown24.wav")
		ui.plot_talk("Master, I have a strange experience to relate. I know that you have a great knowledge of those monstrosities that inhabit the Labyrinth, and this is something that I cannot understand for the very life of me... I was awakened during the night by a scraping sound just outside of my Tavern. When I looked out from my bedroom, I saw the shapes of small Demon-like creatures in the inn yard. After a short time, they ran off, but not before stealing the sign to my Inn. I don't know why the demons would steal my sign but leave my family in peace... 'Tis strange, no?")
	end,
}

register_quest "sky_rock_quest"
{
	name      = "Magic Rock",
	level     = "level5",
	enabled   = false,
	completed = 2, -- 1 = accepted, 2 = picked up the magic rock, 3 = finished
	score     = 50000,
	message   = "found the Magic Rock for Griswold.",

	gossip = {
		adria 	= "The Heaven Stone is very powerful, and were it any but Griswold who bid you find it, I would prevent it. He will harness its powers and its use will be for the good of us all.",
		cain 	= "Griswold speaks of the Heaven Stone that was destined for the enclave located in the East. It was being taken there for further study. This stone glowed with an Energy that somehow granted vision beyond that which a normal man could possess. I do not know what secrets it holds, my friend, but finding this stone would certainly prove most valuable.",
		farnham = "I used to have a nice ring; it was a really expensive one, with blue and green and red and silver. Don't remember what happened to it, though. I really miss that ring...",
		gillian = "Well, a caravan of some very important people did stop here, but that was quite a while ago. They had strange accents and were starting on a long journey, as I recall.\n\nI don't see how you could hope to find anything that they would have been carrying.",
		griswold ="I am still waiting for you to bring me that Stone from the Heavens. I know that I can make something powerful out of it.",
		ogden 	= "The caravan stopped here to take on some supplies for their journey to the East. I sold them quite an array of fresh fruits and some excellent sweetbreads that Garda has just finished baking. Shame what happened to them...",
		wirt 	= "If anyone can make something out of that rock, Griswold can. He knows what he is doing, and as much as I try to steal his customers, I respect the quality of his work.",
		pepin 	= "I don't know what it is that they thought they could see with that rock, but I will say this. If rocks are falling from the Sky, you had better be careful!",
    },

	gossipwav = {
		adria 	= "witch20.wav",
		cain 	= "storyt20.wav",
		farnham = "drunk19.wav",
		gillian = "bmaid18.wav",
		griswold ="bsmith24.wav",
		ogden 	= "tavown18.wav",
		wirt 	= "pegboy18.wav",
		pepin 	= "healer18.wav",
    },

	OnJournal = function()
		ui.play_sound("bsmith24.wav")
		ui.plot_talk("Stay for a moment - I have a story you might find interesting. A caravan that was bound for the the Eastern Kingdoms passed through here some time ago. It was supposedly carrying a piece of the Heavens that had fallen to Earth! The caravan was ambushed by cloaked riders just north of here along the roadway. I searched the wreckage for this Sky Rock, but it was nowhere to be found. If you should find it, I believe that I can fashion something useful from it.")
	end,
}

register_quest "valor"
{
	name = "Arkaine's Valor",
	level = "level5",
	completed = 5, -- 1 = accepted, 2 = first stone, 3 = second stone, 4 = third stone, 5 = valor pickup (completed)
	score = 75000,

	message = "uncovered the Arkaine's Valor.",

	map = [[
######*######*######*######
#.........................#
#.........................#
#.........................#
#.........#######.........#
#.........#,,,,,#.........#
#......####O,,,O####......#
#......#,,,,,,,,,,,#......#
*......#,,O,,,,,O,,#......*
#...#######,,,,,#######...#
#...#,,,,,#,,,,,#,,,,,#...#
#...#,O,O,#,,,,,#,O,O,#...#
#...#,,,,,#,,,,,#,,,,,#...#
#...#,,,,,#,,,,,#,,,,,#...#
#...#,,,,,#,,,,,#,,,,,#...#
#...#,O,O,#@@@@@#,O,O,#...#
#...#,,,,,#,,,,,#,,,,,#...#
*...#######,,_,,#######...*
#......#,,,,,,,,,,,#......#
#......#,,,,,,,,,,,#......#
#......#,,###+###,,#......#
#......#,,#,,,,,#,,#......#
#......####,,,,,####......#
#......#,,,,,,,,,,,#......#
#......#,,,,,",,,,,#......#
#......#,,,,,,,,,,,#......#
*......####,,,,,####......*
#.........#,,,,,#.........#
#.........##+#+##.........#
#.........................#
#.........................#
#.........................#
###*#########*#########*###
]],
	map_key = {
		["#"] = "stone_wall",
		["."] = "floor",
		[","] = "floor_nospawn",
		["+"] = "closed_door",
		['_'] = "pedestal_of_blood",
		['"'] = "book_of_blood",
		['@'] = "moving_wall_1",
		['O'] = {"floor_nospawn", "horned_demon"},
	},

	gossip = {
		adria 	= "Should you find these stones of blood, use them carefully.\n\nThey way is fraught with danger and your only hope rests within your self-trust.",
		cain 	= "The Gateway of Blood and the Halls of Fire are landmarks of mystic origin. Wherever this book you read from resides, it is surely a place of great power.\n\nLegends speak of a pedestal that is carved from obsidian stone and has a pool of boiling blood atop its bone-encrusted surface. There are also allusions to stones of blood that will open a door that guards an ancient treasure...\n\nThe nature of this treasure is shrouded in speculation, my friend, but it is said that the ancient hero Arkaine placed the holy armor Valor in a secret vault. Arkaine was the first mortal to turn the tide of the Sin War and chase the Legions of Darkness back to the Burning Hells.\n\nJust before Arkaine died, his armor was hidden away in a secret vault. It is said that when this holy armor is again needed, a hero will arise to don Valor once more. Perhaps you are that hero...",
		farnham = "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZzzzzzzzzzzzzzz...",
		gillian = "The story of the magic armor called Valor is something I often heard the boys talk about. You had better ask one of the men in the village.",
		griswold ="The armor known as Valor could be what tips the scales in your favor. I will tell you that many have looked for it - including myself. Arkaine hid it well, my friend, and it will take more than a bit of luck to unlock the secrets that have kept it concealed oh, lo these many years.",
		ogden 	= "Every child hears the story of Arkaine and his mystic armor known as Valor. If you could find its resting place, you would be well-protected against the Evil in the Labyrinth.",
		wirt 	= "You intend to find the armor known as Valor?\n\nNo one has ever figured out where Arkaine stashed the stuff, and if my contacts couldn't find it, I seriously doubt you ever will, either.",
		pepin 	= "Hmm... It sounds like something I should remember, but I've been so busy learning new cures and creating better elixirs that I must have forgotten. Sorry...",
    },

	gossipwav = {
		adria 	= "witch15.wav",
		cain 	= "storyt15.wav",
		farnham = "drunk15.wav",
		gillian = "bmaid13.wav",
		griswold ="bsmith14.wav",
		ogden 	= "tavown13.wav",
		wirt 	= "pegboy14.wav",
		pepin 	= "healer13.wav",
    },

	OnJournal = function()
		player:play_sound("10")
		ui.plot_talk("...And so, locked beyond the Gateway of Blood and past the Hall of Fire, Valor awaits for the Hero of Light to awaken...")
	end,
}

register_quest "bone_chamber"
{
	name      = "The Chamber of Bone",
	level     = "level6",
	completed = 2, -- 1 = accepted, 2 = finished
	score     = 80000,
	message   = "learned the Guardian spell.",

	map       = [[
###*##*##*###
#...........#
#...........#
*..#@@#@@#..*
#..@,,,,,@..#
#..@,,,,,@..#
*..#,,>,,#..*
#..@,,,,,@..#
#..@,,,,,@..#
*..#@@#@@#..*
#...........#
#...........#
###*##*##*###
]],
	map_key = {
		["#"] = "stone_wall",
		["."] = "floor",
		[","] = "floor_nospawn",
		["+"] = "closed_door",
		['>'] = "stairs_down_special",
		['@'] = "moving_wall_1"
	},

	gossip = {
		adria 	= "You will become an eternal servant of the Dark Lords should you perish within this cursed domain.\n\nEnter the Chamber of Bone at your own peril.",
		cain 	= "A book that speaks of a chamber of human bones? Well, a Chamber of Bone is mentioned in certain archaic writings that I studied in the Libraries of the East. These tomes inferred that when the Lords of the Underworld desired to protect great treasures, they would create domains where those who died in attempt to steal that treasure would be forever bound to defend it. A twisted, but strangely fitting, end?",
		farnham = "Okay, so listen. There's this Chamber of Wood, see. And his wife, you know - her - tells the tree... cause you gotta wait. Then I says, that might work against him, but if you think I'm gonna pay for this... You... uh... yeah.",
		gillian = "I am afraid that I haven't heard anything about that. Perhaps Cain the storyteller could be of some help.",
		griswold ="I know nothing of this place, but you may try asking Cain. He talks about many things, and it would not surprise me if he had some answers to your question.",
		ogden 	= "I am afraid that I don't know anything about that, Good Master. Cain has many books that may be of some help.",
		wirt 	= "A vast and mysterious treasure, you say? Maybe I could be interested in picking up a few things from you... Or better yet, don't you need some rare and expensive supplies to get you through this ordeal?",
		pepin 	= "This sounds like a very dangerous place. If you venture there, please take great care.",
    },

	gossipwav = {
		adria 	= "witch07.wav",
		cain 	= "storyt07.wav",
		farnham = "drunk07.wav",
		gillian = "bmaid06.wav",
		griswold ="bsmith07.wav",
		ogden 	= "tavown05.wav",
		wirt 	= "pegboy07.wav",
		pepin 	= "healer05.wav",
    },

	OnJournal = function()
		player:play_sound("01")
		ui.plot_talk("Beyond the Hall of Heroes lies the Chamber of Bone. Eternal death awaits any who would seek to steal the treasures secured within this room. So speaks the Lord of Terror, and so it is written.")
	end,
}

register_quest "halls_of_blind"
{
	name      = "Halls of Blind",
	level     = "level7",
	completed = 1, -- 1 = finished
	score     = 80000,
	message   = "cleared Halls of Blind.",

	map = [[
####*########*#######*####
#........................#
#........................#
#........................#
*...###########..........*
#...#,,,,,,,,,#..........#
#...@,,,,,h,,,#..........#
#...#,,#####,,#..........#
#...#,h#h,h#,,#..........#
#...#,,#,X,+,,#..........#
#...#,,#h,,#,,#..........#
#...#,h#####,,########...#
*...#,,,h,,h,,,,,,h,,#...#
#...#,,,,,,,,,h,,,,,,#...*
#...########,,#####h,#...#
#..........#,,#,,h#,,#...#
#..........#,,+,,,#,,#...#
#..........#,,#h,h#h,#...#
#..........#,,#####,,#...#
#..........#,,,h,,,,,@...#
#..........#,,,,,,,,,#...#
*..........###########...*
#........................#
#........................#
#........................#
####*#######*########*####
]],
	map_key = {
		["#"] = "stone_wall",
		[","] = "floor_nospawn",
		["."] = "floor",
		["+"] = "closed_door",
		['@'] = "moving_wall_1",
		['h'] = {"floor_nospawn", "illusion_weaver"},
		['X'] = "blind_marker"
	},

	gossip = {
		adria 	= "This is a place of great anguish and terror, and so serves its master well.\n\nTread carefully or you may yourself be staying much longer than you had anticipated.",
		cain 	= "You recite an interesting rhyme written in a style that reminds me of other works. Let me think now - what was it?\n\n...Darkness shrouds the Hidden. Eyes glowing unseen with only the sounds of razor claws briefly scraping to torment those poor souls who have been made sightless for all eternity. The prison for those so Damned is named the Halls of the Blind...",
		farnham = "Look here... (chuckles) That's pretty funny, huh? Get it? Blind - look here? (laughs)",
		gillian = "If you have questions about blindness, you should talk to Pepin. I know that he gave my grandmother a potion that helped clear her vision, so maybe he can help you, too.",
		griswold ="I am afraid that I have neither heard nor seen a place that matches your vivid description, my friend. Perhaps Cain the storyteller could be of some help.",
		ogden 	= "I never much cared for poetry. Occasionally, I had cause to hire minstrels when the Inn was doing well, but that seems like such a long time ago now.\n\nWhat? Oh, yes... uh, well, I suppose you could see what someone else knows.",
		wirt 	= "Let's see, am I selling you something? No. Are you giving me money to tell you about this? No. Are you now leaving and going to talk to the storyteller who lives for this kind of thing? Yes.",
		pepin 	= "This does seem familiar, somehow. I seem to recall reading something very much like that poem while researching the history of demonic afflictions. It spoke of a place of great Evil that... Wait - you're not going there, are you?",
    },

	gossipwav = {
		adria 	= "witch12.wav",
		cain 	= "storyt12.wav",
		farnham = "drunk12.wav",
		gillian = "bmaid10.wav",
		griswold ="bsmith12.wav",
		ogden 	= "tavown10.wav",
		wirt 	= "pegboy11.wav",
		pepin 	= "healer10.wav",
    },

	OnJournal = function()
		player:play_sound("11")
		ui.plot_talk("I can see what you see not -\n\nVision milky, then eyes rot.\n\nWhen you turn, they will be gone,\n\nWhispering their hidden song.\n\nThen you see what cannot be -\n\nShadows move where light should be.\n\nOut of darkness, out of mind,\n\nCast down into the Halls of the Blind.")
	end,
}

register_quest "mad_mage"
{
	name      = "Zhar the Mad",
	level     = "level8",
	completed = 2, -- 1 = accepted, 2 = finished
	score     = 75000,
	message   = "interrupted Zhar the Mad's studies.",

	map = [[
####*###*##*####
#..............#
#..............#
#..............#
*...########...*
#...#,,,,,,#...#
#...#,",",,#...#
#...#,,,,Zs#...#
#...#,",",,#...#
*...#,,,,,,#...*
#...#,",",,#...#
#...#,,,,,,#...#
#...#,",,,,#...#
#...#,,,,,,#...#
*...####,,,#...*
#..............#
#..............#
#..............#
####*###*##*####
]],
	map_key = {
		["#"] = "stone_wall",
		[","] = "floor_nospawn",
		["."] = "floor",
		["+"] = "closed_door",
		['"'] = "library_book",
		['Z'] = {"floor", "zhar_the_mad"},
		['s'] = "zhar_bookshelf"
	},

	OnJournal = function()
		ui.play_sound("sfx/monsters/zhar01.wav")
		ui.plot_talk("What?! Why are you here? All these interruptions are enough to make one insane. Here, take this and leave me to my work. Trouble me no more!")
	end,
}

register_quest "mushroom"
{
	name      = "Black Mushroom",
	level     = "level9",
	completed = 2, -- 1 = accepted, 2 = finished
	failed    = 3,    -- can never be completed, switches into demon brain instead
	score     = 50000,
	enabled   = false,
	message   = "found the Black Muschroom for Adria.",
	--[[
	Character: "Now THAT'S one big mushroom."
	player:play_sound('95')
	Adria: "Yes. This will be perfect for a brew that I am creating. By the way, the Healer is looking for the Brain of some Demon or another so he can treat those who have been afflicted by their poisonous venom. I believe that he intends to make an elixir from it. If you can help him find what he needs, please see if you can get a sample of the elixir for me."
	ui.play_sound("witch24.wav")
	]]
	gossip = {
		adria 	= "It's a big, Black Mushroom that I need. Now run off and get it for me so that I can use it for a special concoction that I am working on.",
		cain 	= "The Witch Adria seeks a Black Mushroom? I know as much about Black Mushrooms as I do about Red Herrings. Perhaps Pepin the Healer could tell you more, but this is something that cannot be found in any of my stories or books.",
		farnham = "Ogden mixes a mean Black Mushroom, but I get sick if I drink that. Listen, listen... Here's the secret - MODERATION IS THE KEY!",
		gillian = "I think Ogden might have some mushrooms in the storage cellar. Why don't you ask him?",
		griswold ="If Adria doesn't have one of these, you can bet that's a rare thing indeed. I can offer you no more help than that, but it sounds like a... why, a huge, gargantuan, swollen, bloated mushroom! Well, good hunting, I suppose.",
		ogden 	= "Let me just say this. Both Garda and I would never, ever serve Black Mushrooms to our honored guests. If Adria wants some mushrooms in her stew, then that is her business, but I can't help you find any. Black Mushrooms... DISGUSTING!",
		wirt 	= "I don't have any mushrooms of ANY size or color for sale. How about something a bit more useful?",
		},

	gossipwav = {
		adria 	= "witch23.wav",
		cain 	= "storyt21.wav",
		farnham = "drunk20.wav",
		gillian = "bmaid19.wav",
		griswold ="bsmith19.wav",
		ogden 	= "tavown19.wav",
		wirt 	= "pegboy19.wav",
    },

	OnJournal = function()
		ui.play_sound("witch22.wav")
		ui.plot_talk("What do we have here? Interesting. It looks like a Book of Reagents. Keep your eyes open for a Black Mushroom. It should be fairly large and easy to identify. If you find it, bring it to me, won't you?")
	end,
}

 register_quest "demon_brain"
 {
	name      = "Black Mushroom",
	level     = "level9",
	completed = 2, -- 1 = accepted, 2 = finished
	score     = 100000,
	enabled   = false,
	message   = "helped Adria to brew the Spectral Elixir.",
	--[[
	Pepin: "Excellent, this is just what I had in mind. I was able to finish the elixir without this, but it can't hurt to have this to study. Would you please carry this to the Witch? I believe that she is expecting it."
	ui.play_sound('healer27.wav')
	Adria: "What? NOW you bring me that elixir from the Healer? (sighs) I was able to finish my brew without it. Why don't you just keep it..."
	ui.play_sound('witch26.wav')
	]]
	gossip = {
		adria 	= "Yes. This will be perfect for a brew that I am creating. By the way, the Healer is looking for the Brain of some Demon or another so he can treat those who have been afflicted by their poisonous venom. I believe that he intends to make an elixir from it. If you can help him find what he needs, please see if you can get a sample of the elixir for me.",
		cain 	= "The Witch Adria seeks a Black Mushroom? I know as much about Black Mushrooms as I do about Red Herrings. Perhaps Pepin the Healer could tell you more, but this is something that cannot be found in any of my stories or books.",
		farnham = "Ogden mixes a mean Black Mushroom, but I get sick if I drink that. Listen, listen... Here's the secret - MODERATION IS THE KEY!",
		gillian = "I think Ogden might have some mushrooms in the storage cellar. Why don't you ask him?",
		griswold ="If Adria doesn't have one of these, you can bet that's a rare thing indeed. I can offer you no more help than that, but it sounds like a... why, a huge, gargantuan, swollen, bloated mushroom! Well, good hunting, I suppose.",
		ogden 	= "Let me just say this. Both Garda and I would never, ever serve Black Mushrooms to our honored guests. If Adria wants some mushrooms in her stew, then that is her business, but I can't help you find any. Black Mushrooms... DISGUSTING!",
		wirt 	= "I don't have any mushrooms of ANY size or color for sale. How about something a bit more useful?",
		pepin   = "The Witch told me that you were searching for the Brain of a Demon to assist me in creating my elixir. It should be of great value to the many who are injured by those foul beasts, if I can just unlock the secrets I suspect that its alchemy holds. If you can remove the Brain of a Demon when you kill it, I would be grateful if you could bring it to me.",
    },

	gossipwav = {
		adria 	= "witch24.wav",
		cain 	= "storyt21.wav",
		farnham = "drunk20.wav",
		gillian = "bmaid19.wav",
		griswold ="bsmith19.wav",
		ogden 	= "tavown19.wav",
		wirt 	= "pegboy19.wav",
		pepin 	= "healer26.wav",
    },

	OnJournal = function()
		ui.play_sound("witch22.wav")
		ui.plot_talk("What do we have here? Interesting. It looks like a Book of Reagents. Keep your eyes open for a Black Mushroom. It should be fairly large and easy to identify. If you find it, bring it to me, won't you?")
	end,
}

register_quest "anvil"
{
	name      = "Anvil of Fury",
	level     = "level10",
	completed = 2, -- 1 = accepted, 2 = finished
	score     = 120000,
	enabled   = false,
	message   = "found the Anvil of Fury for Griswold.",
	--[[
	Character: "I need to get this to Griswold."
	player:play_sound('89')
	Griswold: "I can hardly believe it! This is the Anvil of Fury - Good work, my friend. Now we'll show those bastards that there are no weapons in Hell more deadly than those made by men! Take this and may Light protect you."
	ui.play_sound('bsmith23.wav')
	]]
	gossip = {
		adria 	= "There are many artifacts within the Labyrinth that hold powers beyond the comprehension of mortals. Some of these hold fantastic power that can be used by either the Light or the Darkness. Securing the Anvil from below could shift the course of the Sin War towards the Light.",
		cain 	= "Griswold speaks of the Anvil of Fury - a legendary artifact long searched for, but never found. Crafted from the metallic bones of the razor pit demons, the Anvil of Fury was smelt around the skulls of the five most powerful Magi of the underworld. Carved with runes of power and chaos, any weapon or armor forged upon this anvil will be immersed into the realm of chaos, imbedding it with magical properties. It is said that the unpredictable nature of chaos makes it difficult to know what the outcome of this smithing will be...",
		farnham = "Griswold can't sell his anvil. What will he do then? And I'd be angry too if someone took my anvil!",
		gillian = "Griswold's father used to tell some of us when we were growing up about a giant anvil that was used to make mighty weapons. He said that when a hammer was struck upon this anvil, the ground would shake with a great fury. Whenever the Earth moves, I always remember that story...",
		griswold ="Nothing yet, eh? Well, keep searching. A weapon forged upon the Anvil could be your best hope, and I am sure that I can make you one of the legendary proportions.",
		ogden 	= "Don't you think that Griswold would be a better person to ask about this? He's quite handy, you know.",
		wirt 	= "If you were to find this artifact for Griswold, it could put a serious damper on my business here. Awwww, you'll never find it.",
		pepin 	= "If you had been looking for information on the Pestle of Curing or the Silver Chalice of Purification, I could have assisted you, my friend. However, in this matter, you would be better served to speak to either Griswold or Cain.",
    },

	gossipwav = {
		adria 	= "witch14.wav",
		cain 	= "storyt14.wav",
		farnham = "drunk14.wav",
		gillian = "bmaid12.wav",
		griswold ="bsmith22.wav",
		ogden 	= "tavown12.wav",
		wirt 	= "pegboy13.wav",
		pepin 	= "healer12.wav",
    },

	OnJournal = function()
		ui.play_sound("bsmith21.wav")
		ui.plot_talk("Greetings! It's always a pleasure to see one of my best customers! I know that you have been venturing deeper into the Labyrinth, and there is a story I was told that you may find worth the time to listen to...\n\nOne of the men who returned from the Labyrinth told me about a mystic anvil that he came across during his escape. His description reminded me of legends I had heard in my youth about the Burning Hellforge where powerful weapons of magic are crafted. The legend had it that deep within the Hellforge rested the Anvil of Fury! This anvil contained within it the very essence of the demonic underworld...\n\nIt is said that any weapon crafted upon the burning Anvil is imbued with great power. If this anvil is indeed the Anvil of Fury, I may be able to make you a weapon capable of defeating even the darkest Lord of Hell! Find the Anvil for me, and I'll get to work!")
	end,
}

register_quest "warlord"
{
	name      = "Warlord of Blood",
	level     = "level13",
	completed = 2, -- 1 = accepted, 2 = finished
	score     = 150000,
	enabled   = false,
	message   = "vanquished the Warlord of Blood.",
	--[[
	Warlord: "My blade sings for your blood, mortal. And by my dark masters, it shall not call in vain!"
	ui.play_sound("sfx/monsters/warlrd01.wav")
	Character:Your reign of pain has ended!
	player:play_sound('94')
	]]
	gossip = {
		adria 	= "His prowess with the blade is awesome, and he has lived for thousands of years knowing only warfare. I am sorry... I can not see if you will defeat him.",
		cain 	= "I know of only one legend that speaks of such a warrior as you describe. His story is found within the ancient chronicles of the Sin War...\n\nStained by a thousand years of war, blood and death, the Warlord of Blood stands upon a mountain of his tattered victims. His dark blade screams a black curse to the living; a tortured invitation to any who would stand before this Executioner of Hell.\n\nIt is also written that although he was once a mortal who fought beside the Legion of Darkness during the Sin War, he lost his humanity to his insatiable hunger for blood.",
		farnham = "Always you gotta talk about blood? What about flowers, and sunshine, and that pretty girl that brings the drinks. Listen here, friend - you're obsessive, you know that?",
		gillian = "If you are to battle such a fierce opponent, may Light be your guide and your defender. I will keep you in my thoughts.",
		griswold ="Dark and wicked legends surrounds the one Warlord of Blood. Be well prepared, my friend, for he shows no mercy or quarter.",
		ogden 	= "I am afraid that I haven't heard anything about such a vicious warrior, Good Master. I hope that you do not have to fight him, for he sounds extremely dangerous.",
		wirt 	= "I haven't ever dealt with this Warlord you speak of, but he sounds like he's going through a lot of swords. Wouldn't mind supplying his armies...",
		pepin 	= "Cain would be able to tell you much more about something like this than I would ever wish to know.",
    },

	gossipwav = {
		adria 	= "witch18.wav",
		cain 	= "storyt18.wav",
		farnham = "drunk17.wav",
		gillian = "bmaid16.wav",
		griswold ="bsmith17.wav",
		ogden 	= "tavown16.wav",
		wirt 	= "pegboy17.wav",
		pepin 	= "healer16.wav",
    },

	OnJournal = function()
		player:play_sound('12')
		ui.plot_talk("The armories of Hell are home to the Warlord of Blood. In his wake lay the mutilated bodies of thousands. Angels and Man alike have been cut down to fulfill his endless sacrifices to the Dark Ones who scream for one thing - blood.")
	end,
}

register_quest "lachdanan"
{
	name      = "Lachdanan",
	level     = "level14",
	completed = 2, -- 1 = accepted, 2 = finished
	score     = 150000,
	enabled   = false,
	message   = "redeemed Lachdanan's soul.",
	--[[
	Lachdanan: "You have not found the Golden Elixir. I fear that I am doomed for eternity. Please, keep trying..."
	ui.play_sound("sfx/monsters/lach02.wav")
	Character: "I need to get this to Lachdanan."
	player:play_sound('88')
	Lachdanan: "You have saved my soul from Damnation, and for that I am in your debt. If there is ever a way that I can repay you from beyond the grave I will find it, but for now - take my Helm. On the journey I am about to take, I will have little use for it. May it protect you against the dark powers below. Go with the Light, my friend..."
	ui.play_sound("sfx/monsters/lach03.wav")
	]]
	gossip = {
		adria 	= "You may meet people who are trapped within the labyrinth, such as Lachdanan.\n\nI sense in him honor and great guilt. Aid him, and you aid all of Tristram.",
		cain 	= "You claim to have spoken with Lachdanan? He was a great hero during his life. Lachdanan was an honorable and just man who served his King faithfully for years. But of course, you already know that. Of those who were caught within the grasp of the King's curse, Lachdanan would be the least likely to submit to the Darkness without a fight, so I suppose that your story could be true. If I were in your place, my friend, I would find a way to release him from his torture.",
		farnham = "Lachdanan is dead. Everybody knows that, and you can't fool me into thinking any other way. You can't talk to the dead. I know!",
		gillian = "I've never heard of a Lachdanan before. I'm sorry, but I don't think that I can be of much help to you.",
		griswold ="If it is actually Lachdanan that you have met, then I would advise that you aid him. I dealt with him on several occasions and found him to be honest and loyal in nature. The curse that fell upon the followers of King Leoric would fall especially hard upon him.",
		ogden 	= "You speak of a brave warrior long dead! I'll have no such talk of speaking with departed souls in my inn yard, thank you very much.",
		wirt 	= "Wait, let me guess. Cain was swallowed up in a gigantic fissure that opened beneath him. He was incinerated in a ball of Hellfire, and can't answer your questions anymore. Oh, that isn't what happened? Then I guess you'll be buying something or you'll be on your way.",
		pepin 	= "A Golden Elixir, you say. I have never concocted a potion of that color before, so I can't tell you how it would effect you if you were to try to drink it. As your healer, I strongly advise that should you find such an Elixir, do as Lachdanan asks and do not try to use it.",
    },

	gossipwav = {
		adria 	= "witch13.wav",
		cain 	= "storyt13.wav",
		farnham = "drunk13.wav",
		gillian = "bmaid11.wav",
		griswold ="bsmith13.wav",
		ogden 	= "tavown11.wav",
		wirt 	= "pegboy12.wav",
		pepin 	= "healer11.wav",
    },

	OnJournal = function()
		ui.play_sound("sfx/monsters/lach01.wav")
		ui.plot_talk("Please, don't kill me, just hear me out. I was once Captain of King Leoric's knights, upholding the laws of this land with justice and honor. Then his dark curse fell upon us for the role we played in his tragic death. As my fellow knights succumbed to their twisted fate, I fled from the King's burial chamber, searching for some way to free myself from the curse. I failed...\n\nI have heard of a Golden Elixir that could lift the curse and allow my soul to rest, but I have been unable to find it. My strength now wanes, and with it, the last of my humanity as well. Please aid me and find the Elixir. I will repay your efforts - I swear upon my honor.")
	end,
}

register_quest "lazarus"
{
	name      = "Archbishop Lazarus",
	level     = "level15",
	completed = 2, -- 1 = accepted, 2 = finished
	score     = 200000,
	enabled   = false,
	message   = "repayed Lazarus for his treachery.",
	--[[
	Lazarus: "Abandon your foolish quest! All that awaits you is the wrath of my master! You are too late to save the child! Now you'll join him -- in Hell!"
	ui.play_sound("sfx/monsters/laz01.wav")
	Character: "Your madness ends here, betrayer!"
	player:play_sound('83')
	]]
	gossip = {
		adria 	= "I did not know this Lazarus of whom you speak, but I do sense a great conflict within his being. He poses a great danger, and will stop at nothing to serve the Powers of Darkness which have claimed him as theirs.",
		cain 	= "You must hurry and rescue Albrecht from the hands of Lazarus. The Prince and the people of this Kingdom are counting on you!",
		farnham = "They stab, then bite, then they're all around you. Liar! Liar! They're all dead! Dead! Do you hear me? They just keep falling and falling... their blood spilling out all over the floor... All his fault...(groans)",
		gillian = "I remember Lazarus as being a very kind and giving man. He spoke at my mother's funeral, and was supportive of my grandmother and myself in a very troubled time. I pray every night that somehow, he is still alive and safe.",
		griswold ="I was there when Lazarus led us into the Labyrinth. He spoke of holy retribution, but when we started fighting those Hellspawn, he did not so much as lift his mace against them. He just ran deeper into the dim, endless chambers that were filled with the Servants of Darkness!",
		ogden 	= "Lazarus was the Archbishop who led many of the townspeople into the Labyrinth. I lost many good friends that day, and Lazarus never returned. I suppose he was killed along with most of the others. If you would do me a favor, Good Master, please do not talk to Farnham about that day.",
		wirt 	= "Yes, the righteous Lazarus, who was sooo effective against those monsters down there. Didn't help save my leg, did it? Look, I'll give you a free piece of advice. Ask Farnham, he was there.",
		pepin 	= "I was shocked when I heard of what the townspeople were planning to do that night. I thought that of all people, Lazarus would have had more sense than that. He was an Archbishop, and always seemed to care so much for the townsfolk of Tristram. So many were injured, I could not save them all...",
    },

	gossipwav = {
		adria 	= "witch03.wav",
		cain 	= "storyt37.wav",
		farnham = "drunk03.wav",
		gillian = "bmaid03.wav",
		griswold ="bsmith03.wav",
		ogden 	= "tavown01.wav",
		wirt 	= "pegboy03.wav",
		pepin 	= "healer03.wav",
    },

	OnJournal = function()
		ui.play_sound("storyt36.wav")
		ui.plot_talk("This does not bode well, for it confirms my darkest fears. While I did not allow myself to believe the Ancient Legends, I cannot deny them now. Perhaps the time has come to reveal who I am.\n\nMy true name is Deckard Cain the Elder, and I am the last descendant of an Ancient Brotherhood that was dedicated to safeguarding the secrets of a timeless Evil. An Evil that quite obviously has now been released.\n\nThe Archbishop Lazarus, once King Leoric's most trusted advisor, led a party of simple townsfolk into the Labyrinth to find the King's missing son, Albrecht. Quite some time passed before they returned, and only a few of them escaped with their lives.\n\nCurse me for a fool! I should have suspected his veiled treachery then. It must have been Lazarus himself who kidnapped Albrecht and has since hidden him within the Labyrinth. I do not understand why the Archbishop turned to the Darkness, or what his interest is in the child. Unless he means to sacrifice him to his Dark Masters!\n\nThat must be what he has planned! The survivors of his 'rescue party' say that Lazarus was last seen running into the deepest bowels of the Labyrinth. You must hurry and save the Prince from the Sacrificial Blade of this demented fiend!")
	end,
}

register_quest "diablo"
{
	name      = "Diablo",
	level     = "level15",
	completed = 2, -- 1 = accepted, 2 = finished
	score     = 500000,
	message   = "He defeated the mortal vessel of the Lord of Terror",

	OnJournal = function()
		ui.play_sound("storyt38.wav")
		ui.plot_talk("Your story is quite grim, my friend. Lazarus will surely burn in Hell for his horrific deed. The boy that you describe is NOT our Prince, but I believe that Albrecht may yet be in danger. The symbol of power that you speak of must be a portal in the very heart of the Labyrinth.\n\nKnow this, my friend - the Evil that you move against is the Dark Lord of Terror. He is known to mortal men as Diablo. It was he who was imprisoned within the labyrinth many centuries ago and I fear that he seeks to once again sow chaos in the Realm of Mankind. You must venture through the portal and destroy Diablo before it is too late!")
	end,
}
