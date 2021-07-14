local Serialization = require(script.Parent.Serialization)

local ReplicationSystem = {}
ReplicationSystem.name = "ReplicationSystem"
ReplicationSystem.priority = 1E10

function ReplicationSystem:onCreate(stitch)
	self._entityAddedObservers = {}
	self._entityChangedObservers = {}
	self._entityRemovedObservers = {}

	local function registerComponent(component)
		if not component.replicated then
			return
		end

		self._entityAddedObservers[component.name] = self:createObserver(
			stitch.entityManager:getEntityAddedSignal(component)
		)

		self:createQuery():all(component):forEach(function(entity, data)
			self._entityAddedObservers[component.name]:mark(entity, data)
		end)

		self._entityChangedObservers[component.name] = self:createObserver(
			stitch.entityManager:getEntityChangedSignal(component)
		)

		self._entityRemovedObservers[component.name] = self:createObserver(
			stitch.entityManager:getEntityRemovedSignal(component)
		)
	end

	local function unregisterComponent(component)
		self._entityAddedObservers[component.name]:Destroy()
		self._entityAddedObservers[component.name] = nil
		self._entityChangedObservers[component.name]:Destroy()
		self._entityChangedObservers[component.name] = nil
		self._entityRemovedObservers[component.name]:Destroy()
		self._entityRemovedObservers[component.name] = nil
	end

	local componentRegistered = stitch.entityManager.collection:getComponentRegisteredSignal()
	self._componentRegisteredListener = componentRegistered:connect(registerComponent)
	for _, component in pairs(stitch.entityManager.collection:getAll()) do
		registerComponent(component)
	end

	local componentUnregistered = stitch.entityManager.collection:getComponentUnregisteredSignal()
	self._componentUnregisteredListener = componentUnregistered:connect(unregisterComponent)
end

function ReplicationSystem:writeData(component, entity: Instance | table)
	if not typeof(entity) == "Instance" then
		return
	end
	component = self.stitch.entityManager.collection:resolveOrError(component)
	local replicatedContainerName = ("%s:replicated"):format(component.name)

	local container = entity:FindFirstChild(replicatedContainerName)
	if not container then
		container = Instance.new("Folder")
		container.Name = replicatedContainerName
		container.Parent = entity
	end

	Serialization.write(self:getComponent(component, entity), container)
end

function ReplicationSystem:removeData(component, entity: Instance | table)
	if not typeof(entity) == "Instance" then
		return
	end
	component = self.stitch.entityManager.collection:resolveOrError(component)
	local replicatedContainerName = ("%s:replicated"):format(component.name)

	local container = entity:FindFirstChild(replicatedContainerName)
	if container then
		container:destroy()
	end
end

function ReplicationSystem:onUpdate()
	for componentName, observer in pairs(self._entityAddedObservers) do
		observer:forEach(function(entity)
			self:writeData(componentName, entity)
		end)
	end

	for componentName, observer in pairs(self._entityChangedObservers) do
		observer:forEach(function(entity)
			self:writeData(componentName, entity)
		end)
	end

	for componentName, observer in pairs(self._entityRemovedObservers) do
		observer:forEach(function(entity)
			self:removeData(componentName, entity)
		end)
	end
end

function ReplicationSystem:onDestroy()
	self._componentRegisteredListener:disconnect()
	self._componentUnregisteredListener:disconnect()
end

return ReplicationSystem
