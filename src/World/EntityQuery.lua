local inlinedError = require(script.Parent.Parent.Shared.inlinedError)

local EntityQuery = {}
EntityQuery.__index = EntityQuery

function EntityQuery.new(entityManager)
	assert(entityManager, "Tried to create query without entity manager!")
	local self = setmetatable({
		withComponents = {},
		withoutComponents = {},
		entityManager = entityManager,
	}, EntityQuery)

	return self
end

function EntityQuery:all(...)
	local values = { ... }
	table.move(values, 1, #values, #self.withComponents + 1, self.withComponents)
	return self
end

function EntityQuery:except(...)
	local values = { ... }
	table.move(values, 1, #values, #self.withoutComponents + 1, self.withoutComponents)
	return self
end

function EntityQuery:get()
	local entities = self.entityManager:getEntitiesWith(self.withComponents[1])
	local validEntities = {}
	for _, entity in ipairs(entities) do
		local valid = true
		for _, withComponent in ipairs(self.withComponents) do
			if not self.entityManager:getComponent(withComponent, entity) then
				valid = false
				break
			end
		end
		for _, withoutComponent in ipairs(self.withoutComponents) do
			if self.entityManager:getComponent(withoutComponent, entity) then
				valid = false
				break
			end
		end
		if valid then
			table.insert(validEntities, entity)
		end
	end
	return validEntities
end

function EntityQuery:forEach(callback: ({},...{}) -> nil)
	local entities = self.entityManager:getEntitiesWith(self.withComponents[1])
	for _, entity in ipairs(entities) do
		local obtainedComponents = table.create(#self.withComponents)
		table.insert(obtainedComponents, self.entityManager:getComponent(self.withComponents[1], entity))

		local valid = true
		for _, withComponent in ipairs(self.withComponents) do
			local component = self.entityManager:getComponent(withComponent, entity)
			if not component then
				valid = false
				break
			end
			table.insert(obtainedComponents, component)
		end
		for _, withoutComponent in ipairs(self.withoutComponents) do
			if self.entityManager:getComponent(withoutComponent, entity) then
				valid = false
				break
			end
		end
		if valid then
			xpcall(callback, inlinedError, entity, unpack(obtainedComponents))
		end
	end
end

return EntityQuery
