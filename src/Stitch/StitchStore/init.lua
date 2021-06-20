local Rodux = require(script.Parent.Parent.Parent.Rodux)
local Reducers = require(script.Reducers)
local PcallNoYield = require(script.Parent.Parent.Shared.PcallNoYield)

local StitchStore = {}
StitchStore.__index = StitchStore

function StitchStore.new(stitch)
	local self = setmetatable({
		_actionQueue = {},
		_listeners = {},
		_isAtomicMode = false,
		stitch = stitch,
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

	local storeErrorReporter = {
		reportReducerError = function(prevState, action, errorResult)
			error(errorResult.thrownValue, 0)
		end,
		reportUpdateError = function(prevState, currentState, lastActions, errorResult)
			error(string.format("%s", errorResult.thrownValue), 0)
		end,
	}

	self._store = Rodux.Store.new(reducer, {
		data = {},
	}, middlewares, storeErrorReporter)

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

function StitchStore:_dispatch(action, traceback)
	-- since stack traces are lost when we resolve the action, we keep it stored within the action itself as metadata
	action.traceback = traceback
	table.insert(self._actionQueue, action)
end

function StitchStore:dispatch(action)
	local traceback = debug.traceback(nil, 1)
	if action.type == "deconstructPattern" then
		local deconstructActions = self:_expandDeconstructAction(action)
		self:runWithAtomicDispatch(function()
			for _, deconstruct in ipairs(deconstructActions) do
				self:_dispatch(deconstruct, traceback)
			end
		end)
	else
		self:_dispatch(action, traceback)
	end
end

function StitchStore:_expandDeconstructAction(action: table)
	-- deconstructs must be atomic, since we deconstruct the entire "tree" of patterns attached to
	-- the root.
	-- we unpack deconstructs into actions starting at the leaf nodes
	-- each action needs to be separate to ensure all corresponding deconstruction events are fired
	local function deconstruct(uuid: string, tbl: table)
		local pattern = self:lookup(uuid)
		for patternName, attached_uuid in pairs(pattern.attached) do
			-- special case for root patterns: we skip these
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
	return actions
end

function StitchStore:_createThunk(
	actionQueue: table,
	successfulActions: table,
	erroredActions: table,
	enforceAtomicity: bool
)
	local function thunk(store)
		local copied = {}
		local originalState = store:getState()
		for _, action in ipairs(actionQueue) do
			local newSuccessfulActions
			if action.type == "atomic" then
				-- we enforce atomicity only for depth > 1 thunks, since these are
				-- only creatable by explicitly entering an atomic context
				-- the top-level action queue doesn't need to follow this, however,
				-- as that would cause any failure to discard all pending actions for the flush
				newSuccessfulActions = {}
				action = self:_createThunk(action.actions, newSuccessfulActions, erroredActions, true)
			else
				-- to reduce the overhead of shallow copies, we pass down the currently copied arrays
				-- to the action
				newSuccessfulActions = { action }
				action.copied = copied
			end

			-- dispatches must be atomic, and must not yield!
			-- yielding can cause strange side-effects like resetting state to weird intermediates
			local success, msg = pcall(store.dispatch, store, action)

			if success then
				table.move(newSuccessfulActions, 1, #newSuccessfulActions, #successfulActions + 1, successfulActions)
			else
				if typeof(action) == "table" then
					-- we don't have stack trace of thunk actions
					table.insert(erroredActions, {
						traceback = action.traceback,
						msg = msg,
					})
				end
				if enforceAtomicity then
					-- in atomic thunks, we revert the state back to the original value and error
					self._store:dispatch({
						type = "setState",
						state = originalState,
					})
					self.stitch:error(msg, 0)
				end
			end
		end
	end
	return thunk
end

function StitchStore:runWithAtomicDispatch(callback: callback)
	local oldActionQueue = self._actionQueue
	local oldAtomicState = self._isAtomicMode
	local newActionQueue = {}

	self._actionQueue = newActionQueue
	self._isAtomicMode = true

	local status, msg = PcallNoYield(callback)

	self._isAtomicMode = oldAtomicState
	self._actionQueue = oldActionQueue

	if status then
		table.insert(oldActionQueue, {
			type = "atomic",
			actions = newActionQueue,
		})
	else
		self.stitch:error(msg)
	end
end

function StitchStore:flush()
	if self._isAtomicMode then
		self.stitch:error("tried to flush stitch store while within atomic mode. This is not allowed!")
	end
	local successfulActions = table.create(#self._actionQueue)
	local erroredActions = table.create(#self._actionQueue)
	local thunk = self:_createThunk(self._actionQueue, successfulActions, erroredActions, false)
	pcall(self._store.dispatch, self._store, thunk)
	for _, errorState in ipairs(erroredActions) do
		self.stitch:inlinedError(("%s\n%s"):format(errorState.msg, errorState.traceback), 0)
	end
	table.clear(self._actionQueue)
	for _, action in ipairs(successfulActions) do
		if action.type == "constructPattern" then
			self.stitch:fire("patternConstructed", action.uuid)
		elseif action.type == "updateData" then
			self.stitch:fire("patternUpdated", action.uuid)
		elseif action.type == "deconstructPattern" then
			self.stitch:fire("patternDeconstructed", action.uuid)
		end
	end
	self._store:flush()
end

function StitchStore:getState()
	return self._store:getState()
end

function StitchStore:lookup(uuid: string)
	return self:getState()["data"][uuid]
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
