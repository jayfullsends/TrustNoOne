local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local remoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))

local LootboxService = {}

function LootboxService:Init()
	print("Lootbox Service Init..")
end

function LootboxService:Start()
	print("LootboxService Started..")
end

return LootboxService
