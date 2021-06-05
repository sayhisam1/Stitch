local Reducers = {}

for _, v in pairs(script:GetChildren()) do
	Reducers[v.Name] = require(v)
end

return Reducers
