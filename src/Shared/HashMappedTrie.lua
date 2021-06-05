local MAX_BUCKET_SIZE = 32
local HashMappedTrie = {}

local _COUNT = {}
local _KEYS = {}

local function shallowCopy(tbl)
	local newtbl = {}
	for k, v in pairs(tbl) do
		newtbl[k] = v
	end
	return newtbl
end

function HashMappedTrie.get(tbl: table, key: string)
	local level = 1
	local hash = string.sub(key, level, level)
	while (tbl[_KEYS] and tbl[_KEYS][key] == nil) or tbl[hash] ~= nil do
		tbl = tbl[hash]
		level += 1
		hash = string.sub(key, level, level)
	end
	return (tbl[_KEYS] and tbl[_KEYS][key]) or nil
end

local function insert(tbl: table, key: string, value: any, level: int)
	tbl = shallowCopy(tbl)

	-- key already exists; we just update
	-- TODO: shrink trie when removing keys
	if tbl[_KEYS] and tbl[_KEYS][key] ~= nil then
		tbl[_KEYS] = shallowCopy(tbl[_KEYS])
		tbl[_KEYS][key] = value
		if value == nil then
			tbl[_KEYS][_COUNT] -= 1
		end
		return tbl
	end

	local hash = string.sub(key, level, level)
	if hash ~= "" and tbl[hash] then
		tbl[hash] = insert(tbl[hash], key, value, level + 1)
		return tbl
	end

	tbl[_KEYS] = tbl[_KEYS] or {}
	tbl[_KEYS][key] = value
	tbl[_KEYS][_COUNT] = (tbl[_KEYS][_COUNT] and tbl[_KEYS][_COUNT] + 1) or 1

	-- if we didn't do this, then the trie would never be rebalanced!
	if tbl[_KEYS][_COUNT] > MAX_BUCKET_SIZE then
		-- rebalance current level
		-- TODO: speed up rebalance by doing this mutably
		local newTbl = shallowCopy(tbl)
		newTbl[_KEYS] = nil
		for k, v in pairs(tbl[_KEYS]) do
			if k ~= _COUNT then
				local k_hash = string.sub(k, level, level)
				-- must consider case where key is too short (failsafe!)
				if k_hash == "" then
					newTbl = insert(newTbl, k, v, level)
				else
					newTbl[k_hash] = insert(newTbl[k_hash] or {}, k, v, level + 1)
				end
			end
		end
		return newTbl
	end

	return tbl
end

function HashMappedTrie.set(tbl: table, key: string, value: any)
	return insert(tbl, key, value, 1)
end

return HashMappedTrie
