local Players = game:GetService("Players") :: Players
local ReplicatedStorage = game:GetService("ReplicatedStorage") :: ReplicatedStorage
local ServerStorage = game:GetService("ServerStorage") :: ServerStorage
local DataStoreService = game:GetService("DataStoreService") :: DataStoreService

--// DataStore
local playerDataStore = DataStoreService:GetDataStore("PlayerData_V1")

--// Variables

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
	Owned = {},
	Equipped = {
		Knife = nil,
		Gun = nil,
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
	for key, value in DEFAULT_DATA do
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

local function xpForLevel(Level)
	return 500 + (Level - 1) * 200
end

local DataService = {}

function DataService:GetCurrency(player: Player, currency_type)
	local data = playerData[player.UserId]
	return data.Currencies[currency_type]
end

function DataService:GetData(player: Player)
	if not loaded[player.UserId] then
		return
	end
	return playerData[player.UserId]
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

function DataService:AddXP(player: Player, amount: number)
	local data = playerData[player.UserId]
	if not data then
		return
	end
	data.XP += amount

	while data.XP >= xpForLevel(data.Level) do
		data.XP -= xpForLevel(data.Level)
		data.Level += 1
	end
end

function DataService:Cleanup(player: Player)
	playerData[player.UserId] = nil
	loaded[player.UserId] = nil
end

function DataService:xpForLevel(Level)
	return xpForLevel(Level)
end

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
end

return DataService
