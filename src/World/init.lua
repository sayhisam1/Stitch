local DEFAULT_NAMESPACE = "game"

local ComponentRegistry = require(script.ComponentRegistry)
local EntityManager = require(script.EntityManager)
local SystemGroup = require(script.SystemGroup)
local System = require(script.System)
local HotReloader = require(script.HotReloader)

local World = {}
World.__index = World

function World.new(namespace: string)
	namespace = namespace or DEFAULT_NAMESPACE

	local self = setmetatable({
		namespace = namespace,
		componentRegistry = ComponentRegistry.new(),
		entityManager = EntityManager.new(namespace),
		systemGroups = {},
		_hotReloader = HotReloader.new(),
	}, World)

	return self
end

function World:destroy()
	self._hotReloader:destroy()
	-- explicitly unregister all entities first to ensure system state components are properly cleaned up
	for entity, _ in pairs(self.entityManager:getAll()) do
		self.entityManager:unregister(entity)
	end
	for _, systemGroup in pairs(self.systemGroups) do
		systemGroup:destroy()
	end
	self.componentRegistry:destroy()
	self.entityManager:destroy()
end

function World:registerComponent(componentDefinition: {} | ModuleScript)
	self.componentRegistry:register(componentDefinition)
end
function World:unregisterComponent(componentDefinition: {} | ModuleScript)
	self.componentRegistry:unregister(componentDefinition)
end


function World:addSystem(systemDefinition: {} | ModuleScript)
	if typeof(systemDefinition) == "Instance" and systemDefinition:IsA("ModuleScript") then
		self._hotReloader:listen(systemDefinition, function(module: ModuleScript)
			systemDefinition = require(module)
			if not systemDefinition.name then
				systemDefinition.name = module.Name
			end
			self:addSystem(systemDefinition)
		end, function(module:ModuleScript)
			systemDefinition = require(module)
			if not systemDefinition.name then
				systemDefinition.name = module.Name
			end
			self:removeSystem(systemDefinition)
		end)
		return
	end

	local updateEvent = systemDefinition.updateEvent or System.updateEvent

	if not self.systemGroups[updateEvent] then
		self.systemGroups[updateEvent] = SystemGroup.new(updateEvent)
	end

	self.systemGroups[updateEvent]:addSystem(systemDefinition, self)
end

function World:removeSystem(system: {} | ModuleScript)
	if typeof(system) == "ModuleScript" then
		system = require(system)
	end

	local updateEvent = system.updateEvent or System.updateEvent
	if not self.systemGroups[updateEvent] then
		return
	end
	self.systemGroups[updateEvent]:removeSystem(system)
end

function World:addComponent(componentDefinition: {}, entity: Instance | {}, data: {}?): {}
	return self.entityManager:addComponent(self.componentRegistry:resolveOrError(componentDefinition), entity, data)
end

function World:getComponent(componentDefinition: string | {}, entity: Instance | {}): {}?
	return self.entityManager:getComponent(self.componentRegistry:resolveOrError(componentDefinition), entity)
end

function World:getEntitiesWith(componentDefinition: {})
	return self.entityManager:getEntitiesWith(self.componentRegistry:resolveOrError(componentDefinition))
end

function World:setComponent(componentDefinition: {}, entity: Instance | {}, data: {}): {}
	return self.entityManager:setComponent(self.componentRegistry:resolveOrError(componentDefinition), entity, data)
end

function World:updateComponent(
	componentDefinition: {},
	entity: Instance | {},
	data: {}
): {}
	return self.entityManager:updateComponent(self.componentRegistry:resolveOrError(componentDefinition), entity, data)
end

function World:removeComponent(componentDefinition: {}, entity: Instance | {})
	return self.entityManager:removeComponent(self.componentRegistry:resolveOrError(componentDefinition), entity)
end

return World
