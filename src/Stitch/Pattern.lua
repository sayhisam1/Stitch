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
	if value == nil then
		value = self.stitch.None
	end
	self:updateData({
		[attribute_name] = value,
	})
end

function Pattern:updateData(data: table)
	debug.profilebegin("updateData")
	self.stitch._store:dispatch({
		type = "updateData",
		uuid = self.uuid,
		data = data,
	})
	debug.profileend()
end

function Pattern:getAttachedPatterns()
	local state = self.stitch._store:lookup(self.uuid)
	return state["attached"]
end

return Pattern
