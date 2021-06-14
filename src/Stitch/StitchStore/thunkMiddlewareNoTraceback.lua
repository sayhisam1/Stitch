--[[
	A middleware that allows for functions to be dispatched.
	Functions will receive a single argument, the store itself.
	This middleware consumes the function; middleware further down the chain
	will not receive it.
	Removes the addition of the traceback into the error message
]]

local function thunkMiddlewareNoTraceback(nextDispatch, store)
	return function(action)
		if typeof(action) == "function" then
			local status, msg = pcall(action, store)
			if not status then
				error(msg, 0)
			end
			return msg
		end

		return nextDispatch(action)
	end
end

return thunkMiddlewareNoTraceback
