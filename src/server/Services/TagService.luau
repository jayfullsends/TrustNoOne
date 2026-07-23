local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local playerIDs = require(ServerStorage.Configs.PlayerIDs)

local nameTag = ServerStorage:WaitForChild("Template"):WaitForChild("Nametag")

local TagService = {}

local function isAllowed(player: Player)
	return playerIDs[player.UserId] ~= nil
end

local function setupTag(player: Player)
	if isAllowed(player) then
		local character = player.Character
		if not character then
			warn("No character found")
			return
		end

		local clone = nameTag:Clone()
		clone.TextLabel.Text = playerIDs[player.UserId].Tag
		clone.TextLabel.TextColor3 = playerIDs[player.UserId].Color
		clone.Parent = character
		clone.Adornee = character:FindFirstChild("Head")
	end
end

function TagService:Init()
	print("TagService Init..")
end

function TagService:Start()
	-- print("TagService Started..")
	-- local function onPlayerAdded(player: Player)
	-- 	player.CharacterAdded:Connect(function()
	-- 		setupTag(player)
	-- 	end)

	-- 	if player.Character then
	-- 		setupTag(player)
	-- 	end
	-- end

	-- Players.PlayerAdded:Connect(onPlayerAdded)

	-- for _, player in Players:GetPlayers() do
	-- 	onPlayerAdded(player)
	-- end
end

return TagService
