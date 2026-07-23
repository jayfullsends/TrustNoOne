local RunService = game:GetService("RunService")
local Players = game:GetService("Players") :: Players
local ReplicatedStorage = game:GetService("ReplicatedStorage") :: ReplicatedStorage
local ServerStorage = game:GetService("ServerStorage") :: ServerStorage

--// Datastore
local DataStoreService = game:GetService("DataStoreService") :: DataStoreService
local playerDataStore = DataStoreService:GetDataStore("PlayerData_V1")

local RemoteStorage = require(ReplicatedStorage.Modules.RemoteStorage)

--// Variables

-- local allowedPlayers = {
-- 	2774595226,
-- 	3105268777,
-- 	69253326,
-- }

local playerData = {}
local loaded = {}

local DEFAULT_DATA = {
	Currencies = {
		Coins = 0,
	},
	Inventory = {
		Knives = {},
		Guns = {},
		Pets = {},
		Toys = {},
	},
	XP = 0,
	Level = 1,
	Equipped = {
		Knives = "DefaultKnife",
		Guns = "DefaultRevolver",
		Pets = nil,
		Toys = nil,
	},
	Stats = {
		Wins = 0,
		RoundsPlayed = 0,
		MurdererKills = 0,
		ShotsFired = 0,
	},
	Settings = {
		MusicOn = true,
		SfxOn = true,
		UIColor = "WHITE",
	},
}

--// Functions

local function deepCopy(original)
	local copy = {}
	for key, value in original do
		if typeof(value) == "table" then
			copy[key] = deepCopy(value)
		else
			copy[key] = value
		end
	end

	return copy
end

local function copyDefaults()
	return deepCopy(DEFAULT_DATA)
end

local function reconcileData(data, template)
	template = template or DEFAULT_DATA
	for key, value in template do
		if data[key] == nil then
			if typeof(value) == "table" then
				data[key] = deepCopy(value)
			else
				data[key] = value
			end
		elseif typeof(value) == "table" and typeof(data[key]) == "table" then
			reconcileData(data[key], value)
		end
	end
	return data
end

local DataService = {}

--// Tool Handling
function DataService:EquipItem(player: Player, category, itemKey)
	if not self:HasItem(player, category, itemKey) then
		return false
	end

	local data = playerData[player.UserId]
	if not data then
		return false
	end

	data.Equipped[category] = itemKey
	return true
end

--// Player Stat Handling
function DataService:AddStat(player: Player, statName, amount)
	local data = playerData[player.UserId]
	if not data then
		return
	end

	if data.Stats[statName] then
		data.Stats[statName] += amount
	else
		warn("Stat Name not found in player data...")
	end
end

--// Data Handling -- Grabber
function DataService:GetData(player: Player)
	if not loaded[player.UserId] then
		return
	end
	return playerData[player.UserId]
end

--// Currency Handling
function DataService:GetCurrency(player: Player, currency_type)
	local data = playerData[player.UserId]
	if not data then
		return
	end

	return data.Currencies[currency_type]
end

function DataService:AddCurrency(player: Player, currency_type: string, amount: number)
	local data = playerData[player.UserId]
	if not data then
		return
	end
	if data.Currencies[currency_type] then
		data.Currencies[currency_type] += amount
	else
		warn("Currency Type not found.")
	end
end
-------------------------------------------------------//
-------------------------------------------------------//

--// Item Handling
function DataService:AddItem(player: Player, category, itemKey)
	local data = playerData[player.UserId]
	if not data then
		return false
	end

	local itemTable = data.Inventory[category]
	if not itemTable then
		warn("Inventory category not found: " .. tostring(category))
		return false
	end

	local entry = itemTable[itemKey]
	if entry then
		entry.Count = (entry.Count or 0) + 1
		return true
	end
	itemTable[itemKey] = { Count = 1, Acquired = os.time(), Favorited = false, Locked = false }

	return true
end

function DataService:HasItem(player: Player, category, itemKey)
	local data = playerData[player.UserId]
	if not data then
		return false
	end

	local itemTable = data.Inventory[category]
	if not itemTable then
		warn("Inventory category not found: " .. tostring(category))
		return false
	end

	return itemTable[itemKey] ~= nil
end
-------------------------------------------------------//
-------------------------------------------------------//

--// XP Handling
local function xpForLevel(Level)
	return 500 + (Level - 1) * 200
end

function DataService:AddXP(player: Player, amount: number)
	local data = playerData[player.UserId]
	if not data then
		return
	end

	local startLevel = data.Level
	local startXP = data.XP
	local startXPNeeded = xpForLevel(startLevel)

	data.XP += amount

	while data.XP >= xpForLevel(data.Level) do
		data.XP -= xpForLevel(data.Level)
		data.Level += 1
	end

	return startLevel, startXP, startXPNeeded
end

function DataService:xpForLevel(Level)
	return xpForLevel(Level)
end
-------------------------------------------------------//
-------------------------------------------------------//

--// Game Cleanup
function DataService:Cleanup(player: Player)
	playerData[player.UserId] = nil
	loaded[player.UserId] = nil
end
-------------------------------------------------------//
-------------------------------------------------------//

--// DataService Functions
function DataService:Init()
	print("[Data Service] - Init..")
end

function DataService:Start()
	print("[Data Service] - Started..")
	Players.PlayerAdded:Connect(function(player: Player)
		local success, data = pcall(function()
			return playerDataStore:GetAsync(player.UserId)
		end)

		if not success then
			warn("Failed to load data for: " .. player.Name .. " : " .. player.UserId .. data)
			return
		end
		if typeof(data) ~= "table" then
			data = nil
		end

		playerData[player.UserId] = data and reconcileData(data) or copyDefaults()
		loaded[player.UserId] = true

		-- if RunService:IsStudio() then
		-- 	self:AddItem(player, "Knives", "Karambit")
		-- end

		-- self:AddItem(player, "Knives", "DefaultKnife")
		-- self:AddItem(player, "Guns", "DefaultRevolver")
	end)

	Players.PlayerRemoving:Connect(function(player)
		if not loaded[player.UserId] then
			return
		end

		local success, result = pcall(function()
			return playerDataStore:SetAsync(player.UserId, playerData[player.UserId])
		end)

		if not success then
			warn("Failed to set data for: " .. player.Name .. " : " .. player.UserId)
			return
		end

		self:Cleanup(player)
	end)

	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			if not loaded[player.UserId] then
				continue
			end

			local success, result = pcall(function()
				playerDataStore:SetAsync(player.UserId, playerData[player.UserId])
			end)

			if not success then
				warn("Failed to save data for: " .. player.UserId .. " : " .. result)
			end

			self:Cleanup(player)
		end
	end)

	RemoteStorage.GetInventory.OnServerInvoke = function(player)
		local data = self:GetData(player)
		if not data then
			return
		end

		return { Inventory = data.Inventory, Equipped = data.Equipped }
	end

	RemoteStorage.EquipItem.OnServerInvoke = function(player, category, itemKey)
		if typeof(category) ~= "string" then
			warn("Error Occured Fetching Category Type")
			return false
		end

		if typeof(itemKey) ~= "string" then
			warn("Error Occured Fetching Item Type")
			return false
		end

		return self:EquipItem(player, category, itemKey)
	end
end

return DataService
