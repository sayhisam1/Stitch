--!strict
local inlinedError = require(script.Parent.Parent.Shared.inlinedError)
local Signal = require(script.Parent.Parent.Shared.Signal)

local EntityManager = {}
EntityManager.__index = EntityManager

function EntityManager.new()
	local self = setmetatable({
		entityToComponent = {},
		componentToEntity = {},
		signals = {
			entities = {
				componentAdded = {},
				componentRemoving = {},
				componentChanged = {},
			},
			components = {
				entityAdded = {},
				entityRemoving = {},
				entityChanged = {},
			},
		},
		listeners = {
			entities = {
				destroying = {},
			},
		},
	}, EntityManager)

	return self
end

function EntityManager:destroy()
	for entity, _ in pairs(self.entityToComponent) do
		self:unregister(entity)
	end
	-- disconnect all signals
	for _, componentSignals in pairs(self.signals.components) do
		for k, signal in pairs(componentSignals) do
			signal:disconnectAll()
			componentSignals[k] = nil
		end
	end
end

function EntityManager:register(entity: Instance | {})
	self.entityToComponent[entity] = {}
	-- listen to entity destroying event if is instance
	if typeof(entity) == "Instance" then
		local destroying
		destroying = entity.Destroying:Connect(function()
			destroying:Disconnect()
			self.listeners.entities.destroying[entity] = nil
			self:unregister(entity)
		end)
		self.listeners.entities.destroying[entity] = destroying
	end
end

function EntityManager:unregister(entity: Instance | {})
	for componentName, data in pairs(self.entityToComponent[entity] or {}) do
		self:removeComponent(componentName, entity)
	end
	for _, entitySignals in pairs(self.signals.entities) do
		if entitySignals[entity] then
			entitySignals[entity]:disconnectAll()
			entitySignals[entity] = nil
		end
	end
	if self.listeners.entities.destroying[entity] then
		self.listeners.entities.destroying[entity]:Disconnect()
		self.listeners.entities.destroying[entity] = nil
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

	if self.signals.entities.componentAdded[entity] then
		self.signals.entities.componentAdded[entity]:fire(componentDefinition.name, data)
	end

	if self.signals.components.entityAdded[componentDefinition.name] then
		self.signals.components.entityAdded[componentDefinition.name]:fire(entity, data)
	end

	return data
end

function EntityManager:getComponentAddedSignal(entity: Instance | {})
	if not self:isRegistered(entity) then
		self:register(entity)
	end

	if not self.signals.entities.componentAdded[entity] then
		self.signals.entities.componentAdded[entity] = Signal.new()
	end
	return self.signals.entities.componentAdded[entity]
end

function EntityManager:getEntityAddedSignal(componentDefinition: {})
	if not self.signals.components.entityAdded[componentDefinition.name] then
		self.signals.components.entityAdded[componentDefinition.name] = Signal.new()
	end
	return self.signals.components.entityAdded[componentDefinition.name]
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

	data = componentDefinition:setFromData(data)

	local oldData = self.entityToComponent[entity][componentDefinition.name]

	self.entityToComponent[entity][componentDefinition.name] = data
	self.componentToEntity[componentDefinition.name][entity] = data

	if self.signals.entities.componentChanged[entity] then
		self.signals.entities.componentChanged[entity]:fire(componentDefinition.name, data, oldData)
	end

	if self.signals.components.entityChanged[componentDefinition.name] then
		self.signals.components.entityChanged[componentDefinition.name]:fire(entity, data, oldData)
	end

	return data
end

function EntityManager:updateComponent(componentDefinition: {}, entity: Instance | {}, data: {}): {}
	if not self.entityToComponent[entity] or not self.entityToComponent[entity][componentDefinition.name] then
		error(("%s does not have a component of type %s!"):format(tostring(entity), componentDefinition.name))
	end

	data = componentDefinition:updateFromData(self.entityToComponent[entity][componentDefinition.name], data)

	local oldData = self.entityToComponent[entity][componentDefinition.name]

	self.entityToComponent[entity][componentDefinition.name] = data
	self.componentToEntity[componentDefinition.name][entity] = data

	if self.signals.entities.componentChanged[entity] then
		self.signals.entities.componentChanged[entity]:fire(componentDefinition.name, data, oldData)
	end

	if self.signals.components.entityChanged[componentDefinition.name] then
		self.signals.components.entityChanged[componentDefinition.name]:fire(entity, data, oldData)
	end

	return data
end

function EntityManager:getComponentChangedSignal(entity: Instance | {})
	if not self:isRegistered(entity) then
		self:register(entity)
	end

	if not self.signals.entities.componentChanged[entity] then
		self.signals.entities.componentChanged[entity] = Signal.new()
	end

	return self.signals.entities.componentChanged[entity]
end

function EntityManager:getEntityChangedSignal(componentDefinition: {})
	if not self.signals.components.entityChanged[componentDefinition.name] then
		self.signals.components.entityChanged[componentDefinition.name] = Signal.new()
	end
	return self.signals.components.entityChanged[componentDefinition.name]
end

function EntityManager:removeComponent(componentDefinition: {}, entity: Instance | {})
	if not self.entityToComponent[entity] or not self.entityToComponent[entity][componentDefinition.name] then
		return
	end

	local data = self.entityToComponent[entity][componentDefinition.name]

	if self.signals.entities.componentRemoving[entity] then
		self.signals.entities.componentRemoving[entity]:fire(componentDefinition.name, data)
	end

	if self.signals.components.entityRemoving[componentDefinition.name] then
		self.signals.components.entityRemoving[componentDefinition.name]:fire(entity, data)
	end

	if componentDefinition.destructor then
		xpcall(componentDefinition.destructor, inlinedError, entity, data)
	end

	self.entityToComponent[entity][componentDefinition.name] = nil
	self.componentToEntity[componentDefinition.name][entity] = nil

	if typeof(entity) == "table" and next(self.entityToComponent[entity]) == nil then
		-- since the entity has no more components, we clear the ref to allow gc'ing
		self:unregister(entity)
	end
end

function EntityManager:getComponentRemovingSignal(entity: Instance | {})
	if not self:isRegistered(entity) then
		self:register(entity)
	end

	if not self.signals.entities.componentRemoving[entity] then
		self.signals.entities.componentRemoving[entity] = Signal.new()
	end
	return self.signals.entities.componentRemoving[entity]
end

function EntityManager:getEntityRemovingSignal(componentDefinition: {})
	if not self.signals.components.entityRemoving[componentDefinition.name] then
		self.signals.components.entityRemoving[componentDefinition.name] = Signal.new()
	end
	return self.signals.components.entityRemoving[componentDefinition.name]
end

function EntityManager:getAll()
	local entites = {}
	for entity, _ in pairs(self.entityToComponent) do
		table.insert(entites, entity)
	end
	return entites
end

return EntityManager
