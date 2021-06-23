local Component = require(script.Parent.Component)
local HotReloader = require(script.Parent.HotReloader)
local Util = require(script.Parent.Parent.Shared.Util)

local ComponentCollection = {}
ComponentCollection.__index = ComponentCollection

function ComponentCollection.new()
	local self = setmetatable({
		registeredComponents = {},
		_hotReloader = HotReloader.new(),
	}, ComponentCollection)

	return self
end

function ComponentCollection:destroy()
	self._hotReloader:destroy()
end

function ComponentCollection:register(componentDefinition: table | ModuleScript)
	if typeof(componentDefinition) == "Instance" and componentDefinition:IsA("ModuleScript") then
		self._hotReloader:listen(componentDefinition, function(component)
			self:unregister(component)
			self:register(component)
		end)
		return
	end
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
	local resolvedComponent = self:resolve(componentResolvable)
	if not resolvedComponent then
		return
	end
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
