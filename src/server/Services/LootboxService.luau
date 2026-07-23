local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Modules
local Framework = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Framework"))
local RemoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))

--// Configs
local ItemConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("ItemConfig"))
local CrateConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("CrateConfig"))

--// Services
local DataService

local LootboxService = {}

local function roll(pool)
	local total = 0

	for key, value in pool do
		total += value.Weight
	end

	local randomNum = math.random() * total

	for key, value in pool do
		randomNum -= value.Weight

		if randomNum <= 0 then
			return key
		end
	end
end

function LootboxService:OpenCrate(player: Player, crateName: string)
	local playerCoins = DataService:GetCurrency(player, "Coins")
	if not playerCoins then
		warn("Failed to find players coins..")
		return
	end

	local chosenCrate = CrateConfig[crateName]
	if not chosenCrate then
		warn("Failed to find crate..")
		return
	end

	local chosenCratePrice = chosenCrate.Price
	local cratesPoll = chosenCrate.Pool

	if playerCoins >= chosenCratePrice then
		local result = roll(cratesPoll)
		if not result then
			return
		end

		local info = ItemConfig[result]
		if not info then
			warn("Rolley key not in ItemConfig: " .. tostring(result))
			return
		end

		local addItem = DataService:AddItem(player, info.Category, result)

		if addItem then
			DataService:AddCurrency(player, "Coins", -chosenCratePrice)
			return result
		end
	end

	return false
end

function LootboxService:Init()
	DataService = Framework:GetServices("DataService")
end

function LootboxService:Start()
	print("LootboxService Started..")

	RemoteStorage.OpenCrate.OnServerInvoke = function(player, crateName)
		if typeof(crateName) ~= "string" then
			warn("CrateType doesn't exist..")
			return
		end

		return self:OpenCrate(player, crateName)
	end
end

return LootboxService
