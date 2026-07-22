--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

--// Sounds
local soundsFolder = ReplicatedStorage:WaitForChild("Sounds")

local SOUND_DATA = {
	Spin = {
		Sound = soundsFolder:WaitForChild("WheelSpin"),
		StartTime = 6,
	},
	Claim = {
		Sound = soundsFolder:WaitForChild("Claim"),
	},
	-- Reveal = { Sound = soundsFolder:WaitForChild("Reveal") },  -- add when you have one
}

--// Modules
local RemoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))

--// Configs
local ItemConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("ItemConfig"))
local CrateConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("CrateConfig"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("RarityConfig"))

--// Vars
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--// Templates
local knifeTemplate =
	ReplicatedStorage:WaitForChild("Templates"):WaitForChild("Gui"):WaitForChild("KnifeTemplateFrame") :: Frame

--// UI References
local gui = playerGui:WaitForChild("LootboxUI") :: ScreenGui
local crateTitle = gui:WaitForChild("CrateName") :: TextLabel

local crateScroll = gui:WaitForChild("CrateScroll") :: Frame
local centerMarker = crateScroll:WaitForChild("CenterMarker") :: Frame
local scrollingFrame = crateScroll:WaitForChild("Scrolling") :: Frame

local itemUnlockedContents = gui:WaitForChild("ItemUnlockedContents") :: Frame
local itemUnlocked = itemUnlockedContents:WaitForChild("ItemUnlocked") :: Frame

local closeButton = itemUnlocked:WaitForChild("Close") :: TextButton
local itemImage = itemUnlocked:WaitForChild("ItemImage") :: ImageLabel
local itemName = itemUnlocked:WaitForChild("ItemName") :: TextLabel
local rarityType = itemUnlocked:WaitForChild("RarityType") :: TextLabel

local constants = {
	CARD_STEP = 160,
	CARD_WIDTH = 150,
	WINNER_SLOT = 50,
}

local hiddenUIs = {}

local LootboxUIController = {}

local function randomFromPool(pool)
	local keys = {}
	for key in pool do
		table.insert(keys, key)
	end
	return keys[math.random(1, #keys)]
end

function LootboxUIController:Open(crateName: string, result: string)
	if typeof(crateName) ~= "string" then
		return
	end
	if typeof(result) ~= "string" then
		return
	end

	local crate = CrateConfig[crateName]
	if not crate then
		return
	end

	local pool = crate.Pool

	--// Clear old cards
	for _, child in scrollingFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	--// Fresh state each open
	crateTitle.Text = crate.Name
	crateScroll.Visible = true
	crateTitle.Visible = true
	itemUnlockedContents.Visible = false
	gui.Enabled = true

	--// Build cards
	for i = 1, 60 do
		local card = knifeTemplate:Clone()

		local itemKey
		if i == constants.WINNER_SLOT then
			itemKey = result
		else
			itemKey = randomFromPool(pool)
		end

		local info = ItemConfig[itemKey]
		if not info then
			continue
		end

		card.Frame.ImageLabel.Image = info.ImageId
		card.Frame.ItemName.Text = itemKey
		card.Frame.ItemRarityColor.BackgroundColor3 = RarityConfig[info.Rarity].Color

		card.Parent = scrollingFrame
	end

	--// Hide the rest of the UI
	for _, other in playerGui:GetChildren() do
		if other:IsA("ScreenGui") and other.Name ~= "LootboxUI" and other.Enabled then
			other.Enabled = false
			table.insert(hiddenUIs, other)
		end
	end

	--// Spin sound
	local spin = SOUND_DATA.Spin
	spin.Sound.TimePosition = spin.StartTime
	spin.Sound:Play()

	--// Tween the reel
	local viewportWidth = crateScroll.AbsoluteSize.X
	local targetX = -((constants.WINNER_SLOT - 1) * constants.CARD_STEP)
		- (constants.CARD_WIDTH / 2)
		+ (viewportWidth / 2)

	scrollingFrame.Position = UDim2.fromScale(0, 0.5)

	local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tween = TweenService:Create(scrollingFrame, tweenInfo, { Position = UDim2.new(0, targetX, 0.5, 0) })
	tween:Play()
	tween.Completed:Wait()

	spin.Sound:Stop()

	--// Reveal
	local info = ItemConfig[result]
	if info then
		itemImage.Image = info.ImageId
		itemName.Text = result
		rarityType.Text = info.Rarity
		rarityType.TextColor3 = RarityConfig[info.Rarity].Color
	end

	local Claim = SOUND_DATA.Claim
	crateScroll.Visible = false
	crateTitle.Visible = false
	Claim.Sound:Play()
	itemUnlockedContents.Visible = true
end

function LootboxUIController:Init()
	print("LootboxUIController Init..")
end

function LootboxUIController:Start()
	print("LootboxUIController started..")

	closeButton.MouseButton1Click:Connect(function()
		itemUnlockedContents.Visible = false

		for _, other in hiddenUIs do
			other.Enabled = true
		end
		table.clear(hiddenUIs)

		gui.Enabled = false
	end)
end

return LootboxUIController
