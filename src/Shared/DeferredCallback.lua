local DeferredCallback = {}

DeferredCallback.__index = DeferredCallback
function DeferredCallback.new(event)
	local deferredCallback = setmetatable({}, DeferredCallback)
	local deferralList = nil
	local connection

	function deferredCallback:defer(callback)
		if deferralList == nil then
			deferralList = {}

			connection = event:connect(function()
				connection:disconnect()
				connection = nil

				for _, cb in ipairs(deferralList) do
					local ok, msg = pcall(cb)
					if not ok then
						local err = Instance.new("BindableEvent")
						local errConnection = err.Event:Connect(error)
						err:Fire(msg)
						errConnection:Disconnect()
					end
				end

				deferralList = nil
			end)
		end
		table.insert(deferralList, callback)
	end

	function deferredCallback:Destroy()
		if connection then
			connection:disconnect()
		end
		deferralList = nil
	end

	return deferredCallback
end

return DeferredCallback
