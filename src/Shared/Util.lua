local Util = {}

function Util.shallowCopy(tbl)
	debug.profilebegin("shallowCopy")
	local newtbl = table.move(tbl, 1, #tbl, 1, {})
	for k, v in pairs(tbl) do
		newtbl[k] = v
	end
	debug.profileend()
	return newtbl
end

function Util.getValues(dict, sizeEstimate: int?)
	debug.profilebegin("getValues")
	local values = table.create(sizeEstimate or 8)
	for k, v in pairs(dict) do
		table.insert(values, v)
	end
	debug.profileend()
	return values
end

function Util.mergeTable(a: table, b: table)
	local new_table = Util.shallowCopy(a)
	for k, v in pairs(b) do
		new_table[k] = v
	end
	return new_table
end

return Util
