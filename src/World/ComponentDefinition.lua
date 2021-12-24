--!strict
local Immutable = require(script.Parent.Parent.Shared.Immutable)
local Symbol = require(script.Parent.Parent.Shared.Symbol)
local NONE = Symbol.named("NONE")

--[=[
	@class ComponentDefinition

	A ComponentDefinition is a table that defines a Component.
	
	All ComponentDefinitions must be registered to a World before they can be used.
	
	Example usage:

	```lua
	local positionComponent = {
		name = "position",
		defaults = {
			x = 0,
			y = 0,
			z = 0,
		},
	}
	world:registerComponent(positionComponent)
	```
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
	@prop validator ((data: {}) -> boolean)?
	@within ComponentDefinition
	A function that will be called to validate the data when adding or changing a component.
	Should return true if the data is valid, false otherwise.
]=]
ComponentDefinition.validator = nil

--[=[
	@prop tag boolean? | string?
	@within ComponentDefinition
	@tag special

	:::info
	This property only has an effect when `TagSystem` is added to the World.
	:::

	Used to apply CollectionService tags to the entity the component is attached to
	(see: `TagSystem` for more details).

	If tag is `true`, the tag will be the same as the name of the ComponentDefinition.
]=]
ComponentDefinition.tag = nil

--[=[
	@prop replicate boolean?
	@within ComponentDefinition
	@tag special

	:::info
	This property only has an effect when `ReplicationSystem` is added to the World.
	:::

	Enables replication of the component (see: `ReplicationSystem` for more details).
]=]
ComponentDefinition.replicate = nil

--[=[
	@prop destructor (entity, data) -> nil?
	@within ComponentDefinition
	If set, this function will be called when the component is removed.
	You should use this to clean up any resources that were allocated when adding the component (e.g. any event connections).
	The function will be passed the entity and the data of the component.

	:::danger
	Component destructors should not yield - this will lead to undefined behavior!
	:::
]=]
ComponentDefinition.destructor = nil

function ComponentDefinition:createFromData(data: {}?): {}
	data = Immutable.mergeTable(Immutable.deepCopy(self.defaults), data or {}, NONE)

	self:validateOrErrorData(data)

	return data
end

function ComponentDefinition:setFromData(data: {}): {}
	data = Immutable.shallowCopy(data)

	self:validateOrErrorData(data)

	return data
end

function ComponentDefinition:updateFromData(old: {}, new: {}): {}
	local data = Immutable.mergeTable(old, new, NONE)

	self:validateOrErrorData(data)

	return data
end

function ComponentDefinition:validateOrErrorData(data: {})
	if not self.validator then
		return true
	end
	if not self.validator(data) then
		error(("Failed to validate data for component of type %s."):format(self.name), 2)
	end
	return true
end

return ComponentDefinition
