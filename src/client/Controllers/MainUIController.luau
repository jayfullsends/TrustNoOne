local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player.PlayerGui or player:WaitForChild("PlayerGui")

local gui = playerGui:WaitForChild("MainUI") :: ScreenGui
