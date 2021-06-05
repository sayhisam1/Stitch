local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local HashMappedTrie = require(script.Parent.Parent.Parent.Parent.Shared.HashMappedTrie)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)

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
		debug.profilebegin("constructPattern")
		t.strict(constructPatternTypes)(action)
		local data = action.data
		local uuid = action.uuid
		local refuuid = action.refuuid
		local pattern = action.pattern

		local pattern_state = HashMappedTrie.get(state, uuid)
		if pattern_state then
			stitch:error(("tried to create Pattern %s with duplicate uuid %s!"):format(tostring(pattern), uuid))
		end

		if uuid ~= refuuid then
			local ref_state = HashMappedTrie.get(state, refuuid)
			if not ref_state then
				stitch:error(("tried to attach to unknown ref %s!"):format(refuuid))
			end
			if ref_state["attached"][pattern.name] then
				stitch:error(("tried to attach duplicate Pattern %s to %s!"):format(tostring(pattern), refuuid))
			end

			local new_ref_state = Util.shallowCopy(ref_state)
			new_ref_state["attached"] = Util.shallowCopy(new_ref_state["attached"])
			new_ref_state["attached"][pattern.name] = uuid
			setmetatable(new_ref_state, getmetatable(ref_state))

			state = HashMappedTrie.set(state, refuuid, new_ref_state)
		end

		state = HashMappedTrie.set(
			state,
			uuid,
			setmetatable({
				data = data,
				attached = {},
				patternName = pattern.name,
				uuid = uuid,
				refuuid = refuuid,
			}, pattern)
		)
		debug.profileend()
		return state
	end
end
