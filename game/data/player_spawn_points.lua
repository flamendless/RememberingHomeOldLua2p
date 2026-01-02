local PlayerSpawnPoints = {}

PlayerSpawnPoints.Outside = {

	default = {800, 258},

	Menu = {800, 258},
	StorageRoom = {446, 258},
}

PlayerSpawnPoints.StorageRoom = {

	default = {312, 48},

	Outside = {312, 48},
	Kitchen = {16, 48, Enums.face_dir.right},
}

PlayerSpawnPoints.UtilityRoom = {

	default = {318, 48},

	Kitchen = {16, 48, Enums.face_dir.right},
}

PlayerSpawnPoints.Kitchen = {

	default = {443, 64},

	StorageRoom = {443, 64},
	UtilityRoom = {398, 64},
}

PlayerSpawnPoints.LivingRoom = {

	default = {360, 64},

}

return PlayerSpawnPoints
