local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))

local player = Players.LocalPlayer

local mouse = player:GetMouse()
local debounce = false

local TOOL_DELAYS = {
	Knives = { Cooldown = 0.75, AnimationID = "rbxassetid://101223579158877" },
	Guns = { Cooldown = 3 },
}

local WeaponController = {}

function WeaponController:Init()
	return
end

function WeaponController:Start()
	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		if not humanoid then
			return
		end

		local tracks = {}

		local animator = humanoid:WaitForChild("Animator") :: Animator
		if not animator then
			return
		end

		for category, config in TOOL_DELAYS do
			if config.AnimationID then
				local animation = Instance.new("Animation")
				animation.AnimationId = config.AnimationID
				tracks[category] = animator:LoadAnimation(animation)
			end
		end

		local knifeTrack = tracks["Knives"]
		if knifeTrack then
			knifeTrack:GetMarkerReachedSignal("Hit"):Connect(function()
				RemoteStorage.SwingKnife:FireServer()
			end)
		end

		character.ChildAdded:Connect(function(child)
			if child:IsA("Tool") then
				local category = child:GetAttribute("Category")
				if not category then
					warn("No category found")
					return
				end

				local track = tracks[category]

				child.Activated:Connect(function()
					if debounce then
						return
					end

					if category == "Knives" then
						if track then
							track:Play()
						end

						debounce = true
						task.wait(TOOL_DELAYS[category].Cooldown)
						debounce = false
					elseif category == "Guns" then
						debounce = true
						RemoteStorage.FireRevolver:FireServer(mouse.Hit.Position)
						task.wait(TOOL_DELAYS[category].Cooldown)
						debounce = false
					end
				end)
			end
		end)
	end

	player.CharacterAdded:Connect(onCharacterAdded)

	if player.Character then
		onCharacterAdded(player.Character)
	end
end

return WeaponController
