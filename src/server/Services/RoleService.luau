local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players") :: Players

local RemoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))

local RoleService = {}

RoleService.Roles = {
	Murderer = {
		description = "Find and eliminate all players before the timer runs out!",
		max = 1,
	},

	Sheriff = {
		description = "Use your weapon to eliminate the murderer..",
		max = 1,
	},

	Innocent = {
		description = "Hide until the timer runs out!",
		max = nil,
	},
}

local PlayerRoles = {}

function RoleService:AssignRoles(player_list)
	local roles = {}
	local availableRoles = {}

	for _, player in player_list do
		table.insert(availableRoles, player)
	end

	for i = #availableRoles, 2, -1 do
		local j = math.random(1, i)
		availableRoles[i], availableRoles[j] = availableRoles[j], availableRoles[i]
	end

	for i = 3, #availableRoles do
		roles[availableRoles[i].UserId] = "Innocent"
	end

	roles[availableRoles[1].UserId] = "Murderer"
	roles[availableRoles[2].UserId] = "Sheriff"

	PlayerRoles = roles

	return roles
end

function RoleService:GetRole(player: Player)
	return PlayerRoles[player.UserId]
end

function RoleService:SendRole(player: Player)
	local PLAYER_ROLE = PlayerRoles[player.UserId]
	RemoteStorage.SendRole:FireClient(player, PLAYER_ROLE)
end

function RoleService:Lookup()
	local innocents = {}
	local Murderer
	local Sheriff

	for UserID, roleName in PlayerRoles do
		if roleName == "Murderer" then
			Murderer = UserID
		elseif roleName == "Sheriff" then
			Sheriff = UserID
		else
			table.insert(innocents, UserID)
		end
	end

	return innocents, Murderer, Sheriff
end

function RoleService:Init()
	print("[Role Service] Init..")
end

function RoleService:Start()
	print("[Role Service] Started..")
end

return RoleService
