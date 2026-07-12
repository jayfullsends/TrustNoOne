local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local adminUI = ServerStorage:WaitForChild("AdminUI")

local GROUP_ID = 69253326

local COMMANDS = {
	--// 255 — Owner only (irreversible / economy / server-wide / fairness)
	-- resetAllData    = { minRank = 255 }, -- wipes EVERYONE's data
	resetPlayerData = { minRank = 255 }, -- wipes one player's progress
	Shutdown = { minRank = 255 }, -- kills the server for everyone
	giveCoins = { minRank = 255 }, -- economy
	setCoins = { minRank = 255 },
	giveXP = { minRank = 255 },
	setLevel = { minRank = 255 },
	giveItem = { minRank = 255 }, -- bypasses monetization
	setRole = { minRank = 255 }, -- affects round fairness
	giveWeapon = { minRank = 255 }, -- arming a player mid-round
	forceStartRound = { minRank = 255 }, -- disrupts everyone's game
	endRound = { minRank = 255 },
	skipPhase = { minRank = 255 },

	--// 254 — Admin (moderation, reversible, scoped to one player)
	kick = { minRank = 254 },
	ban = { minRank = 254 }, -- needs a ban DataStore
	unban = { minRank = 254 },
	mute = { minRank = 254 }, -- needs chat-service hooks
	unmute = { minRank = 254 },
	teleportTo = { minRank = 254 },
	bring = { minRank = 254 },
	freeze = { minRank = 254 },
	unfreeze = { minRank = 254 },
	respawn = { minRank = 254 },
	announce = { minRank = 254 },
	players = { minRank = 254 }, -- read-only info
}
