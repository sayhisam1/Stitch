local _COUNT = {}
local _KEYS = {}
local DEFAULT_BUCKET_SIZE = 8
local HashMappedTrie = {}
HashMappedTrie.__index = HashMappedTrie

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
	local self = setmetatable({
		bucketSize = bucketSize or DEFAULT_BUCKET_SIZE,
		data = {
			[_COUNT] = 0,
		},
	}, HashMappedTrie)
	return self
end

function HashMappedTrie:getHash(key: string, depth: int)
	return (string.byte(key, depth) % self.bucketSize) + 1
end

function HashMappedTrie:get(key: string)
	debug.profilebegin("HashMappedTrie:get")
	local depth = 1
	local hash = HashMappedTrie.getHash(self, key, depth)
	local data = self.data
	while not data[key] and data[hash] do
		data = data[hash]
		depth += 1
		hash = HashMappedTrie.getHash(self, key, depth)
	end
	local returnValue = data[key]
	debug.profileend()
	return returnValue
end

function HashMappedTrie:set(key: string, value: any)
	debug.profilebegin("HashMappedTrie:set")
	local newMap = HashMappedTrie.new(self.bucketSize)
	newMap.data = shallowCopy(self.data)

	local data = newMap.data
	local depth = 1
	local hash = HashMappedTrie.getHash(self, key, depth)

	while not data[key] and data[hash] do
		data[hash] = shallowCopy(data[hash])
		data = data[hash]
		depth += 1
		hash = HashMappedTrie.getHash(self, key, depth)
	end

	-- key already exists - just need to update value
	if data[key] then
		data[key] = value
		if value == nil then
			data[_COUNT] -= 1
		end
		debug.profileend()
		return newMap
	end

	-- must rebalance in this case
	if data[_COUNT] + 1 > newMap.bucketSize then
		local newData = table.create(newMap.bucketSize)
		for i = 1, newMap.bucketSize do
			newData[i] = {
				[_COUNT] = 0,
			}
		end
		for k, v in pairs(data) do
			if k ~= _COUNT then
				local k_hash = HashMappedTrie.getHash(newMap, k, depth)
				newData[k_hash][k] = v
				newData[k_hash][_COUNT] += 1
			end
		end
		for k, _ in pairs(data) do
			data[k] = nil
		end
		for k, v in pairs(newData) do
			data[k] = v
		end
		data = data[hash]
	end

	data[key] = value
	data[_COUNT] += 1

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
