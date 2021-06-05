local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)

return function(stitch)
	local WorkingActionInterface = t.interface({
		data = t.table,
		uuid = t.string,
	})

	return function(state, action)
		t.strict(WorkingActionInterface)(action)
		local data = action.data
		local uuid = action.uuid

		if not state[uuid] then
			stitch:error(("tried to update data of non-existant working  with uuid %s!"):format(uuid))
		end

		state[uuid]["data"] = Util.shallowCopy(data)

		return state
	end
end
