local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local InstanceRegistry = {}
InstanceRegistry.__index = InstanceRegistry

function InstanceRegistry.new(stitch)
	local self = setmetatable({
		instanceUuidTag = ("Stitch_%s_UUID_Tag"):format(stitch.namespace),
		instanceUuidAttribute = ("Stitch_%s_UUID"):format(stitch.namespace),
		stitch = stitch,
	}, InstanceRegistry)

	self.uuidToInstance = setmetatable({}, {
		__mode = "v",
	})

	self:setupInstanceListeners()
	for _, instance in ipairs(CollectionService:GetTagged(self.instanceUuidTag)) do
		self:registerInstance(instance)
	end

	return self
end

function InstanceRegistry:destroy()
	self._instanceAdded:disconnect()
	self._instanceRemoved:disconnect()

	-- Remove all attributes and tags
	for _, instance in pairs(CollectionService:GetTagged(self.instanceUuidTag)) do
		instance:SetAttribute(self.instanceUuidAttribute, nil)
		CollectionService:RemoveTag(instance, self.instanceUuidTag)
	end
end

function InstanceRegistry:getInstanceUuid(instance: Instance)
	return instance:GetAttribute(self.instanceUuidAttribute)
end

function InstanceRegistry:registerInstance(instance: Instance)
	local uuid = instance:GetAttribute(self.instanceUuidAttribute)
	if not uuid then
		uuid = HttpService:GenerateGUID(false)
		instance:SetAttribute(self.instanceUuidAttribute, uuid)
	end

	if self.uuidToInstance[uuid] then
		self.stitch:error(("tried to register instance %s with duplicate id %s (already have %s)!"):format(
			instance,
			uuid,
			self.uuidToInstance[uuid]
		))
	end

	self.uuidToInstance[uuid] = instance
	self.stitch:fire("instanceRegistered", instance)

	return uuid
end

function InstanceRegistry:unregisterInstance(instance: Instance)
	local uuid = instance:GetAttribute(self.instanceUuidAttribute)
	self.uuidToInstance[uuid] = nil
	self.stitch:fire("instanceUnregistered", instance)
end

function InstanceRegistry:setupInstanceListeners()
	local instanceAdded = CollectionService:GetInstanceAddedSignal(self.instanceUuidTag)
	self._instanceAdded = instanceAdded:Connect(function(instance: Instance)
		self:registerInstance(instance)
	end)

	local instanceRemoved = CollectionService:GetInstanceRemovedSignal(self.instanceUuidTag)
	self._instanceRemoved = instanceRemoved:Connect(function(instance: Instance)
		self:unregisterInstance(instance)
	end)
end

function InstanceRegistry:lookup(uuid: string)
	return self.uuidToInstance[uuid]
end

return InstanceRegistry
