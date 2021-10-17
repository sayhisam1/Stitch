--!strict
local Util = require(script.Parent.Parent.Shared.Util)

local ComponentDefinition = {}
ComponentDefinition.__index = ComponentDefinition
ComponentDefinition.defaults = {}
ComponentDefinition.validators = {}

function ComponentDefinition:createFromData(data: {}?): {}
	data = Util.mergeTable(Util.deepCopy(self.defaults), data or {})

	self:validateOrErrorData(data)

	return data
end

function ComponentDefinition:setFromData(data: {}): {}
	data = Util.shallowCopy(data)

	self:validateOrErrorData(data)

	return data
end

function ComponentDefinition:updateFromData(old: {}, new: {}): {}
	local data = Util.mergeTable(old, new)

	self:validateOrErrorData(data)

	return data
end

function ComponentDefinition:validateOrErrorData(data: {})
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

return ComponentDefinition
