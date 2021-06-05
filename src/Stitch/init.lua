local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local DEFAULT_NAMESPACE = "game"
local t = require(script.Parent.Parent.t)

local PatternCollection = require(script.PatternCollection)
local StitchStore = require(script.StitchStore)
local InstanceRegistry = require(script.InstanceRegistry)
local Symbol = require(script.Parent.Shared.Symbol)
local InstancePattern = require(script.InstancePattern)

local Stitch = {}
Stitch.__index = Stitch

function Stitch.new(namespace)
	namespace = namespace or DEFAULT_NAMESPACE

	local self = setmetatable({
		namespace = namespace,
		_listeners = {},
		errorPrefix = ("[Stitch:%s]"):format(namespace),
		Heartbeat = RunService.Heartbeat,
		None = Symbol.named("None"),
	}, Stitch)

	self._store = StitchStore.new(self)
	self._collection = PatternCollection.new(self)
	self._instanceRegistry = InstanceRegistry.new(self)

	self:registerPattern(InstancePattern)
	return self
end

function Stitch:destroy()
	self._store:destroy()
	self._collection:destroy()
	self._instanceRegistry:destroy()
end

function Stitch:registerPattern(patternDefinition)
	local registered = self._collection:registerPattern(patternDefinition)
	self:fire("patternRegistered", registered)

	return registered
end

function Stitch:registerInstance(instance: Instance)
	local instanceUuid = self._instanceRegistry:registerInstance(instance)
	self:createRootPattern(InstancePattern, instanceUuid)

	return instanceUuid
end

function Stitch:lookupUuid(uuid: string)
	return self._instanceRegistry:lookup(uuid) or self._store:lookup(uuid)
end

function Stitch:getUuid(ref)
	local uuid

	if t.Instance(ref) then
		uuid = self._instanceRegistry:getInstanceUuid(ref)
	elseif t.table(ref) then
		uuid = ref.uuid
	elseif t.string(ref) then
		uuid = ref
	end

	return uuid
end

function Stitch:getPatternByRef(patternResolvable, ref)
	local patternName = self._collection:getPatternName(patternResolvable)
	local refuuid = self:getUuid(ref)
	if not refuuid then
		return nil
	end
	local refdata = self._store:lookup(refuuid)
	local attached_uuid = refdata["attached"][patternName]

	return attached_uuid and self._store:lookup(attached_uuid) or nil
end

function Stitch:getOrCreatePatternByRef(patternResolvable, ref, data: table?)
	-- for convenience, if the ref is an instance, we register the instance
	if t.Instance(ref) and not self._instanceRegistry:getInstanceUuid(ref) then
		ref = self:registerInstance(ref)
	end

	local attached_pattern = self:getPatternByRef(patternResolvable, ref)
	if not attached_pattern then
		local pattern = self._collection:resolvePattern(patternResolvable)
		local refuuid = self:getUuid(ref)

		self._store:dispatch({
			type = "constructPattern",
			refuuid = refuuid,
			uuid = HttpService:GenerateGUID(false),
			data = data or {},
			pattern = pattern,
		})

		attached_pattern = self:getPatternByRef(patternResolvable, ref)
	end

	return attached_pattern
end

function Stitch:createRootPattern(patternResolvable, uuid: string, data: table?)
	uuid = uuid or HttpService:GenerateGUID(false)
	local pattern = self._collection:resolvePattern(patternResolvable)

	self._store:dispatch({
		type = "constructPattern",
		refuuid = uuid,
		uuid = uuid,
		data = data or {},
		pattern = pattern,
	})

	return self:getPatternByRef(patternResolvable, uuid)
end

-- function Stitch:removeAllWorkingsWithRef(ref)
-- 	return self._collection:removeAllWorkingsWithRef(ref)
-- end

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

function Stitch:error(message)
	error(("%s %s"):format(self.errorPrefix, message), 2)
end

return Stitch
