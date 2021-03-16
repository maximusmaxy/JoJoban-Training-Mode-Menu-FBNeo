------------------------------------------
-- JoJoban Training Mode Menu for FBNeo --
--               by Maxie               --
------------------------------------------
-- Credits to the following Stardust Romhackers for contributing in some way to the creation of this script:
-- peon2: The training mode requiem lua which was the base for this script https://github.com/peon2/JoJoban-Training-Mode
-- potatoboih : Creating the original script, updating the hit editor lua and finding ram addresses.
-- Klofkac: Worked with potatoboih to create the original script.
-- DrewDos: Creating the memory map document.
-- GaryButternubs: Finding ram addresses.
-- Unknown: The creator of the hit editor lua. We probably wouldn't have live hitboxes without you.
-- tylerneylon: Json parser https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
-- guruslum: Child mode and delayed health/meter refill scripts

-------------------
-- CONFIGURATION --
-------------------

local fcReplay = false --Determines whether it's a fightcade replay or not
local debug = false --Fbneo doesn't have watches so draw the variables on the screen

-- The available built in colors are: 
-- "clear", "red", "green", "blue", "white", "black", "gray", "grey", "orange", "yellow", "green", "teal", "cyan", "purple" and "magenta"
-- You can create your own colors using the rgb(a) format by replacing "#" with "0x" eg. teal or #008080 would be written as 0x008080
-- The last two characters are for transparency eg. 80 = half transparency and FF = opaque 
-- A half transparent teal would be written as 0x00808080

local colors = {
	menuBackground = 0x36393FFF,
	menuTitle = 0xB1B3B6FF,
	menuSelectedMin = { 43, 156, 255 }, --0x2B9CFFFF,
	menuSelectedMax = { 37, 134, 219 }, --0x2586DBFF,
	menuUnselected = "white",
	menuBorder = 0x202225FF,
	dpadBack = "black", --0x55CDFCFF,
	dpadBorder = "white", --0xFFFFFFFF,
	dpadActive = "red", --0xF7A8B8FF,
	orangebox = 0xFF800000,
	wakeupIndicator = 0xFBA400FF,
	wakeupBorder = 0xFFFFFF00
}

-- Sound IDs can be found in the 3rd option of the diagnostics menu

local sounds = {
	open = 0x00FD,
	close = 0x00FD,
	select = 0x016C, --0x013D, 
	cancel = 0x00FD,
	move = 0x016B, --0x007E,
	error = 0x00F2,
}

-- These are the default values for the menu options and you can change them to what you desire
-- They will be replaced when the settings are saved to menu settings.txt

local options = {
	guardAction = 1,
	guardActionDelay = 0,
	airTech = true,
	airTechDirection = 1,
	airTechDelay = 0,
	mediumKickHotkey = 1,
	strongKickHotkey = 1,
	music = false,
	meterRefill = 2,
	healthRefill = 2,
	standGaugeRefill = true,
	infiniteRounds = true,
	guiStyle = 2,
	inputStyle = 2,
	p1Gui = true,
	p2Gui = false,
	infoNumbers = true,
	forceStand = 1,
	ips = true,
	perfectAirTech = false,
	reversal = 1,
	throwTech = false,
	hitboxes = 1,
	p1Child = false,
	p2Child = false,
	tandemCooldown = true,
	boingo = false,
	level = 1,
	wakeupReversal = false,
	guardReversal = false,
	hitReversal = false,
	reversalButton = 1,
	reversalDirection = 1,
	reversalMotion = 1,
	reversalReplay = 1,
	hitboxColor = 0xFF000000,
	hurtboxColor = 0x0040FF00,
	collisionboxColor = 0x00FF0000,
	successColor = 0x00FF00FF, -- Yes/success color of gui elements
	failColor = 0xFF0000FF, -- No/fail color of gui elements
	comboCounterActiveColor = 0x0000FFFF, -- Colour of the combo counter if the combo hasn't dropped
	inputHistoryA = 0x00FF00FF, -- Colour of the letter A in the input history
	inputHistoryB = 0x0000FFFF, -- Colour of the letter B in the input history
	inputHistoryC = 0xFF0000FF, -- Colour of the letter C in the input history
	inputHistoryS = 0xFFFF00FF, -- Colour of the letter S in the input history
	trialsFilename = "sample_trials.json",
	trialSuccess = {},
	p1Recording = {},
	p2Recording = {},
	recordingSlot = 1,
	slot1 = true,
	slot2 = false,
	slot3 = false,
	slot4 = false,
	slot5 = false,
	replayInterval = 0,
	taunt = true,
	stageIndex = 1,
	killDenial = false,
	p1Character = 1,
	p2Character = 1,
	trialHud = true,
	disableHud = false,
	infiniteTimestop = false,
	menuSound = true,
	characterSpecific = true,
	status = 1,
	block = 1,
	kakyoinPose = 1,
	p1Hp = 144,
	p2Hp = 144,
	standGaugeLimit = false,
	-- p1StandGauge = 88,
	-- p1StandMin = 1,
	-- p1StandMax = 88,
	p2StandGauge = 88,
	p2StandMin = 1,
	p2StandMax = 88,
	romHack = false,
	boxTransparency = 0,
}

-----------------------
-- END CONFIGURATION --
-----------------------

print("JoJo's Bizarre Adventure: Heritage for the Future Training Mode Menu for FBNeo")
print("Credits to Maxie and the HFTF Stardust Romhackers for the current version with menu features.")
print("Credits to peon2 for programming, potatoboih for finding RAM values and Klofkac for the initial version.")
print("Special Thanks to Zarythe for graphical design and all the beta testers.")
print("Developed specifically for JoJo's Bizarre Adventure (Japan 990913, NO CD) (jojobanr1) though other versions should work.")
print("This script was designed for FBNeo. It is not compatible with FBA-RR. Some compatibility with Mame-RR")
print("Because of how knockdown is handled in JoJo, meaties may not behave as expected. Occasionally when the game is reset the script messes up, simply hit 'restart' in the lua script window to fix that")
print()
print("Commands List")
print()

if fcReplay then
	print("Alt + 1 to toggle gui")
	print("Alt + 2 to toggle hitboxes")
	print("Alt + 3 to toggle music")
	print("Alt + 4 to cyle input style")
else
	print("Coin: Open up the menu")
	print("Start: Control your opponent and lock direction when released")
	print("Not in use 1: Record")
	print("Not in use 2: Replay")
	print("Press F5 to rebind your not in use keys")
	print("Hold down replay to loop")
	print("Not in use 1 on menu: Restore p2 stand gauge")
	print("Not in use 2 on menu: Restore p1 stand gauge")
end

-------------------------------------------------
-- Aliases
-------------------------------------------------

local readByte = memory.readbyte
local readByteSigned = memory.readbytesigned
local readWord = memory.readword
local readWordSigned = memory.readwordsigned
local readDWord = memory.readdword
local readDWordSigned = memory.readdwordsigned
local readByteRange = memory.readbyterange
local writeByte = memory.writebyte
local writeWord = memory.writeword
local writeDWord = memory.writedword

local lShift = bit.lshift
local rShift = bit.rshift
local band = bit.band
local bor = bit.bor
local bxor = bit.bxor

--Copies values from one table to another
function tableCopy(source, dest) 
	for k, v in pairs(source) do
		dest[k] = v
	end
end

--Returns the index of an object in a table
function tableIndex(t, obj) 
	for i = 1, #t, 1 do
		if t[i] == obj then
			return i
		end
	end
	return -1
end

--Compares the contents of two indexed tables of the same length
function tableCompare(tab1, tab2)
	for i = 1, #tab1, 1 do
		if tab1[i] ~= tab2[i] then return false end
	end
	return true
end

-- creates a set similar to the java style collection
function createSet(list)
	local set = {}
	for _, l in ipairs(list) do 
		set[l] = true 
	end
	return set
end

-------------------------------------------------
-- Data
-------------------------------------------------

local stage = {
	left = 32,
	leftZoomed = -16,
	right = 352,
	rightZoomed = 400,
	noParallax = createSet({ 17, 41 }),
	offCenter = createSet({ 3, 19, 20, 21, 22 }),
	names = {
		"Lock Up",
		"Health Room",
		"In an Airplane",
		"Tigerbaum Garden",
		"Hotel (Devil)",
		"Remains",
		"Hotel (Justice)",
		"Amusement Park",
		"Small Island",
		"Desert (Noon)",
		"Ruins",
		"Country Town (Noon)",
		"Underground Sewer",
		"Inside House",
		"Dio's Coffin",
		"Clock Tower",
		"Suburbs",
		"On the Bridge",
		"Country Town Twilight",
		"Desert (Morning)",
		"Desert (Twilight)",
		"Desert (Evening)",
		"Desert (Midnight)",
		"Dio's Coffin 2",
		"Remains 2",
		"Small Island 2",
		"Country Town (Night)",
		"Ice Stage (Destroyed)",
		"Suburbs 2",
		"Suburbs 3",
		"Clock Tower 2",
		"Dio's Mansion",
		"Map",
		"Remains 3",
		"Hotel (Devil) 2",
		"Small Island 3",
		"Ruins 2",
		"Sewer 2",
		"Ice Stage (Clean)",
		"Dio's Coffin 3",
		"Clock Tower 3",
		"On The Bridge 2",
	}
}

local characters = {
	"Jotaro",
	"Kakyoin",
	"Avdol",
	"Polnareff",
	"Old Joseph",
	"Iggy",
	"Alessi",
	"Chaka",
	"Devo",
	"Midler",
	"Dio",
	"Shadow Dio",
	"Young Joseph",
	"Hol Horse",
	"Vanilla Ice",
	"New Kakyoin",
	"Black Polnareff",
	"Petshop",
	"Mariah",
	"Hoingo",
	"Rubber Soul",
	"Khan",
	"N'Doul",
	"Boss Ice",
	"Death 13",
}

local optionType = {
	subMenu = 1,
	bool = 2,
	int = 3,
	list = 4,
	func = 5,
	info = 6,
	color = 7,
	slider = 8,
	trialCharacters = 9,
	trial = 10,
	files = 11,
	file = 12, 
	key = 13,
	listSelect = 14,
	managedInt = 15,
	trialAbout = 16,
	back = 17
}

local hudStyles = {
	"None",
	"Simple",
	"Advanced",
	"Wakeup Indicator",
	"Frame Data",
	"Trial Debug",
	"Attack Info",
	"Action Frame Info",
	"Projectile Frame Info"
}

local systemOptions = {
	{
		name = "Meter Refill:",
		key = "meterRefill",
		type = optionType.list,
		list = {
			"Disabled",
			"Instant",
			"Delayed"
		}
	},
	{
		name = "Health Refill:",
		key = "healthRefill",
		type = optionType.list,
		list = {
			"Disabled",
			"Instant",
			"Delayed"
		}
	},
	{
		name = "Stand Gauge Refill:",
		key = "standGaugeRefill",
		type = optionType.bool
	},
	{
		name = "IPS:",
		key = "ips",
		type = optionType.bool
	},
	{
		name = "Kill Denial:",
		key = "killDenial",
		type = optionType.bool
	},
	{
		name = "Infinite Rounds:",
		key = "infiniteRounds",
		type = optionType.bool
	},
	{
		name = "Infinite Timestop:",
		key = "infiniteTimestop",
		type = optionType.bool
	},
	{
		name = "Tandem Cooldown",
		key = "tandemCooldown",
		type = optionType.bool
	}, 
	{
		name = "Taunt:",
		key = "taunt",
		type = optionType.bool
	},
	{
		name = "Music:",
		key = "music",
		type = optionType.bool
	},
	{
		name = "Romhack:",
		key = "romHack",
		type = optionType.bool,
		info = "Enables the romhack.txt"
	},
	{
		name = "Return",
		type = optionType.back
	}
}

local battleOptions = {
	{
		name = "P1 Character:",
		key = "p1Character",
		type = optionType.list,
		list = characters
	},
	{
		name = "P2 Character:",
		key = "p2Character",
		type = optionType.list,
		list = characters
	},
	{
		name = "Stage:",
		key = "stageIndex",
		type = optionType.int,
		min = 0, 
		max = 41
	},
	{
		name = "P1 HP Max",
		key = "p1Hp",
		type = optionType.int,
		min = 1,
		max = 144,
		inc = 10,
		info = "Hold A to increase by 10",
	},
	{
		name = "P2 HP Max",
		key = "p2Hp",
		type = optionType.int,
		min = 1,
		max = 144,
		inc = 10,
		info = "Hold A to increase by 10",
	},
	{
		name = "Stand Gauge Limit",
		key = "standGaugeLimit",
		type = optionType.bool,
	},
	-- {
	-- 	name = "P1 Stand Gauge Max",
	-- 	key = "p1StandGauge",
	-- 	type = optionType.managedInt,
	-- 	min = "p1StandMin",
	-- 	max = "p1StandMax",
	-- 	inc = 10,
	-- 	info = "Hold A to increase by 10",
	-- },
	{
		name = "Stand Gauge Max",
		key = "p2StandGauge",
		type = optionType.managedInt,
		min = "p2StandMin",
		max = "p2StandMax",
		inc = 10,
		info = "Hold A to increase by 10",
	},
	{
		name = "P1 Child:",
		key = "p1Child",
		type = optionType.bool
	},
	{
		name = "P2 Child:",
		key = "p2Child",
		type = optionType.bool
	},
	{
		name = "Return",
		type = optionType.back
	}
}

local characterSpecificOptions = {
	{
		name = "Kakyoin Pose:",
		key = "kakyoinPose",
		type = optionType.list,
		list = {
			"Off",
			"1",
			"2",
			"3",
			"4",
			"5",
		}
	},
	{
		name = "Spawn Boingo:",
		key = "boingo",
		type = optionType.bool,
	},
	{
		name = "Mariah Level:",
		key = "level",
		type = optionType.list,
		list = {
			"Off",
			"1",
			"2",
			"3",
			"4", 
			"5", 
			"6",
			"7",
			"MAX"
		},
		info = "Locks Mariah's level"
	},
	{
		name = "Return",
		type = optionType.back
	}
}

local enemyOptions = {
	{
		name = "Status:",
		key = "status",
		type = optionType.list,
		list = {
			"Stand",
			"Crouch",
			"Jump",
		}
	},
	{
		name = "Block:",
		key = "block",
		type = optionType.list,
		list = {
			"Off",
			"Status",
			"All",
			"Status After Hit",
			"All After Hit",
			"Random",
		}
	},
	{
		name = "Blocking Action:",
		key = "guardAction",
		type = optionType.list,
		list = {
			"Off",
			"Push block",
			"Guard Cancel"
		}
	},
	{
		name = "Blocking Action Delay:",
		key = "guardActionDelay",
		type = optionType.int,
		min = 0,
		max = 15
	},
	{
		name = "Air Tech:",
		key = "airTech",
		type = optionType.bool
	},
	{
		name = "Air Tech Direction:",
		key = "airTechDirection",
		type = optionType.list,
		list = {
			"Up/Neutral",
			"Down",
			"Toward",
			"Away",
			"Random"
		}
	},
	{
		name = "Air Tech Delay:",
		key = "airTechDelay",
		type = optionType.int,
		min = 0,
		max = 10
	},
	{
		name = "O Frame Air Tech:",
		key  = "perfectAirTech",
		type = optionType.bool
	},
	{
		name = "Force Stand:",
		key = "forceStand",
		type = optionType.list,
		list = {
			"Default",
			"On",
			"Off"
		}
	},
	{
		name = "Throw Tech:",
		key = "throwTech",
		type = optionType.bool,
	}, 
	{
		name = "Return",
		type = optionType.back
	}
}

local hudOptions = {
	{
		name = "Hitboxes",
		key = "hitboxes",
		type = optionType.list, 
		list = {
			"Disabled",
			"Enabled"
		}
	},
	{
		name = "Hud Style:",
		key = "guiStyle",
		type = optionType.list,
		list = hudStyles
	},
	{
		name = "Input Display Style:",
		key = "inputStyle",
		type = optionType.list,
		list = {
			"Simple",
			"History",
			"Frames",
		}
	},
	{
		name = "Player 1 Hud:",
		key = "p1Gui", 
		type = optionType.bool
	},
	{
		name = "Player 2 Hud:",
		key = "p2Gui",
		type = optionType.bool
	},
	{
		name = "Info Numbers:",
		key = "infoNumbers",
		type = optionType.bool
	},
	{
		name = "Character Specific:",
		key = "characterSpecific",
		type = optionType.bool
	},
	{
		name = "Remove Game Hud:",
		key = "disableHud",
		type = optionType.bool,
		info = "Enable/Disable from character select"
	},
	{
		name = "Trial Hud:",
		key = "trialHud",
		type = optionType.bool
	},
	{
		name = "Menu Sound:",
		key = "menuSound",
		type = optionType.bool
	},
	{
		name = "Return",
		type = optionType.back
	}
}

local colorOptions = {
	{
		name = "Hitbox Color",
		key = "hitboxColor",
		type = optionType.color,
		default = 0xFF000000
	},
	{
		name = "Hurtbox Color",
		key = "hurtboxColor",
		type = optionType.color,
		default = 0x0040FF00
	},
	{
		name = "Collisionbox Color",
		key = "collisionboxColor",
		type = optionType.color,
		default = 0x00FF0000
	},
	{
		name = "A Input Color",
		key = "inputHistoryA",
		type = optionType.color,
		default = 0x00FF00FF
	},
	{
		name = "B Input Color",
		key = "inputHistoryB",
		type = optionType.color,
		default = 0x0000FFFF
	},
	{
		name = "C Input Color",
		key = "inputHistoryC",
		type = optionType.color,
		default = 0xFF0000FF
	},
	{
		name = "S Input Color",
		key = "inputHistoryS",
		type = optionType.color,
		default = 0xFFFF00FF
	},
	{
		name = "Success Color",
		key = "successColor",
		type = optionType.color,
		default = 0x00FF00FF
	},
	{
		name = "Fail Color",
		key = "failColor",
		type = optionType.color,
		default = 0xFF0000FF
	},
	{
		name = "Combo Color",
		key = "comboCounterActiveColor",
		type = optionType.color,
		default = 0x0000FFFF
	},
	{
		name = "Box Transparency",
		key = "boxTransparency",
		type = optionType.int,
		min = 0,
		max = 255,
		inc = 10,
		info = "Hold A to increase by 10",
	},
	{
		name = "Return",
		type = optionType.back
	}
}

local reversalOptions = {
	{
		name = "Wakeup Reversal:",
		key = "wakeupReversal",
		type = optionType.bool
	},
	{
		name = "Guard Reversal:",
		key = "guardReversal",
		type = optionType.bool
	},
	{
		name = "Hit Reversal:",
		key = "hitReversal",
		type = optionType.bool
	},
	{
		name = "Reversal Button:",
		key = "reversalButton",
		type = optionType.list,
		list = {
			"A",
			"B",
			"C",
			"S",
			"A+B+C",
			"A+B",
			"A+C",
			"B+C"
		}
	},
	{
		name = "Reversal Direction:",
		key = "reversalDirection",
		type = optionType.list,
		list = {
			"5 - Neutral",
			"6 - Forward",
			"7 - Up Back",
			"8 - Up",
			"9 - Up Forward",
			"1 - Down Back",
			"2 - Down",
			"3 - Down Forward",
			"4 - Back"
		}
	},
	{
		name = "Reversal Motion:",
		key = "reversalMotion",
		type = optionType.list,
		list = {
			"None",
			"236 - QCF",
			"214 - QCB",
			"623 - DP",
			"421 - RDP",
			"41236 - HCF",
			"63214 - HCB",
			"22 - DD",
			"6248 - 360",
			"62486248 - 720",
			"463214 - TWS"
		}
	},
	{
		name = "Reversal Replay:",
		key = "reversalReplay",
		type = optionType.list,
		list = {
			"None",
			"Recording",
			"Buffered Recording",
--			"Inputs.txt",
--			"Buffered Inputs.txt"
		}
	},
	{
		name = "Reset to Default",
		type = optionType.func,
		func = function() 
			resetReversalOptions()
			playSound(sounds.select, 0x4040)
		end
	},
	{
		name = "Return",
		type = optionType.back
	}
}

local trialOptions = {
	{
		name = "Save Recording",
		type = optionType.func,
		func = function() trialRecordingSave() end
	},
	{
		name = "Export Trials",
		type = optionType.func,
		func = function() exportTrial() end
	},
	{
		name = "Select Trials",
		type = optionType.files,
	},
	{
		name = "Reset Trial Completion",
		type = optionType.func,
		func = function() resetTrialCompletion() end
	},
	{
		name = "Return",
		type = optionType.back,
	}
}

local recordReplaySettings = {
	{
		name = "Recording Slot:",
		key = "recordingSlot",
		type = optionType.int,
		min = 1,
		max = 5
	},
	{
		name = "Replay Slot 1:",
		key = "slot1",
		type = optionType.bool
	},
	{
		name = "Replay Slot 2:",
		key = "slot2",
		type = optionType.bool
	},
	{
		name = "Replay Slot 3:",
		key = "slot3",
		type = optionType.bool
	},
	{
		name = "Replay Slot 4:",
		key = "slot4",
		type = optionType.bool
	},
	{
		name = "Replay Slot 5:",
		key = "slot5",
		type = optionType.bool
	},
	{
		name = "Replay interval:",
		key = "replayInterval",
		type = optionType.int,
		min = 0,
		max = 100,
		inc = 10,
		info = "Hold A to increase by 10",
	},
	{
		name = "Not In Use 1 Hotkey:",
		key = "mediumKickHotkey",
		type = optionType.key,
		list = {
			"disabled",
			"record",
			"recordP2",
			"recordAntiAir",
			"recordParry",
		},
		names = {
			disabled = "Disabled",
			record = "Record P1",
			recordP2 = "Record P2",
			recordAntiAir = "Record Anti-air",
			recordParry = "Record Parry",
		}
	},
	{
		name = "Not In Use 2 Hotkey:",
		key = "strongKickHotkey",
		type = optionType.key,
		list = {
			"disabled",
			"replay",
			"replayP2",
			"inputPlayback",
		},
		names = {
			disabled = "Disabled",
			replay = "Replay P1",
			replayP2 = "Replay P2",
			inputPlayback = "Input Playback",
		}
	},
	{
		name = "Reset to Default",
		type = optionType.func,
		func = function() 
			resetReplayOptions()
			playSound(sounds.select, 0x4040)
		end
	},
	{
		name = "Return",
		type = optionType.back
	}
}

local rootOptions = {
	{
		name = "Enemy Settings",
		type = optionType.subMenu,
		options = enemyOptions
	},
	{
		name = "Battle Settings",
		type = optionType.subMenu,
		options = battleOptions
	},
	{
		name = "System Settings",
		type = optionType.subMenu,
		options = systemOptions
	},
	{
		name = "Hud Settings",
		type = optionType.subMenu,
		options = hudOptions
	},
	{
		name = "Record/Replay Settings",
		type = optionType.subMenu,
		options = recordReplaySettings
	},
	{
		name = "Reversal Settings",
		type = optionType.subMenu,
		options = reversalOptions
	},
	{
		name = "Character Specific Settings",
		type = optionType.subMenu,
		options = characterSpecificOptions
	},
	{
		name = "Color Settings",
		type = optionType.subMenu,
		options = colorOptions
	},
	{
		name = "Combo Trials",
		type = optionType.trialCharacters
	}, 
	{
		name = "Trial Options",
		type = optionType.func,
		func = function() trialOptionsVerification() end
	},
	{
		name = "About",
		type = optionType.info,
		infos = {
			"Credits to Maxie and the HFTF Stardust",
			"Romhackers for the current release.",
			"Credits to peon2, potatoboih, Klofkac and",
			"Zarythe for the initial version.",
			"This script is still undergoing development.",
			"For bug reports and feature requests please",
			"DM Maxie#7777 on discord.",
			"Thank you!"
		}
	},
	{
		name = "Return",
		type = optionType.back
	}
}

local infoOptions = {
	{
		name = "Return",
		type = optionType.back
	}
}

local colorSliderOptions = {
	{
		name = "Red: ",
		type = optionType.slider,
		mask = 0xFF000000,
		shift = 24
	},
	{
		name = "Green: ",
		type = optionType.slider,
		mask = 0xFF0000,
		shift = 16
	},
	{
		name = "Blue: ",
		type = optionType.slider,
		mask = 0xFF00,
		shift = 8
	},
	{
		name = "Reset to default",
		type = optionType.func,
		func = function() resetColor() end
	},
	{
		name = "Return",
		type = optionType.back
	}
}

local menu = {
	state = 0, --0 = closed, 1 = top menu, 2 = sub menu
	index = 1,
	previousIndex = 1,
	previousSubIndex = 1,
	min = 1,
	options = rootOptions,
	title = "Training Menu",
	info = "",
	color = nil,
	default = nil,
	flash = 0,
	flashColor = {}
}

local parserDictionary = {
	u = 0x01,
	d = 0x02,
	l = 0x04,
	r = 0x08,
	a = 0x10,
	b = 0x20,
	c = 0x40,
	s = 0x80
}

local p1 = {
	character = 0,
	health = 0, 
	damage = 0,
	previousDamage = 0,
	comboDamage = 0,
	standHealth = 0,
	standGauge = 0,
	standGaugeMax = 0,
	combo = 0,
	control = false,
	directionLock = 0,
	inputs = 0,
	previousInputs = 0,
	recording = false,
	loop = false,
	displayComboCounter = 0,
	comboCounterColor = "white",
	recorded = {},
	recordedFacing = 0,
	inputPlayback = nil,
	inputPlaybackFacing = 0,
	inputHistoryTable = {},
	playback = nil,
	playbackCount = 0,
	playbackFacing = 0,
	playbackFlipped = false,
	guarding = 0,
	animationState = 0,
	guardState = 0,
	standGuardState = 0,
	riseFall = 0,
	hitstun = 0,
	afterHitstun = 0,
	standHitstun = 0,
	blockstun = 0,
	blocking = 0,
	canAct1 = 0,
	canAct2 = 0,
	stand = false,
	previousIps = 0,
	ips = 0,
	ipsCount = 0,
	scaling = 0,
	canReversal = false,
	reversalCount = 0,
	canAct = false,
	frameAdvantage = 0,
	defenseAction = 0,
	wakeupCount = 0,
	guardCount = 0,
	hitCount = 0,
	airtechCount = 0,
	pushblockCount = 0,
	wakeupFreeze = 0,
	hitFreeze = 0,
	actionAddress = 0,
	frameAddress = 0,
	standFrameAddress = 0,
	stunType = 0,
	stunCount = 0,
	wakeupFrame = false,
	meaty = false,
	attackHit = 0,
	standAttackHit = 0,
	actionId = 0,
	standActionId = 0,
	airtech = false,
	techable = 0,
	newButtons = 0,
	healthDelay = 0,
	actFrame = 0,
	guardFrame = 0,
	guardAct = false,
	actType = 0,
	attackType = 0,
	standAct = false,
	afterHit = 0,
	blockAll = 0,
	randomBlock = 0,
	animationCount = 0,
	standAnimationCount = 0,
	buttons = {},
	memory = nil,
	memory2 = nil,
	memory4 = nil
}

-- Shallow copy of p1 with new tables created
local p2 = {}
for k, v in pairs(p1) do
	if type(v) == "table" then
		p2[k] = {}
	else
		p2[k] = v
	end
end

--Set individual memory values

p1.memory = {  --0x203488C
	character = 0x203489F,
	health = 0x205BB28,
	standHealth = 0x205BB48,
	combo = 0x205BB38,
	meter = 0x205BB64,
	meterBar = 0x2034862,
	meterNumber = 0x2034863,
	standGaugeMax = 0x02035211,
	guarding = 0x00000000, 
	facing = 0x2034899,
	side = 0x20349F9, 
	animationState = 0x00000000, 
	riseFall  = 0x00000000, 
	hitstun = 0x02034971,
	standHitstun = 0x020351B1,
	blockstun = 0x00000000, 
	stand = 0x2034A1F,
	ips = 0x2034E9E,
	ipsCount = 0x2034E9F,
	scaling = 0x2034E9D,
	height = 0x00000000,
	guardState = 0x00000000,
	standGuardState = 0x00000000,
	canAct1 = 0x02034941, --B5
	canAct2 = 0x02034A25, --199
	standCanAct1 = 0x02035181,
	standCanAct2 = 0x02035265,
	throwTech = 0x02034A3C, --1b0
	standFacing = 0x20350D9,
	standActive = 0x02034A20,
	child = 0x02034AB2,
	defenseAction = 0x00000000,
	hitFreeze = 0x02034A5F,
	wakeupFreeze = 0x00000000,
	stunType = 0x00000000,
	stunCount = 0x00000000,
	attackId = 0x02034968,
	attackHit = 0x02034969,
	standAttackId = 0x020351A8,
	standAttackHit = 0x020351A9,
	tandem = 0x02034A39,
	tandemCount = 0x02032D74,
	actionId = 0x0203491E,
	standActionId = 0x0203515E,
	cc = 0x2034A38,
	attackType = 0x02034A48,
	standAttackType = 0x02035288,
	blocking = 0x00000000,
	animationCount = 0x203492F,
	standAnimationCount = 0x203516F,
	invul = 0x20349DE,
	standInvul = 0x203521E,
}

p1.memory2 = {
	healthRefill = 0x20349CC,
	standGaugeRefill = 0x203520C,
	hitbox = 0x02034938, --AC
	standHitbox = 0x2035178,
	x = 0x20348E8,
	y = 0x20348EC,
	standX = 0x2035128,
	standY = 0x203512C
}

p1.memory4 = {
	actionAddress = 0x0203491C,
	standActionAddress = 0x0203515C,
	frameAddress = 0x02034918,
	standFrameAddress = 0x02035158,
}

p2.memory = { 
	character = 0x2034CBF,
	health = 0x205BB29,
	standHealth = 0x205BB49,
	combo = 0x205BB39,
	meter = 0x205BB65,
	meterBar = 0x2034886,
	meterNumber = 0x2034887,
	standGaugeMax = 0x02035631,
	guarding = 0x02034E51,
	facing = 0x2034CB9,
	side = 0x2034E19,
	animationState = 0x02034D93,
	riseFall = 0x002034DA8,
	hitstun = 0x02034D91,
	standHitstun = 0x020355D1,
	blockstun = 0x02034D5A,
	stand = 0x02034E3F,
	ips = 0x00000000,
	scaling = 0x00000000,
	height = 0x02034D0D,
	guardState = 0x02034D92,
	standGuardState = 0x20355D2,
	canAct1 = 0x02034D61, --B5
	canAct2 = 0x02034E45, --199
	standCanAct1 = 0x02034D61,
	standCanAct2 = 0x02035685,
	throwTech = 0x02034E5C,
	standFacing = 0x020354F9,
	standActive = 0x02034E40,
	child = 0x02034ED2,
	defenseAction = 0x02034D92,
	hitFreeze = 0x02034E7F,
	wakeupFreeze = 0x02034D9A,
	stunType = 0x02034E82,
	stunCount = 0x02034E92,
	techable = 0x02034EE3,
	cc = 0x2034E58,
	attackType = 0x02034E68,
	blocking = 0x2034E52,
	standBlocking = 0x2035692,
}

p2.memory2 = {
	healthRefill = 0x2034DEC,
	standGaugeRefill = 0x203562C,
	hitbox = 0x02034D58,
	standHitbox = 0x02035598,
	x = 0x2034D08,
	y = 0x2034D0C,
	standX = 0x2035548,
	standY = 0x203554C,
}

p2.memory4 = {
	actionAddress = 0x02034D3C,
	standActionAddress = 0x0203557C,
	frameAddress = 0x02034D38,
	standFrameAddress = 0x02035578,
	yVelocity = 0x2034DA8,
}

p1.health = readByte(p1.memory.health)
p1.standHealth = readByte(p1.memory.standHealth)
p1.standGauge = p1.standHealth 
p2.health = readByte(p2.memory.health)
p2.standHealth = readByte(p2.memory.standHealth)
p2.standGauge = p2.standHealth

p1.name = "P1 "
p1.number = 1
p1.address = 0x203488C
p1.standAddress = 0x20350CC
p2.name = "P2 "
p2.number = 2
p2.address = 0x2034CAC
p2.standAddress = 0x20354EC

local system = {
	screenFreeze = 0,
	antiAir = 0,
	parry = 0,
	recordingSlots = 5,
	playerSelect = 0,
	p1Swap = 0,
	p2Swap = 0,
	attackId = 0,
	attackAddress = 0,
	startUp = 0,
	active = { 0 },
	recovery = 0,
	frameState = 0,
	frameAdvantage = false,
	proj1Address = 0,
	proj2Address = 0,
	sBullet = 0x2038870,
	iFrames = { 0 },
}

local hud = {
	startUp = 0,
	active = 0,
	recovery = 0,
	frameAdvantage = 0,
	reversalFrame = 0,
	iFrames = 0,
	invul = false,
	standInvul = false,
	ips = 0,
}

local buttons = {
	up = "Up",
	down = "Down",
	left = "Left",
	right = "Right"
}

if fba then
	buttons.a = "Weak Attack"
	buttons.b = "Medium Attack"
	buttons.c = "Strong Attack"
	buttons.s = "Stand"
	buttons.mk = "Not in use 1"
	buttons.sk = "Not in use 2"
elseif mame then
	buttons.a = "Button 1"
	buttons.b = "Button 2"
	buttons.c = "Button 3"
	buttons.s = "Button 4"
	buttons.mk = "Button 5"
	buttons.sk = "Button 6"
else
	error("This script is only intended for FBNeo and MAME-rr.", 0)
end

local inputDictionary = {
	[0x01] = "Up",
	[0x02] = "Down",
	[0x04] = "Left",
	[0x08] = "Right",
	[0x10] = buttons.a,
	[0x20] = buttons.b,
	[0x40] = buttons.c,
	[0x80] = buttons.s,
}

for k, v in pairs(buttons) do
	p1.buttons[k] = p1.name..v
	p2.buttons[k] = p2.name..v
end

if fba then
	p1.buttons.start = "P1 Start"
	p1.buttons.coin = "P1 Coin"
	p2.buttons.start = "P2 Start"
	p2.buttons.coin = "P2 Coin"
elseif mame then
	p1.buttons.start = "1 Player Start"
	p1.buttons.coin = "Coin 1"
	p2.buttons.start = "2 Players Start"
	p2.buttons.coin = "Coin 2"
end

local selectInputs = {
	p1.buttons.a,
	p1.buttons.s,
	p2.buttons.a,
	p2.buttons.s
}

local cancelInputs = {
	p1.buttons.b,
	p1.buttons.c,
	p1.buttons.mk,
	p1.buttons.sk,
	p2.buttons.b,
	p2.buttons.c,
	p2.buttons.mk,
	p2.buttons.sk
}

local transferButtons = {
	buttons.a,
	buttons.b,
	buttons.c,
	buttons.s,
	buttons.up,
	buttons.down,
	buttons.left,
	buttons.right
}

local playerSelectInputs = {
	p1.buttons.a,
	p1.buttons.b,
	p1.buttons.c,
	p1.buttons.s,
	p1.buttons.start
}

local inputModule = {
	current = {},
	previous = {},
	held = {},
	overwrite = {},
	transfer = false,
	transferWait = false
}

local hitboxOffsets = {
	0x61DEE9E, --Jotaro
	0x61E0FCA, --Kakyoin
	0x61E52DC, --Avdol
	0x61E73A2, --Pol
	0x61EA1EA, --Old Joseph
	0x61EF37E, --Iggy
	0x61F18B2, --Alessi
	0x61F45D2, --Chaka
	0x61F66EA, --Devo
	0x61F9372, --Ndoul
	0x61FC7B8, --Midler
	0x61FDB7E, --DIO
	0x61FFE3E, --Ice
	0x62014E2, --Death13
	0x62023EE, --SDio
	0x62043BA, --Young Joseph
	0x620608E, --Hol Horse
	0x6208702, --Iced
	0x620B042, --NKak
	0x620D986, --BPol
	0x620F196, --Petshop
	0x0000000, --???
	0x62104BE, --Mariah
	0x621125C, --Hoingo
	0x6212418, --Rubber
	0x62145B6  --Khan
}

--Initialise input held count time
function initButtons(player) 
	for _, v in pairs(player.buttons) do
		inputModule.held[v] = 0
	end
end

initButtons(p1)
initButtons(p2)

local reversal = {
	buttons = {
		0x10,
		0x20,
		0x40,
		0x80,
		0x70,
		0x30,
		0x50,
		0x60
	},
	directions = {
		0x00, 
		0x08,
		0x05,
		0x01,
		0x09,
		0x06,
		0x02,
		0x0A,
		0x04
	},
	motions = {
		{},
		{ 0x02, 0x0A, 0x08 },
		{ 0x02, 0x06, 0x04 },
		{ 0x08, 0x02, 0x0A },
		{ 0x04, 0x02, 0x06 },
		{ 0x04, 0x06, 0x02, 0x0A, 0x08 },
		{ 0x08, 0x0A, 0x02, 0x06, 0x04 },
		{ 0x02, 0x00, 0x02, 0x02, 0x00, 0x02 },
		{ 0x08, 0x02, 0x04, 0x01 },
		{ 0x08, 0x02, 0x04, 0x01, 0x08, 0x02, 0x04, 0x01 },
		{ 0x04, 0x08, 0x0A, 0x02, 0x06, 0x04 }
	}
}

local wakeupOffsets = {
	{ -1, 0 },
	{ -2, -1 },
	{ -2, -3 },
	{ 0, 0 },
	{ 0, 0 },
	{ 0, 0 },
	{ 0, 0 },
	{ 0, 0 },
	{ -2, -2 },
	{ 0, 0 },
	{ -2, 0 },
	{ 0, 0 },
	{ -2, -2 },
	{ 0, 0 },
	{ 0, 0 },
	{ 0, 0 },
	{ -3, -3 },
	{ -2, -2 },
	{ -2, -1 },
	{ 0, 0 },
	{ 0, 0 },
	{ 0, 0 }, 
	{ -3, -3 },
	{ -3, -3 },
	{ -3, -3 }, 
	{ -2, -2 }
}

local stunType = {
	[0] = 13,
	[1] = 10,
	[2] = 13,
	[3] = 16,
	[4] = 22,
	[5] = 24,
	[6] = 60,
	[7] = 60,
	[8] = 60,
	[9] = 30,
	[10] = 30,
	[11] = 30,
	[12] = 232,
	[13] = 13,
	[14] = 13,
	[15] = 232
}

local childColorCode = {
	[0x0B] = 0x14, --dio
	[0x0E] = 0x14, --sdio
	[0x14] = 0x11, --petshop
	[0x16] = 0x11, --mariah
	[0x18] = 0x0F  --rubber
}

local boxCache = {
	{ {}, {}, {} },
	{ {}, {}, {} },
}

local projectiles = {}

for i = 1, 64, 1 do
	projectiles[i] = {
		state = 0,
		previousState = 0,
		facing = 0,
		char = 0,
		hitbox = 0,
		x = 0,
		y = 0,
		attackId = 0,
		previousAttackId = 0,
		attackHit = 0,
		previousAttackHit = 0,
		actionId = 0,
		previousActionId = 0,
		consumed = false
	}
end

local stageBorder = { -- { left border, right border, parallax adjustment, center? }
	{ 3, 397, 0 }, --0
	{ 3, 381, 0 },
	{ -253, 621, 0 },
	{ 64, 576, 13, 320 }, --off center, r = 20
	{ 3, 381, 0 },
	{ -256, 800, 64 },
	{ 3, 381, 69 },
	{ 80, 560, 75 },
	{ 48, 848, 25 },
	{ 0, 0, 0 }, --na
	{ 48, 592, 16 }, --10
	{ 192, 704, 28 },
	{ -192, 704, 0 },
	{ 56, 840, 0 },
	{ 48, 576, 0 },
	{ 48, 592, 16 },
	{ -384, 912, 0 },
	{ -512, 832, 0 }, --parallax doesn't scroll
	{ -192, 704, 28 },
	{ -384, 992, 80, 256 }, --off center r = 92
	{ -384, 992, 80, 256 }, --20 off center
	{ -384, 992, 80, 256 }, --off center
	{ -384, 992, 80, 256 }, --off center
	{ 48, 576, 0 },
	{ -256, 800, 64 },
	{ 48, 848, 25 },
	{ -192, 704, 28 },
	{ 56, 840, 0 },
	{ -384, 912, 0 },
	{ -384, 912, 0 },
	{ 48, 592, 16 }, --30
	{ 0, 0, 0 }, --na
	{ 0, 0, 0 }, --na
	{ -256, 800, 64},
	{ 3, 381, 0 },
	{ 48, 848, 25 },
	{ 48, 592, 16 },
	{ -192, 704, 0 },
	{ 56, 840, 0 },
	{ 48, 576, 0 },
	{ 48, 592, 16 }, --40
	{ -512, 832, 0 } --parallax doesn't scroll
}

local charToIndex = {
	[0] = 1,
	[1] = 2,
	[2] = 3,
	[3] = 4,
	[4] = 5,
	[5] = 6,
	[6] = 7,
	[7] = 8,
	[8] = 9,
	[10] = 10,
	[11] = 11,
	[12] = 23,
	[13] = 24,
	[14] = 12,
	[15] = 13,
	[16] = 14,
	[17] = 15,
	[18] = 16,
	[19] = 17,
	[20] = 18,
	[22] = 19,
	[23] = 20,
	[24] = 21,
	[25] = 22
}

local indexToName = {
	"Jotaro",
	"Kakyoin",
	"Avdol",
	"Polnareff",
	"Old Joseph",
	"Iggy",
	"Alessi",
	"Chaka",
	"Devo",
	"Midler",
	"Dio",
	"Shadow Dio",
	"Young Joseph",
	"Hol Horse",
	"Vanilla Ice",
	"New Kakyoin",
	"Black Polnareff",
	"Petshop",
	"Mariah",
	"Hoingo",
	"Rubber Soul",
	"Khan",
	"Boss Ice",
	"Death 13",
}

local nameToId = {
	Jotaro = 0,
	Kakyoin = 1,
	Avdol = 2,
	Polnareff = 3,
	["Old Joseph"] = 4,
	Iggy = 5,
	Alessi = 6,
	Chaka = 7,
	Devo = 8, 
	["N'Doul"] = 9,
	Midler = 10,
	Dio = 11,
	["Boss Ice"] = 12,
	["Death 13"] = 13,
	["Shadow Dio"] = 14,
	["Young Joseph"] = 15,
	["Hol Horse"] = 16,
	["Vanilla Ice"] = 17,
	["New Kakyoin"] = 18,
	["Black Polnareff"] = 19,
	Petshop = 20,
	Mariah = 22,
	Hoingo = 23,
	["Rubber Soul"] = 24,
	Khan = 25
}

local idToName = {
	[0] = "Jotaro",
	[1] = "Kakyoin",
	[2] = "Avdol",
	[3] = "Polnareff",
	[4] = "Old Joseph",
	[5] = "Iggy",
	[6] = "Alessi",
	[7] = "Chaka",
	[8] = "Devo",
	[9] = "N'Doul",
	[10] = "Midler",
	[11] = "Dio",
	[12] = "Boss Ice",
	[13] = "Death 13",
	[14] = "Shadow Dio",
	[15] = "Young Joseph",
	[16] = "Hol Horse",
	[17] = "Vanilla Ice",
	[18] = "New Kakyoin",
	[19] = "Black Polnareff",
	[20] = "Petshop",
	[22] = "Mariah",
	[23] = "Hoingo",
	[24] = "Rubber Soul",
	[25] = "Khan"
}

local hexToAnime = {
	8, 
	2, 
	5, --up down
	4, 
	7, 
	1,
	4, --up left down
	6,
	9,
	3,
	6, --up down right
	5, --left right
	8, --up left right
	1, --down left right
	5, --up down left right
}

local trials = {}
local trial = {}

local comboType = {
	id = 1,
	multi = 2,
	alt = 3, 
	tandem = 4,
	inputs = 5,
	pCharge = 6,
	sCharge = 7,
	bCharge = 8,
	whiff = 9,
	projectiles = 10,
	remote = 11,
	recall = 12,
	meaty = 13,
	timeStop = 14,
	timeStopEnd = 15,
	double = 16,
	doubleMeaty = 17,
	action = 18,
	standAction = 19,
	projectileAction = 20,
	reset = 21,
	meatyReset = 22,
	sBullet = 23,
	meatyCmd = 24,
	grab = 25,
}

local comboDictionary = {} 

tableCopy(comboType, comboDictionary)
comboDictionary["player charge"] = comboType.pCharge
comboDictionary["character charge"] = comboType.pCharge
comboDictionary["stand charge"] = comboType.sCharge
comboDictionary["projectile charge"] = comboType.bCharge
comboDictionary["bullet charge"] = comboType.bCharge
comboDictionary["return"] = comboType.recall
comboDictionary["time stop"] = comboType.timeStop
comboDictionary["time stop end"] = comboType.timeStopEnd
comboDictionary["time stop finish"] = comboType.timeStopEnd
comboDictionary["ub"] = comboType.double
comboDictionary["unblockable"] = comboType.double
comboDictionary["meaty double"] = comboType.doubleMeaty
comboDictionary["meaty ub"] = comboType.doubleMeaty
comboDictionary["meaty unblockable"] = comboType.doubleMeaty
comboDictionary["double meaty"] = comboType.doubleMeaty
comboDictionary["ub meaty"] = comboType.doubleMeaty
comboDictionary["unblockable meaty"] = comboType.doubleMeaty
comboDictionary["stand action"] = comboType.standAction
comboDictionary["projectile action"] = comboType.projectileAction
comboDictionary["meaty reset"] = comboType.meatyReset
comboDictionary["s bullet"] = comboType.sBullet
comboDictionary["meaty cmd"] = comboType.meatyCmd
comboDictionary["throw"] = comboType.grab

local intToComboString = {
	"id",
	"multi",
	"alt",
	"tandem",
	"inputs",
	"player charge",
	"stand charge",
	"projectile charge",
	"whiff",
	"projectiles",
	"remote",
	"recall",
	"meaty",
	"time stop",
	"time stop end",
	"double",
	"double meaty",
	"action",
	"stand action",
	"projectile action",
	"reset",
	"meaty reset",
	"s bullet",
	"meaty cmd",
	"grab",
}

local recordingKeys = createSet({
	"recording"
})

local recordingArrays = createSet({
	"p1Recording",
	"p2Recording"
})

--Character * 0x100 + id
local commandGrabLeniency = {
	[0x134] = 2, -- kakyoin
	[0x446] = 2, -- oldseph 360/720
	[0x529] = 2, --iggy
	[0x51D] = 2, --iggy
	[0x0A10] = 1, --midler
	[0x0E30] = 2, --sdio
	[0x1234] = 2, --nkak
	[0x172A] = 2, --hoingo
	[0x1812] = 2, --rubber
}


local moveDefinitions = {}
for i = 1, 24, 1 do
	moveDefinitions[i] = {}
end

local romHacks = {
	active = {},
	cache = {},
	txt = {},
	killDenial = {
		--[0x6188F6C] = 0xE301, -- Kill denial
		--[0x6186DDC] = 0xE301, --??
		--[0x618708C] = 0xE301, --??
		[0x6183AE6] = 0xE301, -- Kill check
		[0x6184648] = 0xE301, -- Stand kill check
		--[0x6186FB2] = 0xE301, --??
		[0x6187520] = 0xE301, -- Increase player hitstop
		[0x6187532] = 0xE201, -- Increase player v stand hitstop
		[0x6187566] = 0xE301, -- Increase stand hitstop
		[0x6187592] = 0xE301, -- Increase stand v stand hitstop
		[0x6187630] = 0xE201, -- Increase projectile hitstop
		[0x61880C2] = 0xE301, -- Timestop kill check
		[0x618A18E] = 0xE301, -- Grab kill check
	},
	stageSwap = {
		[0x6176C10] = 0xE200, -- Check for dev region
		[0x6179212] = 0x0008, -- Start check
		[0x6179220] = 0x0018, -- Previous C check
		[0x6179282] = 0x0008, -- Start check
		[0x6179290] = 0x0008, -- A check
		[0x617929C] = 0xE200, -- Stage id number, modified manually
	},
	p1Swap = {
		[0x6044D44] = 0x0018, -- Check for dev region
		--Next 3 instructions put 0x1040 (Start + C) into R5
		[0x604BF42] = 0xE510, -- Mov #$10, R5   R5 = 0x10
		[0x604BF48] = 0x4518, -- Shll8 R5       R5 = 0x1000
		[0x604BF62] = 0x7540, -- Add #$40, R5   R5 = 0x1040
		[0x604BF44] = 0xE440, -- 0x40 (C) into R4 
		[0x604BF6A] = 0x0009, -- Clear R4 update
		[0x604BFE6] = 0xE300, -- Character id number, modified manually
	},
	p2Swap = {
		[0x6044D44] = 0x0018, -- Check for dev region
		--Next 3 instructions put 0x1040 (Start + C) into R5
		[0x604BF5C] = 0xE510, -- Mov #$10, R5   R5 = 0x10
		[0x604BF5E] = 0x4518, -- Shll8 R5       R5 = 0x1000
		[0x604BF62] = 0x7540, -- Add #$40, R5   R5 = 0x1040
		[0x604BF60]	= 0xE440, -- 0x40 (C) into R4 
		[0x604BF6A] = 0x0009, -- Clear R4 update
		[0x604BFE6] = 0xE300, -- Character id number, modified manually
	},
	comboCounter = {
		[0x61A1118] = 0x0000, --p1 combo counter
		[0x61A1048] = 0x2E50, --p2 combo counter
	},
	petshopFlap = {
		[0x68A43A8] = 0x0000, --idle sound
		[0x68A46F8] = 0x0000, --forward sound
		[0x68A47A0] = 0x0000, --back sound
		[0x68A49D8] = 0x0000, --up sound
	},
	kakyoinPose = {
		[0x6811924] = 0x0604, --Modifies the random action frame (type 0xD) to set a specific value (type 0x6)
		[0x6811926] = 0x0200, --This byte is set manually to the desired pose
		[0x6811988] = 0x0604, --kak s.on
		[0x681198A] = 0x0200, 
		[0x6895BE0] = 0x0604, --nkak s.off
		[0x6895BE2] = 0x0200, 
		[0x6895C44] = 0x0604, --nkak s.on
		[0x6895C46] = 0x0200,
	},
	standGauge = {
		[0x60451B2] = 0xE300, --Move stand gauge max into R3, modified manually
		[0x60451BA] = 0xE200, --Move stand gauge max into R2, modified manually
	},
	boingo = {
		[0x616E71C] = 0x0018, --Set t bit to 1
	}
}

local hitInfo = {
	names =  {
		"Damage",
		"Stand Damage",
		"Meter (Whiff)",
		"Meter (Hit)",
		"Blocking",
		"Attribute",
		"Launch X",
		"Launch Y",
		"Blocking",
		"Blocking2",
		"Hitstop",
		"Knockback (Hit)",
		"Hitspark",
		nil,
		"Hit Effect",
		"Screenshake",
		nil,
		"Knockback (Block)",
		"Hitstun",
		"Blockstun",
		"Instant Standcrash",
		"Sound",
		"Air Blocking",
		"Kill Denial",
		"Background Flash",
		"Parry",
		nil,
		"Teching",
		nil,
		nil,
		nil,
		"Scaling",
		nil,
		nil,
		nil,
		"Blazing Fists",
		"IPS",
		nil,
		nil,
		nil,
		nil,
		"Unused 1",
		"Unused 2",
		"Unused 3",
		"Unused 4",
		"Unused 5",
		"Unused 6",
		"Khan",
	},
	tables = {
		[4] = { 
			[0x0] = "Overhead",
			[0x1] = "Mid",
			[0x2] = "Low",
			[0x3] = "Unblockable",
		},
		[5] = { 
			[0x1D] = "Launch",
			[0x1B] = "Knockdown",
			[0x20] = "Wallbounce",
			[0x27] = "Offscreen Launch",
			[0x2A] = "Child Transform",
			[0x31] = "Grab",
			[0x60] = "Instakill softlock"
		}
	}
}

local frameInfo = {
	{
		name = "Frame",
		info = {
			[2] = {
				name = "End",
				table = {
					[0] = "No",
					[0x80] = "Yes"
				}
			},
			[3] = "Count",
			[4] = {
				name = "Sprite",
				length = 4,
				hex = true
			},
			[10] = {
				name = "X Mod",
				signed = true
			},
			[11] = {
				name = "Y Mod",
				signed = true
			},
			[12] = {
				name = "Hitbox",
				length = 2
			},
			[25] = "Sound"
		}
	},
	{
		name = "Unconditional Jump",
		info = {
			[4] = {
				name = "Jump",
				length = 4,
				hex = true
			}
		}
	},
	{
		name = "Simple Frame",
		info = {
			[3] = "Count",
			[4] = {
				name = "Sprite",
				length = 4,
				hex = true
			},
			[10] = {
				name = "X Mod",
				signed = true
			},
			[11] = {
				name = "Y Mod",
				signed = true
			},
		}
	},
	{
		name = "Condition Equal",
		info = {
			[4] = {
				name = "Jump",
				length = 4,
				hex = true
			}
		}
	},
	{
		name = "Condition Not Equal",
		info = {
			[4] = {
				name = "Jump",
				length = 4,
				hex = true
			}
		}
	},
	{
		name = "5"
	},
	{
		name = "Set Value",
		info = {
			[2] = "Index",
			[3] = "Value"
		}
	},
	{
		name = "Add To Value",
		info = {
			[2] = "Index",
			[3] = "Value"
		}
	},
	{
		name = "Check Value If Equal",
		info = {
			[2] = "Index",
			[3] = "Condition"
		}
	},
	{
		name = "And Value",
		info = {
			[2] = "Index",
			[3] = "Value"
		}
	},
	{
		name = "10",
		info = {
			[2] = "Index"
		}
	},
	{
		name = "Temporary Jump",
		info = {
			[4] = {
				name = "Jump",
				length = 4,
				hex = true
			}
		}
	},
	{
		name = "12"
	},
	{
		name = "Random Decision"
	},
	{
		name = "Jump With Action Table"
	},
	{
		name = "No Sprite Frame"
	},
	{
		name = "16"
	},
	{
		name = "17"
	},
	{
		name = "18"
	},
}

local canActIds = {
	createSet({ 2, 6, 9, 10 }),
	{},
	createSet({ 3, 10, 19 }),
	createSet({ 13 }),
	{},
	{},
	{},
	{},
	{},
	{},
	createSet({ 1, 10, 15 }),
	createSet({ 13 }),
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
}

local actType0 = {
	createSet({ 9 }),
	createSet({ 163 }),
	{},
	createSet({ 20 }),
	createSet({ 12, 14 }),
	{},
	createSet({ 95, 96, 97 }),
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	createSet({ 152, 154 }),
	{},
	{},
	createSet({ 18, 76 }),
	{},
	createSet({ 105, 106, 107, 108 }),
	{},
	{},
	{},
	createSet({ 223, 227, 229, 231, 233 }),
	createSet({ 20, 22 }),
}

local standPlusFrames = {
	createSet({ 2 }),
	{},
	createSet({ 3, 4, 10, 19 }),
	createSet({ 13 }),
	{},
	{},
	{},
	{},
	{},
	{},
	createSet({ 1 }),
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
	{},
}

local kakPoseFrames = createSet({
	--kak
	0x6810808, 0x6810888, 0x68108A8, 0x68108C8, --5a
	0x6811570, 0x6811590, 0x68115B0, --236
	0x68F7C1C, 0x68F7820, 0x68F7A2C, 0x68F7654, 0x68F733C, 0x68F74E8, --s.2a, s.5b, s.5c, s.6a, s.6b, s.4C
	--nkak
	0x6894B44, 0x6894B64, 0x6894B84, --5a
	0x689582C, 0x689584C, 0x689586C, --236
	0x697E6A8, 0x697E3F0, 0x697E57C, 0x697E2E4, 0x697E02C, 0x697E178, --s.2a, s.5b, s.5c, s.6a, s.6b, s.4C
})

local flipFrames = createSet({
	0x6801D50, 0x6801D70, 0x6801D90, 0x6801DB0, --jotaro f dash
	0x6801FF8, 0x6802018, 0x6802038, 0x6802058, 0x6801F70, 0x6801F90, 0x6801FB0, 0x6801FD0, --jotaro b dash
	0x68E89AC, 0x68E89CC, 0x68E89EC, --jotaro s f dash
	0x68E8AB4, 0x68E8AD4, 0x68E8AF4, --jotaro s b dash
	0x681641C, 0x681643C, 0x681645C, 0x681647C, --avdol f dash
	0x681656C, 0x681658C, 0x68165AC, 0x68165CC, --avdol b dash
	0x68FF538, 0x68FF558, --avdol s f dash
	0x68FF620, 0x68FF640, --avdol s b dash
	0x681817C, --avdol 2B
	0x681827C, --avdol 2C
	0x681807C, --avdol 6C
	-- 0x681813C, 0x681815C, --avdol dash 2B
	-- 0x681823C, 0x681825C, --avdol dash 2C
	0x681DE9C, 0x681DEBC, 0x681DEDC, 0x681DEFC, 0x681DF1C, --pol f dash 
	0x681DF9C, 0x681DFBC, 0x681DFDC, 0x681DFFC, 0x681E01C, --pol b dash 
	0x690D8E4, 0x690D904, 0x690D924, 0x690D944, --pol s f dash
	0x690DB04, 0x690DB24, 0x690DB44, 0x690DB64, --pol s b dash
	0x6849BD8, 0x6849BF8, 0x6849C18, 0x6849C38, 0x6849C58, --chaka f dash
	0x6849CD8, 0x6849CF8, 0x6849D18, 0x6849D38, 0x6849D58,--chaka b dash
	0x6934674, 0x6934694, 0x69346B4, --chaka s f dash
	0x6934754, 0x6934774, 0x6934794, --chaka s b dash
	0x684A7D0, --chaka 5C
	0x68524F4, 0x6852514, 0x6852534, --devo f dash
	0x68525DC, 0x68525FC, 0x685261C, --devo b dash
	0x693ECA0, 0x693ECC0, 0x693ECE0, 0x693ED00, 0x693ED20, 0x693ED40, 0x693ED60, --devo s f dash
	0x693EFE0, 0x693F000, 0x693F020, 0x693F040, 0x693F060, 0x693F080, 0x693F0A0,--devo s b dash
	0x685B254, 0x685B274, 0x685B294, 0x685B2B4, 0x685B2D4, --midler crouch
	0x6878610, --yojo 2C
	0x6889154, 0x6889174, 0x6889194, --ice f dash
	0x68892A4, 0x68892C4, 0x68892E4, --ice b dash
	0x69744F8, 0x6974518, --ice s f dash
	0x6974578, 0x6974598, --ice s b dash
	0x69749C0, 0x69749E0, --ice f air dash
	0x6974A48, 0x6974A68, --ice b air dash
	0x6894C94, 0x6894CB4, 0x6894CD4, 0x6894CF4, 0x6894D18, 0x6894D38, --nkak 5C/66C
	0x689AB10, 0x689AB30, 0x689AB50, 0x689AB70, 0x689AB90, --bpol f dash
	0x689AC10, 0x689AC30, 0x689AC50, 0x689AC70, 0x689AC90, --bpol b dash
	0x68BC6D0, --rubber 2A
})

local blockActiveFrame = {
	[0x68F0424] = 2, --Jotaro
	[0x68F0404] = 2,
	[0x68F99E4] = 4, --Kak
	[0x68F9A04] = 4,
	[0x68F9AC4] = 4, 
	[0x68F9AE4] = 4, 
	[0x68FB9C0] = 2, 
	[0x6836A5C] = 1, --Iggy
	[0x68460E8] = 2, --Alessi
	[0x6960EEC] = 2, --Midler
	[0x69B26A4] = 2, --Dio
	[0x69B2824] = 2, 
	[0x69B29A4] = 2, 
	[0x69B2C84] = 2, 
	[0x69B2E04] = 2,
	[0x69B2F84] = 2, 
	[0x69B5638] = 2,
	[0x6980A28] = 4, --Nkak
	[0x6980A48] = 4, 
	[0x698E324] = 4, --Rubber
	[0x698E304] = 4,
}


-------------------------------------------------
-- json.lua 
-- By tylerneylon
-- https://gist.github.com/tylerneylon/59f4bcf316be525b30ab
-------------------------------------------------

--[[ json.lua
A compact pure-Lua JSON library.
The main functions are: json.stringify, json.parse.
## json.stringify:
This expects the following to be true of any tables being encoded:
 * They only have string or number keys. Number keys must be represented as
strings in json; this is part of the json spec.
 * They are not recursive. Such a structure cannot be specified in json.
A Lua table is considered to be an array if and only if its set of keys is a
consecutive sequence of positive integers starting at 1. Arrays are encoded like
so: `[2, 3, false, "hi"]`. Any other type of Lua table is encoded as a json
object, encoded like so: `{"key1": 2, "key2": false}`.
Because the Lua nil value cannot be a key, and as a table value is considerd
equivalent to a missing key, there is no way to express the json "null" value in
a Lua table. The only way this will output "null" is if your entire input obj is
nil itself.
An empty Lua table, {}, could be considered either a json object or array -
it's an ambiguous edge case. We choose to treat this as an object as it is the
more general type.
To be clear, none of the above considerations is a limitation of this code.
Rather, it is what we get when we completely observe the json specification for
as arbitrary a Lua object as json is capable of expressing.
## json.parse:
This function parses json, with the exception that it does not pay attention to
\u-escaped unicode code points in strings.
It is difficult for Lua to return null as a value. In order to prevent the loss
of keys with a null value in a json string, this function uses the one-off
table value json.null (which is just an empty table) to indicate null values.
This way you can check if a value is null with the conditional
`val == json.null`.
If you have control over the data and are using Lua, I would recommend just
avoiding null values in your data to begin with.
--]]

local json = {}

-- Internal functions.

json.in_char = {'\\', '"', '/', '\b', '\f', '\n', '\r', '\t'}
json.out_char = {'\\', '"', '/',  'b',  'f',  'n',  'r',  't'}

local function escape_str(s)
	for i, c in ipairs(json.in_char) do
		s = s:gsub(c, '\\' .. json.out_char[i])
	end
	return s
end

-- Returns pos, did_find; there are two cases:
-- 1. Delimiter found: pos = pos after leading space + delim; did_find = true.
-- 2. Delimiter not found: pos = pos after leading space;     did_find = false.
-- This throws an error if err_if_missing is true and the delim is not found.
local function skip_delim(str, pos, delim, err_if_missing)
	pos = pos + #str:match('^%s*', pos)
	if str:sub(pos, pos) ~= delim then
		if err_if_missing then
			error('Expected ' .. delim .. ' near position ' .. pos)
		end
    	return pos, false
  	end
  	return pos + 1, true
end

json.esc_map = {b = '\b', f = '\f', n = '\n', r = '\r', t = '\t'}

-- Expects the given pos to be the first character after the opening quote.
-- Returns val, pos; the returned pos is after the closing quote character.
local function parse_str_val(str, pos, val)
	val = val or ''
	local early_end_error = 'End of input found while parsing string.'
	if pos > #str then error(early_end_error) end
	local c = str:sub(pos, pos)
	if c == '"'  then return val, pos + 1 end
	if c ~= '\\' then return parse_str_val(str, pos + 1, val .. c) end
	-- We must have a \ character.
	local nextc = str:sub(pos + 1, pos + 1)
	if not nextc then error(early_end_error) end
	return parse_str_val(str, pos + 2, val .. (json.esc_map[nextc] or nextc))
end

-- Returns val, pos; the returned pos is after the number's final character.
local function parse_num_val(str, pos)
	local num_str = str:match('^-?%d+%.?%d*[eE]?[+-]?%d*', pos)
	local val = tonumber(num_str)
	if not val then error('Error parsing number at position ' .. pos .. '.') end
	return val, pos + #num_str
end

-- Public values and functions.

function json.stringify(obj) -- rewritten to output in desired formatting
	local curlyboy = not obj[1] and next(obj) ~= nil
	local sb = { (curlyboy and "{" or "[") }
	insertJsonTable(sb, obj, 1)
	sb[#sb + 1] = (curlyboy and "}" or "]")
	return table.concat(sb, "\n")
end

function insertJsonTable(sb, t, depth)
	if next(t) == nil then return end
	for k, v in pairs(t) do
		local keyType = type(k)
		local valueType = type(v)
		local key
		local value
		local skip = false

		if keyType == "number" then
			key = string.rep("    ", depth)
		else
			key = string.rep("    ", depth).."\""..k.."\": "
		end
		
		if valueType == "nil" then 
			skip = true
		elseif recordingKeys[k] then
			value = "[\""..table.concat(v, "\",\"").."\"],"
		elseif recordingArrays[k] then
			sb[#sb + 1] = key.."["
			for i = 1, #v, 1 do
				sb[#sb + 1] = string.rep("    ", depth + 1).."[\""..table.concat(v[i], "\",\"").."\"],"
			end
			sb[#sb] = sb[#sb]:sub(1, -2)
			sb[#sb + 1] = string.rep("    ", depth).."],"
			skip = true
		elseif valueType == "table" then
			local curlyboy = not v[1] and next(v) ~= nil
			sb[#sb + 1] = key..(curlyboy and "{" or "[")
			depth = depth + 1
			insertJsonTable(sb, v, depth)
			depth = depth - 1
			sb[#sb + 1] = string.rep("    ", depth)..(curlyboy and "}" or "]")..","
			skip = true
		elseif valueType == "string" then
			value = "\""..escape_str(v).."\","
		elseif valueType == "boolean" then
			value = (v and "true" or "false")..","
		elseif valueType == "number" and k == "type" then
			if v == 1 then
				skip = true
			else
				value = "\""..intToComboString[v].."\","
			end
		else
			value = v..","
		end

		if not skip then
			sb[#sb + 1] = key..value
		end
	end
	sb[#sb] = sb[#sb]:sub(1, -2)
end

json.null = {}  -- This is a one-off table to represent the null value.
json.literals = {['true'] = true, ['false'] = false, ['null'] = json.null}

function json.parse(str, pos, end_delim)
	pos = pos or 1
	if pos > #str then error('Reached unexpected end of input.') end
	local pos = pos + #str:match('^%s*', pos)  -- Skip whitespace.
	local first = str:sub(pos, pos)
	if first == '{' then  -- Parse an object.
		local obj, key, delim_found = {}, true, true
		pos = pos + 1
		while true do
			key, pos = json.parse(str, pos, '}')
			if key == nil then return obj, pos end
			if not delim_found then error('Comma missing between object items.') end
			pos = skip_delim(str, pos, ':', true)  -- true -> error if missing.
			obj[key], pos = json.parse(str, pos)
			pos, delim_found = skip_delim(str, pos, ',')
		end
	elseif first == '[' then  -- Parse an array.
		local arr, val, delim_found = {}, true, true
		pos = pos + 1
		while true do
			val, pos = json.parse(str, pos, ']')
			if val == nil then return arr, pos end
			if not delim_found then error('Comma missing between array items.') end
			arr[#arr + 1] = val
			pos, delim_found = skip_delim(str, pos, ',')
		end
	elseif first == '"' then  -- Parse a string.
		return parse_str_val(str, pos + 1)
	elseif first == '-' or first:match('%d') then  -- Parse a number.
		return parse_num_val(str, pos)
	elseif first == end_delim then  -- End of an object or array.
		return nil, pos + 1
	else  -- Parse true, false, or null.
		for lit_str, lit_val in pairs(json.literals) do
			local lit_end = pos + #lit_str - 1
			if str:sub(pos, lit_end) == lit_str then return lit_val, lit_end + 1 end
		end
		local pos_info_str = 'position ' .. pos .. ': ' .. str:sub(pos, pos + 10)
		error('Invalid json syntax starting at ' .. pos_info_str)
	end
end

-------------------------------------------------
-- IO
-------------------------------------------------

-- Reads the inputs.txt file and turns it into an array of hex values containing p1 and p2 inputs
function readInputsFile()
	p1.inputPlayback = {}
	p2.inputPlayback = {}
	local f, err = io.open("inputs.txt", "r")
	if err then 
		print("Error reading inputs.txt")
		return 
	end
	local player = nil
	for line in f:lines() do
		if (line ~= "" and line:sub(1, 1) ~= "-") then
			if (line == "P1") then
				player = p1
			elseif (line == "P2") then
				player = p2
			elseif player then
				local inputs = parseInput(line)
				for _ = 1, inputs.wait, 1 do
					player.inputPlayback[#player.inputPlayback + 1] = inputs.hex
				end
			end
		end
	end
	f:close()
end

-- Creates the inputs.txt file if it doesn't exist
function createInputsFile()
	local exists = io.open("inputs.txt", "r")
	if exists then
		exists:close()
		return
	end
	local f, err = io.open("inputs.txt", "w")
	if err then 
		print("Error creating inputs.txt")
		return 
	end
	f:write([[- The syntax for the inputs text is as follows:
- P1 = Start player 1's inputs (Only 1 player is required)
- P2 = Start player 2's inputs (Only 1 player is required)
- u = Up
- d = Down
- l = Left
- r = Right
- a = A
- b = B
- c = C
- s = S
- number = Repeat for x frames

- Each new line is a frame of input unless specified with a number eg. 5 = nothing for 5 frames, da10 = down and A for 10 frames

- Directions assume that both player 1 and player 2 are facing to the right. The inputs will be flipped programaticaly if
- players swap sides so there is no need to rewrite your input for each side.

- To perform the input playback change one of the hotkeys in the menu to "Input playback" and press the hotkey


- Player 1 Start
P1

- Player 2 start
P2
]]);
	f:close()
end

-- Creates the romhack.txt file if it doesn't exist
function createRomhackFile()
	local exists = io.open("romhack.txt", "r")
	if exists then
		exists:close()
		return
	end
	local f, err = io.open("romhack.txt", "w")
	if err then 
		print("Error creating romhack.txt")
		return 
	end
	f:write([[- Syntax
- - Dashes are comments
- > Arrows are addresses
- Under the address you list the assembly instructions to insert
- The instruction set can be found at http://www.shared-ptr.com/sh_insns.html
- Instructions are 2 bytes in length even if you only need to overwrite a single byte of data so keep that in mind
]]);
	f:close()
end

-- Converts the input text into a hex value and a wait time
function parseInput(line)
	local _, _, number = line:find("(%d+)")
	local inputs = {
		hex = 0,
		wait = tonumber(number) or 1
	}
	for letter in line:lower():gmatch("%a") do
		local inputHex = parserDictionary[letter]
		if inputHex then
			inputs.hex = bor(inputs.hex, inputHex)
		end
	end
	return inputs
end

-- Saves settings to menu settings.txt
function writeSettings()
	local f, err = io.open("menu settings.json", "w")
	if err then 
		print("Could not save settings to \"menu settings.json\"")
		return 
	end
	options.p1Recording = {}
	options.p2Recording = {}
	for i = 1, system.recordingSlots, 1 do
		options.p1Recording[i] = getParsedRecording(p1.recorded[i])
		options.p2Recording[i] = getParsedRecording(p2.recorded[i])
	end
	local settingsString = json.stringify(options)
	options.p1Recording = p1.recorded
	options.p2Recording = p2.recorded
	local _, err = f:write(settingsString)
	if err then
		menu.info = "Error saving settings"
	else
		menu.info = "Saved settings successfully"
	end
	f:close()
end

function getParsedRecording(recording)
	if #recording == 0 then return {} end
	local strings = {}
	local count = 1
	local hex = recording[1]
	local previousHex = hex
	local str = hexToInputString(hex)
	for i = 2, #recording, 1 do
		hex = recording[i]
		if hex == previousHex then
			count = count + 1
		else
			str = str..tostring(count)
			strings[#strings + 1] = str
			str = hexToInputString(hex)
			count = 1
		end
		previousHex = hex
	end
	if count ~= 1 then
		str = str..tostring(count)
		strings[#strings + 1] = str
	end
	return strings
end

function hexToInputString(hex)
	local str = ""
	for k, v in pairs(parserDictionary) do
		if band(hex, v) == v then
			str = str..k
		end
	end
	return str
end

--Read settings from menu settings.txt
function readSettings()
	local f, err = io.open("menu settings.json", "r")
	if err then
		return
	end
	local optionString = f:read("*all")
	if #optionString == 0 then
		f:close()
		os.remove("menu settings.json")
		return
	end
	local parsedOptions = json.parse(optionString)
	tableCopy(parsedOptions, options)
	f:close()
end

function parseRecording(strings)
	local recording = {}
	for i = 1, #strings, 1 do
		local inputs = parseInput(strings[i])
		for _ = 1, inputs.wait, 1 do
			recording[#recording + 1] = inputs.hex
		end
	end
	return recording
end

function readTrials()
	local success = readTrial(options.trialsFilename)
	if success then return end
	success = readTrial("sample_trials.json")
	if success then return end
	local jsons = getTrialsJsons()
	if #jsons == 0 then return end
	readTrial(jsons[1])
end

function readTrial(filename)
	local t, err = io.open(filename, "r")
	if err then
		print(err)
		return false
	end
	trials = json.parse(t:read("*all"))
	sanitizeTrials()
	options.trialsFilename = filename
	if options.trialSuccess[filename] == nil then
		local successTable = {}
		for i = 1, 24, 1 do 
			successTable[i] = 0
		end
		options.trialSuccess[filename] = successTable
	end
	--sanitize for added boss characters
	if #options.trialSuccess[filename] < 24 then
		options.trialSuccess[filename][23] = 0
		options.trialSuccess[filename][24] = 0
	end
	return true
end

function exportTrial()
	if not trial.export then
		menu.info = "No new trials to export"
		playSound(sounds.error, 0x4040)
		return
	end
	local backup =  "_backup_"..options.trialsFilename
	local success = os.rename(options.trialsFilename, backup)
	if not success then
		menu.info = "Error backing up to "..backup
		playSound(sounds.error, 0x4040)
		return
	end
	local f, err = io.open(options.trialsFilename, "w")
	if err then
		menu.info = "Error accessing "..options.trialsFilename
		playSound(sounds.error, 0x4040)
		return
	end
	local trialString = json.stringify(trials)
	local _, err = f:write(trialString)
	if err then
		menu.info = "Error exporting trial"
		playSound(sounds.error, 0x4040)
	else
		menu.info = "Trials exported successfully"
		trial.export = false
		os.remove(backup)
		playSound(sounds.select, 0x4040)
	end
	f:close()
end

function getTrialsJsons()
	local handle = io.popen("dir .\\ /b")
	local files = {}
	if handle == nil then
	  	menu.info = "No trials jsons found"
	  	return files
	end
	for line in handle:lines() do
		if line:match(".*[Tt][Rr][Ii][Aa][Ll].*json$") then
			files[#files + 1] = line
		end
	end
	handle:close()
	return files
end

function readMoveDefinitions()
	local f, err = io.open("move_id_def.txt", "r")
	if err then
		return false
	end
	local index = 1
	for line in f:lines() do
		index = addMoveDefinition(line, index)
	end
	f:close()
end

function addMoveDefinition(line, index)
	if line == nil or #line == 0 then return index end
	local charIndex = charToIndex[nameToId[line]]
	if charIndex then 
		return charIndex
	end
	local _, _, id, name = line:find("(%d+)%s+([^-]*)")
	if id then
		id = tonumber(id)
		if name == nil or name == "" then
			moveDefinitions[index][id] = false
		else
			moveDefinitions[index][id] = name
		end
	end
	return index
end

function readRomhack()
	local f, err = io.open("romhack.txt", "r")
	if err then return end
	local table = {}
	local address
	for line in f:lines() do 
		local _, _, t, value = line:find("^([->]?)%s*(%x+)")
		if t == ">" then
			address = tonumber(value, 16)
		elseif value and t ~= "-" then
			table[address] = tonumber(value, 16)
			address = address + 2
		end
	end
	f:close()
	romHacks.txt = table
end

-------------------------------------------------
-- Romhacks
-------------------------------------------------

function writeHack(hack)
	-- If already active return
	if romHacks.active[hack] then return false end
	-- Check if caching is needed
	local cache = false
	-- Create cache for original bytes
	if not romHacks.cache[hack] then
		romHacks.cache[hack] = {}
		cache = true
	end
	for k, v in pairs(romHacks[hack]) do
		-- Store original bytes
		if cache then
			romHacks.cache[hack][k] = readWord(k) 
		end
		-- Write new bytes
		writeWord(k, v) 
	end
	-- Mark as active
	romHacks.active[hack] = true
	return true
end

function restoreHack(hack)
	-- If not active or no cache (shouldn't happen?) then return
	if not romHacks.active[hack] or not romHacks.cache[hack] then return false end
	-- Restore original bytes
	for k, v in pairs(romHacks.cache[hack]) do
		writeWord(k, v)
	end
	-- Mark as inactive 
	romHacks.active[hack] = false
	return true
end

function updateHacks()
	updateHack("killDenial", options.killDenial)
	updateHack("comboCounter", options.disableHud)
	updateHack("petshopFlap", not options.music)
	updateHack("txt", options.romHack)
	updateHack("boingo", options.boingo)
	updateKakyoinPose()
	updateStandGaugeLimit()
end

function updateHack(hack, option)
	if option then
		writeHack(hack)
	else
		restoreHack(hack)
	end
end

function updateStage(id)
	if id ~= system.stageId then
		--hack the stage id to a specific value
		romHacks.stageSwap[0x617929C] = 0xE200 + id
		writeHack("stageSwap")
		return true
	end
	return false
end

function updateCharacter(player, id)
	if player.character ~= id then
		if player.number == 1 then
			romHacks.p1Swap[0x604BFE6] = 0xE300 + id
			writeHack("p1Swap")
			system.p1Swap = 2
		else
			romHacks.p2Swap[0x604BFE6] = 0xE300 + id
			writeHack("p2Swap")
			system.p2Swap = 2
		end
		return true
	end
	return false
end

function updateKakyoinPose()
	restoreHack("kakyoinPose")
	if options.kakyoinPose > 1 then
		local poseByte = 0x0200 + options.kakyoinPose - 2
		romHacks.kakyoinPose[0x6811926] = poseByte
		romHacks.kakyoinPose[0x681198A] = poseByte
		romHacks.kakyoinPose[0x6895BE2] = poseByte
		romHacks.kakyoinPose[0x6895C46] = poseByte
		writeHack("kakyoinPose")
	end
end

function updateStandGaugeLimit()
	restoreHack("standGauge")
	if options.standGaugeLimit then
		romHacks.standGauge[0x60451B2] = 0xE300 + options.p2StandGauge
		romHacks.standGauge[0x60451BA] = 0xE200 + options.p2StandGauge
		writeWord(p2.memory2.standGaugeRefill, options.p2StandGauge)
		writeHack("standGauge")
	end
end

-------------------------------------------------
-- Memory Reader
-------------------------------------------------

function updateMemory()
	readSystemMemory()
	readPlayerMemory(p1)
	readPlayerMemory(p2)
	readProjectileMemory()
end

function readPlayerMemory(player) 
	player.previousHealth = player.health
	player.previousCombo = player.combo
	player.previousGuarding = player.guarding
	player.previousAnimationState = player.animationState
	player.previousRiseFall = player.riseFall
	player.previousHitstun = player.hitstun
	player.previousblockstun = player.blockstun
	player.previousIps = player.ips
	player.previousIpsCount = player.ipsCount
	player.previousScaling = player.scaling
	player.previousWakeupCount = player.wakeupCount
	player.previousAirtechCount = player.airtechCount
	player.previousDefenseAction = player.defenseAction
	player.previousPushblockCount = player.pushblockCount
	player.previousGuardCount = player.guardCount
	player.previousHitCount = player.hitCount
	player.previousHitFreeze = player.hitFreeze
	player.previousStunCount = player.stunCount
	player.previousAttackId = player.attackId
	player.previousStandAttackId = player.standAttackId
	player.previousAttackHit = player.attackHit
	player.previousStandAttackHit = player.standAttackHit
	player.previousTandem = player.tandem
	player.previousTandemCount = player.tandemCount
	player.previousStand = player.stand
	player.previousActionId = player.actionId
	player.previousStandActionId = player.standActionId
	player.previousY = player.y
	player.previousTechable = player.techable
	player.previousFrameAddress = player.frameAddress
	player.previousStandFrameAddress = player.standFrameAddress
	for k, v in pairs(player.memory) do
		player[k] = readByte(v)
	end
	for k, v in pairs(player.memory2) do
		player[k] = readWordSigned(v)
	end
	for k, v in pairs (player.memory4) do
		player[k] = readDWord(v)
	end
	if player.standGauge < player.standHealth then
		player.standGauge = player.standHealth
	end
end

function readProjectileMemory()
	for i = 0, 63, 1 do
		local projectile = projectiles[i + 1]
		projectile.previousState = projectile.state
		local address = 0x0203848C + i * 0x420
		projectile.state = readByte(address)
		if projectile.state > 0 then
			projectile.facing = readByte(address + 0x0D)
			projectile.char = readByte(address + 0x13)
			projectile.hitbox = readWord(address + 0xAC)
			projectile.x = readWordSigned(address + 0x5C)
			projectile.y = readWordSigned(address + 0x60)
			projectile.previousAttackId = projectile.attackId
			projectile.attackId = readByte(address + 0xDC)
			projectile.previousAttackHit = projectile.attackHit
			projectile.attackHit = readByte(address + 0xDD)
			projectile.previousActionId = projectile.actionId
			projectile.actionId = readByte(address + 0x92)
			projectile.frameAddress = readDWord(address + 0x8C)
			if projectile.previousState == 0 then
				projectile.consumed = false
			end
		end
	end
end

function readSystemMemory()
	system.screenFreeze = readByte(0x020314C6)
	system.stageId = readByte(0x02031459)
	system.screenX = readWordSigned(0x0203145C)
	system.screenY = readWordSigned(0x02031470)
	system.previousTimeStop = system.timeStop
	system.timeStop = readByte(0x20314C2)
	system.slowDown = readByte(0x2006190)
	system.frameCount = readDWord(0x2031448)
	system.previousPlayerSelect = system.playerSelect
	system.playerSelect = readByte(0x2033142)
	system.coined = readByte(0x20314AA)
	system.state = readByte(0x2031452) -- 1 character select, 2 pre battle, 3 battle 
	system.inMatch = system.state == 3
	system.zoomState = readByte(0x2048DA8) -- 0 zoomed in, 1 zooming out, 2 zoomed out, 3 zooming in
	system.betweenRounds = readByte(0x020314A2) > 0
	system.rng = readDWord(0x20162E4)
	system.rng2 = readDWord(0x205C1B8)
	--system.timeStopState = readByte(0x2033ABD)
	--system.screenZoom = 0
end

-------------------------------------------------
-- Inputs
-------------------------------------------------

function updateInput()
	updatePlayerInput(p1)
	updatePlayerInput(p2)

	if options.inputStyle == 1 then
		p1.inputHistoryTable[1] = p1.inputs
		p2.inputHistoryTable[1] = p2.inputs
	elseif options.inputStyle == 2 then
		updateSimpleHistory(p1)
		updateSimpleHistory(p2)
	elseif options.inputStyle == 3 then
		updateFrameHistory(p1)
		updateFrameHistory(p2)
	end
end

function updatePlayerInput(player)
	player.previousInputs = player.inputs
	player.inputs = getPlayerInputHex(player.name)
	for _, v in pairs(player.buttons) do
		if inputModule.current[v] then
			inputModule.held[v] = inputModule.held[v] + 1
		else
			inputModule.held[v] = 0
		end
	end
end

function updateInputBefore()
	inputModule.previous = inputModule.current
	inputModule.current = joypad.read() -- reads all inputs
	inputModule.transfer = false

	updatePlayerInputBefore(p1, p2)
	updatePlayerInputBefore(p2, p1)

	-- Disable taunt
	if not options.taunt and system.inMatch and band(system.coined, 1) == 1 then
		inputModule.start = inputModule.current[p1.buttons.start]
		inputModule.overwrite[p1.buttons.start] = false
	else
		inputModule.start = false
	end

	-- Character Select Control
	updateSelectTransfer()

	if inputModule.transfer then
		transferInputs(inputModule.current, inputModule.overwrite)
	end

	tableCopy(inputModule.overwrite, inputModule.current)
	joypad.set(inputModule.current)
end

function updatePlayerInputBefore(player, other)
	if not system.inMatch or menu.state > 0 then return end
	if player.previousControl and not player.control then
		local direction = band(getPlayerInputHex(other.name), 0x0F) 
		player.directionLock = player.side == 1 and direction or swapHexDirection(direction)
		updateBlockStatus(player)
	end
	-- Input Playback
	if player.playbackCount > 0 then
		local hex =  player.playback[#player.playback - player.playbackCount + 1]
		hex = (player.playbackFlipped and swapHexDirection(hex) or hex)
		local inputs = hexToPlayerInput(hex, player.name)
		tableCopy(inputs, inputModule.overwrite)
		player.playbackCount = player.playbackCount - 1
		if player.playbackCount == 0 then
			if player.loop then
				player.playback = duplicateList(getPlaybackRecording(player), false, false)
				insertDelay(player.playback, options.replayInterval, 0)
				player.playbackCount = #player.playback
				player.playbackFlipped = player.facing ~= 1
			end
		end
	elseif player.control or (player.recording and options.mediumKickHotkey == "recordP2") then
		inputModule.transfer = true
	elseif player.directionLock ~= 0 then
		local direction = (player.side == 1 and player.directionLock or swapHexDirection(player.directionLock))
		local directionInputs = hexToPlayerInput(direction, player.name)
		tableCopy(directionInputs, inputModule.overwrite)
	end
end

function updateBlockStatus(player)
	--update status option
	if band(player.directionLock, 0x1) == 0x1 then
		options.status = 3 --jump
	elseif band(player.directionLock, 0x2) == 0x2 then
		options.status = 2 --crouch
	else
		options.status = 1 --stand
	end
	--update block option
	if options.block < 3 then
		if band(player.directionLock, 0x4) == 0x4 then
			options.block = 2 --block
		else
			options.block = 1 --no block
		end
	else
		player.directionLock = band(player.directionLock, 0x3)
	end
end

function updateSelectTransfer()
	if system.state == 1 then -- character select
		if system.playerSelect == 0 and pressedTable(playerSelectInputs) then -- None selected and p1 selects a char
			if system.coined == 1 then
				inputModule.overwrite[p2.buttons.start] = true
			end
			inputModule.transferWait = true
		elseif system.playerSelect == 1 and system.coined == 3 then -- P1 selected P2 not selected, both coined
			-- Wait until the select is released or it will auto select the character
			if inputModule.transferWait then
				inputModule.transferWait = heldTable(playerSelectInputs, 0)
			else
				inputModule.transfer = true
			end
		elseif system.playerSelect == 3 then
			inputModule.transferWait = false
		end
	end
end

--Returns whether a key is pressed once
function pressed(key)
	return (not inputModule.previous[key] and inputModule.current[key])
end

--Checks a table of inputs for being pressed
function pressedTable(table)
	for i = 1, #table, 1 do
		if pressed(table[i]) then return true end
	end
	return false
end

--This is like when you hold down a key on a computer and it spams it after a certain amount of time
function repeating(key) 
	local value = inputModule.held[key]
	if value == 0 then 
		return false 
	end
	if value == 1 or (value > 20 and value % 3 == 0) then
		return true
	end
	return false
end

--Input held for x frames
function held(key, x)
	return inputModule.held[key] > x
end

function heldTable(table, x)
	for i = 1, #table, 1 do
		if held(table[i], x) then return true end
	end
	return false
end

--Turns a hex into both players inputs
function hexToInputTable(hex)
	local table = {}
	inputTableInsert(table, hex, "P1 ")
	inputTableInsert(table, rShift(hex, 8), "P2 ")
	return table
end

--Turns a hex into a player input table
function hexToPlayerInput(hex, player)
	local table = {}
	inputTableInsert(table, hex, player)
	return table
end

--Used by hextoinputtable
function inputTableInsert(table, hex, player)
	for k, v in pairs(inputDictionary) do
		if band(k, hex) == k then
			table[player..v] = true
		end
	end
end

--Swaps left and right in a hex for changing sides
function swapHexDirection(hex)
	return swapBits(hex, 2, 3)
end

--swaps two individual bits in a hex
function swapBits(hex, p1, p2)
	local bit1 = band(rShift(hex, p1), 1)
	local bit2 = band(rShift(hex, p2), 1)
	local x = bxor(bit1, bit2)
	x = bor(lShift(x, p1), lShift(x, p2))
	return bxor(hex, x)
end

-- Gets the specified players inputs as a hex
function getPlayerInputHex(name)
	local hex = 0
	for k, v in pairs(inputDictionary) do
		if inputModule.current[name..v] then
			hex = bor(hex, k)
		end
	end
	return hex
end

-- Updates the the input history on the hud
function updateSimpleHistory(player)
	local direction = band(player.inputs, 0x0F)
	local previousDirection = band(player.previousInputs, 0x0F)
	local buttons = band(player.inputs, 0xF0)
	local previousButtons = band(player.previousInputs, 0xF0)
	player.previousNewButtons = player.newButtons
	player.newButtons = band(bxor(previousButtons, 0xF0), buttons)
	if (player.previousNewButtons ~= player.newButtons and player.newButtons ~= 0) or 
			(previousDirection ~= direction and direction ~= 0) then
		for i = 13, 2, - 1 do
			player.inputHistoryTable[i] = player.inputHistoryTable[i - 1]
		end
		if previousButtons ~= buttons then
			player.inputHistoryTable[1] = player.newButtons + direction
		else
			player.inputHistoryTable[1] = direction
		end
	end
end

function updateFrameHistory(player)
	if player.inputs ~= player.previousInputs then
		if band(player.inputHistoryTable[1], 0xFFFF) > 600 then
			clearInputHistory(player)
		else
			for i = 13, 2, - 1 do
				player.inputHistoryTable[i] = player.inputHistoryTable[i - 1]
			end
		end
		-- First 2 bytes are frame count, 3rd is inputs
		player.inputHistoryTable[1] = lShift(player.inputs, 16) + 1
	else
		player.inputHistoryTable[1] = player.inputHistoryTable[1] + 1
	end
end

function clearInputHistory(player)
	local int = options.inputStyle == 3 and -1 or 0
	for i = 1, 13, 1 do 
		player.inputHistoryTable[i] = int
	end
end

function transferInputs(source, dest)
	for i = 1, #transferButtons, 1 do
		local p1key = "P1 "..transferButtons[i]
		if source[p1key] then
			dest[p1key] = false
			dest["P2 "..transferButtons[i]] = true
		end
	end
end

-------------------------------------------------
-- Gameplay Loop
-------------------------------------------------

function updateGameplayLoop() --main loop for gameplay calculations
	updatePlayer(p1, p2)
	updatePlayer(p2, p1)
	updateBlock(p2, p1)
	writeByte(0x205CC1A, options.music and 0x80 or 0x00) -- Toggle music off or on

	if fcReplay then return end  -- Don't write if replay

	writeByte(0x20312C1, 0x01) -- Unlock all characters
	writeByte(0x20314B4, 0x63) -- Infinite Clock Time
	if options.infiniteRounds then
		writeByte(0x2034860, 0) -- Reset round to 0
		writeByte(0x2034884, 0)
	end
	if not options.ips then -- IPS
		writeByte(p1.memory.ips, 0x00)
		p1.ips = 0
	end
	if not options.tandemCooldown then
		writeByte(0x02034AC9, 0x00)
		writeByte(0x02034EE9, 0x00)
	end
	if options.level > 1 then
		writeByte(0x02033210, options.level - 2)
	end
	if romHacks.active.stageSwap then
		restoreHack("stageSwap")
	end
	if system.p1Swap > 0 then
		updatePlayerSwap(p1, system.p1Swap, "p1Swap")
		system.p1Swap = system.p1Swap - 1
	end
	if system.p2Swap > 0 then
		updatePlayerSwap(p2, system.p2Swap, "p2Swap")
		system.p2Swap = system.p2Swap - 1
	end
	if options.disableHud then 
		removeGameHud()
	end
	if options.guiStyle == 3 then
		updateIPSPrediction()
	elseif options.guiStyle == 5 then
		updateFrameData()
	elseif options.guiStyle == 9 then
		updateProjectileFrameInfo()
	end
	if options.characterSpecific then
		updateCharacterSpecific()
	end
end

function updatePlayer(player, other) 
	--combo counters
	if (player.previousHealth > player.health or other.combo > other.previousCombo) then
		player.damage = math.abs(player.previousHealth - player.health)
		if (other.combo > 1 and other.previousCombo ~= 0) then
			other.comboDamage = math.abs(other.comboDamage) + player.damage
		else
			other.comboDamage = player.damage
		end
		player.previousDamage = player.damage
	end

	if player.combo >= 2 then
		player.displayComboCounter = player.combo
		player.comboCounterColor = options.comboCounterActiveColor
	else
		player.comboCounterColor = "white"
	end

	--Health Regen
	if options.healthRefill > 1 and ((player.previousCombo > 0 or other.damage ~= 0) and (player.combo == 0)) then
		if options.healthRefill == 2 then
			local maxHealth = player.number == 1 and options.p2Hp or options.p1Hp
			writeWord(other.memory2.healthRefill, maxHealth)
		elseif options.healthRefill == 3 then
			other.healthDelay = 60
		end
		other.damage = 0
	end 

	if other.combo > 0 or player.hitstun == 3 or player.hitstun == 4 or system.timeStop > 0 or system.betweenRounds then
		player.healthDelay = 0
	end

	if player.healthDelay > 0 then
		if player.healthDelay == 1 then
			local maxHealth = player.number == 1 and options.p1Hp or options.p2Hp
			player.healthRefill = math.min(player.healthRefill + 2, maxHealth)
			writeWord(player.memory2.healthRefill, player.healthRefill)
			if player.healthRefill < maxHealth then
				player.healthDelay = 2
			end
		end
		if system.screenFreeze == 0 then
			player.healthDelay = player.healthDelay - 1
		end
	end

	--Meter refill
	if options.meterRefill > 1 and system.timeStop == 0 and system.screenFreeze == 0 then
		if options.meterRefill == 2 then
			writeByte(player.memory.meterNumber, 0x0A)
		elseif options.meterRefill == 3 then
			player.meterBar = player.meterBar + 2
			if player.meterBar >= 104 then
				player.meterBar = 0
				player.meterNumber = player.meterNumber + 1
				if player.meterNumber >= 10 then
					player.meterBar = 104
					player.meterNumber = 10
				end
			end
			writeByte(player.memory.meterNumber, player.meterNumber)
			writeByte(player.memory.meterBar, player.meterBar)
		end
	end

	--Infinite Timestop
	if system.timeStop == 1 and options.infiniteTimestop then
		writeByte(player.memory.meterNumber, 0x0A)
	end

	--Stand refill 
	if options.standGaugeRefill and player.standHealth <= 0 and player.cc == 0 then
		--local maxGauge = player.number == 1 and options.p1StandGauge or options.p2StandGauge
		local max = options.standGaugeLimit and options.p2StandGauge or player.standGaugeMax
		writeWord(player.memory2.standGaugeRefill, max)
	end

	-- Air Tech
	player.previousAirTech = player.airtech

	player.airtech = player.height > 0 and player.hitstun == 1 and player.riseFall == 0xFF and
		(player.previousRiseFall == 0x00 or --Rising to falling
		(player.previousAnimationState == 1 and player.animationState == 2)) -- Spiked

	-- If the air tech gets eaten by a screen freeze try again after the screen freeze ends
	if system.screenFreeze > 0 then
		if player.previousAirTech then
			player.screenFreezeTech = true
		end
	else
		if player.screenFreezeTech then
			player.airtech = true
			player.screenFreezeTech = false
		end
	end

	-- Reversals

	-- If the player is in defense action 28 or 30 and the wakeupFreeze is finished they are starting their wakeup
	if (player.defenseAction == 28 or player.defenseAction == 30) and player.wakeupFreeze == 0xFF and player.wakeupCount == 0 then
		-- For some god forsaken reason specific characters with specific wakeups cancel into their idle early
		-- I've tried to figure out why but i have no idea so i've hardcoded offsets for each characters wakeup animation :^)
		local wakeupOffset = wakeupOffsets[player.character + 1][player.defenseAction == 28 and 1 or 2]
		player.wakeupCount = getActionLength(player.actionAddress) + wakeupOffset + 2
		player.hitCount = 0
	end

	if player.guarding > 0 and player.previousGuarding == 0 then
		updateGuardReversal(player)
		player.hitCount = 0
	end

	-- If hit and not defenseAction 29 (Launch) or in the air already
	if player.hitstun == 1 and player.previousHitstun ~= 1 then
		if player.y == 0 and player.defenseAction ~= 29 and player.defenseAction ~= 27 and player.defenseAction ~= 39  then
			updateHitReversal(player)
			player.guardCount = 0
		end
	end

	-- Update reversal counters
	if system.screenFreeze == 0 and system.timeStop == 0 then -- not screen frozen

		if player.wakeupCount > 0 then
			-- if not in hol horse slow down skip frame
			if system.slowDown == 0 or system.frameCount % 2 == 0 then
				player.wakeupCount = player.wakeupCount - 1
				player.wakeupFrame = (player.wakeupCount == 1)
			end
		end

		if player.guardCount > 0 then
			if freezeStunUpdated(player) then
				updateGuardReversal(player)
			end
			player.guardCount = player.guardCount - 1
		end

		if player.hitCount > 0 then
			if freezeStunUpdated(player) then
				updateHitReversal(player)
			end
			player.hitCount = player.hitCount - 1
		end

		if player.airtechCount > 0 then
			player.airtechCount = player.airtechCount - 1
		end

		if player.pushblockCount > 0 then
			player.pushblockCount = player.pushblockCount - 1
		end
	end

	-- Update meaty
	if player.wakeupFrame then
		if player.hitFreeze > 0 or player.defenseAction == 27 then -- If hit or sweep
			if player.guarding > 0 then
				updateGuardReversal(player)
			else
				updateHitReversal(player)
			end
			player.meaty = true
		else
			player.meaty = false
		end
	end

	-- Kill denial
	if options.killDenial and player.healthRefill < 0 then
		writeWord(player.memory2.healthRefill, 0)
	end

	-- Can Act
	updatePlayerAct(player)

	-- Update out of hitstun count
	if player.hitstun > 0 then
		player.afterHitstun = 0
	elseif system.screenFreeze == 0 then
		player.afterHitstun = player.afterHitstun + 1
	end
end

function updateBlock(player, other)
	if options.block == 3 then -- Block all
		local direction = getBlockDirectionLock(player, other)
		if band(direction, 0x4) == 0x4 then
			player.directionLock = direction
			player.blockAll = 12
		else
			if player.blockAll == 1 then
				player.directionLock = direction
			end
			if system.screenFreeze == 0 then
				player.blockAll = player.blockAll - 1
			end
		end
	elseif options.block == 4 or options.block == 5 then -- Block after hit
		if player.wakeupCount == 2 and player.afterHit > 0 then
			player.afterHit = 0
			player.directionLock = band(player.directionLock, 0x3) 
		elseif player.canAct then
			if player.afterHit == 1 then
				if options.status == 1 then
					player.directionLock = 0x0
				elseif options.status == 2 then
					player.directionLock = 0x2
				elseif options.status == 3 then
					player.directionLock = 0x1
				end
			elseif options.block == 5 and player.afterHit > 0 then
				local direction = getBlockDirectionLock(player, other)
				if band(direction, 0x4) == 0x4 then
					player.directionLock = direction
				end
			end
			if system.screenFreeze == 0 then
				player.afterHit = player.afterHit - 1
			end
		else
			player.afterHit = 30
			if options.block == 4 then
				player.directionLock = band(player.directionLock, 0x3) + 0x4
			elseif options.block == 5 then
				local direction = getBlockDirectionLock(player, other)
				if band(direction, 0x4) == 0x4 then
					player.directionLock = direction
				end
			end
		end
	elseif options.block == 6 then --random
		local direction = getBlockDirectionLock(player, other)
		if player.canAct then
			if player.randomBlock == 0 then
				player.randomBlock = math.random(2)
			end
			if player.randomBlock == 1 then
				if band(direction, 0x4) == 0x4 then
					player.directionLock = direction
					player.blockAll = 12
				else
					if player.blockAll == 1 then
						player.directionLock = direction
					end
					if system.screenFreeze == 0 then
						player.blockAll = player.blockAll - 1
					end
				end
			else
				if options.status == 1 then
					player.directionLock = 0x0
				elseif options.status == 2 then
					player.directionLock = 0x2
				elseif options.status == 3 then
					player.directionLock = 0x1
				end
			end
		else
			if player.wakeupCount == 2 then
				player.randomBlock = math.random(2)
				if player.randomBlock == 1 then
					player.directionLock = direction
				else
					player.directionLock = band(direction, 0x3)
				end
				player.blockAll = 0
			else
				if band(direction, 0x4) == 0x4 then
					player.directionLock = direction
				end
				player.blockAll = 2
			end
			player.randomBlock = 0
		end
	end
end

function getBlockDirectionLock(player,other)
	local hitType = getBlockDirection(other)
	if hitType == 0 then --neutral
		if options.status == 1 then
			return 0x0
		elseif options.status == 2 then
			return 0x2
		elseif options.status == 3 then
			return 0x1
		end
	elseif band(hitType, 0x1) == 0x1 then --overhead
		return 0x4
	elseif band(hitType, 0x4) == 0x4 then --low
		return 0x6
	else --mid, unblockable
		if options.status == 1 then
			return  0x4
		elseif options.status == 2 then
			return  0x6
		elseif options.status == 3 then
			return  0x5
		end
	end
end

function getBlockDirection(player)
	local hitType = 0
	if player.stand == 0 then
		local frameType = getHitType(player.frameAddress, player.address, player.attackId, player.previousAttackId, player.attackHit)
		hitType = bor(hitType, frameType)
	end
	if player.standActive > 0 then
		local frameType = getHitType(player.standFrameAddress, player.standAddress, player.standAttackId, player.previousStandAttacId, player.standAttackHit)
		hitType = bor(hitType, frameType)
	end
	for i = 1, 32, 1 do
		local projectile = projectiles[i]
		if projectile.state > 0 then
			local address = 0x0203848C + (i - 1) * 0x420
			local frameType = getHitType(projectile.frameAddress, address, projectile.attackId, projectile.previousAttackId, projectile.attackHit)
			hitType = bor(hitType, frameType)
		end
	end
	return hitType
end

function getHitType(frameAddress, address, attackId, previousAttackId, attackHit)
	local blockFrame = blockActiveFrame[frameAddress]
	if blockFrame then return blockFrame end
	if hasNextHitbox(address, frameAddress) then
		return getFrameHitType(address, attackId, previousAttackId, attackHit)
	end
	return 0
end

function hasNextHitbox(address, frame)
	if hasHitbox(readByte(frame + 0xD)) then return true end
	frame = getNextFrame(address, frame)
	if frame == 0 then return false end
	if hasHitbox(readByte(frame + 0xD)) then return true end
	if readByte(address + 0x1ac) == 1 then --tandem skips frames
		frame = getNextFrame(address, frame)
		return hasHitbox(readByte(frame + 0xD))
	end
	return false
end

function getFrameHitType(address, attackId, previousAttackId, attackHit)
	if attackHit > 0 and attackId == previousAttackId then return 0 end
	local attackAddress = readDWord(address + 0xD0) + attackId * 0x30
	local hitType = band(readByte(attackAddress + 0x4), 0x3)
	if hitType == 0 then --overhead
		return 1
	elseif hitType == 1 then --mid
		return 2
	elseif hitType == 2 then --low
		return 4
	elseif hitType == 3 then --unblockable
		return 8
	end
end

function getNextFrame(address, frame)
	if readByte(frame + 0x02) == 0x80 then 
		return 0
	end
	frame = frame + readByte(frame + 0x1)
	local ram = {
		[0xA4] = readByte(address + 0xA4)
	}
	while true do
		local type = readByte(frame)
		if type == 0x0 or type == 0x2 or type == 0xF then --frame/simple/no sprite
			return frame
		elseif type == 0x1 then --branch
			frame = readDWord(frame + 0x4)
		elseif type == 0x3 then --a4 ~= 0
			if ram[0xA4] == 0 then
				frame = frame + 8
			else
				frame = readDWord(frame + 0x4)
			end
		elseif type == 0x4 then --a4 == 0
			if ram[0xA4] == 0 then
				frame = readDWord(frame + 0x4)
			else
				frame = frame + 8
			end
		elseif type == 0x5 then --a4 = 0
			ram[0xA4] = 0
			frame = frame + 4
		elseif type == 0x6 then --a4 + (frame + 2) = (frame + 3)
			ram[0xA4 + readByte(frame + 0x2)] = readByte(frame + 0x3)
			frame = frame + 4
		elseif type == 0x7 then --a4 + (frame + 2) += (frame + 3)
			local offset = readByte(frame + 0x2)
			local byte = ram[0xA4 + offset] or readByte(address + 0xA4 + offset)
			byte = byte + readByte(frame + 0x3)
			ram[0xA4 + offset] = byte
			frame = frame + 4
		elseif type == 0x8 then --a4 + (frame + 2) == (frame + 3) and A4 = 0xFF or A4 = 0x00
			local offset = readByte(frame + 0x2)
			local byte = ram[0xA4 + offset] or readByte(address + 0xA4 + offset)
			if byte == readByte(frame + 0x3) then
				ram[0xA4] = 0xFF
			else
				ram[0xA4] = 0x0
			end
			frame = frame + 4
		elseif type == 0x9 then --a4 = (frame + 2) &= (frame + 3)
			local offset = readByte(frame + 0x2)
			local byte = ram[0xA4 + offset] or readByte(address + 0xA4 + offset)
			byte = band(byte, readByte(frame + 0x3))
			ram[0xA4 + offset] = byte
			frame = frame + 4
		elseif type == 0xA then --???
			if readByte(frame + 0x3) ~= 0 then
				local byte = ram[0xAE] or readByte(address + 0xAE)
				local offset = readByte(frame + 0x2)
				ram[0xA4 + offset] = byte
			end
			frame = frame + 4
		elseif type == 0xB then --subroutine
			ram[0x94] = frame + 8
			frame = readDWord(frame + 0x4)
		elseif type == 0xC then --return from subroutine
			frame = ram[0x94] or readDWord(address + 0x94)
		elseif type == 0xD then --random
			local offset = readByte(frame + 0x2)
			ram[0] = getNextRn(ram[0])
			ram[0xA4 + offset] = band(modifyRn(ram[0]), readByte(frame + 0x3))
			frame = frame + 4
		elseif type == 0xE then --lookup table
			local offset = readByte(frame + 0x2)
			local byte = ram[0xA4 + offset] or readByte(address + 0xA4 + offset)
			frame = frame + 4 + byte * 4 
		elseif type == 0x10 then --f+2 = 198
			local offset = readWord(frame + 0x2)
			ram[0xA4 + offset] = readByte(address + 0x198)
			frame = frame + 4
		elseif type == 0x11 then --f+2 = 194
			local offset = readWord(frame + 0x2)
			ram[0xA4 + offset] = readByte(address + 0x194)
			frame = frame + 4
		elseif type == 0x12 then --f+2 = 192
			local offset = readWord(frame + 0x2)
			ram[0xA4 + offset] = readByte(address + 0x192)
			frame = frame + 4
		else
			return 0
		end
	end
end

function getNextRn(seed)
	local rng = seed or system.rng
	rng = rng * 0x41C54E6D
	rng = band(rng, 0xFFFFFFFF)
	rng = rng + 3039
	return rng
end

function modifyRn(rng)
	rng = rShift(rng, 16)
	rng = band(rng, 0x7FFF)
	return rng
end

function getNextRn2(seed)
	local rng = seed or system.rng2
	rng = rng * 3 + 0x3711
	rng = band(rng, 0xFFFF)
	return rng
end

function modifyRn2(rng)
	return band(rShift(rng, 8), 0xFF)
end

function getActionLength(address)
	local count = 0
	while true do
		if readByte(address) ~= 0 then
			break
		end
		count = count + readByte(address + 0x03)
		if readByte(address + 0x02) == 0x80 then 
			break 
		end
		address = address + 0x20
	end
	return count
end

function updateGuardReversal(player)
	player.guardCount = player.hitFreeze + stunType[band(player.stunType, 0x0F)] + 3
	-- Add the motion lenth if bufferable
	if options.reversalReplay == 3 or options.reversalReplay == 5 or 
	   (options.reversalReplay == 1 and options.reversalMotion ~= 1) then
		player.guardCount = player.guardCount + #system.reversal - 1
		-- if a reversal replay then adjust based on final button index
		if options.reversalReplay == 3 then
			player.guardCount = player.guardCount - getFinalButtonIndex(system.reversal) + 1
		end
	end
end

function updateHitReversal(player)
	player.hitCount = player.hitFreeze + stunType[band(player.stunType, 0x0F)] + 5
end

function freezeStunUpdated(player)
	if player.hitFreeze == 0 and player.stunCount == 0 and player.previousHitFreeze ~= 1 and player.previousStunCount == stunType[player.stunType] then return false end
	if player.hitFreeze == player.previousHitFreeze and player.hitFreeze ~= 0 then return true end
	return player.hitFreeze > player.previousHitFreeze or player.stunCount < player.previousStunCount
end

function updatePlayerSwap(player, count, hack)
	if count == 2 then
		restoreHack(hack)
	elseif count == 1 then
		local address = player.address
		writeByte(address + 0x1B2, 0) --clear round start animation wait timer
		writeByte(address + 0xE4, 1) --clear round start animation
		writeByte(address + 0xE5, 0) --clear round start animation
		writeWord(0x205BAFC, 0) --clear hud update wait timer
		writeByte(0x2034AA2, 0) --enable p1 borders
		writeByte(0x2034AA3, 1) --enable p1 screen scroll
		writeByte(0x2034EC2, 0) --enable p2 borders
		writeByte(0x2034EC3, 1) --enable p2 screen scroll
		writeByte(0x20314A2, 0) --enable zoom
		--updateStandGaugeMax() --Update max stand gauge for menu
		--Fix for hoingo breaking stage borders
		if not trial.enabled and player.character == 23 then
			writeWord(player.memory2.x, system.screenX + 200)
		end
	end
end

function removeGameHud()
	writeWord(0x205BAFE, 0xF201) --Hp bars
	writeWord(0x205BB00, 0xEF01) --P1 meter
	writeWord(0x205BB02, 0x4001) --P2 meter
	writeWord(0x205BB7C, 0xF031) --Stand On/First Hit ect.
	writeByte(0x205BB30, 0xF0) --Combo counter
end

function updateFrameData()
	--Iframes
	updateIFrames()

	--Frame Advantage
	updatePlayerFrameAdvantage(p1, p2)
	updatePlayerFrameAdvantage(p2, p1)

	--Start Up/Active/Recovery
	updateAnimationData()
end

function updateAnimationData()
	if system.screenFreeze > 0 then return end --Don't update on screen freeze 

	local hitbox, frameAddress

	if p1.standActive == 1 then
		hitbox = p1.standHitbox
		frameAddress = p1.standFrameAddress
	else
		hitbox = p1.hitbox
		frameAddress = p1.frameAddress
	end

	local hasActive = hasHitbox(hitbox)

	--Check projectiles if no hitbox found
	if not hasActive then
		local projectile = getActiveProjectile()
		if projectile then
			hitbox = projectile.hitbox
			frameAddress = projectile.frameAddress
		end
	end

	local invul
	if p1.stand > 0 then
		invul = hud.standInvul
	else
		invul = hud.invul
	end

	--If new action
	if p1.previousCanAct and not p1.canAct then
		--Start calculating new frames
		system.recovery = 0
		system.iFrames = invul and { 0, 1 } or { 1 }
		if hasHitbox(hitbox) then
			system.startUp = 0
			system.active = { frameHitStop(frameAddress) and 0 or 1}
			system.frameState = 1
		else
			system.startUp = 1
			system.active = { 0 }
			system.frameState = 0
		end
	elseif p1.canAct and not p1.previousCanAct then
		--Store complete frames for display
		if system.active[1] ~= 0 then
			local active = ""
			for i = 1, #system.active, 1 do
				if i % 2 == 0 then
					active = active.."("..system.active[i]..") "
				else
					active = active..system.active[i].." "
				end
			end 
			local iFrames
			if #system.iFrames == 1 then
				iFrames = "0"
			else
				iFrames = ""
				local count = system.iFrames[1]
				for i = 2, #system.iFrames, 1 do
					if i % 2 == 0 then
						iFrames = iFrames..(count + 1)
						if i == #system.iFrames then
							iFrames = iFrames.."-"..(count + system.iFrames[i])
						end
					else
						iFrames = iFrames.."-"..count
						if i ~= #system.iFrames then
							iFrames = iFrames..", "
						end
					end
					count = count + system.iFrames[i]
				end
			end
			hud.startUp = system.startUp
			hud.active = active
			hud.recovery = system.recovery
			hud.iFrames = iFrames
		end
	else
		--Don't update on hitstop
		if frameHitStop(frameAddress) then return end

		if system.frameState == 0 then --Start up
			if hasHitbox(hitbox) then
				system.frameState = 1
				system.active[#system.active] = system.active[#system.active] + 1
				system.startUp = system.startUp + 1
			else
				system.startUp = system.startUp + 1
			end
		elseif system.frameState == 1 then --Active
			if hasHitbox(hitbox) then
				system.active[#system.active] = system.active[#system.active] + 1
			else
				system.frameState = 2
				system.recovery = system.recovery + 1
			end
		elseif system.frameState == 2 then --Recovery
			if hasHitbox(hitbox) then
				system.active[#system.active + 1] = system.recovery
				system.active[#system.active + 1] = 1
				system.recovery = 0
				system.frameState = 1
			else
				system.recovery = system.recovery + 1
			end
		end

		--iframes
		local iFrames = system.iFrames
		if (invul and #iFrames % 2 == 1) or (#iFrames % 2 == 0 and not invul) then
			iFrames[#iFrames + 1] = 1
		else
			iFrames[#iFrames] = iFrames[#iFrames] + 1
		end	
	end
end

function updatePlayerAct(player)
	player.previousCanAct = player.canAct
	if player.number == 1 then
		if player.stand == 0 then
			if player.character == 6 and projectiles[1].state == 1 and projectiles[1].attackId == 15 then --alessi projectile normals
				player.previousProjectileEnd = player.projectileEnd
				player.projectileEnd = readByte(0x2034A2A)
				player.canAct = playerCanAct(player, player.attackType, player.previousProjectileEnd == 1 and 0 or 1, player.canAct2, projectiles[1].frameAddress)
			else
				player.canAct = playerCanAct(player, player.attackType, player.canAct1, player.canAct2, player.frameAddress)
			end
		else
			player.canAct = playerCanAct(player, player.standAttackType, player.standCanAct1, player.standCanAct2, player.standFrameAddress)
		end
	else
		local guardState = player.stand == 0 and player.guardState or player.standGuardState
		if player.yVelocity > 0 and player.yVelocity < 0x80000000 then --if positive signed
			guardState = 0
		end
		if player.guardAct then
			player.canAct = (guardState == 0 or guardState == 2)
			if player.canAct then 
				player.guardAct = false
			end
		elseif guardState == 1 then
			player.actType = 1
			player.guardAct = true
			player.canAct = false
			player.guardFrame = emu.framecount()
		else
			player.canAct = (player.standActive == 0 and player.standHitsun == 0 or player.hitstun == 0)
			if not player.canAct and player.wakeupCount > 0 then
				player.actType = 2
			end
		end
	end

	if player.canAct and not player.previousCanAct then
		player.actFrame = emu.framecount()
		player.standAct = player.stand > 0
	end
end

function playerCanAct(player, attackType, act1, act2, frameAddress)
	if player.stand == 0 then
		if player.hitstun > 0 then return false end
	else
		if player.standHitstun > 0 then return false end
	end
	if flipFrames[frameAddress] then
		act1 = act1 == 0 and 1 or 0
	end
	if player.character == 1 or player.character == 18 then --kak/nkak
		if kakPoseFrames[frameAddress] then return true end
	end
	local frame = player.stand == 0 
	if act1 == 0 then
		if act2 == 0 and player.hitFreeze == 0 and player.previousHitFreeze == 0 then return true end
		local actSet = actType0[player.character + 1]
		if attackType == 0 and not (actSet[player.actionId] or actSet[player.standActionId]) then return true end
		if canActIds[player.character + 1][attackType] then return true end	
	end
	return false
end

function updatePlayerFrameAdvantage(player, other)
	if player.canAct then
		if not player.previousCanAct and other.canAct and system.frameAdvantage then
			-- Update frame advantage
			hud.frameAdvantage = p2.actFrame - p1.actFrame
			if p1.standAct then
				if p2.actType ~= 2 and not standPlusFrames[p1.character + 1][p1.standAttackType] then
					hud.frameAdvantage = hud.frameAdvantage + 1
				end
				p1.standAct = false
			end
			hud.reversalFrame = hud.frameAdvantage
			if p2.actType ~= 1 then
				hud.frameAdvantage = hud.frameAdvantage - 1
			end
			system.frameAdvantage = false
			p2.actType = 0
		end
	else
		if player.number == 2 then
			system.frameAdvantage = true
		end
	end
end

function updateIFrames()
	hud.invul = getPlayerInvul(p1.invul, p1.frameAddress)
	if p1.standActive > 0 then 
		hud.standInvul = getPlayerInvul(p1.standInvul, p1.standFrameAddress)
	else
		hud.standInvul = false
	end
end

function getPlayerInvul(invul, address)
	if invul > 0 then
		return true
	else
		local invulFrame = readByte(address + 0x1B)
		return invulFrame > 0
	end
end

function getActiveProjectile()
	for i = 32, 1, -1 do
		local projectile = projectiles[i]
		if projectile.state > 0 then
			return projectile
		end
	end
	return nil
end

function frameHitStop(frameAddress)
	--if frame + 0x12 == 1 then it's not affected by the hitstop counter
	return  p1.hitFreeze > 0 and readByte(p1.frameAddress + 0x12) == 0
end

function updateProjectileFrameInfo()
	system.previousProj1Address = system.proj1Address
	system.proj1Address = readDWord(0x02038518)
	system.previousProj2Address = system.proj2Address
	system.proj2Address = readDWord(0x02038938)
end

function updateCharacterSpecific()
	if p1.character == 16 or p1.character == 23 then --hol/hoingo s bullet hud
		local sBullet = getSBullet()
		if sBullet then system.sBullet = sBullet end
	end
end

function getSBullet()
	for i = 3, 1, -1 do
		local projectile = projectiles[i]
		if projectile.state > 0 and projectile.attackId == 31 then
			return 0x2038870 + (i - 1) * 0x420
		end
	end
end

function statusOptionUpdated()
	if options.status == 1 then
		p2.directionLock = band(p2.directionLock, 0xC)
	elseif options.status == 2 then
		p2.directionLock = band(p2.directionLock, 0xC) + 0x2
	elseif options.status == 3 then
		p2.directionLock = band(p2.directionLock, 0xC) + 0x1
	end
end

function blockOptionUpdated()
	if options.block == 1 then
		if band(p2.directionLock, 0x2) == 0x2 then --down
			p2.directionLock = 0x2
		elseif band(p2.directionLock, 0x1) == 0x1 then --up
			p2.directionLock = 0x1
		else
			p2.directionLock = 0x0
		end
	elseif options.block == 2 then
		if band(p2.directionLock, 0x2) == 0x2 then --down
			p2.directionLock = 0x6
		elseif band(p2.directionLock, 0x1) == 0x1 then --up
			p2.directionLock = 0x5
		else
			p2.directionLock = 0x4
		end
	end
end

function updateIPSPrediction()
	local rng = system.rng2
	local count = p1.ipsCount
	--Check if ips is on and not an ips trigger on next hit
	if p1.ips == 0 or getIPSTrigger(modifyRn2(rng), count) then 
		hud.ips = 0 
		return 
	end
	--Calculate the next ips trigger count
	while true do
		if count > 7 then
			rng = getNextRn2(rng)
			if getIPSTrigger(modifyRn2(rng), count) then
				hud.ips = count - p1.ipsCount
				return
			end
		end
		count = count + 1
	end
end

function getIPSTrigger(rng, count)
	if count > 16 then
		if band(rng, 0x3) == 0 then return true end
	elseif count > 7 then
		if band(rng, 0x7) == 0 then return true end
	end
	return false
end

-------------------------------------------------
-- Input Checker
-------------------------------------------------

function updateInputCheck()
	if fcReplay then return end
	checkPlayerInput(p1, p2)
	checkPlayerInput(p2, p1)
	updatePlayerRecording(p1)
	updatePlayerRecording(p2)
	if menu.state > 0 then
		updateMenu()
	end
end

local hotkeyFunctions = {
	record = function(player)
		record(player)
	end,
	recordP2 = function(player, other)
		record(other)
	end,
	recordAntiAir = function(player, other)
		recordAntiAir(player, other)
	end,
	recordParry = function(player, other)
		recordParry(player, other)
	end,
	replay = function(player)
		replaying(player)
	end,
	replayP2 = function(player, other)
		replaying(other)
	end,
	inputPlayback = function(player, other)
		inputPlayback(player)
		inputPlayback(other)
	end,
	disabled = function() end
}

function checkPlayerInput(player, other)
	other.previousControl = other.control

	if pressed(player.buttons.coin) then
		openMenu()
	end

	if menu.state > 0 then 
		if pressed(player.buttons.mk) then
			local max = options.standGaugeLimit and options.p2StandGauge or other.standGaugeMax
			writeWord(other.memory2.standGaugeRefill, max)
		end

		if pressed(player.buttons.sk) then
			local max = options.standGaugeLimit and options.p2StandGauge or player.standGaugeMax
			writeWord(player.memory2.standGaugeRefill, max)
		end
		return
	end

	-- trial mode disables other inputs
	if trial.enabled then
		--Scroll inputs
		if player.number ~= 1 then return end
		if trial.success then
			if pressed(player.buttons.start) or inputModule.start then
				trialNext()
			end
		else
			if inputModule.current[player.buttons.start] or inputModule.start then
				if repeating(player.buttons.up) then
					trial.min = (trial.min == 1 and 1 or trial.min - 1)
				elseif repeating(player.buttons.down) then
					trial.min = (#trial.combo - trial.min > 12) and trial.min + 1 or trial.min
				end
			end
		end
		--Reset 
		if pressed(player.buttons.mk) then
			trialReset()
		end
		--Replay
		if pressed(player.buttons.sk) then
			trialReplay()
		end
		return
	end

	if inputModule.current[player.buttons.start] or inputModule.start then --checks to see if P1 is holding start
		other.control = true

		if pressed(player.buttons.mk) then
			local max = options.standGaugeLimit and options.p2StandGauge or other.standGaugeMax
			writeWord(other.memory2.standGaugeRefill, max)
		end

		if pressed(player.buttons.sk) then
			local max = options.standGaugeLimit and options.p2StandGauge or player.standGaugeMax
			writeWord(player.memory2.standGaugeRefill, max)
		end
	else
		other.control = false
	end

	if pressed(player.buttons.mk) then
		hotkeyFunctions[options.mediumKickHotkey](player, other)
	elseif pressed(player.buttons.sk) then
		hotkeyFunctions[options.strongKickHotkey](player, other)
	end

	if held(player.buttons.sk, 15) then
		if options.strongKickHotkey == "replayP2" then
			other.loop = true
		else
			player.loop = true
		end
	end
end

function updatePlayerRecording(player)
	if player.recording then
		local recording = player.recorded[options.recordingSlot]
		recording[#recording + 1] = (player.recordedFacing == 1 and player.inputs or swapHexDirection(player.inputs))
		if player.number == 1 then
			updateTrialRecording()
		end
	end
end

function record(player)
	player.playbackCount = 0
	player.loop = false
	if player.recording then
		stopRecord(player)
	else
		player.recording = true
		player.recorded[options.recordingSlot] = {}
		player.recordedFacing = player.facing
		if player.number == 1 then
			trialStartRecording()
		end
	end
end

function recordAntiAir(player, other)
	if player.number == 2 then return end
	if player.recording then
		other.playbackCount = 0
		other.loop = false
		stopRecord(other)
		record(player)
	elseif system.antiAir > 0 then
		system.antiAir = 0
	else
		player.playbackCount = 0
		player.loop = false
		system.antiAir = 1
	end
end

function recordParry(player, other)
	if player.number == 2 then return end
	if player.recording then
		other.playbackCount = 0
		other.loop = false
		stopRecord(other)
		record(player)
	elseif system.parry > 0 then
		system.parry = 0
	else
		player.playbackCount = 0
		player.loop = false
		system.parry = 1
	end
end

function replaying(player)
	player.loop = false
	stopRecord(player)
	if player.playbackCount == 0 then
		player.playback = getPlaybackRecording(player)
		player.playbackCount = #player.playback
		player.playbackFlipped = player.facing ~= 1
	else
		player.playbackCount = 0
	end
end

function getPlaybackRecording(player)
	local recordings = {}
	for i = 1, 5, 1 do
		if options["slot"..i] then
			recordings[#recordings + 1] = player.recorded[i]
		end
	end
	if #recordings == 0 then return recordings end
	return recordings[math.random(#recordings)]
end

function inputPlayback(player)
	stopRecord(player)
	player.loop = false
	if player.playbackCount == 0 then
		readInputsFile()
		player.playback = player.inputPlayback
		player.playbackCount = #player.inputPlayback
		player.playbackFlipped = player.facing ~= 1
	else
		player.playbackCount = 0
	end
end

function stopRecord(player)
	if not player.recording then return end
	player.recording = false
	if player.number == 1 then
		trialFinaliseRecording()
		updateReversal()
	end
	writeSettings()
end

function resetReplayOptions()
	options.recordingSlot = 1
	options.slot1 = true
	options.slot2 = false
	options.slot3 = false
	options.slot4 = false
	options.slot5 = false
	options.replayInterval = 0
	options.mediumKickHotkey = "record"
	options.strongKickHotkey = "replay"
end

-------------------------------------------------
-- Character Control
-------------------------------------------------

function updateCharacterControl()
	if fcReplay then return end

	inputModule.overwrite = {}

	if menu.state > 0 then return end

	controlPlayers()
	controlPlayer(p2, p1)
end

function controlPlayers()
	if system.antiAir > 0 then
		if system.antiAir == 1 then
			p2.playback = { 0x01 }
			p2.playbackCount = 1
			if p2.y > 0 then
				if trial.enabled then
					if trial.antiAirReplay then
						system.antiAir = 0
						trial.antiAirReplay = false
						trialStartReplay()
					else
						system.antiAir = 2
					end
				else
					system.antiAir = 0
					record(p1)
				end
			end
		elseif system.antiAir == 2 then
			if p2.y == 0 then
				system.antiAir = 0
				trial.antiAirDelay = true
			end
		end
	elseif system.parry > 0 then
		if system.parry == 1 then
			p2.playback = { 0x01 }
			p2.playbackCount = 1
			if p2.y > 0 then
				system.parry = 2
			end
		elseif system.parry == 2 then
			if p2.y == 0 then
				p2.playback = { 0x40 }
				p2.playbackCount = 1
				system.parry = 0
				if trial.enabled then
					if trial.parryReplay then
						trialStartReplay()
						trial.parryReplay = false
					else
						trial.parryDelay = true
					end
				else
					record(p1)
				end
			end
		end
	end
end

function controlPlayer(player, other)
	-- Player 2 menu option controls
	if player.playbackCount > 0 then return end
	-- Guard Action
	if options.guardAction > 1 and canGuardAction(player) then
		--Push block
		if options.guardAction == 2 then
			pushBlock(player)
		-- Guard Cancel
		elseif options.guardAction == 3 then
			guardCancel(player)
		end
	-- Air Tech
	elseif options.airTech and player.airtech then
		airTech(player)
	--Perfect Air Tech 
	elseif options.perfectAirTech and canPerfectAirTech(player) then
		airTech(player, true)
	-- Throw tech
	elseif options.throwTech and player.throwTech > 0 then
		throwTech(player)
	end
	-- return if the player is now being controlled
	if player.playbackCount > 0 then return end
	-- Reversals
	if options.forceStand > 1 and canReversal(player) and canStand(player) then
		setPlayback(player, { 0x80 })
		local max = options.standGaugeLimit and options.p2StandGauge or player.standGaugeMax
		writeWord(player.memory2.standGaugeRefill, max)
	else
		if options.wakeupReversal and player.wakeupCount > 0 then
			doReversal(player, other, player.wakeupCount, player.previousWakeupCount)
		end
		if options.guardReversal then
			if player.guardCount > 0 then
				doReversal(player, other, player.guardCount, player.previousGuardCount)
			end
			if player.pushblockCount > 0 then
				doReversal(player, other, player.pushblockCount, player.previousPushblockCount)
			end
		end
		if options.hitReversal then
			if player.hitCount > 0 then
				doReversal(player, other, player.hitCount, player.previousHitCount)
			end
			if player.airtechCount > 0 then
				doReversal(player, other, player.airtechCount, player.previousAirtechCount)
			end
		end
	end
end

function setPlayback(player, table)
	player.playback = table
	player.playbackCount = #table
	player.playbackFacing = player.facing
	player.playbackFlipped = false
	player.loop = false
end

--Copies values from an indexed table to another and trims 0 values
function duplicateList(source, trimStart, trimEnd)
	local table = {}
	local start = 1
	local final = #source
	if trimStart then
		while start < #source do
			if source[start] == 0 then
				start = start + 1
			else
				break
			end
		end
	end
	if trimEnd then
		while final > 1 do
			if source[final] == 0 then
				final = final - 1
			else
				break
			end
		end
	end
	for i = start, final, 1 do
		table[#table + 1] = source[i]
	end
	return table
end

function insertDelay(inputs, number, hex)
	for _ = 1, number, 1 do
		table.insert(inputs, 1, hex)
	end
end

function airTech(player, perfect)
	local inputs
	local direction = options.airTechDirection == 5 and math.random(4) or options.airTechDirection
	if direction == 1 then
		inputs = { 0x70 }
	elseif direction == 2 then
		inputs = { 0x72}
	elseif direction == 3 then
		inputs = (player.facing == 1 and { 0x78 } or { 0x74 })
	elseif direction == 4 then
		inputs = (player.facing == 1 and { 0x74 } or { 0x78 })
	end
	local buffered = isReversalBuffered()
	if player.height > 32 or buffered then
		if buffered then
			if options.hitReversal then
				updateReversal()
			end
			player.airtechCount = #system.reversal + 1
		elseif direction == 1 and player.stand == 0 then
			player.airtechCount = 4
		else
			player.airtechCount = 11
		end
	end
	if not perfect then
		local delay = (system.slowDown == 1 and options.airTechDelay % 2 == 0) and options.airTechDelay + 1 or options.airTechDelay
		insertDelay(inputs, delay, 0)
		player.airtechCount = player.airtechCount + options.airTechDelay
	end
	setPlayback(player, inputs)
end

function pushBlock(player)
	local direction = band(0x0F, player.inputs)
	local inputs = { bor(0x70, direction) }
	insertDelay(inputs, options.guardActionDelay, direction)
	setPlayback(player, inputs)
	player.pushblockCount = 18 + options.guardActionDelay
	player.guardCount = 0
	if options.guardReversal then
		updateReversal()
	end
end

function guardCancel(player)
	local inputs = (player.side == 1 and { 0x08, 0x02, 0x1A } or { 0x04, 0x02, 0x16 })
	insertDelay(inputs, options.guardActionDelay, band(player.inputs, 0x0F))
	setPlayback(player, inputs)
	player.guardCount = 0
	--player.reversalCount = 15 Jotaro s.off
end

function throwTech(player)
	setPlayback(player, { 0x44 })
end

function updateReversal()
	system.reversal = getReversal(p2, p1)
end

function getReversal(player)
	local inputs
	local button = reversal.buttons[options.reversalButton]
	if options.reversalReplay ~= 1 then
		if options.reversalReplay == 2 or options.reversalReplay == 3 then --Replay
			inputs = duplicateList(getPlaybackRecording(player), true, true)
		elseif options.reversalReplay == 4 or options.reversalReplay == 5 then --Inputs.txt
			readInputsFile()
			inputs = duplicateList(player.inputPlayback, true, true)
			player.playbackFacing = player.inputPlaybackFacing
		end
	elseif options.reversalMotion ~= 1 then
		inputs = duplicateList(reversal.motions[options.reversalMotion], true, true);
		inputs[#inputs + 1] = bor(inputs[#inputs], button)
	else 
		inputs = { bor(reversal.directions[options.reversalDirection], button) }
	end
	return inputs
end

function doReversal(player, other, count, previousCount)
	-- If starting a new reversal and the reversal is a recording update to shuffle replay slots
	if previousCount == 0 and count ~= 0 and (options.reversalReplay == 2 or options.reversalReplay == 3) then
		updateReversal()
	end
	local inputs = system.reversal
	if options.reversalReplay == 2 or options.reversalReplay == 4 then
		if count == 1 then
			player.loop = false
			player.playback = inputs
			player.playbackCount = #inputs
		end
		return
	end
	local reversalIndex
	if options.reversalReplay ~= 1 then
		reversalIndex = getFinalButtonIndex(inputs) - count + 1
	else
		reversalIndex = #inputs - count + 1
		player.playbackFacing = 1
	end
	if reversalIndex < 1 or reversalIndex > #inputs then
		return
	end
	-- If on the ground use the other players facing because they might be flipped during the combo
	if player.y > 0 then
		player.playbackFlipped = player.facing ~= 1
	else
		player.playbackFlipped = other.facing == 1
	end
	player.loop = false
	player.playback = { inputs[reversalIndex] }
	player.playbackCount = 1
end

function getFinalButtonIndex(inputs)
	local index = #inputs
	local button = 0
	for i = #inputs, 1, -1 do
		if button > 0 then
			if band(button, inputs[i]) == button then
				index = i
			else
				return index
			end
		end
		if inputs[i] > 0x0F then
			button = band(inputs[i], 0xF0)
			index = i
		end
	end
	return 1
end

function isReversalBuffered()
	return options.reversalReplay == 3 or options.reversalReplay == 5 or (options.reversalReplay == 1 and options.reversalMotion ~= 1)
end

function canGuardAction(player)
	return player.previousGuarding == 0 and player.guarding > 0
end

function canPerfectAirTech(player)
	return player.previousHitstun == 0 and player.hitstun == 1 and player.height > 0
end

function canReversal(player)
	if player.wakeupCount == 1 or
	   player.guardCount == 1 or
	   player.hitCount == 1 or
	   player.airtechCount == 1 or
	   player.pushblockCount == 1 then
		return true
	end
	return false
end

function canStand(player) 
	return (options.forceStand == 2 and player.stand ~= 1) or
		(options.forceStand == 3 and player.stand == 1)
end

function resetReversalOptions()
	options.wakeupReversal = false
	options.guardReversal = false
	options.hitReversal = false
	options.reversalButton = 1
	options.reversalDirection = 1
	options.reversalMotion = 1
	options.reversalReplay = 1
end

-------------------------------------------------
-- Menu
-------------------------------------------------

function openMenu()
	if menu.state == 0 then
		writeByte(0x20713A3, 0x00); -- Bit mask that disables player input
		--stop record/replay
		stopRecord(p1)
		stopRecord(p2)
		p1.playbackCount = 0
		p2.playbackCount = 0
		system.parry = 0
		system.antiAir = 0
		playSound(sounds.open, 0x4040)
		--open menu
		if trial.enabled then
			menu.state = 6
		else
			menu.state = 1
			menu.title = "Training Menu"
			menu.index = 1
			menu.options = rootOptions
			updateMenuInfo()
			--update unmanaged options
			options.p1Child = p1.child == 0xFF
			options.p2Child = p2.child == 0xFF
			options.stageIndex = system.stageId
			options.p1Character = tableIndex(characters, idToName[p1.character])
			options.p2Character = tableIndex(characters, idToName[p2.character])
			--updateStandGaugeMax()
		end
	else
		menuClose()
	end
end

function updateMenu() 
	if pressedTable(selectInputs) then
		menuSelect()
	elseif pressedTable(cancelInputs) then
		menuCancel()
	elseif repeating(p1.buttons.up) or repeating(p2.buttons.up) then
		menuUp() 
	elseif repeating(p1.buttons.down) or repeating(p2.buttons.down) then
		menuDown()
	elseif repeating(p1.buttons.left) or repeating(p2.buttons.left) then
		menuLeft()
	elseif repeating(p1.buttons.right) or repeating(p2.buttons.right) then
		menuRight()
	end
	updateMenuFlash()
end

function menuSelect()
	local option = menu.options[menu.index]
	if option.type == optionType.subMenu then
		menu.state = 2
		menu.previousIndex = menu.index
		menu.index = 1
		menu.options = option.options
		menu.title = option.name
		updateMenuInfo()
		playSound(sounds.select, 0x4040)
	elseif option.type == optionType.bool then
		options[option.key] = not options[option.key]
		optionUpdated(option.key)
		playSound(sounds.select, 0x4040)
	elseif option.type == optionType.func then
		option.func()
	elseif option.type == optionType.back then
		menuCancel()
		playSound(sounds.cancel, 0x4040)
	elseif option.type == optionType.info then
		menu.state = 3
		menu.previousIndex = menu.index
		menu.index = 1
		menu.options = infoOptions
		menu.title = option.name
		menu.info = option.infos
		playSound(sounds.select, 0x4040)
	elseif option.type == optionType.color then
		menu.color = option.key
		menu.state = 4
		menu.previousSubIndex = menu.index
		menu.index = 1
		menu.options = colorSliderOptions
		menu.title = "Color Picker"
		menu.default = option.default
		playSound(sounds.select, 0x4040)
	elseif option.type == optionType.trialCharacters then
		if #trials == 0 then
			menu.info = "No trials jsons found"
			playSound(sounds.error, 0x4040)
		else
			menu.state = 5
			menu.options = getTrialCharacterOptions()
			menu.previousIndex = menu.index
			menu.index = charToIndex[p1.character] or 1
			menu.title = "Combo Trials"
			playSound(sounds.select, 0x4040)
		end
	elseif option.type == optionType.trialCharacter then
		menu.state = 6
		menu.options = getTrialOptions(menu.index)
		menu.previousSubIndex = menu.index
		menu.index = 1
		menu.title = option.name
		updateMenuTrial()
		playSound(sounds.select, 0x4040)
	elseif option.type == optionType.trial then
		menuClose()
	elseif option.type == optionType.files then
		local fileOptions = getFileOptions()
		if #fileOptions == 0 then
			menu.info = "No trials jsons found"
			playSound(sounds.error, 0x4040)
		else
			menu.options = fileOptions
			menu.state = 7
			menu.previousSubIndex = menu.index
			menu.index = 1
			menu.min = 1
			menu.title = "Trial Select"
			playSound(sounds.select, 0x4040)
		end
	elseif option.type == optionType.file then
		readTrial(option.name)
		writeSettings()
		playSound(sounds.select, 0x4040)
	elseif option.type == optionType.trialAbout then
		menu.state = 8
		menu.options = getTrialAboutOptions()
		menu.previousSubIndex = menu.index
		menu.index = 1
		menu.title = option.name
		playSound(sounds.select, 0x4040)
	end
end

function menuCancel()
	if menu.state == 1 then -- menu
		menuClose()
	elseif menu.state == 4 then -- color picker
		menu.state = 2
		menu.index = menu.previousSubIndex
		menu.options = colorOptions
		menu.title = "Color Settings"
		updateMenuInfo()
		playSound(sounds.cancel, 0x4040)
	elseif menu.state == 6 or menu.state == 8 then -- trials / trials about
		menu.state = 5
		menu.index = menu.previousSubIndex
		menu.options = getTrialCharacterOptions()
		menu.title = "Combo Trials"
		trialModeStop()
		playSound(sounds.cancel, 0x4040)
	elseif menu.state == 7 then -- files
		menu.state = 2
		menu.index = menu.previousSubIndex
		menu.options = trialOptions
		menu.title = "Trial Options"
		updateMenuInfo()
		playSound(sounds.cancel, 0x4040)
	elseif menu.state > 1 then -- sub menu
		menu.state = 1
		menu.index = menu.previousIndex
		menu.options = rootOptions
		menu.title = "Training Menu"
		updateMenuInfo()
		playSound(sounds.cancel, 0x4040)
	end
end

function menuClose()
	menu.state = 0
	gui.clearuncommitted()
	writeByte(0x20713A3, 0xFF) -- Bit mask that enables player input
	--update unamanaged options
	updateChild(p1, options.p1Child, 0x020348D5)
	updateChild(p2, options.p2Child, 0x02034CF5)
	updateReversal()
	playSound(sounds.close, 0x4040)
	if trial.enabled then
		trialMenuClose()
	else
		writeSettings()
	end
end

function menuLeft()
	local option = menu.options[menu.index]
	local value = options[option.key]
	if option.type == optionType.bool then
		options[option.key] = not value
		optionUpdated(option.key)
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.int then
		local inc = (option.inc and heldTable(selectInputs, 1)) and option.inc or 1
		if (value - inc < option.min) then inc = value - option.min end
		options[option.key] = (value == option.min and option.max or value - inc)
		optionUpdated(option.key)
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.managedInt then
		local inc = (option.inc and heldTable(selectInputs, 1)) and option.inc or 1
		local min = options[option.min]
		if (value - inc < min) then inc = value - min end
		options[option.key] = (value == min and options[option.max] or value - inc)
		optionUpdated(option.key)
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.list then
		options[option.key] = (value == 1 and #option.list or value - 1)
		optionUpdated(option.key)
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.slider then
		local inc = (heldTable(selectInputs, 1) and 10 or 1)
		local value = getMenuColor(option.mask, option.shift)
		if (value - inc < 0) then inc = value end
		options[menu.color] = options[menu.color] - lShift(inc, option.shift)
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.key then
		local index = tableIndex(option.list, value)
		options[option.key] = option.list[index == 1 and #option.list or index - 1]
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.trialCharacter or option.type == optionType.trialAbout then
		menu.index = math.floor(menu.index % 2) == 0 and menu.index - 1 or menu.index + 1
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.trial then
		if menu.index == 1 then
			menu.index = math.min(12, #menu.options - 1)
		elseif menu.index == 13 then
			menu.index = math.min(24, #menu.options - 1)
		elseif menu.index == 25 then
			menu.index = #menu.options
		else
			menu.index = menu.index - 1
		end
		updateMenuTrial()
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.back then --trials
		if menu.state == 5 then --trial characters
			menu.index = math.floor(menu.index % 2) == 0 and menu.index - 1 or menu.index + 1
			playSound(sounds.move, 0x4040)
		elseif menu.state == 6 then
			if #menu.options > 25 then
				menu.index = #menu.options - 1
			end
			playSound(sounds.move, 0x4040)
		end
	end
end

function menuRight()
	local option = menu.options[menu.index]
	local value = options[option.key]
	if option.type == optionType.bool then
		options[option.key] = not value
		optionUpdated(option.key)
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.int then
		local inc = (option.inc and heldTable(selectInputs, 1)) and option.inc or 1
		if (value + inc > option.max) then inc = option.max - value end
		options[option.key] = (value >= option.max and option.min or value + inc)
		optionUpdated(option.key)
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.managedInt then
		local inc = (option.inc and heldTable(selectInputs, 1)) and option.inc or 1
		local max = options[option.max]
		if (value + inc > max) then inc = max - value end
		options[option.key] = (value >= max and options[option.min] or value + inc)
		optionUpdated(option.key)
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.list then
		options[option.key] = (value >= #option.list and 1 or value + 1)
		optionUpdated(option.key)
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.slider then
		local inc = (heldTable(selectInputs, 1) and 10 or 1)
		local value = getMenuColor(option.mask, option.shift)
		if (value + inc > 255) then inc = 255 - value end
		options[menu.color] = options[menu.color] + lShift(inc, option.shift)
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.key then
		local index = tableIndex(option.list, value)
		options[option.key] = option.list[index >= #option.list and 1 or index + 1]
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.trialCharacter or option.type == optionType.trialAbout then
		menu.index = math.floor(menu.index % 2) == 0 and menu.index - 1 or menu.index + 1
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.trial then
		if menu.index == #menu.options - 1 then
			if #menu.options > 25 then
				menu.index = #menu.options
			else
				menu.index = menu.index > 12 and 13 or 1
			end
		elseif menu.index % 12 == 0 then
			menu.index = menu.index - 11
		else
			menu.index = menu.index + 1
		end
		updateMenuTrial()
		playSound(sounds.move, 0x4040)
	elseif option.type == optionType.back then
		if menu.state == 5 then --trial characters
			menu.index = math.floor(menu.index % 2) == 0 and menu.index - 1 or menu.index + 1
			playSound(sounds.move, 0x4040)
		elseif menu.state == 6 then --trials
			if #menu.options > 25 then
				menu.index = 25
			end
			playSound(sounds.move, 0x4040)
		end
	end
end

function menuUp()
	if menu.state == 3 then --about
		return
	elseif menu.state == 5 then --trials characters
		if menu.index < 3 then
			menu.index = menu.index + #menu.options - 2
		else
			menu.index = menu.index - 2
		end
		playSound(sounds.move, 0x4040)
	elseif menu.state == 6 then --trials
		if menu.index == #menu.options then
			if #menu.options > 25 then
				menu.index = 24
			else
				menu.index = #menu.options > 1 and #menu.options - 1 or 1
			end
		elseif menu.index < 13 then
			if menu.index + 24 < #menu.options then
				menu.index = menu.index + 24
			else
				menu.index = #menu.options
			end
		else
			menu.index = menu.index - 12
		end
		updateMenuTrial()
		playSound(sounds.move, 0x4040)
	elseif menu.state == 7 then --files
		menu.index = (menu.index == 1 and #menu.options or menu.index - 1)
		if #menu.options > 15 then
			menu.min = math.min(math.max(menu.index - 8, 1), #menu.options - 14)
		end
		playSound(sounds.move, 0x4040)
	else
		menu.index = (menu.index == 1 and #menu.options or menu.index - 1)
		updateMenuInfo()
		playSound(sounds.move, 0x4040)
	end
end

function menuDown()
	if menu.state == 3 then --about
		return
	elseif menu.state == 5 then --trials characters
		if menu.index > #menu.options - 2 then
			menu.index = menu.index - #menu.options + 2
		else
			menu.index = menu.index + 2
		end
		playSound(sounds.move, 0x4040)
	elseif menu.state == 6 then --trials
		if menu.index == #menu.options then
			menu.index = math.min(#menu.options - 1, 12)
		elseif menu.index + 12 < #menu.options then
			menu.index = menu.index + 12
		elseif menu.index > 24 then
			menu.index = menu.index - 24
		else
			menu.index = #menu.options
		end
		updateMenuTrial()
		playSound(sounds.move, 0x4040)
	elseif menu.state == 7 then --files
		menu.index = (menu.index >= #menu.options and 1 or menu.index + 1)
		if #menu.options > 15 then
			menu.min = math.min(math.max(menu.index - 8, 1), #menu.options - 14)
		end
		playSound(sounds.move, 0x4040)
	else
		menu.index = (menu.index >= #menu.options and 1 or menu.index + 1)
		updateMenuInfo()
		playSound(sounds.move, 0x4040)
	end
end

function updateMenuInfo() 
	if menu.options[menu.index].info then
		menu.info = menu.options[menu.index].info
	else
		menu.info = ""
	end
end

function getMenuColor(mask, shift)
	return rShift(band(mask, options[menu.color]), shift)
end

function resetColor()
	options[menu.color] = menu.default
	playSound(sounds.select, 0x4040)
end

function getTrialCharacterOptions()
	local optionsTable = {}
	for i = 1, 24, 1 do
		optionsTable[i] = {
			name = trials[i].name or indexToName[i],
			type = optionType.trialCharacter,
			completed = trialCompletedCount(i)
		}
	end
	optionsTable[25] = {
		name = trials[25].name,
		type = optionType.trialAbout
	}
	optionsTable[26] = {
		name = "Return",
		type = optionType.back
	}
	return optionsTable
end

function trialCompletedCount(index)
	local success = options.trialSuccess[options.trialsFilename][index] or 0
	local count = 0
	while success > 0 do
		if band(success, 1) == 1 then
			count = count + 1
		end
		success = rShift(success, 1)
	end
	return count
end

function getTrialOptions(index)
	local optionsTable = {}
	local success = options.trialSuccess[options.trialsFilename][index] or 0
	local characterTrials = trials[index].trials
	for i = 1, #characterTrials, 1 do
		optionsTable[i] = {
			type = optionType.trial,
			id = i,
			success = band(rShift(success, i - 1), 1) == 1,
			trial = characterTrials[i]
		}
	end
	optionsTable[#optionsTable + 1] = {
		name = "Return",
		type = optionType.back
	}
	return optionsTable
end

function updateMenuTrial()
	if menu.index ~= #menu.options then
		trialModeStart()
	else
		trialModeStop()
	end
end

function updateChild(player, option, address)
	writeByte(player.memory.child, option and 0xFF or 0x00)
	if option and childColorCode[player.character] then
		writeByte(address, childColorCode[player.character])
	end
end

function getFileOptions()
	local jsons = getTrialsJsons()
	if #jsons == 0 then return {} end
	local optionsTable = {}
	for i = 1, #jsons, 1 do
		optionsTable[i] = {
			name = jsons[i],
			type = optionType.file
		}
	end
	optionsTable[#optionsTable + 1] = {
		name = "Return",
		type = optionType.back
	}
	return optionsTable
end

function getTrialAboutOptions()
	local optionsTable = {}
	local max = math.max(#trials[25].info - 12, 0) + 1
	for i = 1, max, 1 do
		optionsTable[i] = {
			name = "Return",
			type = optionType.back
		}
	end
	return optionsTable
end

function boxTransparencyUpdated()
	local alpha = options.boxTransparency
	options.hitboxColor = band(options.hitboxColor, 0xFFFFFF00) + alpha
	options.hurtboxColor = band(options.hurtboxColor, 0xFFFFFF00) + alpha
	options.collisionboxColor = band(options.collisionboxColor, 0xFFFFFF00) + alpha
	colors.orangebox = band(colors.orangebox, 0xFFFFFF00) + alpha
end

local optionUpdateFunctions = {
	inputStyle = function()
		clearInputHistory(p1)
		clearInputHistory(p2)
	end,
	killDenial = updateHacks,
	stageIndex = function()
		updateStage(options.stageIndex)
	end,
	p1Character = function()
		updateCharacter(p1, nameToId[characters[options.p1Character]])
	end,
	p2Character = function()
		updateCharacter(p2, nameToId[characters[options.p2Character]])
	end,
	disableHud = updateHacks,
	music = updateHacks,
	status = statusOptionUpdated,
	block = blockOptionUpdated,
	kakyoinPose = updateKakyoinPose,
	p1Hp = function() writeWord(p1.memory2.healthRefill, options.p1Hp) end,
	p2Hp = function() writeWord(p2.memory2.healthRefill, options.p2Hp) end,
	standGaugeLimit = updateStandGaugeLimit,
	p2StandGauge = updateStandGaugeLimit,
	romHack = updateHacks,
	boxTransparency = boxTransparencyUpdated,
	boingo = updateHacks,
}

function optionUpdated(key)
	local func = optionUpdateFunctions[key]
	if func then func() end
end

function updateMenuFlash()
	menu.flash = (menu.flash + 1) % 120
	local inc = menu.flash < 60 and menu.flash or 120 - menu.flash
	local min = colors.menuSelectedMin
	local max = colors.menuSelectedMax
	for i = 1, 3, 1 do
		menu.flashColor[i] = min[i] + (max[i] - min[i]) / 60 * inc
	end
end

-- function updateStandGaugeMax()
-- 	options.p1StandMax = p1.standGaugeMax
-- 	options.p2StandMax = p2.standGaugeMax
-- 	if options.p1StandGauge == 72 or options.p1StandGauge == 80 or options.p1StandGauge == 88 then
-- 		options.p1StandGauge = options.p1StandMax
-- 	end
-- 	if options.p2StandGauge == 72 or options.p2StandGauge == 80 or options.p2StandGauge == 88 then
-- 		options.p2StandGauge = options.p2StandMax
-- 	end
-- end

function playSound(id, pan)
	if not options.menuSound then return end
	local addr = readDWord(0x203120C)
	writeWord(addr, 0x0007)
	writeWord(addr + 2, id)
	writeWord(addr + 4, pan)
	writeWord(addr + 6, 0x0002)
	addr = addr == 0x20330FC and 0x2032F04 or addr + 8
	writeDWord(0x203120C, addr)
end

-------------------------------------------------
-- Trials
-------------------------------------------------

function updateTrial()
	if not trial.enabled or trial.success then return end
	if trial.replay then
		updateTrialReplay()
	elseif trial.reset then
		updateTrialReset()
	elseif trial.trial.parry and not trialStarted() and system.parry == 0 then
		updateTrialParry()
	elseif trial.trial.antiair and not trialStarted() and system.antiAir == 0 then
		updateTrialAntiAir()
	end
	updateTrialCheck(false)
end

function updateTrialCheck(tailCall)
	local input = trial.combo[trial.index]
	if input.type == comboType.meatyCmd then
		local cmdLeniency = getCmdLeniency(input.id, p1.character)
		if checkAttackId(input.id) then
			return advanceTrialIndex()
		elseif p2.afterHitstun > 3 then
			return trialFail()
		end
	elseif p2.wakeupFrame and (p2.previousDefenseAction == 28 or p2.previousDefenseAction == 30) then
		local cmdLeniency = getCmdLeniency(input.id, p1.character)
		if input.type == comboType.meaty and checkAttackId(input.id) then
			return advanceTrialIndex()
		elseif input.type == comboType.doubleMeaty and 
				checkAttackId(input.id[1]) and checkAttackId(input.id[2]) then
			return advanceTrialIndex()
		elseif input.type == comboType.timeStop and 
				system.previousTimeStop == 0 and system.timeStop > 0 then 
			return advanceTrialIndex()
		elseif trialStarted() then
			return trialFail()
		end
	elseif input.type == comboType.meatyReset then
		if p2.previousHitCount == 3 or p2.previousHitCount == 2 then
			if checkAttackId(input.id) then
				return advanceTrialIndex()
			end
		elseif trialStarted() and not trialStun(input) then
			return trialFail()
		end		
	elseif p2.previousY > 0 and p2.y == 0 and p2.previousTechable == 1 and p2.stand > 0 then
		if input.type == comboType.reset and checkAttackId(input.id) then
			return advanceTrialIndex()
		else
			return trialFail()
		end
	elseif trialStarted() and not trialStun(input) then
		return trialFail()
	elseif input.type == comboType.id then
		if checkAttackId(input.id) then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.multi then
		if checkAttackId(input.id[trial.subIndex]) then
			return advanceTrialSubIndex(input)
		end
	elseif input.type == comboType.alt then
		for i = 1, #input.id, 1 do
			if checkAttackId(input.id[i]) then
				return advanceTrialIndex()
			end
		end
	elseif input.type == comboType.tandem then
		if p1.previousTandem == 0 and p1.tandem == 1 then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.inputs then
		if p1.previousTandemCount ~= p1.tandemCount and not tailCall then
			if checkTandemInput(input.id[trial.subIndex]) then
				return advanceTrialSubIndex(input)
			else 
				return trialFail()
			end
		end
	elseif input.type == comboType.pCharge then
		if p1.previousActionId ~= input.id and p1.actionId == input.id then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.sCharge then
		if p1.previousStandActionId ~= input.id and p1.standActionId == input.id then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.bCharge then
		for i = 1, 32, 1 do
			local projectile = projectiles[i]
			if projectile.previousState == 0 and projectile.state == 1 and input.id == projectile.attackId then
				return advanceTrialIndex()
			end
		end
	elseif input.type == comboType.whiff then
		if checkWhiffId(input.id) then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.projectiles then
		if checkAttackId(input.id) then
			for i = 1, 32, 1 do
				if projectiles[i].attackId == input.id then
					projectiles[i].consumed = true
				end
			end
			return advanceTrialIndex()
		end
	elseif input.type == comboType.remote then
		if p1.previousStand == 1 and p1.stand == 2 then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.recall then
		if p1.previousStand == 2 and p1.stand == 0 then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.timeStop then
		if system.previousTimeStop == 0 and system.timeStop > 0 then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.timeStopEnd then
		if system.previousTimeStop > 0 and system.timeStop == 0 then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.double then
		if checkAttackId(input.id[1]) and checkAttackId(input.id[2]) then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.action then
		if p1.attackHit > 0 and p1.attackId == input.id[1] and 
				p1.previousActionId ~= input.id[2] and p1.actionId == input.id[2] then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.standAction then
		if p1.standAttackHit > 0 and p1.standAttackId == input.id[1] and 
				p1.previousStandActionId ~= input.id[2] and p1.standActionId == input.id[2] then
			return advanceTrialIndex()
		end
	elseif input.type == comboType.projectileAction then
		for i = 1, 32, 1 do
			local projectile = projectiles[i]
			if projectile.state > 0 then
				if projectile.attackHit > 0 and projectile.attackId == input.id[1] and 
						projectile.previousActionId ~= input.id[2] and projectile.actionId == input.id[2] then
					return advanceTrialIndex()
				end
			end
		end
	elseif input.type == comboType.sBullet then
		if (p1.character == 16 and p1.previousActionId == 43 and p1.actionId == 44) or -- hol horse s bullet
				(p1.character == 23 and p1.previousActionId == 90 and p1.actionId == 91) then --hoingo s bullet
			local bytes = readDWord(getSBullet())
			local dir = 0
			for i = 1, #input.directions, 1 do
				local hex = input.directions[i]
				hex = p1.facing == 1 and hex or swapHexDirection(hex)
				dir = lShift(dir, 4) + hex
			end
			if dir == bytes then
				return advanceTrialIndex()
			else
				return trialFail()
			end
		end
	elseif input.type == comboType.grab then
		if p2.throwTech > 0 then
			return advanceTrialIndex()
		end
	end
end

function trialStarted()
	return (trial.drill and trial.drillSuccess > 0) or not (trial.index == 1 and trial.subIndex == 1)
end

function checkTandemInput(id)
	local address = 0x02032174 + (p1.tandemCount - 1) * 6
	local ids = readByteRange(address, 3)
	if ids[1] == 0x1A then -- if super just test second byte
		return id:sub(3, 4) == string.format("%02X", ids[2])
	elseif #id == 10 then -- if old 10 length format shorten first
		id = id:sub(1, 6)
	end
	return id == string.format("%02X%02X%02X", ids[1], ids[2], ids[3])
end

function checkAttackId(id)
	if p1.attackHit > 0 and p1.attackId == id and 
		(p1.previousAttackHit == 0 or p1.attackId ~= p1.previousAttackId) then
		return true
	end
	if p1.standAttackHit > 0 and p1.standAttackId == id and 
		(p1.previousStandAttackHit == 0 or p1.previousStandAttackId ~= p1.standAttackId) then
		return true
	end
	for i = 1, 32, 1 do
		local projectile = projectiles[i]
		if projectile.state > 0 and not projectile.consumed then
			if projectile.attackHit > 0 and projectile.attackId == id and 
				(projectile.previousAttackHit == 0 or projectile.previousAttackId ~= projectile.attackId) then
				return true
			end
		end
	end
	return false
end

function checkWhiffId(id)
	if p1.attackId == id and hasHitbox(p1.hitbox)  then
		return true
	end
	if  p1.standAttackId == id and hasHitbox(p1.standHitbox) then
		return true
	end
	-- for i = 0, 31, 1 do
	-- 	local address = 0x0203848C + i * 0x420
	-- 	if readByte(address + 0xDC) == id and hasHitbox(readWordSigned(address + 0xAC)) then
	-- 		return true
	-- 	end
	-- end
	return false
end

function hasHitbox(id)
	return readWordSigned(hitboxOffsets[p1.character + 1] + id * 0x10) ~= 0
end

function getAttackId()
	if p1.attackHit > 0 and (p1.previousAttackHit == 0 or p1.attackId ~= p1.previousAttackId) then 
		return p1.attackId
	end
	if p1.standAttackHit > 0 and (p1.previousStandAttackHit == 0 or p1.previousStandAttackId ~= p1.standAttackId) then
		return p1.standAttackId
	end
	for i = 1, 32, 1 do
		local projectile = projectiles[i]
		if projectile.state > 0 then
			if projectile.attackHit > 0 and (projectile.previousAttackHit == 0 or projectile.previousAttackId ~= projectile.attackId) then
				return projectile.attackId
			end
		end
	end
	return -1
end

function trialStun(input)
	if p2.guarding > 0 and p2.previousGuarding == 0 then --blocking
		return false
	end
	if p2.hitstun == 3 or p2.hitstun == 4 then --grab
		return true 
	end
	if p2.wakeupFrame and (p2.previousDefenseAction == 28 or p2.previousDefenseAction == 30) then --wakeup frame
		return false
	end
	if p2.y > 0 or (p2.y == 0 and p2.previousY > 0) then --in air or tech roll
		if p2.previousHitstun > 0 and p2.hitstun == 0 then
			return false 
		end
	else
		local cmdLeniency = getCmdLeniency(input.id, p1.character)
		if p2.defenseAction > 26 then 
			return true
		elseif cmdLeniency > 0 then
			if p2.afterHitstun >= cmdLeniency then
				return false
			end
		elseif p2.hitCount == 2 then
			return false
		end
	end
	return true
end

function getCmdLeniency(id, char)
	if type(id) ~= "number" then return 0 end
	return commandGrabLeniency[char * 0x100 + id] or 0
end

function trialModeStart()
	trial.trial = menu.options[menu.index].trial
	trial.id = menu.index
	trial.combo = trial.trial.combo
	trial.recorded = parseTrialRecording()
	trial.index = 1
	trial.min = 1
	trial.success = false
	trial.failIndex = 0
	trial.subIndex = 1
	trial.wait = 0
	trial.replay = false
	trial.reset = false

	trial.parryDelay = false
	trial.parryReplay = false
	system.parry = 0

	trial.antiAirDelay = false
	trial.antiAirReplay = false
	system.antiAir = 0

	if trial.trial.drill then 
		trial.drill = trial.trial.drill
		trial.drillSuccess = 0
	else
		trial.drill = false
	end

	writeWord(p1.memory2.standGaugeRefill, p1.standGaugeMax)

	--remove scaling retention
	--writeByte(0x2034E89, 0)

	if not trial.enabled then
		storeOptions()
	end
	trial.enabled = true
	updateOptions()
end

function trialModeStop()
	if not trial.enabled then return end
	retrieveOptions()
	updateHacks()
	system.parry = 0
	system.antiAir = 0
	trial.enabled = false
end

function storeOptions() 
	menu.previousOptions = {}
	tableCopy(options, menu.previousOptions)
end

function updateOptions()
	local t = trial.trial
	if t.ips ~= nil then
		options.ips = trial.ips
	end
	if t.tandemCooldown ~= nil then
		options.tandemCooldown = t.tandemCooldown
	end
	options.block = t.block or 1
	if t.direction ~= nil then
		p2.directionLock = t.direction
		updateBlockStatus(p2)
	end
	if t.rng ~= nil then
		writeDWord(0x20162E4, t.rng)
	end
	if t.rng2 ~= nil then
		writeDWord(0x205C1B8, t.rng2)
	end
	if t.health ~= nil then
		options.healthRefill = t.health and 2 or 1
	else
		options.healthRefill = 2
	end
	if t.meter ~= nil then
		local meterType = type(t.meter)
		if meterType == "number" then
			options.meterRefill = 1
			writeByte(p1.memory.meterNumber, t.meter)
		elseif meterType == "boolean" then
			options.meterRefill = (t.meter and 2 or 1)
		end
	else
		options.meterRefill = 2
	end
	if t.standGauge ~= nil then
		options.standGaugeRefill = t.standGauge
	else
		options.standGaugeRefill = true
	end
	if t.p1 then
		if t.p1.hp then
			options.p1Hp = t.p1.hp
			writeWord(p1.memory2.healthRefill, t.p1.hp)
		else
			options.p1Hp = 144
			writeWord(p1.memory2.healthRefill, 144)
		end
		if t.p1.child ~= nil then
			options.p1Child = t.p1.child
		else
			options.p1Child = false
		end
		updateChild(p1, options.p1Child, 0x020348D5)
		if p1.character == 0x16 then -- mariah
			writeByte(0x02033210, t.p1.level or 0)
		end
	end
	if t.p2 then
		if t.p2.hp then
			options.p2Hp = t.p2.hp
			writeWord(p2.memory2.healthRefill, t.p2.hp)
		else
			options.p2Hp = 144
			writeWord(p2.memory2.healthRefill, 144)
		end
		if t.p2.child ~= nil then
			options.p2Child = t.p2.child
		else
			options.p2Child = false
		end
		if t.p2.standGauge ~= nil then
			options.standGaugeLimit = true
			options.p2StandGauge = t.p2.standGauge
		else
			options.standGaugeLimit = false
			writeWord(p2.memory2.standGaugeRefill, p2.standGaugeMax)
		end
		updateStandGaugeLimit()
		updateChild(p2, t.p2.child, 0x02034CF5)
	end
	if t.tandemChain then
		local tandemChain = t.tandemChain
		for i = 0, 31, 1 do
			writeByte(0x02032178 + i * 6, band(tandemChain, 1))
			tandemChain = rShift(tandemChain, 1)
		end
	end
	if t.pose then
		options.kayoinPose = t.pose + 1
	else
		options.kakyoinPose = 1
	end
	options.guiStyle = 2
	options.p1Gui = false
	options.p2Gui = false
	options.hitboxes = false
	options.ips = false
	options.tandemCooldown = false
	options.guardAction = 1
	options.perfectAirTech = false
	options.forceStand = 1
	options.throwTech = false
	options.airTechDelay = 0
	options.airTech = true
	options.airTechDirection = 2
	options.boingo = false
	options.level = 1
	options.inputStyle = 1
	options.infiniteRounds = true
	options.infiniteTimestop = false
	options.killDenial = t.drill or false
	options.romHack = false
	updateHacks()
	resetReversalOptions()
end

function retrieveOptions()
	tableCopy(menu.previousOptions, options)
end

function trialSave()
	retrieveOptions()
	writeSettings()
	storeOptions()
	updateOptions()
end

function advanceTrialIndex()
	trial.failIndex = 0
	trial.subIndex = 1
	trial.index = trial.index + 1
	if #trial.combo > 13 then
		trial.min = math.min(math.max(trial.index - 6, 1), #trial.combo - 12)
	end
	if trial.index > #trial.combo then
		system.parry = 0
		system.antiAir = 0
		if trial.drill then
			trial.drillSuccess = trial.drillSuccess + 1
			trial.index = 1
			trial.subIndex = 1
			trial.min = 1
		else
			trialSuccess()
		end
	elseif trialTailCall() then
		return updateTrialCheck(true) --make a tail call to check for multiple hits on the same frame if the id's are different
	end
end

function advanceTrialSubIndex(input)
	trial.subIndex = trial.subIndex + 1
	if trial.subIndex > #input.id then
		return advanceTrialIndex()
	elseif trialTailCall() then
		return updateTrialCheck(true)
	end
end

function trialSuccess()
	trial.success = true
	if p1.playbackCount ~= 0 then return end
	menu.options[menu.index].success = true
	local trialSuccess = options.trialSuccess[options.trialsFilename]
	local value = bor(trialSuccess[menu.previousSubIndex] or 0, lShift(1, trial.id - 1))
	trialSuccess[menu.previousSubIndex] = value
	trialSave()
end

function trialFail()
	if trial.success then return end
	if trial.drill and trial.drillSuccess >= trial.drill then
		trialSuccess()
	else
		trial.drillSuccess = 0
		trial.failIndex = trial.index
		trial.index = 1
		trial.min = 1
		trial.subIndex = 1
		trial.drillSuccess = 0
	end
end

function trialTailCall() -- determines whether the previous id is the same as the current id 
	local input = trial.combo[trial.index]
	local inputId
	local inputTable = false
	if input.type == comboType.multi then 
		if trial.subIndex > 1 then
			return input.id[trial.subIndex] ~= input.id[trial.subIndex - 1]
		end
		inputId = input.id[1]
	elseif input.type == comboType.id or input.type == comboType.meaty then
		inputId = input.id
	elseif input.type == comboType.alt then
		inputId = input.id
		inputTable = true
	else
		return false
	end
	local previousInput = trial.combo[trial.index - 1]
	local previousInputId
	local previousInputTable = false
	if previousInput.type == comboType.multi then
		previousInputId = previousInput.id[#previousInput.id]
	elseif previousInput.type == comboType.id then
		previousInputId = previousInput.id
	elseif previousInput.type == comboType.alt then
		previousInputId = previousInput.id
		previousInputTable = true
	elseif previousInput.type == comboType.meaty then
		return false
	else
		return false
	end
	if inputTable then
		if previousInputTable then
			for i = 1, #inputId, 1 do
				for j = 1, #previousInputId, 1 do
					if inputId[i] == previousInputId[j] then return false end
				end
			end
		else
			for i = 1, #inputId, 1 do
				if inputId[i] == previousInputId then return false end 
			end
		end
	else
		if previousInputTable then
			for i = 1, #previousInputId, 1 do
				if inputId == previousInputId[i] then return false end 
			end
		else
			if inputId == previousInputId then return false end
		end
	end
	return true
end

function trialNext()
	if menu.index == #menu.options - 1 then
		openMenu()
	else
		menu.index = menu.index + 1
		trialModeStart()
		trialMenuClose()
	end
end

function trialStartRecording()
	local recording = {
		name = "",
		difficulty = 1,
		author = "",
		info = {
			""
		},
		ips = options.ips,
		tandemCooldown = options.tandemCooldown,
		p1 = {
			character = p1.character,
			x = p1.x,
			y = p1.y,
			stand = p1.stand,
			standX = p1.standX,
			standY = p1.standY,
			facing = p1.facing,
			standFacing = readByte(0x2035239),
			child = p1.child == 0xFF,
			hp = p1.healthRefill
		},
		p2 = {
			character = p2.character,
			x = p2.x,
			y = p2.y,
			stand = p2.stand,
			standX = p2.standX,
			standY = p2.standY,
			facing = p2.facing,
			standFacing = readByte(0x2035659),
			child = p2.child == 0xFF,
			hp = p2.healthRefill
		},
		stage = {
			id = system.stageId,
			x = system.screenX,
			y = system.screenY
		},
		combo = {},
		direction = p2.directionLock,
		rng = system.rng,
		rng2 = system.rng2,
		position = false,
		tandemChain = getTandemChain()
	}
	if options.healthRefill == 1 then
		recording.health = false
	end
	if options.meterRefill == 1 then
		recording.meter = readByte(p1.memory.meterNumber)
	end
	if not options.standGaugeRefill then
		recording.standGauge = false
	end
	if p1.character == 0x16 then -- mariah
		recording.p1.level = readByte(0x02033210)
	end
	if options.mediumKickHotkey == "recordParry" then
		recording.parry = true
	elseif options.mediumKickHotkey == "recordAntiAir" then
		recording.antiair = true
	end
	if options.standGaugeLimit then
		recording.p2.standGauge = options.p2StandGauge
	end
	if options.kakyoinPose > 1 then
		recording.pose = options.kakyoinPose
	end
	if options.block > 1 then
		recording.block = options.block
	end
	trial.recording = recording
	trial.recordingSubIndex = 1
	trial.recordingFacing = p1.facing
end

--Read every 5th byte of tandem for tandem chain state prior to recording and restore it on replay to fix issues with characters like devo
function getTandemChain()
	local tandemChain = 0
	for i = 0, 31, 1 do
		tandemChain = tandemChain + lShift(readByte(0x02032178 + i * 6), i)
	end
	return tandemChain
end

function updateTrialRecording()
	local combo = trial.recording.combo
	local attackId = getAttackId()
	if attackId ~= -1 then
		local char = charToIndex[p1.character]
		local move = char and moveDefinitions[char][attackId] or nil
		if move ~= false then
			combo[#combo + 1] = {
				type = p2.wakeupFrame and comboType.meaty or comboType.id,
				name = move or tostring(#combo + 1),
				id = attackId
			}
		end
	elseif p1.previousTandem == 0 and p1.tandem == 1 then 
		combo[#combo + 1] = {
			type = comboType.tandem,
			name = "214S"
		}
		trial.recordingSubIndex = 1
	elseif p1.tandem == 1 and p1.previousTandemCount ~= p1.tandemCount then
		local address = 0x02032174 + (p1.tandemCount - 1) * 6
		local ids = readByteRange(address, 3)
		local id = string.format("%02X%02X%02X", ids[1], ids[2], ids[3])
		if trial.recordingSubIndex == 1 then
			combo[#combo + 1] = {
				name = tostring(#combo + 1),
				type = comboType.inputs,
				id = {
					id
				}
			}
		else
			combo[#combo].id[trial.recordingSubIndex] = id
		end
		trial.recordingSubIndex = trial.recordingSubIndex + 1
		if trial.recordingSubIndex > 3 then
			trial.recordingSubIndex = 1
		end
	elseif p1.previousStand == 1 and p1.stand == 2 then
		combo[#combo + 1] = {
			name = "6AA (Remote)",
			type = comboType.remote
		}
	elseif p1.previousStand == 2 and p1.stand == 0 and p1.character ~= 0x08 then
		combo[#combo + 1] = {
			name = "S (Recall)",
			type = comboType.recall
		}
	elseif system.previousTimeStop == 0 and system.timeStop > 0 then
		local tsName = {
			[0] = "6BA6S ",
			[11] = "6CA6S ",
			[14] = "A6C4S "
		}
		combo[#combo + 1] = {
			name = (tsName[p1.character] or "").."(Time Stop)",
			type = comboType.timeStop
		}
	elseif system.previousTimeStop > 0 and system.timeStop == 0 then
		combo[#combo + 1] = {
			name = "(Time Stop End)",
			type = comboType.timeStopEnd
		}
	elseif p2.throwTech > 0 then
		combo[#combo + 1] = {
			name = "6C (Grab)",
			type = comboType.grab,
		}
	elseif (p1.character == 16 and p1.previousActionId == 43 and p1.actionId == 44) or -- hol horse s bullet
			(p1.character == 23 and p1.previousActionId == 90 and p1.actionId == 91) then --hoingo s bullet
		local name = "S "
		local directions = {}
		local bytes = readDWord(0x2038870)
		for i = 7, 0, -1 do 
			local dir = band(rShift(bytes, i * 4), 0xF)
			if dir ~= 0 then
				dir = p1.facing == 1 and dir or swapHexDirection(dir)
				directions[#directions + 1] = dir
				name = name..hexToAnime[dir]
			end
		end
		combo[#combo + 1] = {
			name = name,
			type = comboType.sBullet,
			directions = directions,
		}
	end
end

function trialFinaliseRecording()
	local trim = not (options.mediumKickHotkey == "recordParry" or options.mediumKickHotkey == "recordAntiAir")
	local hexes = duplicateList(p1.recorded[options.recordingSlot], trim, false)
	if #hexes == 0 then return end
	trial.recording.recording = getParsedRecording(hexes)
end

function trialRecordingSave()
	local recording = trial.recording
	if not recording then
		menu.info = "No recording found!"
		playSound(sounds.error, 0x4040)
		return
	end
	local char = charToIndex[recording.p1.character]
	if not char then
		menu.info = "Trials for this character are not supported"
		playSound(sounds.error, 0x4040)
		return
	end
	local charTrials = trials[char].trials
	if  #charTrials >= 32 then
		menu.info = "Trial limit of 32 reached!"
		playSound(sounds.error, 0x4040)
	elseif #trial.recording.combo == 0 then
		menu.info = "No combo found!"
		playSound(sounds.error, 0x4040)
	elseif menu.info ~= "Recording added to trials!" then -- Prevent accidental duplication
		charTrials[#charTrials + 1] = trial.recording
		menu.info = "Recording added to trials!"
		trial.export = true
		playSound(sounds.select, 0x4040)
	end
end

function trialReset()
	if trialPlayback() then
		trialForceStop()
	else
		trialModeStart()
		trial.reset = true
		trial.positionCounter = 0
	end
end

function updateTrialReset()
	if trial.wait > 0 then
		trial.wait = trial.wait - 1
		return
	end

	--update stage
	if updateStage(trial.trial.stage.id) then
		trial.wait = 5
		return 
	end

	--update characters
	if updateCharacter(p1, trial.trial.p1.character) then
		trial.wait = 5
		return
	end
	if updateCharacter(p2, trial.trial.p2.character) then
		trial.wait = 5
		return
	end

	--update stand
	if updateTrialStand() then
		return
	end

	--update position
	if updateTrialPosition() then
		trial.wait = 1
		return
	end

	trial.reset = false
end

function trialReplay()
	if trialPlayback() then
		trialForceStop()
	else
		if trial.recorded then
			trialModeStart()
			trial.replay = true
			trial.positionCounter = 0
		end 
	end
end

function updateTrialReplay()
	if trial.wait > 0 then
		trial.wait = trial.wait - 1
		return
	end

	--update stand
	if updateTrialStand() then
		return
	end

	--update position
	if updateTrialPosition() then
		trial.wait = 1
		return
	end

	if trial.trial.parry then
		system.parry = 1
		trial.parryReplay = true
	elseif trial.trial.antiair then
		system.antiAir = 2
		trial.antiAirReplay = true
	else
		trialStartReplay()
	end
	trial.replay = false
end

function updateTrialAntiAir()
	if trial.wait > 0 then
		trial.wait = trial.wait - 1
		return
	end

	if trial.antiAirDelay then
		trial.antiAirDelay = false
		trial.wait = 20
		return
	end

	--update stand
	if updateTrialStand() then
		return
	end

	system.antiAir = 1
end

function updateTrialParry()
	if trial.wait > 0 then
		trial.wait = trial.wait - 1
		return
	end

	if trial.parryDelay then
		trial.parryDelay = false
		trial.wait = 40
		return
	end

	--update stand
	if updateTrialStand() then
		return
	end

	system.parry = 1
end

function trialStartReplay()
	p1.playback = trial.recorded
	p1.playbackCount = #trial.recorded
	p1.playbackFacing = 1
	p1.playbackFlipped = p1.side ~= 1
end


function trialPlayback()
	return trial.reset or trial.replay or p1.playbackCount > 0 or p2.playbackCount > 0
end

function updateTrialStand()
	local p1update = updateTrialPlayerStand(p1, trial.trial.p1.stand)
	local p2update = updateTrialPlayerStand(p2, trial.trial.p2.stand)
	return p1update or p2update
end

function updateTrialPlayerStand(player, stand)
	if player.stand == stand then
		return false
	elseif (player.stand == 0 and stand > 0) or (player.stand == 1 and stand == 0) or player.stand == 2 then
		player.playback = { 0x80 }
		player.playbackCount = 1
		trial.wait = 10
	elseif player.stand == 1 and stand == 2 then
		player.playback = { 0x08, 0x38 }
		player.playbackFacing = 1
		player.playbackFlipped = player.facing ~= 1
		player.playbackCount = 2
		trial.wait = 30
	end
	return true
end

-- Updates your the position of the player and stand relative to the recorded stages borders and facing direction
function updateTrialPosition()
	-- update positions of player and stand
	local p1x, p1sx, p2x, p2sx
	local updated = false
	-- position difference between p1, p2 and stands
	local p1sd = math.abs(trial.trial.p1.x - trial.trial.p1.standX)
	local p2d = math.abs(trial.trial.p1.x - trial.trial.p2.x)
	local p2sd = math.abs(trial.trial.p1.x - trial.trial.p2.standX)
	-- borders of stage and recorded stage
	local sx = stageBorder[system.stageId + 1][1]
	local sx2 = stageBorder[system.stageId + 1][2]
	local sp = stageBorder[system.stageId + 1][3]
	local tx = stageBorder[trial.trial.stage.id + 1][1]
	local tx2 = stageBorder[trial.trial.stage.id + 1][2]
	local tp = stageBorder[trial.trial.stage.id + 1][3]
	-- screen position
	local screenX = system.screenX
	local trialScreenX = trial.trial.stage.x
	local newScreenX

	-- update facing direction
	writeByte(p1.memory.facing, trial.trial.p1.facing)
	writeByte(p2.memory.facing, trial.trial.p2.facing)
	if trial.trial.p1.standFacing then
		local facing = trial.trial.p1.standFacing
		writeByte(p1.memory.standFacing, facing)
		writeByte(0x203514D, facing)
		writeByte(0x2035239, facing)
	end
	if trial.trial.p2.standFacing then
		local facing = trial.trial.p2.standFacing
		writeByte(p2.memory.standFacing, facing)
		writeByte(0x203556D, facing)
		writeByte(0x2035659, facing)
	end

	-- update position relative to the border you are facing towards
	if trial.trial.p1.facing == 1 then
		-- relative distance from right border
		p1x = sx2 - (tx2 - trial.trial.p1.x)
		-- modifier based on zoom state
		local zx = (system.zoomState == 0 or system.zoomState == 3) and stage.left or stage.leftZoomed
		-- if the relative distance is outside of current stage bounds 
		if p1x < sx + zx then
			-- hug left border
			p1x = sx + zx
		end
		-- update position relative to player 1
		p1sx = p1x + p1sd
		p2x = p1x + p2d
		p2sx = p1x + p2sd
		-- update screen position
		newScreenX = sx2 - (tx2 - trialScreenX)
		if newScreenX < sx then
			newScreenX = sx
		end
	else
		-- relative distance from left border
		p1x = sx + (trial.trial.p1.x - tx)
		-- modifier based on zoom state
		local zx = (system.zoomState == 0 or system.zoomState == 3) and stage.right or stage.rightZoomed
		-- if the relative distance is outside of current stage bounds 
		if p1x > sx2 + zx then
			-- hug right border
			p1x = sx2 + zx
		end
		--update position relative to player 1
		p1sx = p1x - p1sd
		p2x = p1x - p2d
		p2sx = p1x - p2sd
		-- update screen position
		newScreenX = sx + (trialScreenX - tx)
		if newScreenX > sx2 then
			newScreenX = sx2
		end
	end

	-- update screen position
	writeWord(0x0203145C, newScreenX)

	--move parrallax position relative to screen position
	if not stage.noParallax[system.stageId] then
		local sHalf = stage.offCenter[system.stageId] and stageBorder[system.stageId + 1][4] - sx or math.floor(sx2 - sx / 2)
		local sMod = (sHalf - sp) / sHalf
		local sOffset = sHalf + sMod * (newScreenX - sHalf)
		writeWord(0x02031464, sOffset)
	end

	if p1.x ~= p1x then
		writeWord(p1.memory2.x, p1x)
		updated = true
	end
	if p2.x ~= p2x then
		writeWord(p2.memory2.x, p2x)
		updated = true
	end
	if (p1.stand > 0 or p1.character == 0x08) and p1.standX ~= p1sx then
		writeWord(p1.memory2.standX, p1sx)
		updated = true
	end
	if p2.stand > 0 and p2.standX ~= p2sx then
		writeWord(p2.memory2.standX, p2sx)
		updated = true
	end

	if updated then
		trial.positionCounter = trial.positionCounter + 1
		if trial.positionCounter == 15 then
			return false
		end
	end

	-- return whether updated or not
	return updated
end

function trialMenuClose()
	trial.reset = true
	trial.positionCounter = 0
end

function trialForceStop()
	trialModeStart()
	p1.playbackCount = 0
	p2.playbackCount = 0
	system.parry = 0
	system.antiAir = 0
	trial.parryReplay = false
	trial.antiAirReplay = false
end

function parseTrialRecording()
	if not trial.trial.recording then
		return nil
	end
	return parseRecording(trial.trial.recording)
end

function resetTrialCompletion()
	clearTrialOptions()
	writeSettings()
	playSound(sounds.select, 0x4040)
end

function clearTrialOptions()
	local successTable = options.trialSuccess[options.trialsFilename] or 0
	for i = 1, 24, 1 do 
		successTable[i] = 0
	end
	menu.info = "Trial completion reset!"
end

-- Cleans up the trial table. Swaps strings for ints
function sanitizeTrials()
	--add boss characters
	if #trials < 24 then
		trials[23] = {
			name = "Boss Ice",
			trials = {},
		}
		trials[24] = {
			name = "Death 13",
			trials = {},
		}
	end
	if #trials < 25 then
		trials[25] = {
			name = "About",
			trials = {},
			info = {},
		}
	end
	for i = 1, 24, 1 do
		for y = 1, #trials[i].trials, 1 do
			for c = 1, #trials[i].trials[y].combo, 1 do
				trials[i].trials[y].combo[c].type = comboDictionary[trials[i].trials[y].combo[c].type] or 1
			end
		end
	end
end

function trialOptionsVerification()
	if #trials == 0 then
		menu.info = "No trials jsons found"
		playSound(sounds.error, 0x4040)
	else
		-- replace the current option with the submenu and select it
		local option = menu.options[menu.index]
		option.type = optionType.subMenu
		option.options = trialOptions
		menuSelect()
	end
end

-------------------------------------------------
-- Gui
-------------------------------------------------

function guiWriter() -- Writes the GUI
	drawHitboxes()
	drawHud()
	drawMenu()
end

function drawHud()
	if options.guiStyle == 1 then return end

	if options.infoNumbers then
		drawInfoNumbers()
	end

	if options.inputStyle == 1 then
		drawSimpleInputs()
	elseif options.inputStyle == 2 then
		drawHistoryInputs()
	elseif options.inputStyle == 3 then
		drawFrameInputs()
	end
	if trial.enabled then
		drawTrialGui()
	else
		if (p1.recording) then
			gui.text(152,32,"Recording", options.failColor)
		elseif (p1.playbackCount > 1) then
			gui.text(152,32,"Replaying", options.failColor)
		end
		if (p2.recording) then
			gui.text(200,32,"Recording", options.failColor)
		elseif (p2.playbackCount > 1) then
			gui.text(200,32,"Replaying", options.failColor)
		end
	end

	if menu.state == 0 then
		if options.guiStyle == 3 then
			drawAdvancedHud()
		elseif options.guiStyle == 4 then
			drawMeatyHud()
		elseif options.guiStyle == 5 then
			drawFrameData()
		elseif options.guiStyle == 6 then
			drawTrialDebugHud()
		elseif options.guiStyle == 7 then
			drawAttackInfo()
		elseif options.guiStyle == 8 then
			drawActionFrameInfo()
		elseif options.guiStyle == 9 then
			drawProjectileFrameInfo()
		end
	end

	if options.characterSpecific then
		drawCharacterSpecific()
	end

	if debug then
		drawDebug(160, 20)
	end
end

function drawSimpleInputs()
	if options.guiStyle ~= 3 then
		if options.p1Gui then
			drawFixedInput(p1.inputHistoryTable[1], 7, 80)
		end
		if options.p2Gui then 
			drawFixedInput(p2.inputHistoryTable[1], 343, 80)
		end
	else
		if options.p1Gui then
			drawFixedInput(p1.inputHistoryTable[1], 7, 56)
		end
		if options.p2Gui then 
			drawFixedInput(p2.inputHistoryTable[1], 343, 56)
		end
	end
	drawSimpleHud()
end

function drawHistoryInputs()
	if options.p1Gui then -- p1
		local historyLength = (options.guiStyle == 3 and 13 or 11)
		for i = 1, historyLength, 1 do
			local hex = p1.inputHistoryTable[i]
			drawInput(hex, 13, 200 - (11 * i))
		end
	end
	if options.p2Gui then  -- p2
		local historyLength = (options.guiStyle == 3 and 13 or 11)
		for i = 1, historyLength, 1 do
			local hex = p2.inputHistoryTable[i]
			drawInput(hex, 337, 200 - (11 * i))
		end
	end
	drawSimpleHud()
end

function drawFrameInputs()
	if options.p1Gui then -- p1
		for i = 1, 13, 1 do
			local hex = p1.inputHistoryTable[i]
			if hex ~= -1 then
				local count = band(0xFFFF, hex)
				local input = rShift(hex, 16)
				guiTextAlignRight(22, 199 - (11 * i), count, colors.menuUnselected)
				drawInput(input, 25, 200 - (11 * i))
			end
		end
	end

	if options.p2Gui then  -- p2
		for i = 1, 13, 1 do
			local hex = p2.inputHistoryTable[i]
			if hex ~= -1 then
				local count = band(0xFFFF, hex)
				local input = rShift(hex, 16)
				guiTextAlignRight(346, 199 - (11 * i), count, colors.menuUnselected)
				drawInput(input, 349, 200 - (11 * i))
			end
		end
	end
end

function drawInput(hex, x, y) -- Draws the dpad and buttons
	local buttonOffset = 0
	if band(hex, 0x10) == 0x10 then --A
		gui.text(x + 12, y - 1, "A", options.inputHistoryA)
		buttonOffset = buttonOffset + 6
	end
	if band(hex, 0x20) == 0x20 then --B
		gui.text(x + 12 + buttonOffset, y - 1, "B", options.inputHistoryB)
		buttonOffset = buttonOffset + 6
	end
	if band(hex, 0x40) == 0x40 then --C
		gui.text(x + 12 + buttonOffset, y - 1, "C", options.inputHistoryC)
		buttonOffset = buttonOffset + 6
	end
	if band(hex, 0x80) == 0x80 then --S
		gui.text(x + 12 + buttonOffset, y - 1, "S", options.inputHistoryS)
	end
	if band(hex, 0x0F) > 0 then
		drawDpad(x, y, 3)
	end
	if band(hex, 0x01) == 0x01 then --Up
		gui.box(x + 4, y, x + 5, y - 2, colors.dpadActive)
	end
	if band(hex, 0x02) == 0x02 then --Down
		gui.box(x + 4, y + 3, x + 5, y + 5, colors.dpadActive)
	end
	if band(hex, 0x04) == 0x04 then --Left
		gui.box(x + 1, y + 1, x + 3, y + 2, colors.dpadActive)
	end
	if band(hex, 0x08) == 0x08 then --Right
		gui.box(x + 6, y + 1, x + 8, y + 2, colors.dpadActive)
	end 
end

function drawFixedInput(hex, x, y)
	gui.text(x + 12, y - 2, "A", band(hex, 0x10) == 0x10 and colors.dpadActive or colors.menuUnselected) --A
	gui.text(x + 18, y - 2, "B", band(hex, 0x20) == 0x20 and colors.dpadActive or colors.menuUnselected) --B
	gui.text(x + 24, y - 2, "C", band(hex, 0x40) == 0x40 and colors.dpadActive or colors.menuUnselected) --C
	gui.text(x + 30, y - 2, "S", band(hex, 0x80) == 0x80 and colors.dpadActive or colors.menuUnselected) --S
	drawDpad(x, y, 3)
	if band(hex, 0x01) == 0x01 then --Up
		gui.box(x + 4, y, x + 5, y - 2, colors.dpadActive)
	end
	if band(hex, 0x02) == 0x02 then --Down
		gui.box(x + 4, y + 3, x + 5, y + 5, colors.dpadActive)
	end
	if band(hex, 0x04) == 0x04 then --Left
		gui.box(x + 1, y + 1, x + 3, y + 2, colors.dpadActive)
	end
	if band(hex, 0x08) == 0x08 then --Right
		gui.box(x + 6, y + 1, x + 8, y + 2, colors.dpadActive)
	end 
end

function drawSimpleHud()
	if options.guiStyle ~= 3 then
		if options.p1Gui then
			gui.text(8,50,"P1 Damage: "..tostring(p2.previousDamage)) -- Damage of P1's last hit
			gui.text(8,66,"P1 Combo: ")
			gui.text(48,66, p1.displayComboCounter, p1.comboCounterColor) -- P1's combo count
			gui.text(8,58,"P1 Combo Damage: "..tostring(p1.comboDamage)) -- Damage of P1's combo in total
		end
		if options.p2Gui then
			gui.text(300,50,"P2 Damage: " .. tostring(p1.previousDamage)) -- Damage of P2's last hit
			gui.text(300,66,"P2 Combo: ")
			gui.text(348,66, p2.displayComboCounter, p2.comboCounterColor) -- P2's combo count
			gui.text(300,58,"P2 Combo Damage: " .. tostring(p2.comboDamage)) -- Damage of P2's combo in total
		end
	end
end

function drawAdvancedHud()
	gui.text(146,40,"Damage: ") -- Damage of P1's last hit
	guiTextAlignRight(236,40,p2.previousDamage) -- Damage of P1's last hit
	gui.text(146,48,"Combo Damage: ") -- Damage of P1's combo in total
	guiTextAlignRight(236,48,p1.comboDamage) -- Damage of P1's combo in total
	gui.text(146,56,"Combo: ")
	guiTextAlignRight(236,56,p1.displayComboCounter, p1.comboCounterColor)
	gui.text(146,64,"IPS: ") -- IPS for P1's combo
	if p1.ips > 0 then 
		guiTextAlignRight(236, 64, hud.ips, options.successColor)
	else
		guiTextAlignRight(236, 64, "OFF", options.failColor)
	end
	gui.text(146,72,"Scaling: ") -- Scaling for P1's combo
	if p1.previousScaling == 0 then
		guiTextAlignRight(236, 72, "OFF", options.failColor)
	else
		guiTextAlignRight(236, 72, "ON", options.successColor)
	end
	gui.text(146, 80, "Meaty:") 
	if p2.meaty then
		guiTextAlignRight(236, 80, "ON", options.successColor)
	else
		guiTextAlignRight(236, 80, "OFF", options.failColor)
	end
end

function drawMeatyHud()
	gui.text(168, 50, "Meaty:") 
	if p2.meaty then
		guiTextAlignRight(214, 50, "YES", options.successColor)
	else
		guiTextAlignRight(214, 50, "NO", options.failColor)
	end
	drawWakeupIndicator(145, 62, p2.wakeupCount)
end

function drawTrialDebugHud()
	debugInfo = { 
		"Attack ID:", p1.attackId,
		"Stand Attack ID:", p1.standAttackId,
		"Action ID:", p1.actionId,
		"Stand Action ID:", p1.standActionId,
		"Projectile 1 ID:", projectiles[1].attackId,
		"Projectile 1 Action:", projectiles[1].actionId,
		"Projectile 2 ID:", projectiles[2].attackId,
		"Projectile 3 ID:", projectiles[3].attackId,
		"Projectile 4 ID:", projectiles[4].attackId,
		"Projectile 5 ID:", projectiles[5].attackId,
	}
	local x = 146
	local x2 = 236
	local y = 40
	for i = 1, #debugInfo, 2 do
		gui.text(x, y + 8 * i / 2, debugInfo[i])
		gui.text(x2, y + 8 * i / 2, debugInfo[i + 1])
	end
end

function drawInfoNumbers()
	gui.text(18,15, p1.health) -- P1 Health at x:18 and y:15
	gui.text(355,15, p2.health) -- P2 Health
	gui.text(50, 24, p1.standHealth) -- P1's Stand Health
	gui.text(326,24, p2.standHealth) -- P2's Stand Health
	gui.text(135,216,tostring(p1.meter)) -- P1's meter fill
	gui.text(242,216,tostring(p2.meter)) -- P2's meter fill
end

function guiTextAlignRight(x, y, text, color) 
	local t = tostring(text)
	color = color or "white"
	gui.text(x - #t * 4, y, t, color)
end

function drawDpad(dpadX, dpadY, sideLength)
	gui.box(dpadX, dpadY, dpadX + (sideLength * 3), dpadY + sideLength, colors.dpadBack, colors.dpadBorder)
	gui.box(dpadX + sideLength, dpadY - sideLength, dpadX + (sideLength * 2), dpadY + (sideLength * 2), colors.dpadBack, colors.dpadBorder)
	gui.box(dpadX + 1, dpadY + 1, dpadX + (sideLength * 3) - 1, dpadY+sideLength - 1, colors.dpadBack)
end

-- Draws the menu overlay
function drawMenu()
	if menu.state == 0 then return end
	gui.box(90, 36, 294, 212, colors.menuBackground, colors.menuBorder)
	gui.text(110, 42, menu.title, colors.menuTitle)
	if menu.state == 3 then --info
		drawInfo()
	elseif menu.state == 5 then --trials characters
		drawTrialsCharacters()
	elseif menu.state == 6 then --trials
		drawTrials()
	elseif menu.state == 7 then --files
		drawFileList()
	elseif menu.state == 8 then --trial about
		drawTrialsAbout()
	else
		drawList()
	end
end

function drawList()
	for i = 1, #menu.options, 1 do
		local color = (menu.index == i and menu.flashColor or colors.menuUnselected)
		local option = menu.options[i]
		local x = 100
		local x2 = 200
		local y = 42 + i * 12
		gui.text(x, y, option.name, color)
		if option.type == optionType.bool then
			local bool = options[option.key]
			local word = bool and "Enabled" or "Disabled"
			gui.text(x2, y, word, color)
			drawSlidingBar(i, bool and 2 or 1, 2, color)
		elseif option.type == optionType.int then
			local number = options[option.key]
			gui.text(x2, y, number, color)
			drawSlidingBar(i, number - option.min + 1, option.max - option.min + 1, color)
		elseif option.type == optionType.managedInt then
			local number = options[option.key]
			gui.text(x2, y, number, color)
			local min = options[option.min]
			local max = options[option.max]
			drawSlidingBar(i, number - min + 1, max - min + 1, color)
		elseif option.type == optionType.list then
			local index = options[option.key]
			local word = option.list[index]
			gui.text(x2, y, word, color)
			drawSlidingBar(i, index, #option.list, color)
		elseif option.type == optionType.slider then
			local value = getMenuColor(option.mask, option.shift)
			gui.text(x + 50, y, value, color)
		elseif option.type == optionType.key then
			local value = options[option.key]
			local index = tableIndex(option.list, value)
			local word = option.names[value]
			gui.text(x2, y, word, color)
			drawSlidingBar(i, index, #option.list, color)
		end
	end
	if menu.state == 4 then
		local color = bor(options[menu.color], 0xFF)
		gui.box(200, 60, 240, 100, color, color)
		gui.text(186, 112, "Hold A to increase by 10", colors.menuTitle)
	end
	if #menu.info > 0 then
		gui.box(90, 10, 294, 28, colors.menuBackground, colors.menuBorder)
		gui.text(100, 16, menu.info, colors.menuUnselected)
	end
end

function drawSlidingBar(i, index, size, color)
	if menu.index ~= i then return end
	local length = 62
	local inc = length / size
	local x = 199
	local y =  51 + i * 12
	gui.line(x, y, x + length, y, colors.menuUnselected)
	gui.line(x + (index - 1) * inc, y, x + (index - 1) * inc + inc, y, color)
end

function drawInfo()
	for i = 1, #menu.info, 1 do
		gui.text(100, 48 + i * 12, menu.info[i], colors.menuUnselected)
	end
	gui.text(110, 172, "Return", menu.flashColor)
end

function drawWakeupIndicator(x, y, count)
	gui.box(x, y, x + 92, y + 18, colors.wakeupBorder)
	if count > 0 then
		local length = math.min(count, 29)
		gui.box(x + 90 - length * 3, y + 2, x + 90, y + 16, colors.wakeupIndicator)
	end
end

function drawDebug(x, y) 
	local debugInfo = {
		p2.wakeupCount.." wakeup count",
		p2.guardCount.." guard count",
		p2.hitCount.." hit count",
		p2.airtechCount.." airtech count",
		p2.pushblockCount.." pushblock count",
		(p2.wakeupFrame and "true" or "false").." wakeup frame",
		p1.attackId.." attack id",
		p1.attackHit.." attack hit",
		p1.standAttackId.." stand attack id",
		p1.standAttackHit.." stand attack hit",
		p1.actionId.." action id",
		p1.standActionId.." stand action id",
		--p2.hitstun.." hitstun",
		p2.hitFreeze.." hit stop",
		p2.stunCount.." hitstun count",
		--p2.stunType.." stun type",
		p2.defenseAction.." p2 defense action",
		--string.format("%08X p2 action address", p2.actionAddress),
		--string.format("%08X p2 action frame", readDWord(p2.memory4.actionAddress - 8)),
		--string.format("%08X p2 action frame previous", readDWord(p2.memory4.actionAddress - 4)),
		--readByte(0x2034D4F).." p2 action frame count",
		system.rng.." RNG 1",
		system.rng2.." RNG 2",
		--p2.y.." p2 y",
		--(readDWordSigned(0x2034DA8) / 0x10000).." p2 y velocity",
		--readByte(0x2034CAC + 0x1B).." p2 scaling index"
		-- projectiles[1].attackId.." proj attack id",
		-- projectiles[1].attackHit.." proj hit",
		-- projectiles[1].actionId.." proj action id",
		-- system.screenX.." screen x",
		-- readWord(0x02031464).." screen px",
		-- p1.x.." p1 x",
		-- p2.x.." p2 x",
		tostring(p1.canAct).." p1 can act",
		-- tostring(p2.canAct).." p2 can act",
		-- tostring(p2.hitstun).." p2 hitstun",
		-- p2.guardState.." p2 guard state",
		-- p2.riseFall.." p2 rise fall",
		readWordSigned(0x2034DA8).." p2 y velocity",
		(readDWordSigned(0x2034DA8) / 0x10000).." p2 y velocity",
		--p2.blocking.." p2 blocking",
		p1.attackType.." p1 attack type",
		p1.canAct1.." p1 can act 1",
		p1.canAct2.." p1 can act 2",
	}
	for i = 1, #debugInfo, 1 do
		gui.text(x, y + 8 * i, debugInfo[i])
	end
	local tc = readByte(0x02032D76)
	for i = 0, 14, 1 do
		local ids = readByteRange(0x02032174 + i * 6, 6)
		local str = string.format("%02X%02X%02X%02X%02X%02X", ids[1], ids[2], ids[3], ids[4], ids[5], ids[6])
		gui.text(100, 40 + i * 8, str)
		local current = tc - 1
		if i == current then
			gui.text(90, 40 + i * 8, "->")
		end
	end
end

function drawTrialsCharacters()
	for i = 1, #menu.options - 1, 1 do
		local option = menu.options[i]
		local color = (menu.index == i) and menu.flashColor or colors.menuUnselected
		local x = 100 + ((i - 1) % 2) * 100
		local y = 54 + math.floor((i - 1) / 2) * 12
		gui.text(x, y, option.name, color)
		if option.completed then
			guiTextAlignRight(x + 86, y, option.completed.."/"..#trials[i].trials, color)
		end
	end
	local color = (menu.index == #menu.options) and menu.flashColor or colors.menuUnselected
	gui.text(200, 198, "Return", color)
end

function drawTrials()
	if menu.index ~= #menu.options then
		local trial = menu.options[menu.index].trial
		gui.text(100, 60, trial.name, colors.menuUnselected)
		local difficulty = type(trial.difficulty) == "number" and string.rep("* ", trial.difficulty) or trial.difficulty
		gui.text(100, 72, "Difficulty: "..difficulty, colors.menuUnselected)
		gui.text(100, 84, "Author: "..trial.author, colors.menuUnselected)
		gui.text(100, 96, "Info:", colors.menuUnselected)
		for i = 1, #trial.info, 1 do
			gui.text(100, 100 + i * 8, trial.info[i], colors.menuUnselected)
		end
	end
	for i = 1, #menu.options - 1, 1 do
		local option = menu.options[i]
		local color = (menu.index == i) and menu.flashColor or colors.menuUnselected
		local successColor = option.success and "red" or "clear"
		local x = 102 + ((i - 1) % 12) * 15
		local y = 160 + math.floor((i - 1) / 12) * 13
		local textOffset = i < 10 and 2 or 0
		gui.box(x, y, x + 12, y + 10, successColor, color)
		gui.text(x + 3 + textOffset, y + 2, i, color)
	end
	local color = (menu.index == #menu.options) and menu.flashColor or colors.menuUnselected
	gui.text(240, 192, "Return", color)
end

function drawTrialGui()
	if not options.trialHud then return end
	local length = math.min(13, #trial.combo)
	for i = 1, length, 1 do
		local index = trial.min + i - 1
		local color
		if trial.failIndex == 0 then
			color = index < trial.index and options.comboCounterActiveColor or colors.menuUnselected
		else
			color = index < trial.failIndex and options.comboCounterActiveColor or
				index == trial.failIndex and options.failColor or colors.menuUnselected
		end
		gui.text(14, 44 + i * 10, trial.combo[index].name, color)
		if index == trial.index then
			gui.text(3, 44 + i * 10, "->")
		end
	end
	if menu.state == 0 then
		if trial.drill then
			gui.text(168, 72, "Loops")
			guiTextAlignRight(218, 72, trial.drillSuccess.."/"..trial.drill)
		end
		if trial.success then
			gui.text(178, 60, "Success!")
			gui.text(10, 188, "Start: Next Trial")
		elseif #trial.combo > 13 then
			gui.text(10, 188, "Start + Up/Down: Scroll")
		end
	end
	if p1.playbackCount > 1 then
		gui.text(179, 34, "Preview", options.failColor)
	end
	gui.text(290, 52, "Not in Use 1: Restart")
	gui.text(290, 62, "Not in Use 2: Preview")
	drawFixedInput(p1.inputHistoryTable[1], 175, 216)
end

function drawFileList()
	local length = math.min(#menu.options, 15)
	for i = 1, length, 1 do
		local index = menu.min + i - 1
		local option = menu.options[index]
		local color = menu.index == index and menu.flashColor or 
			options.trialsFilename == option.name and options.failColor or colors.menuUnselected
		gui.text(100, 44 + i * 10, option.name, color)
	end
end

function drawTrialsAbout()
	local info = trials[25].info
	local length = math.min(#info, 12)
	for i = 1, length, 1 do
		gui.text(100, 42 + i * 12, info[i + menu.index - 1], colors.menuUnselected)
	end
	if #info > 12 then
		if menu.index > 1 then
			gui.text(194, 42, "^", colors.menuUnselected)
		end
		if menu.index ~= #info - 11 then
			gui.text(194, 198, "v", colors.menuUnselected)
		end
	end
	gui.text(100, 198, "Return", menu.flashColor)
end

function drawAttackInfo()
	if p1.attackHit > 0 and (p1.previousAttackHit == 0 or p1.attackId ~= p1.previousAttackId) then 
		system.attackId = p1.attackId
		system.attackAddress = readDWord(0x203488C + 0xD0) + system.attackId * 0x30
	end
	if p1.standAttackHit > 0 and (p1.previousStandAttackHit == 0 or p1.previousStandAttackId ~= p1.standAttackId) then
		system.attackId = p1.standAttackId
		system.attackAddress = readDWord(0x20350CC + 0xD0) + system.attackId * 0x30
	end
	for i = 1, 32, 1 do
		local projectile = projectiles[i]
		if projectile.state > 0 then
			if projectile.attackHit > 0 and (projectile.previousAttackHit == 0 or projectile.previousAttackId ~= projectile.attackId) then
				system.attackId = projectile.attackId
				system.attackAddress = readDWord(0x0203806C + i * 0x420 + 0xD0) + system.attackId * 0x30
				break
			end
		end
	end
	if system.attackAddress == 0 then return end
	gui.text(92, 40, "ID:"..system.attackId)
	gui.text(182, 40, string.format("Address: %08X", system.attackAddress))
	for i = 0, 0x2F, 1 do
		local x = math.floor(i / 0x10)
		local y = i % 0x10
		local name = hitInfo.names[i + 1] or i
		local value = readByte(system.attackAddress + i)
		local table = hitInfo.tables[i]
		if table then
			value = table[value] or value
		end
		gui.text(92 + x * 90, 50 + y * 8, name..": "..value)
	end
end

local frameData = {
	"Start Up: ", hud.startUp,
	"Active: ", hud.active,
	"Recovery: ", hud.recovery,
	"Frame Advantage: ", hud.frameAdvantage,
	"Reversal: ", hud.reversalFrame,
	"I Frames: ", hud.iFrames,
	--"Push Block: ", hud.pushBlock or "NA",
	"P1 act: ", tostring(p1.canAct),
	"P2 act: ", tostring(p2.canAct),
	"P1 invul: ", hud.invul,
	"S1 invul: ", hud.standInvul,
	-- "update frame advantage: ", tostring(system.frameAdvantage),
	-- "cancel frame: ", tostring(readByte(p1.frameAddress + 0x14) == 0),
	-- "can act 1: ", p1.canAct1,
	-- "can act 2: ", p1.canAct2,
	-- "stand act 1: ", p1.standCanAct1,
	-- "stand act 2: ", p1.standCanAct2,
	-- "attack type: ", p1.attackType,
	-- "stand attack type: ", p1.standAttackType,
	-- "p1 hitstop: ", p1.hitFreeze,
	-- "p1 grab: ", p1.hitstun,
	-- "p1 stand grab: ", p1.standHitstun,
	-- "p2 guard: ", p2.guardState,
	-- "p2 stand guard: ", p2.standGuardState,
}

function drawFrameData()
	frameData[2] = hud.startUp
	frameData[4] = hud.active
	frameData[6] = hud.recovery
	frameData[8] = hud.frameAdvantage
	frameData[10] = hud.reversalFrame 
	frameData[12] = hud.iFrames
	frameData[14] = tostring(p1.canAct)
	frameData[16] = tostring(p2.canAct)
	frameData[18] = tostring(hud.invul)
	frameData[20] = tostring(hud.standInvul)

	for i = 1, #frameData, 2 do
		gui.text(160, 38 + i * 4, frameData[i]..frameData[i + 1])
		--gui.text(218, 38 + i * 4, frameData[i + 1])
	end
end

function drawActionFrameInfo()
	drawPlayerFrameInfo(p1.previousFrameAddress, 92, 50, "Player Address: %08X")
	drawPlayerFrameInfo(p1.previousStandFrameAddress, 230, 50, "Stand Address: %08X")
end

function drawProjectileFrameInfo()
	drawPlayerFrameInfo(system.previousProj1Address, 92, 50, "Projectile 1 Address: %08X")
	drawPlayerFrameInfo(system.previousProj2Address, 230, 50, "Projectile 2 Address: %08X")
end

function drawPlayerFrameInfo(frameAddress, baseX, baseY, name)
	gui.text(baseX, baseY - 10, string.format(name, frameAddress))
	if frameAddress < 0x6000000 or frameAddress > 0x6FFFFFF then return end
	local info = frameInfo[readByte(frameAddress) + 1]
	local length = readByte(frameAddress + 1)
	local i = 0
	local y = 0
	local x = 0
	while i < length do
		local key, value
		if i == 0 then
			key = "Type"
			value = info and info.name or i
		elseif i == 1 then
			key = "Size"
			value = length
		else
			if info and info.info and info.info[i] then
				local byteInfo = info.info[i]
				local type = type(byteInfo)
				if type == "table" then
					key = byteInfo.name
					if byteInfo.table then
						local byte = readByte(frameAddress + i)
						value = byteInfo.table[byte] or byte
					else
						if byteInfo.length == 4 then
							value = byteInfo.signed and readDWordSigned(frameAddress + i) or readDWord(frameAddress + i)
							i = i + 3
							if byteInfo.hex then
								value = string.format("%08X", value)
							end
						elseif byteInfo.length == 2 then
							value = byteInfo.signed and readWordSigned(frameAddress + i) or readWord(frameAddress + i)
							i = i + 1
							if byteInfo.hex then
								value = string.format("%04X", value)
							end
						else
							value = byteInfo.signed and readByteSigned(frameAddress + i) or readByte(frameAddress + i)
							if byteInfo.hex then
								value = string.format("%02X", value)
							end
						end
					end
				else
					key = byteInfo
					value = readByte(frameAddress + i)
				end
			else
				key = i
				value = readByte(frameAddress + i)
			end
		end
		gui.text(baseX + x * 80, baseY + y * 8, key..": "..value)
		i = i + 1
		y = y + 1
		if y > 0x10 then
			x = x + 1
			y = 0
		end
	end
end

function drawCharacterSpecific()
	if p1.character == 16 or p1.character == 23 then
		local bytes = readDWord(system.sBullet)
		local word = "S Bullet: "
		for i = 7, 0, -1 do 
			local dir = band(rShift(bytes, i * 4), 0xF)
			if dir ~= 0 then word = word..hexToAnime[dir] end
		end
		gui.text(56, 207, word)
	end
end

-------------------------------------------------
-- Hitboxes
-------------------------------------------------

function updateHitboxes()
	boxCache[2] = boxCache[1]
	boxCache[1] = getHitboxes()
end

function drawHitboxes()
	if options.hitboxes == 1 then
		return
	elseif options.hitboxes == 2 then
		if fba then
			drawCachedHitboxes(boxCache[2])
		else
			drawCachedHitboxes(boxCache[1])
		end
	elseif options.hitboxes == 3 then
		local adr = p1.memory.character

		local px = readWordSigned(adr + 0x5C)
		local py = 224 - 16 - readWordSigned(adr + 0x60)
		
		--Flip
		local flip = (readByteSigned(adr + 0x0d) == -1 and -1 or 1)
	
		--Hit Editor boxes
		drawbox(0x2035984, px, py, flip, options.collisionboxColor)
		
		--Hurtbox
		drawbox(0x203596C, px, py, flip, options.hurtboxColor)
		drawbox(0x2035974, px, py, flip, options.hurtboxColor)
		drawbox(0x203597C, px, py, flip, options.hurtboxColor)
		
		--Attack
		drawbox(0x203595C, px, py, flip, options.hitboxColor)
		drawbox(0x2035964, px, py, flip, colors.orangebox)
	end
end

function getHitboxes()
	local boxData = {{}, {}, {}}

	--local zoomX = readWordSigned(0x0205DBAA) / 384
	--local zoomY = readWordSigned(0x0205DBAE) / 224
	local screenX = system.screenX
	local screenY = system.screenY

	-- Player 1
	if p1.stand ~= 1 then
		drawPlayerHitboxes(p1.hitbox, p1.x - screenX, p1.y + screenY, p1.facing, p1.character, boxData)
	end
	if p1.standActive == 1 then
		drawPlayerHitboxes(p1.standHitbox, p1.standX - screenX, p1.standY + screenY, p1.standFacing, p1.character, boxData)
	end

	-- Player 2
	if p2.stand ~= 1 then
		drawPlayerHitboxes(p2.hitbox, p2.x - screenX, p2.y + screenY, p2.facing, p2.character, boxData)
	end
	if p2.standActive == 1 then
		drawPlayerHitboxes(p2.standHitbox, p2.standX - screenX, p2.standY + screenY, p2.standFacing, p2.character, boxData)
	end

	--Projectiles
	for i = 1, 64, 1 do
		local projectile = projectiles[i]
		if projectile.state > 0 then
			drawPlayerHitboxes(projectile.hitbox, projectile.x - screenX, projectile.y + screenY, projectile.facing, projectile.char, boxData)
		end
	end

	return boxData
end

function drawPlayerHitboxes(hitbox, x, y, facing, character, data)
	if hitbox == 0 then return end

	local hitboxOffset = hitboxOffsets[character + 1] + hitbox * 0x10

	local atk1 = readWordSigned(hitboxOffset)
	local atk2 = readWordSigned(hitboxOffset + 0x02)
	local head = readWordSigned(hitboxOffset + 0x04)
	local torso = readWordSigned(hitboxOffset + 0x06)
	local legs = readWordSigned(hitboxOffset + 0x08)
	local col = readWordSigned(hitboxOffset + 0x0A)
	
	local flip = facing == 1 and -1 or 1

	y = 460 - y

	local boxOffset = 0x6700000 + character * 0x1002

	drawbox2(atk1, boxOffset, x, y, flip, options.hitboxColor, data, 3)
	drawbox2(atk2, boxOffset, x, y, flip, colors.orangebox, data, 3)
	drawbox2(head, boxOffset, x, y, flip, options.hurtboxColor, data, 2)
	drawbox2(torso, boxOffset, x, y, flip, options.hurtboxColor, data, 2)
	drawbox2(legs, boxOffset, x, y, flip, options.hurtboxColor, data, 2)
	drawbox2(col, boxOffset, x, y, flip, options.collisionboxColor, data, 1)
end

function drawbox(adr, x, y, flip, color)
	local boxx1 = x + readWordSigned(adr) * flip
	local boxxrad = boxx1 + readWord(adr + 0x02) * flip
	local boxy1 = y - readWordSigned(adr + 0x04)
	local boxyrad = boxy1 - readWord(adr + 0x06)
	gui.box(boxx1,boxy1,boxxrad,boxyrad,color)
end

function drawbox2(i, offset, x, y, flip, color, data, layer)
	if i == 0 then return end
	local boxx1 = x + readWordSigned(offset + i * 0x08 + 0x02) * flip
	local boxxrad = boxx1 + readWord(offset + i * 0x08 + 0x04) * flip
	local boxy1 = y - readWordSigned(offset + i * 0x08 + 0x06)
	local boxyrad = boxy1 - readWord(offset + i * 0x08 + 0x08)
	table.insert(data[layer], { boxx1, boxy1, boxxrad, boxyrad, color })
end

function drawCachedHitboxes(data)
	for layer = 1, 3, 1 do
		local dataLayer = data[layer]
		for i = 1, #dataLayer, 1 do
			gui.box(dataLayer[i][1], dataLayer[i][2], dataLayer[i][3], dataLayer[i][4], dataLayer[i][5])
		end
	end
end

-------------------------------------------------
-- Register Functions
-------------------------------------------------

input.registerhotkey(1, function()
	if fcReplay then
		options.guiStyle = (options.guiStyle == 2) and 1 or 2
	else
		options.guiStyle = (options.guiStyle == #hudStyles) and 1 or options.guiStyle + 1
	end
	gui.clearuncommitted()
end)

input.registerhotkey(2, function()
	options.hitboxes = (options.hitboxes == 2) and 1 or options.hitboxes + 1
	gui.clearuncommitted()
end)

input.registerhotkey(3, function()
	options.music = not options.music
end)

input.registerhotkey(4, function()
	options.inputStyle = (options.inputStyle == 3) and 1 or options.inputStyle + 1
	clearInputHistory(p1)
	clearInputHistory(p2)
	gui.clearuncommitted()
end)

function replayOptions() 
	options.guiStyle = 2
	options.p1Gui = true
	options.p2Gui = true
	options.healthRefill = 1
	options.meterRefill = 1
	options.ips = true
	options.airTech = false
	options.guardAction = 1
	options.perfectAirTech = false
	options.forceStand = 1
	options.throwTech = false
	options.tandemCooldown = true
	options.boingo = false
	options.level = 1
	options.inputStyle = 2
	options.infiniteRounds = false
	options.taunt = true
	options.killDenial = false
	options.disableHud = false
	options.infiniteTimestop = false
	options.block = 1
	options.status = 1
	options.kakyoinPose = 1
	options.p1Hp = 144
	options.p2Hp = 144
	options.standGaugeLimit = false
	options.romHack = false
	resetReversalOptions()
end

-- Updates old settings to new
function updateSettings() 
	-- hotkey numbers to keys
	if type(options.mediumKickHotkey) == "number" then
		options.mediumKickHotkey = "record"
	end
	if type(options.strongKickHotkey) == "number" then
		options.strongKickHotkey = "replay"
	end
	-- mariah level bugfix
	if options.level == 0 then
		options.level = 1
	end
	-- update single recording to multiple recording slots
	if options.p1Recording[1] == nil then
		for i = 1, system.recordingSlots, 1 do
			options.p1Recording[i] = {}
			options.p2Recording[i] = {}
		end
	elseif type(options.p1Recording[1]) == "string" then
		local recording1 = options.p1Recording
		local recording2 = options.p2Recording
		options.p1Recording = { recording1 }
		options.p2Recording = { recording2 }
		for i = 2, system.recordingSlots, 1 do
			options.p1Recording[i] = {}
			options.p2Recording[i] = {}
		end
	end
	for i = 1, system.recordingSlots, 1 do
		options.p1Recording[i] = parseRecording(options.p1Recording[i])
		options.p2Recording[i] = parseRecording(options.p2Recording[i])
	end
	p1.recorded = options.p1Recording
	p2.recorded = options.p2Recording
	-- update refill types
	if type(options.healthRefill) == "boolean" then
		options.healthRefill = 2
	end
	if type(options.meterRefill) == "boolean" then
		options.meterRefill = 2
	end 
end

emu.registerstart(function()
	writeByte(0x20713A8, 0x09) -- Infinite Credits
	writeByte(0x20713A3, 0xFF) -- Bit mask that enables player input
	readSettings()
	updateSettings()
	readTrials()
	readMoveDefinitions()
	createInputsFile()
	createRomhackFile()
	clearInputHistory(p1)
	clearInputHistory(p2)
	updateReversal()
	if fcReplay then 
		replayOptions()
	end
	readRomhack()
	updateHacks()
end)

gui.register(function()
	guiWriter()
end)

emu.registerexit(function()
	gui.clearuncommitted()
	writeByte(0x20713A3, 0xFF) -- Bit mask that enables player input
	-- restore romhacks
	for k, v in pairs(romHacks.active) do
		if v then
			restoreHack(k)
		end
	end
end)

emu.registerbefore(function()
	updateInputBefore()
end)

savestate.registerload(function()
	writeByte(0x20713A3, menu.state > 0 and 0x00 or 0xFF); -- Enable/disable player input
end)

-------------------------------------------------
-- Main Loop
-------------------------------------------------

while true do 
	updateMemory()
	updateGameplayLoop()
	updateInput()
	updateInputCheck()
	updateTrial()
	updateCharacterControl()
	updateHitboxes()
	emu.frameadvance()
end