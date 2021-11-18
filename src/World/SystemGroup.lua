--!strict
local inlinedError = require(script.Parent.Parent.Shared.inlinedError)
local SystemDefinition = require(script.Parent.SystemDefinition)

local SystemGroup = {}
SystemGroup.__index = SystemGroup

-- Represents a group of systems that update according to a given event
-- Update order is determined by the `priority` attribute on each system

function SystemGroup.new(event, world)
	local self = setmetatable({
		systems = {},
		_listener = nil,
		world = world
	}, SystemGroup)

	self._listener = event:connect(function(...)
		self:updateSystems(...)
	end)

	return self
end

function SystemGroup:destroy()
	self._listener:disconnect()
	for i, system in ipairs(self.systems) do
		table.remove(self.systems, i)
		xpcall(system.destroy, inlinedError, system, self.world)
	end
end

function SystemGroup:updateSystems(...)
	for _, system in ipairs(self.systems) do
		debug.profilebegin(("%s update"):format(system.name))
		xpcall(system.update, inlinedError, system, self.world, ...)
		debug.profileend()
	end
end

function SystemGroup:addSystem(systemSpec: {})
	if typeof(systemSpec.name) ~= "string" then
		error("Tried to add a system without a name!")
	end

	if getmetatable(systemSpec) and getmetatable(systemSpec) ~= SystemDefinition then
		error(
			"Failed to add system %s: components should not have a metatable!",
			tostring(systemSpec.name)
		)
	end

	systemSpec = setmetatable(systemSpec, SystemDefinition)

	local priority = systemSpec.priority
	local insertPos = #self.systems + 1

	for i, existing in ipairs(self.systems) do
		if existing.priority > priority then
			insertPos = i
			break
		end
	end

	systemSpec:create(self.world)
	table.insert(self.systems, insertPos, systemSpec)
end

function SystemGroup:removeSystem(system: {})
	for i, existing in ipairs(self.systems) do
		if existing.name == system.name then
			table.remove(self.systems, i)
			xpcall(existing.destroy, inlinedError, existing, self.world)
			return
		end
	end
end

return SystemGroup
