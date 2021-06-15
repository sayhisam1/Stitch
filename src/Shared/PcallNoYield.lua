--!nocheck

--[[
	Calls a function and throws an error if it attempts to yield.

	Pass any number of arguments to the function after the callback.

	This function supports multiple return; all results returned from the
	given function will be returned.

	Shamelessly adapted from Rodux's source code
]]

local function resultHandler(co, ok, ...)
	local returns = { ... }
	if coroutine.status(co) ~= "dead" then
		ok = false
		returns = {
			"Attempted yield in callback where it is prohibited! (Check for waits or yielding Roblox function calls?)",
		}
	end

	return ok, unpack(returns)
end

local function PcallNoYield(callback, ...)
	local co = coroutine.create(callback)

	return resultHandler(co, coroutine.resume(co, ...))
end

return PcallNoYield
