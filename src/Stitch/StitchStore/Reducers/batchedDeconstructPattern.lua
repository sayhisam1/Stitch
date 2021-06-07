local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)
local HashMappedTrie = require(script.Parent.Parent.Parent.Parent.Shared.HashMappedTrie)

return function(stitch)
	local BatchedActionInterface = t.interface({
		actions = t.table,
	})

	return function(state, batchAction)
		t.strict(BatchedActionInterface)(batchAction)
		debug.profilebegin("batched deconstruct pattern")
		local new_patterns = {}
		for _, action in ipairs(batchAction.actions) do
			local uuid = action.uuid
			new_patterns[uuid] = HashMappedTrie.None
		end
		-- loop through again to remove parent attached
		-- need 2 loops so that we only remove from parents who themselves are not being removed!
		for _, action in ipairs(batchAction.actions) do
			local uuid = action.uuid
			local data = HashMappedTrie.get(state, uuid)
			local refuuid = data.refuuid
			if not new_patterns[refuuid] then
				local new_ref_data = Util.shallowCopy(HashMappedTrie.get(state, refuuid))
				new_ref_data["attached"] = Util.shallowCopy(new_ref_data["attached"])
				new_ref_data["attached"][data.patternName] = nil
				new_patterns[refuuid] = new_ref_data
			end
		end
		state = HashMappedTrie.setAll(state, new_patterns)
		debug.profileend()
		return state
	end
end
