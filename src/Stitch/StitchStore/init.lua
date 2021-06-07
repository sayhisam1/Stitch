local Rodux = require(script.Parent.Parent.Parent.Rodux)
local Reducers = require(script.Reducers)
local HashMappedTrie = require(script.Parent.Parent.Shared.HashMappedTrie)

local StitchStore = {}
StitchStore.__index = StitchStore

function StitchStore.new(stitch)
	local self = setmetatable({
		_actionQueue = {},
		_listeners = {},
	}, StitchStore)

	local reducers = self:initializeReducers(Reducers, stitch)
	local reducer = function(state, action)
		state = state or {}
		if reducers[action.type] then
			state = reducers[action.type](state, action)
		end
		return state
	end

	local middlewares = {
		Rodux.thunkMiddleware,
	}

	if stitch.debug then
		table.insert(middlewares, Rodux.loggerMiddleware)
	end

	self.heartbeatListener = stitch.Heartbeat:connect(function()
		self:flush()
	end)

	self._store = Rodux.Store.new(reducer, HashMappedTrie.new(math.huge), middlewares)

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
	table.insert(self._actionQueue, action)
end

function StitchStore:expandDeconstructAction(action: table, successfulActions: table)
	local function deconstruct(uuid, tbl: table)
		local pattern = self:lookup(uuid)
		for patternName, attached_uuid in pairs(pattern.attached) do
			if attached_uuid ~= uuid then
				deconstruct(attached_uuid, tbl)
			end
		end
		table.insert(tbl, {
			type = "deconstructPattern",
			uuid = uuid,
		})
		return tbl
	end

	local actions = deconstruct(action.uuid, {})
	return function(store)
		local copied = {}
		for _, deconstructAction in ipairs(actions) do
			deconstructAction.copied = copied
			store:dispatch(deconstructAction)
		end
		for _, deconstructAction in ipairs(actions) do
			table.insert(successfulActions, deconstructAction)
		end
	end
end
function StitchStore:flush()
	local successfulActions = table.create(#self._actionQueue)
	local function atomicThunk(store)
		debug.profilebegin("StitchStoreFlush")
		local copied = {}
		for _, action in ipairs(self._actionQueue) do
			action.copied = copied
			if action.type == "deconstructPattern" then
				action = self:expandDeconstructAction(action, successfulActions)
			end
			local success, msg = pcall(store.dispatch, store, action)
			if success then
				if action.type == "deconstructPattern" then
					copied = copied
				else
					table.insert(successfulActions, action)
				end
			end
		end
		debug.profileend()
	end
	self._store:dispatch(atomicThunk)
	table.clear(self._actionQueue)
	for _, action in ipairs(successfulActions) do
		if action.type == "constructPattern" then
			self:fire("patternConstructed", action.uuid)
		elseif action.type == "updateData" then
			self:fire("patternUpdated", action.uuid)
		elseif action.type == "deconstructPattern" then
			self:fire("patternDeconstructed", action.uuid)
		end
	end
	self._store:flush()
end

function StitchStore:getState()
	return self._store:getState()
end

function StitchStore:lookup(uuid: string)
	return HashMappedTrie.get(self:getState(), uuid)
end

function StitchStore:fire(eventName, ...)
	if not self._listeners[eventName] then
		return -- Do nothing if no listeners registered
	end

	for _, callback in ipairs(self._listeners[eventName]) do
		local success, errorValue = coroutine.resume(coroutine.create(callback), ...)

		if not success then
			warn(("Event listener for %s encountered an error: %s"):format(tostring(eventName), tostring(errorValue)))
		end
	end
end

function StitchStore:on(eventName, callback)
	self._listeners[eventName] = self._listeners[eventName] or {}
	table.insert(self._listeners[eventName], callback)

	return function()
		for i, listCallback in ipairs(self._listeners[eventName]) do
			if listCallback == callback then
				table.remove(self._listeners[eventName], i)
				break
			end
		end
	end
end

function StitchStore:getAll()
	return self._store:getState().data
end

return StitchStore
