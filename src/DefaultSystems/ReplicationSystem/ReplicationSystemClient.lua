local ReplicationWatcher = require(script.Parent.ReplicationWatcher)
local Util = require(script.Parent.Parent.Parent.Shared.Util)
local ReplicationSystem = {}

ReplicationSystem.name = "ReplicationSystem"
ReplicationSystem.priority = -1E10
ReplicationSystem.stateComponent = {
	name = "replicationSystemState",
	defaults = {
		watchers = {},
		lastComponents = {},
	},
	destructor = function(_, data)
		for _, watcher in pairs(data.watchers) do
			watcher:destroy()
		end
	end,
}

function ReplicationSystem.createWatchers(world, componentName: string)
	world:createQuery():all(componentName):forEach(function(entity, data)
		if not world:getComponent(ReplicationSystem.stateComponent, entity) then
			world:addComponent(ReplicationSystem.stateComponent, entity)
		end

		local state = world:getComponent(ReplicationSystem.stateComponent, entity)
		if state.watchers[componentName] then
			if state.watchers[componentName]:isDirty() then
				world:updateComponent(componentName, entity, state.watchers[componentName]:read())
			end
			return
		end

		local watcher = ReplicationWatcher.new(entity, ("%s:%s:replicated"):format(world.namespace, componentName))
		world:updateComponent(ReplicationSystem.stateComponent, entity, {
			watchers = Util.setKey(state.watchers, componentName, watcher),
		})
		world:updateComponent(componentName, entity, watcher:read())
	end)
end

function ReplicationSystem.removeWatchers(world, componentName: string)
	world:createQuery():all(componentName):forEach(function(entity, data)
		local state = world:getComponent(ReplicationSystem.stateComponent, entity)
		if not state then
			return
		end

		if not state.watchers[componentName] then
			return
		end

		state.watchers[componentName.name]:destroy()
		world:updateComponent(ReplicationSystem.stateComponent, entity, {
			watchers = Util.removeKey(state.watchers, componentName),
		})
	end)
end

function ReplicationSystem.onUpdate(world)
	local function addComponentIfNotExists(componentDefinition, instance)
		if not world:getComponent(componentDefinition, instance) then
			world:addComponent(componentDefinition, instance)
		end
	end
	local registeredComponents = world.componentRegistry:getAll()
	addComponentIfNotExists(ReplicationSystem.stateComponent, workspace)
	local state = world:getComponent(ReplicationSystem.stateComponent, workspace)

	if state.lastComponents ~= registeredComponents then
		-- check for removed components
		for name, _ in pairs(state.lastComponents) do
			if not registeredComponents[name] then
				ReplicationSystem:removeReplicate(world, name)
			end
		end
		world:updateComponent(ReplicationSystem.stateComponent, workspace, {
			lastComponents = registeredComponents,
		})
	end

	for _, componentDefinition in pairs(registeredComponents) do
		if not componentDefinition.replicate then
			continue
		end

		ReplicationSystem.createWatchers(world, componentDefinition.name)
	end

	world:createQuery():all(ReplicationSystem.stateComponent):forEach(function(entity, data)
		if entity == workspace then
			return
		end

		local newWatchers = data.watchers
		for componentName, watcher in pairs(data.watchers) do
			local newData = world:getComponent(componentName, entity)
			if not newData then
				watcher:destroy()
				newWatchers = Util.removeKey(newWatchers, componentName)
			end
		end

		if newWatchers == data.watchers then
			return
		end

		world:updateComponent(ReplicationSystem.stateComponent, entity, {
			watchers = newWatchers
		})
	end)
end

return ReplicationSystem
