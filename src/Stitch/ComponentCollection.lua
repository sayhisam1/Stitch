local Component = require(script.Parent.Component)
local HotReloader = require(script.Parent.HotReloader)
local Util = require(script.Parent.Parent.Shared.Util)
local Signal = require(script.Parent.Parent.Shared.Signal)

local ComponentCollection = {}
ComponentCollection.__index = ComponentCollection

function ComponentCollection.new()
	local self = setmetatable({
		registeredComponents = {},
		_hotReloader = HotReloader.new(),
		_componentRegistered = Signal.new(),
		_componentUnregistered = Signal.new(),
	}, ComponentCollection)

	return self
end

function ComponentCollection:destroy()
	self._componentRegistered:destroy()
	self._componentUnregistered:destroy()
	self._hotReloader:destroy()
end

function ComponentCollection:register(componentDefinition: table | ModuleScript)
	if typeof(componentDefinition) == "Instance" and componentDefinition:IsA("ModuleScript") then
		self._hotReloader:listen(componentDefinition, function(component, originalModule: ModuleScript)
			if not component.name then
				component.name = originalModule.Name
			end
			self:register(component)
		end, function(component)
			self:unregister(component)
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

	self._componentRegistered:fire(componentDefinition)

	return componentDefinition
end

function ComponentCollection:unregister(componentResolvable)
	local resolvedComponent = self:resolveOrError(componentResolvable)

	self.registeredComponents[resolvedComponent.name] = nil
	self._componentUnregistered:fire(resolvedComponent)
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

function ComponentCollection:getComponentRegisteredSignal()
	return self._componentRegistered
end

function ComponentCollection:getComponentUnregisteredSignal()
	return self._componentUnregistered
end

return ComponentCollection
