# Systems

- Flashlight + Animation Sync = flashlight bobbing on player movement
- Behavior Tree + Enemy Controller = needed for enemy

---

# Scenes/Rooms

In section lists the steps and files that are needed to create a new room.

1. Put room background image and `.aseprite` in `res/images/{new_room}/`
2. In `aseprite`, export layers to multiple images to `res/exported/{new_room}/`
3. Generate via `./build.sh gen_atlas {new_room}` then copy with `./build.sh copy_res`
4. Create assemblage in `src/assemblages/{new_room}.lua`
5. Create items in `src/atlases/{new_room}_items.lua`
6. Create state in `src/states/{new_room}.lua`
7. Add entry to the following (or run `./build.sh new_room PascalCaseName snake_case` to scaffold steps 4–7 and data stubs):
- `src/data/resources_list.lua`
- `src/global.lua`
- `src/ecs.lua`
- `src/data/player_spawn_points.lua`
- `src/data/lights.lua`
- `src/data/doors.lua`
