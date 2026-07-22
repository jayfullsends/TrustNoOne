--//Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Player References
local player = Players.LocalPlayer
local playerGui = player.PlayerGui

--// Sounds
local soundsFolder = ReplicatedStorage:WaitForChild("Sounds")
local notifySound = soundsFolder:WaitForChild("NotifySound")

--// Templates
local MessageTemplate =
	ReplicatedStorage:WaitForChild("Templates"):WaitForChild("Gui"):WaitForChild("Message") :: TextLabel

--// UI References
local gui = playerGui:WaitForChild("NotifyUI")
local mainFrame = gui:WaitForChild("Frame") :: Frame

local max_toasts = 3
local activeToasts = {}

local NotifyController = {}

function NotifyController:Notify(msg: string)
	if typeof(msg) ~= "string" then
		warn("Type Error..")
		return
	end

	notifySound:Play()

	local clone = MessageTemplate:Clone()
	clone.Text = msg
	clone.Parent = mainFrame

	table.insert(activeToasts, clone)

	if #activeToasts > max_toasts then
		local oldest = table.remove(activeToasts, 1)
		oldest:Destroy()
	end

	task.delay(1.5, function()
		local index = table.find(activeToasts, clone)
		if index then
			table.remove(activeToasts, index)
		end
		clone:Destroy()
	end)
end

function NotifyController:Init()
	print("Notification Controller Init..")
end

function NotifyController:Start()
	print("Notification Controller Started..")
end

return NotifyController
