
local Types = {}

local WorldInterface = require(script.WorldInterface)

export type World = typeof(WorldInterface.new())
export type Entity = Instance | {}
export type ComponentResolvable = {} | string
export type SystemResolvable = {} | ModuleScript

export type ComponentDefinition = {
	name: string,
	defaults: {}?,
	validators: {}?,
	destructor: (any, any) -> nil,
} | ModuleScript

export type SystemDefinition = {
    name: string,
    priority: number?,
    updateEvent: RBXScriptSignal?,
    onCreate: (World) -> nil,
    onUpdate: (World, any) -> nil,
    onDestroy: (World) -> nil,
} | ModuleScript

return Types