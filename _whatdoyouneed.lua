--[[
	generate a trace of all requires that happen in the domain of lua
]]

local _this_file_path = debug.getinfo(1, "S").source

-- from: http://lua-users.org/wiki/SplitJoin
local function string_split(str, sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	str:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

--[[
	stores where all the data goes, indexed by filename based on the depth of the require
	file paths start with '@' because that's just how debug.source does things
	if a file path begins with '?' that means the lib doesn't understand the include being made
	example data:
	
	treeMap = {
		['@main.lua'] = {
			['@lib/make_my_game_better.lua'] = {},
			['@lib/complex_lib/init.lua'] = {
				['@lib/complex_lib/parts/part1.lua'] = {},
				['@lib/complex_lib/parts/part2.lua'] = {},
			},
		},
	}
]]
local treeMap = {}

local whatdoyouneed = {
	origRequire = require,
	
	fixPathSamples = {
		-- fix relative paths to make them usable by love
		{"%./", "", 1},
		{"%.\\", "", 1},
		
		-- make backslashes into forward slashes
		{"\\", "/"},
		
		-- replace dots in paths that end in .lua
		{"(.*)%.lua$", function(w)
			return w:gsub("%.", "/") .. ".lua"
		end},
	}
}

-- translates require paths into actual files
function whatdoyouneed.fixPath(path)
	--print("fixPath IN: ", path)
	for _, gsubArgs in ipairs(whatdoyouneed.fixPathSamples) do
		local count
		path, count = path:gsub(unpack(gsubArgs))
		if love.filesystem.isFile(path) then
			return '@'..path
		end
	end
	--print("fixPath OUT: ", path)
	return nil
end

-- get a file from a require path, uses fixPath above
function whatdoyouneed.pathToFile(path)
	local packageParts = string_split(package.path, ';')
	local cap, count
	for _, searchLocation in ipairs(packageParts) do
		cap, count = string.gsub(searchLocation, "%?", path)
		if count > 0 then
			local newpath = whatdoyouneed.fixPath(cap)
			if love.filesystem.isFile(cap) then
				return cap
			elseif newpath then
				return newpath
			end
		end
	end
	return '?'..path
end

-- turns reverse-linear history into a dependency map
function whatdoyouneed.resolveStack(stack)
	local start = treeMap
	for i=#stack,1,-1 do
		local val = stack[i]
		if not start[ val.source ] then
			start[val.source] = {}
		end
		start = start[val.source]
	end
end

-- get the tree
function whatdoyouneed:getTree()
	return treeMap
end

-- actually set up the replacement 
require = function(res)
	local level = 1
	local stack = {
		{
			-- start the stack with the resource being requested
			source=whatdoyouneed.pathToFile(res),
			-- we have no idea what line we're on
			line=-1
		}
	}
	while true do
		local info = debug.getinfo(level, "Sl")
		if not info then break end
		-- ignore C functions, whatever boot.lua is doing, and ourselves
		if info.what ~= "C"  and info.source ~= "boot.lua" and info.source ~= _this_file_path then
			table.insert(stack, {source=info.source, line=info.currentline})
		end
		level = level + 1
	end
	whatdoyouneed.resolveStack(stack)
	return whatdoyouneed.origRequire(res)
end

return whatdoyouneed