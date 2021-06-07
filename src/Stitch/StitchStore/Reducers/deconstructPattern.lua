local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local HashMappedTrie = require(script.Parent.Parent.Parent.Parent.Shared.HashMappedTrie)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)

return function(stitch)
	return function(state, action)
		debug.profilebegin("deconstructPattern")

		local uuid = action.uuid
		local copied = action.copied

		local pattern_state = HashMappedTrie.get(state, uuid)
		if not pattern_state then
			debug.profileend()
			stitch:error(("tried to decontruct non-existent pattern with uuid %s!"):format(uuid))
		end

		for patternName, attached_uuid in pairs(pattern_state["attached"]) do
			debug.profileend()
			stitch:error(("tried to deconstruct %s, but has attached child %s of pattern %s!"):format(
				uuid,
				attached_uuid,
				patternName
			))
		end

		local refuuid = pattern_state.refuuid
		local patternName = pattern_state.patternName

		-- remove from parent
		local ref_state = HashMappedTrie.get(state, refuuid)
		if not ref_state then
			debug.profileend()
			stitch:error(("tried to deconstruct %s, but could not reference parent %s!"):format(uuid, refuuid))
		end

		ref_state = Util.shallowCopy(ref_state, copied)
		ref_state["attached"] = Util.shallowCopy(ref_state["attached"], copied)
		ref_state["attached"][patternName] = nil

		state = HashMappedTrie.set(state, refuuid, ref_state, copied)
		state = HashMappedTrie.set(state, uuid, nil, copied)

		debug.profileend()
		return state
	end
end
