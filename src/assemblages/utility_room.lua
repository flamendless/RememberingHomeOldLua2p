local UtilityRoom = {
	lights = {},
}

local pl = Data.Lights.utility_room.pl
for i, pos in ipairs(pl.pos) do
	UtilityRoom.lights["pl" .. i] = function(e)
		local y = Data.Lights.get_light_y("utility_room", "pl", i)
		e:assemble(Assemblages.Light.point, pos.x, y, pl.lz, pl.ls, Palette.get_diffuse("utility_room_bulb_light"))
			:give("id", "pl" .. i)
			:give("light_group", Enums.light_group.side_pl)
			:give("light_switch_id", "room")
			:give("light_fading", pl.fade, -1)
	end
end

return UtilityRoom
