local ReplicatedStorage = game:GetService("ReplicatedStorage") :: ReplicatedStorage

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local remoteFunctions = remotesFolder:WaitForChild("RemoteFunctions") :: Folder
local remoteEvents = remotesFolder:WaitForChild("RemoteEvents") :: Folder

return {
	--//Gameplay Handling
	SendRole = remoteEvents:WaitForChild("SendRole") :: RemoteEvent,
	RoundEnded = remoteEvents:WaitForChild("RoundEnded") :: RemoteEvent,

	--/ Timer
	TimerEvent = remoteEvents:WaitForChild("TimerEvent") :: RemoteEvent,
	CurrentState = remoteEvents:WaitForChild("CurrentState") :: RemoteEvent,

	--// Inventory Handling
	GetInventory = remoteFunctions:WaitForChild("GetInventory") :: RemoteFunction,

	--// Weapon Handling
	EquipItem = remoteFunctions:WaitForChild("EquipItem") :: RemoteFunction,

	--// Weapons
	FireRevolver = remoteEvents:WaitForChild("FireRevolver") :: RemoteEvent,
	SwingKnife = remoteEvents:WaitForChild("SwingKnife") :: RemoteEvent,

	--// Buy Handling
	BuyItem = remoteFunctions:WaitForChild("BuyItem") :: RemoteFunction,

	--// Settings Handling
	GetSettings = remoteFunctions:WaitForChild("GetSettings") :: RemoteFunction,
	SetSetting = remoteEvents:WaitForChild("SetSetting") :: RemoteEvent,

	--// Crate Handling
	OpenCrate = remoteFunctions:WaitForChild("OpenCrate") :: RemoteFunction,
}
