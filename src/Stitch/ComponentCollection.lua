local Component = require(script.Parent.Component)
local Util = require(script.Parent.Parent.Shared.Util)

local ComponentCollection = {}
ComponentCollection.__index = ComponentCollection

function ComponentCollection.new()
	local self = setmetatable({
		registeredComponents = {},
	}, ComponentCollection)

	return self
end

function ComponentCollection:destroy() end

function ComponentCollection:register(componentDefinition: table)
	if getmetatable(componentDefinition) then
		error(
			"Failed to register component %s: components should not have a metatable!",
			tostring(componentDefinition.name)
		)
	end

	componentDefinition = Util.shallowCopy(componentDefinition)
	local componentName = componentDefinition.name

	if self.registeredComponents[componentName] then
		error(("Tried to register duplicate Component %s!"):format(componentName))
	end

	setmetatable(componentDefinition, Component)
	self.registeredComponents[componentName] = componentDefinition

	return componentDefinition
end

function ComponentCollection:unregister(componentResolvable)
	local resolvedComponent = self:resolveOrError(componentResolvable)
	self.registeredComponents[resolvedComponent.name] = nil
end

function ComponentCollection:resolve(componentResolvable)
	local componentResolvableType = typeof(componentResolvable)
	if not componentResolvableType == "string" and not componentResolvableType == "table" then
		error(
			("Invalid ComponentResolvable %s of type %s"):format(
				tostring(componentResolvable),
				typeof(componentResolvable)
			)
		)
	end

	local componentName = componentResolvable
	if componentResolvableType == "table" then
		componentName = componentResolvable.name
	end

	return self.registeredComponents[componentName]
end

function ComponentCollection:resolveOrError(componentResolvable)
	return self:resolve(componentResolvable) or error(
		("Failed to resolve Component %s!"):format(tostring(componentResolvable))
	)
end

function ComponentCollection:getAll()
	return self.registeredComponents
end

return ComponentCollection
