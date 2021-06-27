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

function System:registerSystemStateComponent(component)
	if not self._systemStateComponents then
		self._systemStateComponents = {}
	end

	self.stitch.entityManager.collection:register(component)
	table.insert(self._systemStateComponents, component)
end

function System:connectEntityAddedSignal(componentResolvable: string | table, callback: callback)
	if not self._listeners then
		self._listeners = {}
	end

	local listener = self.stitch.entityManager:getEntityAddedSignal(componentResolvable):connect(callback)
	table.insert(self._listeners, listener)
end

function System:connectEntityChangedSignal(componentResolvable: string | table, callback: callback)
	if not self._listeners then
		self._listeners = {}
	end

	local listener = self.stitch.entityManager:getEntityChangedSignal(componentResolvable):connect(callback)
	table.insert(self._listeners, listener)
end

function System:connectEntityRemovedSignal(componentResolvable: string | table, callback: callback)
	if not self._listeners then
		self._listeners = {}
	end

	local listener = self.stitch.entityManager:getEntityRemovedSignal(componentResolvable):connect(callback)
	table.insert(self._listeners, listener)
end

function System:create()
	xpcall(self.onCreate, inlinedError, self, self.stitch)
end

function System:update()
	xpcall(self.onUpdate, inlinedError, self, self.stitch)
	if self._observers then
		for _, observer in ipairs(self._observers) do
			observer:clear()
		end
	end
end

function System:destroy()
	xpcall(self.onDestroy, inlinedError, self, self.stitch)
	if self._observers then
		for _, observer in ipairs(self._observers) do
			observer:destroy()
		end
	end
	if self._listeners then
		for _, listener in ipairs(self._listeners) do
			listener:disconnect()
		end
	end
	if self._systemStateComponents then
		for _, component in ipairs(self._systemStateComponents) do
			self.stitch.entityManager.collection:unregister(component)
		end
	end
end

-- User overridable functions
function System:onCreate() end

function System:onUpdate() end

function System:onDestroy() end

return System
