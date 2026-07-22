local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Framework = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Framework"))
local RemoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))

--// Vars
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// Gui Vars
local gui = playerGui:WaitForChild("TestingUI") :: ScreenGui

local mainframe = gui:WaitForChild("Frame") :: Frame
local buyButton = mainframe:WaitForChild("BuyButton") :: TextButton

local LootboxUIController

local TestingUIController = {}

function TestingUIController:Init()
	print("TestingUIController Init..")
	LootboxUIController = Framework:GetServices("LootboxUIController")
end

function TestingUIController:Start()
	print("TestingUIController started..")

	buyButton.MouseButton1Click:Connect(function()
		local result = RemoteStorage.OpenCrate:InvokeServer("ClassicCrate")
		if not result then
			print("Not Enough Coins..")
			return
		end

		LootboxUIController:Open("ClassicCrate", result)
	end)
end

return TestingUIController
