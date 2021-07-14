local RunService = game:GetService("RunService")

if RunService:IsServer() then
	return require(script.ReplicationSystemServer)
else
	return require(script.ReplicationSystemClient)
end
