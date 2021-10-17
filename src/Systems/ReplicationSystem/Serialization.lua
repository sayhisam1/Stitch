local Serializer = {}

function Serializer.write(data: {}, container: Folder)
	for _, child in pairs(container:GetChildren()) do
		if not data[child.Name] then
			child:Destroy()
		end
	end
	for key, value in pairs(data) do
		local valueObject = container:FindFirstChild(key)
		if not valueObject then
			if typeof(value) == "string" then
				valueObject = Instance.new("StringValue")
			elseif typeof(value) == "Instance" then
				valueObject = Instance.new("ObjectValue")
			elseif typeof(value) == "number" then
				valueObject = Instance.new("NumberValue")
			elseif typeof(value) == "Vector3" then
				valueObject = Instance.new("Vector3Value")
			elseif typeof(value) == "CFrame" then
				valueObject = Instance.new("CFrameValue")
			elseif typeof(value) == "boolean" then
				valueObject = Instance.new("BoolValue")
			elseif typeof(value) == "Color3" then
				valueObject = Instance.new("Color3Value")
			else
				warn(("tried to serialize invalid value %s of type %s!"):format(tostring(value), typeof(value)))
				continue
			end
			valueObject.Name = key
			valueObject.Parent = container
		end
		valueObject.Value = value
	end
end

function Serializer.read(container: Folder)
	local data = {}

	for _, child in pairs(container:GetChildren()) do
		data[child.Name] = child.Value
	end

	return data
end

return Serializer
