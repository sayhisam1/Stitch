local Observer = {}
Observer.__index = Observer

function Observer.new(entityManager, componentResolvable: string | table)
	local componentName = entityManager.collection:resolveOrError(componentResolvable)

	local self = setmetatable({
		componentName = componentName,
		dirtyList = {},
	}, Observer)

	local function markDirty(entity)
		self.dirtyList[entity] = entity
	end
	local function unmarkDirty(entity)
		self.dirtyList[entity] = nil
	end
	self._entityChangedSignal = entityManager:getEntityChangedSignal(componentResolvable):connect(markDirty)

	self._entityAddedSignal = entityManager:getEntityAddedSignal(componentResolvable):connect(markDirty)

	self._entityRemovedSignal = entityManager:getEntityRemovedSignal(componentResolvable):connect(unmarkDirty)

	for _, entity in pairs(entityManager:getEntitiesWith(componentResolvable)) do
		markDirty(entity)
	end

	return self
end

function Observer:destroy()
	self._entityChangedSignal:disconnect()
	self._entityAddedSignal:disconnect()
	self._entityRemovedSignal:disconnect()
	self:clear()
end

function Observer:get()
	return self.dirtyList
end

function Observer:clear()
	table.clear(self.dirtyList)
end

return Observer
