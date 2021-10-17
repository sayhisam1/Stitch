local DEFAULT_NAMESPACE = "game"

local ComponentRegistry = require(script.ComponentRegistry)
local EntityManager = require(script.EntityManager)
local SystemManager = require(script.SystemManager)
local EntityQuery = require(script.EntityQuery)

local World = {}
World.__index = World

function World.new(namespace: string)
	namespace = namespace or DEFAULT_NAMESPACE

	local self = setmetatable({
		namespace = namespace,
		componentRegistry = ComponentRegistry.new(),
		entityManager = EntityManager.new(namespace),
		systemGroups = {},
	}, World)

	self.systemManager = SystemManager.new(self)

	return self
end

function World:destroy()
	-- explicitly unregister all entities first to ensure system state components are properly cleaned up
	for entity, _ in pairs(self.entityManager:getAll()) do
		self.entityManager:unregister(entity)
	end
	self.systemManager:destroy()
	self.componentRegistry:destroy()
	self.entityManager:destroy()
end

function World:registerComponent(componentDefinition: {} | ModuleScript)
	self.componentRegistry:register(componentDefinition)
end
function World:unregisterComponent(componentDefinition: {} | ModuleScript)
	self.componentRegistry:unregister(componentDefinition)
end

function World:createQuery()
	return EntityQuery.new(self)
end

function World:addSystem(systemDefinition: {} | ModuleScript)
	return self.systemManager:addSystem(systemDefinition)
end

function World:removeSystem(system: {} | ModuleScript)
	return self.systemManager:removeSystem(system)
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
