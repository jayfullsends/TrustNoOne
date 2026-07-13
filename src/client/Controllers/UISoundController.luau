local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui or player:WaitForChild("PlayerGui") :: PlayerGui

local soundsFolder = ReplicatedStorage:WaitForChild("Sounds") :: Folder

local UISoundController = {}

function UISoundController:Init()
	return
end

function UISoundController:Start()
	for _, descendant in PlayerGui:GetDescendants() do
		if descendant:IsA("GuiButton") then
			descendant.Activated:Connect(function()
				soundsFolder.Click:Play()
			end)
		end
	end
end

return UISoundController
