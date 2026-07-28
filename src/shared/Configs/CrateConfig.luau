local CrateConfig = {
	ShadowCrate = {
		Name = "Shadow Crate",
		Category = "Knives",
		Order = 1,
		Image = "rbxassetid://113243012575930",
		Description = "A crate forged in darkness, contains a deadly surprise..",
		Price = 1000,
		Pool = {
			Butterfly = { Weight = 50 },
			Karambit = { Weight = 25 },
			ShadowBlade = { Weight = 12.5 },
			GoldenKnife = { Weight = 8.5 },
			TrustBlade = { Weight = 4 },
		},
	},

	IroncladCrate = {
		Name = "Ironclad Crate",
		Category = "Knives",
		Order = 2,
		Image = "rbxassetid://0",
		Description = "Just a crate",
		Price = 1000,
		Pool = {},
	},

	ChaosCrate = {
		Name = "Chaos Crate",
		Category = "Knives",
		Order = 3,
		Image = "rbxassetid://0",
		Description = "a crate i think :p",
		Price = 1000,
		Pool = {},
	},

	-- ClassicCrate = {
	-- 	Name = "Classic Crate",
	-- 	Category = "Knives",
	-- 	Image = "rbxassetid://0",
	-- 	Description = "",
	-- 	Price = 500,
	-- 	Pool = {
	-- 		Karambit = { Weight = 50 },
	-- 		Butterfly = { Weight = 50 },
	-- 	},
	-- },
	-- LegendaryCrate = {
	-- 	Name = "Legendary Crate",
	-- 	Category = "Knives",
	-- 	Image = "rbxassetid://0",
	-- 	Description = "",
	-- 	Price = 1000,
	-- 	Pool = {
	-- 		ShadowBlade = { Weight = 60 },
	-- 		GoldenKnife = { Weight = 30 },
	-- 		TrustBlade = { Weight = 10 },
	-- 	},
	-- },
}

return CrateConfig
