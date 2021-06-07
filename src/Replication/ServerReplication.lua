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
	end)

	local function subscribeActions(player: Player, uuid: string)
		if not subscribers[uuid] then
			stitch:error(("%s requested to subscribe to non-existant uuid %s!"):format(player.Name, uuid))
		end

		local queue = {}
		local left = 1
		local right = 1
		table.insert(queue, right, uuid)
		right += 1
		local construct = false
		local actions = {}
		while left ~= right do
			local pattern = stitch:lookupPatternByUuid(queue[left])
			left += 1
			local action
			if construct then
				action = {
					type = "constructPattern",
					data = pattern.data,
					uuid = pattern.uuid,
					refuuid = pattern.refuuid,
					patternName = pattern.patternName,
				}
			else
				action = {
					type = "updateData",
					data = pattern.data,
					uuid = pattern.uuid,
				}
			end
			subscribers[uuid][player] = player
			table.insert(actions, action)
			for patternName, attached_uuid in pairs(pattern.attached) do
				if subscribers[attached_uuid] then
					construct = true
					table.insert(queue, right, attached_uuid)
					right += 1
				end
			end
		end
		remoteEvent:FireClient(player, "dispatch", unpack(actions))
	end

	local connection = remoteEvent.OnServerEvent:connect(function(player: Player, request: string, ...)
		if request == "subscribe" then
			local uuid = select(1, ...)
			subscribeActions(player, uuid)
		elseif request == "unsubscribe" then
			local uuid = select(1, ...)
			if not subscribers[uuid] then
				stitch:error(("%s requested to unsubscribe to non-existant uuid %s!"):format(player.Name, uuid))
			end
			subscribers[uuid][player] = nil
		end
	end)
	stitch:on("destroyed", function()
		connection:disconnect()
	end)

	local function issueAction(action)
		local uuid = action.uuid
		if subscribers[uuid] then
			for _, player in pairs(subscribers[uuid]) do
				remoteEvent:FireClient(player, "dispatch", action)
			end
		end
	end
end
