local DevTools = {
	show = false,
	show_fps = true,
	designer = false,
	pause = false,
	flags = {
		animation = false,
		deferred_lighting = false,
		bounding_box = false,
		bump_collision = false,
		camera = false,
		culling = false,
		fireflies = false,
		flashlight = true,
		fog = true,
		gamestates = false,
		id = false,
		light = false,
		log = false,
		movement = false,
		path = false,
		render_sprite = false,
		transform = false,
		randomize_uv = false,
		behavior_tree = false,
	},
	metrics = {
		give = {},
		remove = {},
	},
}

local slab_components

local stats = {
	show = false,
	exclude_slab = true,
	stats = {},
	title = "Stats",
}
local mouse = {
	show = false,
	title = "Mouse Info",
}
local entity_list = {
	show = false,
	show_list = false,
	t_es = {},
	n_es_id = 0,
	n_active = 0,
	title = "Entity List",
}
local system_list = {
	show = false,
	title = "System List",
}
local component_list = {
	show = false,
	title = "Component List",
}
local debug_list = {
	show = true,
	title = "Debug List",
}
local fade = {
	show = false,
	title = "Fade",
}

local image_viewer = {
	show = false,
	title = "Image Viewer",
	e = nil,
	mode = nil, -- quad or full
}

local list = {
	stats,
	mouse,
	entity_list,
	system_list,
	component_list,
	debug_list,
	fade,
	image_viewer,
}

local getFPS = love.timer.getFPS
local font = love.graphics.getFont()
local cols = 2

function DevTools.init()
	Slab.Initialize({ "NoDocks" })
end

local color_white = { 1, 1, 1, 1 }
function DevTools.update(dt)
	if not DevTools.show then
		return
	end
	if not GameStates.world then
		return
	end

	Slab.Update(dt)

	Slab.BeginWindow("list", { Title = "DevTools" })
	if DevTools.pp_effects then
		for _, effect in ipairs(DevTools.pp_effects) do
			if Slab.CheckBox(effect.is_active, effect:type()) then
				effect.debug_show = not effect.debug_show
				effect.is_active = not effect.is_active
			end
			if effect.debug_update then
				effect:debug_update(dt)
			end
		end
	end
	if Slab.CheckBox(DevTools.flags.fog, "Fog") then
		DevTools.flags.fog = not DevTools.flags.fog
	end
	if Slab.CheckBox(DevTools.designer, "Designer") then
		DevTools.designer = not DevTools.designer
	end
	for _, v in ipairs(list) do
		if Slab.CheckBox(v.show, v.title) then
			v.show = not v.show
		end
	end
	Slab.EndWindow()

	if DevTools.designer then
		GameStates.world:emit("set_ambiance", color_white)
	end

	DevTools.draw_stats()
	DevTools.draw_mouse()
	DevTools.draw_entities_list()
	DevTools.draw_system_list()
	DevTools.draw_component_list()
	DevTools.draw_debug_list()
	DevTools.draw_fade()
	DevTools.draw_image_viewer()
	GameStates.world:emit("debug_update", dt)
end

function DevTools.draw()
	if not DevTools.show then
		return
	end
	if not GameStates.world then
		return
	end

	love.graphics.setFont(font)
	if DevTools.camera then
		DevTools.camera:attach()
	end

	GameStates.world:emit("debug_draw")
	GameStates.world:emit("debug_draw_ui")

	if DevTools.camera then
		DevTools.camera:detach()
	end
	Slab.Draw()
end

function DevTools.draw_stats()
	if not stats.show then
		return
	end
	stats.show = Slab.BeginWindow("stats", {
		Title = stats.title,
		IsOpen = stats.show,
	})
	if Slab.CheckBox(stats.exclude_slab, "Exclude Slab") then
		stats.exclude_slab = not stats.exclude_slab
	end
	Slab.Text("FPS: " .. getFPS())
	for k, v in pairs(stats.stats) do
		Slab.Text(k .. ": " .. v)
	end
	Slab.Separator()
	if Slab.BeginTree("Give") then
		Slab.BeginLayout("layout_give", {Columns = 2})
		for k, v in pairs(DevTools.metrics.give) do
			Slab.SetLayoutColumn(1)
			Slab.Text(k)
			Slab.SetLayoutColumn(2)
			Slab.Text(v)
		end
		Slab.EndLayout()
		Slab.EndTree()
	end

	if Slab.BeginTree("Remove") then
		Slab.BeginLayout("layout_remove", {Columns = 2})
		for k, v in pairs(DevTools.metrics.remove) do
			Slab.SetLayoutColumn(1)
			Slab.Text(k)
			Slab.SetLayoutColumn(2)
			Slab.Text(v)
		end
		Slab.EndLayout()
		Slab.EndTree()
	end

	Slab.EndWindow()
end

function DevTools.draw_mouse()
	if not mouse.show then
		return
	end
	mouse.show = Slab.BeginWindow("mouse", {
		Title = mouse.title,
		IsOpen = mouse.show,
	})
	local mx, my = love.mouse.getPosition()
	local cx, cy = 0, 0
	local camera = DevTools.camera
	if camera then
		cx, cy = camera:toWorld(mx, my)
	end
	local str_m = string.format("Mouse: (%d, %d)", mx, my)
	local str_c = string.format("Camera: (%d, %d)", cx, cy)
	Slab.Text(str_m)
	Slab.Text(str_c)
	Slab.EndWindow()
end

function DevTools.draw_entities_list()
	if not entity_list.show then
		return
	end
	entity_list.show = Slab.BeginWindow("ent_list", {
		Title = entity_list.title,
		IsOpen = entity_list.show,
	})
	entity_list.t_es = GameStates.world:getEntities()
	entity_list.n_es_id = 0
	entity_list.n_active = 0
	for _, e in ipairs(entity_list.t_es) do
		if e.id then
			entity_list.n_es_id = entity_list.n_es_id + 1
		end
		if not e.hidden then
			entity_list.n_active = entity_list.n_active + 1
		end
	end
	Slab.Text("# of entities: " .. #entity_list.t_es)
	Slab.Text("# of entities with id: " .. entity_list.n_es_id)
	Slab.Text("# of active entities: " .. entity_list.n_active)

	if Slab.Button("Toggle List (with ID)") then
		entity_list.show_list = not entity_list.show_list
	end

	if entity_list.show_list then
		Slab.BeginLayout("layout_e_id", {
			Columns = cols,
		})
		local i = 1
		for _, e in ipairs(entity_list.t_es) do
			local id = e.id and e.id.value
			if id then
				Slab.SetLayoutColumn(i)
				local hidden = e.hidden
				if Slab.CheckBox(not hidden, id) then
					hidden = not hidden
					if hidden then
						e:give("hidden")
					else
						e:remove("hidden")
					end
				end
				i = i + 1
				if i > cols then
					i = 1
				end
			end
		end
		Slab.EndLayout()
	end
	Slab.EndWindow()
end

function DevTools.draw_system_list()
	if not system_list.show then
		return
	end
	system_list.show = Slab.BeginWindow("systems", {
		Title = system_list.title,
		IsOpen = system_list.show,
	})
	Slab.BeginLayout("layout_systems", { Columns = 3 })
	local col = 1
	for _, v in ipairs(GameStates.world:getSystems()) do
		Slab.SetLayoutColumn(col)
		if Slab.CheckBox(v.debug_enabled, v.debug_title) then
			v.debug_enabled = not v.debug_enabled
			v:setEnabled(v.debug_enabled)
		end
		col = col + 1
		if col > 3 then
			col = 1
		end
	end
	Slab.EndLayout()
	Slab.EndWindow()
end

function DevTools.draw_component_list()
	if not component_list.show then
		return
	end
	component_list.show = Slab.BeginWindow("components", {
		Title = component_list.title,
		IsOpen = component_list.show,
	})
	local entities = GameStates.world:getEntities()
	for _, e in ipairs(entities) do
		local id = e.id.value
		if id then
			if Slab.BeginTree(id) then
				local components = e:getComponents()
				for k in pairs(components) do
					if Slab.BeginTree(k) then
						if slab_components[k] then
							slab_components[k](e)
						end
						Slab.EndTree()
					end
				end

				Slab.EndTree()
			end
		end
	end
	Slab.EndWindow()
end

function DevTools.draw_debug_list()
	if not debug_list.show then
		return
	end
	debug_list.show = Slab.BeginWindow("debug", {
		Title = debug_list.title,
		IsOpen = debug_list.show,
	})
	Slab.BeginLayout("layout_debug", { Columns = 2 })
	local states = GameStates.world:getSystems()
	local i = 1
	for _, v in ipairs(states) do
		if v.debug_update or v.debug_draw then
			Slab.SetLayoutColumn(i)
			if Slab.CheckBox(v.debug_show, v.debug_title) then
				v.debug_show = not v.debug_show
				if v.debug_on_toggle then
					v:debug_on_toggle()
				end
			end
			i = i + 1
			if i > 2 then
				i = 1
			end
		end
	end
	Slab.EndLayout()
	Slab.EndWindow()
end

function DevTools.slab_hidden(e)
	if not e.hidden and not e.dev_hidden then return end
	if Slab.CheckBox(e.hidden ~= nil, "hidden") then
		if e:has("hidden") then
			e:remove("hidden"):give("dev_hidden")
		else
			e:give("hidden"):remove("dev_hidden")
		end
	end
end

function DevTools.slab_id(e)
	if not e.id then return end
	Slab.Text("id: " .. e.id.value)
	if e.id.sub_id then
		Slab.Text("sub id: " .. e.id.sub_id)
	end
end

function DevTools.slab_color(e)
	if not e.color then return end
	UIWrapper.color(e.color.value)
end

function DevTools.slab_z_index(e)
	if not e.z_index then return end
	local id = e.id.value
	local z_index = e.z_index
	if Slab.CheckBox(z_index.sortable, id .. ".sortable") then
		z_index.sortable = not z_index.sortable
	end
	z_index.value = UIWrapper.edit_number(id .. ".z_index", z_index.value, true)
end

function DevTools.slab_sprite(e)
	if not e.sprite then return end
	if Slab.Button("Show Sprite") then
		image_viewer.show = true
		image_viewer.e = e
		image_viewer.mode = "quad"
	end
	Slab.SameLine()
	if Slab.Button("Show Full") then
		image_viewer.show = true
		image_viewer.e = e
		image_viewer.mode = "full"
	end
end

function DevTools.slab_attach_to(e)
	if not e.attach_to then return end
	local e_other = GameStates.world:getEntityByKey(e.attach_to.key)
	Slab.Text("Attached to ID: " .. e_other.id.value)
	if e.attach_to_offset and Slab.BeginTree("Attach to offset") then
		local ato = e.attach_to_offset
		ato.ox = UIWrapper.edit_number("ox", ato.ox, true)
		ato.oy = UIWrapper.edit_number("oy", ato.oy, true)
		Slab.EndTree()
	end
end

function DevTools.slab_pos(e)
	if not e.pos then return end
	local pos = e.pos
	pos.x = UIWrapper.edit_number("x", pos.x, true)
	pos.y = UIWrapper.edit_number("y", pos.y, true)
end

function DevTools.slab_transform(e)
	local transform = e.transform
	if transform and Slab.BeginTree("Transform") then
		transform.rotation = UIWrapper.edit_range("r", transform.rotation, 0, 1, false)
		transform.sx = UIWrapper.edit_number("sx", transform.sx, false)
		transform.sy = UIWrapper.edit_number("sy", transform.sy, false)
		transform.ox = UIWrapper.edit_number("ox", transform.ox, false)
		transform.oy = UIWrapper.edit_number("oy", transform.oy, false)
		transform.kx = UIWrapper.edit_number("kx", transform.kx, false)
		transform.ky = UIWrapper.edit_number("ky", transform.ky, false)
		Slab.EndTree()
	end

	local quad = e.quad
	local quad_transform = e.quad_transform
	if quad and quad_transform and Slab.BeginTree("Quad Transform") then
		quad_transform.rotation = UIWrapper.edit_range("r", quad_transform.rotation, 0, 1, false)
		quad_transform.sx = UIWrapper.edit_number("sx", quad_transform.sx, false)
		quad_transform.sy = UIWrapper.edit_number("sy", quad_transform.sy, false)
		quad_transform.ox = UIWrapper.edit_number("ox", quad_transform.ox, false)
		quad_transform.oy = UIWrapper.edit_number("oy", quad_transform.oy, false)
		Slab.EndTree()
	end
end

slab_components = {
	attach_to = DevTools.slab_attach_to,
	attach_to_offset = DevTools.slab_attach_to,
	color = DevTools.slab_color,
	dev_hidden = DevTools.slab_hidden,
	hidden = DevTools.slab_hidden,
	id = DevTools.slab_id,
	pos = DevTools.slab_pos,
	sprite = DevTools.slab_sprite,
	transform = DevTools.slab_transform,
	z_index = DevTools.slab_z_index,
}

function DevTools.draw_fade()
	if not fade.show then return end
	fade.show = Slab.BeginWindow("Fade", {
		Title = fade.title,
		IsOpen = fade.show,
	})
	local f = Fade.getColor()
	UIWrapper.color(f)

	Slab.Text("State: " .. Fade.state)
	Slab.Text("Duration: " .. Fade.duration)
	Slab.Text("Delay: " .. Fade.delay)
	Slab.EndWindow()
end

function DevTools.draw_image_viewer()
	if not image_viewer.show then return end
	image_viewer.show = Slab.BeginWindow("Image Viewer", {
		Title = image_viewer.title,
		IsOpen = image_viewer.show,
	})
	if Slab.Button("Close") then
		image_viewer.show = false
		image_viewer.e = nil
	end

	local e = image_viewer.e
	if e then
		Slab.SameLine()
		Slab.Text("Mode: " .. image_viewer.mode)
		local sprite = e.sprite
		if image_viewer.mode == "quad" then
			local subx, suby, subw, subh = e.quad.quad:getViewport()
			Slab.Image(e.id.value,
				{
					Image = sprite.image,
					SubX = subx, SubY = suby,
					SubW = subw, SubH = subh,
					W = subw * 2, H = subh * 2,
				}
			)
		elseif image_viewer.mode == "full" then
			Slab.Image(e.id.value, {
				Image = sprite.image,
				W = sprite.iw, H = sprite.ih,
			})
		end
	end
	Slab.EndWindow()
end

function DevTools.end_draw()
	if stats.show then
		stats.stats = love.graphics.getStats(stats.stats)
		if stats.exclude_slab then
			stats.stats = Slab.CalculateStats(stats.stats)
		end
	end
end

function DevTools.keypressed(key)
	if not GameStates.world then
		return
	end
	if Slab.IsAnyInputFocused() then
		return
	end

	if key == "`" then
		DevTools.show = not DevTools.show
		Slab.EnableStats(DevTools.show)
	-- elseif key == "m" then
	-- 	GameStates.world:emit("save_game")
	-- elseif key == "l" then
	-- 	GameStates.world:emit("load_game")
	elseif key == "space" then
		DevTools.pause = not DevTools.pause
	elseif key == "h" then
		DevTools.show_fps = not DevTools.show_fps
	elseif key == "c" then
		GameStates.world:emit("debug_on_toggle", "camera")
	elseif key == "l" then
		GameStates.world:emit("debug_on_toggle", "deferred_lighting")
	elseif key == "f" then
		fade.show = not fade.show
	elseif key == "r" then
		love.event.quit("restart")
	elseif key == "escape" and DevTools.show then
		love.event.quit()
	end
end

function DevTools.mousemoved(mx, my, dx, dy)
	if not GameStates.world then
		return
	end
	GameStates.world:emit("debug_mousemoved", mx, my, dx, dy)
end

function DevTools.mousepressed(mx, my, mb)
	if not GameStates.world then
		return
	end
	GameStates.world:emit("debug_mousepressed", mx, my, mb)
end

function DevTools.mousereleased(mx, my, mb)
	if not GameStates.world then
		return
	end
	GameStates.world:emit("debug_mousereleased", mx, my, mb)
end

function DevTools.wheelmoved(wx, wy)
	if not GameStates.world then
		return
	end
	GameStates.world:emit("debug_wheelmoved", wx, wy)
end

function DevTools.clear()
	tablex.clear(DevTools.metrics.give)
	tablex.clear(DevTools.metrics.remove)
end

return DevTools
