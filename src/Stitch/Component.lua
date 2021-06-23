--!strict
local Util = require(script.Parent.Parent.Shared.Util)

local Component = {}
Component.__index = Component

Component.defaults = {}
Component.validators = {}

function Component:createFromData(data: table?): table
	data = Util.mergeTable(self.defaults, data or {})

	self:validateOrErrorData(data)

	return data
end

function Component:setFromData(data: table): table
	data = Util.shallowCopy(data)

	self:validateOrErrorData(data)

	return data
end

function Component:updateFromData(old: table, new: table): table
	local data = Util.mergeTable(old, new)

	self:validateOrErrorData(data)

	return data
end

function Component:validateOrErrorData(data: table)
	for key, validator in pairs(self.validators) do
		if not validator(data[key]) then
			error("Failed to create component %s - invalid value %s (of type %s) for key %s!"):format(
				self.name,
				tostring(data[key]),
				typeof(data[key]),
				key
			)
		end
	end
end

return Component
