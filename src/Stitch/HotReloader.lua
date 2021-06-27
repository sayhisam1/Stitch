local RunService = game:GetService("RunService")

-- Determines which events to fire after the store has been updated

local HotReloader = {}
HotReloader.__index = HotReloader

function HotReloader.new()
	local self = setmetatable({
		_listeners = {},
		_clonedModules = {},
	}, HotReloader)
	return self
end

function HotReloader:destroy()
	self._listeners = nil
	for _, cloned in pairs(self._clonedModules) do
		cloned:Destroy()
	end
	self._clonedModules = nil
end

function HotReloader:listen(module: ModuleScript, callback: callback, cleanup: callback)
	local lastUpdated = module
	if RunService:IsStudio() then
		local moduleChanged = module.Changed:connect(function()
			cleanup(require(lastUpdated))
			if self._clonedModules[module] then
				self._clonedModules[module]:Destroy()
			end
			local cloned = module:Clone()
			cloned.Name = cloned.Name .. "HotReloaded"
			cloned.Parent = module.Parent
			self._clonedModules[module] = cloned
			lastUpdated = cloned
			local loaded = require(cloned)
			callback(loaded, module)
			warn(("HotReloaded %s!"):format(module:GetFullName()))
		end)
		table.insert(self._listeners, moduleChanged)
	end
	callback(require(module))
end

return HotReloader
