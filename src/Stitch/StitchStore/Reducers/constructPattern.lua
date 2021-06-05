local t = require(script.Parent.Parent.Parent.Parent.Parent.t)

return function(stitch)
	local constructPatternTypes = t.interface({
		pattern = t.interface({
			name = t.string,
		}),
		data = t.table,
		uuid = t.string,
		refuuid = t.string,
	})

	return function(state, action)
		t.strict(constructPatternTypes)(action)
		local data = action.data
		local uuid = action.uuid
		local refuuid = action.refuuid
		local pattern = action.pattern

		if state[uuid] then
			stitch:error(("tried to create Pattern %s with duplicate uuid %s!"):format(tostring(pattern), uuid))
		end

		if uuid ~= refuuid then
			if not state[refuuid] then
				stitch:error(("tried to attach to unknown ref %s!"):format(refuuid))
			end
			if state[refuuid]["attached"][pattern.name] then
				stitch:error(("tried to attach duplicate Pattern %s to %s!"):format(tostring(pattern), refuuid))
			end

			state[refuuid]["attached"][pattern.name] = uuid
		end

		state[uuid] = setmetatable({
			data = data,
			attached = {},
			patternName = pattern.name,
			uuid = uuid,
			refuuid = refuuid,
		}, pattern)

		return state
	end
end
