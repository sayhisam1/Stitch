local RunService = game:GetService("RunService")

--!strict

local System = {}
System.__index = System

System.priority = math.huge
System.updateEvent = RunService.Heartbeat

function System:update()
	self:onUpdate()
end

function System:destroy()
	self:onDestroy()
end

return System
