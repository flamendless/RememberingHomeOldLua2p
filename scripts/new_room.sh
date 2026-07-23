#!/bin/bash
# Scaffold a new playable room. See NOTES.md for the full workflow.
#
# Usage: ./build.sh new_room PascalCaseName [snake_case_name]
# Example: ./build.sh new_room DiningRoom dining_room

set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
pascal="${1:-}"
snake="${2:-}"

if [ -z "$pascal" ]; then
	echo "Usage: ./build.sh new_room PascalCaseName [snake_case_name]"
	echo "Example: ./build.sh new_room DiningRoom dining_room"
	exit 1
fi

pascal_to_snake() {
	echo "$1" | sed 's/\([A-Z]\)/_\1/g' | sed 's/^_//' | tr '[:upper:]' '[:lower:]'
}

if [ -z "$snake" ]; then
	snake="$(pascal_to_snake "$pascal")"
fi

lower="$(echo "$pascal" | tr '[:upper:]' '[:lower:]')"
pascal_items="$(echo "$snake" | sed -r 's/(^|_)([a-z])/\U\2/g' | sed 's/_//g')"

state_file="$root/src/states/${lower}.lua"
assemblage_file="$root/src/assemblages/${lower}.lua"
atlas_file="$root/src/atlases/${snake}_items.lua"

for f in "$state_file" "$assemblage_file" "$atlas_file"; do
	if [ -f "$f" ]; then
		echo "Refusing to overwrite existing file: $f"
		exit 1
	fi
done

mkdir -p "$(dirname "$state_file")" "$(dirname "$assemblage_file")" "$(dirname "$atlas_file")"

cat >"$state_file" <<EOF
local ${pascal} = Concord.system()

function ${pascal}:init(world)
	self.id = "${snake}"
	self.world = world
end

function ${pascal}:state_setup()
	local w, h = Resources.data.images.${snake}:getDimensions()
	local ww, wh = love.graphics.getDimensions()

	self.canvas = Canvas.create_main()
	self.scale = math.min(ww / w, wh / h)
	self.camera = Gamera.new(0, 0, w, h)
	self.camera:setWindow(0, 0, ww, wh)
	Concord.entity(self.world):assemble(Assemblages.Common.camera, self.camera, self.scale, w, h)
	Concord.entity(self.world):assemble(Assemblages.Common.bg, self.id)

	self.world:emit("create_room_bounds", w, h)
	self.world:emit("parse_room_items", self.id)
	self.world:emit("setup_post_process", {
		Shaders.ngrading("lut_dusk"),
		Shaders.film_grain(),
		Shaders.blur(),
		Shaders.glitch(),
	})

	for _, v in pairs(Assemblages.${pascal}.lights) do
		Concord.entity(self.world):assemble(v)
	end
	self.world:emit("set_ambiance", Palette.get_diffuse("ambiance_${snake}"))
	self.world:emit("set_draw", "ev_draw_ex")
end

function ${pascal}:state_init()
	self.world:emit("spawn_player", function(e_player)
		self.world:emit("camera_follow", e_player, 0.25)
		self.world:emit("toggle_component", e_player, "can_move", true)
		self.world:emit("toggle_component", e_player, "can_interact", true)
		self.world:emit("toggle_component", e_player, "can_run", true)
	end)

	self.timeline = TLE.Do(function()
		Fade.fade_in(nil, 1)
		self.camera:setScale(4)
		self.timeline:Pause()
	end)
end

function ${pascal}:state_update(dt)
	self.world:emit("preupdate", dt)
	self.world:emit("update", dt)
end

function ${pascal}:state_draw()
	self.world:emit("begin_deferred_lighting", self.camera, self.canvas)
	self.world:emit("end_deferred_lighting")
	self.world:emit("apply_post_process", self.canvas)
	self.world:emit("draw_ui")
	Fade.draw()
end

function ${pascal}:ev_draw_ex()
	self.world:emit("draw_bg")
	self.world:emit("draw")
end

return ${pascal}
EOF

cat >"$assemblage_file" <<EOF
local ${pascal} = {
	lights = {},
}

local pl = Data.Lights.${snake}.pl
for i, pos in ipairs(pl.pos) do
	${pascal}.lights["pl" .. i] = function(e)
		e:assemble(Assemblages.Light.point, pos.x, pos.y, pl.lz, pl.ls, Palette.get_diffuse("${snake}_side"))
			:give("id", "pl" .. i)
			:give("light_group", "side_pl")
			:give("light_switch_id", "top")
			:give("light_fading", pl.fade, -1)
	end
end

return ${pascal}
EOF

cat >"$atlas_file" <<EOF
local Data = {
	-- Add exported item placements for ${pascal}. See src/atlases/kitchen_items.lua.
}

return Data
EOF

insert_after_line() {
	local pattern="$1"
	local file="$2"
	local block="$3"
	if grep -qF "$pattern" "$file" 2>/dev/null; then
		echo "Already present in $file: $pattern"
		return
	fi
	perl -i -0pe "s/(${pattern}\n)/\${1}${block}/s" "$file"
}

insert_after_line "	KitchenItems = require(\"atlases.kitchen_items\")," \
	"$root/src/global.lua" \
	"	${pascal_items}Items = require(\"atlases.${snake}_items\"),\n"

insert_after_line "	Kitchen = require(\"assemblages.kitchen\")," \
	"$root/src/global.lua" \
	"	${pascal} = require(\"assemblages.${lower}\"),\n"

if ! grep -q "state_systems.${pascal}" "$root/src/ecs.lua"; then
	perl -i -0pe "s/(state_systems\.Kitchen = \{.*?\n\}\n)/\${1}\nstate_systems.${pascal} = tablex.copy(state_systems.Kitchen)\n/s" "$root/src/ecs.lua"
fi

if ! grep -q "ResourcesList.${pascal}" "$root/src/data/resources_list.lua"; then
	cat >>"$root/src/data/resources_list.lua" <<EOF

ResourcesList.${pascal} = {
	images = {
		{ "bg_inventory",     "res/images/inventory_notes/bg_inventory.png" },
		{ "bg_desc",          "res/images/inventory_notes/bg_desc.png" },
		{ "flashlight",       "res/images/inventory_notes/flashlight.png" },
		{ "inventory_border", "res/images/inventory_notes/border.png" },
		{ "bg_notes",         "res/images/inventory_notes/bg_notes.png" },
		{ "note_cursor",      "res/images/inventory_notes/note_cursor.png" },
		{ "atlas_keys",       "res/ui/atlas_keys.png" },
		unpack(textures),
	},
	array_images = {
		{ "${snake}",             "res/images/${snake}/${snake}.png" },
		{ "atlas_${snake}_items", "res/images/atlases/${snake}.png" },
		unpack(player),
	},
	image_data = {
		{ "lut_dusk_16", "res/lut/lut_dusk_16.png" },
		{ "lut_dusk_64", "res/lut/lut_dusk_64.png" },
	},
	fonts = {
		{ "item_name",        "res/fonts/DigitalDisco.ttf", 20, "default" },
		{ "item_desc",        "res/fonts/DigitalDisco.ttf", 16, "default" },
		{ "note_list",        "res/fonts/DigitalDisco.ttf", 16, "default" },
		{ "inventory_choice", "res/fonts/DigitalDisco.ttf", 24, "default" },
		unpack(fnt_common),
	},
}
EOF
fi

if ! grep -q "Doors.${pascal}" "$root/src/data/doors.lua"; then
	perl -i -pe "s/(Doors\.Kitchen = \{)/Doors.${pascal} = {\n}\n\n\${1}/" "$root/src/data/doors.lua"
fi

if ! grep -q "PlayerSpawnPoints.${pascal}" "$root/src/data/player_spawn_points.lua"; then
	perl -i -pe "s/(PlayerSpawnPoints\.Kitchen = \{)/PlayerSpawnPoints.${pascal} = {\n\tdefault = { 360, 64 },\n}\n\n\${1}/" "$root/src/data/player_spawn_points.lua"
fi

if ! grep -q "Lights.${snake}" "$root/src/data/lights.lua"; then
	perl -i -pe "s/(Lights\.kitchen = \{)/Lights.${snake} = {\n\tpl = {\n\t\tlz = 48,\n\t\tls = 128,\n\t\tfade = 6,\n\t\tpos = {\n\t\t\t{ x = 86,  y = 26 },\n\t\t\t{ x = 386, y = 27 },\n\t\t},\n\t},\n}\n\n\${1}/" "$root/src/data/lights.lua"
fi

echo "Created room scaffold: ${pascal} (${snake})"
echo ""
echo "Files created:"
echo "  $state_file"
echo "  $assemblage_file"
echo "  $atlas_file"
echo ""
echo "Updated:"
echo "  src/global.lua"
echo "  src/ecs.lua"
echo "  src/data/resources_list.lua"
echo "  src/data/doors.lua"
echo "  src/data/player_spawn_points.lua"
echo "  src/data/lights.lua"
echo ""
echo "Manual steps remaining:"
echo "  1. Add art to res/images/${snake}/ and export layers to res/exported/${snake}/"
echo "  2. Run: ./build.sh gen_atlas ${snake} && ./build.sh copy_res"
echo "  3. Fill in src/atlases/${snake}_items.lua item placements"
echo "  4. Wire doors in src/data/doors.lua and spawn points in src/data/player_spawn_points.lua"
echo "  5. Add Palette entries for ambiance_${snake} and ${snake}_side if needed"
echo "  6. Test with: GameStates.switch(\"${pascal}\")"
