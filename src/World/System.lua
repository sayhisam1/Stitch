local RunService = game:GetService("RunService")
local EntityQuery = require(script.Parent.EntityQuery)
local inlinedError = require(script.Parent.Parent.Shared.inlinedError)

local System = {}
System.__index = System

System.priority = 1000
System.updateEvent = RunService.Heartbeat

function System:createQuery()
	return EntityQuery.new(self.stitch.entityManager)
end

function System:registerComponent(component)
	if not self._components then
		self._components = {}
	end

	self.stitch.entityManager.collection:register(component)
	table.insert(self._components, component)
end

function System:create()
	xpcall(self.onCreate, inlinedError, self, self.stitch)
end

function System:update()
	xpcall(self.onUpdate, inlinedError, self, self.stitch)
end

function System:destroy()
	xpcall(self.onDestroy, inlinedError, self, self.stitch)
	if self._components then
		for _, component in ipairs(self._components) do
			self.stitch.entityManager.collection:unregister(component)
		end
	end
end

-- User overridable functions
function System:onCreate() end

function System:onUpdate() end

function System:onDestroy() end

-- Helper methods that wrap stitch entityManager behavior
function System:addComponent(...)
	return self.stitch.entityManager:addComponent(...)
end

function System:getComponent(...)
	return self.stitch.entityManager:getComponent(...)
end

function System:setComponent(...)
	return self.stitch.entityManager:setComponent(...)
end

function System:updateComponent(...)
	return self.stitch.entityManager:updateComponent(...)
end

function System:removeComponent(...)
	return self.stitch.entityManager:removeComponent(...)
end

return System
