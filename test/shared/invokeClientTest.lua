local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local TextReporterNone = {
	report = function()
	end
}

local remoteFunction: RemoteFunction
if RunService:IsServer() then
	remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = "TestRemoteRPC"
	remoteFunction.Parent = script
else
	remoteFunction = script:WaitForChild("TestRemoteRPC")
	local TestEZ = require(ReplicatedStorage.TestEZ)
	remoteFunction.OnClientInvoke = function(roots, patterns)
		local testResults = TestEZ.TestBootstrap:run(roots, TextReporterNone, patterns)
		return testResults.errors
	end
end

return function(...)
	assert(RunService:IsServer(), "tried to invoke client test rpc from client!")
	local plr = Players:GetPlayers()[1]
	if not plr then
		Players.PlayerAdded:wait()
		plr = Players:GetPlayers()[1]
	end
	local errors = remoteFunction:InvokeClient(plr, ...)
	for _, err in pairs(errors) do
		error(err, 2)
	end
end
