local HttpService = game:GetService("HttpService")

local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)
local registerInstanceActionCreator = require(script.Parent.registerInstance)

return function(stitch)
	local WorkingActionInterface = t.interface({
		patternResolvable = t.union(t.string, t.interface({ name = t.string })),
		data = t.optional(t.table),
		uuid = t.optional(t.string),
		ref = t.union(t.string, t.Instance, t.interface({ uuid = t.string })),
	})

	local registerInstance = registerInstanceActionCreator(stitch)
	return function(state, action)
		t.strict(WorkingActionInterface)(action)
		local staticPattern = stitch._collection:resolveOrErrorPattern(action.patternResolvable, state)
		local data = action.data or {}
		local uuid = action.uuid or HttpService:GenerateGUID(false)
		local ref = action.ref

		if state["workings"][uuid] then
			error(("%s Tried to create Working of Pattern %s with duplicate id %s!"):format(
				stitch.errorPrefix,
				tostring(staticPattern),
				uuid
			))
		end

		-- Only store refs as uuids
		local refUUID = ref
		if t.interface({ uuid = t.string })(ref) then
			refUUID = ref.uuid
		elseif t.Instance(ref) then
			state = registerInstance(state, {
				ref = ref,
			})
			refUUID = stitch._collection:getInstanceUUID(ref)
		end

		if state["UUIDAttached"][refUUID][staticPattern.name] then
			error(("%s Tried to attach Working of duplicate pattern %s to ref %s"):format(
				stitch.errorPrefix,
				staticPattern.name,
				tostring(ref)
			))
		end
		-- Add to ref's attached list
		state["UUIDAttached"][refUUID] = Util.shallowCopy(state["UUIDAttached"][refUUID])
		state["UUIDAttached"][refUUID][staticPattern.name] = uuid

		if state["workings"][uuid] then
			error(("%s Tried to create Working %s with duplicate UUID %s"):format(
				stitch.errorPrefix,
				staticPattern.name,
				uuid
			))
		end
		local working = staticPattern.new()
		working.private = {}
		working.data = data
		working.uuid = uuid
		working.refUUID = refUUID
		working.isInstanceRef = t.Instance(ref)

		state["workings"] = Util.shallowCopy(state["workings"])
		state["workings"][uuid] = working

		state["UUIDAttached"] = Util.shallowCopy(state["UUIDAttached"])
		state["UUIDAttached"][uuid] = {}

		return state
	end
end
