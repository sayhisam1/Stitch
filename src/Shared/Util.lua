local Util = {}

function Util.shallowCopy(tbl)
	local newtbl = {}
	for k, v in pairs(tbl) do
		newtbl[k] = v
	end
	return newtbl
end
return Util
