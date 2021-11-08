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
		lastComponents = {},
	},
	destructor = function(_, data)
		for _, listener in pairs(data.tagAddedListeners) do
			listener:disconnect()
		end
		for _, listener in pairs(data.tagRemovedListeners) do
			listener:disconnect()
		end
	end
}

function TagSystem.onUpdate(world)
	local function addComponentIfNotExists(componentDefinition, instance)
		if not world:getComponent(componentDefinition, instance) then
			world:addComponent(componentDefinition, instance)
		end
	end
	local registeredComponents = world.componentRegistry:getAll()
	addComponentIfNotExists(TagSystem.stateComponent, workspace)
	local state = world:getComponent(TagSystem.stateComponent, workspace)

	if state.lastComponents == registeredComponents then
		return
	end

	-- handle new additions
	local newTagAddedListeners = {}
	local newTagRemovedListeners = {}
	for _, componentDefinition in pairs(registeredComponents) do
		local tag = componentDefinition.tag
		if not tag then
			continue
		end

		if typeof(tag) == "boolean" then
			tag = componentDefinition.name
		end

		if state.tagAddedListeners[tag] then
			newTagAddedListeners[tag] = state.tagAddedListeners[tag]
			newTagRemovedListeners[tag] = state.tagRemovedListeners[tag]
			continue
		end

		newTagAddedListeners[componentDefinition.name] = CollectionService:GetInstanceAddedSignal(tag):Connect(function(instance)
			addComponentIfNotExists(componentDefinition, instance)
		end)
		for _, instance in pairs(CollectionService:GetTagged(tag)) do
			addComponentIfNotExists(componentDefinition, instance)
		end

		newTagRemovedListeners[componentDefinition.name] = CollectionService:GetInstanceRemovedSignal(tag):Connect(function(instance)
			world:removeComponent(componentDefinition, instance)
		end)
	end

	-- check for removed components
	for name, listener in pairs(state.tagAddedListeners) do
		if not registeredComponents[name] then
			listener:disconnect()
			newTagAddedListeners[name] = nil
		end
	end
	for name, listener in pairs(state.tagRemovedListeners) do
		if not registeredComponents[name] then
			listener:disconnect()
			newTagRemovedListeners[name] = nil
		end
	end

	world:updateComponent(TagSystem.stateComponent, workspace, {
		tagAddedListeners = newTagAddedListeners,
		tagRemovedListeners = newTagRemovedListeners,
		lastComponents = registeredComponents,
	})
end

return TagSystem
