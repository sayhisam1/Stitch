local RunService = game:GetService("RunService")
local inlinedError = require(script.Parent.Parent.Shared.inlinedError)
local Util = require(script.Parent.Parent.Shared.Util)

local System = {}
System.__index = System

System.priority = 1000
System.updateEvent = RunService.Heartbeat

function System:create(world)
	if self.stateComponent then
		world:registerComponent(Util.setKey(self.stateComponent, "name", self.stateComponent.name or self.name))
	end
	xpcall(self.onCreate, inlinedError, self, world)
end

function System:update(world)
	xpcall(self.onUpdate, inlinedError, self, world)
end

function System:destroy(world)
	xpcall(self.onDestroy, inlinedError, self, world)
	if self.stateComponent then
		world:unregisterComponent(Util.setKey(self.stateComponent, "name", self.stateComponent.name or self.name))
	end
end

-- User overridable functions
function System:onCreate() end

function System:onUpdate() end

function System:onDestroy() end

return System
