local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local HashMappedTrie = require(script.Parent.Parent.Parent.Parent.Shared.HashMappedTrie)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)

return function(stitch)
	local constructPatternTypes = t.interface({
		patternName = t.string,
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
		local patternName = action.patternName

		local pattern_state = HashMappedTrie.get(state, uuid)
		if pattern_state then
			stitch:error(("tried to create Pattern %s with duplicate uuid %s!"):format(patternName, uuid))
		end

		state = HashMappedTrie.set(state, uuid, {
			data = data,
			attached = {},
			patternName = patternName,
			uuid = uuid,
			refuuid = refuuid,
		})

		local ref_state = HashMappedTrie.get(state, refuuid)
		if not ref_state then
			stitch:error(("tried to attach to unknown ref %s!"):format(refuuid))
		end
		if ref_state["attached"][patternName] then
			stitch:error(("tried to attach duplicate Pattern %s to %s!"):format(patternName, refuuid))
		end

		local new_ref_state = Util.shallowCopy(ref_state)
		new_ref_state["attached"] = Util.shallowCopy(new_ref_state["attached"])
		new_ref_state["attached"][patternName] = uuid

		state = HashMappedTrie.set(state, refuuid, new_ref_state)

		debug.profileend()
		return state
	end
end
