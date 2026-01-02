local Palette = require("palette")
local Lights = require("data.lights")

local StorageRoom = {
	lights = {},
}

local Light = require("assemblages.light")

local pl = Lights.storage_room.pl
for i, pos in ipairs(pl.pos) do
	StorageRoom.lights["pl" .. i] = function(e)
		e:assemble(Light.point, pos.x, pos.y, pl.lz, pl.ls, Palette.get_diffuse("storage_room_bulb_light"))
			:give("id", "pl" .. i)
			:give("light_group", "side_pl")
			:give("light_switch_id", "room")
			:give("light_fading", pl.fade, -1)
	end
end

return StorageRoom
