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

-------------------
-- CONFIGURATION --
-------------------

local fcReplay = false --Determines whether it's a fightcade replay or not
local debug = false -- Fbneo doesn't have watches so draw the variables on the screen

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
	meterRefill = true,
	healthRefill = true,
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
	print("Coin to open up the menu.")
	print("Hold start control your opponent.")
	print("Special functions are bound to Not In Use 1 and 2. The functions can be reassigned in the menu.")
	print("Holding down replay button will make it loop.")
	print("Pressing MK on the menu will restore p2 stand gauge")
	print("Pressing HK on the menu will restore p1 stand gauge")
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

-------------------------------------------------
-- Data
-------------------------------------------------

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
	back = 14
}

local systemOptions = {
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
		name = "Music:",
		key = "music",
		type = optionType.bool
	},
	{
		name = "Hud Style:",
		key = "guiStyle",
		type = optionType.list,
		list = {
			"None",
			"Simple",
			"Advanced",
			"Wakeup Indicator",
			"Trial Debug",
		}
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
		name = "Not In Use 1 Hotkey:",
		key = "mediumKickHotkey",
		type = optionType.key,
		list = {
			"record",
			"recordParry",
			"disabled"
		},
		names = {
			record = "Record",
			recordParry = "Record Parry",
			disabled = "Disabled"
		}
	},
	{
		name = "Not In Use 2 Hotkey:",
		key = "strongKickHotkey",
		type = optionType.key,
		list = {
			"replay",
			"replayP2",
			"inputPlayback",
			"disabled"
		},
		names = {
			replay = "Replay",
			replayP2 = "Replay P2",
			inputPlayback = "Input Playback",
			disabled = "Disabled"
		}
	},
	{
		name = "Return",
		type = optionType.back
	}
}

local battleOptions = {
	{
		name = "Meter Refill:",
		key = "meterRefill",
		type = optionType.bool
	},
	{
		name = "Health Refill:",
		key = "healthRefill",
		type = optionType.bool
	},
	{
		name = "Stand Gauge Refill:",
		key = "standGaugeRefill",
		type = optionType.bool
	},
	{
		name = "Infinite Rounds:",
		key = "infiniteRounds",
		type = optionType.bool
	},
	{
		name = "IPS:",
		key = "ips",
		type = optionType.bool
	},
	{
		name = "Tandem Cooldown",
		key = "tandemCooldown",
		type = optionType.bool
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
		name = "Boingo RNG:",
		key = "boingo",
		type = optionType.bool,
		info = "Warning: This breaks RNG while enabled"
	},
	{
		name = "Mariah Level:",
		key = "level",
		type = optionType.list,
		list = {
			"Disabled",
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
		name = "Guard Action:",
		key = "guardAction",
		type = optionType.list,
		list = {
			"Default",
			"Push block",
			"Guard Cancel"
		}
	},
	{
		name = "Guard Action Delay:",
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
			"Inputs.txt",
			"Buffered Inputs.txt"
		}
	},
	{
		name = "Reset to Default",
		type = optionType.func,
		func = function() resetReversalOptions() end
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
		name = "Reversal Settings",
		type = optionType.subMenu,
		options = reversalOptions
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
	previousHealth = 0,
	damage = 0,
	previousDamage = 0,
	comboDamage = 0,
	standHealth = 0,
	standGauge = 0,
	standGaugeMax = 0,
	combo = 0,
	previousCombo = 0,
	control = false,
	previousControl = false,
	directionLock = 0,
	directionLockFacing = 0,
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
	previousGuarding = 0,
	animationState = 0,
	previousAnimationState = 0,
	guardAnimation = 0,
	standGuardAnimation = 0,
	riseFall = 0,
	previousRiseFall = 0,
	hitstun = 0,
	blockstun = 0,
	previousBlockstun = 0,
	blocking = false,
	canAct1 = 0,
	canAct2 = 0,
	stand = false,
	previousIps = 0,
	ips = 0,
	scaling = 0,
	previousScaling = 0,
	canReversal = false,
	previousCanReversal = false,
	reversalCount = 0,
	canAct = false,
	previousCanAct = false,
	frameAdvantage = 0,
	defenseAction = 0,
	previousDefenseAction = 0,
	wakeupCount = 0,
	previousWakeupCount = 0,
	guardCount = 0,
	previousGuardCount = 0,
	hitCount = 0,
	previousHitCount = 0,
	airtechCount = 0,
	previousAirtechCount = 0,
	pushblockCount = 0,
	previousPushblockCount = 0,
	wakeupFreeze = 0,
	hitFreeze = 0,
	previousHitFreeze = 0,
	actionAddress = 0,
	stunType = 0,
	stunCount = 0,
	previousStunCount = 0,
	wakeupFrame = false,
	meaty = false,
	attackHit = 0,
	standAttackHit = 0,
	actionId = 0,
	standActionId = 0,
	airtech = false,
	newButtons = 0,
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
	healthRefill = 0x20349CD,
	combo = 0x205BB38,
	meter = 0x205BB64,
	meterRefill = 0x2034863,
	standGaugeRefill = 0x203520D,
	standGaugeMax = 0x02035211,
	guarding = 0x00000000, --placeholder need to find this later
	facing = 0x2034899,
	animationState = 0x00000000, --placeholder need to find this later
	riseFall  = 0x00000000, --placeholder need to find this later
	hitstun = 0x00000000, --placeholder need to find this later
	blockstun = 0x00000000, --placeholder need to find this later
	stand = 0x2034A1F,
	ips = 0x2034E9E,
	scaling = 0x2034E9D,
	height = 0x00000000,
	guardAnimation = 0x00000000,
	standGuardAnimation = 0x00000000,
	canAct1 = 0x02034941,
	canAct2 = 0x02034A25,
	throwTech = 0x02034A3C, --1b0
	standFacing = 0x20350D9,
	standActive = 0x02034A20,
	child = 0x02034AB2,
	defenseAction = 0x00000000,
	hitFreeze = 0x00000000,
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
	standActionId = 0x0203515E
}

p1.memory2 = {
	hitbox = 0x02034938, --AC
	standHitbox = 0x2035178,
	x = 0x20348E8,
	y = 0x20348EC,
	standX = 0x2035128,
	standY = 0x203512C
}

p1.memory4 = {
	actionAddress = 0x0203491C,
	standActionAddress = 0x0203515C
}

p2.memory = { 
	character = 0x2034CBF,
	health = 0x205BB29,
	standHealth = 0x205BB49,
	healthRefill = 0x2034DED,
	combo = 0x205BB39,
	meter = 0x205BB65,
	meterRefill = 0x2034887,
	standGaugeRefill = 0x203562D,
	standGaugeMax = 0x02035631,
	guarding = 0x02034E51,
	facing = 0x2034CB9,
	animationState = 0x02034D93,
	riseFall = 0x002034DA8,
	hitstun = 0x02034D91,
	blockstun = 0x02034D5A,
	stand = 0x02034E3F,
	ips = 0x00000000,
	scaling = 0x00000000,
	height = 0x02034D0D,
	guardAnimation = 0x02034D92,
	standGuardAnimation = 0x20355D2,
	canAct1 = 0x00000000,
	canAct2 = 0x00000000,
	throwTech = 0x02034E5C,
	standFacing = 0x020354F9,
	standActive = 0x02034E40,
	child = 0x02034ED2,
	defenseAction = 0x02034D92,
	hitFreeze = 0x02034E7F,
	wakeupFreeze = 0x02034D9A,
	stunType = 0x02034E82,
	stunCount = 0x02034E92
}

p2.memory2 = {
	hitbox = 0x02034D58,
	standHitbox = 0x02035598,
	x = 0x2034D08,
	y = 0x2034D0C,
	standX = 0x2035548,
	standY = 0x203554C,
}

p2.memory4 = {
	actionAddress = 0x02034D3C,
	standActionAddress = 0x0203557C
}

p1.health = readByte(p1.memory.health)
p1.standHealth = readByte(p1.memory.standHealth)
p1.standGauge = p1.standHealth 
p2.health = readByte(p2.memory.health)
p2.standHealth = readByte(p2.memory.standHealth)
p2.standGauge = p2.standHealth

p1.name = "P1 "
p1.number = 1
p2.name = "P2 "
p2.number = 2

local system = {
	frameAdvantage = 0,
	previousFrame = emu.framecount() - 1,
	screenFreeze = 0,
	parry = 0,
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
	p1.buttons.s
}

local cancelInputs = {
	p1.buttons.b,
	p1.buttons.c,
	p1.buttons.mk,
	p1.buttons.sk
}

local inputTables = {
	current = {},
	previous = {},
	held = {},
	overwrite = {}
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
		inputTables.held[v] = 0
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
	{ -2, -2 },
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
		consumed = false
	}
end

local stageBorder = { -- { left border, right border }
	{ 3, 397 },
	{ 3, 381 },
	{ -253, 621 },
	{ 64, 576 }, 
	{ 3, 381 },
	{ -256, 800 },
	{ 3, 381 },
	{ 80, 560 },
	{ 48, 848 },
	{ 0, 0 },
	{ 48, 592 },
	{ 192, 704 },
	{ -192, 704 },
	{ 56, 840 },
	{ 48, 576 },
	{ 48, 592 },
	{ -384, 912 },
	{ -512, 832 },
	{ -192, 704 },
	{ -384, 992 }, 
	{ -384, 992 }, 
	{ -384, 992 }, 
	{ -384, 992 }, 
	{ 48, 576 },
	{ -256, 800 },
	{ 48, 848 },
	{ -192, 704 },
	{ 56, 840 },
	{ -384, 912 },
	{ -384, 912 },
	{ 48, 592 },
	{ 0, 0 },
	{ 0, 0 },
	{ -256, 800 },
	{ 3, 381 },
	{ 48, 848 }, 
	{ 48, 592 }, 
	{ -192, 704 },
	{ 56, 840 }, 
	{ 48, 576 },
	{ 48, 592 }, 
	{ -512, 832 }
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
	"Khan"
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
	Midler = 10,
	Dio = 11,
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
	standAction = 19
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
	"stand action"
}

-- creates a set similar to the java style collection
function createSet(list)
	local set = {}
	for _, l in ipairs(list) do 
		set[l] = true 
	end
	return set
end

local recordingKeys = createSet({
	"recording",
	"p1Recording",
	"p2Recording"
})

local moveDefinitions = {}
for i = 1, 22, 1 do
	moveDefinitions[i] = {}
end

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
		local literals = {['true'] = true, ['false'] = false, ['null'] = json.null}
		for lit_str, lit_val in pairs(literals) do
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
	p1.inputPlaybackFacing = 1
	p2.inputPlayback = {}
	p2.inputPlaybackFacing = 0
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
	f:write([[- They syntax for the inputs text is as follows:
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

- Directions assume the player 1 is on the left and facing right, while player 2 is on the right facing left. The inputs will be 
- flipped programaticaly if players swap sides so there is no need to rewrite your input for each side.

- To perform the input playback change one of the hotkeys in the menu to "Input playback" and press the hotkey


- Player 1 Start
P1

- Player 2 start
P2
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
	options.p1Recording = getParsedRecording(p1.recorded, p1.recordedFacing ~= 1)
	options.p2Recording = getParsedRecording(p2.recorded, p2.recordedFacing ~= 0)
	local settingsString = json.stringify(options)
	local _, err = f:write(settingsString)
	if err then
		menu.info = "Error saving settings"
	else
		menu.info = "Saved settings successfully"
	end
	f:close()
end

function getParsedRecording(recording, swap)
	if #recording == 0 then return {} end
	local strings = {}
	local count = 1
	local hex = swap and swapHexDirection(recording[1]) or recording[1]
	local previousHex = hex
	local str = hexToInputString(hex)
	for i = 2, #recording, 1 do
		hex = swap and swapHexDirection(recording[i]) or recording[i]
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
	local parsedOptions = json.parse(f:read("*all"))
	tableCopy(parsedOptions, options)
	p1.recorded = parseRecording(options.p1Recording)
	p1.recordedFacing = 1
	p2.recorded = parseRecording(options.p2Recording)
	p2.recordedFacing = 0
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
		for i = 1, 22, 1 do 
			successTable[i] = 0
		end
		options.trialSuccess[filename] = successTable
	end
	return true
end

function exportTrial()
	if not trial.export then
		menu.info = "No new trials to export"
		return
	end
	local backup =  "_backup_"..options.trialsFilename
	local success = os.rename(options.trialsFilename, backup)
	if not success then
		menu.info = "Error backing up to "..backup
		return
	end
	local f, err = io.open(options.trialsFilename, "w")
	if err then
		menu.info = "Error accessing "..options.trialsFilename
		return
	end
	local trialString = json.stringify(trials)
	local _, err = f:write(trialString)
	if err then
		menu.info = "Error exporting trial"
	else
		menu.info = "Trials exported successfully"
		trial.export = false
		os.remove(backup)
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

-------------------------------------------------
-- Memory Reader
-------------------------------------------------

function updateMemory()
	readSystemMemory()
	readPlayerMemory(p1)
	readPlayerMemory(p2)
	readProjectileMemory()
	
	inputTables.previous = inputTables.current
	inputTables.current = joypad.read() -- reads all inputs

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
	player.previousScaling = player.scaling
	player.previousWakeupCount = player.wakeupCount
	player.previousAirtechCount = player.airtechCount
	player.previousDefenseAction = player.defenseAction
	player.previousPushblockCount = player.pushblockCount
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
	--system.timeStopState = readByte(0x2033ABD)
	--system.screenZoom = 0
end

-------------------------------------------------
-- Inputs
-------------------------------------------------

function updateInput()
	p1.previousInputs = p1.inputs
	p1.inputs = getPlayerInputHex("P1 ")
	p2.previousInputs = p2.inputs
	p2.inputs = getPlayerInputHex("P2 ")
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

--Returns whether a key is pressed once
function pressed(key)
	return (not inputTables.previous[key] and inputTables.current[key])
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
	local value = inputTables.held[key]
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
	return inputTables.held[key] > x
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
function getPlayerInputHex(player)
	local hex = 0
	for k, v in pairs(inputDictionary) do
		if inputTables.current[player..v] then
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

-------------------------------------------------
-- Gameplay Loop
-------------------------------------------------

function updateGameplayLoop() --main loop for gameplay calculations
	updatePlayer(p1, p2)
	updatePlayer(p2, p1)
	writeByte(0x205CC1A, options.music and 0x80 or 0x00) -- Toggle music off or on

	if fcReplay then return end  -- Don't write if replay

	writeByte(0x20314B4, 0x63) -- Infinite Clock Time
	if options.infiniteRounds then
		writeByte(0x2034860, 0) -- Reset round to 0
	end
	if not options.ips then -- IPS
		writeByte(p1.memory.ips, 0x00)
	end
	if not options.tandemCooldown then
		writeByte(0x02034AC9, 0x00)
		writeByte(0x02034EE9, 0x00)
	end
	if options.boingo then
		writeDWord(0x020162E4, 0)
	end
	if options.level > 1 then
		writeByte(0x02033210, options.level - 2)
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
	if options.healthRefill and ((player.previousCombo > 0 or other.damage ~= 0) and (player.combo == 0)) then
		writeByte(other.memory.healthRefill, 0x90)
		other.damage = 0
	end

	--Meter refill
	if options.meterRefill then
		writeByte(player.memory.meterRefill, 0x680A)
	end

	--Stand refill 
	if options.standGaugeRefill and player.standHealth == 0 then
		writeByte(player.memory.standGaugeRefill, player.standGaugeMax)
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
	if system.screenFreeze == 0 then -- not screen frozen

		if player.wakeupCount > 0 then
			player.wakeupCount = player.wakeupCount - 1
			player.wakeupFrame = (player.wakeupCount == 1)
		end

		if player.guardCount > 0 then
			if player.hitFreeze > player.previousHitFreeze or player.stunCount < player.previousStunCount then
				updateGuardReversal(player)
			end
			player.guardCount = player.guardCount - 1
		end

		if player.hitCount > 0 then
			if player.hitFreeze > player.previousHitFreeze or player.stunCount < player.previousStunCount then
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
	-- Add 3 if a buffered motion
	if options.reversalReplay == 3 or options.reversalReplay == 5 or 
	   (options.reversalReplay == 1 and options.reversalMotion ~= 1) then
		player.guardCount = player.guardCount + 3
	end
end

function updateHitReversal(player)
	player.hitCount = player.hitFreeze + stunType[band(player.stunType, 0x0F)] + 5
end

-------------------------------------------------
-- Input Checker
-------------------------------------------------

function updateInputCheck()
	if fcReplay then return end
	checkPlayerInput(p1, p2)
	checkPlayerInput(p2, p1)
	if menu.state > 0 then
		updateMenu()
	end
end

local hotkeyFunctions = {
	record = function(player)
		record(player)
	end,
	recordParry = function(player, other)
		recordParry(player, other)
	end,
	replay = function(player)
		replaying(player)
	end,
	replayP2 = function(player, other)
		replayTransfer(player, other)
	end,
	inputPlayback = function(player, other)
		inputPlayback(player)
		inputPlayback(other)
	end,
	disabled = function() end
}

function checkPlayerInput(player, other)
	for _, v in pairs(player.buttons) do
		if inputTables.current[v] then
			inputTables.held[v] = inputTables.held[v] + 1
		else
			inputTables.held[v] = 0
		end
	end

	other.previousControl = other.control

	if pressed(player.buttons.coin) then
		openMenu()
	end

	if menu.state > 0 then 
		if pressed(player.buttons.mk) then
			writeByte(other.memory.standGaugeRefill, other.standGaugeMax)
		end

		if pressed(player.buttons.sk) then
			writeByte(player.memory.standGaugeRefill, player.standGaugeMax)
		end
		return
	end

	-- trial mode disables other inputs
	if trial.enabled then
		--Scroll inputs
		if trial.success then
			if pressed(player.buttons.start) then
				trialNext()
			end
		else
			if inputTables.current[player.buttons.start] then
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

	if inputTables.current[player.buttons.start] then --checks to see if P1 is holding start
		
		other.control = true

		if pressed(player.buttons.mk) then
			writeByte(other.memory.standGaugeRefill, other.standGaugeMax)
		end

		if pressed(player.buttons.sk) then
			writeByte(player.memory.standGaugeRefill, player.standGaugeMax)
		end
	else
		other.control = false
	end

	if pressed(player.buttons.mk) then
		hotkeyFunctions[options.mediumKickHotkey](player, other)
		
	elseif pressed(player.buttons.sk) then
		checkFinaliseRecording(player, options.strongKickHotkey) --todo if updating hotkeys
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

function checkFinaliseRecording(player, hotkey)
	if hotkey ~= "disabled" then
		if player.number == 1 and player.recording then
			trialFinaliseRecording()
		end
	end
end

function record(player)
	player.playbackCount = 0
	player.loop = false
	player.recording = not player.recording
	if player.recording then
		player.recorded = {}
		player.recordedFacing = player.facing
		if player.number == 1 then
			trialStartRecording()
		end
	else
		if player.number == 1 then
			trialFinaliseRecording()
		end
	end
end

function recordParry(player, other)
	if player.number == 2 then return end
	if player.recording then
		other.playbackCount = 0
		other.loop = false
		other.recording = false
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
	player.recording = false
	if player.playbackCount == 0 then
		player.playback = player.recorded
		player.playbackCount = #player.recorded
		player.playbackFacing = player.recordedFacing
		player.playbackFlipped = player.facing ~= player.recordedFacing
	else
		player.playbackCount = 0
	end
end

function replayTransfer(player, other)
	player.recording = false
	player.loop = false
	other.recording = false
	other.loop = false
	if other.playbackCount == 0 then
		other.playback = player.recorded
		other.playbackCount = #player.recorded
		other.playbackFacing = player.recordedFacing
		other.playbackFlipped = other.facing ~= player.recordedFacing
	else
		other.playbackCount = 0
	end
end

function inputPlayback(player)
	player.recording = false
	player.loop = false
	if player.playbackCount == 0 then
		readInputsFile()
		player.playback = player.inputPlayback
		player.playbackCount = #player.inputPlayback
		player.playbackFacing = player.inputPlaybackFacing
		player.playbackFlipped = player.facing ~= player.inputPlaybackFacing
	else
		player.playbackCount = 0
	end
end

-------------------------------------------------
-- Character Control
-------------------------------------------------

function updateCharacterControl()
	if fcReplay then return end
	if menu.state > 0 then return end

	inputTables.overwrite = {}

	controlPlayers()
	controlPlayer(p1, p2)
	controlPlayer(p2, p1)

	if next(inputTables.overwrite) ~= nil then --empty table
		joypad.set(inputTables.overwrite)
	end
end

function controlPlayers()
	if system.parry > 0 then
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
	-- recording
	if player.recording then
		table.insert(player.recorded, player.inputs)
		if player.number == 1 then
			updateTrialRecording()
		end
	end
	-- Direction Lock
	if player.previousControl and not player.control then
		player.directionLock = band(other.inputs, 0x0F) 
		player.directionLockFacing = player.facing
	end
	-- Player 2 menu option controls
	if player.number == 2 and player.playbackCount == 0 then
		-- Guard Action
		if options.guardAction > 1 and canGuardAction(player) then
			--Push block
			if options.guardAction == 2 then
				pushBlock(player)
			-- Guard Cancel
			elseif options.guardAction == 3 then
				guardCancel(player)
			end
			player.blocking = false
		-- Air Tech
		elseif options.airTech and player.airtech then
			airTech(player, other)
		--Perfect Air Tech 
		elseif options.perfectAirTech and canPerfectAirTech(player) then
			airTech(player, other, true)
		-- Throw tech
		elseif options.throwTech and player.throwTech > 0 then
			throwTech(player)
		end
		-- Reversals
		if options.forceStand > 1 and canReversal(player) and canStand(player) then
			setPlayback(player, { 0x80 })
			writeByte(player.memory.standGaugeRefill, player.standGaugeMax)
		else
			if options.wakeupReversal and player.wakeupCount > 0 then
				doReversal(player, other, player.wakeupCount)
			end
			if options.guardReversal then
				if player.guardCount > 0 then
					doReversal(player, other, player.guardCount)
				end
				if player.pushblockCount > 0 then
					doReversal(player, other, player.pushblockCount)
				end
			end
			if options.hitReversal then
				 if player.hitCount > 0 then
					doReversal(player, other, player.hitCount)
				end
				if player.airtechCount > 0 then
					doReversal(player, other, player.airtechCount)
				end
			end
		end
	end
	-- Input Playback
	if player.playbackCount > 0 then
		local hex =  player.playback[#player.playback - player.playbackCount + 1]
		hex = (player.playbackFlipped and swapHexDirection(hex) or hex)
		local inputs = hexToPlayerInput(hex, player.name)
		tableCopy(inputs, inputTables.overwrite)
		player.playbackCount = player.playbackCount - 1
		if player.playbackCount == 0 then
			if player.loop then
				player.playbackFlipped = player.facing ~= player.playbackFacing
				player.playbackCount = #player.playback
			end
			if player.recordParry then
				player.recordParry = false
			end
			--todo
			-- if trial.enabled then
			-- 	trialModeStart()
			-- end
		end
	-- Player control
	elseif player.control then
		local inputs = hexToPlayerInput(other.inputs, player.name)
		tableCopy(inputs, inputTables.overwrite)
	-- Direction Lock
	elseif player.directionLock ~= 0 then
		local direction = (player.facing == player.directionLockFacing and player.directionLock or swapHexDirection(player.directionLock))
		local inputs = hexToPlayerInput(direction, player.name)
		tableCopy(inputs, inputTables.overwrite)
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

function airTech(player, other, perfect)
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
			player.airtechCount = #getReversal(player, other) + 1
		elseif direction == 1 and player.stand == 0 then
			player.airTechCount = 4
		else
			player.airtechCount = 11
		end
	end
	if not perfect then
		insertDelay(inputs, options.airTechDelay, 0)
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
end

function guardCancel(player)
	local inputs = (player.facing == 1 and { 0x08, 0x02, 0x1A } or { 0x04, 0x02, 0x16 })
	insertDelay(inputs, options.guardActionDelay, band(player.inputs, 0x0F))
	setPlayback(player, inputs)
	player.guardCount = 0
	--player.reversalCount = 15 Jotaro s.off
end

function throwTech(player)
	setPlayback(player, { 0x44 })
end

function getReversal(player, other)
	local inputs
	local button = reversal.buttons[options.reversalButton]
	if options.reversalReplay ~= 1 then
		if options.reversalReplay == 2 or options.reversalReplay == 3 then --Replay
			local recordedPlayer = (options.strongKickHotkey == "replayP2" and other or player)
			inputs = duplicateList(recordedPlayer.recorded, true, true)
			player.playbackFacing = recordedPlayer.recordedFacing
			if player.y > 0 then
				player.playbackFlipped = player.facing ~= recordedPlayer.recordedFacing
			else
				player.playbackFlipped = other.facing == recordedPlayer.recordedFacing
			end
		elseif options.reversalReplay == 4 or options.reversalReplay == 5 then --Inputs.txt
			readInputsFile()
			inputs = duplicateList(player.inputPlayback, true, true)
			player.playbackFacing = player.inputPlaybackFacing
			if player.y > 0 then
				player.playbackFlipped = player.facing ~= player.inputPlaybackFacing
			else
				player.playbackFlipped = other.facing == player.inputPlaybackFacing
			end
		end
	elseif options.reversalMotion ~= 1 then
		inputs = duplicateList(reversal.motions[options.reversalMotion], true, true);
		inputs[#inputs + 1] = bor(inputs[#inputs], button)
	else 
		inputs = { bor(reversal.directions[options.reversalDirection], button) }
	end
	return inputs
end

function doReversal(player, other, count)
	local inputs = getReversal(player, other)
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
		-- If on the ground use the other players facing because they might be flipped during the combo
		if player.y > 0 then
			player.playbackFlipped = player.facing ~= 1
		else
			player.playbackFlipped = other.facing == 1 
		end
	end
	if reversalIndex < 1 or reversalIndex > #inputs then
		return
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

function canAct(player)
	return player.canAct1 == 0 and player.canAct2 == 0
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
		if trial.enabled then
			menu.state = 6
		else
			menu.state = 1
			menu.title = "Training Menu"
			menu.index = 1
			menu.options = rootOptions
			updateMenuInfo()
			--update child options
			options.p1Child = readByte(p1.memory.child) == 0xFF
			options.p2Child = readByte(p2.memory.child) == 0xFF
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
	elseif repeating(p1.buttons.up) then
		menuUp()
	elseif repeating(p1.buttons.down) then
		menuDown()
	elseif repeating(p1.buttons.left) then
		menuLeft()
	elseif repeating(p1.buttons.right) then
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
	elseif option.type == optionType.bool then
		options[option.key] = not options[option.key]
	elseif option.type == optionType.func then
		option.func()
	elseif option.type == optionType.back then
		menuCancel()
	elseif option.type == optionType.info then
		menu.state = 3
		menu.previousIndex = menu.index
		menu.index = 1
		menu.options = infoOptions
		menu.title = option.name
		menu.info = option.infos
	elseif option.type == optionType.color then
		menu.color = option.key
		menu.state = 4
		menu.previousSubIndex = menu.index
		menu.index = 1
		menu.options = colorSliderOptions
		menu.title = "Color Picker"
		menu.default = option.default
	elseif option.type == optionType.trialCharacters then
		if #trials == 0 then
			menu.info = "No trials jsons found"
		else
			menu.state = 5
			menu.options = getTrialCharacterOptions()
			menu.previousIndex = menu.index
			menu.index = charToIndex[p1.character]
			menu.title = "Combo Trials"
		end
	elseif option.type == optionType.trialCharacter then
		menu.state = 6
		menu.options = getTrialOptions(menu.index, option)
		menu.previousSubIndex = menu.index
		menu.index = 1
		menu.title = option.name
		updateMenuTrial()
	elseif option.type == optionType.trial then
		menuClose()
	elseif option.type == optionType.files then
		local fileOptions = getFileOptions()
		if #fileOptions == 0 then
			menu.info = "No trials jsons found"
		else
			menu.options = fileOptions
			menu.state = 7
			menu.previousSubIndex = menu.index
			menu.index = 1
			menu.title = "Trial Select"
		end
	elseif option.type == optionType.file then
		readTrial(option.name)
		writeSettings()
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
	elseif menu.state == 6 then -- trials 
		menu.state = 5
		menu.index = menu.previousSubIndex
		menu.options = getTrialCharacterOptions()
		menu.title = "Combo Trials"
		trialModeStop()
	elseif menu.state == 7 then -- files
		menu.state = 2
		menu.index = menu.previousSubIndex
		menu.options = trialOptions
		menu.title = "Trial Options"
		updateMenuInfo()
	elseif menu.state > 1 then -- sub menu
		menu.state = 1
		menu.index = menu.previousIndex
		menu.options = rootOptions
		menu.title = "Training Menu"
		updateMenuInfo()
	end
end

function menuClose()
	menu.state = 0
	gui.clearuncommitted()
	writeByte(0x20713A3, 0xFF) -- Bit mask that enables player input
	--update child options
	updateChild(p1, options.p1Child, 0x020348D5)
	updateChild(p2, options.p2Child, 0x02034CF5)
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
	elseif option.type == optionType.int then
		options[option.key] = (value == option.min and option.max or value - 1)
	elseif option.type == optionType.list then
		options[option.key] = (value == 1 and #option.list or value - 1)
		optionUpdated(option.key)
	elseif option.type == optionType.slider then
		local inc = (heldTable(selectInputs, 1) and 10 or 1)
		local value = getMenuColor(option.mask, option.shift)
		if (value - inc < 0) then 
			inc = value
		end
		options[menu.color] = options[menu.color] - lShift(inc, option.shift)
	elseif option.type == optionType.key then
		local index = tableIndex(option.list, value)
		options[option.key] = option.list[index == 1 and #option.list or index - 1]
	elseif option.type == optionType.trialCharacter then
		if menu.index ~= 23 then
			menu.index = math.floor(menu.index % 2) == 0 and menu.index - 1 or menu.index + 1
		end
	elseif option.type == optionType.trial then
		if menu.index % 12 == 1 then
			if #menu.options < 14 or menu.index == 13 then
				menu.index = #menu.options - 1
			else
				menu.index = 12
			end
		else
			menu.index = menu.index - 1
		end
		updateMenuTrial()
	end
end

function menuRight()
	local option = menu.options[menu.index]
	local value = options[option.key]
	if option.type == optionType.bool then
		options[option.key] = not value
	elseif option.type == optionType.int then
		options[option.key] = (value >= option.max and option.min or value + 1)
	elseif option.type == optionType.list then
		options[option.key] = (value >= #option.list and 1 or value + 1)
		optionUpdated(option.key)
	elseif option.type == optionType.slider then
		local inc = (heldTable(selectInputs, 1) and 10 or 1)
		local value = getMenuColor(option.mask, option.shift)
		if (value + inc > 255) then
			inc = 255 - value
		end
		options[menu.color] = options[menu.color] + lShift(inc, option.shift)
	elseif option.type == optionType.key then
		local index = tableIndex(option.list, value)
		options[option.key] = option.list[index >= #option.list and 1 or index + 1]
	elseif option.type == optionType.trialCharacter then
		if menu.index ~= 23 then
			menu.index = math.floor(menu.index % 2) == 0 and menu.index - 1 or menu.index + 1
		end
	elseif option.type == optionType.trial then
		if menu.index == #menu.options - 1 then
			menu.index = menu.index > 12 and 13 or 1
		elseif menu.index % 12 == 0 then
			menu.index = menu.index - 11
		else
			menu.index = menu.index + 1
		end
		updateMenuTrial()
	end
end

function menuUp()
	if menu.state == 3 then --about
		return
	elseif menu.state == 5 then --trials characters
		if menu.index == 1 then
			menu.index = 21
		elseif menu.index == 2 then
			menu.index = 23
		elseif menu.index == 23 then
			menu.index = 22
		else
			menu.index = menu.index - 2
		end
	elseif menu.state == 6 then --trials
		if menu.index == #menu.options then
			menu.index = #menu.options > 1 and #menu.options - 1 or 1
		elseif menu.index < 13 then
			menu.index = #menu.options
		else
			menu.index = menu.index - 12
		end
		updateMenuTrial()
	else
		menu.index = (menu.index == 1 and #menu.options or menu.index - 1)
		updateMenuInfo()
	end
end

function menuDown()
	if menu.state == 3 then --about
		return
	elseif menu.state == 5 then --trials characters
		if menu.index == 21 then
			menu.index = 1
		elseif menu.index == 22 then
			menu.index = 23
		elseif menu.index == 23 then
			menu.index = 2
		else
			menu.index = menu.index + 2
		end
	elseif menu.state == 6 then --trials
		if menu.index < 13 and #menu.options > 13 then
			menu.index = math.min(menu.index + 12, #menu.options - 1)
		elseif menu.index == #menu.options then
			menu.index = 1
		else
			menu.index = #menu.options
		end
		updateMenuTrial()
	else
		menu.index = (menu.index >= #menu.options and 1 or menu.index + 1)
		updateMenuInfo()
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
end

function getTrialCharacterOptions()
	local optionsTable = {}
	for i = 1, 22, 1 do
		optionsTable[i] = {
			name = indexToName[i],
			type = optionType.trialCharacter,
			completed = trialCompletedCount(i)
		}
	end
	optionsTable[#optionsTable + 1] = {
		name = "Return",
		type = optionType.back
	}
	return optionsTable
end

function trialCompletedCount(index)
	local success = options.trialSuccess[options.trialsFilename][index]
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
	local success = options.trialSuccess[options.trialsFilename][index]
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

function optionUpdated(key)
	if key == "inputStyle" then
		clearInputHistory(p1)
		clearInputHistory(p2)
	end
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
	end
	updateTrialCheck(false)
end

function updateTrialCheck(tailCall)
	local input = trial.combo[trial.index]
	if p2.wakeupFrame and not tailCall then
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
	end
end

function trialStarted()
	return (trial.drill and trial.drillSuccess > 0) or not (trial.index == 1 and trial.subIndex == 1)
end

function checkTandemInput(id)
	local address = 0x02032174 + (p1.tandemCount - 1) * 6
	local ids = readByteRange(address, 3)
	if #id == 10 then
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
	if p2.guarding > 0 and p2.previousGuarding == 0 then 
		return false
	end
	if p2.hitstun == 3 then 
		return true 
	end
	if p2.wakeupFrame then 
		return false
	end
	if p2.y > 0 then
		if p2.previousHitstun > 0 and p2.hitstun == 0 then 
			return false 
		end
	else
		if p2.defenseAction > 26 then 
			return true
		elseif p1.character == 0x04 and input.id == 70 then
			if p2.previousHitstun > 0 and p2.hitstun == 0 then
				return false
			end
		elseif p2.hitCount == 2 then 
			return false
		end
	end
	return true
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

	if trial.trial.drill then 
		trial.drill = trial.trial.drill
		trial.drillSuccess = 0
	else
		trial.drill = false
	end

	writeByte(p1.memory.standGaugeRefill, p1.standGaugeMax)
	writeByte(p2.memory.standGaugeRefill, p2.standGaugeMax)
	
	if not trial.enabled then
		storeOptions()
	end
	trial.enabled = true
	updateOptions()
end

function trialModeStop()
	if not trial.enabled then return end
	retrieveOptions()
	system.parry = 0
	trial.enabled = false
end

function storeOptions() 
	menu.previousOptions = {}
	tableCopy(options, menu.previousOptions)
end

function updateOptions()
	if trial.trial.ips ~= nil then
		options.ips = trial.ips
	end
	if trial.trial.tandemCooldown ~= nil then
		options.tandemCooldown = trial.trial.tandemCooldown
	end
	if trial.trial.direction ~= nil then
		p2.directionLock = trial.trial.direction
		p2.directionLockFacing = 1
	end
	if trial.trial.rng ~= nil then
		writeDWord(0x020162E4, trial.trial.rng)
	end
	if trial.trial.meter ~= nil then
		local meterType = type(trial.trial.meter)
		if meterType == "number" then
			options.meterRefill = false
			writeByte(p1.memory.meterRefill, trial.trial.meter)
		elseif meterType == "boolean" then
			options.meterRefill = trial.trial.meter
		end
	else
		options.meterRefill = true
	end
	if trial.trial.standGauge ~= nil then
		options.standGaugeRefill = trial.trial.standGauge
	else
		options.standGaugeRefill = true
	end
	if trial.trial.p1 then
		if trial.trial.p1.child ~= nil then
			options.p1Child = trial.trial.p1.child
		else
			options.p1Child = false
		end
		updateChild(p1, options.p1Child, 0x020348D5)
		if p1.character == 0x16 then -- mariah
			writeByte(0x02033210, trial.trial.p1.level or 0)
		end
	end
	if trial.trial.p2 then
		if trial.trial.p2.child ~= nil then
			options.p2Child = trial.trial.p2.child
		else
			options.p2Child = false
		end
		updateChild(p2, trial.trial.p2.child, 0x02034CF5)
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
	options.healthRefill = true
	options.level = 1
	options.inputStyle = 1
	options.infiniteRounds = true
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
	local value = bor(trialSuccess[menu.previousSubIndex], lShift(1, trial.id - 1))
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
			child = p1.child == 0xFF
		},
		p2 = {
			character = p2.character,
			x = p2.x,
			y = p2.y,
			stand = p2.stand,
			standX = p2.standX,
			standY = p2.standY,
			facing = p2.facing,
			child = p2.child == 0xFF
		},
		stage = {
			id = system.stageId,
			x = system.screenX,
			y = system.screenY
		},
		combo = {},
		direction = p2.directionLockFacing == 1 and p2.directionLock or swapHexDirection(p2.directionLock),
		rng = readDWord(0x020162E4),
		position = false
	}
	if not options.meterRefill then
		recording.meter = readByte(p1.memory.meterRefill)
	end
	if not options.standGaugeRefill then
		recording.standGauge = false
	end
	if p1.character == 0x16 then -- mariah
		recording.p1.level = readByte(0x02033210)
	end
	if options.mediumKickHotkey == "recordParry" then
		recording.parry = true
	end
	trial.recording = recording
	trial.recordingSubIndex = 1
	trial.recordingFacing = p1.facing
end

function updateTrialRecording()
	local combo = trial.recording.combo
	local attackId = getAttackId()
	if attackId ~= -1 then
		local move = moveDefinitions[charToIndex[p1.character]][attackId]
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
	elseif system.previousTimeStop > 0 and system.timestop == 0 then
		combo[#combo + 1] = {
			name = "(Time Stop End)",
			type = comboType.timeStopEnd
		}
	end
end

function trialFinaliseRecording()
	local hexes = duplicateList(p1.recorded, true, false)
	if #hexes == 0 then return end
	local swap = trial.recording.p1.facing ~= 1
	trial.recording.recording = getParsedRecording(hexes, swap)
end

function trialRecordingSave()
	if not trial.recording then
		menu.info = "No recording found!"
	elseif #trial.recording.combo == 0 then
		menu.info = "No combo found!"
	elseif menu.info ~= "Recording added to trials!" then -- Prevent accidental duplication
		local charTrials = trials[charToIndex[trial.recording.p1.character]].trials
		charTrials[#charTrials + 1] = trial.recording
		menu.info = "Recording added to trials!"
		trial.export = true
	end
end

function trialReset()
	if trialPlayback() then
		trialForceStop()
	else
		trialModeStart()
		trial.reset = true
	end
end

function updateTrialReset()
	--update stand
	if updateTrialStand() then
		return
	end

	--update position
	if trial.trial.position then
		if updateTrialPosition() then
			trial.wait = 1
			return
		end
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
	else
		trialStartReplay()
	end
	trial.replay = false
end

function updateTrialParry()
	if trial.wait > 0 then
		trial.wait = trial.wait - 1
		return
	end

	if updateTrialStand() then
		return
	end

	if trial.parryDelay then
		trial.parryDelay = false
		trial.wait = 40
		return
	end

	system.parry = 1
end

function trialStartReplay()
	p1.playback = trial.recorded
	p1.playbackCount = #trial.recorded
	p1.playbackFacing = 1
	p1.playbackFlipped = p1.facing ~= 1
end

function trialPlayback()
	return trial.reset or trial.replay or p1.playbackCount > 0 or p2.playbackCount > 0
end

function updateTrialStand()
	return updateTrialPlayerStand(p1, trial.trial.p1.stand) or updateTrialPlayerStand(p2, trial.trial.p2.stand)
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
	local p1x, p1sx, p2x, p2sx
	local updated = false
	-- position difference between p1, p2 and stands
	local p1sd = math.abs(trial.trial.p1.x - trial.trial.p1.standX)
	local p2d = math.abs(trial.trial.p1.x - trial.trial.p2.x)
	local p2sd = math.abs(trial.trial.p1.x - trial.trial.p2.standX)
	-- borders of stage and recorded stage
	local sx = stageBorder[system.stageId + 1][1]
	local sx2 = stageBorder[system.stageId + 1][2]
	local rx = stageBorder[trial.trial.stage.id + 1][1]
	local rx2 = stageBorder[trial.trial.stage.id + 1][2]
	-- update position relative to the border you are facing towards
	if trial.trial.p1.facing == 1 then
		-- relative distance from right border
		p1x = sx2 - (rx2 - trial.trial.p1.x)
		-- if the relative distance is outside of current stage bounds 
		if p1x < sx then
			-- hug left border
			p1x = sx
		end
		-- update position relative to player 1
		p1sx = p1x + p1sd
		p2x = p1x + p2d
		p2sx = p1x + p2sd
	else
		-- relative distance from left border
		p1x = sx + (trial.trial.p1.x - rx)
		-- if the relative distance is outside of current stage bounds 
		if p1x > sx2 then
			-- hug right border
			p1x = sx2
		end
		--update position relative to player 1
		p1sx = p1x - p1sd
		p2x = p1x - p2d
		p2sx = p1x - p2sd
	end
	-- update positions of player and stand
	writeWord(p1.facing, trial.trial.p1.facing)
	writeWord(p2.facing, trial.trial.p2.facing)
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
	-- return whether updated or not
	return updated
end

function trialMenuClose()
	updateTrialStand()
end

function trialForceStop()
	trialModeStart()
	p1.playbackCount = 0
	p2.playbackCount = 0
	system.parry = 0
	trial.parryReplay = false
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
end

function clearTrialOptions()
	local successTable = options.trialSuccess[options.trialsFilename]
	for i = 1, 22, 1 do 
		successTable[i] = 0
	end
	menu.info = "Trial completion reset!"
end

-- Cleans up the trial table. Swaps strings for ints
function sanitizeTrials()
	for i = 1, #trials, 1 do
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
	
	if (p1.recording) then
		gui.text(152,32,"Recording", options.failColor)
	elseif (p1.playbackCount > 0) then
		gui.text(152,32,"Replaying", options.failColor)
	end

	if (p2.recording) then
		gui.text(200,32,"Recording", options.failColor)
	elseif (p2.playbackCount > 0) then
		gui.text(200,32,"Replaying", options.failColor)
	end

	if menu.state == 0 then
		if options.guiStyle == 3 then
			drawAdvancedHud()
		elseif options.guiStyle == 4 then
			drawMeatyHud()
		elseif options.guiStyle == 5 then
			drawTrialDebugHud()
		end
	end

	if trial.enabled then
		drawTrialGui()
	end

	if debug then
		drawDebug(180, 30)
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
	if p1.previousIps == 0 or not options.ips then --It flickers on and off if you don't check the menu option
		guiTextAlignRight(236, 64, "OFF", options.failColor)
	else
		guiTextAlignRight(236, 64, "ON", options.successColor)
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
	gui.box(90, 36, 294, 208, colors.menuBackground, colors.menuBorder)
	gui.text(110, 42, menu.title, colors.menuTitle)
	if menu.state == 3 then --info
		drawInfo()
	elseif menu.state == 5 then --trials characters
		drawTrialsCharacters()
	elseif menu.state == 6 then --trials
		drawTrials()
	elseif menu.state == 7 then --files
		drawFileList()
	else
		drawList()
	end
end

function drawList()
	for i = 1, #menu.options, 1 do
		local color = (menu.index == i and menu.flashColor or colors.menuUnselected)
		local option = menu.options[i]
		gui.text(100, 48 + i * 12, option.name, color)
		if option.type == optionType.bool then
			local word = options[option.key] and "Enabled" or "Disabled"
			gui.text(200, 48 + i * 12, word, color)
		elseif option.type == optionType.int then
			local number = options[option.key]
			gui.text(200, 48 + i * 12, number, color)
		elseif option.type == optionType.list then
			local word = option.list[options[option.key]]
			gui.text(200, 48 + i * 12, word, color)
		elseif option.type == optionType.slider then
			local value = getMenuColor(option.mask, option.shift)
			gui.text(150, 48 + i * 12, value, color)
		elseif option.type == optionType.key then
			local word = option.names[options[option.key]]
			gui.text(200, 48 + i * 12, word, color)
		end
	end
	if menu.state == 4 then
		local color = bor(options[menu.color], 0xFF)
		gui.box(200, 60, 240, 100, color, color)
		gui.text(186, 112, "Hold A to increase by 10", colors.menuTitle)
	end
	gui.text(110, 196, menu.info, colors.menuTitle)
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
		p2.hitstun.." hitstun",
		readByte(0x02034D61).." hitstun2",
		p2.y.." p2 y",
		p2.defenseAction.." p2 defense action",
		projectiles[1].attackId.." proj attack id",
		projectiles[1].attackHit.." proj hit",
		system.screenX.." screen x",
		p1.x.." p1 x",
		p2.x.." p2 x",
	}
	for i = 1, #debugInfo, 1 do
		gui.text(x, y + 8 * i, debugInfo[i])
	end
end

function drawTrialsCharacters()
	for i = 1, #menu.options - 1, 1 do
		local option = menu.options[i]
		local color = (menu.index == i) and menu.flashColor or colors.menuUnselected
		local x = 100 + ((i - 1) % 2) * 100
		local y = 60 + math.floor((i - 1) / 2) * 12
		gui.text(x, y, option.name, color)
		guiTextAlignRight(x + 86, y, option.completed.."/"..#trials[i].trials, color)
	end
	local color = (menu.index == 23) and menu.flashColor or colors.menuUnselected
	gui.text(200, 192, "Return", color)
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
		gui.text(202, 40, "Not in Use 1: Restart")
		gui.text(202, 50, "Not in Use 2: Replay")
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
	gui.text(200, 192, "Return", color)
end

function drawTrialGui()
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
	drawFixedInput(p1.inputHistoryTable[1], 175, 216)
end

function drawFileList()
	for i = 1, #menu.options, 1 do
		local option = menu.options[i]
		local color = menu.index == i and menu.flashColor or 
			options.trialsFilename == option.name and options.failColor or colors.menuUnselected
		gui.text(100, 50 + i * 10, option.name, color)
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
		options.guiStyle = (options.guiStyle == 5) and 1 or options.guiStyle + 1
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
	options.healthRefill = false
	options.meterRefill = false
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
	resetReversalOptions()
end

function updateSettings() -- updates old settings to new
	if type(options.mediumKickHotkey) == "number" then
		options.mediumKickHotkey = "record"
	end
	if type(options.strongKickHotkey) == "number" then
		options.strongKickHotkey = "replay"
	end
end

emu.registerstart(function()
	writeByte(0x20713A8, 0x09) -- Infinite Credits
	writeByte(0x20312C1, 0x01) -- Unlock all characters
	writeByte(0x20713A3, 0xFF) -- Bit mask that enables player input
	readSettings()
	updateSettings()
	readTrials()
	readMoveDefinitions()
	createInputsFile()
	clearInputHistory(p1)
	clearInputHistory(p2)
	if fcReplay then 
		replayOptions()
	end
end)

gui.register(function()
	guiWriter()
end)

emu.registerexit(function()
	gui.clearuncommitted()
	writeByte(0x20713A3, 0xFF) -- Bit mask that enables player input
end)

-------------------------------------------------
-- Main Loop
-------------------------------------------------

while true do 
	updateMemory()
	updateGameplayLoop()
	updateInput()
	updateInputCheck()
	updateCharacterControl()
	updateTrial()
	updateHitboxes()
	emu.frameadvance()
end