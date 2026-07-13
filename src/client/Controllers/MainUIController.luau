local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Framework = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Framework"))

local player = Players.LocalPlayer
local playerGui = player.PlayerGui or player:WaitForChild("PlayerGui")

local gui = playerGui:WaitForChild("MainUI") :: ScreenGui

--// UI Vars
local mainFrame = gui:WaitForChild("Mainframe") :: Frame

--// Coin Frame
local coinFrame = mainFrame:WaitForChild("CoinFrame") :: Frame
local coinAmount = coinFrame:WaitForChild("CoinAmount") :: TextLabel

--// Level
local levelFrame = mainFrame:WaitForChild("LevelFrame") :: Frame
local xpBar = levelFrame:WaitForChild("XPBar") :: Frame
local xpBarFill = xpBar:WaitForChild("XPFill") :: Frame
local playersLevel = levelFrame:WaitForChild("PlayersLevel") :: TextLabel

local buttonsHolder = mainFrame:WaitForChild("ButtonsHolder") :: Frame
--// Inventory
local inventoryButtonFrame = buttonsHolder:WaitForChild("InventoryButtonFrame") :: Frame
local inventoryButton = inventoryButtonFrame:WaitForChild("InventoryButton") :: Frame
local openInventoryButton = inventoryButton:WaitForChild("OpenInventoryButton") :: TextButton

--// Settings
local settingsButtonFrame = buttonsHolder:WaitForChild("SettingsButtonFrame") :: Frame
local settingsButton = settingsButtonFrame:WaitForChild("SettingsButton") :: Frame
local openSettingsButton = settingsButton:WaitForChild("OpenSettingsButton") :: TextButton

--// Shop
local shopButtonFrame = buttonsHolder:WaitForChild("ShopButtonFrame") :: Frame
local shopButton = shopButtonFrame:WaitForChild("ShopButton") :: Frame
local openShopButton = shopButton:WaitForChild("OpenShopButton") :: TextButton

--// Spectate
local spectateButtonFrame = buttonsHolder:WaitForChild("SpectateButtonFrame") :: Frame
local spectateButton = spectateButtonFrame:WaitForChild("SpectateButton") :: Frame
local openSpectateButton = spectateButton:WaitForChild("OpenSpectateButton") :: TextButton

local ShopController
local InventoryController
local SpectateController
local SettingsController

local MainUIController = {}

function setupOpen(button: TextButton, Controller: any)
	button.MouseButton1Click:Connect(function()
		Controller:OpenOrClose()
	end)
end

function MainUIController:Init()
	print("MainUI Controller Init..")
	ShopController = Framework:GetServices("ShopController")
	InventoryController = Framework:GetServices("InventoryController")
	SpectateController = Framework:GetServices("SpectateController")
	SettingsController = Framework:GetServices("SettingsController")
end

function MainUIController:Start()
	setupOpen(openShopButton, ShopController)
	setupOpen(openInventoryButton, InventoryController)
	setupOpen(openSpectateButton, SpectateController)
	setupOpen(openSettingsButton, SettingsController)
end

return MainUIController
