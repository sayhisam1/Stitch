local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)
local HashMappedTrie = require(script.Parent.Parent.Parent.Parent.Shared.HashMappedTrie)

return function(stitch)
	local WorkingActionInterface = t.interface({
		data = t.table,
		uuid = t.string,
	})

	return function(state, action)
		t.strict(WorkingActionInterface)(action)
		debug.profilebegin("update data")
		local data = action.data
		local uuid = action.uuid

		local pattern_state = HashMappedTrie.get(state, uuid)
		if not pattern_state then
			stitch:error(("tried to update data of non-existant working  with uuid %s!"):format(uuid))
		end

		local new_pattern_state = Util.shallowCopy(pattern_state)
		new_pattern_state["data"] = Util.shallowCopy(pattern_state["data"])
		for k, v in pairs(data) do
			if v == stitch.None then
				v = nil
			end
			new_pattern_state["data"][k] = v
		end
		state = HashMappedTrie.set(state, uuid, new_pattern_state)
		debug.profileend()
		return state
	end
end
