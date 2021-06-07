local Rodux = require(script.Parent.Parent.Parent.Rodux)
local Reducers = require(script.Reducers)
local HashMappedTrie = require(script.Parent.Parent.Shared.HashMappedTrie)

local StitchStore = {}
StitchStore.__index = StitchStore

function StitchStore.new(stitch)
	local self = setmetatable({
		_updateQueue = {},
		_deconstructQueue = {},
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

	local middlewares = {}
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
	if action.type == "updateData" then
		table.insert(self._updateQueue, action)
	elseif action.type == "deconstructPattern" then
		table.insert(self._deconstructQueue, action)
	elseif action.type == "constructPattern" then
		self._store:dispatch(action)
		self:fire("patternConstructed", action.uuid)
	end
end

function StitchStore:flush()
	if #self._updateQueue > 0 then
		local batchedAction = {
			type = "batchedUpdateData",
			actions = self._updateQueue,
		}
		self._store:dispatch(batchedAction)
		for _, action in ipairs(self._updateQueue) do
			self:fire("patternUpdated", action.uuid)
		end
		table.clear(self._updateQueue)
	end

	if #self._deconstructQueue > 0 then
		local deconstructActions = {}

		local function deconstruct(uuid)
			local pattern = self:lookup(uuid)
			for patternName, attached_uuid in pairs(pattern.attached) do
				if attached_uuid ~= uuid then
					deconstruct(attached_uuid)
				end
			end
			table.insert(deconstructActions, {
				type = "deconstructPattern",
				uuid = uuid,
			})
		end

		for _, action in ipairs(self._deconstructQueue) do
			deconstruct(action.uuid)
		end

		local batchedAction = {
			type = "batchedDeconstructPattern",
			actions = deconstructActions,
		}

		self._store:dispatch(batchedAction)

		for _, action in ipairs(deconstructActions) do
			self:fire("patternDeconstructed", action.uuid)
		end

		table.clear(self._deconstructQueue)
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

return StitchStore
