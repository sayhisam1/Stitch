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
return Util
