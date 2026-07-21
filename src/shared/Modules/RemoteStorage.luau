local ReplicatedStorage = game:GetService("ReplicatedStorage") :: ReplicatedStorage

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes") :: Folder
local remoteFunctions = remotesFolder:WaitForChild("RemoteFunctions") :: Folder
local remoteEvents = remotesFolder:WaitForChild("RemoteEvents") :: Folder

return {
	--//Gameplay Handling
	RoleAssigned = remoteEvents:WaitForChild("RoleAssigned") :: RemoteEvent,
	RoundState = remoteEvents:WaitForChild("RoundState") :: RemoteEvent,
	SendRole = remoteEvents:WaitForChild("SendRole") :: RemoteEvent,
	RoundEnded = remoteEvents:WaitForChild("RoundEnded") :: RemoteEvent,
	RoundSummary = remoteEvents:WaitForChild("RoundSummary") :: RemoteEvent,

	--// Currency Handling
	CoinCollected = remoteEvents:WaitForChild("CoinCollected") :: RemoteEvent,

	--/ Timer
	TimerEvent = remoteEvents:WaitForChild("TimerEvent") :: RemoteEvent,
	CurrentState = remoteEvents:WaitForChild("CurrentState") :: RemoteEvent,

	--// Inventory Handling
	GetInventory = remoteFunctions:WaitForChild("GetInventory") :: RemoteFunction,

	--// Weapon Handling
	EquipItem = remoteFunctions:WaitForChild("EquipItem") :: RemoteFunction,
	UseWeapon = remoteEvents:WaitForChild("UseWeapon") :: RemoteEvent,

	--// Weapons
	FireRevolver = remoteEvents:WaitForChild("FireRevolver") :: RemoteEvent,
	SwingKnife = remoteEvents:WaitForChild("SwingKnife") :: RemoteEvent,

	--// Buy Handling
	BuyItem = remoteFunctions:WaitForChild("BuyItem") :: RemoteFunction,

	--// Settings Handling
	GetSettings = remoteFunctions:WaitForChild("GetSettings") :: RemoteFunction,
	SetSetting = remoteEvents:WaitForChild("SetSetting") :: RemoteEvent,
}
