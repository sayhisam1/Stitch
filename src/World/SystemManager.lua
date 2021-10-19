local HotReloader = require(script.Parent.HotReloader)
local SystemDefinition = require(script.Parent.SystemDefinition)
local SystemGroup = require(script.Parent.SystemGroup)

local SystemManager = {}
SystemManager.__index = SystemManager

function SystemManager.new(world)
    local self = setmetatable({}, SystemManager)
    self.systemGroups = {}
    self.world = world
    self._hotReloader = HotReloader.new()

    return self
end

function SystemManager:destroy()
    self._hotReloader:destroy()
    for _, group in pairs(self.systemGroups) do
        group:destroy()
    end
end

function SystemManager:addSystem(systemDefinition: {} | ModuleScript)
	if typeof(systemDefinition) == "Instance" and systemDefinition:IsA("ModuleScript") then
		self._hotReloader:listen(systemDefinition, function(module: ModuleScript)
			systemDefinition = require(module)
			if not systemDefinition.name then
				systemDefinition.name = module.Name
			end
			self:addSystem(systemDefinition)
		end, function(module:ModuleScript)
			systemDefinition = require(module)
			if not systemDefinition.name then
				systemDefinition.name = module.Name
			end
			self:removeSystem(systemDefinition)
		end)
		return
	end

	local updateEvent = systemDefinition.updateEvent or SystemDefinition.updateEvent

	if not self.systemGroups[updateEvent] then
		self.systemGroups[updateEvent] = SystemGroup.new(updateEvent, self.world)
	end

	self.systemGroups[updateEvent]:addSystem(systemDefinition)
end

function SystemManager:removeSystem(system: {} | ModuleScript)
	if typeof(system) == "Instance" and system:IsA("ModuleScript") then
		local moduleName = system.Name
		system = require(system)
		if not system.name then
			system.name = moduleName
		end
	end

	local updateEvent = system.updateEvent or SystemDefinition.updateEvent
	if not self.systemGroups[updateEvent] then
		return
	end
	self.systemGroups[updateEvent]:removeSystem(system)
end

return SystemManager