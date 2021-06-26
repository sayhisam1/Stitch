local RunService = game:GetService("RunService")
local Observer = require(script.Parent.Observer)
--!strict

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
	self:onCreate()
end

function System:update()
	self:onUpdate()
	if self._observers then
		for _, observer in ipairs(self._observers) do
			observer:clear()
		end
	end
end

function System:destroy()
	self:onDestroy()
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
