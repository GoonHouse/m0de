-- ruin everything
io.stdout:setvbuf("no")
--require('mobdebug').start()
	
-- https://github.com/tanema/light_world.lua
--require("lib.core.camera")
--require("lib.core.world")
--Gui = --require()

--animations library

-- entities like players, enemies, ...
--require("lib.entities.player")

-- game states
--Gamestate = require('lib.vendor.hump.gamestate')
--require("lib.states.game")

--[[
	write some helper methods for STI to filter maps with a function and
	transform it accordingly?
]]

-- Example: STI Example
local LightWorld = require 'libs.lightworld'
local sti = require 'libs.sti'
local ProFi = require 'libs.ProFi'
local rectdec = require 'libs.rectdec'

function love.load()
	--love._openConsole()
	--Gamestate.switch(game)
	ProFi:start()
	print("zebras")
	x = 0
	y = 0
	z = 1
	scale = 1

	-- create light world
	lightWorld = LightWorld({
		ambient = {55,55,55},
		shadowBlur = 0.0
	})

	map = sti.new("maps/map")
	image_normal = love.graphics.newImage("resources/graphics/border_NRM.png")

	-- create light
	lightMouse = lightWorld:newLight(0, 0, 255, 127, 63, 300)
	lightMouse:setGlowStrength(0.3)

	-- performance is immensely fucked here, use some smangy rectangles holmes
	-- https://github.com/mikolalysenko/rectangle-decomposition
	
	rectdec:setMap(map.layers[1])
	local rectangles = rectdec:parseMap()
	local TILE_SIZE = 32
	for _, r in ipairs(rectangles) do
		print("rectangle #", _)
		local start_x = r.start_x * TILE_SIZE
		local start_y = r.start_y * TILE_SIZE
		local width = (r.end_x - r.start_x + 1) * TILE_SIZE
		local height = (r.end_y - r.start_y + 1) * TILE_SIZE

		local x = start_x + (width / 2)
		local y = start_y + (height / 2)
		
		local rect = lightWorld:newRectangle(x-TILE_SIZE, y-TILE_SIZE, width, height)
		rect:setNormalMap(image_normal, width, height)
		
		--local body = love.physics.newBody(phys_world, x, y, 0, 0)
		--local shape = love.physics.newRectangleShape(body, 0, 0, width, height)

		--shape:setFriction(0)

		--table.insert(wall_rects, {body = body, shape = shape})
	end
	
	--[[
	-- if you want really laggy junk, use this
	for iy, row in ipairs(map.layers[1].data) do
		for ix, col in ipairs(row) do
			if col then
				local sx, sy = map:convertTileToScreen(ix,iy)
				local rect = lightWorld:newRectangle(sx-col.width/2, sy-col.height/2, col.width, col.height)
				rect:setNormalMap(image_normal, col.width, col.height)
			end
		end
	end
	]]
end

function love.update(dt)
	--Gamestate.update(dt)
	love.window.setTitle("Light vs. Shadow Engine (FPS:" .. love.timer.getFPS() .. ")")

	if love.keyboard.isDown("down") then
		y = y - dt * 200
	elseif love.keyboard.isDown("up") then
		y = y + dt * 200
	end

	if love.keyboard.isDown("right") then
		x = x - dt * 200
	elseif love.keyboard.isDown("left") then
		x = x + dt * 200
	end

	if love.keyboard.isDown("-") then
		scale = scale - 0.01
	elseif love.keyboard.isDown("=") then
		scale = scale + 0.01
	end

	map:update(dt)
	lightWorld:update(dt)
	lightMouse:setPosition((love.mouse.getX() - x)/scale, (love.mouse.getY() - y)/scale, z)
end

function love.mousepressed(x, y, c)
	--Gamestate.mousepressed(x, y, c)
	if c == "wu" then
	z = z + 1
	elseif c == "wd" then
	z = z - 1
	end
end

function love.keypressed(key, code)
	--Gamestate.keypressed(key, code)
end

function love.draw()
	--Gamestate.draw()
	lightWorld:setTranslation(x, y, scale)
	love.graphics.push()
	love.graphics.translate(x, y)
	love.graphics.scale(scale)
	lightWorld:draw(function()
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle("fill", -x/scale, -y/scale, love.graphics.getWidth()/scale, love.graphics.getHeight()/scale)
		map:draw()
	end)
	love.graphics.pop()
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