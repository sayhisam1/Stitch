local t = require(script.Parent.Parent.Parent.t)

local Types = {}

Types.PatternDefinition = t.interface({
	-- User implementations
	name = t.string,
})

return Types
