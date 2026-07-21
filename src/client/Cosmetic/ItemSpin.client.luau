local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local TAG = "MuseumDisplay"
local DEGREES_PER_SECOND = 90

local spinningItems = {}

local function addItem(item)
	spinningItems[item] = true
end

local function removeItem(item)
	spinningItems[item] = nil
end

for _, item in CollectionService:GetTagged(TAG) do
	addItem(item)
end

CollectionService:GetInstanceAddedSignal(TAG):Connect(addItem)
CollectionService:GetInstanceRemovedSignal(TAG):Connect(removeItem)

RunService.Heartbeat:Connect(function(dt)
	local step = math.rad(DEGREES_PER_SECOND * dt)
	local rotation = CFrame.Angles(0, step, 0)

	for item in spinningItems do
		if item:IsA("BasePart") then
			local cf = item.CFrame
			item.CFrame = CFrame.new(cf.Position) * rotation * cf.Rotation
		elseif item:IsA("Model") then
			local pivot = item:GetPivot()
			item:PivotTo(CFrame.new(pivot.Position) * rotation * pivot.Rotation)
		end
	end
end)
