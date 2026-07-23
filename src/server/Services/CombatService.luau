local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TouchInputService = game:GetService("TouchInputService")
local RunService = game:GetService("RunService") :: RunService

local itemConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("ItemConfig"))

local GameStates = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("GameStates"))
local remoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))
local Framework = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Framework"))

local knivesFolder = ServerStorage.Tools.Knives
local gunsFolder = ServerStorage.Tools.Guns
local revolverPickup = ServerStorage:WaitForChild("Tools"):WaitForChild("RevolverPickup")

local WEAPONS = {
	Knife = {
		SWING_COOLDOWN = 0.75,
		Range = 4,
	},

	Revolver = {
		FIRE_COOLDOWN = 3,
		Range = 150,
	},
}

local DEFAULT_ITEMS = {
	Knives = "DefaultKnife",
	Guns = "DefaultRevolver",
}

--// Module Sevices
local CombatService = {}
local GameService
local RoleService
local StatsService
local DataService

--// Weapon Handling
local cooldowns = {}
local armed = {}
local droppedGun

function CombatService:Init()
	print("[Combat Service Init..]")
	GameService = Framework:GetServices("GameService")
	RoleService = Framework:GetServices("RoleService")
	StatsService = Framework:GetServices("StatsService")
	DataService = Framework:GetServices("DataService")
end

function CombatService:ResetArmedPlayers()
	armed = {}
	if droppedGun then
		droppedGun:Destroy()
		droppedGun = nil
	end
end

local function getEquippedTool(player: Player, category, folder, defaultKey)
	local playerData = DataService:GetData(player)
	if not playerData then
		return
	end

	local itemKey = playerData.Equipped[category] or defaultKey
	if not itemKey then
		return
	end

	local info = itemConfig[itemKey]
	if not info then
		itemKey = defaultKey
	end

	info = itemConfig[itemKey]

	if itemConfig[itemKey] == nil then
		warn("Key name mismatch..")
		return
	end

	local clone = folder:FindFirstChild(info.ModelName)
	if not clone then
		warn("No tool found in the folder..")
		return
	end

	return clone:Clone()
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

		local tool = getEquippedTool(player, "Guns", gunsFolder, DEFAULT_ITEMS.Guns)
		if not tool then
			return
		end

		pickedUp = true

		tool.Parent = player.Backpack
		armed[player.UserId] = true
		clone:Destroy()
		droppedGun = nil
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
		local clone = getEquippedTool(player, "Knives", knivesFolder, DEFAULT_ITEMS.Knives)

		if clone then
			clone.Parent = player.Backpack or player.Character
		end
	elseif role == "Sheriff" then
		local clone = getEquippedTool(player, "Guns", gunsFolder, DEFAULT_ITEMS.Guns)

		if clone then
			clone.Parent = player.Backpack or player.Character
			armed[player.UserId] = true
		end
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

		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { char }

		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then
			return
		end

		local playersKnifeTool = char:FindFirstChildOfClass("Tool")
		if not playersKnifeTool then
			warn("You don't have a knife!?")
			return
		end

		-- local knifeSound = knife:WaitForChild("BlueHandle"):WaitForChild("HitSound") :: Sound
		-- if not knifeSound then
		-- 	return
		-- end

		if RoleService:GetRole(player) ~= "Murderer" then
			return
		end

		if GameService:GetState() ~= GameStates.Active then
			return
		end

		local parts = workspace:GetPartBoundsInRadius(hrp.Position, WEAPONS.Knife.Range)

		local closestDistance = math.huge
		local closestTarget

		for _, part: Part in parts do
			local playerModel = part:FindFirstAncestorOfClass("Model")

			local hitPlayer = Players:GetPlayerFromCharacter(playerModel)
			if not hitPlayer then
				continue
			end

			if playerModel == char then
				continue
			end

			local HitPlayerHRP = playerModel:FindFirstChild("HumanoidRootPart")
			if not HitPlayerHRP then
				continue
			end

			local toTarget = HitPlayerHRP.Position - hrp.Position
			local distance = toTarget.Magnitude

			local raycast = workspace:Raycast(hrp.Position, toTarget, raycastParams)
			if not raycast then
				continue
			end

			local playerHit = raycast.Instance:IsDescendantOf(playerModel)

			if not playerHit then
				continue
			end

			if distance < closestDistance then
				closestDistance = distance
				closestTarget = Players:GetPlayerFromCharacter(playerModel)
			end
		end
		if closestTarget then
			local humanoid = closestTarget.Character:FindFirstChildWhichIsA("Humanoid")
			if humanoid and humanoid.Health > 0 then
				humanoid:TakeDamage(100)
				GameService:PlayerKilled(closestTarget)
				StatsService:AddKill(player)
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

		local equippedRevolver = char:FindFirstChildOfClass("Tool")
		if not equippedRevolver then
			warn("You don't have a revolver..")
			return
		end
		local muzzle = equippedRevolver:FindFirstChild("Muzzle") :: Part
		if not muzzle then
			warn("Weapon has no muzzle...")
			return
		end

		local sound = muzzle:FindFirstChild("Shot") :: Sound
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
			StatsService:AddKill(player)
			GameService:PlayerKilled(hitPlayer)
			local humanoid = model:FindFirstChildWhichIsA("Humanoid")
			if humanoid then
				humanoid:TakeDamage(100)
			end
		elseif RoleService:GetRole(hitPlayer) == "Innocent" then
			GameService:PlayerKilled(hitPlayer)
			GameService:PlayerKilled(player)

			local hitPlayerHum = model:FindFirstChildWhichIsA("Humanoid")
			if hitPlayerHum then
				hitPlayerHum:TakeDamage(100)
			end

			local shooterHum = char:FindFirstChildWhichIsA("Humanoid")

			if shooterHum then
				shooterHum:TakeDamage(100)
			end
		end
	end)
end

return CombatService
