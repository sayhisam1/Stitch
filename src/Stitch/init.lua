--!strict
local HttpService = game:GetService("HttpService")

local DEFAULT_NAMESPACE = "game"

local Util = require(script.Parent.Shared.Util)
local Signal = require(script.Parent.Shared.Signal)
local PatternCollection = require(script.PatternCollection)

local Stitch = {}
Stitch.__index = Stitch

function Stitch.new(namespace: string)
	namespace = namespace or DEFAULT_NAMESPACE

	local self = setmetatable({
		namespace = namespace,
		logPrefix = ("[Stitch:%s]"):format(namespace),
		instanceUuidTag = ("Stitch_%s_UUID_Tag"):format(namespace),
		instanceUuidAttribute = ("Stitch_%s_UUID"):format(namespace),
	}, Stitch)

	self._collection = PatternCollection.new(self)
	self.entities = {
		data = {},
	}
	self.identifierToInstance = {}

	return self
end

function Stitch:destroy()
	if self._events then
		for key: string, event in pairs(self._events) do
			event:destroy()
		end
	end
end

function Stitch:addPattern(patternDefinition: table | ModuleScript)
	self._collection:register(patternDefinition)
end

-- Returns an entity given a reference
function Stitch:register(reference: Instance)
	local uuid = reference:GetAttribute(self.instanceUuidAttribute)

	if not uuid then
		uuid = HttpService:GenerateGUID(false)
		reference:SetAttribute(self.instanceUuidAttribute, uuid)
	end

	if self.entities.data[uuid] then
		self:error(("tried to register reference with uuid %s, but already registered!"):format(uuid))
	end

	self.entities.data[uuid] = {}
	self.identifierToInstance[uuid] = reference

	return uuid
end

function Stitch:unregister(entityResolvable: Instance | string)
	local instance = entityResolvable
	if typeof(entityResolvable) == "string" then
		instance = self.identifierToInstance[entityResolvable]
	end

	if not instance then
		self:error(("failed to resolve instance for %s!"):format(tostring(entityResolvable)))
	end

	local entity = instance:GetAttribute(self.instanceUuidAttribute)
	if not entity or not self.entities.data[entity] then
		self:error(("failed to resolve %s (may be already removed?)!"):format(tostring(entity)))
	end

	for patternName, data in pairs(self.entities.data[entity]) do
		local pattern = self._collection:resolveOrError(patternName)
		self:fire(pattern.name .. "Removed", self.identifierToInstance[entity], setmetatable(data, pattern))
		self.entities.data[entity][patternName] = nil
	end

	self.identifierToInstance[entity] = nil
end

function Stitch:remove(patternResolvable: string | table, entityResolvable: Instance | string)
	local pattern = self._collection:resolveOrError(patternResolvable)

	local entity = entityResolvable

	if typeof(entityResolvable) == "Instance" then
		entity = entityResolvable:GetAttribute(self.instanceUuidAttribute)
	end

	if not entity then
		error(("tried to remove %s from invalid entity %s!"):format(patternResolvable, tostring(entityResolvable)))
	end

	if not self.entities.data[entity][pattern.name] then
		error(("tried to remove non-existant %s from %s!"):format(patternResolvable, tostring(entityResolvable)))
	end

	self:fire(
		pattern.name .. "Removed",
		self.identifierToInstance[entity],
		setmetatable(self.entities.data[entity][pattern.name], pattern)
	)
	self.entities.data[entity][pattern.name] = nil
end

function Stitch:emplace(patternResolvable: string | table, entityResolvable: Instance | string, data: table)
	local pattern = self._collection:resolveOrError(patternResolvable)

	local entity = entityResolvable

	-- try to resolve identifier from instance (shorthand)
	if typeof(entityResolvable) == "Instance" then
		entity = entityResolvable:GetAttribute(self.instanceUuidAttribute) or self:register(entityResolvable)
	end

	if not entity then
		self:error(
			("tried to emplace %s on invalid entity %s!"):format(pattern.patternName, tostring(entityResolvable))
		)
	end

	data = Util.shallowCopy(data or {})
	self.entities.data[entity][pattern.name] = data

	local newPattern = setmetatable(data, pattern)
	self:fire(pattern.name .. "Created", self.identifierToInstance[entity], newPattern)
	return newPattern
end

function Stitch:get(patternResolvable: string | table, entityResolvable: Instance | string)
	local pattern = self._collection:resolveOrError(patternResolvable)

	local entity = entityResolvable

	if typeof(entityResolvable) == "Instance" then
		entity = entityResolvable:GetAttribute(self.instanceUuidAttribute)
	end

	if not entity then
		return nil
	end

	local data = self.entities.data[entity][pattern.name]

	return data and setmetatable(data, pattern) or nil
end

function Stitch:getOrEmplace(patternResolvable: string | table, entityResolvable: Instance | string, data: table)
	return self:get(patternResolvable, entityResolvable) or self:emplace(patternResolvable, entityResolvable, data)
end

function Stitch:replace(patternResolvable: string | table, entityResolvable: Instance | string, data: table)
	local pattern = self._collection:resolveOrError(patternResolvable)

	local entity = entityResolvable

	-- try to resolve identifier from instance (shorthand)
	if typeof(entityResolvable) == "Instance" then
		entity = entityResolvable:GetAttribute(self.instanceUuidAttribute)
	end

	if not entity then
		self:error(
			("tried to replace %s on invalid entity %s!"):format(pattern.patternName, tostring(entityResolvable))
		)
	end

	if not self.entities.data[entity][pattern.name] then
		self:error(
			("tried to replace non-existant pattern %s on entity %s!"):format(
				pattern.patternName,
				tostring(entityResolvable)
			)
		)
	end

	data = Util.shallowCopy(data)
	self.entities.data[entity][pattern.name] = data
	local newPattern = setmetatable(data, pattern)
	self:fire(pattern.name .. "Updated", self.identifierToInstance[entity], newPattern)
	return newPattern
end

function Stitch:emplaceOrReplace(patternResolvable: string | table, entityResolvable: Instance | string, data: table)
	local pattern = self._collection:resolveOrError(patternResolvable)

	local entity = entityResolvable

	-- try to resolve identifier from instance (shorthand)
	if typeof(entityResolvable) == "Instance" then
		entity = entityResolvable:GetAttribute(self.instanceUuidAttribute) or self:register(entityResolvable)
	end

	if not entity then
		self:error(
			("tried to emplace or replace %s on invalid entity %s!"):format(
				pattern.patternName,
				tostring(entityResolvable)
			)
		)
	end

	data = Util.shallowCopy(data)
	self.entities.data[entity][pattern.name] = data

	local newPattern = setmetatable(data, pattern)
	self:fire(pattern.name .. "Created", self.identifierToInstance[entity], newPattern)
	return newPattern
end

-- Accepts a callback, and sets the data to the returned value from the callback
-- callback takes current data as a parameter
-- **Warning** the passed parameter is *not* a copy of the original data
-- hence, modifying it directly may lead to un-intended side-effects!
function Stitch:patch(
	patternResolvable: string | table,
	entityResolvable: Instance | string,
	callback: (table) -> (table)
)
	local pattern = self._collection:resolveOrError(patternResolvable)

	local entity = entityResolvable

	-- try to resolve identifier from instance (shorthand)
	if typeof(entityResolvable) == "Instance" then
		entity = entityResolvable:GetAttribute(self.instanceUuidAttribute)
	end

	if not entity then
		self:error(("tried to patch %s on invalid entity %s!"):format(pattern.patternName, tostring(entityResolvable)))
	end

	if not self.entities.data[entity][pattern.name] then
		self:error(
			("tried to patch non-existant pattern %s on entity %s!"):format(
				pattern.patternName,
				tostring(entityResolvable)
			)
		)
	end

	local data = callback(self.entities.data[entity][pattern.name])
	if not data then
		self:error(("failed to patch - received return %s (of type %s)!"):format(tostring(data), typeof(data)))
	end

	self.entities.data[entity][pattern.name] = data

	local newComponent = setmetatable(data, pattern)
	self:fire(pattern.name .. "Updated", self.identifierToInstance[entity], newComponent)

	return newComponent
end

function Stitch:error(msg: string, level: int)
	error(("%s %s"):format(self.logPrefix, msg), level)
end

function Stitch:fire(name: string, ...)
	if not self._events or not self._events[name] then
		return
	end

	self._events[name]:fire(...)
end

function Stitch:_getOrCreateEvent(name: string)
	if not self._events then
		self._events = {}
	end

	-- we use bindables here to match roblox event deferral semantics
	if not self._events[name] then
		self._events[name] = Signal.new()
	end

	return self._events[name]
end

function Stitch:GetOnCreatedSignal(patternResolvable: string | table)
	local pattern = self._collection:resolveOrError(patternResolvable)
	return self:_getOrCreateEvent(pattern.name .. "Created")
end
function Stitch:GetOnUpdatedSignal(patternResolvable: string | table)
	local pattern = self._collection:resolveOrError(patternResolvable)
	return self:_getOrCreateEvent(pattern.name .. "Updated")
end
function Stitch:GetOnRemovedSignal(patternResolvable: string | table)
	local pattern = self._collection:resolveOrError(patternResolvable)
	return self:_getOrCreateEvent(pattern.name .. "Removed")
end

return Stitch
