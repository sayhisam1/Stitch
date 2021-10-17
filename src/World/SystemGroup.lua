--!strict
local inlinedError = require(script.Parent.Parent.Shared.inlinedError)
local Util = require(script.Parent.Parent.Shared.Util)
local System = require(script.Parent.System)

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
		table.remove(self.systems, i)
		xpcall(system.destroy, inlinedError, system)
	end
end

function SystemGroup:updateSystems()
	for _, system in ipairs(self.systems) do
		debug.profilebegin(("%s update"):format(system.name))
		xpcall(system.update, inlinedError, system)
		debug.profileend()
	end
end

function SystemGroup:addSystem(system: {}, stitch: {}?)
	if typeof(system.name) ~= "string" then
		error("Tried to add a system without a name!")
	end
	system = setmetatable(Util.shallowCopy(system), System)
	-- inject stitch reference for convenience
	system.stitch = stitch

	local priority = system.priority
	local insertPos = #self.systems + 1

	for i, existing in ipairs(self.systems) do
		if existing.priority > priority then
			insertPos = i
			break
		end
	end

	system:create()
	table.insert(self.systems, insertPos, system)
end

function SystemGroup:removeSystem(system: {})
	for i, existing in ipairs(self.systems) do
		if existing.name == system.name then
			table.remove(self.systems, i)
			xpcall(existing.destroy, inlinedError, existing)
			return
		end
	end
end

return SystemGroup