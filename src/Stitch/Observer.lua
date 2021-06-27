local Observer = {}
Observer.__index = Observer

function Observer.new(...)
	local self = setmetatable({
		marked = {},
		_listeners = {},
	}, Observer)

	local function mark(entity, data)
		self.marked[entity] = data
	end

	for _, signal in pairs({ ... }) do
		table.insert(self._listeners, signal:connect(mark))
	end

	return self
end

function Observer:destroy()
	for _, listener in ipairs(self._listeners) do
		listener:disconnect()
	end
	self:clear()
end

function Observer:get()
	return self.marked
end

function Observer:clear()
	table.clear(self.marked)
end

return Observer
