local constructPattern = require(script.Parent.constructPattern)

return function(stitch)
	local constructPatternAction = constructPattern(stitch)
	return function(state, action)
		local uuid = action.uuid
		local instance = action.instance

		if typeof(instance) ~= "Instance" then
			debug.profileend()
			error(
				("tried to construct instance pattern with invalid instance %s of type %s!"):format(
					tostring(instance),
					typeof(instance)
				),
				0
			)
		end

		state = constructPatternAction(state, action)
		state["data"][uuid]["instance"] = instance

		return state
	end
end
