local RunService = game:GetService("RunService")
local inlinedError = require(script.Parent.Parent.Shared.inlinedError)
local Util = require(script.Parent.Parent.Shared.Util)

--[=[
	@class SystemDefinition

	A SystemDefinition is a table that defines a System. 

	All SystemDefinition must be added to a World to be used.
]=]
local SystemDefinition = {}
SystemDefinition.__index = SystemDefinition

--[=[
	@prop name string?
	@within SystemDefinition
	Used to identify the System in the World (should be unique).

	If `name` is not defined and the SystemDefinition is returned by a ModuleScript,
	then registering the ModuleScript will use the name of the ModuleScript.
]=]
SystemDefinition.name = nil

--[=[
	@prop priority number?
	@within SystemDefinition
	Used to identify the System's priority within an updateEvent.

	**Lower priority values run first.**
	
	By default, the priority is `1000`.
]=]
SystemDefinition.priority = 1000

--[=[
	@prop updateEvent RBXScriptSignal?
	@within SystemDefinition
	The event that the System should listen to for updates. Each time the event fires, the System is updated.

	By default, the event is `RunService.Heartbeat`.
]=]
SystemDefinition.updateEvent = RunService.Heartbeat

function SystemDefinition:create(world)
	if self.stateComponent then
		world:registerComponent(Util.setKey(self.stateComponent, "name", self.stateComponent.name or self.name))
	end
	xpcall(self.onCreate, inlinedError, world)
end

function SystemDefinition:update(world, ...)
	xpcall(self.onUpdate, inlinedError, world, ...)
end

function SystemDefinition:destroy(world)
	xpcall(self.onDestroy, inlinedError, world)
	if self.stateComponent then
		world:unregisterComponent(Util.setKey(self.stateComponent, "name", self.stateComponent.name or self.name))
	end
end

-- User overridable functions

--[=[
	Called when the System is added to a World.
	You should override this function if you wanted to do some manual setup for the System.

	@param world World -- The World the System was added to.
	@return nil
]=]
function SystemDefinition:onCreate() end

--[=[
	Called when the System is updated.
	You should override this function to control what happens on each update.

	@param world World -- The World the System belongs to.
	@param ... any -- The arguments passed to the updateEvent. By default, this is just the time since last update.
	@return nil
]=]
function SystemDefinition:onUpdate() end

--[=[
	Called when the System is removed from the World.
	You should override this function if you wanted to do some manual cleanup for the System.

	@param world World -- The World the System belonged to.
	@return nil
]=]
function SystemDefinition:onDestroy() end

return SystemDefinition
