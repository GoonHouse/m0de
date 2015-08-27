-- server.lua
local SharedNet = require("SharedNet")
local Server = class("Server", SharedNet)

function Server:initialize(toconnect)
	SharedNet.initialize(self)
	self.target = toconnect
	self.host = enet.host_create(self.target)
	
	self.peers = {}
end

function Server:update(dt)
	self.timeout = dt
	local event = self.host:service(self.timeout)
	if event then
		if event.type == "connect" then
			table.insert(self.peers, event.peer)
			self:onConnect(event)
		elseif event.type == "receive" then
			self:onReceive(event.data, event.peer)
		elseif event.type == "disconnect" then
			self:onDisconnect(event)
		end
	end
end

function Server:send(command, args, peer)
	local ndata = binser.serialize({command=command, args=args})
	peer:send(ndata)
end

return Server