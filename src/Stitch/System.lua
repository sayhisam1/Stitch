local RunService = game:GetService("RunService")
local Observer = require(script.Parent.Observer)
local inlinedError = require(script.Parent.Parent.Shared.inlinedError)

local System = {}
System.__index = System

System.priority = 1000
System.updateEvent = RunService.Heartbeat

function System:createObserver(componentResolvable)
	local observer = Observer.new(self.stitch.entityManager, componentResolvable)
	if not self._observers then
		self._observers = {}
	end
	table.insert(self._observers, observer)
	return observer
end
function System:create()
	xpcall(self.onCreate, inlinedError, self)
end

function System:update()
	xpcall(self.onUpdate, inlinedError, self)
	if self._observers then
		for _, observer in ipairs(self._observers) do
			observer:clear()
		end
	end
end

function System:destroy()
	xpcall(self.onDestroy, inlinedError, self)
	if self._observers then
		for _, observer in ipairs(self._observers) do
			observer:destroy()
		end
	end
end

-- User overridable functions
function System:onCreate() end

function System:onUpdate() end

function System:onDestroy() end

return System
