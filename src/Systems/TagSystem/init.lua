local CollectionService = game:GetService("CollectionService")

local TagSystem = {}
TagSystem.name = "TagSystem"
TagSystem.priority = -1E10

function TagSystem:onCreate(stitch)
	self._instanceAddedListeners = {}
	self._instanceRemovedListeners = {}
	self._entityAddedListeners = {}
	self._entityRemovedListeners = {}

	local function addComponent(component, instance)
		if not self:getComponent(component, instance) then
			local defaults: Folder = instance:FindFirstChild("defaults")
			local componentDefaults = defaults and defaults:FindFirstChild(component.name) or nil
			local data = {}
			for _, default in pairs(componentDefaults and componentDefaults:GetChildren() or {}) do
				data[default.Name] = default.Value
			end
			self:addComponent(component, instance)
		end
	end
	local function removeComponent(component, instance)
		self:removeComponent(component, instance)
	end

	local function registerComponent(component)
		if not component.tagged then
			return
		end
		local instanceAdded = CollectionService:GetInstanceAddedSignal(component.name)
		self._instanceAddedListeners[component.name] = instanceAdded:connect(function(instance: Instance)
			addComponent(component, instance)
		end)

		local instanceRemoved = CollectionService:GetInstanceRemovedSignal(component.name)
		self._instanceRemovedListeners[component.name] = instanceRemoved:connect(function(instance: Instance)
			removeComponent(component, instance)
		end)

		for _, instance in pairs(CollectionService:GetTagged(component.name)) do
			addComponent(component, instance)
		end

		local entityAdded = stitch.entityManager:getEntityAddedSignal(component)
		self._entityAddedListeners[component.name] = entityAdded:connect(function(entity: Instance | table)
			if typeof(entity) == "Instance" and not CollectionService:HasTag(entity, component.name) then
				CollectionService:AddTag(entity, component.name)
			end
		end)

		local entityRemoved = stitch.entityManager:getEntityRemovedSignal(component)
		self._entityRemovedListeners[component.name] = entityRemoved:connect(function(entity: Instance | table)
			if typeof(entity) == "Instance" and CollectionService:HasTag(entity, component.name) then
				CollectionService:RemoveTag(entity, component.name)
			end
		end)
	end

	local componentRegistered = stitch.entityManager.collection:getComponentRegisteredSignal()
	self._componentRegisteredListener = componentRegistered:connect(registerComponent)
	for _, component in pairs(stitch.entityManager.collection:getAll()) do
		registerComponent(component)
	end

	local componentUnregistered = stitch.entityManager.collection:getComponentUnregisteredSignal()
	self._componentUnregisteredListener = componentUnregistered:connect(function(component)
		if self._instanceAddedListeners[component.name] then
			self._instanceAddedListeners[component.name]:disconnect()
			self._instanceAddedListeners[component.name] = nil
			self._instanceRemovedListeners[component.name]:disconnect()
			self._instanceRemovedListeners[component.name] = nil
			self._entityAddedListeners[component.name]:disconnect()
			self._entityAddedListeners[component.name] = nil
			self._entityRemovedListeners[component.name]:disconnect()
			self._entityRemovedListeners[component.name] = nil
		end
	end)
end

function TagSystem:onDestroy()
	self._componentRegisteredListener:disconnect()
	self._componentUnregisteredListener:disconnect()
	for _, listener in pairs(self._instanceAddedListeners) do
		listener:disconnect()
	end
	for _, listener in pairs(self._instanceRemovedListeners) do
		listener:disconnect()
	end
	for _, listener in pairs(self._entityAddedListeners) do
		listener:disconnect()
	end
	for _, listener in pairs(self._entityRemovedListeners) do
		listener:disconnect()
	end
end

return TagSystem
