local Util = {}

function Util.shallowCopy(tbl)
	debug.profilebegin("shallowCopy")
	local newtbl = table.move(tbl, 1, #tbl, 1, {})
	for k, v in pairs(tbl) do
		newtbl[k] = v
	end
	setmetatable(newtbl, getmetatable(tbl))
	debug.profileend()
	return newtbl
end

return Util
