local t = require(script.Parent.Parent.Parent.Parent.Parent.t)
local Util = require(script.Parent.Parent.Parent.Parent.Shared.Util)
local Types = require(script.Parent.Parent.Parent.Types)
local Pattern = require(script.Parent.Parent.Parent.Pattern)

local PatternActionInterface = t.interface({
	patternDefinition = Types.PatternDefinition,
})
return function(stitch)
	return function(state, action)
		t.strict(PatternActionInterface)(action)
		local patternDefinition = action.patternDefinition
		t.strict(t.none)(state["patterns"][patternDefinition.name])

		patternDefinition = setmetatable(Util.shallowCopy(patternDefinition), Pattern)
		patternDefinition.__index = patternDefinition
		patternDefinition.__tostring = Pattern.__tostring
		patternDefinition.stitch = stitch

		patternDefinition.new = function()
			return setmetatable({}, patternDefinition)
		end

		state["patterns"] = Util.shallowCopy(state["patterns"])
		state["patterns"][patternDefinition.name] = patternDefinition
		return state
	end
end
