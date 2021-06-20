local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local DEFAULT_NAMESPACE = "game"

local PatternCollection = require(script.PatternCollection)
local StitchStore = require(script.StitchStore)
local Symbol = require(script.Parent.Shared.Symbol)
local Util = require(script.Parent.Shared.Util)
local InstancePattern = require(script.InstancePattern)
local HotReloader = require(script.HotReloader)
local InlinedError = require(script.Parent.Shared.InlinedError)

-- Maintain a list of created stitches so we can destroy on server close
local createdStitches = {}

game:BindToClose(function()
	for _, v in ipairs(createdStitches) do
		coroutine.wrap(function()
			v:destroy()
		end)()
	end
end)

local Stitch = {}
Stitch.__index = Stitch

function Stitch.new(namespace)
	namespace = namespace or DEFAULT_NAMESPACE

	local self = setmetatable({
		namespace = namespace,
		_listeners = {},
		logPrefix = ("[Stitch:%s]"):format(namespace),
		instanceUuidTag = ("Stitch_%s_UUID_Tag"):format(namespace),
		instanceUuidAttribute = ("Stitch_%s_UUID"):format(namespace),
		Heartbeat = RunService.Heartbeat,
		None = Symbol.named("None"),
		debug = false,
	}, Stitch)

	self._store = StitchStore.new(self)
	self._collection = PatternCollection.new(self)
	self._hotReloader = HotReloader.new(self)

	self:registerPattern(InstancePattern)
	self:setupInstanceListeners()

	table.insert(createdStitches, self)

	return self
end

function Stitch:destroy()
	self:fire("destroyed")
	self._instanceAdded:disconnect()
	self._instanceRemoved:disconnect()
	self._store:destroy()
	self._collection:destroy()
	self._hotReloader:destroy()
	table.remove(createdStitches, table.find(createdStitches, self))
end

function Stitch:setupInstanceListeners()
	local instanceAdded = CollectionService:GetInstanceAddedSignal(self.instanceUuidTag)
	self._instanceAdded = instanceAdded:Connect(function(instance: Instance)
		self:registerInstance(instance)
	end)

	local instanceRemoved = CollectionService:GetInstanceRemovedSignal(self.instanceUuidTag)
	self._instanceRemoved = instanceRemoved:Connect(function(instance: Instance)
		self:unregisterInstance(instance)
	end)

	for _, entity in ipairs(CollectionService:GetTagged(self.instanceUuidTag)) do
		self:registerInstance(entity)
	end
end

function Stitch:registerPattern(patternDefinition)
	if typeof(patternDefinition) == "Instance" and patternDefinition:IsA("ModuleScript") then
		self._hotReloader:listen(patternDefinition, function(loaded)
			if self._collection:resolvePattern(loaded) then
				self._collection:unregisterPattern(loaded)
			end
			self:registerPattern(loaded)
		end)
		return
	end

	local registered = self._collection:registerPattern(patternDefinition)
	self:fire("patternRegistered", registered)

	return registered
end

function Stitch:getInstanceUuid(entity: Instance)
	return entity:GetAttribute(self.instanceUuidAttribute)
end

function Stitch:registerInstance(instance: Instance)
	local uuid = self:getInstanceUuid(instance)
	if not uuid then
		uuid = HttpService:GenerateGUID(false)
		instance:SetAttribute(self.instanceUuidAttribute, uuid)
	end
	if not CollectionService:HasTag(instance, self.instanceUuidTag) then
		CollectionService:AddTag(instance, self.instanceUuidTag)
	end
	local existingPattern = self:lookupPatternByUuid(uuid)
	if not existingPattern then
		self._store:dispatch({
			type = "constructInstancePattern",
			refuuid = uuid,
			uuid = uuid,
			data = {},
			patternName = InstancePattern.name,
			instance = instance,
		})
		self:flushActions()
		existingPattern = self:lookupPatternByUuid(uuid)
	end
	return existingPattern
end

function Stitch:unregisterInstance(instance: Instance)
	if CollectionService:HasTag(instance, self.instanceUuidTag) then
		CollectionService:RemoveTag(instance, self.instanceUuidTag)
		-- return to let collectionservice listeners handle unregistration
		return
	end
	-- we leave the uuid on the instance, since removing the attribute seems kind of pointless
	local uuid = self:getUuid(instance)
	self:deconstructPatternsWithRef(uuid)
end

function Stitch:lookupInstanceByUuid(uuid: string)
	local pattern = self._store:lookup(uuid)
	if pattern then
		return pattern:getInstance()
	end
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
		return self:getInstanceUuid(ref)
	elseif typeof(ref) == "table" and ref.uuid then
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
	local attached_pattern = self:getPatternByRef(patternResolvable, ref)

	if not attached_pattern then
		local pattern = self._collection:resolveOrErrorPattern(patternResolvable)
		local refuuid = self:getUuid(ref)
		local constructionData = Util.mergeTable(pattern.data or {}, data or {})

		-- for convenience, if the ref is an instance, we register it
		if typeof(ref) == "Instance" and not self:lookupPatternByUuid(refuuid) then
			ref = self:registerInstance(ref)
			refuuid = ref.uuid
		end

		self._store:dispatch({
			type = "constructPattern",
			refuuid = refuuid,
			uuid = HttpService:GenerateGUID(false),
			data = constructionData,
			patternName = pattern.name,
		})

		self:flushActions()

		attached_pattern = self:getPatternByRef(patternResolvable, ref)
	end

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

-- Accepts a callback, and executes in immediately.
-- All actions (e.g. sets, construction, destruction, etc) will be guaranteed to happen
-- atomically within this callback
function Stitch:doAtomicTask(callback: callback)
	self._store:runWithAtomicDispatch(callback)
end

function Stitch:error(message, level)
	error(("%s %s"):format(self.logPrefix, message), level or 2)
end

function Stitch:inlinedError(message: string, level: int)
	InlinedError(("%s %s"):format(self.logPrefix, message), level or 3)
end

function Stitch:pdebug(...)
	if self.debug then
		print(self.logPrefix, "(DEBUG)", ...)
	end
end

return Stitch
