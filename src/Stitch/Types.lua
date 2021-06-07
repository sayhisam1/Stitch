local t = require(script.Parent.Parent.Parent.t)

local Types = {}

Types.PatternDefinition = t.interface({
	-- User implementations
	name = t.string,
	reducer = t.optional(t.callback),
	schema = t.optional(t.callback),
	defaults = t.optional(t.map(t.string, t.any)),
	units = t.optional(t.map(t.string, t.any)),
	refCheck = t.optional(t.union(t.array(t.string), t.callback)),
	shouldUpdate = t.optional(t.callback),

	-- Reserved Properties
	lastData = t.none,
	stitch = t.none,
	fire = t.none,
	on = t.none,
	refuuid = t.none,
	isInstanceRef = t.none,
	get = t.none,

	-- Events
	onUpdated = t.optional(t.callback),
	initialize = t.optional(t.callback),
	destroy = t.optional(t.callback),
	render = t.optional(t.callback),

	effects = t.optional(t.map(t.any, t.callback)),
})

return Types
