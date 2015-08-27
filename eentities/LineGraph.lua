--[[
	MeshGraph, a library to draw meshes as graphs.
	
	@TODOS: a whole bunch of stuff
	* view scaling
	
	@DONE:
	* fix the initial draw being so damn fucked up, remove the necessity
	* reduce the necessity of valuesRecorded
]]

local LineGraph = class("LineGraph")

function LineGraph:initialize(x, y, width)
	-- == location
	self.x = x or 400
	self.y = y or 500 --love.graphics.getHeight()
	self.width = width or 100
	--self.height = height or 300
	
	-- == update info
	self.delay = 0.5
	self.points = self.width
	self.pointSpacing = self.width / self.points
	
	-- == draw options
	self.graphColor = {0, 0, 255, 255}
	
	-- == internal values
	self.verts = {}
	
	-- fill out the points with initial values for visibility
	for i=1,(self.points)*2,2 do
		self.verts[i] = self.x + i*self.pointSpacing
		self.verts[i+1] = self.y - i
	end
	
	-- call the police, I have a number that never stops growing integer
	-- (this could probably be gotten from the x value of the last vertex or something)
	--self.valuesRecorded = 0
	self.currentTime = 0
end

function LineGraph:getValues(dt, reps)
	-- if our update rate somehow stalls us for more than a single reporting period,
	-- pad the graph by reporting the same FPS we had previously
	reps = reps or 0
	local retVals = {}
	for i=1,reps do
		--uncomment for more useful statistics
		--table.insert(retVals, love.timer.getAverageDelta()*1000*30)
		table.insert(retVals, love.timer.getFPS())
	end
	-- not averaging these could probably make things look inaccurate in the event of immense lag
	return retVals
end

function LineGraph:updateClock(dt)
	self.currentTime = self.currentTime + dt
	local reps = math.floor(self.currentTime/self.delay)
	self.currentTime = self.currentTime - self.delay*reps
	
	return reps
end

function LineGraph:update(dt)
	-- update the current time of the graph
	local reps = self:updateClock(dt)
	
	-- get values, we pass dt & reps for the sake of the program
	local newVals = self:getValues(dt, reps)
	
	if newVals and #newVals > 0 then 
		-- add any new values as verts
		
		--[[
			shift the Y values back a single position
			start at the Nth+1 Y, to prevent nestling loops
		]]
		for j=2+(#newVals*2),self.points*2,2 do
			self.verts[j-2] = self.verts[j]
		end
		--[[
			the verts table contains twice as many entries as we do points
			get to the end, step back by X values * 2 to align ourself to the actual "point"
			we do not need to add or subtract because this aligns us with the final value
			
			invert the value because our Y is flipped
		]]
		for i=1,#newVals do
			self.verts[self.points*2 - (i-1)*2] = self.y - newVals[i]
		end
	end
end

-- draws all the graphs in your list
function LineGraph:draw(dt)
	love.graphics.setColor(self.graphColor)
	love.graphics.line(self.verts)
end

return LineGraph