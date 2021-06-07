local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local InstanceRegistry = {}
InstanceRegistry.__index = InstanceRegistry

function InstanceRegistry.new(stitch)
	local self = setmetatable({
		instanceUuidTag = ("Stitch_%s_UUID_Tag"):format(stitch.namespace),
		instanceUuidAttribute = ("Stitch_%s_UUID"):format(stitch.namespace),
		stitch = stitch,
		_listeners = {},
	}, InstanceRegistry)

	self.uuidToInstance = {}

	return self
end

function InstanceRegistry:destroy()
	-- Remove all attributes and tags
	for _, instance in pairs(CollectionService:GetTagged(self.instanceUuidTag)) do
		instance:SetAttribute(self.instanceUuidAttribute, nil)
		CollectionService:RemoveTag(instance, self.instanceUuidTag)
	end
end

function InstanceRegistry:isRegistered(instance: Instance)
	local uuid = self:getInstanceUuid(instance)
	return (uuid and self.uuidToInstance[uuid] and true) or false
end
function InstanceRegistry:getInstanceUuid(instance: Instance)
	return instance:GetAttribute(self.instanceUuidAttribute)
end

function InstanceRegistry:registerInstance(instance: Instance)
	local uuid = instance:GetAttribute(self.instanceUuidAttribute)
	-- if already registered, we can bail
	if self.uuidToInstance[uuid] == instance then
		return uuid
	end
	if not uuid then
		if RunService:IsServer() then
			uuid = HttpService:GenerateGUID(false)
			instance:SetAttribute(self.instanceUuidAttribute, uuid)
		else
			-- on clients, we let server be authoritative
			local event = instance:GetAttributeChangedSignal(self.instanceUuidAttribute)
			event:Wait()
			uuid = instance:GetAttribute(self.instanceUuidAttribute)
		end
	end

	if self.uuidToInstance[uuid] then
		self.stitch:error(("tried to register instance %s with duplicate id %s (already have %s)!"):format(
			instance,
			uuid,
			self.uuidToInstance[uuid]
		))
	end

	self.uuidToInstance[uuid] = instance
	CollectionService:AddTag(instance, self.instanceUuidTag)
	return uuid
end

function InstanceRegistry:unregisterInstance(instance: Instance)
	local uuid = instance:GetAttribute(self.instanceUuidAttribute)
	self.uuidToInstance[uuid] = nil
end

function InstanceRegistry:lookup(uuid: string)
	return self.uuidToInstance[uuid]
end
function InstanceRegistry:fire(eventName, ...)
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

function InstanceRegistry:on(eventName, callback)
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

return InstanceRegistry
