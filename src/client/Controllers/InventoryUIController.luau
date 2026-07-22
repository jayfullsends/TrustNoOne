local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("ItemConfig"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("RarityConfig"))

local Framework = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Framework"))
local RemoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))

local NotifyController

local player = Players.LocalPlayer
local PlayerGui = player.PlayerGui

--// UI Vars
local inventoryUI = PlayerGui:WaitForChild("InventoryUI") :: ScreenGui

local InventoryController = {}

local TEMPLATES = {
	ItemTemplate = ReplicatedStorage:WaitForChild("Templates")
		:WaitForChild("Gui")
		:WaitForChild("InventoryItemTemplate"),
}

local STORED_UI_ELEMENTS = {
	Tabs = {
		HighlightedTab = "rbxassetid://71414477829870",
		UnhighlightedTab = "rbxassetid://89151746451688",
	},
}

local DEFAULT_ITEMS = {
	Knives = "DefaultKnife",
	Guns = "DefaultRevolver",
}

local UI_SOUNDS = {
	ClickSound = ReplicatedStorage:WaitForChild("Sounds"):WaitForChild("Click") :: Sound,
}

local selectedTab = nil
local selectedItem = nil
local inventoryData = nil
local selectedCategory = nil
local counts = {}
local equippedData = nil

--// Mainframe Section
local mainFrame = inventoryUI:WaitForChild("Mainframe") :: Frame
local closeUIButton = mainFrame:WaitForChild("CloseUI") :: TextButton

--// Content Tab
local contentTab = mainFrame:WaitForChild("ContentTab") :: Frame
local categorySelect = contentTab:WaitForChild("CategorySelect") :: ImageButton
local ownedTitleText = contentTab:WaitForChild("OwnedTitle"):WaitForChild("TextLabel") :: TextLabel
local itemCollectedAmount = contentTab:WaitForChild("ItemCollectedAmount") :: TextLabel

--// Item Info Tab
local itemInfoTab = contentTab:WaitForChild("ItemInfoTab") :: Frame
local itemInfoBackgroundOutside = itemInfoTab:WaitForChild("ItemInfoBackgroundOutside") :: ImageLabel
local itemInfoBackgroundInside = itemInfoBackgroundOutside:WaitForChild("ItemInfoBackgroundInside") :: ImageLabel

-- local itemImageViewport = itemInfoBackgroundInside:WaitForChild("ItemImageViewport") :: ViewportFrame
local itemImageBackground = itemInfoBackgroundInside:WaitForChild("ItemImageBackground") :: ImageLabel
local itemImage = itemImageBackground:WaitForChild("ItemImage") :: ImageLabel

local itemNameTab = itemInfoBackgroundInside:WaitForChild("ItemNameTab") :: ImageLabel
local itemName = itemNameTab:WaitForChild("ItemName") :: TextLabel
local itemRarity = itemNameTab:WaitForChild("ItemRarity") :: TextLabel

local itemInfo = itemInfoBackgroundInside:WaitForChild("ItemInfo") :: ImageLabel
local equipButton = itemInfo:WaitForChild("EquipButton") :: TextButton
local useDefaultButton = itemInfo:WaitForChild("UseDefaultButton") :: TextButton
local itemDescriptionText = itemInfo:WaitForChild("ItemDescriptionText") :: TextLabel
local itemAcquiredText = itemInfo:WaitForChild("ItemAcquiredText") :: TextLabel
local itemCreatorText = itemInfo:WaitForChild("ItemCreatorText") :: TextLabel

--// Scroll Frame Content
local scrollFrameContent = contentTab:WaitForChild("ScrollFrameContent") :: Frame
local toysContentFrame = scrollFrameContent:WaitForChild("ToysContentFrame") :: ScrollingFrame
local knivesContentFrame = scrollFrameContent:WaitForChild("KnivesContentFrame") :: ScrollingFrame
local gunsContentFrame = scrollFrameContent:WaitForChild("GunsContentFrame") :: ScrollingFrame
local petsContentFrame = scrollFrameContent:WaitForChild("PetsContentFrame") :: ScrollingFrame

--// Sections Tab
local sectionsTab = mainFrame:WaitForChild("SectionsTab") :: Frame
local openKnivesTab = sectionsTab:WaitForChild("OpenKnivesTab") :: ImageButton
local openGunsTab = sectionsTab:WaitForChild("OpenGunsTab") :: ImageButton
local OpenToysTab = sectionsTab:WaitForChild("OpenToysTab") :: ImageButton
local OpenPetsTab = sectionsTab:WaitForChild("OpenPetsTab") :: ImageButton

local function populate(category, scrollFrame)
	local owned = 0
	local total = 0

	for _, item in ItemConfig do
		if item.Category == category then
			total += 1
		end
	end

	for key, value in inventoryData[category] do
		local clone = TEMPLATES.ItemTemplate:Clone() :: ImageButton
		clone.ItemImageBackground.Item.Image = ItemConfig[key].ImageId
		clone:WaitForChild("ItemName").Text = key
		local count = value.Count or 0

		if count > 1 then
			clone.ItemCount.Text = "x" .. count
		else
			clone.ItemCount.Text = ""
		end

		clone.ItemRarity.Text = ItemConfig[key].Rarity
		clone.ItemRarity.TextColor3 = RarityConfig[ItemConfig[key].Rarity].Color
		clone.ItemAcquired.Text = os.date("%m/%d/%Y", value.Acquired)

		clone.Parent = scrollFrame
		owned += 1

		clone.MouseButton1Click:Connect(function()
			selectedItem = key
			selectedCategory = category

			itemNameTab.ItemName.Text = key
			itemNameTab.ItemRarity.Text = ItemConfig[key].Rarity
			itemNameTab.ItemRarity.TextColor3 = RarityConfig[ItemConfig[key].Rarity].Color

			itemDescriptionText.Text = ItemConfig[key].Description
			itemAcquiredText.Text = os.date("Acquired on : %m/%d/%Y at %I:%M %p", value.Acquired)
			itemCreatorText.Text = ItemConfig[key].Creator

			if equippedData[category] == key then
				equipButton.Text = "Equipped"
			else
				equipButton.Text = "Equip"
			end

			itemImageBackground.ItemImage.Image = ItemConfig[key].ImageId
		end)
	end
	counts[category] = { owned = owned, total = total }
end

local function showTab(button: ImageButton, scrollFrame: ScrollingFrame, category)
	for _, frame in scrollFrameContent:GetChildren() do
		if frame:IsA("ScrollingFrame") then
			frame.Visible = false
		end
	end

	local c = counts[category]
	itemCollectedAmount.Text = c.owned .. " : " .. c.total .. " owned"

	if selectedTab then
		selectedTab.Image = STORED_UI_ELEMENTS.Tabs.UnhighlightedTab
	end

	button.Image = STORED_UI_ELEMENTS.Tabs.HighlightedTab
	selectedTab = button

	scrollFrame.Visible = true
end

local function setupSectionsTab(button: ImageButton, scrollFrame: ScrollingFrame, category)
	button.MouseButton1Click:Connect(function()
		UI_SOUNDS.ClickSound:Play()
		showTab(button, scrollFrame, category)
	end)
end

function InventoryController:OpenOrClose()
	inventoryUI.Enabled = not inventoryUI.Enabled
end

function InventoryController:Init()
	NotifyController = Framework:GetServices("NotifyController")
end

function InventoryController:Start()
	local success, result = pcall(function()
		return RemoteStorage.GetInventory:InvokeServer()
	end)

	if not success or not result then
		NotifyController:Notify("Couldn't load your inventory")
		return
	end

	inventoryData = result.Inventory
	equippedData = result.Equipped

	populate("Knives", knivesContentFrame)
	populate("Guns", gunsContentFrame)
	populate("Toys", toysContentFrame)
	populate("Pets", petsContentFrame)

	showTab(openKnivesTab, knivesContentFrame, "Knives")

	equipButton.MouseButton1Click:Connect(function()
		if not selectedItem then
			NotifyController:Notify("Select an item to equip")
			return
		end

		local success = RemoteStorage.EquipItem:InvokeServer(selectedCategory, selectedItem)
		if success then
			equippedData[selectedCategory] = selectedItem
			equipButton.Text = "Equipped"
		else
			NotifyController:Notify("Couldn't equip that item")
		end
	end)

	useDefaultButton.MouseButton1Click:Connect(function()
		if not selectedCategory then
			NotifyController:Notify("Select a category first")
			return
		end

		local defaultKey = DEFAULT_ITEMS[selectedCategory]
		if not defaultKey then
			NotifyController:Notify("No default for this category")
			return
		end

		local success = RemoteStorage.EquipItem:InvokeServer(selectedCategory, defaultKey)
		if success then
			equippedData[selectedCategory] = defaultKey

			if selectedItem == equippedData[selectedCategory] then
				equipButton.Text = "Equipped"
			else
				equipButton.Text = "Equip"
			end
		end
	end)

	--//Setups -- {}
	setupSectionsTab(openKnivesTab, knivesContentFrame, "Knives")
	setupSectionsTab(openGunsTab, gunsContentFrame, "Guns")
	setupSectionsTab(OpenToysTab, toysContentFrame, "Toys")
	setupSectionsTab(OpenPetsTab, petsContentFrame, "Pets")

	--// Close Funfcionality
	closeUIButton.MouseButton1Click:Connect(function()
		self:OpenOrClose()
	end)
end

return InventoryController
