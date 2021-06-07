local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local DEFAULT_NAMESPACE = "game"

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
		logPrefix = ("[Stitch:%s]"):format(namespace),
		Heartbeat = RunService.Heartbeat,
		None = Symbol.named("None"),
		debug = false,
	}, Stitch)

	self._store = StitchStore.new(self)
	self._collection = PatternCollection.new(self)
	self._instanceRegistry = InstanceRegistry.new(self)

	self._store:on("patternDeconstructed", function(...)
		self:fire("patternDeconstructed", ...)
	end)

	self._store:on("patternConstructed", function(...)
		self:fire("patternConstructed", ...)
	end)

	self._store:on("patternUpdated", function(...)
		self:fire("patternUpdated", ...)
	end)

	self:registerPattern(InstancePattern)
	self:setupInstanceListeners()
	return self
end

function Stitch:destroy()
	self:fire("destroyed")
	self._instanceAdded:disconnect()
	self._instanceRemoved:disconnect()
	self._store:destroy()
	self._collection:destroy()
	self._instanceRegistry:destroy()
end

function Stitch:setupInstanceListeners()
	local instanceAdded = CollectionService:GetInstanceAddedSignal(self._instanceRegistry.instanceUuidTag)
	self._instanceAdded = instanceAdded:Connect(function(instance: Instance)
		self:registerInstance(instance)
	end)

	local instanceRemoved = CollectionService:GetInstanceRemovedSignal(self._instanceRegistry.instanceUuidTag)
	self._instanceRemoved = instanceRemoved:Connect(function(instance: Instance)
		self:unregisterInstance(instance)
	end)
	for _, instance in ipairs(CollectionService:GetTagged(self._instanceRegistry.instanceUuidTag)) do
		self:registerInstance(instance)
	end
end

function Stitch:registerPattern(patternDefinition)
	local registered = self._collection:registerPattern(patternDefinition)
	self:fire("patternRegistered", registered)

	return registered
end

function Stitch:registerInstance(instance: Instance)
	if not self._instanceRegistry:isRegistered(instance) then
		local instanceUuid = self._instanceRegistry:registerInstance(instance)
		self:createRootPattern(InstancePattern, instanceUuid)
		self:fire("instanceRegistered", instance)
		return instanceUuid
	end
end

function Stitch:unregisterInstance(instance: Instance)
	local uuid = self:getUuid(instance)
	if not uuid then
		self:error(("failed to get uuid for instance %s!"):format(instance.Name))
	end
	local listener
	listener = self.Heartbeat:connect(function()
		pcall(function()
			self:deconstructPatternsWithRef(instance)
			self._store:flush()
			self._instanceRegistry:uregisterInstance(instance)
			self:fire("instanceUnregistered", instance)
		end)
		listener:disconnect()
	end)
end
function Stitch:lookupInstanceByUuid(uuid: string)
	return self._instanceRegistry:lookup(uuid)
end

function Stitch:lookupPatternByUuid(uuid: string)
	local patternData = self._store:lookup(uuid)
	if not patternData then
		return
	end
	local pattern = self._collection:resolveOrErrorPattern(patternData.patternName)
	return setmetatable(patternData, pattern)
end

function Stitch:getUuid(ref: any)
	local uuid

	if typeof(ref) == "string" then
		uuid = ref
	elseif typeof(ref) == "Instance" then
		uuid = self._instanceRegistry:getInstanceUuid(ref)
	elseif typeof(ref) == "table" then
		uuid = ref.uuid
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
	local attached_uuid = refdata and refdata["attached"][patternName]

	if attached_uuid then
		local data = self._store:lookup(attached_uuid)
		local pattern = self._collection:resolveOrErrorPattern(data.patternName)
		return setmetatable(data, pattern)
	end
end

function Stitch:getOrCreatePatternByRef(patternResolvable, ref, data: table?)
	-- for convenience, if the ref is an instance, we register the instance
	if typeof(ref) == "Instance" and not self._instanceRegistry:isRegistered(ref) then
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
			patternName = pattern.name,
		})
		self:flushActions()

		attached_pattern = self:getPatternByRef(patternResolvable, ref)
	end

	return attached_pattern
end

function Stitch:createRootPattern(patternResolvable, uuid: string, data: table?)
	uuid = uuid or HttpService:GenerateGUID(false)
	local patternName = self._collection:getPatternName(patternResolvable)

	self._store:dispatch({
		type = "constructPattern",
		refuuid = uuid,
		uuid = uuid,
		data = data or {},
		patternName = patternName,
	})
	self:flushActions()
	local attached_pattern = self:getPatternByRef(patternResolvable, uuid)

	return attached_pattern
end

function Stitch:deconstructPatternsWithRef(ref)
	local uuid = self:getUuid(ref)
	self._store:dispatch({
		type = "deconstructPattern",
		uuid = uuid,
	})
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

function Stitch:flushActions()
	self._store:flush()
end

function Stitch:error(message)
	error(("%s %s"):format(self.logPrefix, message), 2)
end

function Stitch:pdebug(message)
	if self.debug then
		warn(("%s %s"):format(self.logPrefix, message))
	end
end

return Stitch
