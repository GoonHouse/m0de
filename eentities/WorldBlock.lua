local WorldBlock = class("WorldBlock")

function WorldBlock:initialize(args)
	-- Box2DPhysicsSystem
	self.box2dDef = {
		-- constructor stuff
		posX = args.x,
		posY = args.y,
		shape = "rectangle",
		
		-- ???
		debugDraw = true,
	}
	
	self.hitbox = {
		w = args.width,
		h = args.height,
	}
end

function WorldBlock:drawBox2DOutlines(dt)
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

return WorldBlock