local Players = game:GetService("Players") :: Players
local ReplicatedStorage = game:GetService("ReplicatedStorage") :: ReplicatedStorage

--// Modules
local Framework = require(ReplicatedStorage.Modules.Framework)
local RoleService = require(script.Parent:WaitForChild("RoleService"))
local remoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))
local gameStates = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameStates"))

local gameSpawns = workspace.Map.Spawns:GetChildren()

--// Game Variables
--// Start
local MIN_PLAYERS = 3
local INTERMISSION_TIME = 5

--// Main
local ROUND_DURATION = 180
local CURRENT_STATE
local ROUND_WINNER

--// Round Tables
local PLAYERS_PLAYING
local ROUND_PARTICIPANTS
local results

local GameService = {}
local CombatService
local StatsService

local function setState(stateName)
	CURRENT_STATE = stateName
	remoteStorage.CurrentState:FireAllClients(CURRENT_STATE)
	print("Remote Fired!")
end

local function didThisRoleWin(role, winner)
	if role == "Murderer" then
		return winner == "Murderer"
	else
		return winner == "Innocent"
	end
end

function GameService:TeleportPlayers()
	for i, player in PLAYERS_PLAYING do
		local character = player.Character
		if not character then
			continue
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then
			continue
		end

		if not gameSpawns[i] then
			continue
		end
		humanoidRootPart.CFrame = gameSpawns[i].CFrame + Vector3.new(0, 3, 0)
	end
end

function GameService:GetState()
	return CURRENT_STATE
end

function GameService:Init()
	print("[Game Service] - Init..")
	CombatService = Framework:GetServices("CombatService")
	StatsService = Framework:GetServices("StatsService")
end

function GameService:PlayerKilled(victim)
	local player_killed = table.find(PLAYERS_PLAYING, victim)
	if not player_killed then
		return
	end

	local player_role = RoleService:GetRole(victim)
	table.remove(PLAYERS_PLAYING, player_killed)

	if ROUND_WINNER then
		return
	end

	CombatService:DropGun(victim)

	if player_role == "Murderer" then
		ROUND_WINNER = "Innocent"
	else
		for _, player in PLAYERS_PLAYING do
			if RoleService:GetRole(player) ~= "Murderer" then
				return
			end
		end
		ROUND_WINNER = "Murderer"
	end
end

function GameService:Start()
	print("[Game Service] - Started..")
	while true do
		local ok, err = pcall(function()
			if #Players:GetPlayers() < MIN_PLAYERS then
				setState(gameStates.Waiting)
				task.wait(1)
				return
			end

			ROUND_WINNER = nil
			StatsService:Reset()
			PLAYERS_PLAYING = {}
			results = {}
			ROUND_PARTICIPANTS = {}
			CombatService:ResetArmedPlayers()
			setState(gameStates.Intermission)

			for i = INTERMISSION_TIME, 0, -1 do
				remoteStorage.TimerEvent:FireAllClients("Intermission_Countdown", i)
				if i == 0 then
					remoteStorage.TimerEvent:FireAllClients("Round_Starting", "Round Starting..")
					for _, player in Players:GetPlayers() do
						table.insert(ROUND_PARTICIPANTS, player)
						table.insert(PLAYERS_PLAYING, player)
					end
				end
				task.wait(1)
			end

			setState(gameStates.Active)
			self:TeleportPlayers()

			RoleService:AssignRoles(ROUND_PARTICIPANTS)

			for _, player in PLAYERS_PLAYING do
				if not player then
					continue
				end
				RoleService:SendRole(player)
			end

			for i = 10, 1, -1 do
				remoteStorage.TimerEvent:FireAllClients("Giving_Tools", "Giving Tools In : " .. i .. " Seconds!")
				task.wait(1)
			end

			for _, player in PLAYERS_PLAYING do
				CombatService:GiveWeapon(player, RoleService:GetRole(player))
			end

			for i = ROUND_DURATION, 0, -1 do
				remoteStorage.TimerEvent:FireAllClients("Round_Countdown", i)
				task.wait(1)

				if ROUND_WINNER then
					break
				end
			end

			if not ROUND_WINNER then
				ROUND_WINNER = "Innocent"
			end

			for _, player in ROUND_PARTICIPANTS do
				local role = RoleService:GetRole(player)
				local survived = table.find(PLAYERS_PLAYING, player) ~= nil
				local won = didThisRoleWin(role, ROUND_WINNER)

				results[player.UserId] = StatsService:AwardPlayer(player, { won = won, survived = survived })
			end

			local innocents, murderer, sheriff = RoleService:Lookup()

			for _, player in ROUND_PARTICIPANTS do
				local r = results[player.UserId]
				remoteStorage.RoundEnded:FireClient(player, {
					winner = ROUND_WINNER,
					murderer = murderer,
					sheriff = sheriff,
					innocents = innocents,
					earned = r.earned,
					level = r.level,
					currentXP = r.currentXP,
					xpNeeded = r.xpNeeded,
				})
			end

			setState(gameStates.Ending)

			task.wait(3)

			for _, player in PLAYERS_PLAYING do
				player:LoadCharacterAsync()
			end

			task.wait(5)
			PLAYERS_PLAYING = {}
			ROUND_PARTICIPANTS = {}
			results = {}
			CombatService:ResetArmedPlayers()
			StatsService:Reset()
			ROUND_WINNER = nil
		end)

		if not ok then
			warn("GameService Failed due to : " .. err)
			task.wait(3)
		end
	end
end

return GameService
