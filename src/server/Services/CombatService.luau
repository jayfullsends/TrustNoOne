local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService") :: RunService

local GameStates = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameStates"))
local remoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))
local Framework = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Framework"))

local knife = ServerStorage:WaitForChild("Tools"):WaitForChild("Knife")
local revolver = ServerStorage:WaitForChild("Tools"):WaitForChild("Revolver")
local revolverPickup = ServerStorage:WaitForChild("Tools"):WaitForChild("RevolverPickup")

local WEAPONS = {
	Knife = {
		SWING_COOLDOWN = 0.75,
		Range = 3,
	},

	Revolver = {
		FIRE_COOLDOWN = 3,
		Range = 150,
	},
}

--// Module Sevices
local CombatService = {}
local GameService
local RoleService
local StatsService

--// Weapon Handling
local cooldowns = {}
local armed = {}
local droppedGun

function CombatService:Init()
	print("[Combat Service Init..]")
	GameService = Framework:GetServices("GameService")
	RoleService = Framework:GetServices("RoleService")
	StatsService = Framework:GetServices("StatsService")
end

function CombatService:ResetArmedPlayers()
	armed = {}
	if droppedGun then
		droppedGun:Destroy()
		droppedGun = nil
	end
end

function CombatService:DropGun(victim: Player)
	if not armed[victim.UserId] then
		return
	end
	armed[victim.UserId] = nil

	local character = victim.Character
	if not character then
		return
	end

	local clone = revolverPickup:Clone() :: Model
	clone:PivotTo(character:GetPivot())
	droppedGun = clone

	local pickedUp = false

	local function onTouch(hit)
		if pickedUp then
			return
		end
		local char = hit:FindFirstAncestorOfClass("Model") :: Model
		local player = Players:GetPlayerFromCharacter(char)
		if not player then
			return
		end

		if player == victim then
			return
		end

		if RoleService:GetRole(player) == "Murderer" then
			return
		end
		if GameService:GetState() ~= GameStates.Active then
			return
		end

		pickedUp = true
		local tool = revolver:Clone()
		tool.Parent = player.Backpack
		armed[player.UserId] = true
		clone:Destroy()
	end

	for _, part in clone:GetChildren() do
		if part:IsA("BasePart") then
			part.Touched:Connect(onTouch)
		end
	end

	local spin = RunService.Heartbeat:Connect(function(dt)
		clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, math.rad(90) * dt, 0))
	end)

	clone.Destroying:Connect(function()
		spin:Disconnect()
	end)

	clone.Parent = workspace
end

function CombatService:GiveWeapon(player: Player, role: string)
	if role == "Murderer" then
		local clone = knife:Clone()
		clone.Parent = player.Backpack or player.Character
	elseif role == "Sheriff" then
		local clone = revolver:Clone()
		clone.Parent = player.Backpack or player.Character
		armed[player.UserId] = true
	end
end

function CombatService:Start()
	remoteStorage.SwingKnife.OnServerEvent:Connect(function(player: Player)
		local now = os.clock()
		if now - (cooldowns[player.UserId] or 0) < WEAPONS.Knife.SWING_COOLDOWN then
			return
		end
		cooldowns[player.UserId] = now

		local char = player.Character
		if not char then
			return
		end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		local knife = char:FindFirstChildOfClass("Tool")
		if not knife then
			warn("You don't have a knife!?")
			return
		end

		local knifeSound = knife:WaitForChild("BlueHandle"):WaitForChild("HitSound") :: Sound
		if not knifeSound then
			return
		end

		if RoleService:GetRole(player) ~= "Murderer" then
			return
		end

		if GameService:GetState() ~= GameStates.Active then
			return
		end

		local parts = workspace:GetPartBoundsInRadius(hrp.Position, WEAPONS.Knife.Range)

		local hit = {}
		for _, part: Part in parts do
			local playerModel = part:FindFirstAncestorOfClass("Model")

			local hitPlayer = Players:GetPlayerFromCharacter(playerModel)
			if not hitPlayer then
				continue
			end

			local humanoid = playerModel:FindFirstChildWhichIsA("Humanoid") :: Humanoid
			if humanoid == player.Character:FindFirstChild("Humanoid") then
				continue
			end

			if humanoid and not hit[humanoid] then
				hit[humanoid] = true
				StatsService:AddKill(player)
				humanoid:TakeDamage(100)
				knifeSound:Play()
				GameService:PlayerKilled(hitPlayer)
			end
		end
	end)

	remoteStorage.FireRevolver.OnServerEvent:Connect(function(player: Player, MousePos)
		if typeof(MousePos) ~= "Vector3" then
			return
		end

		local char = player.Character
		if not char then
			return
		end

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		local revolver = char:FindFirstChildOfClass("Tool")
		if not revolver then
			warn("You don't have a revolver..")
			return
		end
		local muzzle = revolver:FindFirstChild("Muzzle") :: Part
		if not muzzle then
			warn("Weapon has no muzzle...")
			return
		end

		local sound = muzzle:WaitForChild("Shot") :: Sound
		if not sound then
			warn("No Sound Found!")
			return
		end

		if not armed[player.UserId] then
			return
		end

		if GameService:GetState() ~= GameStates.Active then
			return
		end

		local now = os.clock()
		if now - (cooldowns[player.UserId] or 0) < WEAPONS.Revolver.FIRE_COOLDOWN then
			return
		end
		cooldowns[player.UserId] = now

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { char }

		local raycast = workspace:Raycast(
			muzzle.Position,
			(MousePos - muzzle.Position).Unit * WEAPONS.Revolver.Range,
			raycastParams
		)

		if not raycast then
			return
		end

		local endPos = raycast.Position
		local distance = (endPos - muzzle.Position).Magnitude
		local midpoint = (muzzle.Position + endPos) / 2

		local beam = Instance.new("Part")
		beam.Color = Color3.fromRGB(255, 255, 255)
		beam.Material = Enum.Material.Neon
		beam.Anchored = true
		beam.CanCollide = false
		beam.CanQuery = false
		beam.CanTouch = false
		beam.Size = Vector3.new(0.2, 0.2, distance)
		beam.CFrame = CFrame.lookAt(midpoint, endPos)
		beam.Parent = workspace
		Debris:AddItem(beam, 0.1)

		sound:Play()
		StatsService:AddShot(player)

		local hitPart = raycast.Instance
		local model = hitPart:FindFirstAncestorOfClass("Model") :: Model
		local hitPlayer = Players:GetPlayerFromCharacter(model)
		if not hitPlayer then
			return
		end

		if RoleService:GetRole(hitPlayer) == "Murderer" then
			local humanoid = model:FindFirstChild("Humanoid") :: Humanoid
			humanoid:TakeDamage(100)
			GameService:PlayerKilled(hitPlayer)
		elseif RoleService:GetRole(hitPlayer) == "Innocent" then
			local hitPlayerHum = model:FindFirstChild("Humanoid") :: Humanoid
			GameService:PlayerKilled(hitPlayer)
			hitPlayerHum:TakeDamage(100)
			char:FindFirstChild("Humanoid"):TakeDamage(100)
			GameService:PlayerKilled(player)
		end
	end)
end

return CombatService
