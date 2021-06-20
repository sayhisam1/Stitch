--!strict
local HttpService = game:GetService("HttpService")

local DEFAULT_NAMESPACE = "game"

local Symbol = require(script.Parent.Shared.Symbol)
local PatternCollection = require(script.PatternCollection)

local Stitch = {}
Stitch.__index = Stitch

function Stitch.new(namespace: string)
	namespace = namespace or DEFAULT_NAMESPACE

	local self = setmetatable({
		namespace = namespace,
		logPrefix = ("[Stitch:%s]"):format(namespace),
		instanceUuidTag = ("Stitch_%s_UUID_Tag"):format(namespace),
		instanceUuidAttribute = ("Stitch_%s_UUID"):format(namespace),
	}, Stitch)

	self._collection = PatternCollection.new(self)
	self.entities = {
		data = {},
	}
	return self
end

function Stitch:destroy() end

function Stitch:addPattern(patternDefinition: table | ModuleScript)
	self._collection:register(patternDefinition)
end

-- Returns an entity given a reference
function Stitch:register(reference: Instance)
	local uuid = reference:GetAttribute(self.instanceUuidAttribute)

	if not uuid then
		uuid = HttpService:GenerateGUID(false)
	end

	if self.entities.data[uuid] ~= nil then
		self:error(("tried to register reference with uuid %s, but already registered!"):format(uuid))
	end

	self.entities.data[uuid] = {}

	return uuid
end

function Stitch:emplace(patternResolvable: string | table, entity: Instance | string, data: table)
	local pattern = self._collection:resolveOrError(patternResolvable)
end

function Stitch:get(patternResolvable: string | table, entity: Instance | string) end

function Stitch:error(msg: string, level: int)
	error(("%s %s"):format(self.logPrefix, msg), level)
end
return Stitch
