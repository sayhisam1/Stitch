function callbackMiddleware(nextDispatch, store)
	return function(action)
		local result = nextDispatch(action)
		if action.callback then
			action.callback()
		end
		return result
	end
end

return callbackMiddleware
