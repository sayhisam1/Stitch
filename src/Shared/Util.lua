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

function Util.shallowCopyOnce(table: table, copied: table)
	debug.profilebegin("shallowCopyOnce")
	if copied[table] then
		return table
	end
	local ret = Util.shallowCopy(table)
	copied[ret] = true
	debug.profileend()
	return ret
end

function Util.mergeTable(a: table, b: table)
	local new_table = Util.shallowCopy(a)
	for k, v in pairs(b) do
		new_table[k] = v
	end
	return new_table
end
return Util
