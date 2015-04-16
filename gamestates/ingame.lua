local Game = require 'game'
local InGame = Game:addState('InGame')

local LightWorld = require 'lib/lightworld'
local sti = require 'lib/sti'
local rectdec = require 'lib.rectdec'

function InGame:enteredState()
	self:log('Entering InGame')
	if not self.loaded then
		self:loadWorld()
		self.loaded = true
	end
	print_r(_ingame_)
end

function InGame:establishCamera()
	self.camera_x = 0
	self.camera_y = 0
	self.camera_z = 1
	self.camera_scale = 1
end

function InGame:processRectangles( rectangles )
	local TILE_SIZE = 32
	local image_normal = love.graphics.newImage("media/images/border-normals.png")
	
	for _, r in ipairs(rectangles) do
		print("rectangle #", _)
		local start_x = r.start_x * TILE_SIZE
		local start_y = r.start_y * TILE_SIZE
		local width = (r.end_x - r.start_x + 1) * TILE_SIZE
		local height = (r.end_y - r.start_y + 1) * TILE_SIZE

		local x = start_x + (width / 2)
		local y = start_y + (height / 2)
		
		local rect = self.lightWorld:newRectangle(x-TILE_SIZE, y-TILE_SIZE, width, height):setNormalMap(image_normal, width, height)
		-- ingame_.image['border-normals']
		
		local body = love.physics.newBody(self.physWorld, x-TILE_SIZE, y-TILE_SIZE, "static")
		local shape = love.physics.newRectangleShape(width, height)
		local fixture = love.physics.newFixture(body, shape, 1)

		table.insert(self.objects, {body = body, shape = shape, fixture = fixture, rect = rect})
	end
end

function InGame:exitedState()
	self:log('Exiting InGame')
end

function InGame:loadWorld()
	self:log("loading world")
	
	self.objects = {}
	
	self.physWorld = love.physics.newWorld(0, 0, true)
	
	self.lightWorld = LightWorld({
		ambient = {55,55,55},
		shadowBlur = 0.0
	})

	self.map = sti.new("maps/map")
	
	self.lightMouse = self.lightWorld:newLight(0, 0, 255, 127, 63, 300)
	self.lightMouse:setGlowStrength(0.3)
	
	rectdec:setMap(self.map.layers[1])
	self:processRectangles(rectdec:parseMap())
	
	self:establishCamera()
end

function InGame:controlUpdate(dt)
	if love.keyboard.isDown("down") then
		self.camera_y = self.camera_y - dt * 200
	elseif love.keyboard.isDown("up") then
		self.camera_y = self.camera_y + dt * 200
	end

	if love.keyboard.isDown("right") then
		self.camera_x = self.camera_x - dt * 200
	elseif love.keyboard.isDown("left") then
		self.camera_x = self.camera_x + dt * 200
	end

	if love.keyboard.isDown("-") then
		self.camera_scale = self.camera_scale - 0.01
	elseif love.keyboard.isDown("=") then
		self.camera_scale = self.camera_scale + 0.01
	end
end

function InGame:update(dt)
	self:controlUpdate(dt)
	self.map:update(dt)
	self.lightWorld:update(dt)
	self.lightMouse:setPosition((love.mouse.getX() - self.camera_x)/self.camera_scale, (love.mouse.getY() - self.camera_y)/self.camera_scale, self.camera_z)
end

function InGame:draw()
	self.lightWorld:setTranslation(self.camera_x, self.camera_y, self.camera_scale)
	love.graphics.push()
	love.graphics.translate(self.camera_x, self.camera_y)
	love.graphics.scale(self.camera_scale)
	self.lightWorld:draw(function()
		love.graphics.setColor(255, 255, 255)
		-- basically, anything before this will be tossed out the window
		love.graphics.rectangle("fill", -self.camera_x/self.camera_scale, -self.camera_y/self.camera_scale, love.graphics.getWidth()/self.camera_scale, love.graphics.getHeight()/self.camera_scale)
		self.map:draw()
	end)
	for k,v in ipairs(self.objects) do
		local points = {v.body:getWorldPoints(v.shape:getPoints())}
		table.insert(points, points[1])
		table.insert(points, points[2])
		-- repeat the last points because 
		love.graphics.line(points)
	end
	love.graphics.pop()
end

function InGame:keypressed(key, code)
	if key == 'escape' then
		self:gotoState('MainMenu')
	end
end

function InGame:mousepressed(x,y,button)
	if button == "wu" then
		self.camera_z = self.camera_z + 1
	elseif button == "wd" then
		self.camera_z = self.camera_z - 1
	end
end

return InGame