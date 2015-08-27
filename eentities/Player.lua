--[[
local assets =  require "src.assets"
local anim8 = require "lib.anim8"
local Bullet = require "src.entities.Bullet"
local TimerEvent = require "src.entities.TimerEvent"
local ScreenSplash = require "src.entities.ScreenSplash"
local gamestate = require "lib.gamestate"
]]

local Player = class("Player")

function Player:initialize(args)
	-- Box2DPhysicsSystem
	self.box2dDef = {
		-- constructor stuff
		posX = args.x,
		posY = args.y,
		shape = "rectangle",
		bodyType = "dynamic",
		
		-- extra properties
		Mass = 30,
		LinearDamping = 0.1,
		
		-- ???
		debugDraw = true,
	}
	
	self.hitbox = {
		w = 10,
		h = 10,
	}
	
	self.platforming = {
		moveSpeed = 1000,
		moveSpeedMax = 200,
		jumpForce = 300,
	}
	
	-- PlayerControlSystem
	self.controlable = true
	--[[
		majorTypes:    Axis, Button
		basicTypes:    key, gamepadButton, analogStick, mouseButton
		advancedTypes: thresholdButton, binaryAxis
	]]
	self.keybinds = {
		moveHorizontal = {
			majorType = "Axis",
			config = {
				{
					type = "binaryAxis",
					vals = {'a', 'd'},
				},
				{
					type = "analogStick",
					vals = {'leftx', 1}
				},
			}
		},
		moveVertical = {
			majorType = "Axis",
			config = {
				{
					type = "binaryAxis",
					vals = {'w', 's'},
				},
				{
					type = "analogStick",
					vals = {'lefty', 1}
				},
			}
		},
		jump = {
			majorType = "Button",
			config = {
				{
					type = "key",
					vals = {'w'},
				},
				{
					type = "key",
					vals = {'space'},
				},
				{
					type = "gamepadButton",
					vals = {'a', 1}
				},
			}
		},
	}
	-- @granted .controls
	
	--[[
	self.isAlive = true
	self.isPlayer = true
	self.isSolid = true
	self.controlable = true
	--self.sprite = assets.img_catandcannon
	self.fg = true
	--local g = anim8.newGrid(32, 32, assets.img_cat:getWidth(), assets.img_cat:getHeight())
	--self.animation_stand = anim8.newAnimation(g('1-1', 1), 0.1)
	--self.animation_walk = anim8.newAnimation(g('2-5', 1), 0.1)
	--self.animation = self.animation_stand
	self.health = 100
	self.maxHealth = 100
	self.shotTimer = 0
	self.shotInterval = 0.45
	self.gunAngle = 2 * math.pi
	self.hasGun = true
	]]
end

function Player:jump(dt)
	-- joke's on you, we're spinning instead
	local b = self.body
	if b then
		local gx, gy = b:getWorld():getGravity()
		local m = b:getMass()
		b:applyForce(
			(gx * m * self.platforming.jumpForce),
			-(gy * m * self.platforming.jumpForce)
		)
		--b:setAngularVelocity( b:getAngularVelocity() + self.platforming.spinSpeed*dt )
	end
end

function Player:drawBox2DOutlines(dt)
	love.graphics.push("all")
	love.graphics.setColor(0, 0, 255)
	love.graphics.setLineWidth(20)
	for fixtureIndex, theFixture in pairs(self.body:getFixtureList()) do
		-- make the last point the first point to close the shape
		local points = {self.body:getWorldPoints(theFixture:getShape():getPoints())}
		table.insert(points, points[1])
		table.insert(points, points[2])
		
		love.graphics.line( points )
	end
	love.graphics.pop()
end

function Player:draw(dt)
	self:drawBox2DOutlines(dt)
	--[[
	if self.hasGun then
		local p = self.animation.position
		local dy = (p ~= 2 and p ~= 3) and 0 or -1
		local dx = self.platforming.direction == 'l' and 2 or -2
		love.graphics.draw(assets.img_gun, self.pos.x + 16 + dx, self.pos.y + 10 + dy, self.gunAngle - math.pi / 4)
	end
	]]
end

function Player:onHit()
	self.isAlive = nil
	self.lifetime = 0.25
	self.fadeTime = 0.25
	self.alpha = 1
	self.ai = nil
	self.platforming.moving = false
	self.vel.y = -300
	self.vel.x = (math.random() - 0.5) * 400
	self.controlable = nil
	assets.snd_meow:play()
	world:add(self)
	local n = gamestate.current().score
	local message = "You Died."
	if n == 0 then message = "You Failed Pretty Hard."
	elseif n < 10 then message = "You Killed Some Pigs and They Killed you Back."
	elseif n < 30 then message = "That's a lot of Bacon."
	elseif n < 100 then message = "You a crazy Pig Killer."
	else message = "Pigpocolypse." end

	world:add(TimerEvent(1.2, function() world:add(ScreenSplash(0.5, 0.4, message .. " Press Space to Try Again.", 800)) end))
	gamestate.current().isSpawning = false
	gamestate.current().restartOnSpace = true
end

function Player:onCollision(col)
	if self.isAlive and col.other.isEnemy and col.other.isAlive then
		self:onHit()
	end
end

-- the implications of this living here are perplexing due to how it might handle subclassing et al
function Player:controlUpdate(dt)
	local controls = self.controls
	
	if controls.jump:pressed() then
		--log.debug("horses")
		self:jump(dt)
	end
	
	-- throw that ass in a circle
	if self.body then
		local velx, vely = self.body:getLinearVelocity()
		local nvelx, nvely = velx, vely
		
		--[[
			player traveling: 90
			max speed       : 120
			update force    : 40
		]]
		local hspeed = self.platforming.moveSpeed * controls.moveHorizontal:getValue() * dt
		local vspeed = self.platforming.moveSpeed * controls.moveVertical:getValue() * dt
		
		nvelx = nvelx + hspeed
		
		-- only allow returning downward
		if controls.moveVertical:getValue() > 0 then
			nvely = nvely + vspeed
		end
		
		-- don't set the velocity of something that didn't move
		if nvelx ~= velx or nvely ~= vely then
			self.body:setLinearVelocity(nvelx, nvely)
		end
	end
end

return Player