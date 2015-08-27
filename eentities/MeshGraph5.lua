--[[
	MeshGraph, a library to draw meshes as graphs.
	
	@TODOS: a whole bunch of stuff
	* view scaling
]]

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
	self.pointSpacing = self.width / self.points+2
	
	-- == draw options
	self.graphColor = {0, 0, 255, 255}
	
	-- == internal values
	-- set to "fan" for a lag-o-meter
	self.mesh = love.graphics.newMesh(self.points+2, "fan") -- 2 extra for start/end points to keep the shape solid
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
	
	self.verts[1][1] = self.verts[2][1]
	self.verts[self.points+2][1] = self.verts[self.points+1][1]
	self.verts[self.points+2][2] = 0
	
	self.mesh:setVertices(self.verts)
	
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
		-- we use 3 to skip the first index with enough room to still reach back one
		for j=2,self.points do
			local x,y,u,v,r,g,b,a = self.mesh:getVertex(j+1)
			log.trace("honk",j,"<-",j+1,x,y,u,v,r,g,b,a)
			--log.trace("honk", j, "<-", j+1, self.verts[j][2], "<-", nextVert[2])
			self.mesh:setVertex(j, x,y, u,v, r,g,b,a)
			--self.mesh:setVertex(j, self.verts[j][1], nextVert[2], nextVert[3], nextVert[4], nextVert[5], nextVert[6], nextVert[7], nextVert[8])
		end
		
		for i=1,#newVals do
			local indice = self.points - (i-1) + 1
			--self.verts[self.points - (i-1) - 1][2] = newVals[i]
			local theVert = self.verts[indice]
			log.trace("bjork", i, newVals[i], indice, theVert[2])
			self.mesh:setVertex(indice, theVert[1], newVals[i], theVert[3], theVert[4], theVert[5], theVert[6], theVert[7], theVert[8])
		end
	end
end

-- draws all the graphs in your list
function MeshGraph:draw(dt)
	local x = self.x
	--x = x - self.verts[1][1]
	love.graphics.draw(self.mesh, x, self.y, 0, 1, -1)
	-- flip the y scale because half the time these numbers are gonna be positive
end

return MeshGraph