--!strict
local Util = require(script.Parent.Parent.Shared.Util)
export type ComponentDefinition = {
	name: string,
	defaults: {}?,
	validators: {}?,
	destructor: (any, any) -> nil,
} | ModuleScript

--[=[
	@type ComponentResolvable ComponentDefinition | string
	@within ComponentDefinition
	Whenever an API refers to a `ComponentResolvable`,
	either the definition or the name of the component can be used.
]=]

--[=[
	@class ComponentDefinition

	A ComponentDefinition is a table that defines a Component.

	All ComponentDefinitions must be registered to a World before they can be used.
]=]
local ComponentDefinition = {}
ComponentDefinition.__index = ComponentDefinition

--[=[
	@prop name string?
	@within ComponentDefinition
	Used to identify the Component in the World (should be unique).

	If `name` is not defined and the ComponentDefinition is returned by a ModuleScript,
	then registering the ModuleScript will use the name of the ModuleScript.
]=]
ComponentDefinition.name = nil

--[=[
	@prop defaults {}?
	@within ComponentDefinition
	The default data to use when adding a component. If data is provided to `World.addComponent`,
	then the data will be merged with the defaults.
]=]
ComponentDefinition.defaults = {}

--[=[
	@prop validators {string : (any) -> boolean}?
	@within ComponentDefinition
	A table of functions that will be called to validate the data when adding or changing a component.
	
	The value of each key is a function that accepts data[key] and returns true if the value is valid.
]=]
ComponentDefinition.validators = {}

--[=[
	@prop tag boolean? | string?
	@within ComponentDefinition
	| ❕ This property only has an effect when `TagSystem` is added to the World. |
	| --------------------------------------------------------------------------------- |

	Used to apply CollectionService tags to the entity the component is attached to
	(see: `TagSystem` for more details).

	If tag is `true`, the tag will be the same as the name of the ComponentDefinition.
]=]
ComponentDefinition.tag = nil

--[=[
	@prop replicate boolean?
	@within ComponentDefinition
	| ❕ This property only has an effect when `ReplicationSystem` is added to the World. |
	| --------------------------------------------------------------------------------- |
	Enables replication of the component (see: `ReplicationSystem` for more details).
]=]
ComponentDefinition.replicate = nil

--[=[
	@prop destructor (entity, data) -> nil?
	@within ComponentDefinition
	If set, this function will be called when the component is removed.
	You should use this to clean up any resources that were allocated when adding the component (e.g. any event connections).
	The function will be passed the entity and the data of the component.

	| ❗ Component destructors should not yield - this will lead to undefined behavior. |
	| --------------------------------------------------------------------------------- |
]=]
ComponentDefinition.destructor = nil


function ComponentDefinition:createFromData(data: {}?): {}
	data = Util.mergeTable(Util.deepCopy(self.defaults), data or {})

	self:validateOrErrorData(data)

	return data
end

function ComponentDefinition:setFromData(data: {}): {}
	data = Util.shallowCopy(data)

	self:validateOrErrorData(data)

	return data
end

function ComponentDefinition:updateFromData(old: {}, new: {}): {}
	local data = Util.mergeTable(old, new)

	self:validateOrErrorData(data)

	return data
end

function ComponentDefinition:validateOrErrorData(data: {})
	for key, validator in pairs(self.validators) do
		if not validator(data[key]) then
			error("Failed to create component %s - invalid value %s (of type %s) for key %s!"):format(
				self.name,
				tostring(data[key]),
				typeof(data[key]),
				key
			)
		end
	end
end

return ComponentDefinition
