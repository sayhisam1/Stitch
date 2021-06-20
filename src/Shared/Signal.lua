local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({
		_listeners = {},
	}, Signal)
	return self
end

function Signal:destroy()
	self._listeners = nil
end

function Signal:connect(callback: callback)
	table.insert(self._listeners, callback)
	local disconnect = function()
		for i, v in ipairs(self._listeners) do
			if v == callback then
				table.remove(self._listeners, i)
				return
			end
		end
	end
	return {
		disconnect = disconnect,
		Disconnect = disconnect,
	}
end

Signal.Connect = Signal.connect

function Signal:fire(...)
	for _, callback in ipairs(self._listeners) do
		coroutine.wrap(callback)(...)
	end
end

Signal.Fire = Signal.fire

return Signal
