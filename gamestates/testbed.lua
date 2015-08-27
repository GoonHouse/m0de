local Game = require 'game'
local TestBed = Game:addState('TestBed')

function TestBed:enteredState()
	self:log('Entering TestBed')
	if not self.loaded then
		self:loadWorld()
		self.loaded = true
	end
end

function TestBed:exitedState()
	self:log('Exiting TestBed')
end

function TestBed:cheapShape(posX, posY, width, height, density, bodyType)
	local obj = {}
	posX = posX or 0
	posY = posY or 0
	width = width or 100
	height = height or 100
	density = density or 1
	bodyType = bodyType or "static"
	obj.body = love.physics.newBody(self.physWorld, posX, posY, bodyType)
	obj.shape = love.physics.newRectangleShape(width, height)
	obj.fixture = love.physics.newFixture(obj.body, obj.shape, density)
	obj.mesh = love.graphics.newMesh(4)
	local points = {obj.shape:getPoints()}
	local v = 1
	for i=1,#points,2 do
		obj.mesh:setVertex(v, {points[i],points[i+1]})
		v = v + 1
	end
	obj.fixture:setUserData(obj.mesh)
	
	table.insert(self.objects, obj)
	
	return obj
end

function TestBed:loadWorld()
	log.debug("he plays an old guitar")
	
	-- == basic properties
	self.objects = {}
	
	-- == physicsening
	local gravity = 9.80665 -- :^)
	local gmult = 3 -- this shit is too slow
	self.physWorld = love.physics.newWorld(0, gravity * gmult, true)
	
	local x, y = 0, 0
	local w, h = 1000, 500
	local girth = 30
	self:cheapShape(    x + w/2,       y,     w, girth) -- top border, probably
	self:cheapShape(    x + w/2,   y + h,     w, girth) -- bottom?
	self:cheapShape(    x-girth, y + h/2, girth,     h) -- left?
	self:cheapShape(x + w+girth, y + h/2, girth,     h) -- right?
	
	-- == entities
	self.eWorld = tiny.world(
		require ("esystems.Box2DPhysicsSystem")(self.physWorld),
		require ("esystems.PlayerControlSystem")(),
		require ("esystems.UpdateSystem")(),
		require ("esystems.DrawSystem")()
	)
	
	local Client = require("client")
	local Server = require("server")
	
	local theHost = "localhost"
	local thePort = "27015"
	
	self.theServer = Server("localhost:6789")
	self.theClient = Client("localhost:6789")
	
	-- == player
	--[[
	local Player = require("eentities.Player")
	self.thePlayer = Player({
		x = 100,
		y = 100,
	})
	]]

	self.eWorld:add(self.theServer)
	self.eWorld:add(self.theClient)
	--self.eWorld:add(self.thePlayer)
	local MeshGraph = require("eentities.BlendGraph")
	--self.fpsgraph = MeshGraph()
	self.fpsgraph = MeshGraph(0, love.graphics.getHeight())
	self.eWorld:add(self.fpsgraph)
	
	god = self
end

local nondrawableFilter = tiny.rejectAny("drawable")
function TestBed:update(dt)
	self.physWorld:update(dt)
	self.eWorld:update(dt, nondrawableFilter)
end

--[[
local drawableFilter = function(system, entity)
	log.debug("system: ", system)
	log.debug("entity: ", entity)
	log.debug("hotdog: ", "tasty")
end
]]
local drawableFilter = tiny.requireAny("drawable")
function TestBed:draw()
	self.eWorld:update(0, drawableFilter)
	
	love.graphics.push("all")
	love.graphics.setColor(0, 255, 0)
	for objIndex, theObj in pairs(self.objects) do
		local posx, posy = theObj.body:getPosition() --theObj.body:getWorldCenter()
		local rot = theObj.body:getAngle()
		love.graphics.draw(theObj.mesh, posx, posy, rot)
	end
	--[[
	for bodyIndex, theBody in pairs(self.physWorld:getBodyList()) do
		for fixtureIndex, theFixture in pairs(theBody:getFixtureList()) do
			local posx, posy = theBody:getPosition() --theObj.body:getWorldCenter()
			local rot = theBody:getAngle()
			love.graphics.draw(theFixture:getUserData(), posx, posy, rot)
		end
	end
	]]
	--[[
	for objIndex, theObj in pairs(self.objects) do
		local posx, posy = theObj.body:getPosition() --theObj.body:getWorldCenter()
		local rot = theObj.body:getAngle()
		love.graphics.draw(theObj.mesh, posx, posy, rot)
	end
	]]
	--[[
	for bodyIndex, theBody in pairs(self.physWorld:getBodyList()) do
		for fixtureIndex, theFixture in pairs(theBody:getFixtureList()) do
			-- make the last point the first point to close the shape
			local points = {theBody:getWorldPoints(theFixture:getShape():getPoints())}
			table.insert(points, points[1])
			table.insert(points, points[2])
			--log.trace(theBody.body:getPosition())
			love.graphics.line( points )
		end
	end
	]]
	love.graphics.pop()
end

function TestBed:keypressed(key, code)
	if key == 'escape' then
		self:gotoState('MainMenu')
	end
end

function TestBed:mousepressed(x,y,button)
	if button == "wu" then
		self.camera_z = self.camera_z + 1
	elseif button == "wd" then
		self.camera_z = self.camera_z - 1
	end
end

return TestBed