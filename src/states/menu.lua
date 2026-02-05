local Menu = Concord.system({
	pool = { "option_key", "color", "pos", "text", "on_enter_menu" },
	pool_disabled = { "option_key", "option_disabled" },
	pool_text = { "menu_text" },
	pool_main_menu = {
		constructor = Ctor.ListByID,
		id = "main_menu",
	},
	pool_sub_menu = {
		constructor = Ctor.ListByID,
		id = "sub_menu",
	},
})

local offset_x = 64
local dur_in = 0.75
local dur_out = 0.5
local color_select = Palette.get("menu_select", 1)
local color_disabled = Palette.get("menu_disabled", 1)
local about_done = false
local ANGLE_UP = 90
local ANGLE_RIGHT = 0
local duration_show = 0.75
local duration_hide = 0.75
local duration_pos = 0.75
local target_x = 176
local tools = {
	"Manjaro",
	"i3-Gaps",
	"Discord",
	"Löve Framework",
	"Luapreprocess",
	"Vim",
	"Aseprite",
	"Audacity",
	"Export-TextureAtlas",
	"love-build",
	"msdf-bmfont",
}
local libs = {
	"Anim8",
	"Batteries",
	"beehive",
	"Bitser",
	"Bump-niji",
	"Concord",
	"Enum",
	"Flux",
	"Gamera",
	"HUMP",
	"JProf",
	"Lily",
	"Log",
	"Lume",
	"ngrading",
	"Outliner",
	"Peeker",
	"ReflowPrint",
	"SDF",
	"Semver",
	"Slab",
	"Splashes",
	"strict",
	"TimelineEvents",
}
local options = { "Play", "Settings", "About", "Exit" }
local options_sub = { "Continue", "New Game" }

local function color_to(color, target_color, dur)
	Flux.to(color.value, dur, {
		[1] = target_color[1],
		[2] = target_color[2],
		[3] = target_color[3],
		[4] = target_color[4],
	})
end

local about_template = {
	{ "@COLOR" },
	{ "A Game By:" },
	{ "flamendless studio    @flam8studio" },
	{ "" },

	{ "@COLOR" },
	{ "Programmer:" },
	{ "Brandon Blanker Lim-it    @flamendless" },
	{ "" },

	{ "@COLOR" },
	{ "Arts:" },
	{ "Conrad Reyes    @Shizzy619" },
	{ "" },

	{ "@COLOR" },
	{ "Level Design:" },
	{ "Piolo Maurice Laudencia    @piotato" },
	{ "" },

	--TODO add musician here
	{ "@COLOR" },
	{ "Music/Sound:" },
	{ "???    @???" },
	{ "" },

	{ "@LAYOUT:LEFT" },
	{ "@COLOR" },
	{ "TOOLS USED:" },
}

local function generate_about()
	local t = about_template
	for i = 1, #tools, 3 do
		local a = tools[i]
		local b = tools[i + 1] or ""
		local c = tools[i + 2] or ""
		if b ~= "" then
			a = a .. ","
		end
		if c ~= "" then
			b = b .. ","
		end
		local subt = { string.format("%s %s %s", a, b, c) }
		table.insert(t, subt)
	end

	table.insert(t, { "@LAYOUT:RIGHT" })
	table.insert(t, { "@COLOR" })
	table.insert(t, { "LIBRARIES USED:" })

	for i = 1, #libs, 4 do
		local a = libs[i]
		local b = libs[i + 1] or ""
		local c = libs[i + 2] or ""
		local d = libs[i + 3] or ""
		if b ~= "" then
			a = a .. ","
		end
		if c ~= "" then
			b = b .. ","
		end
		if d ~= "" then
			c = c .. ","
		end
		local subt = { string.format("%s %s %s %s", a, b, c, d) }
		table.insert(t, subt)
	end

	table.insert(t, { "@LAYOUT:CENTER" })
	table.insert(t, { "" })
	table.insert(t, { "SPECIAL THANKS to the people at the Löve Discord server" })
	table.insert(t, {
		"_IMAGES",
		"twitter",
		"discord",
		"website",
		"mail",
	})

	return t
end

function Menu:init(world)
	self.id = "menu"
	self.world = world
	self.keys = {}
	self.is_transition = true
	self.current_state = Enums.menu_state.menu
end

function Menu:state_setup()
	local ww, wh = love.graphics.getDimensions()
	self.camera = Gamera.new(0, 0, ww * 2, wh * 2)
	self.camera:setWindow(0, 0, ww, wh)
	self.canvases = {}
	Canvas.init_canvases(self.canvases)
	self.mb = Shaders.MotionBlur(self.canvases.main)
	self:setup_menu()
end

function Menu:state_init()
	Fade.set_color({ 0, 0, 0, 1 })
	self.timeline = TLE.Do(function()
		self:hide_main_menu(0.1)
		self:hide_sub_menu(0.1)
		self.timeline:Pause()
		Fade.fade_in(function()
			self:menu_unpause()
		end)
		self.timeline:Pause()
		-- self.subtitle:remove("anchor")
		self:show_main_menu()
		self.timeline:Pause()
		self.world:emit("set_focus_list", "main_menu")
		self.is_transition = false
	end)
end

function Menu:state_update(dt)
	if self.is_transition then
		return
	end
	if Inputs.released("cancel") then
		self:menu_back()
	end

	local mx, my = love.mouse.getPosition()
	self.world:emit("update", dt)
	self.world:emit("check_mouse_hover", mx, my)
	self.world:emit("hover_effects")

	if self.current_state == Enums.menu_state.settings and not self.mb.flag_process then
		self.world:emit("update_settings", dt)
	end
end

function Menu:state_draw()
	if self.current_state ~= Enums.menu_state.exit then
		self.canvases.main:attach()
		self.camera:attach()
		self.world:emit("draw")
		if self.current_state == Enums.menu_state.settings and not self.mb.flag_process then
			local l, t = self.camera:getVisible()
			love.graphics.push()
			love.graphics.translate(l, t)
			self.world:emit("draw_settings")
			love.graphics.pop()
		end
		Fade.draw()
		self.camera:detach()
		self.canvases.main:detach()
		self.mb:post_process_draw()
		self.canvases.main:render()
	end
end

function Menu:setup_menu()
	local ww, wh = love.graphics.getDimensions()
	local bg_door = Resources.data.images.bg_door
	local bg_hallway = Resources.data.images.bg_hallway
	-- local sheet_title = Resources.data.images.sheet_title
	-- local subtitle = Resources.data.images.subtitle

	local bg_hw_w, bg_hw_h = bg_hallway:getDimensions()
	local bg_door_w, bg_door_h = bg_door:getDimensions()
	-- local title_w, title_h = sheet_title:getDimensions()
	-- local subt_w, subt_h = subtitle:getDimensions()

	local scale = math.min(ww / bg_door_w, wh / bg_door_h)
	local scale_hallway = math.min(ww / bg_hw_w, wh / bg_hw_h)
	-- local scale_title = math.min((bg_door_w * scale) / title_w, (bg_door_h * scale) / title_h)
	-- local scale_subt = math.min((title_w * scale_title) / subt_w, (title_h * scale) / subt_h)
	-- scale_subt = scale_subt * 0.75

	Concord.entity(self.world):assemble(Assemblages.Menu.bg_door, ww * 1.5, wh/2, scale, bg_door_w/2, bg_door_h/2)

	Concord.entity(self.world)
		:assemble(Assemblages.Menu.bg_hallway, ww/2, wh * 1.5, scale_hallway, bg_hw_w/2, bg_hw_h/2)

	self.e_desk = Concord.entity(self.world):assemble(Assemblages.Menu.desk, ww, wh)
	self.e_title = Concord.entity(self.world):assemble(Assemblages.Menu.sheet_title, ww, wh)
	-- self.subtitle = Concord.entity(self.world)
	-- 	:assemble(Assemblages.Menu.subtitle, ww * 0.25, wh * 1.5, self.title, scale_subt, subt_w/2, subt_h/2)

	local jamboree_fnt = "res/fonts/Jamboree.fnt"
	local jamboree_png = "res/fonts/Jamboree.png"
	local sdf_menu = love.graphics.newFontMSDF(jamboree_fnt, jamboree_png)
	local font_menu = Resources.data.fonts.menu
	local str_target_h = font_menu:getHeight()
	local str_h = sdf_menu:getHeight()
	local str_scale = str_target_h / str_h * 0.75
	local offset = 16
	local padding = 2

	local has_save = Save.valid_checkpoints
	local n_opt_sub = has_save and #options_sub or (#options_sub - 1)

	self.world:emit("create_list_group", "sub_menu", true, n_opt_sub)
	for i, str in ipairs(options_sub) do
		local lstr = string.lower(str)
		lstr = string.gsub(lstr, "%s+", "")
		local str_w = sdf_menu:getWidth(str) * str_scale
		local x = self.canvases.bot.width - str_w - offset
		local y = self.canvases.bot.y + (i * str_h) + (padding * i) - offset
		local id = "text_sub_" .. lstr

		local e = Concord.entity(self.world)
			:assemble(Assemblages.Menu.option_item, id, str, jamboree_fnt, jamboree_png, x, y, str_scale, i, 2, "sub_menu")
			:give("on_enter_menu", "on_" .. lstr)

		if not has_save and str == "Continue" then
			e:give("list_item_skip")
		end
	end

	self.world:emit("create_list_group", "main_menu", true, #options)
	for i, str in ipairs(options) do
		local lstr = string.lower(str)
		local str_w = sdf_menu:getWidth(str) * str_scale
		local x = self.canvases.bot.width - str_w - offset
		local y = self.canvases.bot.y + (i * str_h) + (padding * i) - offset
		local id = "text_" .. lstr

		Concord.entity(self.world)
			:assemble(Assemblages.Menu.option_item, id, str, jamboree_fnt, jamboree_png, x, y, str_scale, i, 1, "main_menu")
			:give("on_enter_menu", "on_" .. lstr, 0, lstr)
	end
	self.world:__flush()
end

function Menu:setup_about()
	local about = generate_about()
	local about_links = {
		"https://twitter.com/@flam8studio",
		"https://discord.gg/2W4tyyV",
		"https://flamendless.itch.io",
		"mailto:flamendless.studio@gmail.com",
	}
	local _, _, w, h = self.camera:getVisible()
	local base_x = w/2
	local base_y = h + 16
	local layout = false
	local layout_base_y = 0
	local largest = 0
	local dt_color = false
	local color = Palette.get("about_normal")

	Concord.entity(self.world):assemble(Assemblages.Menu.btn_back, 8, base_y):give("on_click", 1, "menu_back")

	for i, el in ipairs(about) do
		if type(el[1]) == "string" and el[1] ~= "_IMAGES" then
			local str = el[1]
			local resource_id = el[2] or "about_20"
			local font = Resources.data.fonts[resource_id]
			local space = el[3]
			local str_w = font:getWidth(str)
			local str_h = font:getHeight(str)
			local x = base_x - str_w/2
			local y = base_y
			if space then
				base_y = base_y + space
			end

			if str == "@LAYOUT:LEFT" then
				base_x = w * 0.25
				layout_base_y = base_y
				layout = true
			elseif str == "@LAYOUT:RIGHT" then
				base_x = w * 0.75
				layout_base_y = base_y
				layout = true
			elseif str == "@LAYOUT:CENTER" then
				base_x = w/2
				base_y = largest
				layout = false
			elseif str == "@COLOR" then
				color = Palette.get("about_hint")
				dt_color = true
			else
				if layout then
					y = layout_base_y
					layout_base_y = layout_base_y + str_h
					largest = math.max(largest, layout_base_y)
				end
				local id = "about_text_" .. i
				Concord.entity(self.world):assemble(Assemblages.Menu.about_text, id, resource_id, str, x, y, color)
				if dt_color then
					color = Palette.get("about_normal")
					dt_color = false
				end
				if not layout then
					base_y = base_y + str_h
				end
			end
		elseif type(el[1] == "string") and el[1] == "_IMAGES" then
			base_x = w/2
			base_y = h * 2
			local pad = 24
			local n = #el
			local n2 = (n - 1)/2
			for i2 = 2, n do
				local id = "about_image_" .. (i + i2)
				local resource_id = el[i2]
				local image = Resources.data.images[resource_id]
				local iw, ih = image:getDimensions()

				local bx = base_x - (n2 * iw)
				local x = bx + (iw * (i2 - 2)) + pad/2
				local y = base_y - ih/2 - pad/2
				Concord.entity(self.world)
					:assemble(Assemblages.Menu.about_ext_link, id, resource_id, x, y)
					:give("on_click", 1, "open_url", about_links[i2])
			end
		end
	end
end

function Menu:menu_unpause(bool)
	self.timeline:Unpause()
	if bool ~= nil then
		self.is_transition = bool
	end
end

function Menu:show_main_menu()
	for _, e in ipairs(self.pool_main_menu) do
		e:remove("hidden")
			:give("target_color", Palette.get("white", 1), duration_show)
			:give("lerp_on_finish", "menu_unpause", 0, false)
			:give("move_to_original", duration_pos)
	end
	self.current_state = Enums.menu_state.menu
	self.world:emit("set_focus_list", "main_menu")
end

function Menu:hide_main_menu(duration)
	if duration then
		if type(duration) ~= "number" then
			error('Assertion failed: type(duration) == "number"')
		end
	end
	for _, e in ipairs(self.pool_main_menu) do
		e:give("target_color", Palette.get("white", 0), duration or duration_hide)
			:give("lerp_on_finish_multi", { signal = "hide_entity", args = { e } }, { signal = "menu_unpause" })
			:give("move_by", target_x, 0, duration or duration_pos)
	end
end

function Menu:show_sub_menu()
	for _, e in ipairs(self.pool_sub_menu) do
		e:remove("hidden")
			:give("target_color", Palette.get("white", 1), duration_show)
			:give("lerp_on_finish", "menu_unpause", 0, false)
			:give("move_to_original", duration_pos)
	end

	Timer.after(duration_show, function()
		self.current_state = Enums.menu_state.sub_menu
		local override_cursor = Save.valid_checkpoints and 1 or 2
		self.world:emit("set_focus_list", "sub_menu", override_cursor)
	end)
end

function Menu:hide_sub_menu(duration)
	if duration then
		if type(duration) ~= "number" then
			error('Assertion failed: type(duration) == "number"')
		end
	end
	for _, e in ipairs(self.pool_sub_menu) do
		e:give("target_color", Palette.get("white", 0), duration or duration_hide)
			:give("lerp_on_finish", "hide_entity", 0, e)
			:give("move_by", target_x, 0, duration or duration_pos)
	end
end

function Menu:on_newgame()
	local ww, wh = love.graphics.getDimensions()
	local dur = 2
	local timer = 1.25
	-- TODO turn off BGM

	self:hide_sub_menu()
	self.e_desk:give("hidden")

	--TODO change target_color
	for _, e in ipairs(self.pool_text) do
		e:give("target_color", Palette.get("white", 0), dur)
	end

	local e_desk_fast = Concord.entity(self.world):assemble(Assemblages.Menu.desk_fast, ww, wh)

	Timer.after(timer, function()
		-- TODO: (Brandon) add sudden static sound
		e_desk_fast:give("hidden")
		Timer.after(timer, function()
			self.world:emit("switch_state", "Intro")
		end)
	end)
end

function Menu:on_continue()
	-- TODO load saved game here
end

function Menu:on_settings()
	local l, t, w, h = self.camera:getWorld()
	local cworld = { x = l, y = t, w = w, h = h }
	self.world:emit("init_settings")
	self:MB_move(cworld.w, nil, ANGLE_RIGHT)
end

function Menu:on_about()
	local l, t, w, h = self.camera:getWorld()
	local cworld = { x = l, y = t, w = w, h = h }
	if not about_done then
		self:setup_about()
		about_done = true
	end
	self:MB_move(nil, cworld.h, ANGLE_UP)
end

function Menu:on_exit()
	local btn = love.window.showMessageBox(
		"Alert",
		"Are you sure you want to exit the game?",
		{ "Exit", "Cancel", escapebutton = 2 }
	)

	if btn == 1 then
		love.event.quit(0)
	elseif btn == 2 then
		self.current_state = Enums.menu_state.menu
		Log.info("Switched Menu State to:", self.current_state)
	end
end

function Menu:menu_back()
	if self.current_state == Enums.menu_state.sub_menu and not self.is_transition then
		self.is_transition = true
		self:hide_sub_menu()
		self:show_main_menu()
	elseif self.current_state ~= Enums.menu_state.menu and self.current_state ~= Enums.menu_state.play then
		self:MB_return()
	end
end

function Menu:MB_move(tx, ty, angle)
	-- TODO add motion blur sound
	local cx, cy = self.camera:getPosition()
	local cpos = { x = cx, y = cy }
	local duration = 1
	local distance = { 1.0 }
	local prev_angle = (angle + 180) % 360

	self.mb.flag_process = true
	Flux.to(cpos, duration, { x = tx, y = ty })
		:onstart(function()
			self.mb:store_previous(cx, cy, prev_angle)
			self.mb:set_angle(angle)
			Flux.to(distance, duration, { [1] = 0.0 }):onupdate(function()
				self.mb:set_strength(distance[1])
			end)
		end)
		:onupdate(function()
			self.camera:setPosition(cpos.x, cpos.y)
			self.world:emit("on_camera_move", self.camera)
		end)
		:oncomplete(function()
			self.mb.flag_process = false
		end)
end

function Menu:MB_return()
	-- TODO add motion blur sound
	local cx, cy = self.camera:getPosition()
	local cpos = vec2(cx, cy)
	local duration = 1
	local distance = { 1.0 }
	local temp_mb = self.mb.previous

	self.mb.flag_process = true
	Flux.to(cpos, duration, { x = temp_mb.target.x, y = temp_mb.target.y })
		:onstart(function()
			self.mb:set_angle(temp_mb.angle)
			Flux.to(distance, duration, { [1] = 0.0 }):onupdate(function()
				self.mb:set_strength(distance[1])
			end)
		end)
		:onupdate(function()
			self.camera:setPosition(cpos.x, cpos.y)
			self.world:emit("on_camera_move", self.camera)
		end)
		:oncomplete(function()
			self.current_state = Enums.menu_state.menu
			Log.info("Switched Menu State to:", self.current_state)
			self.mb.flag_process = false
		end)
end

function Menu:state_mousepressed(mx, my, mb)
	self.world:emit("mousepressed", mx, my, mb)
end

function Menu:open_url(str)
	if type(str) ~= "string" then
		error('Assertion failed: type(str) == "string"')
	end
	love.system.openURL(str)
end

Menu["on_list_cursor_update_" .. "main_menu"] = function(self, e_hovered)
	for _, e in ipairs(self.pool_main_menu) do
		local pos = e.pos
		local color = e.color
		if e == e_hovered then
			color_to(color, color_select, dur_in)
			Flux.to(pos, dur_in, { x = pos.orig_x - offset_x })
		else
			color_to(color, color.original, dur_out)
			Flux.to(pos, dur_out, { x = pos.orig_x })
		end
	end
end

Menu["on_list_cursor_update_" .. "sub_menu"] = function(self, e_hovered)
	for _, e in ipairs(self.pool_sub_menu) do
		local pos = e.pos
		local color = e.color
		if e.list_item_skip then
			color_to(color, color_disabled, dur_out)
			Flux.to(pos, dur_out, { x = pos.orig_x })
		elseif e == e_hovered then
			color_to(color, color_select, dur_in)
			Flux.to(pos, dur_in, { x = pos.orig_x - offset_x })
		else
			color_to(color, color.original, dur_out)
			Flux.to(pos, dur_out, { x = pos.orig_x })
		end
	end
end

Menu["on_list_item_interact_" .. "main_menu"] = function(self, e_hovered)
	local text = e_hovered.text.value
	if text == "Play" then
		self.is_transition = true
		self:hide_main_menu()
		self:show_sub_menu()
	elseif text == "Settings" then
		self.current_state = Enums.menu_state.settings
		self:on_settings()
	elseif text == "About" then
		self.current_state = Enums.menu_state.about
		self:on_about()
	elseif text == "Exit" then
		self.current_state = Enums.menu_state.exit
		self:on_exit()
	end
end

Menu["on_list_item_interact_" .. "sub_menu"] = function(self, e_hovered)
	local text = e_hovered.text.value
	if text == "Continue" then
		self:on_continue()
	elseif text == "New Game" then
		self:on_newgame()
	end
end

return Menu
