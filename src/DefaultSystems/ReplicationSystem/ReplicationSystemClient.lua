local ContainerWatcher = require(script.Parent.ContainerWatcher)
local Util = require(script.Parent.Parent.Parent.Shared.Util)

local ReplicationSystem = {}
ReplicationSystem.name = "ReplicationSystem"
ReplicationSystem.priority = 1E10

local ReplicationState = {
	name = "replicationSystemState",
	defaults = {
		watchers = {},
		folderAdded = {},
	},
	destructor = function(entity, data)
		for key, watcher in pairs(data.watchers) do
			watcher:destroy()
			data.watchers[key] = nil
		end
		for key, listener in pairs(data.folderAdded) do
			listener:disconnect()
			data.folderAdded[key] = nil
		end
	end,
}

function ReplicationSystem:onCreate(stitch)
	self:registerComponent(ReplicationState)
	self._entityAddedObservers = {}
	self._entityRemovedObservers = {}

	local function registerComponent(component)
		if not component.replicated then
			return
		end

		self._entityAddedObservers[component.name] = self:createObserver(
			stitch.entityManager:getEntityAddedSignal(component)
		)

		self._entityRemovedObservers[component.name] = self:createObserver(
			stitch.entityManager:getEntityRemovedSignal(component)
		)

		self:createQuery():all(component):forEach(function(entity)
			self._entityAddedObservers[component.name]:mark(entity, self:getComponent(component, entity))
		end)
	end

	local function unregisterComponent(component)
		if not component.replicated then
			return
		end
		self._entityAddedObservers[component.name]:Destroy()
		self._entityAddedObservers[component.name] = nil
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

function ReplicationSystem:onUpdate()
	for componentName, observer in pairs(self._entityRemovedObservers) do
		observer:forEach(function(entity: Instance | {})
			if typeof(entity) ~= "Instance" then
				return
			end
			local replicationState = self:getComponent(ReplicationState, entity)
			if not replicationState then
				return
			end

			local newFolderAdded = Util.shallowCopy(replicationState.folderAdded)
			if newFolderAdded[componentName] then
				newFolderAdded[componentName]:disconnect()
				newFolderAdded[componentName] = nil
			end

			local newWatchers = Util.shallowCopy(replicationState.watchers)
			if newWatchers[componentName] then
				newWatchers[componentName]:destroy()
				newWatchers[componentName] = nil
			end

			self:updateComponent(ReplicationState, entity, {
				watchers = newWatchers,
				folderAdded = newFolderAdded,
			})
		end)
	end

	for componentName, observer in pairs(self._entityAddedObservers) do
		observer:forEach(function(entity: Instance | {})
			if typeof(entity) ~= "Instance" then
				return
			end

			local replicatedStateComponent = self:getComponent(ReplicationState, entity)
			if not replicatedStateComponent then
				replicatedStateComponent = self:addComponent(ReplicationState, entity)
			end

			local replicatedContainerName = ("%s:replicated"):format(componentName)
			local container = entity:FindFirstChild(replicatedContainerName)

			if not container then
				local childAdded
				childAdded = entity.ChildAdded:connect(function(child: Instance)
					if child.Name == replicatedContainerName then
						childAdded:disconnect()
						-- clear listener from replicatedState
						local replicationState = self:getComponent(ReplicationState, entity)
						local newFolderAdded = Util.shallowCopy(replicationState.folderAdded)
						newFolderAdded[componentName] = nil
						self:updateComponent(componentName, entity, {
							folderAdded = newFolderAdded,
						})
						-- schedule the replication logic to be added next tick
						observer:mark(entity, self:getComponent(componentName, entity))
					end
				end)

				local newFolderAdded = Util.shallowCopy(replicatedStateComponent.folderAdded)
				newFolderAdded[componentName] = childAdded
				self:updateComponent(ReplicationState, entity, {
					folderAdded = newFolderAdded,
				})
				return
			end

			local watcher = ContainerWatcher.new(container)
			local newWatchers = Util.shallowCopy(replicatedStateComponent.watchers)
			newWatchers[componentName] = watcher
			self:updateComponent(ReplicationState, entity, {
				watchers = newWatchers,
			})
		end)
	end

	self:createQuery():all(ReplicationState):forEach(function(entity, replicationState)
		for componentName, watcher in pairs(replicationState.watchers) do
			if watcher.dirty then
				self:updateComponent(componentName, entity, watcher:read())
			end
		end
	end)
end

function ReplicationSystem:onDestroy()
	self._componentRegisteredListener:disconnect()
	self._componentUnregisteredListener:disconnect()
end

return ReplicationSystem
