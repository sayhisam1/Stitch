local Util = {}

function Util.shallowCopy(dict)
	debug.profilebegin("shallowCopy")
	local copied = table.move(dict, 1, #dict, 1, {})
	for k, v in pairs(dict) do
		copied[k] = v
	end
	debug.profileend()
	return copied
end

function Util.deepCopy(dict)
	local copied = table.move(dict, 1, #dict, 1, {})
	for k, v in pairs(dict) do
		if typeof(v) == "table" then
			v = Util.deepCopy(v)
		end
		copied[k] = v
	end
	return copied
end

function Util.removeKey(dict, key)
	local copied = table.move(dict, 1, #dict, 1, {})
	for k, v in pairs(dict) do
		if k ~= key then
			copied[k] = v
		end
	end
	return copied
end

function Util.setKey(dict, key, value)
	local copied = table.move(dict, 1, #dict, 1, {})
	for k, v in pairs(dict) do
		copied[k] = v
	end
	copied[key] = value
	return copied
end

function Util.getValues(dict, sizeEstimate: number?)
	debug.profilebegin("getValues")
	local values = table.create(sizeEstimate or 8)
	for k, v in pairs(dict) do
		table.insert(values, v)
	end
	debug.profileend()
	return values
end

function Util.mergeTable(a: {}, b: {}, noneValue: any?)
	local copied = Util.shallowCopy(a)
	for k, v in pairs(b) do
		if v == noneValue then
			v = nil
		end
		copied[k] = v
	end
	return copied
end

return Util
