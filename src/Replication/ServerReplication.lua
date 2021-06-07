local Queue = require(script.Parent.Parent.Shared.Queue)
return function(stitch, remoteEvent: RemoteEvent)
	local weak_table = {
		__mode = "kv",
	}
	local subscribers = {}
	local dirty = {}

	stitch:on("patternConstructed", function(pattern_uuid)
		local pattern = stitch:lookupPatternByUuid(pattern_uuid)
		if pattern.replicated then
			subscribers[pattern.uuid] = setmetatable({}, weak_table)
			dirty[pattern.uuid] = false
			-- if we didn't do this, then subscribers would never know to subscribe to patterns attached to patterns!
			if subscribers[pattern.refuuid] then
				for _, player in pairs(subscribers[pattern.refuuid]) do
					remoteEvent:FireClient(player, "dispatch", {
						type = "constructPattern",
						uuid = pattern_uuid,
						refuuid = pattern.refuuid,
						data = pattern.data,
						patternName = pattern.patternName,
					})
				end
			end
		end
	end)

	stitch:on("patternUpdated", function(pattern_uuid)
		dirty[pattern_uuid] = true
	end)

	stitch:on("patternDeconstructed", function(pattern_uuid)
		if not subscribers[pattern_uuid] then
			return
		end
		for _, player in pairs(subscribers[pattern_uuid]) do
			remoteEvent:FireClient(player, "dispatch", {
				type = "deconstructPattern",
				uuid = pattern_uuid,
			})
		end
		dirty[pattern_uuid] = nil
	end)

	local function subscribe(player: Player, pattern: table, construct: bool)
		if not subscribers[pattern.uuid] then
			return
		end
		local action = {
			type = construct and "constructPattern" or "updateData",
			data = pattern.data,
			uuid = pattern.uuid,
			refuuid = construct and pattern.refuuid or nil,
			patternName = construct and pattern.patternName or nil,
		}
		subscribers[pattern.uuid][player] = player
		remoteEvent:FireClient(player, "dispatch", action)
	end
	local function subscribeActions(player: Player, uuid: string)
		if not subscribers[uuid] then
			stitch:error(("%s requested to subscribe to non-existant uuid %s!"):format(player.Name, uuid))
		end

		local queue = Queue.new()
		queue:enqueue(uuid)
		local construct = false
		while queue:peek() do
			local curr_uuid = queue:dequeue()
			local pattern = stitch:lookupPatternByUuid(curr_uuid)
			subscribe(player, pattern, construct)
			for patternName, attached_uuid in pairs(pattern.attached) do
				if attached_uuid ~= curr_uuid then
					queue:enqueue(attached_uuid)
				end
			end
			construct = true
		end
	end

	local function unsubscribe(player: Player, pattern: table)
		if not subscribers[pattern.uuid] then
			return
		end
		subscribers[pattern.uuid][player] = nil
	end
	local function unsubscribeActions(player: Player, uuid: string)
		if not subscribers[uuid] then
			stitch:error(("%s requested to unsubscribe from non-existant uuid %s!"):format(player.Name, uuid))
		end

		local queue = Queue.new()
		queue:enqueue(uuid)
		while queue:peek() do
			local curr_uuid = queue:dequeue()
			local pattern = stitch:lookupPatternByUuid(curr_uuid)
			unsubscribe(player, pattern)
			for patternName, attached_uuid in pairs(pattern.attached) do
				queue:enqueue(attached_uuid)
			end
		end
	end
	local connection = remoteEvent.OnServerEvent:connect(function(player: Player, request: string, ...)
		if request == "subscribe" then
			local uuid = select(1, ...)
			subscribeActions(player, uuid)
		elseif request == "unsubscribe" then
			local uuid = select(1, ...)
			unsubscribeActions(player, uuid)
		end
	end)

	stitch:on("destroyed", function()
		connection:disconnect()
	end)

	local heartbeat = stitch.Heartbeat:connect(function()
		for uuid, isDirty in pairs(dirty) do
			if isDirty then
				dirty[uuid] = false
				local pattern = stitch:lookupPatternByUuid(uuid)
				for _, player in pairs(subscribers[uuid]) do
					remoteEvent:FireClient(player, "dispatch", {
						type = "updateData",
						data = pattern.data,
						uuid = uuid,
					})
				end
			end
		end
	end)

	stitch:on("destroyed", function()
		heartbeat:disconnect()
	end)
end
