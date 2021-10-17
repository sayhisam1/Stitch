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

	self.stitch:registerComponent(component)
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
			self.stitch:unregisterComponent(component)
		end
	end
end

-- User overridable functions
function System:onCreate() end

function System:onUpdate() end

function System:onDestroy() end

return System
