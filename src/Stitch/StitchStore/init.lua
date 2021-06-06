local Rodux = require(script.Parent.Parent.Parent.Rodux)
local Reducers = require(script.Reducers)
local DeferredCallback = require(script.Parent.Parent.Shared.DeferredCallback)
local HashMappedTrie = require(script.Parent.Parent.Shared.HashMappedTrie)

local StitchStore = {}
StitchStore.__index = StitchStore

function StitchStore.new(stitch)
	local self = setmetatable({
		_updateQueue = {},
		_deconstructQueue = {},
	}, StitchStore)

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

	self.heartbeatListener = stitch.Heartbeat:connect(function()
		self:flush()
	end)

	self._store = Rodux.Store.new(reducer, HashMappedTrie.new(math.huge), middlewares)

	self.changed = self._store.changed

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
	self.heartbeatListener:disconnect()
	self._store:destruct()
end

function StitchStore:dispatch(action)
	if action.type == "updateData" then
		table.insert(self._updateQueue, action)
	elseif action.type == "deconstructPattern" then
		table.insert(self._deconstructQueue, action)
	else
		self._store:dispatch(action)
	end
end

function StitchStore:flush()
	if #self._updateQueue > 0 then
		self._store:dispatch({
			type = "batchedUpdateData",
			actions = self._updateQueue,
		})
		table.clear(self._updateQueue)
	end
	for _, action in ipairs(self._deconstructQueue) do
		self._store:dispatch(action)
	end
	table.clear(self._deconstructQueue)
	self._store:flush()
end

function StitchStore:getState()
	return self._store:getState()
end

function StitchStore:lookup(uuid: string)
	return HashMappedTrie.get(self:getState(), uuid)
end

return StitchStore
