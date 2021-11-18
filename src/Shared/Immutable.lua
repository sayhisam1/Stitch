local Immutable = {}

local function shallowCopy(dict)
	local copied = table.create(#dict)
	for k, v in pairs(dict) do
		copied[k] = v
	end
	return copied
end

function Immutable.shallowCopy(dict)
	return table.freeze(shallowCopy(dict))
end

local function deepCopy(dict)
	local copied = shallowCopy(dict)
	for k, v in pairs(dict) do
		if typeof(v) == "table" then
			copied[k] = deepCopy(v)
		end
	end
	return copied
end

function Immutable.deepCopy(dict)
	return table.freeze(deepCopy(dict))
end

function Immutable.removeKey(dict, key)
	local copied = shallowCopy(dict)
	copied[key] = nil
	return table.freeze(copied)
end

function Immutable.setKey(dict, key, value)
	local copied = shallowCopy(dict)
	copied[key] = value
	return table.freeze(copied)
end

function Immutable.mergeTable(a: {}, b: {}, noneValue: any?)
	local copied = shallowCopy(a)
	for k, v in pairs(b) do
		if v == noneValue then
			v = nil
		end
		copied[k] = v
	end
	return table.freeze(copied)
end

function Immutable.count(dict)
	local count = 0
	for _ in pairs(dict) do
		count += 1
	end
	return count
end

return Immutable
