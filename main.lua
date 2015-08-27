-- include
--require("mobdebug").start()
io.stdout:setvbuf("no")
--whatdoyouneed = require('lib.whatdoyouneed')

-- == libraries
require("enet")
sti 	 = require 'lib.sti'
flux	 = require "lib.flux"
cron     = require 'lib.cron'
Menu     = require 'lib.menu'
ProFi    = require 'lib.ProFi'
lume     = require 'lib.lume'
--lurker   = require 'lib.lurker'
log      = require 'lib.log'
tiny     = require 'lib.tiny-ecs.tiny'
tactile	 = require 'lib.tactile.tactile'
class	 = require 'lib.middleclass'
binser	 = require 'lib.binser.binser'

log.level = 'trace' --trace, debug, info, warn, error, fatal??

-- game & gamestate requires
local Game = require 'game'

-- global game states
require 'gamestates.loading'
require 'gamestates.main_menu'
require 'gamestates.options_menu'
require 'gamestates.options_sound'
require 'gamestates.options_keyboard'
require 'gamestates.testbed'

-- global Ressources
_menu_ = { image = {}, texture = {}, sound = {} }
_testbed_ = { image = {}, texture = {}, sound = {} }

-- game instance
local testgame = nil	-- main game object

-- basic LÖVE callbacks used on this game; add more as needed
function love.load(arg)
	--if arg[#arg] == "-debug" then require("mobdebug").start() end
	ProFi:start()
	testgame = Game:new() -- initialize game
end

function love.draw()
	testgame:draw()
	local ds = love.graphics.getStats()
	
	local things_to_draw = {
		-- == execution time
		["FPS"] = love.timer.getFPS(),
		["dt"] = love.timer.getDelta(),
		["^dt"] = love.timer.getAverageDelta(),
		["time"] = love.timer.getTime(),
		
		-- == memory
		["garbage"] = collectgarbage("count"),
		
		-- == graphics on level 3
		["draw calls"] = ds.drawcalls,
		["canvas switches"] = ds.canvasswitches,
		["texture memory"] = ds.texturememory,
		["images"] = ds.images,
		["canvases"] = ds.canvases,
		["fonts"] = ds.fonts,
	}
	local height = 12
	local labelgap = 120
	local x = 10
	local y = 10
	local i = 1
	for k,v in pairs(things_to_draw) do
		love.graphics.print(k, x, y+((i-1) * height))
		love.graphics.print(v, x+labelgap, y+((i-1) * height))
		i = i + 1
	end
	--[[
	love.graphics.print("dt", 10, 20)
	love.graphics.print(love.timer.getDelta(), 60, 20)
	love.graphics.print("^dt", 10, 30)
	love.graphics.print(love.timer.getAverageDelta(), 60, 30)
	love.graphics.print("time", 10, 40)
	love.graphics.print(love.timer.getTime(), 60, 40)
	]]
end

function love.update(dt)
	--lurker.update(dt)
	cron.update(dt)
	flux.update(dt)
	
	-- this is stupid but whatever I have to see if it's really the cause
	testgame:update(dt)
end

function love.keypressed(key, code)
	testgame:keypressed(key, code)
end

function love.keyreleased(key, code)
	testgame:keyreleased(key, code)
end

function love.mousepressed(x,y,button)
	testgame:mousepressed(x,y,button)
end

function love.mousereleased(x,y,button)
	testgame:mousereleased(x,y,button)
end

function love.quit()
	testgame:quit()
end

function print_r ( t )  
	local print_r_cache={}
	local function sub_print_r(t,indent)
			if (print_r_cache[tostring(t)]) then
					print(indent.."*"..tostring(t))
			else
					print_r_cache[tostring(t)]=true
					if (type(t)=="table") then
							for pos,val in pairs(t) do
									if (type(val)=="table") then
											print(indent.."["..pos.."] => "..tostring(t).." {")
											sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
											print(indent..string.rep(" ",string.len(pos)+6).."}")
									elseif (type(val)=="string") then
											print(indent.."["..pos..'] => "'..val..'"')
									else
											print(indent.."["..tostring(pos).."] => "..tostring(val))
									end
							end
					else
							print(indent..tostring(t))
					end
			end
	end
	if (type(t)=="table") then
			print(tostring(t).." {")
			sub_print_r(t,"  ")
			print("}")
	else
			sub_print_r(t,"  ")
	end
	print()
end

--print_r(whatdoyouneed:getTree())