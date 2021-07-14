--!nocheck

--[[
	errors without breaking the flow of execution
]]

local bindable = Instance.new("BindableEvent")
bindable.Event:Connect(error)

local function inlinedError(msg, level)
	bindable:Fire(debug.traceback(msg, 2), level or 2)
end

return inlinedError
