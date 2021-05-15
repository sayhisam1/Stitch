local DeferredCallback = {}

DeferredCallback.__index = DeferredCallback
function DeferredCallback.new(event)
	local deferredCallback = setmetatable({}, DeferredCallback)
	local deferralList = nil

	function deferredCallback:defer(callback)
		if deferralList == nil then
			deferralList = {}

			local connection
			connection = event:Connect(function()
				connection:Disconnect()

				for _, cb in ipairs(deferralList) do
					cb()
				end

				deferralList = nil
			end)
		end
		table.insert(deferralList, callback)
	end

	return deferredCallback
end

return DeferredCallback
