local RunService = game:GetService("RunService")

local coinsFolder = game.Workspace:WaitForChild("Map"):WaitForChild("Coins")

RunService.Heartbeat:Connect(function(dt)
	local coins = coinsFolder:GetChildren()
	for _, coin in coins do
		coin.CFrame = coin.CFrame * CFrame.Angles(0, 0, math.rad(90) * dt)
	end
end)
