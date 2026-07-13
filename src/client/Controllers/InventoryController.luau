local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteStorage = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage")

local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui or player:WaitForChild("PlayerGui")

--// UI Vars
local inventoryUI = PlayerGui:WaitForChild("InventoryUI") :: ScreenGui

local InventoryController = {}

function InventoryController:Open()
	inventoryUI.Enabled = true
end

function InventoryController:Close()
	inventoryUI.Enabled = false
end

function InventoryController:Init()
	return
end

function InventoryController:Start()
	return
end

return InventoryController
