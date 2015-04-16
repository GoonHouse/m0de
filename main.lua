-- include
flux	 = require "lib.flux"
cron     = require 'lib.cron'
Menu     = require 'lib.menu'
ProFi    = require 'lib.ProFi'
lume     = require 'lib.lume'
lurker   = require 'lib.lurker'

-- game & gamestate requires
local Game = require 'game'

-- global game states
require 'gamestates.loading'
require 'gamestates.main_menu'
require 'gamestates.options_menu'
require 'gamestates.options_sound'
require 'gamestates.options_keyboard'
require 'gamestates.ingame'

-- global Ressources
_menu_ = { image = {}, texture = {}, sound = {} }
_ingame_ = { image = {}, texture = {}, sound = {} }

-- game instance
local testgame = nil	-- main game object

-- basic LÖVE callbacks used on this game; add more as needed
function love.load()
	ProFi:start()
	testgame = Game:new() -- initialize game
end

function love.draw()
	testgame:draw()
end

function love.update(dt)
	lurker.update(dt)
	cron.update(dt)
	flux.update(dt)
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