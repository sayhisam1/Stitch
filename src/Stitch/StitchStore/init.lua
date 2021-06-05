local Rodux = require(script.Parent.Parent.Parent.Rodux)
local Reducers = require(script.Reducers)
local DeferredCallback = require(script.Parent.Parent.Shared.DeferredCallback)
local HashMappedTrie = require(script.Parent.Parent.Shared.HashMappedTrie)

local StitchStore = {}
StitchStore.__index = StitchStore

function StitchStore.new(stitch)
	local self = setmetatable({}, StitchStore)

	local reducers = self:initializeReducers(Reducers, stitch)
	local reducer = function(state, action)
		state = state or {}
		if reducers[action.type] then
			state = reducers[action.type](state, action)
		end
		return state
	end

	local middlewares = {}
	if stitch.debug then
		table.insert(middlewares, Rodux.loggerMiddleware)
	end

	self._store = Rodux.Store.new(reducer, {}, middlewares)
	self.deferredStoreChanged = DeferredCallback.new(self._store.changed)

	return self
end

function StitchStore:initializeReducers(reducerTable: table, stitch: table)
	local reducers = {}

	for reducerName, reducerCreator in pairs(reducerTable) do
		reducers[reducerName] = reducerCreator(stitch)
	end

	return reducers
end

function StitchStore:destroy()
	self._store:destruct()
end

function StitchStore:dispatch(...)
	return self._store:dispatch(...)
end

function StitchStore:getState()
	return self._store:getState()
end

function StitchStore:deferUntilChanged(callback)
	self.deferredStoreChanged:defer(callback)
end

function StitchStore:lookup(uuid: string)
	return HashMappedTrie.get(self:getState(), uuid)
end

return StitchStore
