local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Framework = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Framework"))

local XP_REWARDS = {
	Played = 25,
	Survived = 60,
	Win = 100,
	PerKill = 45,
}

local StatsService = {}
local DataService

local stats = {}

--// Non Self Functions
local function increment(userId, stat, amount)
	if not stats[userId] then
		stats[userId] = { Kills = 0, Shots = 0 }
	end
	stats[userId][stat] += amount
end

function StatsService:AwardPlayer(player: Player, context)
	local roundStats = self:GetStats(player)

	local xp = XP_REWARDS.Played
	if context.survived then
		xp += XP_REWARDS.Survived
	end
	if context.won then
		xp += XP_REWARDS.Win
	end
	xp += roundStats.Kills * XP_REWARDS.PerKill

	local startLevel, startXP, startXPNeeded = DataService:AddXP(player, xp)

	local data = DataService:GetData(player)
	if not data then
		return {
			earned = xp,
			level = 1,
			currentXP = 0,
			xpNeeded = 1000,
			kills = roundStats.Kills,
			shots = roundStats.Shots,
		}
	end

	DataService:AddStat(player, "RoundsPlayed", 1)

	if context.won then
		DataService:AddStat(player, "Wins", 1)
	end
	DataService:AddStat(player, "ShotsFired", roundStats.Shots)

	if context.role == "Murderer" then
		DataService:AddStat(player, "MurdererKills", roundStats.Kills)
	end

	return {
		earned = xp,
		level = data.Level,
		startLevel = startLevel,
		startXP = startXP,
		startXPNeeded = startXPNeeded,
		currentXP = data.XP,
		xpNeeded = DataService:xpForLevel(data.Level),
		kills = roundStats.Kills,
		shots = roundStats.Shots,
	}
end

--// Progression Functions
function StatsService:AddKill(player: Player)
	increment(player.UserId, "Kills", 1)
end

function StatsService:AddShot(player: Player)
	increment(player.UserId, "Shots", 1)
end

function StatsService:GetStats(player: Player)
	return stats[player.UserId] or { Kills = 0, Shots = 0 }
end

function StatsService:Reset()
	stats = {}
end

--// Default Init -- Start

function StatsService:Init()
	DataService = Framework:GetServices("DataService")
end

function StatsService:Start()
	return
end

return StatsService
