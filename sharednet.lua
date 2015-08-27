-- client.lua
local SharedNet = class("SharedNet")

function SharedNet:initialize()
	self.clientIndex = 0 -- how many clients do we have?
	self.networkCallbacks = {}
	self.isActive = false
	
	self.timeout = 0 --ms
	
	-- we have to specify what we know before we can use them
	self:registerKnownCallbacks()
end

function SharedNet:addNetworkCallback(name, func)
	self.networkCallbacks[name] = func
end

function SharedNet:onReceive(data, peer)
	local ndata = binser.deserialize(data)
	
	if self.networkCallbacks[ndata.command] then
		return self.networkCallbacks[ndata.command](self, ndata.args, peer)
	end
end

function SharedNet:onConnect(event)
	log.trace(self.class.name, "connect", event.peer)
end

function SharedNet:onDisconnect(event)
	log.trace(self.class.name, "disconnect", event.peer)
end

--[[
	Uses Paramters:
	player
	x
	y
]]
local function ncAt(self, args,clientid)
	local x, y = args.x, args.y
	assert(x and y)
	x, y = tonumber(x), tonumber(y)
	-- @TODO: figure out how to get the player ID from here and then adjust their position accordingly
end

local function ncMakePlayer(self, args, clientid)
	for _,player in pairs(args.players) do
		local x, y = tonumber(player.x), tonumber(player.y)
		assert(x and y)
		game.world.players[player.id] = Player(player.x, player.y)
	end
end

local function ncProbe(self, args,clientid) --client->server
	print("[LUBE|server] client ("..clientid..") probing")
	print("<debug>"..self.clientIndex)
	if game.world.players[self.clientIndex] ~= nil then
		print("[LUBE|server] denied probe from client, index occupied ("..clientid..")")
		self:send('ProbeDeny', {reason='index occupied'}, clientid)
	else
		local build = {
			yourID = self.clientIndex + 1,
			numPlayers = #game.world.players,
		}
		self:send('ProbeAccept', build, clientid)
		print("[LUBE|server] accepted probe from client ("..clientid..") id#"..self.clientIndex)
		
		local x, y = game.spawnpoint.x, game.spawnpoint.y
		game.world.players[game.net.clientIndex] = Player(self.clientIndex, x, y)
		
		-- tell him where all the players are
		for k, v in pairs(game.world.players) do
			if k ~= game.net.clientIndex then
				self:send('MakePlayer', {id=k,x=v.x,y=v.y}, clientid)
			end
		end
		
		self.clientIndex = self.clientIndex + 1
	end
end

local function ncProbeAccept(self, args, clientid) --server->client
	print("[LUBE|client] probe accepted id#"..args.player)
	local x, y = args.x, args.y
	assert(x and y)
	x, y = tonumber(x), tonumber(y)
	for k, v in pairs(args.players) do
		if game.world.players[k] ~= nil then
			print("<WARNING|extra>[LUBE|client] suppressed overwriting player index "..args.player)
		else
			print("<debug>[LUBE|client] built fellow client#"..k.." from probe")
			game.world.players[k] = Player(k, v.x, v.y)
		end
	end
	if game.world.players[ndata.params.player] ~= nil then
		print("<WARNING>[LUBE|client] suppressed overwriting player index "..ndata.params.player)
	else
		game.world.players[ndata.params.player] = Player(ndata.params.player, x, y)
	end
	game.net.myID = ndata.params.player
	game.isProbeAccepted = true
	print("[LUBE|client] connection made")
end

local function ncProbeDeny(self, args, clientid) --server->client
	print("[LUBE|client] probe to server denied, unknown error")
	-- @TODO: Unhook everything to a fresh pre-connect state.
end

local function ncUpdate(self, args, clientid) --client->server
	-- @TODO: Do not accept "update" requests from clients.
	for k, v in pairs(game.world.players) do
		if k ~= args.player then
			self:send('at', {player=k,x=v.x,y=v.y}, clientid)
		end
	end
end

local function ncMove(self, args, clientid) --client->server
	local x, y = args.x, args.y
	assert(x and y)
	x, y = tonumber(x), tonumber(y)
	game.world.players[args.player]:move(x,y)
	-- @TODO: announce/relay
end

local function ncPing(self, args, peer)
	--log.fatal(self.class.name, "ping", args, peer)
	self:send("Ping", args, peer)
end

function SharedNet:registerKnownCallbacks()
	--[[
		* ncAt is defined at the local scope so it gets included
		* the reason that this function exists is so it can get called every time we make
		  a new client, it can include all these things (at object instantiation level)
		  and not when the code gets required (important)  
	]]
	self:addNetworkCallback('At', ncAt)
	self:addNetworkCallback('MakePlayer', ncMakePlayer)
	self:addNetworkCallback('Probe', ncProbe)
	self:addNetworkCallback('ProbeAccept', ncProbeAccept)
	self:addNetworkCallback('ProbeDeny', ncProbeDeny)
	self:addNetworkCallback('Update', ncUpdate)
	self:addNetworkCallback('Move', ncMove)
	self:addNetworkCallback('Ping', ncPing)
end

--[[
commander.newCommand("notification", {
  time   = "uint8_t",
  color  = {
    type = "color",
    func = function(cdata)
      return {cdata.r, cdata.g, cdata.b}
    end
  },
  text   = {
    type = "unsigned char",
    size = 180,
    func = ffi.string
  }
})

client_commands.notification = function(data)
  log("Received notification: %s", data.text)
  
  push_notification(data.text, data.time, data.color)
end
]]

return SharedNet