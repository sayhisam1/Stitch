-- Determines which events to fire after the store has been updated

local Reconciler = {}
Reconciler.__index = Reconciler

function Reconciler.new(stitch)
	local self = setmetatable({
		stitch = stitch,
	}, Reconciler)
	return self
end

function Reconciler:getDiff(oldState, newState)
end

function Reconciler:extractEvents(oldState, newState)
end
