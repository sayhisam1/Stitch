--!strict
local CollectionService = game:GetService("CollectionService")

local ComponentCollection = require(script.Parent.ComponentCollection)

local EntityManager = {}
EntityManager.__index = EntityManager

function EntityManager.new(namespace: string)
	local self = setmetatable({
		instanceTag = ("Stitch%sTag"):format(namespace),
		collection = ComponentCollection.new(),
		entities = {},
		_instanceRemovedSignal = nil,
	}, EntityManager)

	self._instanceRemovedSignal = CollectionService
		:GetInstanceRemovedSignal(self.instanceTag)
		:connect(function(instance: Instance)
			self:_unregisterInstance(instance)
		end)

	return self
end

function EntityManager:destroy()
	self._instanceRemovedSignal:disconnect()

	for _, instance in ipairs(CollectionService:GetTagged(self.instanceTag)) do
		self:unregisterInstance(instance)
	end
end

function EntityManager:registerComponentTemplate(componentDefinition: table | ModuleScript)
	self.collection:register(componentDefinition)
end

function EntityManager:registerInstance(instance: Instance)
	CollectionService:AddTag(instance, self.instanceTag)
	self.entities[instance] = self.entities[instance] or {}
end

function EntityManager:unregisterInstance(instance: Instance)
	CollectionService:RemoveTag(instance, self.instanceTag)
	self:_unregisterInstance(instance)
end

-- need internal version to prevent double-calling due to tag removal
function EntityManager:_unregisterInstance(instance: Instance)
	for componentName, data in pairs(self.entities[instance] or {}) do
		self:removeComponent(componentName, instance)
	end
	self.entities[instance] = nil
end

function EntityManager:addComponent(componentResolvable: string | table, entity: Instance, data: table?): table
	local component = self.collection:resolveOrError(componentResolvable)

	if not self.entities[entity] then
		self:registerInstance(entity)
	end

	if self.entities[entity][component.name] then
		error(("%s already has a component of type %s!"):format(tostring(entity), component.name))
	end

	self.entities[entity][component.name] = component:createFromData(data)
	return self.entities[entity][component.name]
end

function EntityManager:getComponent(componentResolvable: string | table, entity: Instance): table?
	local component = self.collection:resolveOrError(componentResolvable)

	return self.entities[entity] and self.entities[entity][component.name] or nil
end

function EntityManager:setComponent(componentResolvable: string | table, entity: Instance, data: table): table
	local component = self.collection:resolveOrError(componentResolvable)

	if not self.entities[entity] or not self.entities[entity][component.name] then
		error(("%s does not have a component of type %s!"):format(tostring(entity), component.name))
	end

	self.entities[entity][component.name] = component:setFromData(data)
	return self.entities[entity][component.name]
end

function EntityManager:updateComponent(componentResolvable: string | table, entity: Instance, data: table): table
	local component = self.collection:resolveOrError(componentResolvable)

	if not self.entities[entity] or not self.entities[entity][component.name] then
		error(("%s does not have a component of type %s!"):format(tostring(entity), component.name))
	end

	self.entities[entity][component.name] = component:updateFromData(self.entities[entity][component.name], data)
	return self.entities[entity][component.name]
end

function EntityManager:removeComponent(componentResolvable: string | table, entity: Instance)
	local component = self.collection:resolveOrError(componentResolvable)

	if not self.entities[entity] or not self.entities[entity][component.name] then
		return
	end

	self.entities[entity][component.name] = nil

	if next(self.entities[entity]) == nil then
		-- since the entity has no more components, we clear the ref to allow gc'ing
		self.entities[entity] = nil
	end
end

return EntityManager
