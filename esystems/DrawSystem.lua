local DrawSystem = tiny.processingSystem(class "DrawSystem")

DrawSystem.filter = tiny.requireAll("draw")

DrawSystem.drawable = true

function DrawSystem:process(e, dt)
	e:draw(dt)
end

return DrawSystem
