--local assets = require "src.assets"
--local Bullet = require "src.entities.Bullet"

-- @TODO: Optimize by only keeping track of buttons that must be updated.

local PlayerControlSystem = tiny.processingSystem(class "PlayerControlSystem")

PlayerControlSystem.filter = tiny.requireAll("controlable", "keybinds")

function PlayerControlSystem:process(e, dt)
	-- mandatory fun
	e:tactileUpdate(dt)
	-- player controls processing
	e:controlUpdate(dt)
end

-- only update buttons.
local function tactileUpdate(self, dt)
	for _, button in pairs(self.buttons) do
		button:update(dt)
	end
end

function PlayerControlSystem:onAdd(e)
	local kb = e.keybinds
	e.controls = {}
	e.buttons = {}
	for bindName, bindDef in pairs(kb) do
		local pool = {}
		for bindIndex, bindConfig in pairs(bindDef.config) do
			local vals = lume.clone(bindConfig.vals)
			
			-- special exception because they use sub-types and such
			if bindConfig.type == "binaryAxis" then
				vals[1] = tactile.key(bindConfig.vals[1])
				vals[2] = tactile.key(bindConfig.vals[2])
			elseif bindConfig.type == "thresholdButton" then
				vals[1] = tactile.analogStick(unpack(bindConfig.vals[1]))
			end
			
			-- dynamically create the list of possible binds per category
			local metacontrol = tactile[bindConfig.type](unpack(vals))
			--log.debug("meta", metacontrol)
			--print_r(metacontrol)
			table.insert(pool, metacontrol)
		end
		
		-- dynamically create the control type from the established pool
		local control = tactile['new' .. bindDef.majorType](unpack(pool))
		e.controls[bindName] = control
		
		if bindDef.majorType == "Button" then
			e.buttons[bindName] = e.controls[bindName]
		end
	end
	
	e.tactileUpdate = tactileUpdate
end

return PlayerControlSystem
