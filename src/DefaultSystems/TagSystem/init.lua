local CollectionService = game:GetService("CollectionService")
-- Automatically adds components to instance entities that are tagged
local TagSystem = {}

TagSystem.name = "TagSystem"
TagSystem.priority = -1E10

TagSystem.stateComponent = {
	name = "TagSystemState",
	defaults = {
		tagAddedListeners = {},
		tagRemovedListeners = {},
		componentAddedListeners = {},
		lastComponents = {},
	},
	destructor = function(_, data)
		for _, listener in pairs(data.tagAddedListeners) do
			listener:disconnect()
		end
		for _, listener in pairs(data.tagRemovedListeners) do
			listener:disconnect()
		end
		for _, listener in pairs(data.componentAddedListeners) do
			listener:disconnect()
		end
	end,
}

local function addComponentIfNotExists(world, componentDefinition, instance)
	if not world:getComponent(componentDefinition, instance) then
		world:addComponent(componentDefinition, instance)
	end
end

function TagSystem.onUpdate(world)
	local registeredComponents = world.componentRegistry:getAll()
	addComponentIfNotExists(world, TagSystem.stateComponent, workspace)
	local state = world:getComponent(TagSystem.stateComponent, workspace)

	if state.lastComponents == registeredComponents then
		return
	end

	world:removeComponent(TagSystem.stateComponent, workspace)

	local tagAddedListeners = {}
	local tagRemovedListeners = {}
	local componentAddedListeners = {}
	for _, componentDefinition in pairs(registeredComponents) do
		local tag = componentDefinition.tag
		if not tag then
			continue
		end

		if typeof(tag) == "boolean" then
			tag = componentDefinition.name
		end

		tagAddedListeners[componentDefinition.name] = CollectionService
			:GetInstanceAddedSignal(tag)
			:Connect(function(instance)
				addComponentIfNotExists(world, componentDefinition, instance)
			end)
		for _, instance in pairs(CollectionService:GetTagged(tag)) do
			addComponentIfNotExists(world, componentDefinition, instance)
		end

		tagRemovedListeners[componentDefinition.name] = CollectionService
			:GetInstanceRemovedSignal(tag)
			:Connect(function(instance)
				world:removeComponent(componentDefinition, instance)
			end)

		componentAddedListeners[componentDefinition.name] = world
			:getEntityAddedSignal(componentDefinition)
			:Connect(function(entity)
				if typeof(entity) == "Instance" then
					CollectionService:AddTag(entity, tag)
				end
			end)
	end

	world:addComponent(TagSystem.stateComponent, workspace, {
		tagAddedListeners = tagAddedListeners,
		tagRemovedListeners = tagRemovedListeners,
		componentAddedListeners = componentAddedListeners,
		lastComponents = registeredComponents,
	})
end

return TagSystem
