local Palette = {}

-- TODO: (Brandon) finalize colors

Palette.colors = {
	white = { 1, 1, 1 },
	red = { 1, 0, 0 },
	camera_clip = { 0, 0, 0 },
	red_desaturated = { 0.450980, 0.086275, 0.058824 },

	menu_text = { 1.000000, 1.000000, 1.000000 },
	menu_select = { 0.450980, 0.086275, 0.058824 },
	menu_disabled = { 0.298039, 0.298039, 0.298039 },

	about_normal = { 1.000000, 1.000000, 1.000000 },
	about_hint = { 1.000000, 0.090196, 0.266667 },

	ui_show_key_text = { 1, 1, 1 },
	ui_key = { 0.121568627, 0.078431373, 0.207843137 },
	ui_hold_progress = { 0.988235294, 0.988235294, 0.925490196 },
	ui_feedback = { 0.380392, 0.878431, 0.635294 },
	ui_not_hovered = { 0.800000, 0.788235, 0.854902 },
	ui_hovered = { 1.000000, 1.000000, 1.000000 },
	ui_dialogue = { 1.000000, 1.000000, 1.000000 },
	hovered_choice = { 1, 0, 0 },

	outline = { 1, 1, 1 },

	inventory_cell = { 0.623529411765, 0.63137254902, 0.556862745098 },
	note_list = { 0, 0, 0 },
	note_on_hovered = { 1, 0, 0 },
}

for k, v in pairs(Palette.colors) do
	if v[4] ~= nil then
		error(k .. " must have no alpha set")
	end
end

Palette.diffuse = {
	--intro
	ambiance_intro = {1, 1, 1, 1},
	car = { 1, 1, 1 },
	post = { 1, 1, 1 },

	--outside
	ambiance_outside = { 0.7, 0.7, 0.7, 0.3 },
	firefly = { 3, 2.5, 0 },
	car_headlight_pl = { 5, 4.5, 2.3 },
	car_headlight_sl = { 3, 3, 1 },
	door_pl = { 1.62, 1.46, 1.06 },
	door_sl = { 4, 4, 1 },

	ambiance_storage_room = { 0.7, 0.7, 0.7, 0.3 },
	storage_room_bulb_light = { 1.44, 1.64, 0.2 },

	ambiance_utility_room = { 0.7, 0.7, 0.7, 0.3 },
	utility_room_bulb_light = { 1.44, 1.64, 0.2 },

	ambiance_kitchen = { 0.7, 0.7, 0.7, 0.3 },
	kitchen_side = { 1.44, 1.64, 0.2 },
	kitchen_mid_pl = { 1, 1.12, 0.1 },

	ambiance_living_room = { 0.7, 0.7, 0.7, 0.3 },
	living_room_mid_pl = { 2.28, 1.56, 0.5 },
	living_room_side = { 1.44, 1.64, 0.2 },

	ambiance_totally_dark_room = { 0.7, 0.7, 0.7, 0.0 },
}

function Palette.get(color, alpha)
	if type(color) ~= "string" then
		error('Assertion failed: type(color) == "string"')
	end
	if not Palette.colors[color] then
		error("Assertion failed: Palette.colors[color]")
	end
	if alpha then
		if type(alpha) ~= "number" then
			error('Assertion failed: type(alpha) == "number"')
		end
	end
	local c = Palette.colors[color]
	local a = alpha or c[4] or 1
	return { c[1], c[2], c[3], a }
end

function Palette.get_diffuse(color)
	if type(color) ~= "string" then
		error('Assertion failed: type(color) == "string"')
	end
	if not Palette.diffuse[color] then
		error("Assertion failed: Palette.diffuse[color]")
	end
	return { unpack(Palette.diffuse[color]) }
end

return Palette
