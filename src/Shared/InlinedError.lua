--!nocheck

--[[
	errors without breaking the flow of execution
]]

local bindable = Instance.new("BindableEvent")
bindable.Event:Connect(error)

local function InlinedError(msg, level)
	bindable:Fire(msg, level or 2)
end

return InlinedError
