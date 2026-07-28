local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Modules
local LootboxUIController = require(script.Parent.LootboxUIController)
local RemoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))
local CrateConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("CrateConfig"))

--// Configs

local ItemConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("ItemConfig"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("RarityConfig"))

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local crateTemplate = ReplicatedStorage:WaitForChild("Templates"):WaitForChild("Gui"):WaitForChild("CrateTemplate")
local possibleContentsTemplate =
	ReplicatedStorage:WaitForChild("Templates"):WaitForChild("Gui"):WaitForChild("PossibleContentsTemplate")

--// UI Root
local shopUI = PlayerGui:WaitForChild("ShopUI") :: ScreenGui
local mainFrame = shopUI.MainFrame

local contentTab = mainFrame.ContentTab
local sectionsTab = mainFrame.SectionsTab
local categoryFrames = contentTab.CategoryFrames

local closeButton = mainFrame.CloseButton

--// Categories (Knives + Guns are structurally identical)
local CATEGORY_FRAMES = {
	Knives = categoryFrames.KnivesFrame,
	Guns = categoryFrames.GunsFrame,
}

local TAB_BUTTONS = {
	Knives = sectionsTab.OpenKnivesTab,
	Guns = sectionsTab.OpenGunsTab,
}

local selectedCrate

--// Detail panel
local infoInside = contentTab.ItemInfoTab.ItemInfoBackgroundOutside.ItemInfoBackgroundInside
local itemInfo = infoInside.ItemInfo

local itemName = itemInfo.ItemName
local itemCost = itemInfo.ItemCost
local purchaseButton = itemInfo.PurchaseButton
local itemImage = infoInside.ItemImageBackground.ItemImage

local function showCategory(category)
	for _, frame in categoryFrames:GetChildren() do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end

	CATEGORY_FRAMES[category].Visible = true
end

local function selectCrate(crateKey)
	local crate = CrateConfig[crateKey]
	if not crate then
		return
	end

	selectedCrate = crateKey

	local crateInfo = CATEGORY_FRAMES[crate.Category].CrateInfo

	crateInfo.CrateName.Text = crate.Name
	crateInfo.CrateDescription.Text = crate.Description

	itemName.Text = crate.Name
	itemImage.Image = crate.Image
	itemCost.Text = tostring(crate.Price)

	local ContentsHolder = crateInfo.ContentsHolder

	for _, item in ContentsHolder:GetChildren() do
		if item:IsA("Frame") then
			item:Destroy()
		end
	end

	local totalWeight = 0
	for _, entry in crate.Pool do
		totalWeight += entry.Weight
	end

	for itemKey, entry in crate.Pool do
		local info = ItemConfig[itemKey]
		if not info then
			continue
		end

		local rarityColor = (RarityConfig[info.Rarity] or RarityConfig.Default).Color

		local clone = possibleContentsTemplate:Clone()
		clone.ContentItemImage.Image = info.ImageId
		clone.ContentItemRarity.Text = info.Rarity
		clone.ContentItemRarity.TextColor3 = rarityColor
		clone.ContentItemChance.Text = string.format("%.2f%%", entry.Weight / totalWeight * 100)
		clone.LayoutOrder = -entry.Weight

		clone.Parent = ContentsHolder
	end
end

local function populate(category)
	local frame = CATEGORY_FRAMES[category]
	if not frame then
		return
	end

	local holder = frame.CrateHolder

	for _, item in holder:GetChildren() do
		if item:IsA("Frame") then
			item:Destroy()
		end
	end

	for crateKey, crate in CrateConfig do
		if crate.Category ~= category then
			continue
		end

		local clone = crateTemplate:Clone()
		clone.CrateImage.Image = crate.Image
		clone.CrateName.Text = crate.Name
		clone.CratePrice.Text = tostring(crate.Price)
		clone.LayoutOrder = crate.Order

		clone.Name = crateKey
		clone.Parent = holder

		clone.ClickButton.MouseButton1Click:Connect(function()
			selectCrate(crateKey)
		end)
	end
end

local ShopController = {}

function ShopController:OpenOrClose()
	shopUI.Enabled = not shopUI.Enabled
end

function ShopController:Init()
	print("Shop Controller Init..")
end

function ShopController:Start()
	print("Shop Controller Started..")
	populate("Knives")
	populate("Guns")

	--// Button Handling

	for category, button in TAB_BUTTONS do
		button.MouseButton1Click:Connect(function()
			showCategory(category)
		end)
	end

	purchaseButton.MouseButton1Click:Connect(function()
		if not selectedCrate then
			return
		end

		local result = RemoteStorage.OpenCrate:InvokeServer(selectedCrate)
		if not result then
			return
		end

		if result then
			LootboxUIController:Open(selectedCrate, result)
		end
	end)

	closeButton.MouseButton1Click:Connect(function()
		self:OpenOrClose()
	end)
end

return ShopController
