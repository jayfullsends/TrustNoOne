local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui :: PlayerGui

--// UI Vars
local SettingsUI = PlayerGui:WaitForChild("SettingsUI") :: ScreenGui

local SettingsController = {}

-- function SettingsController:OpenOrClose()
-- 	SettingsUI.Enabled = not SettingsUI.Enabled
-- end

function SettingsController:Init()
	return
end

function SettingsController:Start()
	return
end

return SettingsController
