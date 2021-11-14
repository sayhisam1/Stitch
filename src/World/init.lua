local DEFAULT_NAMESPACE = "game"

local ComponentRegistry = require(script.ComponentRegistry)
local EntityManager = require(script.EntityManager)
local SystemManager = require(script.SystemManager)
local EntityQuery = require(script.EntityQuery)
local Symbol = require(script.Parent.Shared.Symbol)

--[=[
	@class World

	The World class is a collection of entities, components, and systems.
	It is the central class that ties all other parts of an ECS together.
	A game could have many worlds, but normally there is only one world per game.
]=]
local World = {}
World.__index = World

--[=[
	@prop NONE UserData
	@within World
	Used to set keys to `nil` on `world:addComponent` or `world:updateComponent` calls.
	```lua
	world:updateComponent("someComponent", entity, {
		foo = World.NONE
	})
	world:getComponent("someComponent", entity).foo -- is nil
	```
]=]
World.NONE = Symbol.named("NONE")

--[=[
	Creates a new World.
	@tag constructor

	@param namespace string? -- The namespace to use for this world.
	@return World
]=]
function World.new(namespace: string)
	namespace = namespace or DEFAULT_NAMESPACE

	local self = setmetatable({
		namespace = namespace,
		componentRegistry = ComponentRegistry.new(),
		entityManager = EntityManager.new(),
		systemGroups = {},
	}, World)

	self.systemManager = SystemManager.new(self)

	return self
end

--[=[
	Destroys a World. 
	Components are detached from entities and Systems are stopped.
	@tag destructor

	@return nil
]=]
function World:destroy()
	-- explicitly unregister all entities first to ensure system state components are properly cleaned up
	for entity, _ in pairs(self.entityManager:getAll()) do
		self.entityManager:unregister(entity)
	end
	self.systemManager:destroy()
	self.componentRegistry:destroy()
	self.entityManager:destroy()
end

--[=[
	Registers a new ComponentDefintion to the World.

	When passed as a ModuleScript:
	- Hot reloading will be enabled
	- The ComponentDefinition will use the name of the ModuleScript if not provided.

	@param componentDefinition ComponentDefinition | ModuleScript
	@return nil
]=]
function World:registerComponent(componentDefinition: {} | ModuleScript)
	self.componentRegistry:register(componentDefinition)
end

--[=[
	Unregisters a ComponentDefinition from the World.

	@param componentResolvable ComponentResolvable 
	@return nil
]=]
function World:unregisterComponent(componentResolvable: {} | ModuleScript)
	self.componentRegistry:unregister(componentResolvable)
end

--[=[
	Creates a new EntityQuery.

	@return EntityQuery
]=]
function World:createQuery()
	return EntityQuery.new(self)
end

--[=[
	Adds a new System to the World.

	When passed as a ModuleScript:
	- Hot reloading will be enabled
	- The SystemDefinition will use the name of the ModuleScript if not provided.

	@param systemDefinition SystemDefinition | ModuleScript
	@return nil
]=]
function World:addSystem(systemDefinition: {} | ModuleScript)
	return self.systemManager:addSystem(systemDefinition)
end

--[=[
	Removes a System from the World.

	@param systemResolvable SystemDefinition | ModuleScript
	@return nil
]=]
function World:removeSystem(systemResolvable: {} | ModuleScript)
	return self.systemManager:removeSystem(systemResolvable)
end

--[=[
	Attaches a component to an entity with given data.
	If no data is provided, the `.default` property of the ComponentDefinition will be used.

	@param componentResolvable ComponentResolvable -- the type of component to attach
	@param entity Instance | {} -- the entity to attach the component to
	@param data {}? -- the data to use for the component
	@return {} -- The added component
	@error "Already exists" -- Thrown if the given component already exists on the entity.
]=]
function World:addComponent(componentResolvable: {} | string, entity: Instance | {}, data: {}?): {}
	return self.entityManager:addComponent(self.componentRegistry:resolveOrError(componentResolvable), entity, data)
end

--[=[
	Gets the component of the given type attached to the given entity.

	Returns `nil` if no such component is attached.

	@param componentResolvable ComponentResolvable -- the type of component to attach
	@param entity Instance | {} -- the entity to get component from
	@return {}? -- The attached component
]=]
function World:getComponent(componentResolvable: {} | string, entity: Instance | {}): {}?
	return self.entityManager:getComponent(self.componentRegistry:resolveOrError(componentResolvable), entity)
end

--[=[
	Gets all entities with the given component type.

	@param componentResolvable ComponentResolvable -- the type of component to get entities with
	@return {any} -- all entities in the world with the given component
]=]
function World:getEntitiesWith(componentResolvable: {} | string)
	return self.entityManager:getEntitiesWith(self.componentRegistry:resolveOrError(componentResolvable))
end

--[=[
	Sets the data of the given component on the given entity.

	@param componentResolvable ComponentResolvable -- the type of component
	@param entity Instance | {} -- the entity with the component
	@param data {} -- the data to set
	@return {} -- The newly set component
]=]
function World:setComponent(componentResolvable: {}, entity: Instance | {}, data: {}): {}
	return self.entityManager:setComponent(self.componentRegistry:resolveOrError(componentResolvable), entity, data)
end

--[=[
	Updates (i.e. merges the keys) the data of the given component on the given entity.

	@param componentResolvable ComponentResolvable -- the type of component
	@param entity Instance | {} -- the entity with the component
	@param data {} -- the data to merge into the existing data
	@return {} -- The newly updated component
]=]
function World:updateComponent(componentResolvable: {}, entity: Instance | {}, data: {}): {}
	return self.entityManager:updateComponent(self.componentRegistry:resolveOrError(componentResolvable), entity, data)
end

--[=[
	Removes the given component from the given entity.

	@param componentResolvable ComponentResolvable -- the type of component
	@param entity Instance | {} -- the entity with the component
	@return nil
]=]
function World:removeComponent(componentResolvable: {}, entity: Instance | {})
	self.entityManager:removeComponent(self.componentRegistry:resolveOrError(componentResolvable), entity)
end

return World
