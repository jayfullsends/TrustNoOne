local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui") :: PlayerGui

--// Main Frame
local gui = PlayerGui:WaitForChild("RoundStatsUI") :: ScreenGui
local main = gui:WaitForChild("Main") :: Frame
local contentFrame = main:WaitForChild("ContentFrame") :: Frame

local UITemplates = ReplicatedStorage:WaitForChild("Templates"):WaitForChild("Gui")
local playerTemplate = UITemplates:WaitForChild("PlayerTemplate") :: Frame

--// Murderer Hierarchy - 1
local murdererFrameBorder = contentFrame:WaitForChild("MurdererFrameBorder") :: Frame
local murdererContentFrame = murdererFrameBorder:WaitForChild("MurdererContentFrame") :: Frame

--// Murderer Hierarchy - 2
local MurdererStatsBackground = murdererContentFrame:WaitForChild("MurdererStatsBackground") :: Frame
local murdererStats = MurdererStatsBackground:WaitForChild("MurdererStats") :: Frame
local murdererKillStats = murdererStats:WaitForChild("KillsStat") :: Frame
local playersKilledAmount = murdererKillStats:WaitForChild("PlayersKilledAmount") :: TextLabel

local murdererplayerIconBackground = murdererContentFrame:WaitForChild("PlayerIconBackground") :: Frame
local murdererplayerIcon = murdererplayerIconBackground:WaitForChild("PlayerIcon") :: Frame
local murdererPlayerImage = murdererplayerIcon:WaitForChild("PlayerImage") :: ImageLabel
local murdererDisplayName = murdererContentFrame:WaitForChild("PlayerDisplayName") :: TextLabel

--// Players Content Frame
local playersContentFrameBackground = contentFrame:WaitForChild("PlayersContentFrameBackground") :: Frame
local playersContentFrame = playersContentFrameBackground:WaitForChild("PlayersContentFrame") :: Frame
local topBar = playersContentFrame:WaitForChild("Topbar") :: Frame
local playersHolder = topBar:WaitForChild("PlayersHolder") :: ScrollingFrame

--// Sheriff Frame Border
local sheriffFrameBorder = contentFrame:WaitForChild("SheriffFrameBorder") :: Frame
local sheriffContentFrame = sheriffFrameBorder:WaitForChild("SheriffContentFrame") :: Frame
local sheriffDisplayName = sheriffContentFrame:WaitForChild("PlayerDisplayName") :: TextLabel

local sheriffplayerIconBackground = sheriffContentFrame:WaitForChild("PlayerIconBackground") :: Frame
local sheriffplayerIcon = sheriffplayerIconBackground:WaitForChild("PlayerIcon") :: Frame
local sheriffplayerImage = sheriffplayerIcon:WaitForChild("PlayerImage") :: ImageLabel

local sheriffStatsBackground = sheriffContentFrame:WaitForChild("SheriffStatsBackground") :: Frame
local sheriffStats = sheriffStatsBackground:WaitForChild("SheriffStats") :: Frame
local sheriffKillStats = sheriffStats:WaitForChild("KillsStat") :: Frame
local shotsFiredAmount = sheriffKillStats:WaitForChild("ShotsFiredAmount") :: TextLabel

local RoundWinner = gui:WaitForChild("RoundWinner") :: Frame
local WinnersText = RoundWinner:WaitForChild("Winners") :: TextLabel

--// Stats Frame
local statsFrame = gui:WaitForChild("StatsFrame") :: Frame
local statsFrameContent = statsFrame:WaitForChild("StatsFrameContent") :: Frame

--// XP Handling
local xpBar = statsFrameContent:WaitForChild("XPBar") :: Frame
local xpFill = xpBar:WaitForChild("XpFill") :: Frame
local playersCurrentLevel = statsFrameContent:WaitForChild("PlayersCurrentLevel") :: TextLabel
local playersNextLevel = statsFrameContent:WaitForChild("PlayersNextLevel") :: TextLabel
local xpEarnedAmount = statsFrameContent:WaitForChild("XPEarnedAmount") :: TextLabel
local xpNeeded = xpBar:WaitForChild("XPNeeded") :: TextLabel

local closeButton = statsFrame:WaitForChild("CloseButton") :: TextButton

local remoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))

--// Functions
local function clearRoster()
	for _, template in playersHolder:GetChildren() do
		if template:IsA("Frame") then
			template:Destroy()
		end
	end
end

local function tweenTo(ratio, duration)
	local info = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local tween = TweenService:Create(xpFill, info, { Size = UDim2.fromScale(ratio, 1) })
	tween:Play()
	tween.Completed:Wait()
end

local function pluralize(count, singular, plural)
	if count == 1 then
		return count .. " " .. singular
	else
		return count .. " " .. plural
	end
end

local function populateMurderer(userId, kills)
	local content
	pcall(function()
		content = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)

	murdererPlayerImage.Image = content

	local Player_Murderer = Players:GetPlayerByUserId(userId)
	if Player_Murderer then
		murdererDisplayName.Text = Player_Murderer.Name
	else
		murdererDisplayName.Text = "Player Left.."
	end

	playersKilledAmount.Text = pluralize(kills, "Kill", "Kills")
end

local function populateSheriff(userId, shots)
	local content
	pcall(function()
		content = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	end)

	sheriffplayerImage.Image = content

	local sheriffPlayer = Players:GetPlayerByUserId(userId)

	if sheriffPlayer then
		sheriffDisplayName.Text = sheriffPlayer.Name
	else
		sheriffDisplayName.Text = "Player Left.."
	end

	shotsFiredAmount.Text = pluralize(shots, "Shot Fired", "Shots Fired")
end

local function buildRoster(innocents)
	for _, userId in innocents do
		local playerName = "Unknown"
		local content
		pcall(function()
			content = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)

		local clone = playerTemplate:Clone()
		local playerRoleFrame = clone:WaitForChild("PlayerRole") :: Frame
		pcall(function()
			playerName = Players:GetNameFromUserIdAsync(userId)
		end)
		local playerRoleName = playerRoleFrame:WaitForChild("PlayersRoleName")
		playerRoleName.Text = "Innocent"
		clone:WaitForChild("PlayerImage").Image = content
		clone:WaitForChild("PlayersName").Text = playerName
		clone.Parent = playersHolder
		clone.Visible = true
	end
end

local function buildWinTitle(winners)
	if winners == "Murderer" then
		WinnersText.Text = "Murderer Wins!"
	elseif winners == "Innocent" then
		WinnersText.Text = "Innocents Win!"
	end
end

local function buildStats(data)
	local playerInfo = data
	local startRatio = math.clamp(data.startXP / data.startXPNeeded, 0, 1)
	local endRatio = math.clamp(data.currentXP / data.xpNeeded, 0, 1)
	local levelsGained = data.level - data.startLevel

	playersCurrentLevel.Text = "Lvl : " .. data.startLevel
	playersNextLevel.Text = "Lvl : " .. (data.startLevel + 1)
	xpNeeded.Text = data.startXP .. " / " .. data.startXPNeeded
	xpEarnedAmount.Text = "XP Earned : +" .. playerInfo.earned

	xpFill.Size = UDim2.fromScale(startRatio, 1)
	task.wait(1)

	if levelsGained == 0 then
		tweenTo(endRatio, 1.25)
	else
		tweenTo(1, 1.25)
		xpFill.Size = UDim2.fromScale(0, 1)

		playersCurrentLevel.Text = "Lvl : " .. data.level
		playersNextLevel.Text = "Lvl : " .. (data.level + 1)
		xpNeeded.Text = playerInfo.currentXP .. " / " .. playerInfo.xpNeeded

		for i = 2, levelsGained do
			tweenTo(1, 0.3)
			xpFill.Size = UDim2.fromScale(0, 1)
		end

		tweenTo(endRatio, 1.25)
	end

	xpNeeded.Text = playerInfo.currentXP .. " / " .. playerInfo.xpNeeded
end

local RoundStatsController = {}

function RoundStatsController:Init()
	return
end

function RoundStatsController:Start()
	remoteStorage.RoundEnded.OnClientEvent:Connect(function(data)
		clearRoster()
		populateMurderer(data.murderer, data.murderer_kills)
		populateSheriff(data.sheriff, data.sheriff_shots)
		buildWinTitle(data.winner)
		buildRoster(data.innocents)
		gui.Enabled = true

		task.delay(10, function()
			gui.Enabled = false
		end)

		buildStats(data)
	end)

	closeButton.MouseButton1Click:Connect(function()
		gui.Enabled = not gui.Enabled
	end)
end

return RoundStatsController
