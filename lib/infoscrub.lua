--[[
	this is a lib to pull relevant info from a computer in a crash log,
	if you use it to be a jackass I will frown at you so hard
	let me tell you
]]

local infoscrub = {
	_VERSION = "infoscrub v1.0.0",
}

function infoscrub:getExternalIP()
	http = require("socket.http"); 
	local b,c,h = http.request(
		"http://ipv4bot.whatismyipaddress.com", --url
		nil, --sink
		"GET", --method
		{ --headers
			"User-Agent: ".self._VERSION,
		}
	)
	local ip
	if b then
		ip = b
	else
		-- I mean, we probably shouldn't error
		-- 'cause in the context of things, we already did
		ip = "Unable To Determine External IP"
	end
	return ip
end

return infoscrub