local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local remoteFunction: RemoteFunction
if RunService:IsServer() then
	remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = "TestRemoteRPC"
	remoteFunction.Parent = script
else
	remoteFunction = script:WaitForChild("TestRemoteRPC")
	local TestEZ = require(ReplicatedStorage.Packages.TestEZ)
	remoteFunction.OnClientInvoke = function(...)
		TestEZ.TestBootstrap:run(...)
	end
end

return function(...)
	assert(RunService:IsServer(), "tried to invoke client test rpc from client!")
	local plr = nil
	while not plr do
		plr = Players:GetPlayers()[1]
		wait()
	end
	return remoteFunction:InvokeClient(plr, ...)
end
