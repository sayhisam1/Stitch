local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)

return function(stitch)
	return function(state, action)
		debug.profilebegin("deconstructPattern")

		local uuid = action.uuid
		local copied = action.copied

		local pattern_state = state["data"][uuid]
		if not pattern_state then
			debug.profileend()
			error(("tried to decontruct non-existent pattern with uuid %s!"):format(uuid), 0)
		end

		for patternName, attachedUuid in pairs(pattern_state["attached"]) do
			-- skip root patterns
			if attachedUuid ~= uuid then
				debug.profileend()
				error(
					("tried to deconstruct %s, but has attached child %s of pattern %s!"):format(
						uuid,
						attachedUuid,
						patternName
					),
					0
				)
			end
		end

		local refuuid = pattern_state.refuuid
		local patternName = pattern_state.patternName

		-- remove from parent
		local ref_state = state["data"][refuuid]
		if not ref_state then
			debug.profileend()
			error(("tried to deconstruct %s, but could not reference parent %s!"):format(uuid, refuuid), 0)
		end

		state = Util.shallowCopyOnce(state, copied)
		state["data"] = Util.shallowCopyOnce(state["data"], copied)
		ref_state = Util.shallowCopyOnce(ref_state, copied)
		ref_state["attached"] = Util.shallowCopyOnce(ref_state["attached"], copied)
		ref_state["attached"][patternName] = nil

		state["data"][refuuid] = ref_state
		state["data"][uuid] = nil

		debug.profileend()
		return state
	end
end
