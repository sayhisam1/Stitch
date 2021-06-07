local HashMappedTrie = require(script.Parent.Parent.Parent.Parent.Shared.HashMappedTrie)

return function(stitch)
	return function(state, action)
		debug.profilebegin("updateData")
		local data = action.data
		local key = action.key
		local value = action.value
		local uuid = action.uuid
		local copied = action.copied
		local pattern_state = HashMappedTrie.get(state, uuid)
		if not pattern_state then
			debug.profileend()
			stitch:error(("tried to update data of non-existant working  with uuid %s!"):format(uuid))
		end

		-- local new_pattern_state = Util.shallowCopyOnce(pattern_state, copied)
		-- new_pattern_state["data"] = Util.shallowCopyOnce(pattern_state["data"], copied)
		if data then
			for k, v in pairs(data) do
				if v == stitch.None then
					v = nil
				end
				pattern_state["data"][k] = v
			end
		elseif key then
			pattern_state["data"][key] = value
		else
			stitch:error("did not receive values to update!")
		end

		state = HashMappedTrie.set(state, uuid, pattern_state, copied)
		debug.profileend()
		return state
	end
end
