local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))

local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui or player:WaitForChild("PlayerGui") :: PlayerGui

local SpectateUI = PlayerGui:WaitForChild("SpectateUI") :: ScreenGui

local SpectateController = {}

function SpectateController:Open()
	SpectateUI.Enabled = true
end

function SpectateController:Close()
	SpectateUI.Enabled = false
end

function SpectateController:Init()
	return
end

function SpectateController:Start()
	return
end

return SpectateController
