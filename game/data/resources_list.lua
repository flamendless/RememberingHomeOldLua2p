local ResourcesList = {}

ResourcesList.Splash = {
	images = {
		{"flamendless_logo", "res/images/splash/flamendless_logo.png"},
		{"sheet_wits", "res/images/splash/sheet_wits.png"},
		{"tex_displacement", "res/textures/displacement.png"},
		{"atlas_keys","res/ui/atlas_keys.png"},

	},
	fonts = {
		{"ui", "res/fonts/Jamboree.ttf", 32, "default"},
		{"firefly", "res/fonts/Firefly.ttf", 172, "default"},
		{"uncle_type", "res/fonts/uncle_type.ttf", 32},
	}
}

ResourcesList.Menu = {
	images = {
		{"bg_door", "res/images/menu/bg_door.png"},
		{"bg_hallway", "res/images/menu/bg_hallway.png"},
		{"sheet_desk", "res/images/menu/sheet_desk.png"},
		{"title", "res/images/menu/title.png"},
		{"subtitle", "res/images/menu/subtitle.png"},
		{"discord", "res/images/menu/icon_discord.png"},
		{"twitter", "res/images/menu/icon_twitter.png"},
		{"website", "res/images/menu/icon_website.png"},
		{"mail", "res/images/menu/icon_mail.png"},
		{"btn_back", "res/images/menu/btn_back.png"},
		{"keyboard1", "res/ui/keyboard1.png"},
		{"keyboard2", "res/ui/keyboard2.png"},
	},
	fonts = {
		{"menu", "res/fonts/Jamboree.ttf", 24, "default"},
		{"about", "res/fonts/DigitalDisco.ttf", 20},
		{"about", "res/fonts/DigitalDisco.ttf", 64},
	}
}

ResourcesList.Intro = {
	images = {
		{"intro", "res/images/intro/bg.png"},
		{"atlas_intro", "res/images/intro/atlas_intro.png"},
		{"sheet_car", "res/images/intro/sheet_car.png"},
		{"sheet_car_reflect", "res/images/intro/sheet_car_reflect.png"},
		{"sheet_splat", "res/ui/sheet_splat.png"},
		{"rain_drop_tilted", "res/images/rain/rain_drop_tilted.png"},
		{"rain_drop_tilted2", "res/images/rain/rain_drop_tilted2.png"},
		{"dummy", "res/textures/dummy.png"},
		{"atlas_keys","res/ui/atlas_keys.png"},

	},
	image_data = {
		{"lut_afternoon_16", "res/lut/lut_afternoon_16.png"},
		{"lut_afternoon_64", "res/lut/lut_afternoon_64.png"},
		{"lut_dusk_16", "res/lut/lut_dusk_16.png"},
		{"lut_dusk_64", "res/lut/lut_dusk_64.png"},
	},
	fonts = {
		{"ui", "res/fonts/Jamboree.ttf", 32, "default"},
		{"dialogue", "res/fonts/DigitalDisco.ttf", 32, "default"},
	},
}

ResourcesList.Outside = {
	images = {
		{"rain_drop", "res/images/rain/rain_drop.png"},
		{"rain_drop2", "res/images/rain/rain_drop2.png"},
		{"sheet_cloud", "res/ui/sheet_cloud.png"},
		{"sheet_splat", "res/ui/sheet_splat.png"},
		{"sheet_brush", "res/ui/sheet_brush.png"},
		{"bg_inventory","res/images/inventory_notes/bg_inventory.png"},
		{"bg_desc","res/images/inventory_notes/bg_desc.png"},
		{"flashlight","res/images/inventory_notes/flashlight.png"},
		{"inventory_border","res/images/inventory_notes/border.png"},
		{"bg_notes","res/images/inventory_notes/bg_notes.png"},
		{"note_cursor","res/images/inventory_notes/note_cursor.png"},

		{"tex_displacement","res/textures/displacement.png"},
		{"pause_bg","res/textures/pause_bg.png"},
		{"bayer16","res/textures/bayer16.png"},
		{"pal_hollow","res/textures/pal_hollow.png"},

		{"atlas_keys","res/ui/atlas_keys.png"},

	},
	array_images = {
		{"bg_sky", "res/images/outside/bg_sky.png"},
		{"bg_house", "res/images/outside/bg_house.png"},
		{"atlas_outside_items","res/images/atlases/outside.png"},
		{"firefly", "res/images/outside/firefly.png"},
		{"splashes", "res/images/outside/splashes.png"},
		{"splashes_low", "res/images/outside/splashes_low.png"},
		{"sheet_player_idle","res/images/player/sheet_player_idle_normal.png"},
		{"sheet_player_walk","res/images/player/sheet_player_walk_normal.png"},
		{"sheet_player_run","res/images/player/sheet_player_run_normal.png"},
		{"sheet_player_open_door","res/images/player/sheet_player_open_door_normal.png"},
		{"sheet_player_idle_f","res/images/player/sheet_player_idle_flashlight.png"},
		{"sheet_player_walk_f","res/images/player/sheet_player_walk_flashlight.png"},
		{"sheet_player_run_f","res/images/player/sheet_player_run_flashlight.png"},
		{"sheet_player_open_door_f","res/images/player/sheet_player_open_door_flashlight.png"},

	},
	image_data = {
		{"lut_dusk_16", "res/lut/lut_dusk_16.png"},
		{"lut_dusk_64", "res/lut/lut_dusk_64.png"},
	},
	fonts = {
		{"ui", "res/fonts/Jamboree.ttf", 32, "default"},
		{"dialogue","res/fonts/DigitalDisco.ttf",32,"default"},
		{"item_name","res/fonts/DigitalDisco.ttf",20,"default"},
		{"item_desc","res/fonts/DigitalDisco.ttf",16,"default"},
		{"note_list","res/fonts/DigitalDisco.ttf",16,"default"},
		{"inventory_choice","res/fonts/DigitalDisco.ttf",24,"default"},

	},
}

ResourcesList.StorageRoom = {
	images = {
		{"bg_inventory","res/images/inventory_notes/bg_inventory.png"},
		{"bg_desc","res/images/inventory_notes/bg_desc.png"},
		{"flashlight","res/images/inventory_notes/flashlight.png"},
		{"inventory_border","res/images/inventory_notes/border.png"},
		{"bg_notes","res/images/inventory_notes/bg_notes.png"},
		{"note_cursor","res/images/inventory_notes/note_cursor.png"},

		{"tex_displacement","res/textures/displacement.png"},
		{"pause_bg","res/textures/pause_bg.png"},
		{"bayer16","res/textures/bayer16.png"},
		{"pal_hollow","res/textures/pal_hollow.png"},

		{"atlas_keys","res/ui/atlas_keys.png"},

	},
	array_images = {
		{"storage_room", "res/images/storage_room/storage_room.png"},
		{"atlas_storage_room_items","res/images/atlases/storage_room.png"},
		{"sheet_player_idle","res/images/player/sheet_player_idle_normal.png"},
		{"sheet_player_walk","res/images/player/sheet_player_walk_normal.png"},
		{"sheet_player_run","res/images/player/sheet_player_run_normal.png"},
		{"sheet_player_open_door","res/images/player/sheet_player_open_door_normal.png"},
		{"sheet_player_idle_f","res/images/player/sheet_player_idle_flashlight.png"},
		{"sheet_player_walk_f","res/images/player/sheet_player_walk_flashlight.png"},
		{"sheet_player_run_f","res/images/player/sheet_player_run_flashlight.png"},
		{"sheet_player_open_door_f","res/images/player/sheet_player_open_door_flashlight.png"},

	},
	image_data = {
		{"lut_dusk_16", "res/lut/lut_dusk_16.png"},
		{"lut_dusk_64", "res/lut/lut_dusk_64.png"},
	},
	fonts = {
		{"ui", "res/fonts/Jamboree.ttf", 32, "default"},
		{"dialogue","res/fonts/DigitalDisco.ttf",32,"default"},
		{"item_name","res/fonts/DigitalDisco.ttf",20,"default"},
		{"item_desc","res/fonts/DigitalDisco.ttf",16,"default"},
		{"note_list","res/fonts/DigitalDisco.ttf",16,"default"},
		{"inventory_choice","res/fonts/DigitalDisco.ttf",24,"default"},

	},
}

ResourcesList.UtilityRoom = {
	images = {
		{"bg_inventory","res/images/inventory_notes/bg_inventory.png"},
		{"bg_desc","res/images/inventory_notes/bg_desc.png"},
		{"flashlight","res/images/inventory_notes/flashlight.png"},
		{"inventory_border","res/images/inventory_notes/border.png"},
		{"bg_notes","res/images/inventory_notes/bg_notes.png"},
		{"note_cursor","res/images/inventory_notes/note_cursor.png"},

		{"tex_displacement","res/textures/displacement.png"},
		{"pause_bg","res/textures/pause_bg.png"},
		{"bayer16","res/textures/bayer16.png"},
		{"pal_hollow","res/textures/pal_hollow.png"},

		{"atlas_keys","res/ui/atlas_keys.png"},

	},
	array_images = {
		{"utility_room", "res/images/utility_room/utility_room.png"},
		{"atlas_utility_room_items","res/images/atlases/utility_room.png"},
		{"sheet_player_idle","res/images/player/sheet_player_idle_normal.png"},
		{"sheet_player_walk","res/images/player/sheet_player_walk_normal.png"},
		{"sheet_player_run","res/images/player/sheet_player_run_normal.png"},
		{"sheet_player_open_door","res/images/player/sheet_player_open_door_normal.png"},
		{"sheet_player_idle_f","res/images/player/sheet_player_idle_flashlight.png"},
		{"sheet_player_walk_f","res/images/player/sheet_player_walk_flashlight.png"},
		{"sheet_player_run_f","res/images/player/sheet_player_run_flashlight.png"},
		{"sheet_player_open_door_f","res/images/player/sheet_player_open_door_flashlight.png"},

	},
	image_data = {
		{"lut_dusk_16", "res/lut/lut_dusk_16.png"},
		{"lut_dusk_64", "res/lut/lut_dusk_64.png"},
	},

	fonts = {
		{"ui", "res/fonts/Jamboree.ttf", 32, "default"},
		{"dialogue","res/fonts/DigitalDisco.ttf",32,"default"},
		{"item_name","res/fonts/DigitalDisco.ttf",20,"default"},
		{"item_desc","res/fonts/DigitalDisco.ttf",16,"default"},
		{"note_list","res/fonts/DigitalDisco.ttf",16,"default"},
		{"inventory_choice","res/fonts/DigitalDisco.ttf",24,"default"},

	},
}

ResourcesList.Kitchen = {
	images = {
		{"bg_inventory","res/images/inventory_notes/bg_inventory.png"},
		{"bg_desc","res/images/inventory_notes/bg_desc.png"},
		{"flashlight","res/images/inventory_notes/flashlight.png"},
		{"inventory_border","res/images/inventory_notes/border.png"},
		{"bg_notes","res/images/inventory_notes/bg_notes.png"},
		{"note_cursor","res/images/inventory_notes/note_cursor.png"},

		{"tex_displacement","res/textures/displacement.png"},
		{"pause_bg","res/textures/pause_bg.png"},
		{"bayer16","res/textures/bayer16.png"},
		{"pal_hollow","res/textures/pal_hollow.png"},

		{"atlas_keys","res/ui/atlas_keys.png"},

	},
	array_images = {
		{"kitchen", "res/images/kitchen/kitchen.png"},
		{"atlas_kitchen_items","res/images/atlases/kitchen.png"},
		{"sheet_player_idle","res/images/player/sheet_player_idle_normal.png"},
		{"sheet_player_walk","res/images/player/sheet_player_walk_normal.png"},
		{"sheet_player_run","res/images/player/sheet_player_run_normal.png"},
		{"sheet_player_open_door","res/images/player/sheet_player_open_door_normal.png"},
		{"sheet_player_idle_f","res/images/player/sheet_player_idle_flashlight.png"},
		{"sheet_player_walk_f","res/images/player/sheet_player_walk_flashlight.png"},
		{"sheet_player_run_f","res/images/player/sheet_player_run_flashlight.png"},
		{"sheet_player_open_door_f","res/images/player/sheet_player_open_door_flashlight.png"},

	},
	image_data = {
		{"lut_dusk_16", "res/lut/lut_dusk_16.png"},
		{"lut_dusk_64", "res/lut/lut_dusk_64.png"},
	},
	fonts = {
		{"ui", "res/fonts/Jamboree.ttf", 32, "default"},
		{"dialogue","res/fonts/DigitalDisco.ttf",32,"default"},
		{"item_name","res/fonts/DigitalDisco.ttf",20,"default"},
		{"item_desc","res/fonts/DigitalDisco.ttf",16,"default"},
		{"note_list","res/fonts/DigitalDisco.ttf",16,"default"},
		{"inventory_choice","res/fonts/DigitalDisco.ttf",24,"default"},

	},
}

ResourcesList.LivingRoom = {
	images = {
		{"bg_inventory","res/images/inventory_notes/bg_inventory.png"},
		{"bg_desc","res/images/inventory_notes/bg_desc.png"},
		{"flashlight","res/images/inventory_notes/flashlight.png"},
		{"inventory_border","res/images/inventory_notes/border.png"},
		{"bg_notes","res/images/inventory_notes/bg_notes.png"},
		{"note_cursor","res/images/inventory_notes/note_cursor.png"},

		{"tex_displacement","res/textures/displacement.png"},
		{"pause_bg","res/textures/pause_bg.png"},
		{"bayer16","res/textures/bayer16.png"},
		{"pal_hollow","res/textures/pal_hollow.png"},

		{"atlas_keys","res/ui/atlas_keys.png"},

	},
	array_images = {
		{"living_room", "res/images/living_room/living_room.png"},
		{"atlas_living_room_items","res/images/atlases/living_room.png"},
		{"sheet_player_idle","res/images/player/sheet_player_idle_normal.png"},
		{"sheet_player_walk","res/images/player/sheet_player_walk_normal.png"},
		{"sheet_player_run","res/images/player/sheet_player_run_normal.png"},
		{"sheet_player_open_door","res/images/player/sheet_player_open_door_normal.png"},
		{"sheet_player_idle_f","res/images/player/sheet_player_idle_flashlight.png"},
		{"sheet_player_walk_f","res/images/player/sheet_player_walk_flashlight.png"},
		{"sheet_player_run_f","res/images/player/sheet_player_run_flashlight.png"},
		{"sheet_player_open_door_f","res/images/player/sheet_player_open_door_flashlight.png"},

		{"sheet_enemy_suit_idle","res/images/enemy_suit/sheet_enemy_idle.png"},
		{"sheet_enemy_suit_walk","res/images/enemy_suit/sheet_enemy_walk.png"},
		{"sheet_enemy_suit_lean_back","res/images/enemy_suit/sheet_enemy_lean_back.png"},
		{"sheet_enemy_suit_lean_return_back","res/images/enemy_suit/sheet_enemy_lean_return_back.png"},

	},
	image_data = {
		{"lut_dusk_16", "res/lut/lut_dusk_16.png"},
		{"lut_dusk_64", "res/lut/lut_dusk_64.png"},
	},
	fonts = {
		{"ui", "res/fonts/Jamboree.ttf", 32, "default"},
		{"dialogue","res/fonts/DigitalDisco.ttf",32,"default"},
		{"item_name","res/fonts/DigitalDisco.ttf",20,"default"},
		{"item_desc","res/fonts/DigitalDisco.ttf",16,"default"},
		{"note_list","res/fonts/DigitalDisco.ttf",16,"default"},
		{"inventory_choice","res/fonts/DigitalDisco.ttf",24,"default"},

	},
}

return ResourcesList
