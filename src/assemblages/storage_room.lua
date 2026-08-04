local StorageRoom = {
	lights = {},
}

local pl = Data.Lights.storage_room.pl
for i, pos in ipairs(pl.pos) do
	StorageRoom.lights["pl" .. i] = function(e)
		local y = Data.Lights.get_light_y("storage_room", "pl", i)
		e:assemble(Assemblages.Light.point, pos.x, y, pl.lz, pl.ls, Palette.get_diffuse("storage_room_bulb_light"))
			:give("id", "pl" .. i)
			:give("light_group", Enums.light_group.side_pl)
			:give("light_switch_id", "room")
			:give("light_fading", pl.fade, -1)
	end
end

return StorageRoom
