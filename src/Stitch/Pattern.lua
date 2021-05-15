local Pattern = {}
Pattern.__index = Pattern

function Pattern:getRef()
	return self.ref or self.stitch._collection:resolveByUUID(self.refUUID)
end

function Pattern:GetAttribute(attribute_name: string)
	return self.data[attribute_name]
end

function Pattern:SetAttribute(attribute_name: string, value: any)
	self.data[attribute_name] = value
	if self.isInstanceRef then
		local ref = self:getRef()
		if ref then
			ref:SetAttribute(attribute_name, value)
		end
	end
end
-- Aliases SetAttribute
function Pattern:set(attribute_name: string, value: any)
	return self:SetAttribute(attribute_name, value)
end

-- Aliases GetAttribute
function Pattern:get(attribute_name: string)
	return Pattern:GetAttribute(attribute_name)
end

return Pattern
