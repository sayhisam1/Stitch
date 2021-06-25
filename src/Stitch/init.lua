local DEFAULT_NAMESPACE = "game"

local EntityManager = require(script.EntityManager)
local SystemGroup = require(script.SystemGroup)
local System = require(script.System)
local HotReloader = require(script.HotReloader)

local Stitch = {}
Stitch.__index = Stitch

function Stitch.new(namespace: string)
	namespace = namespace or DEFAULT_NAMESPACE

	local self = setmetatable({
		namespace = namespace,
		entityManager = EntityManager.new(namespace),
		systemGroups = {},
		_hotReloader = HotReloader.new(),
	}, Stitch)

	return self
end

function Stitch:destroy()
	for _, systemGroup in pairs(self.systemGroups) do
		systemGroup:destroy()
	end
	self.entityManager:destroy()
end

function Stitch:addSystem(system: {} | ModuleScript)
	if typeof(system) == "Instance" and system:IsA("ModuleScript") then
		self._hotReloader:listen(system, function(value)
			self:addSystem(value)
		end, function(value)
			self:removeSystem(value)
		end)
		return
	end

	local updateEvent = system.updateEvent or System.updateEvent

	if not self.systemGroups[updateEvent] then
		self.systemGroups[updateEvent] = SystemGroup.new(updateEvent)
	end

	self.systemGroups[updateEvent]:addSystem(system, self)
end

function Stitch:removeSystem(system: {} | ModuleScript)
	if typeof(system) == "ModuleScript" then
		system = require(system)
	end

	local updateEvent = system.updateEvent or System.updateEvent
	if not self.systemGroups[updateEvent] then
		return
	end
	self.systemGroups[updateEvent]:removeSystem(system)
end

return Stitch
