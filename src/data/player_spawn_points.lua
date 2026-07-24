local PlayerSpawnPoints = {}
local G = Enums.game_state

PlayerSpawnPoints[G.Outside] = {
	default = { 800, 258 },
	[G.Menu] = { 800, 258 },
	[G.StorageRoom] = { 446, 258 },
}

PlayerSpawnPoints[G.StorageRoom] = {
	default = { 312, 48 },
	[G.Outside] = { 312, 48 },
	[G.Kitchen] = { 16, 48, Enums.face_dir.right },
}

PlayerSpawnPoints[G.UtilityRoom] = {
	default = { 318, 48 },
	[G.Kitchen] = { 16, 48, Enums.face_dir.right },
}

PlayerSpawnPoints[G.Kitchen] = {
	default = { 443, 64 },
	[G.StorageRoom] = { 443, 64 },
	[G.UtilityRoom] = { 398, 64 },
}

PlayerSpawnPoints[G.LivingRoom] = {
	default = { 360, 64 },
}

PlayerSpawnPoints[G.TotallyDarkRoom] = PlayerSpawnPoints[G.LivingRoom]

PlayerSpawnPoints[G.Office1] = {
	default = { 127, 64 },
	[G.Office2] = { 680, 64, Enums.face_dir.left },
}

PlayerSpawnPoints[G.Office2] = {
	default = { 127, 64 },
	[G.Office1] = { 86, 64, Enums.face_dir.right },
}

return PlayerSpawnPoints
