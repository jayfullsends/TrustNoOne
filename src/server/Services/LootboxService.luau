local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

--// Modules
local remoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))

--// Configs
local ItemConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("ItemConfig"))
local CrateConfig = require(ReplicatedStorage)

local LootboxService = {}

function LootboxService:OpenCrate(player, crateName) end

function LootboxService:Init()
	print("Lootbox Service Init..")
end

function LootboxService:Start()
	print("LootboxService Started..")
end

return LootboxService
