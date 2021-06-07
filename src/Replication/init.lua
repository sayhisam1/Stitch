local RunService = game:GetService("RunService")
return function(stitch)
	local remoteEvent
	if RunService:IsServer() then
		remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = stitch.namespace
		remoteEvent.Parent = script
		local ServerReplication = require(script.ServerReplication)
		ServerReplication(stitch, remoteEvent)
	else
		remoteEvent = script:WaitForChild(stitch.namespace)
		local ClientReplication = require(script.ClientReplication)
		ClientReplication(stitch, remoteEvent)
	end

	stitch:on("destroyed", function()
		remoteEvent:destroy()
		remoteEvent = nil
	end)
end
