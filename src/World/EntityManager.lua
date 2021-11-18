--!strict
local inlinedError = require(script.Parent.Parent.Shared.inlinedError)

local EntityManager = {}
EntityManager.__index = EntityManager

function EntityManager.new()
	local self = setmetatable({
		entityToComponent = {},
		componentToEntity = {},
	}, EntityManager)

	return self
end

function EntityManager:destroy()
	for entity, _ in pairs(self.entityToComponent) do
		self:unregister(entity)
	end
end

function EntityManager:register(entity: Instance | {})
	self.entityToComponent[entity] = {}
end

function EntityManager:unregister(entity: Instance | {})
	for componentName, data in pairs(self.entityToComponent[entity] or {}) do
		self:removeComponent(componentName, entity)
	end
	self.entityToComponent[entity] = nil
end

function EntityManager:isRegistered(entity: Instance | {})
	return self.entityToComponent[entity] ~= nil
end

function EntityManager:addComponent(componentDefinition: {}, entity: Instance | {}, data: {}?): {}
	if self:isRegistered(entity) and self.entityToComponent[entity][componentDefinition.name] then
		error(("%s already has a component of type %s!"):format(tostring(entity), componentDefinition.name))
	end

	data = componentDefinition:createFromData(data)

	if not self:isRegistered(entity) then
		self:register(entity)
	end

	self.entityToComponent[entity][componentDefinition.name] = data

	if not self.componentToEntity[componentDefinition.name] then
		self.componentToEntity[componentDefinition.name] = {}
	end

	self.componentToEntity[componentDefinition.name][entity] = data

	return data
end

function EntityManager:getComponent(componentDefinition: string | {}, entity: Instance | {}): {}?
	return self.entityToComponent[entity] and self.entityToComponent[entity][componentDefinition.name] or nil
end

function EntityManager:getEntitiesWith(componentDefinition: {})
	return self.componentToEntity[componentDefinition.name] or table.freeze({})
end

function EntityManager:setComponent(componentDefinition: {}, entity: Instance | {}, data: {}): {}
	if not self.entityToComponent[entity] or not self.entityToComponent[entity][componentDefinition.name] then
		error(("%s does not have a component of type %s!"):format(tostring(entity), componentDefinition.name))
	end

	local newData = componentDefinition:setFromData(data)

	self.entityToComponent[entity][componentDefinition.name] = newData
	self.componentToEntity[componentDefinition.name][entity] = newData

	return newData
end

function EntityManager:updateComponent(componentDefinition: {}, entity: Instance | {}, data: {}): {}
	if not self.entityToComponent[entity] or not self.entityToComponent[entity][componentDefinition.name] then
		error(("%s does not have a component of type %s!"):format(tostring(entity), componentDefinition.name))
	end

	local newData = componentDefinition:updateFromData(self.entityToComponent[entity][componentDefinition.name], data)

	self.entityToComponent[entity][componentDefinition.name] = newData
	self.componentToEntity[componentDefinition.name][entity] = newData

	return newData
end

function EntityManager:removeComponent(componentDefinition: {}, entity: Instance | {})
	if not self.entityToComponent[entity] or not self.entityToComponent[entity][componentDefinition.name] then
		return
	end

	local oldData = self.entityToComponent[entity][componentDefinition.name]

	if componentDefinition.destructor then
		xpcall(componentDefinition.destructor, inlinedError, entity, oldData)
	end

	self.entityToComponent[entity][componentDefinition.name] = nil
	self.componentToEntity[componentDefinition.name][entity] = nil

	if next(self.entityToComponent[entity]) == nil then
		-- since the entity has no more components, we clear the ref to allow gc'ing
		self:unregister(entity)
	end
end

function EntityManager:getAll()
	local entites = {}
	for entity, _ in pairs(self.entityToComponent) do
		table.insert(entites, entity)
	end
	return entites
end

return EntityManager
