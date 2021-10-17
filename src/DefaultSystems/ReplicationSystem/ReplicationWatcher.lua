local Serialization = require(script.Parent.Serialization)

local ReplicationWatcher = {}
ReplicationWatcher.__index = ReplicationWatcher

function ReplicationWatcher.new(parent: Instance, name:string)
	local self = setmetatable({
		parent = parent,
		root = nil,
		name = name,
		dirty = false,
		listeners = {},
		data = {},
	}, ReplicationWatcher)

	local root = parent:FindFirstChild(name)
	if not root then
		local rootAdded = parent.ChildAdded:Connect(function(child)
			if child.Name == name then
				self.root = root
				for k,v in pairs(self.listeners) do
					v:disconnect()
					self.listeners[k] = nil
				end
				self:initializeListeners()
			end
		end)
		table.insert(self.listeners, rootAdded)
	else
		self.root = root
		self:initializeListeners()
	end
	
	return self
end

function ReplicationWatcher:initializeListeners()
	self._instanceAddedSignal = self.root.ChildAdded:Connect(function(child)
		self.dirty = true
		self.listeners[child] = child.Changed:connect(function()
			self.dirty = true
		end)
	end)
	for _, child in pairs(self.root:GetChildren()) do
		self.listeners[child] = child.Changed:connect(function()
			self.dirty = true
		end)
	end
	self._instanceRemovedSignal = self.root.ChildRemoved:connect(function(child)
		if self.listeners[child] then
			self.listeners[child]:disconnect()
			self.listeners[child] = nil
		end
	end)
	self.dirty=true
end

function ReplicationWatcher:destroy()
	for child, listener in pairs(self.listeners) do
		listener:disconnect()
		self.listeners[child] = nil
	end
end

function ReplicationWatcher:isDirty()
	return self.dirty
end

function ReplicationWatcher:reset()
	self.dirty = false
end

function ReplicationWatcher:read()
	if self:isDirty() then
		self.data = Serialization.read(self.root)
		self.dirty = false

	end
	return self.data
end

return ReplicationWatcher
