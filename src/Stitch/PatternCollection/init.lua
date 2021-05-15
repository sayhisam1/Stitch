local CollectionService = game:GetService("CollectionService")

local t = require(script.Parent.Parent.Parent.t)
local Rodux = require(script.Parent.Parent.Parent.Rodux)

local Types = require(script.Parent.Types)
local Reducers = require(script.Reducers)
local DeferredCallback = require(script.Parent.Parent.Shared.DeferredCallback)
local Maid = require(script.Parent.Parent.Shared.Maid)

local callbackMiddleware = require(script.callbackMiddleware)

local PatternCollection = {}
PatternCollection.__index = PatternCollection

function PatternCollection.new(stitch)
	local self = setmetatable({
		stitch = stitch,
		_reducers = {},
		_maid = Maid.new(),
	}, PatternCollection)

	self:_setupReducers(self._reducers)
	local reducer = function(state, action)
		state = state or {}
		if self._reducers[action.type] then
			state = self._reducers[action.type](state, action)
		end
		return state
	end
	self._store = Rodux.Store.new(reducer, {
		patterns = {},
		workings = {},
		UUIDToInstance = {},
		UUIDAttached = {},
	}, {
		callbackMiddleware,
	})

	self:_setupInstanceListener()
	return self
end

function PatternCollection:Destroy()
	self._maid:Destroy()
	self._store:destruct()
	-- Remove all attributes and tags
	for _, instance in pairs(CollectionService:GetTagged(self.stitch.instanceUUIDTag)) do
		instance:SetAttribute(self.stitch.instanceUUIDAttributeString, nil)
		CollectionService:RemoveTag(instance, self.stitch.instanceUUIDTag)
	end
end

function PatternCollection:_setupReducers(reducerTable)
	for reducerName, reducerCreator in pairs(Reducers) do
		reducerTable[reducerName] = reducerCreator(self.stitch)
	end
end
function PatternCollection:_setupInstanceListener()
	local deferredAdd = DeferredCallback.new(self.stitch.Heartbeat)
	self._maid:GiveTask(deferredAdd)
	local instanceAdded = CollectionService:GetInstanceAddedSignal(self.stitch.instanceUUIDTag)
	self._maid:GiveTask(instanceAdded:Connect(function(instance: Instance)
		deferredAdd:defer(function()
			print("instanceadded", instance)
			self._store:dispatch({
				type = "registerInstance",
				ref = instance,
				callback = function()
					self.stitch:fire("instanceRegistered", instance)
				end,
			})
		end)
	end))
	local deferredRemove = DeferredCallback.new(self.stitch.Heartbeat)
	self._maid:GiveTask(deferredRemove)
	local instanceRemoved = CollectionService:GetInstanceRemovedSignal(self.stitch.instanceUUIDTag)
	self._maid:GiveTask(instanceRemoved:Connect(function(instance: Instance)
		print("deferring removal of", instance)
		deferredRemove:defer(function()
			self._store:dispatch({
				type = "unregisterInstance",
				ref = instance,
				callback = function()
					self.stitch:fire("instanceUnregistered", instance)
				end,
			})
		end)
	end))
end

function PatternCollection:register(patternDefinition)
	t.strict(Types.PatternDefinition)(patternDefinition)
	self._store:dispatch({
		type = "registerPattern",
		patternDefinition = patternDefinition,
		callback = function()
			self.stitch:fire("patternRegistered", patternDefinition)
		end,
	})
end

function PatternCollection:resolveByUUID(uuid, state)
	t.strict(t.string)(uuid)
	return self:resolveInstanceByUUID(uuid, state) or self:resolveWorkingByUUID(uuid, state)
end

function PatternCollection:resolveWorkingByUUID(uuid, state)
	t.strict(t.string)(uuid)
	state = state or self._store:getState()
	return state["workings"][uuid]
end

function PatternCollection:resolveWorking(workingResolvable, state)
	if t.table(workingResolvable) then
		return self:resolveInstanceByUUID(workingResolvable.uuid, state)
	end
	return self:resolveWorkingByUUID(workingResolvable, state)
end

function PatternCollection:resolveInstanceByUUID(uuid, state)
	t.strict(t.string)(uuid)
	state = state or self._store:getState()
	return state["UUIDToInstance"][uuid]
end

function PatternCollection:getInstanceUUID(instance)
	t.strict(t.Instance)(instance)
	return instance:GetAttribute(self.stitch.instanceUUIDAttributeString)
end

function PatternCollection:getRefUUID(ref)
	return (t.string(ref) and ref) or (t.Instance(ref) and self:getInstanceUUID(ref)) or (t.table(ref) and ref.uuid)
end
function PatternCollection:getWorkingByRef(patternResolvable, ref, state)
	local staticPattern = self:resolveOrErrorPattern(patternResolvable)
	local refUUID = self:getRefUUID(ref)
	state = state or self._store:getState()
	return state["UUIDAttached"][refUUID] and state["UUIDAttached"][refUUID][staticPattern.name] or nil
end

function PatternCollection:createWorking(patternResolvable, ref, data)
	self._store:dispatch({
		type = "createWorking",
		data = data,
		ref = ref,
		patternResolvable = patternResolvable,
	})
	return self:getWorkingByRef(patternResolvable, ref)
end

function PatternCollection:getOrCreateWorkingByRef(patternResolvable, ref, data)
	return self:getWorkingByRef(patternResolvable, ref) or self:createWorking(patternResolvable, ref, data)
end

function PatternCollection:resolvePattern(patternResolvable, state)
	if not t.union(t.string, t.interface({ name = t.string }))(patternResolvable) then
		error(("%s Invalid PatternResolvable %s of type %s"):format(
			self.stitch.errorPrefix,
			tostring(patternResolvable),
			typeof(patternResolvable)
		))
	end
	state = state or self._store:getState()
	if t.table(patternResolvable) then
		patternResolvable = patternResolvable.name
	end
	return state["patterns"][patternResolvable]
end

function PatternCollection:resolveOrErrorPattern(patternResolvable, state)
	return self:resolvePattern(patternResolvable, state) or error(("%s Failed to resolve Pattern %s!"):format(
		self.stitch.errorPrefix,
		tostring(patternResolvable)
	))
end

function PatternCollection:destroyWorking(workingResolvable)
	local working = self:resolveWorking(workingResolvable)
	self._store:dispatch({
		type = "destroyWorking",
		workingResolvable = workingResolvable,
		callback = function()
			self.stitch:fire("destroyedWorking", working)
		end,
	})
end

function PatternCollection:removeAllWorkingsWithRef(ref)
	local refUUID = self:getRefUUID(ref)
	local state = self._store:getState()
	local refAttached = state["UUIDAttached"][refUUID]
	if refAttached then
		for staticPattern, uuid in pairs(refAttached) do
			self:destroyWorking(uuid)
		end
	end
end
return PatternCollection
