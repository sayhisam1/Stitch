local Util = require(script.Parent.Parent.Shared.Util)

local Pattern = {}
Pattern.__index = Pattern

function Pattern:getRef()
	return self.stitch:lookupInstanceByUuid(self.refuuid) or self.stitch:lookupPatternByUuid(self.refuuid)
end

function Pattern:getData()
	local state = self.stitch._store:lookup(self.uuid)
	return state["data"]
end

function Pattern:get(attribute_name: string)
	return self:getData()[attribute_name]
end

function Pattern:set(attribute_name: string, value: any)
	local data = self:getData()
	local newData = Util.shallowCopy(data)
	if value == self.stitch.None then
		value = nil
	end
	newData[attribute_name] = value
	self:setData(newData)
end

function Pattern:setData(data: table)
	self.stitch._store:dispatch({
		type = "updateData",
		uuid = self.uuid,
		data = data,
	})
end

function Pattern:getAttachedPatterns()
	return self["attached"]
end

return Pattern
