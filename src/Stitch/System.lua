local RunService = game:GetService("RunService")

--!strict

local System = {}
System.__index = System

System.priority = math.huge
System.updateEvent = RunService.Heartbeat

function System:create()
	self:onCreate()
end

function System:update()
	self:onUpdate()
end

function System:destroy()
	self:onDestroy()
end

-- User overridable functions
function System:onCreate() end

function System:onUpdate() end

function System:onDestroy() end

return System
