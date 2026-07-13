local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Framework = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Framework"))

local player = Players.LocalPlayer
local playerGui = player.PlayerGui or player:WaitForChild("PlayerGui")

local gui = playerGui:WaitForChild("MainUI") :: ScreenGui

local ShopController
local InventoryController
local SpectateController
local SettingsController

local MainUIController = {}

function MainUIController:Init()
	print("MainUI Controller Init..")
	ShopController = Framework:GetServices("ShopController")
	InventoryController = Framework:GetServices("InventoryController")
	SpectateController = Framework:GetServices("SpectateController")
	SettingsController = Framework:GetServices("SettingsController")
end

function MainUIController:Start()
	print("MainUI Controller Started..")
end

return MainUIController
