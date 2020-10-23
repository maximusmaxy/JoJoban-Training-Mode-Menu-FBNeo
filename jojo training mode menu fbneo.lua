-------------------
-- CONFIGURATION --
-------------------

-- The available built in colors are: 
-- "clear", "red", "green", "blue", "white", "black", "gray", "grey", "orange", "yellow", "green", "teal", "cyan", "purple" and "magenta"
-- You can create your own colors using the rgb(a) format by replacing "#" with "0x" eg. teal or #008080 would be written as 0x008080
-- The last two characters are for transparency eg. 80 = half transparency and FF = opaque 
-- A half transparent teal would be written as 0x00808080

local colors = {
	menuBackgroundColor = 0xAAAAAAFF,
	menuTitleColor = "grey",
	menuSelectedColor = "green",
	menuUnselectedColor = "red",
}

-- Toggleable hud locations for input history

local hud = {
	scrollFromBottom = true, -- Toggles hud.scrolling the input history upwards or downwards
	xP1 = 13, -- X Position of the first frame of P1's input history.
	yP1 = 200, -- Y Position of the first frame of P1's input history. 207 and 70 are recommended for hud.scrolling from the bottom and top respectively.
	xP2 = 337, -- X Position of the first frame of P2's input history.
	yP2 = 200, -- Y Position of the first frame of P2's input history. 207 and 70 are recommended for hud.scrolling from the bottom and top respectively.
	offset = 3
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
	guiStyle = 2,
	forceStand = 1,
	ips = true,
	perfectAirTech = false,
	reversal = 1,
	throwTech = false,
	hitboxes = 1,
	hitboxColor = 0xFF000000,
	hurtboxColor = 0x0040FF00,
	collisionboxColor = 0x00FF0000,
	orangeboxColor = 0xFF800000,
	comboCounterActiveColor = 0x0000FFFF, -- Colour of the combo counter if the combo hasn't dropped
	inputHistoryA = 0x00FF00FF, -- Colour of the letter A in the input history
	inputHistoryB = 0x0000FFFF, -- Colour of the letter B in the input history
	inputHistoryC = 0xFF0000FF, -- Colour of the letter C in the input history
	inputHistoryS = 0xFFFF00FF -- Colour of the letter S in the input history
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
--This script is not compressed or written efficiently as it is layed out to promote legibility.

print()
print("Commands List")
print()
print("Coin to open up the menu.")
print("Hold start control your opponent.")
print("Special functions are bound to Not In Use 1 and 2. The functions can be reassigned in the menu.")
print("Holding down replay button will make it loop.")
print("Pressing MK on the menu will restore p2 stand gauge")
print("Pressing HK on the menu will restore p1 stand gauge")

local fcReplay = false --Determines whether it's a fightcade replay or not

-- Aliasing memory and bitwise functions
local readByte = memory.readbyte
local readByteSigned = memory.readbytesigned
local readWord = memory.readword
local readWordSigned = memory.readwordsigned
local writeByte = memory.writebyte
local writeWord = memory.writeword
local writeWordSigned = memory.writewordsigned

local lShift = bit.lshift
local rShift = bit.rshift
local band = bit.band
local bor = bit.bor
local bxor = bit.bxor

local optionType = {
	subMenu = 1,
	bool = 2,
	int = 3,
	list = 4,
	func = 5,
	info = 6,
	color = 7,
	slider = 8,
	back = 9
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
		name = "Gui Style:",
		key = "guiStyle",
		type = optionType.list,
		list = {
			"None",
			"Simple",
			"Advanced",
			"P1 + P2"
		}
	},
	{
		name = "Not In Use 1 Hotkey:",
		key = "mediumKickHotkey",
		type = optionType.list,
		list = {
			"Record"
		}
	},
	{
		name = "Not In Use 2 Hotkey:",
		key = "strongKickHotkey",
		type = optionType.list,
		list = {
			"Replay",
			"Replay P2",
			"Input playback"
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
		name = "IPS:",
		key = "ips",
		type = optionType.bool
	},
	{
		name = "Return",
		type = optionType.back
	},

}

local enemyOptions = {
	{
		name = "Guard Action",
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
		name = "O Frame Air Tech",
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
		name = "Reversal:",
		key = "reversal",
		type = optionType.list,
		list = {
			"None",
			"A",
			"B",
			"C",
			"S",
			"A+B+C",
			"Recording",
			"Input playback"
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
		name = "Orangebox Color",
		key = "orangeboxColor",
		type = optionType.color,
		default = 0xFF800000
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
		name = "Color Settings",
		type = optionType.subMenu,
		options = colorOptions
	},
	{
		name = "Save Settings",
		type = optionType.func,
		func = function() writeSettings() end
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
	default = nil
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
	hitstun = false,
	previousHitstun = false,
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
	buttons = {},
	memory = nil,
	memory2 = nil
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

-- Sets the table for use
for i = 1, 13, 1 do 
	p1.inputHistoryTable[i] = 0
	p2.inputHistoryTable[i] = 0
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
	standGaugeMax = 0x00000000,
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
	standActive = 0x02034A20
}

p1.memory2 = {
	hitbox = 0x02034938, --AC
	standHitbox = 0x2035178,
	x = 0x20348E8,
	y = 0x20348EC,
	standX = 0x2035128,
	standY = 0x203512C
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
	standActive = 0x02034E40
}

p2.memory2 = {
	hitbox = 0x02034D58,
	standHitbox = 0x02035598,
	x = 0x2034D08,
	y = 0x2034D0C,
	standX = 0x2035548,
	standY = 0x203554C,
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

hud.scroll = hud.scrollFromBottom and 1 or -1
hud.frameAdvantage = 0

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
	error("This script is only intended for FBA-rr and MAME-rr.", 0)
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

local input = {
	current = {},
	previous = {},
	held = {},
	overwrite = {}
}

local characters = {
	jotaro = 0x00,
	kakyoin = 0x01,
	avdol = 0x02,
	polnaref = 0x03,
	joseph = 0x04,
	iggy = 0x05,
	alessy = 0x06,
	chaka = 0x07,
	devo = 0x08,
	nDoul = 0x09,
	midler = 0x0A,
	dio = 0x0B,
	vanillaIce = 0x0C,
	death13 = 0x0D,
	shadowDio = 0x0E,
	youngJoseph = 0x0F,
	holHorse = 0x10,
	iced = 0x11,
	newKakyoin = 0x12,
	blackPolnareff = 0x13,
	petshop = 0x14,
	mariah = 0x15,
	hoingo = 0x16,
	rubberSoul = 0x17,
	khan = 0x18
}

local gcStartup = { --Default is 10, 10
	[characters.avdol] = {9, 9},
	[characters.iggy] = {11, 11},
	[characters.jotaro] = {8, 10},
	[characters.joseph] = {15, 10},
	[characters.petshop] = {12, 12},
	[characters.rubberSoul] = {5, 5},
	[characters.youngJoseph] = {13, 13}
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
		input.held[v] = 0
	end
end

initButtons(p1)
initButtons(p2)

local boxCache = {
	{ {}, {}, {} },
	{ {}, {}, {} },
}

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

-- Reads a file and returns the contents
function readFile(name)
	local f, err = io.open(name, "r")
	if err then
		return nil
	end
	local contents = f:read("*all")
	f:close()
	return contents
end

--Returns whether a key is pressed once
function pressed(key)
	return (not input.previous[key] and input.current[key])
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
	local value = input.held[key]
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
	return input.held[key] > x
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

--Copies values from one table to another
function tableCopy(source, dest) 
	for k, v in pairs(source) do
		dest[k] = v
	end
end

--Saves settings to menu settings.txt
function writeSettings()
	local f, err = io.open("menu settings.txt", "w")
	if err then 
		print("Could not save settings to \"menu settings.txt\"")
		return 
	end
	local strings = {}
	for k, v in pairs(options) do
		table.insert(strings, k:upper().." = "..tostring(v))
	end
	table.insert(strings, "P1")
	insertPlayerRecording(strings, p1, 1)
	table.insert(strings, "P2")
	insertPlayerRecording(strings, p2, 0)
	local _, err = f:write(table.concat(strings, "\n"))
	if err then
		menu.info = "Error saving settings"
	else
		menu.info = "Saved settings successfully"
	end
	f:close()
end

function insertPlayerRecording(strings, player, facing)
	if #player.recorded == 0 then return end
	local previousHex = player.recorded[1]
	local hex = previousHex
	local count = 1
	local str = hexToInputString(hex)
	for i = 2, #player.recorded, 1 do
		hex =  player.recorded[i] 
		hex = (facing == player.recordedFacing and hex or swapHexDirection(hex))
		if hex == previousHex then
			count = count + 1
		else
			str = str..tostring(count)
			table.insert(strings, str)
			str = hexToInputString(hex)
			count = 1
		end
		previousHex = hex
	end
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
	local f, err = io.open("menu settings.txt", "r")
	if err then 
		return 
	end
	local player = nil
	for line in f:lines() do
		if #line ~= 0 then
			if line == "P1" then
				player = p1
				player.recorded = {}
				player.recordedFacing = 1
			elseif line == "P2" then
				player = p2
				player.recorded = {}
				player.recordedFacing = 0
			elseif player then
				local inputs = parseInput(line)
				for _ = 1, inputs.wait, 1 do
					player.recorded[#player.recorded + 1] = inputs.hex
				end
			else
				setOption(line)
			end
		end
	end
	f:close()
end

function setOption(line)
	for k, v in pairs(options) do
		local _, _, key, value = line:upper():find("(%w+)%s*=%s*(%w+)")
		if key == k:upper() then
			local type = type(v)
			if type == "boolean" then
				options[k] = (value == "TRUE" and true or false)
			elseif type == "number" then
				options[k] = tonumber(value)
			end
			break
		end
	end
end

-- Reads from memory and assigns variables based on the memory
function memoryReader()
	readPlayerMemory(p1)
	readPlayerMemory(p2)
	input.previous = input.current
	input.current = joypad.read() -- reads all inputs
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
	for k, v in pairs(player.memory) do
		player[k] = readByte(v)
	end
	for k, v in pairs(player.memory2) do
		player[k] = readWordSigned(v)
	end
	if player.standGauge < player.standHealth then
		player.standGauge = player.standHealth
	end
end

function inputSorter() --sorts inputs
	p1.previousInputs = p1.inputs
	p1.inputs = getPlayerInputHex("P1 ")
	p2.previousInputs = p2.inputs
	p2.inputs = getPlayerInputHex("P2 ")
end

-- Gets the specified players inputs as a hex
function getPlayerInputHex(player)
	local hex = 0
	for k, v in pairs(inputDictionary) do
		if input.current[player..v] then
			hex = bor(hex, k)
		end
	end
	return hex
end

-- Queues new inputs
function inputHistoryRefresher()
	updatePlayerHistory(p1)
	updatePlayerHistory(p2)
end

function updatePlayerHistory(player)
	local direction = band(player.inputs, 0x0F)
	local previousDirection = band(player.previousInputs, 0x0F)
	if (player.inputs ~= player.previousInputs and player.inputs ~= 0) and
			(player.previousInputs - previousDirection + player.inputs) ~= player.previousInputs and
			(player.previousInputs - previousDirection ~= player.inputs - direction or direction ~= 0) and
			(not (player.inputs - (player.previousInputs - previousDirection) < 0)) then
		for i = 13, 2, - 1 do
			player.inputHistoryTable[i] = player.inputHistoryTable[i - 1]
		end
		if player.previousInputs - previousDirection ~= player.inputs - direction then
			player.inputHistoryTable[1] = player.inputs - (player.previousInputs - previousDirection)
		else
			player.inputHistoryTable[1] = direction
		end
	end
end

function drawDpad(DpadX,DpadY,sideLength)
	gui.box(DpadX,DpadY,DpadX+(sideLength*3),DpadY+sideLength,"black","white")
	gui.box(DpadX+sideLength, DpadY-sideLength, DpadX+(sideLength*2), DpadY+(sideLength*2), "black", "white")
	gui.box(DpadX+1, DpadY+1, DpadX+(sideLength*3)-1, DpadY+sideLength-1,"black")
end

function gameplayLoop() --main loop for gameplay calculations
	updatePlayer(p1, p2)
	updatePlayer(p2, p1)
	-- updateFrameAdvantage(p1, p2)
	writeByte(0x205CC1A, options.music and 0x80 or 0x00) -- Toggle music off or on
	if not fcReplay then  
		writeByte(0x20314B4, 0x63) -- Infinite Clock Time
	end 
	if not options.ips then -- IPS
		writeByte(p1.memory.ips, 0x00)
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

	-- Frame Data
	player.previousCanReversal = player.canReversal
	player.canReversal = canReversal(player)
	player.previousCanAct = player.canAct
	player.canAct = canAct(player)
end

-- p1Frame = 0
-- p2Frame = 0
-- frameAdvantage = 0

-- function updateFrameAdvantage(player, other)
-- 	if not player.previousCanAct and player.canAct then
-- 		p1Frame = emu.framecount()
-- 	end
-- 	if not other.previousCanReversal and other.canReversal then
-- 		p2Frame = emu.framecount()
-- 		frameAdvantage = p2Frame - p1Frame
-- 	end
-- 	gui.text(50, 100, frameAdvantage)
-- end

function inputChecker()
	if fcReplay then return end
	checkPlayerInput(p1, p2)
	checkPlayerInput(p2, p1)
	if menu.state > 0 then
		updateMenu()
	end
end

function checkPlayerInput(player, other)
	for _, v in pairs(player.buttons) do
		if input.current[v] then
			input.held[v] = input.held[v] + 1
		else
			input.held[v] = 0
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

	if input.current[player.buttons.start] then --checks to see if P1 is holding start
		
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
		if options.mediumKickHotkey == 1 then
			record(player)
		end
	elseif pressed(player.buttons.sk) then
		if options.strongKickHotkey == 1 then
			replaying(player)
		elseif options.strongKickHotkey == 2 then
			replayTransfer(player, other)
		elseif options.strongKickHotkey == 3 then
			inputPlayback(player)
			inputPlayback(other)
		end
	end

	if held(player.buttons.sk, 15) then
		if options.strongKickHotkey == 2 then
			other.loop = true
		else
			player.loop = true
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

function characterControl()
	if fcReplay then return end
	if menu.state > 0 then return end

	input.overwrite = {}

	controlPlayer(p1, p2)
	controlPlayer(p2, p1)

	if next(input.overwrite) ~= nil then --empty table
		joypad.set(input.overwrite)
	end
end

function controlPlayer(player, other)
	-- recording
	if player.recording then
		table.insert(player.recorded, player.inputs)
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
		elseif options.airTech and canAirTech(player) then
			airTech(player)
		--Perfect Air Tech 
		elseif options.perfectAirTech and canPerfectAirTech(player) then
			airTech(player, true)
		-- Throw tech
		elseif options.throwTech and player.throwTech > 0 then
			throwTech(player)
		-- Reversals
		elseif player.canReversal then
			-- Force Stand
			if options.forceStand > 1 and canStand(player) then
				setPlayback(player, { 0x80 })
				writeByte(player.memory.standGaugeRefill, player.standGaugeMax)
			-- Reversal
			elseif options.reversal > 1 then
				reversal(player)
			end
		end
	end
	-- Input Playback
	if player.playbackCount > 0 then
		local hex =  player.playback[#player.playback - player.playbackCount + 1]
		hex = (player.playbackFlipped and swapHexDirection(hex) or hex)
		local inputs = hexToPlayerInput(hex, player.name)
		tableCopy(inputs, input.overwrite)
		player.playbackCount = player.playbackCount - 1
		if player.playbackCount == 0 and player.loop then
			player.playbackFlipped = player.facing ~= player.playbackFacing
			player.playbackCount = #player.playback
		end
	-- Player control
	elseif player.control then
		local inputs = hexToPlayerInput(other.inputs, player.name)
		tableCopy(inputs, input.overwrite)
	-- Direction Lock
	elseif player.directionLock ~= 0 then
		local direction = (player.facing == player.directionLockFacing and player.directionLock or swapHexDirection(player.directionLock))
		local inputs = hexToPlayerInput(direction, player.name)
		tableCopy(inputs, input.overwrite)
	end
end

function setPlayback(player, table)
	player.playback = table
	player.playbackCount = #table
	player.playbackFacing = player.facing
	player.playbackFlipped = false
	player.loop = false
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
		player.reversalCount = (player.stand and 10 or 3)
	elseif direction == 2 then
		inputs = { 0x72}
		player.reversalCount = 10
	elseif direction == 3 then
		inputs = (player.facing == 1 and { 0x78 } or { 0x74 })
		player.reversalCount = 10
	elseif direction == 4 then
		inputs = (player.facing == 1 and { 0x74 } or { 0x78 })
		player.reversalCount = 10
	end
	if not perfect then
		insertDelay(inputs, options.airTechDelay, 0)
	end
	setPlayback(player, inputs)
	if player.height > 32 then	--player height 32 rolls, 33 doesn't
		player.reversalCount = player.reversalCount + #inputs
	else
		player.reversalCount = 0
	end
end

function pushBlock(player)
	local direction = band(0x0F, player.inputs)
	local inputs = { bor(0x70, direction) }
	insertDelay(inputs, options.guardActionDelay, direction)
	setPlayback(player, inputs)
	player.reversalCount = 18 + options.guardActionDelay
end

function guardCancel(player)
	local inputs = (player.facing == 1 and { 0x08, 0x02, 0x1A } or { 0x04, 0x02, 0x16 })
	insertDelay(inputs, options.guardActionDelay, band(player.inputs, 0x0F))
	setPlayback(player, inputs)
	--player.reversalCount = 15 Jotaro s.off
end

function throwTech(player)
	setPlayback(player, { 0x44 })
end

function reversal(player)
	local inputs
	player.playbackFacing = player.facing
	player.playbackFlipped = false
	player.loop = false
	if options.reversal == 2 then -- A
		inputs = { bor(0x10, band(0x0F, player.inputs)) }
	elseif options.reversal == 3 then -- B
		inputs = { bor(0x20, band(0x0F, player.inputs)) }
	elseif options.reversal == 4 then -- C
		inputs = { bor(0x40, band(0x0F, player.inputs)) }
	elseif options.reversal == 5 then -- S
		inputs = { bor(0x80, band(0x0F, player.inputs)) }
	elseif options.reversal == 6 then -- ABC
		inputs = { bor(0x70, band(0x0F, player.inputs)) }
	elseif options.reversal == 7 then -- Recording
		inputs = player.recorded
		player.playbackFacing = player.recordedFacing
		player.playbackFlipped = player.facing ~= player.recordedFacing
	elseif options.reversal == 8 then -- Input playback
		readInputsFile()
		inputs = player.inputPlayback
		player.playbackFacing = player.inputPlaybackFacing
		player.playbackFlipped = player.facing ~= player.inputPlaybackFacing
	end
	player.playback = inputs
	player.playbackCount = #inputs
	while (player.playback[#player.playback - player.playbackCount + 1] == 0) do -- trim empty inputs
		player.playbackCount = player.playbackCount - 1
	end
end

function canGuardAction(player)
	return player.previousGuarding == 0 and player.guarding > 0
end

function canAirTech(player)
	return player.height > 0 and player.hitstun == 1 and player.riseFall == 0xFF and
		(player.previousRiseFall == 0x00 or --Rising to falling
		(player.previousAnimationState == 1 and player.animationState == 2)) -- Spiked
end

function canPerfectAirTech(player)
	return player.previousHitstun == 0 and player.hitstun == 1 and player.height > 0
end

function canReversal(player)
	player.reversalCount = player.reversalCount - 1
	if player.reversalCount == 1 then
		player.reversalCount = 0
		return true
	end
	if not player.blocking and canGuardAction(player) then
		player.blocking = true
	end
	if player.blocking and 
		(player.stand  == 0 and player.guardAnimation == 2) or
		(player.stand == 1 and player.standGuardAnimation == 2) then
		player.blocking = false
		return true
	end
	if player.previousHitstun == 1 and player.hitstun ~= 1 then
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

function openMenu()
	if menu.state == 0 then
		menu.state = 1
		menu.title = "Training Menu"
		menu.index = 1
		menu.options = rootOptions
		updateMenuInfo()
		writeByte(0x20713A3, 0x00); -- Bit mask that disables player input
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
	elseif option.type == optionType.memory then
		options[option.key] = (value == 0 and readByte(option.memory) or value - 1)
	elseif option.type == optionType.slider then
		local inc = (heldTable(selectInputs, 1) and 10 or 1)
		local value = getMenuColor(option.mask, option.shift)
		if (value - inc < 0) then 
			inc = value
		end
		options[menu.color] = options[menu.color] - lShift(inc, option.shift)
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
	elseif option.type == optionType.memory then
		options[option.key] = (value >= readByte(option.memory) and 0 or value + 1)
	elseif option.type == optionType.slider then
		local inc = (heldTable(selectInputs, 1) and 10 or 1)
		local value = getMenuColor(option.mask, option.shift)
		if (value + inc > 255) then
			inc = 255 - value
		end
		options[menu.color] = options[menu.color] + lShift(inc, option.shift)
	end
end

function menuUp()
	if menu.state == 3 then return end
	menu.index = (menu.index == 1 and #menu.options or menu.index - 1)
	updateMenuInfo()
end

function menuDown()
	if menu.state == 3 then return end
	menu.index = (menu.index >= #menu.options and 1 or menu.index + 1)
	updateMenuInfo()
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

function guiWriter() -- Writes the GUI
	if options.guiStyle ~= 1 then
		drawHitboxes()
	end

	if menu.state > 0 then
		drawMenu()
	end

	if options.guiStyle == 1 then
		return
	end

	gui.text(18,15, p1.health) -- P1 Health at x:18 and y:15
	gui.text(355,15, p2.health) -- P2 Health
	gui.text(50, 24, p1.standHealth) -- P1's Stand Health
	gui.text(326,24, p2.standHealth) -- P2's Stand Health
	gui.text(135,216,tostring(p1.meter)) -- P1's meter fill
	gui.text(242,216,tostring(p2.meter)) -- P2's meter fill

	if (options.guiStyle > 1) then
		local historyLength = (options.guiStyle == 3 and 13 or 11)
		for i = 1, historyLength, 1 do
			local hex = p1.inputHistoryTable[i]
			local buttonOffset = 0
			if band(hex, 0x10) == 0x10 then --A
				gui.text(hud.xP1+hud.offset*4,hud.yP1-1-((11)*i*hud.scroll),"A", options.inputHistoryA)
				buttonOffset=buttonOffset+6
			end
			if band(hex, 0x20) == 0x20 then --B
				gui.text(hud.xP1+hud.offset*4+buttonOffset,hud.yP1-1-((11)*i*hud.scroll),"B", options.inputHistoryB)
				buttonOffset=buttonOffset+6
			end
			if band(hex, 0x40) == 0x40 then --C
				gui.text(hud.xP1+hud.offset*4+buttonOffset,hud.yP1-1-((11)*i*hud.scroll),"C", options.inputHistoryC)
				buttonOffset=buttonOffset+6
			end
			if band(hex, 0x80) == 0x80 then --S
				gui.text(hud.xP1+hud.offset*4+buttonOffset,hud.yP1-1-((11)*i*hud.scroll),"S", options.inputHistoryS)
			end
			if band(hex, 0x0F) > 0 then
				drawDpad(hud.xP1,hud.yP1-((11)*i*hud.scroll),hud.offset)
			end
			if band(hex, 0x01) == 0x01 then --Up
				gui.box(hud.xP1+hud.offset+1, hud.yP1-(11*i*hud.scroll), hud.xP1+hud.offset*2-1, hud.yP1-hud.offset+1-(11*i*hud.scroll),"red")
			end
			if band(hex, 0x02) == 0x02 then --Down
				gui.box(hud.xP1+hud.offset+1, hud.yP1+hud.offset-(11*i*hud.scroll), hud.xP1+hud.offset*2-1, hud.yP1+hud.offset*2-(11*i*hud.scroll)-1,"red")
			end
			if band(hex, 0x04) == 0x04 then --Left
				gui.box(hud.xP1+1, hud.yP1+1-(11*i*hud.scroll), hud.xP1+hud.offset, hud.yP1+hud.offset-1-(11*i*hud.scroll),"red")
			end
			if band(hex, 0x08) == 0x08 then --Right
				gui.box(hud.xP1+hud.offset*2, hud.yP1+1-(11*i*hud.scroll), hud.xP1+hud.offset*3-1, hud.yP1+hud.offset-1-(11*i*hud.scroll),"red")
			end
		end
	end
	
	if options.guiStyle == 2 or options.guiStyle == 4 then
		gui.text(8,50,"P1 Damage: "..tostring(p2.previousDamage)) -- Damage of P1's last hit
		gui.text(8,66,"P1 Combo: ")
		gui.text(48,66, p1.displayComboCounter, p1.comboCounterColor) -- P1's combo count
		gui.text(8,58,"P1 Combo Damage: "..tostring(p1.comboDamage)) -- Damage of P1's combo in total
	elseif options.guiStyle == 3 and menu.state == 0 then
		gui.text(146,45,"Damage: ") -- Damage of P1's last hit
		guiTextAlignRight(236,45,p2.previousDamage) -- Damage of P1's last hit
		gui.text(146,53,"Combo Damage: ") -- Damage of P1's combo in total
		guiTextAlignRight(236,53,p1.comboDamage) -- Damage of P1's combo in total
		gui.text(146,61,"Combo: ")
		guiTextAlignRight(236,61,p1.displayComboCounter, p1.comboCounterColor)
		gui.text(146,69,"IPS: ") -- IPS for P1's combo
		if p1.previousIps == 0 or not options.ips then --It flickers on and off if you don't check the menu option
			guiTextAlignRight(236, 69, "OFF", "red")
		else
			guiTextAlignRight(236, 69, "ON", "green")
		end
		gui.text(146,77,"Scaling: ") -- Scaling for P1's combo
		if p1.previousScaling == 0 then
			guiTextAlignRight(236, 77, "OFF", "red")
		else
			guiTextAlignRight(236, 77, "ON", "green")
		end
		-- gui.text(146, 85, "Frame Advantage: ")
		-- guiTextAlignRight(236, 85, frameAdvantage)
	end

	if (p1.recording) then
		gui.text(152,32,"Recording", "red")
	elseif (p1.playbackCount > 0) then
		gui.text(152,32,"Replaying", "red")
	end

	if (options.guiStyle == 4) then

		gui.text(300,50,"P2 Damage: " .. tostring(p1.previousDamage)) -- Damage of P2's last hit
		gui.text(300,66,"P2 Combo: ")
		gui.text(348,66, p2.displayComboCounter, p2.comboCounterColor) -- P2's combo count
		gui.text(300,58,"P2 Combo Damage: " .. tostring(p2.comboDamage)) -- Damage of P2's combo in total

		for i = 1, 11, 1 do
			local hex = p2.inputHistoryTable[i]
			local buttonOffset=0
			if band(hex, 0x10) == 0x10 then --A
				gui.text(hud.xP2+hud.offset*4,hud.yP2-1-((11)*i*hud.scroll),"A",options.inputHistoryA)
				buttonOffset=buttonOffset+6
			end
			if band(hex, 0x20) == 0x20 then --B
				gui.text(hud.xP2+hud.offset*4+buttonOffset,hud.yP2-1-((11)*i*hud.scroll),"B",options.inputHistoryB)
				buttonOffset=buttonOffset+6
			end
			if band(hex, 0x40) == 0x40 then --C
				gui.text(hud.xP2+hud.offset*4+buttonOffset,hud.yP2-1-((11)*i*hud.scroll),"C",options.inputHistoryC)
				buttonOffset=buttonOffset+6
			end
			if band(hex, 0x80) == 0x80 then --S
				gui.text(hud.xP2+hud.offset*4+buttonOffset,hud.yP2-1-((11)*i*hud.scroll),"S",options.inputHistoryS)
			end
			if band(hex, 0x0F) > 0 then
				drawDpad(hud.xP2,hud.yP2-((11)*i*hud.scroll),hud.offset)
			end
			if band(hex, 0x01) == 0x01 then --Up
				gui.box(hud.xP2+hud.offset+1, hud.yP2-(11*i*hud.scroll), hud.xP2+hud.offset*2-1, hud.yP2-hud.offset+1-(11*i*hud.scroll),"red")
			end
			if band(hex, 0x02) == 0x2 then --Down
				gui.box(hud.xP2+hud.offset+1, hud.yP2+hud.offset-(11*i*hud.scroll), hud.xP2+hud.offset*2-1, hud.yP2+hud.offset*2-(11*i*hud.scroll)-1,"red")
			end
			if band(hex, 0x04) == 0x04 then --Left
				gui.box(hud.xP2+1, hud.yP2+1-(11*i*hud.scroll), hud.xP2+hud.offset, hud.yP2+hud.offset-1-(11*i*hud.scroll),"red")
			end
			if band(hex, 0x08) == 0x08 then --Right
				gui.box(hud.xP2+hud.offset*2, hud.yP2+1-(11*i*hud.scroll), hud.xP2+hud.offset*3-1, hud.yP2+hud.offset-1-(11*i*hud.scroll),"red")
			end
		end
	end
	if (p2.recording) then
		gui.text(200,32,"Recording", "red")
	elseif (p2.playbackCount > 0) then
		gui.text(200,32,"Replaying", "red")
	end
end

function guiTextAlignRight(x, y, text, color) 
	local t = tostring(text)
	color = color or "white"
	gui.text(x - #t * 4, y, t, color)
end

-- Draws the menu overlay
function drawMenu()
	gui.box(90, 36, 294, 188, colors.menuBackgroundColor, "white")
	gui.text(110, 42, menu.title, colors.menuTitleColor)
	if menu.state == 3 then --info
		for i = 1, #menu.info, 1 do
			gui.text(100, 48 + i * 12, menu.info[i], colors.menuTitleColor)
		end
		gui.text(110, 172, "Return", colors.menuSelectedColor)
	else
		for i = 1, #menu.options, 1 do
			local color = (menu.index == i and colors.menuSelectedColor or colors.menuUnselectedColor)
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
			elseif option.type == optionType.memory then
				local number = options[option.key]
				local word = (number == readByte(option.memory) and "Max" or number)
				gui.text(200, 48 + i * 12, word, color)
			elseif option.type == optionType.slider then
				local value = getMenuColor(option.mask, option.shift)
				gui.text(150, 48 + i * 12, value, color)
			end
		end
		if menu.state == 4 then
			local color = bor(options[menu.color], 0xFF)
			gui.box(200, 60, 240, 100, color, color)
			gui.text(186, 112, "Hold A to increase by 10", colors.menuTitleColor)
		end
		gui.text(110, 172, menu.info, colors.menuTitleColor)
	end
end

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
		drawbox(0x2035964, px, py, flip, options.orangeboxColor)
	end
end

function getHitboxes()
	local boxData = {{}, {}, {}}

	--local zoomX = readWordSigned(0x0205DBAA) / 384
	--local zoomY = readWordSigned(0x0205DBAE) / 224
	local screenX = readWordSigned(0x0203145C)
	local screenY = readWordSigned(0x02031470)

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
	for i = 0, 63, 1 do
		local projectile = readByte(0x0203848C + i * 0x420 + 0x00)
		if projectile > 0 then
			local pFacing = readByte(0x0203848C + i * 0x420 + 0x0D)
			local pChar = readByte(0x0203848C + i * 0x420 + 0x13)
			local pHitbox = readWord(0x0203848C + i * 0x420 + 0xAC)
			local pX = readWordSigned(0x0203848C + i * 0x420 + 0x5C)
			local pY = readWordSigned(0x0203848C + i * 0x420 + 0x60)
			drawPlayerHitboxes(pHitbox, pX - screenX, pY + screenY, pFacing, pChar, boxData)
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
	drawbox2(atk2, boxOffset, x, y, flip, options.orangeboxColor, data, 3)
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

function replayOptions() 
	options.healthRefill = false
	options.meterRefill = false
	options.ips = true
	options.guardAction = 1
	options.airTech = false
	options.perfectAirTech = false
	options.forceStand = 1
	options.reversal = 1
	options.throwTech = false
end

--register callbacks
emu.registerstart(function()
	writeByte(0x20713A8, 0x09) -- Infinite Credits
	writeByte(0x20312C1, 0x01) -- Unlock all characters
	writeByte(0x20713A3, 0xFF) -- Bit mask that enables player input
	readSettings()
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

local previousFrame = emu.framecount() - 1

while true do 
	local currentFrame = emu.framecount()
	if currentFrame ~= previousFrame then -- if frame isn't repeated
		memoryReader()
		gameplayLoop()
		inputSorter()
		inputChecker()
		inputHistoryRefresher()
		characterControl()
		updateHitboxes()
	end
	previousFrame = currentFrame
	emu.frameadvance()
end