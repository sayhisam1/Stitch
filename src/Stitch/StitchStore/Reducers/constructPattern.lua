local HashMappedTrie = require(script.Parent.Parent.Parent.Parent.Shared.HashMappedTrie)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)

return function(stitch)
	return function(state, action)
		debug.profilebegin("constructPattern")
		local data = action.data
		local uuid = action.uuid
		local refuuid = action.refuuid
		local patternName = action.patternName
		local copied = action.copied

		local pattern_state = HashMappedTrie.get(state, uuid)
		if pattern_state then
			debug.profileend()
			stitch:error(("tried to create Pattern %s with duplicate uuid %s!"):format(patternName, uuid))
		end

		state = HashMappedTrie.set(state, uuid, {
			data = data,
			attached = {},
			patternName = patternName,
			uuid = uuid,
			refuuid = refuuid,
		}, copied)

		local ref_state = HashMappedTrie.get(state, refuuid)
		if not ref_state then
			debug.profileend()
			stitch:error(("tried to attach to unknown ref %s!"):format(refuuid))
		end
		if ref_state["attached"][patternName] then
			debug.profileend()
			stitch:error(("tried to attach duplicate Pattern %s to %s!"):format(patternName, refuuid))
		end

		local new_ref_state = Util.shallowCopy(ref_state)
		new_ref_state["attached"] = Util.shallowCopy(new_ref_state["attached"])
		new_ref_state["attached"][patternName] = uuid

		state = HashMappedTrie.set(state, refuuid, new_ref_state, copied)

		debug.profileend()
		return state
	end
end
