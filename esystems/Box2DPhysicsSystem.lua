local Box2DPhysicsSystem = tiny.processingSystem(class "Box2DPhysicsSystem")

function Box2DPhysicsSystem:initialize(box2dWorld)
	self.box2dWorld = box2dWorld
end

Box2DPhysicsSystem.drawable = true --???

Box2DPhysicsSystem.filter = tiny.requireAll("box2dDef", "hitbox")

function Box2DPhysicsSystem:process(e, dt)
	if e.drawBox2DOutlines and e.box2dDef.debugDraw then
		e:drawBox2DOutlines(dt)
	end
end

-- box2d doesn't have the ability to "add" things quite like this so we're just going to
-- leave this commented until I come by a reason to use these

function Box2DPhysicsSystem:onAdd(e)
	--log.debug("Box2DPhysicsSystem:onAdd entity", e)
	--log.debug("Box2DPhysicsSystem:onAdd world?", self.box2dWorld)
	local b2def = e.box2dDef
	local hitbox = e.hitbox
	
	--[[
		unused body properties:
		active,
		angle,
		angularDamping,
		angularVelocity,
		awake,
		bullet,
		fixedRotation,
		gravityScale,
		inertia,
		linearDamping,
		linearVelocity,
		mass,
		position,
		sleepingAllowed,
		userData,
	]]
	
	-- == establish base shape
	-- declare body [reusable]
	e.body = love.physics.newBody(self.box2dWorld, b2def.posX, b2def.posY, b2def.bodyType)
	
	-- make shape [this can be memoized; not passed by reference]
	if b2def.shape == "rectangle" then
		e.shape = love.physics.newRectangleShape(hitbox.w, hitbox.h)
	else
		log.fatal("Tried to create unknown box2d shape", b2def.shape)
	end
	
	-- attach the two [disposable]
	e.fixture = love.physics.newFixture(e.body, e.shape)
	
	-- == set all the special properties
	e.body:setMass(b2def.Mass)
	e.body:setMass(b2def.LinearDamping)
	
	--log.trace(e, "mass", e.body:getMass())
end

function Box2DPhysicsSystem:onRemove(e)
	e.fixture:destroy()
	e.shape:destroy()
	e.body:destroy() --should destroy the fixtures too, but, who knows
end

return Box2DPhysicsSystem