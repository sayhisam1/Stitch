local InstancePattern = {
	name = "StitchManagedInstance",
	replicated = true,
}

function InstancePattern:getInstance()
	return self.instance
end

return InstancePattern
