local Framework = {}
local Services = {}

function Framework:GetServices(name)
	return Services[name]
end

function Framework:Start(serviceFolder: Folder)
	for _, module in serviceFolder:GetChildren() do
		if module:IsA("ModuleScript") then
			Services[module.Name] = require(module)
		end
	end

	for _, service in Services do
		if service.Init then
			service:Init()
		end
	end

	for _, service in Services do
		if service.Start then
			service:Start()
		end
	end
end

return Framework
