local World = require(script.Parent.World)

local Types = {}

export type World = typeof(World.new())
export type Enity = Instance | {}
export type Component = string | {}

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