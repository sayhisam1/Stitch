local DeferredCallback = {}

DeferredCallback.__index = DeferredCallback
function DeferredCallback.new(event)
	local deferredCallback = setmetatable({}, DeferredCallback)
	local deferralList = nil
	local connection

	function deferredCallback:defer(callback)
		if deferralList == nil then
			deferralList = {}

			connection = event:Connect(function()
				connection:Disconnect()
				connection = nil
				for _, cb in ipairs(deferralList) do
					cb()
				end

				deferralList = nil
			end)
		end
		table.insert(deferralList, callback)
	end

	function deferredCallback:Destroy()
		if connection then
			connection:Disconnect()
		end
		deferralList = nil
	end

	return deferredCallback
end

return DeferredCallback
