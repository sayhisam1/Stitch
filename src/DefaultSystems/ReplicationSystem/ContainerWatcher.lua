local Serialization = require(script.Parent.Serialization)

local ContainerWatcher = {}
ContainerWatcher.__index = ContainerWatcher

function ContainerWatcher.new(container: Folder)
	local self = setmetatable({
		_container = container,
	}, ContainerWatcher)
	self.changedListeners = {}
	self.dirty = true
	self._instanceAddedSignal = container.ChildAdded:Connect(function(child)
		self.dirty = true
		self.changedListeners[child] = child.Changed:connect(function()
			self.dirty = true
		end)
	end)
	for _, child in pairs(container:GetChildren()) do
		self.changedListeners[child] = child.Changed:connect(function()
			self.dirty = true
		end)
	end
	self._instanceRemovedSignal = container.ChildRemoved:connect(function(child)
		if self.changedListeners[child] then
			self.changedListeners[child]:disconnect()
			self.changedListeners[child] = nil
		end
	end)
	return self
end

function ContainerWatcher:destroy()
	self._container = nil
	self._instanceAddedSignal:disconnect()
	self._instanceRemovedSignal:disconnect()
	for child, listener in pairs(self.changedListeners) do
		listener:disconnect()
		self.changedListeners[child] = nil
	end
end

function ContainerWatcher:reset()
	self.dirty = false
end

function ContainerWatcher:read()
	if self.dirty then
		self.data = Serialization.read(self._container)
		self.dirty = false
	end
	return self.data
end

return ContainerWatcher
