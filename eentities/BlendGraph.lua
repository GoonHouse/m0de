local MeshGraph = require("eentities.MeshGraph4")

local BlendGraph = class("BlendGraph", MeshGraph)

function BlendGraph:initialize(...)
	MeshGraph.initialize(self, ...)
	
	self.upColor = {255,0,0,20}
	self.downColor = {0,255,0,20}
	self.lastColor = self.downColor
end

function BlendGraph:update(dt)
	-- update the current time of the graph
	local reps = self:updateClock(dt)
	
	-- get values, we pass dt & reps for the sake of the program
	local newVals = self:getValues(dt, reps)
	
	if newVals and #newVals > 0 then 
		for j=3,self.points+1+#newVals do
			self.verts[j-1][2] = self.verts[j][2]
			self.verts[j-1][3] = self.verts[j][3]
			self.verts[j-1][4] = self.verts[j][4]
			self.verts[j-1][5] = self.verts[j][5]
			self.verts[j-1][6] = self.verts[j][6]
			self.verts[j-1][7] = self.verts[j][7]
			self.verts[j-1][8] = self.verts[j][8]
		end
		
		for i=1,#newVals do
			local dex = self.points+1 - (i-1)
			if self.verts[dex-1][2] < newVals[i] then
				self.verts[dex][8] = self.downColor[4]
				self.verts[dex][7] = self.downColor[3]
				self.verts[dex][6] = self.downColor[2]
				self.verts[dex][5] = self.downColor[1]
				self.lastColor = self.downColor
			elseif self.verts[dex-1][2] > newVals[i] then
				self.verts[dex][8] = self.upColor[4]
				self.verts[dex][7] = self.upColor[3]
				self.verts[dex][6] = self.upColor[2]
				self.verts[dex][5] = self.upColor[1]
				self.lastColor = self.upColor
				--[[
			else
				self.verts[dex][8] = self.lastColor[4]
				self.verts[dex][7] = self.lastColor[3]
				self.verts[dex][6] = self.lastColor[2]
				self.verts[dex][5] = self.lastColor[1]
				]]
			end
			self.verts[dex][2] = newVals[i]
		end
		
		self.mesh:setVertices(self.verts)
	end
end

function BlendGraph:getValues(dt, reps)
	-- if our update rate somehow stalls us for more than a single reporting period,
	-- pad the graph by reporting the same FPS we had previously
	reps = reps or 0
	local retVals = {}
	for i=1,reps do
		--uncomment for more useful statistics
		--table.insert(retVals, love.timer.getAverageDelta()*1000*30)
		table.insert(retVals, collectgarbage("count")*0.1024)
	end
	-- not averaging these could probably make things look inaccurate in the event of immense lag
	return retVals
end

return BlendGraph