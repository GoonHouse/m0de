local MeshGraph = class("MeshGraph")

function MeshGraph:initialize(x, y, width)
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
	self.mesh = love.graphics.newMesh(self.points+2) -- 2extra for start/end points to keep the shape solid
	self.verts = {}
	
	-- fill out the points with initial values for visibility
	for i=1,self.points+2 do
		table.insert(self.verts, {
			i*self.pointSpacing,
			i,
			0,0,
			self.graphColor[1],
			self.graphColor[2],
			self.graphColor[3],
			self.graphColor[4],
		})
	end
	
	-- reset start/end points
	self.verts[1][1] = self.verts[2][1]
	self.verts[self.points+2][1] = self.verts[self.points+1][1]
	self.verts[self.points+2][2] = 0
	
	self.mesh:setVertices(self.verts)
	
	-- call the police, I have a number that never stops growing integer
	-- (this could probably be gotten from the x value of the last vertex or something)
	--self.valuesRecorded = 0
	self.currentTime = 0
end

function MeshGraph:getValues(dt, reps)
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

function MeshGraph:updateClock(dt)
	self.currentTime = self.currentTime + dt
	local reps = math.floor(self.currentTime/self.delay)
	self.currentTime = self.currentTime - self.delay*reps
	
	return reps
end

function MeshGraph:update(dt)
	-- update the current time of the graph
	local reps = self:updateClock(dt)
	
	-- get values, we pass dt & reps for the sake of the program
	local newVals = self:getValues(dt, reps)
	
	if newVals and #newVals > 0 then 
		-- add any new values as verts
		for i=#newVals,1 do
			
			local x = self.verts[self.points+1-i][1] + self.pointSpacing
			--insert before the very last point
			table.insert(self.verts, 2, {
				x,
				newVals[i],
				0,0,
				self.graphColor[1],
				self.graphColor[2],
				self.graphColor[3],
				self.graphColor[4]
			})
		
			-- remove the vert at the end before the cap
			table.remove(self.verts, self.points+1)
		end
		--self.valuesRecorded = self.valuesRecorded + #newVals
		
		-- set the beginning and end positions down to ensure filled draw still works
		self.verts[1][1] = self.verts[2][1]
		self.verts[self.points+2][1] = self.verts[self.points+1][1]
		
		-- set verts
		self.mesh:setVertices(self.verts)
	end
end

-- draws all the graphs in your list
function MeshGraph:draw(dt)
	local x = self.x
	--if self.valuesRecorded > self.points then
		x = x - self.verts[1][1]
	--end
	love.graphics.draw(self.mesh, x, self.y, 0, 1, -1)
	-- flip the y scale because half the time these numbers are gonna be positive
end

return MeshGraph