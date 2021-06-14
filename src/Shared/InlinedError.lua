--!nocheck

--[[
	errors without breaking the flow of execution
]]

local bindable = Instance.new("BindableEvent")
bindable.Event:Connect(error)

local function InlinedError(msg)
	bindable:Fire(msg)
end

return InlinedError
