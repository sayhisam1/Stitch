return function(stitch, remoteEvent: RemoteEvent)
	local connection = remoteEvent.OnClientEvent:connect(function(request, ...)
		if request == "subscribe" then
			local uuid = select(1, ...)
			if not subscribers[uuid] then
				stitch:error(("%s requested to subscribe to non-existant uuid %s!"):format(player.Name, uuid))
			end
			table.insert(subscribers[uuid], player)
		end
	end)
	stitch:on("destroyed", function()
		connection:disconnect()
	end)
end
