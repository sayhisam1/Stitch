local t = require(script.Parent.Parent.Parent.Parent.Parent.t)

return function(stitch)
	local deconstructPatternTypes = t.interface({
		uuid = t.string,
	})

	local function deconstruct(state, uuid)
		if not state[uuid] then
			stitch:error(("tried to decontruct non-existent pattern with uuid %s!"):format(uuid))
		end

		local data = state[uuid]
		local refuuid = data.refuuid
		local patternName = data.patternName

		-- remove from parent
		if uuid ~= refuuid then
			state[refuuid]["attached"][patternName] = nil
		end

		-- deconstruct all children
		for attachedPattern, attachedUuid in pairs(state[uuid]["attached"]) do
			state = deconstruct(state, attachedUuid)
		end

		state[uuid] = nil

		return state
	end

	return function(state, action)
		t.strict(deconstructPatternTypes)(action)
		local uuid = action.uuid

		return deconstruct(state, uuid)
	end
end
