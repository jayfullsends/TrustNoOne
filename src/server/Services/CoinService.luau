local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Framework = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Framework"))

local coin = ServerStorage:WaitForChild("Game"):WaitForChild("Coin") :: MeshPart
local coinsFolder = game.Workspace:WaitForChild("Map"):WaitForChild("Coins")
local spawnPart = workspace:WaitForChild("SpawnPart") :: Part

local CoinService = {}
local DataService

local CURRENCY_AMOUNT = {
	Coin = {
		Name = "Coins",
		Value = 1,
	},
}

--// Coin Handling
local spawning = false
local MAX_COINS = 30
local SPAWN_INTERVAL = 0.35

local function spawnCoin()
	local clone = coin:Clone()
	local collected = false
	clone.Anchored = true
	clone.CanQuery = false
	local randomX = (math.random() - 0.5) * spawnPart.Size.X
	local randomZ = (math.random() - 0.5) * spawnPart.Size.Z
	clone.CFrame = CFrame.new(spawnPart.Position + Vector3.new(randomX, 3, randomZ)) * CFrame.Angles(math.rad(90), 0, 0)

	clone.Touched:Connect(function(hit)
		if collected then
			return
		end

		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end

		collected = true
		DataService:AddCurrency(player, CURRENCY_AMOUNT.Coin.Name, CURRENCY_AMOUNT.Coin.Value)
		clone:Destroy()
	end)

	clone.Parent = coinsFolder
end

function CoinService:StartSpawning()
	if spawning then
		return
	end
	spawning = true
	task.spawn(function()
		while spawning do
			if #coinsFolder:GetChildren() < MAX_COINS then
				spawnCoin()
			end
			task.wait(SPAWN_INTERVAL)
		end
	end)
end

function CoinService:StopSpawning()
	spawning = false
end

function CoinService:ClearCoins()
	for _, c in coinsFolder:GetChildren() do
		c:Destroy()
	end
end

function CoinService:Init()
	print("CoinService Init..")
	DataService = Framework:GetServices("DataService")
end

function CoinService:Start()
	return
end

return CoinService
