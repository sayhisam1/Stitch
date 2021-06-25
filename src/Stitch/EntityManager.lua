--!strict
local CollectionService = game:GetService("CollectionService")

local ComponentCollection = require(script.Parent.ComponentCollection)
local Util = require(script.Parent.Parent.Shared.Util)

local EntityManager = {}
EntityManager.__index = EntityManager

function EntityManager.new(namespace: string)
	local self = setmetatable({
		instanceTag = ("Stitch%sTag"):format(namespace),
		collection = ComponentCollection.new(),
		entities = {},
		componentToEntity = {},
		_instanceRemovedSignal = nil,
	}, EntityManager)

	self._instanceRemovedSignal = CollectionService
		:GetInstanceRemovedSignal(self.instanceTag)
		:connect(function(instance: Instance)
			self:unregisterEntity(instance)
		end)

	return self
end

function EntityManager:destroy()
	self._instanceRemovedSignal:disconnect()

	for entity, _ in pairs(self.entities) do
		self:unregisterEntity(entity)
	end

	-- if there are somehow still tagged instances, we remove them here
	for _, instance in ipairs(CollectionService:GetTagged(self.instanceTag)) do
		self:unregisterEntity(instance)
	end
end

function EntityManager:registerComponentTemplate(componentDefinition: table | ModuleScript)
	self.collection:register(componentDefinition)
end

function EntityManager:registerEntity(entity: Instance | table)
	if typeof(entity) == "Instance" and not CollectionService:HasTag(entity, self.instanceTag) then
		CollectionService:AddTag(entity, self.instanceTag)
	end
	self.entities[entity] = self.entities[entity] or {}
end

function EntityManager:unregisterEntity(entity: Instance | table)
	if typeof(entity) == "Instance" and CollectionService:HasTag(entity, self.instanceTag) then
		CollectionService:RemoveTag(entity, self.instanceTag)
	end
	for componentName, data in pairs(self.entities[entity] or {}) do
		self:removeComponent(componentName, entity)
	end
	self.entities[entity] = nil
end

function EntityManager:addComponent(componentResolvable: string | table, entity: Instance | table, data: table?): table
	local component = self.collection:resolveOrError(componentResolvable)

	-- for convenience, we register the entity if needed
	if not self.entities[entity] then
		self:registerEntity(entity)
	end

	if self.entities[entity][component.name] then
		error(("%s already has a component of type %s!"):format(tostring(entity), component.name))
	end

	self.entities[entity][component.name] = component:createFromData(data)

	if not self.componentToEntity[component.name] then
		self.componentToEntity[component.name] = {}
	end

	self.componentToEntity[component.name][entity] = entity

	return self.entities[entity][component.name]
end

function EntityManager:getComponent(componentResolvable: string | table, entity: Instance | table): table?
	local component = self.collection:resolveOrError(componentResolvable)

	return self.entities[entity] and self.entities[entity][component.name] or nil
end

function EntityManager:getEntitiesWith(componentResolvable: string | table)
	local component = self.collection:resolveOrError(componentResolvable)
	return Util.shallowCopy(self.componentToEntity[component.name] or {})
end

function EntityManager:setComponent(componentResolvable: string | table, entity: Instance | table, data: table): table
	local component = self.collection:resolveOrError(componentResolvable)

	if not self.entities[entity] or not self.entities[entity][component.name] then
		error(("%s does not have a component of type %s!"):format(tostring(entity), component.name))
	end

	self.entities[entity][component.name] = component:setFromData(data)
	return self.entities[entity][component.name]
end

function EntityManager:updateComponent(
	componentResolvable: string | table,
	entity: Instance | table,
	data: table
): table
	local component = self.collection:resolveOrError(componentResolvable)

	if not self.entities[entity] or not self.entities[entity][component.name] then
		error(("%s does not have a component of type %s!"):format(tostring(entity), component.name))
	end

	self.entities[entity][component.name] = component:updateFromData(self.entities[entity][component.name], data)
	return self.entities[entity][component.name]
end

function EntityManager:removeComponent(componentResolvable: string | table, entity: Instance | table)
	local component = self.collection:resolveOrError(componentResolvable)

	if not self.entities[entity] or not self.entities[entity][component.name] then
		return
	end

	self.entities[entity][component.name] = nil

	self.componentToEntity[component.name][entity] = nil

	if next(self.entities[entity]) == nil then
		-- since the entity has no more components, we clear the ref to allow gc'ing
		self.entities[entity] = nil
	end
end

return EntityManager
