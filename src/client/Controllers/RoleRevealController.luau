local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local gameRolesConfig = require(ReplicatedStorage:WaitForChild("Configs"):WaitForChild("GameRolesConfig"))
local remoteStorage = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("RemoteStorage"))

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui") :: PlayerGui

--// UI
local gui = PlayerGui:WaitForChild("RoleReveal") :: ScreenGui
local Mainframe = gui:WaitForChild("Mainframe") :: Frame
local ContentFrame = Mainframe:WaitForChild("ContentFrame") :: Frame
local YourRoleFrame = ContentFrame:WaitForChild("YourRoleFrame") :: Frame
local DiamondOutsideBorder = ContentFrame:WaitForChild("DiamondOutsideBorder") :: ImageLabel
local DiamondInsideBorder = DiamondOutsideBorder:WaitForChild("DiamondInsideBorder") :: ImageLabel
local WeaponImage = DiamondInsideBorder:WaitForChild("WeaponImage") :: ImageLabel

local RoleLabel = ContentFrame:WaitForChild("RoleLabel") :: TextLabel
local RoleTextLabel = YourRoleFrame:WaitForChild("RoleTextLabel") :: TextLabel
local RoleDescription = ContentFrame:WaitForChild("RoleDescription") :: TextLabel

local soundsFolder = gui:WaitForChild("Sounds")
local uiAppear = soundsFolder:WaitForChild("ui_appear") :: Sound
local suspenseSound = soundsFolder:WaitForChild("suspense") :: Sound

local roleSound = soundsFolder:WaitForChild("RoleSound")

local RoleRevealController = {}

function RoleRevealController:Init()
	print("[RR] Init..")
end

function RoleRevealController:Start()
	print("[RR] Started..")

	remoteStorage.SendRole.OnClientEvent:Connect(function(ROLE)
		local config = gameRolesConfig[ROLE]
		if not config then
			return
		end

		local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		local tween = TweenService:Create(Mainframe, tweenInfo, { GroupTransparency = 0 })
		local tweenOut = TweenService:Create(Mainframe, tweenInfo, { GroupTransparency = 1 })

		Mainframe.BackgroundColor3 = config.MainColor
		RoleLabel.TextColor3 = config.MainColor
		RoleDescription.Text = config.Description
		RoleLabel.Text = config.Name

		DiamondOutsideBorder.Image = config.DiamondOutsideBorder
		DiamondInsideBorder.Image = config.DiamondInsideBorder
		WeaponImage.Image = config.Icon
		roleSound.SoundId = config.Sound

		--suspenseSound:Play()
		tween:Play()
		tween.Completed:Wait()
		roleSound:Play()

		task.wait(3)

		tweenOut:Play()
	end)
end

return RoleRevealController
