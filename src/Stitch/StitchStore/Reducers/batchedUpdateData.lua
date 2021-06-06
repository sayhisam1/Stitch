local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)
local HashMappedTrie = require(script.Parent.Parent.Parent.Parent.Shared.HashMappedTrie)

return function(stitch)
	local BatchedActionInterface = t.interface({
		actions = t.table,
	})

	return function(state, batchAction)
		t.strict(BatchedActionInterface)(batchAction)
		debug.profilebegin("batched update data")
		local new_patterns = {}
		for _, action in ipairs(batchAction.actions) do
			local data = action.data
			local uuid = action.uuid

			if not new_patterns[uuid] then
				local new_pattern = Util.shallowCopy(HashMappedTrie.get(state, uuid))
				if not new_pattern then
					continue
				end
				new_pattern["data"] = Util.shallowCopy(new_pattern["data"])
				new_patterns[uuid] = new_pattern
			end

			local pattern_state = new_patterns[uuid]

			for k, v in pairs(data) do
				if v == stitch.None then
					v = nil
				end
				pattern_state["data"][k] = v
			end
		end

		state = HashMappedTrie.setAll(state, new_patterns)
		debug.profileend()
		return state
	end
end
