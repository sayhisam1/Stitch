local Util = require(script.Parent.Parent.Parent.Shared.Util)
local Serialization = require(script.Parent.Serialization)

local ReplicationSystem = {}


ReplicationSystem.name = "ReplicationSystem"
ReplicationSystem.priority = -1E10
ReplicationSystem.stateComponent = {
	name = "replicationSystemState",
	defaults = {
		lastComponentData = {},
		lastComponents = {},
	}
}

function ReplicationSystem.replicate(world, componentName: string)
	world:createQuery():all(componentName):forEach(function(entity, data)
		if not world:getComponent(ReplicationSystem.stateComponent, entity) then
			world:addComponent(ReplicationSystem.stateComponent, entity)
		end

		local state = world:getComponent(ReplicationSystem.stateComponent, entity)
		if state.lastComponentData[componentName] == data then
			return
		end
		
		-- write data to folder
		local folderName = ("%s:%s:replicated"):format(world.namespace, componentName)
		local folder = entity:FindFirstChild(folderName)
		if not folder then
			folder = Instance.new("Folder")
			folder.Name = folderName
			folder.Parent = entity
		end

		Serialization.write(data, folder)

		world:updateComponent(ReplicationSystem.stateComponent, entity,{
			lastComponentData = Util.setKey(state.lastComponentData, componentName, data)
		})
	end)
end

function ReplicationSystem.removeReplicate(world, componentName: string)
	world:createQuery():all(componentName):forEach(function(entity, data)
		if not world:getComponent(ReplicationSystem.stateComponent, entity) then
			return
		end

		local state = world:getComponent(ReplicationSystem.stateComponent, entity)
		if not state.lastComponentData[componentName] then
			return
		end
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

		ReplicationSystem.replicate(world, componentDefinition.name)
	end

	world:createQuery():all(ReplicationSystem.stateComponent):forEach(function(entity, data)
		if entity == workspace then
			return
		end

		local newComponentDatas = data.lastComponentData
		for componentName, lastData in pairs(data.lastComponentData) do
			local folderName = ("%s:%s:replicated"):format(world.namespace, componentName)
			local folder = entity:FindFirstChild(folderName)
			local newData = world:getComponent(componentName, entity)
			if not newData then
				if folder then
					folder:Destroy()
				end
				newComponentDatas = Util.removeKey(newComponentDatas, componentName)
			end
		end

		if newComponentDatas == data.lastComponentData then
			return
		end

		world:updateComponent(ReplicationSystem.stateComponent, entity, {
			lastComponentData = newComponentDatas
		})
	end)
end

return ReplicationSystem
