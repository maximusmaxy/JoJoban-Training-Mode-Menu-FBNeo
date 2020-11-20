local trials = {}

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
}

local comboDictionary = {} 

--Copies values from one table to another
function tableCopy(source, dest) 
	for k, v in pairs(source) do
		dest[k] = v
	end
end

tableCopy(comboType, comboDictionary)
comboDictionary["player charge"] = comboType.pCharge
comboDictionary["character charge"] = comboType.pCharge
comboDictionary["stand charge"] = comboType.sCharge
comboDictionary["projectile charge"] = comboType.bCharge
comboDictionary["bullet charge"] = comboType.bCharge
comboDictionary["return"] = comboType.recall

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
}

function readTrials()
	local t, err = loadfile("trials.lua")
	if err then
		return
	end
	trials = t()
	sanitizeTrials()
end

function sanitizeTrials()
	for i = 1, #trials, 1 do
		for y = 1, #trials[i].trials, 1 do
            for c = 1, #trials[i].trials[y].combo, 1 do
                local input = trials[i].trials[y].combo[c]
                trials[i].trials[y].combo[c].type = comboDictionary[input.type] or 1
                if input.type == comboType.inputs then
                    for k = 1, #input.id, 1 do
                        input.id[k] = convertToString(input.id[k])
                    end
                end
			end
		end
	end
end

-- 
function convertToString(num)
	local low = string.format("%08X", num)
	local high = string.format("%04X", num / 0x100000000)
    return high..low:sub(1, 2)..low:sub(5, 8)
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
	local sb = { "[" }
	insertJsonTable(sb, obj, 1)
	sb[#sb + 1] = "]"
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
		elseif k == "recording" then
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

function convert()
    readTrials()
    local filename = "trials.json"
    local f, err = io.open(filename, "w")
	if err then
		print("Error accessing "..filename)
		return
	end
	local trialString = json.stringify(trials)
	local _, err = f:write(trialString)
	if err then
		print("Error exporting trial")
	else
		print("Trials exported successfully")
	end
	f:close()
    print("Conversion successful!")
end

convert()