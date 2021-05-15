local HttpService = game:GetService("HttpService")

local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)

return function(stitch)
	local WorkingActionInterface = t.interface({
		workingResolvable = t.union(t.string, t.interface({ uuid = t.string })),
	})
	local destroyWorking
	destroyWorking = function(state, action)
		t.strict(WorkingActionInterface)(action)
		local working = stitch._collection:resolveWorking(action.workingResolvable, state)
		local staticPattern = getmetatable(working)
		local uuid = working.uuid

		local refUUID = working.refUUID

		for staticPatternName, uuid in pairs(state["UUIDAttached"][uuid]) do
			state = destroyWorking(state, {
				workingResolvable = uuid,
			})
		end

		state["UUIDAttached"][refUUID] = Util.shallowCopy(state["UUIDAttached"][refUUID])
		state["UUIDAttached"][refUUID][staticPattern.name] = nil

		state["workings"] = Util.shallowCopy(state["workings"])
		state["workings"][uuid] = nil

		state["UUIDAttached"] = Util.shallowCopy(state["UUIDAttached"])
		state["UUIDAttached"][uuid] = nil

		return state
	end
	return destroyWorking
end
