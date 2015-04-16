function love.conf(t)
	t.identity = "m0de"
	t.version = "0.9.2"
	
	t.window.title = t.identity
	t.window.width = 1200
	t.window.height = 672
	t.console           = true
	t.modules.joystick  = true
	t.modules.audio     = true
	t.modules.keyboard  = true
	t.modules.event     = true
	t.modules.image     = true
	t.modules.graphics  = true
	t.modules.timer     = true
	t.modules.mouse     = true
	t.modules.sound     = true
	t.modules.physics   = true
end