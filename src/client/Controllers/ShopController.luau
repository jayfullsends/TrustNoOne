local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteStorage = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage")

local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui or player:WaitForChild("PlayerGui") :: PlayerGui

--// UI Vars
local shopUI = PlayerGui:WaitForChild("ShopUI") :: ScreenGui

--// Frames
local mainFrame = shopUI:WaitForChild("Mainframe")

local ShopController = {}

function ShopController:Open()
	shopUI.Enabled = true
end

function ShopController:Close()
	shopUI.Enabled = false
end

function ShopController:Init()
	print("Shop Controller Init..")
end

function ShopController:Start()
	print("Shop Controller Started..")
end

return ShopController
