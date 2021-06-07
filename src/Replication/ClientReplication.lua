return function(stitch, remoteEvent: RemoteEvent)
	local connection = remoteEvent.OnClientEvent:connect(function(request, ...)
		if request == "dispatch" then
			local action = select(1, ...)
			stitch._store:dispatch(action)
		end
	end)
	stitch:on("destroyed", function()
		connection:disconnect()
	end)

	local subscribed = {}
	local function subscribe(pattern)
		if pattern.replicated and not subscribed[pattern.uuid] then
			subscribed[pattern.uuid] = true
			remoteEvent:FireServer("subscribe", pattern.uuid)
		end
	end
	stitch:on("patternConstructed", function(uuid)
		local pattern = stitch:lookupPatternByUuid(uuid)
		subscribe(pattern)
	end)
	for uuid, data in pairs(stitch._store:getAll()) do
		local pattern = stitch:lookupPatternByUuid(uuid)
		subscribe(pattern)
	end
	stitch:on("patternDestroyed", function(uuid)
		if subscribed[uuid] then
			subscribed[uuid] = nil
			remoteEvent:FireServer("unsubscribe", uuid)
		end
	end)
end
