-- client.lua
local SharedNet = require("SharedNet")
local Client = class("Client", SharedNet)

function Client:initialize(toconnect)
	SharedNet.initialize(self)
	self.target = toconnect
	self.host = enet.host_create()
	self.server = self.host:connect(self.target)
	self.master = nil
end

function Client:update(dt)
	self.timeout = dt
	local event = self.host:service(self.timeout)
	if event then
		if event.type == "connect" then
			self.master = event.peer
			self:send("Ping")
			--event.peer:send("Ping")
 		elseif event.type == "receive" then
			--log.trace("Got message: ", event.data, event.peer)
			self:onReceive(event.data, event.peer)
		end
	end
end

function Client:send(command, args)
	local ndata = binser.serialize({command=command, args=args})
	if self.master then
		self.master:send(ndata)
	else
		log.fatal("Tried to send a message to a nonexistant server.", command, args)
	end
end

function Client:close()
	self.server:disconnect()
	self.host:flush()
end

return Client