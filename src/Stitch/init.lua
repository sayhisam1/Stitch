local DEFAULT_NAMESPACE = "game"

local EntityManager = require(script.EntityManager)

local Stitch = {}
Stitch.__index = Stitch

function Stitch.new(namespace: string)
	namespace = namespace or DEFAULT_NAMESPACE

	local self = setmetatable({
		namespace = namespace,
		EntityManager = EntityManager.new(namespace),
	}, Stitch)

	return self
end

function Stitch:destroy()
	self.EntityManager:destroy()
end

return Stitch
