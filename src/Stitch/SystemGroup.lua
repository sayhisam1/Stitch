--!strict
local inlinedError = require(script.Parent.Parent.Shared.inlinedError)

local SystemGroup = {}
SystemGroup.__index = SystemGroup

-- Represents a group of systems that update according to a given event
-- Update order is determined by the `priority` attribute on each system

function SystemGroup.new(event)
	local self = setmetatable({
		systems = {},
		_listener = nil,
	}, SystemGroup)

	self._listener = event:connect(function()
		self:updateSystems()
	end)

	return self
end

function SystemGroup:destroy()
	self._listener:disconnect()
	for i, system in ipairs(self.systems) do
		xpcall(system.destroy, inlinedError, system)
		table.remove(self.systems, i)
	end
end

function SystemGroup:updateSystems()
	for _, system in ipairs(self.systems) do
		xpcall(system.update, inlinedError, system)
	end
end

function SystemGroup:addSystem(system: {})
	local priority = system.priority
	local insertPos = #self.systems + 1

	for i, existing in ipairs(self.systems) do
		if existing.priority > priority then
			insertPos = i
			break
		end
	end

	table.insert(self.systems, insertPos, system)
	xpcall(system.create, inlinedError, system)
end

function SystemGroup:removeSystem(system: {})
	for i, existing in ipairs(self.systems) do
		if existing.name == system.name then
			xpcall(system.destroy, inlinedError, system)
			table.remove(self.systems, i)
			return
		end
	end
end

return SystemGroup
