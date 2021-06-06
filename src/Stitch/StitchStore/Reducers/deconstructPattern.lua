local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local HashMappedTrie = require(script.Parent.Parent.Parent.Parent.Shared.HashMappedTrie)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)

return function(stitch)
	local deconstructPatternTypes = t.interface({
		uuid = t.string,
	})

	local function deconstruct(state, uuid)
		local pattern_state = HashMappedTrie.get(state, uuid)
		if not pattern_state then
			stitch:error(("tried to decontruct non-existent pattern with uuid %s!"):format(uuid))
		end

		local refuuid = pattern_state.refuuid
		local patternName = pattern_state.patternName

		-- remove from parent
		local ref_state = HashMappedTrie.get(state, refuuid)
		ref_state = Util.shallowCopy(ref_state)
		ref_state["attached"] = Util.shallowCopy(ref_state["attached"])
		ref_state["attached"][patternName] = nil
		state = HashMappedTrie.set(state, refuuid, ref_state)

		-- deconstruct all children
		pattern_state = HashMappedTrie.get(state, uuid)
		for attachedPattern, attachedUuid in pairs(pattern_state["attached"]) do
			state = deconstruct(state, attachedUuid)
		end

		state = HashMappedTrie.set(state, uuid, nil)

		return state
	end

	return function(state, action)
		t.strict(deconstructPatternTypes)(action)
		debug.profilebegin("deconstructPattern")
		local uuid = action.uuid

		state = deconstruct(state, uuid)
		debug.profileend()
		return state
	end
end
