local _COUNT = {}
local _KEYS = {}
local DEFAULT_BUCKET_SIZE = 32
local HashMappedTrie = {}
HashMappedTrie.__index = HashMappedTrie
HashMappedTrie.None = {}

local function shallowCopy(tbl)
	local newtbl = table.move(tbl, 1, #tbl, 1, {})
	debug.profilebegin("HashMappedTrie:shallowCopy")
	for k, v in pairs(tbl) do
		newtbl[k] = v
	end
	debug.profileend()
	return newtbl
end

function HashMappedTrie.new(bucketSize: int)
	return {
		data = {},
	}
end

function HashMappedTrie:getHash(key: string, depth: int)
	return (string.byte(key, depth) % self.bucketSize) + 1
end

function HashMappedTrie:get(key: string)
	debug.profilebegin("HashMappedTrie:get")
	local returnValue = self.data[key]
	debug.profileend()
	return returnValue
end

local function shallowCopyOnce(table: table, copied: table)
	if copied[table] then
		return table
	end
	local ret = shallowCopy(table)
	copied[ret] = true
	return ret
end

function HashMappedTrie:set(key: string, value: any, copied: table)
	debug.profilebegin("HashMappedTrie:set")
	local newMap = HashMappedTrie.new(self.bucketSize)
	newMap.data = shallowCopyOnce(self.data, copied)
	newMap.data[key] = value
	debug.profileend()
	return newMap
end

function HashMappedTrie:getAllKeyValues(map: table)
	map = map or {}

	local function populate(data)
		if data[_COUNT] ~= nil then
			for k, v in pairs(data) do
				if k ~= _COUNT then
					map[k] = v
				end
			end
		else
			for i = 1, self.bucketSize do
				populate(data[i])
			end
		end
	end

	populate(self.data)
	return map
end

return HashMappedTrie
