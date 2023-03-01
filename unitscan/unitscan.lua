local unitscan = CreateFrame'Frame'
local forbidden
local is_resting
local deadscan = false
unitscan:SetScript('OnUpdate', function() unitscan.UPDATE() end)
unitscan:SetScript('OnEvent', function(_, event, arg1)
	if event == 'ADDON_LOADED' and arg1 == 'unitscan' then
		unitscan.LOAD()
	elseif event == 'ADDON_ACTION_FORBIDDEN' and arg1 == 'unitscan' then
		forbidden = true
	elseif event == 'PLAYER_TARGET_CHANGED' then
		if UnitName'target' and strupper(UnitName'target') == unitscan.button:GetText() and not GetRaidTargetIndex'target' and (not IsInRaid() or UnitIsGroupAssistant'player' or UnitIsGroupLeader'player') then
			SetRaidTarget('target', 2)
		end
	elseif event == 'ZONE_CHANGED_NEW_AREA' or 'PLAYER_LOGIN' then
		local loc = GetRealZoneText()
		local _, instance_type = IsInInstance()
		is_resting = IsResting()
		nearby_targets = {}
		SetCVar("Sound_EnableErrorSpeech", 0) -- you're welcome
		if instance_type == "raid" or instance_type == "pvp" then return end
		if loc == nil then return end

		for name, zone in pairs(rare_spawns) do
			local reaction = UnitReaction("player", name)
			if not reaction or reaction < 4 then reaction = true else reaction = false end
			if reaction and (loc == zone or string.match(loc, zone) or zone == "A H") then 
				table.insert(nearby_targets, name)
			end
		end
	end
end)
unitscan:RegisterEvent'ADDON_LOADED'
unitscan:RegisterEvent'ADDON_ACTION_FORBIDDEN'
unitscan:RegisterEvent'PLAYER_TARGET_CHANGED'
unitscan:RegisterEvent'ZONE_CHANGED_NEW_AREA'
unitscan:RegisterEvent'PLAYER_LOGIN'

local BROWN = {.7, .15, .05}
local YELLOW = {1, 1, .15}
local CHECK_INTERVAL = .1
unitscan_targets = {}
local found = {}

rare_spawns = {
	-- ["Tablegrapes"] = "A H",
	-- ["Azurous"] = "Winterspring",
	--[[["General Colbatann"] = "Winterspring",
	["Kashock the Reaver"] = "Winterspring",
	["Lady Hederine"] = "Winterspring",
	["Alshirr Banebreath"] = "Felwood",
	["Dessecus"] = "Felwood",
	["Immolatus"] = "Felwood",
	["Monnos the Elder"] = "Azshara",
	["Scalebeard"] = "Azshara",
	["Brother Ravenoak"] = "Stonetalon Mountains",
	["Foreman Rigger"] = "Stonetalon Mountains",
	["Sister Riven"] = "Stonetalon Mountains",
	["Sorrow Wing"] = "Stonetalon Mountains",
	["Taskmaster Whipfang"] = "Stonetalon Mountains",
	["Aean Swiftrunner"] = "Northern Barrens",
	["Ambassador Bloodrage"] = "Northern Barrens",
	["Brontus"] = "Northern Barrens",
	["Captain Gerogg Hammertoe"] = "Southern Barrens",
	["Elder Mystic Razorsnout"] = "Northern Barrens",
	["Gesharahan"] = "Northern Barrens",
	["Hagg Taurenbane"] = "Southern Barrens",
	["Hannah Bladeleaf"] = "Northern Barrens",
	["Marcus Bel"] = "Northern Barrens",
	["Rocklance"] = "Northern Barrens",
	["Sister Rathtalon"] = "Northern Barrens",
	["Swiftmane"] = "Northern Barrens",
	["Swinegart Spearhide"] = "Northern Barrens",
	["Takk the Leaper"] = "Northern Barrens",
	["Thora Feathermoon"] = "Northern Barrens",
	["Captain Flat Tusk"] = "Durotar",
	["Felweaver Scornn"] = "Durotar",
	["Brimgore"] = "Dustwallow Marsh",
	["Sister Hatelash"] = "Mulgore",
	--["Heartrazor"] = "Thousand Needles",
	["Ironeye the Invincible"] = "Thousand Needles",
	["Vile Sting"] = "Thousand Needles",
	["Jin'Zallah the Sandbringer"] = "Tanaris",
	["Warleader Krazzilak"] = "Tanaris",
	["Gruff"] = "Un'Goro Crater",
	["King Mosh"] = "Un'Goro Crater",
	["Rex Ashil"] = "Silithus",
	["Scarlet Executioner"] = "Western Plaguelands",
	["Scarlet High Clerist"] = "Western Plaguelands",
	["Tamra Stormpike"] = "Hillsbrad Foothills",
	["Narillasanz"] = "Alterac Mountains",
	["Grimungous"] = "The Hinterlands",
	["Mith'rethis the Enchanter"] = "The Hinterlands",
	["Darbel Montrose"] = "Arathi Highlands",
	["Foulbelly"] = "Arathi Highlands",
	["Ruul Onestone"] = "Arathi Highlands",
	["Emogg the Crusher"] = "Loch Modan",
	["Siege Golem"] = "Badlands",
	["Highlord Mastrogonde"] = "Searing Gorge",
	["Hematos"] = "Burning Steppes",
	["Lord Captain Wyrmak"] = "Swamp of",
	["Jade"] = "Swamp of",
	["High Priestess Hai'watna"] = "Northern Stranglethorn",
	["Mosh'Ogg Butcher"] = "Northern Stranglethorn",
	["Anathemus"] = "Badlands",
	["Zaricotl"] = "Badlands",
	["Deviate Faerie Dragon"] = "Wailing Caverns",
	["Meshlok the Harvester"] = "Maraudon",
	["Blind Hunter"] = "Razorfen Kraul",
	["Earthcaller Halmgar"] = "Razorfen Kraul",
	["Razorfen Spearhide"] = "Razorfen Kraul",
	["Zerillis"] = "Zul'farrak",
	["Azshir the Sleepless"] = "Scarlet Monastery",
	["Hearthsinger Forresten"] = "Stratholme",
	["Skul"] = "Stratholme",
	["Stonespine"] = "Stratholme",
	["Deathsworn Captain"] = "Shadowfang Keep",
	["Dark Iron Ambassador"] = "Gnomeregan",
	["Lord Roccor"] = "Blackrock Depths",
	["Panzor the Invincible"] = "Blackrock Depths",
	["Pyromancer Loregrain"] = "Blackrock Depths",
	["Verek"] = "Blackrock Depths",
	["Warder Stilgiss"] = "Blackrock Depths",
	["Bannok Grimaxe"] = "Blackrock Spire",
	["Burning Felguard"] = "Blackrock Spire",
	["Crystal Fang"] = "Blackrock Spire",
	["Ghok Bashguud"] = "Blackrock Spire",
	["Spirestone Battle Lord"] = "Blackrock Spire",
	["Spirestone Butcher"] = "Blackrock Spire",
	["Spirestone Lord Magus"] = "Blackrock Spire",
	["Jed Runewatcher"] = "Blackrock Spire",
	["Bruegal Ironknuckle"] = "The Stockade",
	["Miner Johnson"] = "The Deadmines",
	["Skarr the Unbreakable"] = "Dire Maul",
	["Mushgog"] = "Dire Maul",
	["7:XT"] = "Badlands",
	["Accursed Slitherblade"] = "Desolace",
	["Achellios the Banished"] = "Thousand Needles",
	["Akkrilus"] = "Ashenvale",
	["Akubar the Seer"] = "Blasted Lands",
	["Alshirr Banebreath"] = "Felwood",
	["Antilos"] = "Azshara",
	["Antilus the Soarer"] = "Feralas",
	["Apothecary Falthis"] = "Ashenvale",
	["Araga"] = "Alterac Mountains",
	["Arash-ethis"] = "Feralas",
	["Azzere the Skyblade"] = "Southern Barrens",
	["Barnabus"] = "Badlands",
	["Bayne"] = "Tirisfal Glades",
	["Big Samras"] = "Hillsbrad Foothills",
	["Bjarn"] = "Dun Morogh",
	["Blackmoss the Fetid"] = "Teldrassil",
	["Bloodroar the Stalker"] = "Feralas",
	["Boss Galgosh"] = "Loch Modan",
	["Boulderheart"] = "Redridge Mountains",
	["Brack"] = "Westfall",
	["Marisa du'Paige"] = "Westfall",
	["Branch Snapper"] = "Ashenvale",
	["Broken Tooth"] = "Badlands",
	["Brokespear"] = "Northern Barrens",
	["Burgle Eye"] = "Dustwallow Marsh",
	["Carnivous the Breaker"] = "Darkshore",
	["Chatter"] = "Redridge Mountains",
	["Clack the Reaver"] = "Blasted Lands",
	["Clutchmother Zavas"] = "Un'Goro Crater",
	["Commander Felstrom"] = "Duskwood",
	["Cranky Benj"] = "Alterac Mountains",
	["Creepthess"] = "Hillsbrad Foothills",
	["Crimson Elite"] = "Western Plaguelands",
	["Cursed Centaur"] = "Desolace",
	["Cyclok the Mad"] = "Tanaris",
	["Dalaran Spellscribe"] = "Silverpine Forest",
	["Darkmist Widow"] = "Dustwallow Marsh",
	["Dart"] = "Dustwallow Marsh",
	["Death Flayer"] = "Durotar",
	["Death Howl"] = "Felwood",
	["Deatheye"] = "Blasted Lands",
	["Deathmaw"] = "Burning Steppes",
	["Deathspeaker Selendre"] = "Eastern Plaguelands",
	["Deeb"] = "Tirisfal Glades",
	["Diamond Head"] = "Feralas",
	["Digger Flameforge"] = "Southern Barrens",
	["Dishu"] = "Northern Barrens",
	["Dragonmaw Battlemaster"] = "Wetlands",
	["Dreadscorn"] = "Blasted Lands",
	["Drogoth the Roamer"] = "Dustwallow Marsh",
	["Duggan Wildhammer"] = "Eastern Plaguelands",
	["Duskstalker"] = "Teldrassil",
	["Dustwraith"] = "Zul'Farrak",
	["Eck'alom"] = "Ashenvale",
	["Edan the Howler"] = "Dun Morogh",
	["Enforcer Emilgund"] = "Mulgore",
	["Engineer Whirleygig"] = "Northern Barrens",
	["Fallen Champion"] = "Scarlet Monastery",
	["Farmer Solliden"] = "Tirisfal Glades",
	["Faulty War Golem"] = "Searing Gorge",
	["Fedfennel"] = "Elwynn Forest",
	["Fellicent's Shade"] = "Tirisfal Glades",
	["Fenros"] = "Duskwood",
	["Fingat"] = "Swamp of",
	["Firecaller Radison"] = "Darkshore",
	["Flagglemurk the Cruel"] = "Darkshore",
	["Foe Reaper 4000"] = "Westfall",
	["Foreman Grills"] = "Northern Barrens",
	["Foreman Jerris"] = "Western Plaguelands",
	["Foreman Marcrid"] = "Western Plaguelands",
	["Foulmane"] = "Western Plaguelands",
	["Fury Shelda"] = "Teldrassil",
	["Garneg Charskull"] = "Wetlands",
	["Gatekeeper Rageroar"] = "Azshara",
	["General Fangferror"] = "Azshara",
	["Geolord Mottle"] = "Durotar",
	["Geomancer Flintdagger"] = "Arathi Highlands",
	["Geopriest Gukk'rok"] = "Southern Barrens",
	["Swinegart Spearhide"] = "Southern Barrens",
	["Ghost Howl"] = "Mulgore",
	["Gibblesnik"] = "Thousand Needles",
	["Gibblewilt"] = "Dun Morogh",
	["Giggler"] = "Desolace",
	["Gilmorian"] = "Swamp of",
	["Gish the Unmoving"] = "Eastern Plaguelands",
	["Gluggle"] = "Northern Stranglethorn",
	["Gnarl Leafbrother"] = "Feralas",
	["Gnawbone"] = "Wetlands",
	["Gorefang"] = "Silverpine Forest",
	["Gorgon'och"] = "Burning Steppes",
	["Gravis Slipknot"] = "Alterac Mountains",
	["Great Father Arctikus"] = "Dun Morogh",
	["Greater Firebird"] = "Tanaris",
	["Gretheer"] = "Silithus",
	["Grimmaw"] = "Teldrassil",
	["Grimtooth"] = "Alterac Valley",
	["Grizlak"] = "Loch Modan",
	["Grizzle Snowpaw"] = "Winterspring",
	["Grubthor"] = "Silithus",
	["Gruff Swiftbite"] = "Elwynn Forest",
	["Gruklash"] = "Burning Steppes",
	["Grunter"] = "Blasted Lands",
	["Haarka the Ravenous"] = "Tanaris",
	["Hahk'Zor"] = "Burning Steppes",
	["Hammerspine"] = "Dun Morogh",
	["Harb Foulmountain"] = "Thousand Needles",
	["Hayoc"] = "Dustwallow Marsh",
	["Hed'mush the Rotting"] = "Eastern Plaguelands",
	["Heggin Stonewhisker"] = "Southern Barrens",
	["High General Abbendis"] = "Eastern Plaguelands",
	["Hissperak"] = "Desolace",
	["Humar the Pridelord"] = "Northern Barrens",
	["Huricanian"] = "Silithus",
	["Ironback"] = "The Hinterlands",
	["Ironspine"] = "Scarlet Monastery",
	["Jalinde Summerdrake"] = "The Hinterlands",
	["Jimmy the Bleeder"] = "Alterac Mountains",
	["Kaskk"] = "Desolace",
	["Kazon"] = "Redridge Mountains",
	["Kovork"] = "Arathi Highlands",
	["Kregg Keelhaul"] = "Tanaris",
	["Krellack"] = "Silithus",
	["Krethis Shadowspinner"] = "Silverpine Forest",
	["Kurmokk"] = "The Cape of Stranglethorn",
	["Lady Hederine"] = "Winterspring",
	["Lady Moongazer"] = "Darkshore",
	["Lady Sesspira"] = "Azshara",
	["Lady Szallah"] = "Feralas",
	["Lady Vespia"] = "Ashenvale",
	["Lady Vespira"] = "Darkshore",
	["Lady Zephris"] = "Hillsbrad Foothills",
	["Lapress"] = "Silithus",
	["Large Loch Crocolisk"] = "Loch Modan",
	["Leech Widow"] = "Wetlands",
	["Leprithus"] = "Westfall",
	["Licillin"] = "Darkshore",
	["Lo'Grosh"] = "Alterac Mountains",
	["Lord Angler"] = "Dustwallow Marsh",
	["Lord Condar"] = "Loch Modan",
	["Lord Darkscythe"] = "Eastern Plaguelands",
	["Lord Malathrom"] = "Duskwood",
	["Lord Maldazzar"] = "Western Plaguelands",
	["Lord Sakrasis"] = "The Cape of Stranglethorn",
	["Lord Sinslayer"] = "Darkshore",
	["Lost One Chieftain"] = "Swamp of",
	["Lost One Cook"] = "Swamp of",
	["Lost Soul"] = "Tirisfal Glades",
	["Lupos"] = "Duskwood",
	["Ma'ruk Wyrmscale"] = "Wetlands",
	["Magister Hawkhelm"] = "Azshara",
	["Mahamba"] = "Northern Stranglethorn",
	["Magosh"] = "Loch Modan",
	["Magronos the Unyielding"] = "Blasted Lands",
	["Malfunctioning Reaver"] = "Burning Steppes",
	["Malgin Barleybrew"] = "Southern Barrens",
	["Master Digger"] = "Westfall",
	["Master Feardred"] = "Azshara",
	["Mazzranache"] = "Mulgore",
	["Mezzir the Howler"] = "Winterspring",
	["Mirelow"] = "Wetlands",
	["Mist Howler"] = "Ashenvale",
	["Mojo the Twisted"] = "Blasted Lands",
	["Molok the Crusher"] = "Arathi Highlands",
	["Molt Thorn"] = "Swamp of",
	["Mongress"] = "Felwood",
	["Morgaine the Sly"] = "Elwynn Forest",
	["Mother Fang"] = "Elwynn Forest",
	["Muad"] = "Tirisfal Glades",
	["Mugglefin"] = "Ashenvale",
	["Murderous Blisterpaw"] = "Tanaris",
	["Nal'taszar"] = "Stonetalon Mountains",
	["Naraxis"] = "Duskwood",
	["Narg the Taskmaster"] = "Elwynn Forest",
	["Nefaru"] = "Duskwood",
	["Nimar the Slayer"] = "Arathi Highlands",
	["Oakpaw"] = "Ashenvale",
	["Old Cliff Jumper"] = "The Hinterlands",
	["Old Grizzlegut"] = "Feralas",
	["Old Vicejaw"] = "Silverpine Forest",
	["Olm the Wise"] = "Felwood",
	["Omgorn the Lost"] = "Tanaris",
	["Oozeworm"] = "Dustwallow Marsh",
	["Pridewing Patriarch"] = "Stonetalon Mountains",
	["Prince Kellen"] = "Desolace",
	["Crusty"] = "Desolace",
	["Prince Nazjak"] = "Arathi Highlands",
	["Prince Raze"] = "Ashenvale",
	["Putridius"] = "Western Plaguelands",
	["Pogeyan"] = "Northern Stranglethorn",
	["High Priestess Hai'watna"] = "Northern Stranglethorn",
	["Tsul'Kalu"] = "Northern Stranglethorn",
	["Qirot"] = "Feralas",
	["Ragepaw"] = "Felwood",
	["Rak'shiri"] = "Winterspring",
	["Ranger Lord Hawkspear"] = "Eastern Plaguelands",
	["Rathorian"] = "Northern Barrens",
	["Ravage"] = "Blasted Lands",
	["Ravasaur Matriarch"] = "Un'Goro Crater",
	["Ravenclaw Regent"] = "Silverpine Forest",
	["Razormaw Matriarch"] = "Wetlands",
	["Razortalon"] = "The Hinterlands",
	["Rekk'tilac"] = "Searing Gorge",
	["Ressan the Needler"] = "Tirisfal Glades",
	["Retherokk the Berserker"] = "The Hinterlands",
	["Ribchaser"] = "Redridge Mountains",
	["Rippa"] = "The Cape of Stranglethorn",
	["Mogh the Dead "] = "Northern Stranglethorn",
	["Ripscale"] = "Dustwallow Marsh",
	["Ro'Bark"] = "Hillsbrad Foothills",
	["Rohh the Silent"] = "Redridge Mountains",
	["Roloch"] = "Northern Stranglethorn",
	["Rorgish Jowl"] = "Ashenvale",
	["Rot Hide Bruiser"] = "Silverpine Forest",
	["Rumbler"] = "Badlands",
	["Sandarr Dunereaver"] = "Zul'farrak",
	["Scald"] = "Searing Gorge",
	["Scale Belly"] = "The Cape of Stranglethorn",
	["Scargil"] = "Hillsbrad Foothills",
	["Scarlet Interrogator"] = "Western Plaguelands",
	["Scarlet Judge"] = "Western Plaguelands",
	["Scarlet Smith"] = "Western Plaguelands",
	["Seeker Aqualon"] = "Redridge Mountains",
	["Sentinel Amarassan"] = "Stonetalon Mountains",
	["Sergeant Brashclaw"] = "Westfall",
	["Sergeant Curtis"] = "Durotar",
	["Setis"] = "Silithus",
	["Sewer Beast"] = "Stormwind City",
	["Shadowclaw"] = "Darkshore",
	["Shadowforge Commander"] = "Badlands",
	["Shanda the Spinner"] = "Loch Modan",
	["Shleipnarr"] = "Searing Gorge",
	["Silithid Harvester"] = "Southern Barrens",
	--["Silithid Ravager"] = "Thousand Needles",
	["Singer"] = "Arathi Highlands",
	["Skhowl"] = "Alterac Mountains",
	["Slark"] = "Westfall",
	["Slave Master Blackheart"] = "Searing Gorge",
	["Sludge Beast"] = "Northern Barrens",
	["Sludginn"] = "Wetlands",
	["Smoldar"] = "Searing Gorge",
	["Snagglespear"] = "Mulgore",
	["Snarler"] = "Feralas",
	["Snarlflare"] = "Redridge Mountains",
	["Snarlmane"] = "Silverpine Forest",
	["Snort the Heckler"] = "Southern Barrens",
	["Soriid the Devourer"] = "Tanaris",
	["Spiteflayer"] = "Blasted Lands",
	["Squiddic"] = "Redridge Mountains",
	["Sri'skulk"] = "Tirisfal Glades",
	["Stone Fury"] = "Alterac Mountains",
	["Stonearm"] = "Northern Barrens",
	["Strider Clutchmother"] = "Darkshore",
	["Terrorspark"] = "Burning Steppes",
	["Terrowulf Packlord"] = "Ashenvale",
	["Thauris Balgarr"] = "Burning Steppes",
	["The Cleaner"] = "Eastern Plaugelands",
	["The Evalcharr"] = "Azshara",
	["The Husk"] = "Western Plaguelands",
	["The Ongar"] = "Felwood",
	["The Rake"] = "Mulgore",
	["The Razza"] = "Dire Maul",
	["The Reak"] = "The Hinterlands",
	["The Rot"] = "Dustwallow Marsh",
	["Threggil"] = "Teldrassil",
	["Thunderstomp"] = "Northern Barrens",
	["Thuros Lightfingers"] = "Elwynn Forest",
	["Timber"] = "Dun Morogh",
	["Tormented Spirit"] = "Tirisfal Glades",
	["Twilight Lord Everun"] = "Silithus",
	["Uhk'loc"] = "Un'Goro Crater",
	["Ursol'lok"] = "Ashenvale",
	["Uruson"] = "Teldrassil",
	["Varo'then's Ghost"] = "Azshara",
	["Vengeful Ancient"] = "Stonetalon Mountains",
	["Verifonix"] = "The Cape of Stranglethorn",
	["Volchan"] = "Burning Steppes",
	["Vultros"] = "Westfall",
	["War Golem"] = "Badlands",
	["Warlord Thresh'jin"] = "Eastern Plaguelands",
	["Witherheart the Stalker"] = "The Hinterlands",
	["Zalas Witherbark"] = "Arathi Highlands",
	["Zora"] = "Silithus",
	["Zul'Brin Warpbranch"] = "Eastern Plaguelands",
	["Zul'arek Hatefowler"] = "The Hinterlands",
	["Shadikith the Glider"] = "Karazhan",
	["Hyakiss the Lurker"] = "Karazhan",
	["Rokad the Ravager"] = "Karazhan",
	["Goretooth"] = "Nagrand",
	["Voidhunter Yar"] = "Nagrand",
	["Bro'Gaz the Clanless"] = "Nagrand",
	["Marticar"] = "Zangarmarsh",
	["Bog Lurker"] = "Zangarmarsh",
	["Coilfang Emissary"] = "Zangarmarsh",
	["Nuramoc"] = "Netherstorm",
	["Ever-Core the Punisher"] = "Netherstorm",
	["Chief Engineer Lorthander"] = "Netherstorm",
	["Ambassador Jerrikar"] = "Shadowmoon Valley",
	["Collidus the Warp-Watcher"] = "Shadowmoon Valley",
	["Kraator"] = "Shadowmoon Valley",
	["Vorakem Doomspeaker"] = "Hellfire Peninsula",
	["Fulgorge"] = "Hellfire Peninsula",
	["Mekthorg the Wild"] = "Hellfire Peninsula",
	["Hemathion"] = "Blade's Edge Mountains",
	["Morcrush"] = "Blade's Edge Mountains",
	["Speaker Mar'grom"] = "Blade's Edge Mountains",
	["Eldinarcus"] = "Eversong Woods",
	["Trelga"] = "Eversong Woods",
	["Dr. Whitherlimb"] = "Ghostlands",
	["Crippler"] = "Terokkar Forest",
	["Doomsayer Jurim"] = "Terokkar Forest",
	["Okrek"] = "Terokkar Forest",
	["Fenissa the Assassin"] = "Bloodmyst Isle",
	[""] = "Zul'Gurub",
	["Doomwalker"] = "Shadowmoon Valley",
	["Doom Lord Kazzak"] = "Hellfire Peninsula",
	["Fumblub Gearwind"] = "Borean Tundra",
	["Icehorn"] = "Borean Tundra",
	["Old Crystalbark"] = "Borean Tundra",
	["Crazed Indu'le Survivor"] = "Dragonblight",
	["Scarlet Highlord Daion"] = "Dragonblight",
	["Tukemuth"] = "Dragonblight",
	["Arcturis"] = "Grizzly Hills",
	["Grocklar"] = "Grizzly Hills",
	["Seething Hate"] = "Grizzly Hills",
	["Syreian the Bonecarver"] = "Grizzly Hills",
	["King Ping"] = "Howling Fjord",
	["Perobas the Bloodthirster"] = "Howling Fjord",
	["Vigdis the War Maiden"] = "Howling Fjord",
	["High Thane Jorfus"] = "Icecrown",
	["Hildana Deathstealer"] = "Icecrown",
	["Putridus the Ancient"] = "Icecrown",
	["Aotona"] = "Sholazar Basin",
	["King Krush"] = "Sholazar Basin",
	["Loque'nahak"] = "Sholazar Basin",
	["Dirkee"] = "The Storm Peaks",
	["Skoll"] = "The Storm Peaks",
	["Time-Lost Proto Drake"] = "The Storm Peaks",
	["Vyragosa"] = "The Storm Peaks",
	["Gondria"] = "Zul'Drak",
	["Griegen"] = "Zul'Drak",
	["Terror Spinner"] = "Zul'Drak",
	["Zul'Drak Sentinel"] = "Zul'Drak",


	["Krkk'kx"] = "Thousand Needles",
	["Andre Firebeard"] = "Tanaris",
	["Twisted Reflection of Narain"] = "Tanaris",
	["Caliph Scorpidsting"] = "Tanaris",
	["Scorpitar"] = "Tanaris",
	["Aquementas the Unchained"] = "Tanaris",
	["Hellgazer"] = "Tanaris",
	["Emberwing"] = "Tanaris",]]


	-- Cataclysm
	["Garr"] = "Mount Hyjal",
	["Terrorpene"] = "Mount Hyjal",
	["Thartuk the Exile"] = "Mount Hyjal",
	["Ankha"] = "Mount Hyjal",
	["Ban'thalos"] = "Mount Hyjal",
	["Magria"] = "Mount Hyjal",
	["Blazewing"] = "Mount Hyjal",

	["Akma'hat"] = "Uldum",
	["Armagedillo"] = "Uldum",
	["Cyrus the Black"] = "Uldum",
	["Madexx"] = "Uldum",

	["Ghostcrawler"] = "Abyssal Depths",
	["Poseidus"] = "Abyssal Depths",
	["Shok'sharak"] = "Abyssal Depths",
	["Mobus"] = "Abyssal Depths",

	["Lady LaLa"] = "Kelp'thar Forest",

	["Captain Florence"] = "Shimmering Expanse",
	["Captain Fouldwind"] = "Shimmering Expanse",
	["Burgy Blackheart"] = "Shimmering Expanse",
	["Poseidus"] = "Shimmering Expanse",


	["Terborus"] = "Deepholm",
	["Xariona"] = "Deepholm",
	["Golgarok"] = "Deepholm",
	["Aeonaxx"] = "Deepholm",
	["Jadefang"] = "Deepholm",

	["Deth'tilac"] = "Molten Front",


	["Karoma"] = "Twilight Highlands",
	["Julak-Doom"] = "Twilight Highlands",
	["Sambas"] = "Twilight Highlands",
	["Overlord Sunderfury"] = "Twilight Highlands",
	["Tarvus the Vile"] = "Twilight Highlands",


}

do
	local last_played
	
	function unitscan.play_sound()
		if not last_played or GetTime() - last_played > 8 then
			PlaySoundFile([[Interface\AddOns\unitscan\Event_wardrum_ogre.ogg]], 'Sound')
			PlaySoundFile([[Interface\AddOns\unitscan\MapPing.ogg]], 'Sound')
			last_played = GetTime()
		end
	end
end

function unitscan.target(name)
	forbidden = false
	TargetUnit(name, true)
	-- unitscan.print(tostring(UnitHealth(name)) .. " " .. name)
	-- if not deadscan and UnitIsCorpse(name) then
	-- 	return
	-- end
	if forbidden then
		if not found[name] then
			found[name] = true
			--FlashClientIcon()
			unitscan.play_sound()
			unitscan.flash.animation:Play()
			unitscan.discovered_unit = name
		end
	else
		found[name] = false
	end
end

function unitscan.LOAD()
	UIParent:UnregisterEvent'ADDON_ACTION_FORBIDDEN'
	do
		local flash = CreateFrame'Frame'
		unitscan.flash = flash
		flash:Show()
		flash:SetAllPoints()
		flash:SetAlpha(0)
		flash:SetFrameStrata'FULLSCREEN_DIALOG'
		SetCVar("Sound_EnableErrorSpeech", 0)
		
		local texture = flash:CreateTexture()
		texture:SetBlendMode'ADD'
		texture:SetAllPoints()
		texture:SetTexture[[Interface\FullScreenTextures\LowHealth]]

		flash.animation = CreateFrame'Frame'
		flash.animation:Hide()
		flash.animation:SetScript('OnUpdate', function(self)
			local t = GetTime() - self.t0
			if t <= .5 then
				flash:SetAlpha(t * 2)
			elseif t <= 1 then
				flash:SetAlpha(1)
			elseif t <= 1.5 then
				flash:SetAlpha(1 - (t - 1) * 2)
			else
				flash:SetAlpha(0)
				self.loops = self.loops - 1
				if self.loops == 0 then
					self.t0 = nil
					self:Hide()
				else
					self.t0 = GetTime()
				end
			end
		end)
		function flash.animation:Play()
			if self.t0 then
				self.loops = 2
			else
				self.t0 = GetTime()
				self.loops = 1
			end
			self:Show()
		end
	end
	
	local button = CreateFrame('Button', 'unitscan_button', UIParent, 'SecureActionButtonTemplate')
	button:SetAttribute('type', 'macro')
	button:Hide()
	unitscan.button = button
	button:SetPoint('BOTTOM', UIParent, 0, 128)
	button:SetWidth(150)
	button:SetHeight(42)
	button:SetScale(1.25)
	button:SetMovable(true)
	button:SetUserPlaced(true)
	button:SetClampedToScreen(true)
	button:SetScript('OnMouseDown', function(self)
		if IsControlKeyDown() then
			self:RegisterForClicks("AnyDown", "AnyUp")
			self:StartMoving()
		end
	end)
	button:SetScript('OnMouseUp', function(self)
		self:StopMovingOrSizing()
		self:RegisterForClicks("AnyDown", "AnyUp")
	end)
	button:SetFrameStrata'FULLSCREEN_DIALOG'
	button:SetNormalTexture[[Interface\AddOns\unitscan\UI-Achievement-Parchment-Horizontal]]
	button:SetBackdrop{
		tile = true,
		edgeSize = 16,
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	}
	button:SetBackdropBorderColor(unpack(BROWN))
	button:SetScript('OnEnter', function(self)
		self:SetBackdropBorderColor(unpack(YELLOW))
	end)
	button:SetScript('OnLeave', function(self)
		self:SetBackdropBorderColor(unpack(BROWN))
	end)

	function button:set_target(name)
		self:SetText(name)

		self:SetAttribute('macrotext', '/cleartarget\n/targetexact ' .. name)
		self:Show()
		self.glow.animation:Play()
		self.shine.animation:Play()
	end
	
	do
		local background = button:GetNormalTexture()
		background:SetDrawLayer'BACKGROUND'
		background:ClearAllPoints()
		background:SetPoint('BOTTOMLEFT', 3, 3)
		background:SetPoint('TOPRIGHT', -3, -3)
		background:SetTexCoord(0, 1, 0, .25)
	end
	
	do
		local title_background = button:CreateTexture(nil, 'BORDER')
		title_background:SetTexture[[Interface\AddOns\unitscan\UI-Achievement-Title]]
		title_background:SetPoint('TOPRIGHT', -5, -5)
		title_background:SetPoint('LEFT', 5, 0)
		title_background:SetHeight(18)
		title_background:SetTexCoord(0, .9765625, 0, .3125)
		title_background:SetAlpha(.8)

		local title = button:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightMedium')
		title:SetWordWrap(false)
		title:SetPoint('TOPLEFT', title_background, 0, 0)
		title:SetPoint('RIGHT', title_background)
		button:SetFontString(title)

		local subtitle = button:CreateFontString(nil, 'OVERLAY', 'GameFontBlackTiny')
		subtitle:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -4)
		subtitle:SetPoint('RIGHT', title)
		subtitle:SetText'Unit Found!'
	end
	
	do
		local model = CreateFrame('PlayerModel', nil, button)
		button.model = model
		model:SetPoint('BOTTOMLEFT', button, 'TOPLEFT', 0, -4)
		model:SetPoint('RIGHT', 0, 0)
		model:SetHeight(button:GetWidth() * .6)
	end
	
	do
		local close = CreateFrame('Button', nil, button, 'UIPanelCloseButton')
		close:SetPoint('TOPRIGHT', 0, 0)
		close:SetWidth(32)
		close:SetHeight(32)
		close:SetScale(.8)
		close:SetHitRectInsets(8, 8, 8, 8)
	end
	
	do
		local glow = button.model:CreateTexture(nil, 'OVERLAY')
		button.glow = glow
		glow:SetPoint('CENTER', button, 'CENTER')
		glow:SetWidth(400 / 300 * button:GetWidth())
		glow:SetHeight(171 / 70 * button:GetHeight())
		glow:SetTexture[[Interface\AddOns\unitscan\UI-Achievement-Alert-Glow]]
		glow:SetBlendMode'ADD'
		glow:SetTexCoord(0, .78125, 0, .66796875)
		glow:SetAlpha(0)

		glow.animation = CreateFrame'Frame'
		glow.animation:Hide()
		glow.animation:SetScript('OnUpdate', function(self)
			local t = GetTime() - self.t0
			if t <= .2 then
				glow:SetAlpha(t * 5)
			elseif t <= .7 then
				glow:SetAlpha(1 - (t - .2) * 2)
			else
				glow:SetAlpha(0)
				self:Hide()
			end
		end)
		function glow.animation:Play()
			self.t0 = GetTime()
			self:Show()
		end
	end

	do
		local shine = button:CreateTexture(nil, 'ARTWORK')
		button.shine = shine
		shine:SetPoint('TOPLEFT', button, 0, 8)
		shine:SetWidth(67 / 300 * button:GetWidth())
		shine:SetHeight(1.28 * button:GetHeight())
		shine:SetTexture[[Interface\AddOns\unitscan\UI-Achievement-Alert-Glow]]
		shine:SetBlendMode'ADD'
		shine:SetTexCoord(.78125, .912109375, 0, .28125)
		shine:SetAlpha(0)
		
		shine.animation = CreateFrame'Frame'
		shine.animation:Hide()
		shine.animation:SetScript('OnUpdate', function(self)
			local t = GetTime() - self.t0
			if t <= .3 then
				shine:SetPoint('TOPLEFT', button, 0, 8)
			elseif t <= .7 then
				shine:SetPoint('TOPLEFT', button, (t - .3) * 2.5 * self.distance, 8)
			end
			if t <= .3 then
				shine:SetAlpha(0)
			elseif t <= .5 then
				shine:SetAlpha(1)
			elseif t <= .7 then
				shine:SetAlpha(1 - (t - .5) * 5)
			else
				shine:SetAlpha(0)
				self:Hide()
			end
		end)
		function shine.animation:Play()
			self.t0 = GetTime()
			self.distance = button:GetWidth() - shine:GetWidth() + 8
			self:Show()
		end
	end
end

do
	unitscan.last_check = GetTime()
	function unitscan.UPDATE()
		if is_resting then return end
		if not InCombatLockdown() and unitscan.discovered_unit then
			unitscan.button:set_target(unitscan.discovered_unit)
			unitscan.discovered_unit = nil
		end
		if GetTime() - unitscan.last_check >= CHECK_INTERVAL then
			unitscan.last_check = GetTime()
			for name in pairs(unitscan_targets) do
				unitscan.target(name)
			end
			for _, name in pairs(nearby_targets) do
				unitscan.target(name)
			end
		end
	end
end

function unitscan.print(msg)
	if DEFAULT_CHAT_FRAME then
		DEFAULT_CHAT_FRAME:AddMessage(LIGHTYELLOW_FONT_COLOR_CODE .. '<unitscan> ' .. msg)
	end
end

function unitscan.toggle_target(name)
	local key = strupper(name)
	if unitscan_targets[key] then
		unitscan_targets[key] = nil
		found[key] = nil
		unitscan.print('- ' .. key)
	elseif key ~= '' then
		unitscan_targets[key] = true
		unitscan.print('+ ' .. key)
	end
end
	
SLASH_UNITSCAN1 = '/unitscan'
function SlashCmdList.UNITSCAN(parameter)
	local _, _, name = strfind(parameter, '^%s*(.-)%s*$')
	
	if name == '' then
		unitscan.print("Usage:")
		unitscan.print("/unitscan name       - Adds/removes the 'name' from the unit scanner.")
		unitscan.print("/unitscan nearby     - Lists the rare spawns in the same zone as you.")
		unitscan.print("/unitscan dead       - Toggle notifications for dead rares.")
	elseif name == 'nearby' then
		for key, val in pairs(nearby_targets) do
			if not (val == "Lumbering Horror" or val == "Spirit of the Damned" or val == "Bone Witch") then
				unitscan.print(val)
			end
		end
		unitscan.print("Is someone missing? Add it to your list with \"/unitscan someone\"")
	elseif name == 'dead' then
		deadscan = not deadscan
		local say
		if deadscan then say = 'will now' else say = 'will no longer' end
		unitscan.print("Unitscan " .. say .. " detect dead units.")
	else
		unitscan.toggle_target(name)
	end
end