local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)

local ActionInterface = t.interface({
	ref = t.Instance,
})
return function(stitch)
	return function(state, action)
		t.strict(ActionInterface)(action)
		local ref = action.ref
		local uuid = ref:GetAttribute(stitch.instanceUUIDAttributeString)
		if not uuid then
			uuid = HttpService:GenerateGUID(false)
			ref:SetAttribute(stitch.instanceUUIDAttributeString, uuid)
		end
		if t.none(state["UUIDToInstance"][uuid]) then
			print("TAGGING INSTANCE", ref, state["UUIDToInstance"][uuid])
			CollectionService:AddTag(ref, stitch.instanceUUIDTag)
			state["UUIDToInstance"] = Util.shallowCopy(state["UUIDToInstance"])
			state["UUIDToInstance"][uuid] = ref
			state["UUIDAttached"] = Util.shallowCopy(state["UUIDAttached"])
			state["UUIDAttached"][uuid] = {}
		else
			if not state["UUIDToInstance"][uuid] == ref then
				error(("%s Tried to register %s with uuid %s, which is already claimed by %s!"):format(
					stitch.errorPrefix,
					tostring(ref),
					uuid,
					tostring(state["UUIDToInstance"][uuid])
				))
			end
		end
		return state
	end
end
