local RunService = game:GetService("RunService")

local DEFAULT_NAMESPACE = "game"

local PatternCollection = require(script.PatternCollection)

local Stitch = {}
Stitch.__index = Stitch

function Stitch.new(namespace)
	namespace = namespace or DEFAULT_NAMESPACE
	local self = setmetatable({
		namespace = namespace,
		_listeners = {},
		instanceUUIDTag = string.format("Stitch_%s_UUIDTagged", namespace),
		instanceUUIDAttributeString = string.format("Stitch_%s_UUID", namespace),
		errorPrefix = string.format("[Stitch:%s]", namespace),
		Heartbeat = RunService.Heartbeat,
	}, Stitch)
	self._collection = PatternCollection.new(self)
	return self
end

function Stitch:Destroy()
	self._collection:Destroy()
end
function Stitch:registerPattern(patternDefinition)
	return self._collection:register(patternDefinition)
end

function Stitch:getWorkingByRef(patternResolvable, ref)
	return self._collection:getWorkingByRef(patternResolvable, ref)
end

function Stitch:getOrCreateWorkingByRef(patternResolvable, ref)
	return self._collection:getOrCreateWorkingByRef(patternResolvable, ref)
end

function Stitch:removeAllWorkingsWithRef(ref)
	return self._collection:removeAllWorkingsWithRef(ref)
end

function Stitch:fire(eventName, ...)
	if not self._listeners[eventName] then
		return -- Do nothing if no listeners registered
	end

	for _, callback in ipairs(self._listeners[eventName]) do
		local success, errorValue = coroutine.resume(coroutine.create(callback), ...)

		if not success then
			warn(("Event listener for %s encountered an error: %s"):format(tostring(eventName), tostring(errorValue)))
		end
	end
end

function Stitch:on(eventName, callback)
	self._listeners[eventName] = self._listeners[eventName] or {}
	table.insert(self._listeners[eventName], callback)

	return function()
		for i, listCallback in ipairs(self._listeners[eventName]) do
			if listCallback == callback then
				table.remove(self._listeners[eventName], i)
				break
			end
		end
	end
end

return Stitch
