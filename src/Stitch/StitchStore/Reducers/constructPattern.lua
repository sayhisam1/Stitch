local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)

return function(stitch)
	return function(state, action)
		debug.profilebegin("constructPattern")
		local data = action.data
		local uuid = action.uuid
		local refuuid = action.refuuid
		local patternName = action.patternName
		local copied = action.copied

		local existing_pattern = state["data"][uuid]
		if existing_pattern then
			debug.profileend()
			stitch:error(("tried to create Pattern %s with duplicate uuid %s!"):format(patternName, uuid))
		end

		if refuuid ~= uuid then
			local ref_state = state["data"][refuuid]
			if not ref_state then
				debug.profileend()
				stitch:error(("tried to attach to unknown ref %s!"):format(refuuid))
			end
			if ref_state["attached"][patternName] then
				debug.profileend()
				stitch:error(("tried to attach duplicate Pattern %s to %s!"):format(patternName, refuuid))
			end
		end

		state = Util.shallowCopyOnce(state, copied)
		state["data"] = Util.shallowCopyOnce(state["data"], copied)
		state["data"][uuid] = {
			data = data,
			attached = {},
			patternName = patternName,
			uuid = uuid,
			refuuid = refuuid,
		}

		local new_ref_state = Util.shallowCopyOnce(state["data"][refuuid], copied)
		new_ref_state["attached"] = Util.shallowCopyOnce(new_ref_state["attached"], copied)
		new_ref_state["attached"][patternName] = uuid

		state["data"][refuuid] = new_ref_state
		debug.profileend()
		return state
	end
end
