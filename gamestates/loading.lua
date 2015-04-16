local Game = require 'game'
local Loading = Game:addState('Loading')

local loader = require 'lib/love-loader'
local Quad = require 'lib/quad'

local percent = 0
local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()

local function drawLoadingBar()
	local separation = 30;
	local w = screenWidth - 2*separation
	local h = 50;
	local x,y = separation, screenHeight - separation - h;
	love.graphics.rectangle("line", x, y, w, h)

	x, y = x + 3, y + 3
	w, h = w - 6, h - 7

	w = w * (loader.loadedCount / loader.resourceCount)

	love.graphics.rectangle("fill", x, y, w, h)
end

local function processTexture(ressources, ressourceholder)
	for k,v in pairs(ressources.image) do
		if v.quad and type(v.quad) == 'table' then	
			for i,j in pairs(v.quad) do
				ressourceholder.texture[i] = Quad:new( ressourceholder.image[ v[1] ], unpack(j))
			end
		else
			ressourceholder.texture[v[1]] = Quad:new( ressourceholder.image[ v[1] ])
		end
	end
end

function Loading:enteredState( nextscene, ressources, ressourceholder )
	self:log('Entered Loading')

	math.randomseed(os.time())
	
	loader.loadedCount = 0
	loader.resourceCount = 0
	self.fadein = { alpha = 0 }
	-- Title text
--	flux.to(self.fadein, 0.25, { alpha = 1 }):ease("quadin")

	self:log("adding sources ...")
	-- if not already loaded, load ressources
	if ressources and not ressources.done and ressourceholder then
		if ressources.image then
			for k,v in pairs(ressources.image) do
				print(k, v[1], v[2])
				loader.newImage(ressourceholder.image, v[1], v[2])
			end
		end
		if ressources.imagedata then
			for k,v in pairs(ressources.imagedata) do
				print(k, v[1], v[2])
				loader.newImageData(ressourceholder.image, v[1], v[2])
			end
		end
		if ressources.source then
			for k,v in pairs(ressources.source) do
				print(k, v[1], v[2], v[3])
				loader.newSource(ressourceholder.texture, v[1], v[2], v[3])
			end
		end
		if ressources.sounddata then
			for k,v in pairs(ressources.sounddata) do
				print(k, v[1], v[2])
				loader.newSoundData(ressourceholder.texture, v[1], v[2])
			end
		end
		-- mark ressources as loaded
		ressources.done = true
	end

	self:log("start loading")
--	loader.start( function () processTexture(ressources, ressourceholder); self:gotoState( nextscene ) end, print)
	flux.to(self.fadein, 0.35, { alpha = 1 }):ease('linear'):oncomplete(
			function()
				loader.start( 
					function()
						flux.to(self.fadein, 0.35, { alpha = 0 }):ease('linear'):oncomplete(
							function()
								processTexture( ressources, ressourceholder )
								self:gotoState( nextscene )
							end
						)
					end
					, print)
			end
		)
end

function Loading:exitedState()
	love.graphics.setColor(255, 255, 255, 255)
	self:log('Exiting Loading')
end

function Loading:draw()
	love.graphics.setColor(255, 255, 255, self.fadein.alpha * 255)
	
	drawLoadingBar()
	if loader.resourceCount ~= 0 then percent = loader.loadedCount / loader.resourceCount end
	local percentagestring = ("Loading .. %d%%"):format(percent*100)
    love.graphics.print(percentagestring, screenWidth/2-string.len(percentagestring)*2, screenHeight/2)
end

function Loading:update( dt )
	loader.update()
end

return Loading
