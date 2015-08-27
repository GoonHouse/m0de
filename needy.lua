--[[
	This is a lib for doing really, really dumb static file analysis to get an idea of which files require other files.
	
	If you put multiple requires on one line, this will not work, also that's a terrible idea.
]]

-- from: http://lua-users.org/wiki/SplitJoin
function string:split(sep)
	local sep, fields = sep or ":", {}
	local pattern = string.format("([^%s]+)", sep)
	self:gsub(pattern, function(c) fields[#fields+1] = c end)
	return fields
end

-- a list of examples
local positiveExamples = {
	[[local balls = require('libs.horse')]],
	[[require 'boat']],
	[[require "boat/horse"]],
	[[b = require ("exotic\paths\gills.lua")]],
}

-- 
local negativeExamples = {
	
}

local needy = {
	flatMap = {}, -- flatMap[file1] == 'fileItRequires'
	
	-- array of files and require strings that didn't make sense
	nonSense = {}, -- nonSense[filename] == 'linenumber:\trequire line'
	
	-- the list of patterns to test against to find positives
	testBattery = {
		[[require *%( *['"](.+)['"] *%)]],
		[[require *['"](.+)['"] *]],
	},
	
	fixPathSamples = {
		{"%./", "", 1},
		{"%.\\", "", 1},
		-- replace dots in paths that end in .lua
		{"(.*)%.lua$", function(w)
			return w:gsub("%.", "/") .. ".lua"
		end},
	}
}

function needy:fixPath(path)
	print("fixPath IN: ", path)
	for _, gsubArgs in ipairs(self.fixPathSamples) do
		local count
		path, count = path:gsub(unpack(gsubArgs))
		if love.filesystem.isFile(path) then
			return path
		end
	end
	print("fixPath OUT: ", path)
	return nil
end

function needy:pathToFile(path)
	-- we're probably going to have to do a bit of trickery
	local packageParts = package.path:split(';')
	local cap, count
	for _, searchLocation in ipairs(packageParts) do
		cap, count = string.gsub(searchLocation, "%?", path)
		if count > 0 then
			local newpath = self:fixPath(cap)
			if love.filesystem.isFile(cap) then
				return cap
			elseif newpath then
				return newpath
			end
		else
			print("CRITICAL: A path was listed without any room for variables in it: " .. searchLocation)
		end
	end
	return nil
end

local function isFileSource(filename)
	
end

-- if a string contains require, this finds what it is requiring
function needy:resolveRequireString(line)
	local start, stop, cap
	for _, testPattern in pairs(needy.testBattery) do
		start, stop, cap = string.find(line, testPattern)
		if start then
			return cap
		end
	end
	return nil
end

-- simply make note that there's a relationship between files
function needy:recordFile(filename, include)
	if not self.flatMap[filename] then
		self.flatMap[filename] = {}
	end
	table.insert(self.flatMap[filename], include)
end

function needy:analyze(filename)
	if love.filesystem.isFile(filename) then
		local cap
		for line in love.filesystem.lines(filename) do
			cap = self:resolveRequireString(line)
			if cap then
				local newpath = self:pathToFile(cap)
				print("FOUND:",filename,cap,newpath)
				if love.filesystem.isFile(cap) then
					self:analyze(cap)
				elseif newpath then
					self:analyze(newpath)
				end
				self:recordFile(filename, cap)
			end
		end
	else
		assert(false, "Tried to analyze a non-existant file.")
	end
end

return needy