local t = require(script.Parent.Parent.Parent.t)
local Types = require(script.Parent.Types)
local Pattern = require(script.Parent.Pattern)
local Util = require(script.Parent.Parent.Shared.Util)

local PatternCollection = {}
PatternCollection.__index = PatternCollection

function PatternCollection.new(stitch)
	local self = setmetatable({
		registeredPatterns = {},
	}, PatternCollection)
	self.stitch = stitch

	return self
end

function PatternCollection:destroy()
end

function PatternCollection:registerPattern(patternDefinition)
	t.strict(Types.PatternDefinition)(patternDefinition)
	if getmetatable(patternDefinition) then
		self.stitch:error(
			"failed to register pattern %s: patterns should not have a metatable!",
			tostring(patternDefinition.name)
		)
	end

	patternDefinition = Util.shallowCopy(patternDefinition)
	local patternName = patternDefinition.name

	if self.registeredPatterns[patternName] then
		self.stitch:error(("tried to register duplicate Pattern %s!"):format(patternName))
	end

	patternDefinition.__index = patternDefinition
	patternDefinition.stitch = self.stitch

	setmetatable(patternDefinition, Pattern)

	self.registeredPatterns[patternName] = patternDefinition

	return patternDefinition
end

function PatternCollection:unregisterPattern(patternResolvable)
	local resolvedPattern = self:resolveOrErrorPattern(patternResolvable)
	self.registeredPatterns[resolvedPattern.name] = nil
end

function PatternCollection:resolvePattern(patternResolvable)
	local patternResolvableType = typeof(patternResolvable)
	if not patternResolvableType == "string" and not patternResolvableType == "table" then
		self.stitch:error(("invalid PatternResolvable %s of type %s"):format(
			tostring(patternResolvable),
			typeof(patternResolvable)
		))
	end

	local patternName = patternResolvable
	if patternResolvableType == "table" then
		patternName = patternResolvable.name
	end

	return self.registeredPatterns[patternName]
end

function PatternCollection:resolveOrErrorPattern(patternResolvable)
	return self:resolvePattern(patternResolvable)
		or self.stitch:error(("failed to resolve Pattern %s!"):format(tostring(patternResolvable)))
end

function PatternCollection:getPatternName(patternResolvable)
	if typeof(patternResolvable) == "string" then
		return patternResolvable
	end
	return patternResolvable.name
end

function PatternCollection:getAll()
	return self.registeredPatterns
end

return PatternCollection
