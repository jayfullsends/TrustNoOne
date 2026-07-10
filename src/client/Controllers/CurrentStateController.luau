local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))
local gameStates = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameStates"))

local CurrentState = {}

--// Current State UI
local currentStateUI = playerGui:WaitForChild("CurrentState") :: ScreenGui
local mainFrame = currentStateUI:WaitForChild("Mainframe") :: Frame
local currentStateTitle = mainFrame:WaitForChild("CurrentStateTitle") :: TextLabel

--// Role Reveal UI

local function formatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local secs = seconds % 60

	return string.format("%d:%02d", minutes, secs)
end

function CurrentState:Init()
	return
end

function CurrentState:Start()
	remoteStorage.CurrentState.OnClientEvent:Connect(function(StateName)
		if StateName == gameStates.Waiting then
			currentStateTitle.Text = "Waiting for players..."
		elseif StateName == gameStates.Ending then
			currentStateTitle.Text = "Game Is Ending.."
		end
	end)

	remoteStorage.TimerEvent.OnClientEvent:Connect(function(msgType, msg)
		if msgType == "Intermission_Countdown" then
			currentStateTitle.Text = "Intermission : " .. msg
		elseif msgType == "Round_Countdown" then
			currentStateTitle.Text = formatTime(msg)
		elseif msgType == "Round_Starting" then
			currentStateTitle.Text = msg
		elseif msgType == "Giving_Tools" then
			currentStateTitle.Text = msg
		end
	end)
end

return CurrentState
