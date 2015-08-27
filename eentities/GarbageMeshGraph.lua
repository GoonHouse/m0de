local MeshGraph = require("eentities.MeshGraph4")

local GarbageMeshGraph = class("GarbageMeshGraph", MeshGraph)

function GarbageMeshGraph:getValues(dt, reps)
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

return GarbageMeshGraph