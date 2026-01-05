local Renderer = Concord.system({
	pool_circle = { "circle", "draw_mode", "pos" },
	pool_point = { "point", "pos" },
	pool_rect = { "rect", "pos", "draw_mode" },
	pool_text = { "text", "pos" },
	pool_static_text = { "static_text", "pos", "font" },
	pool_bg = { "bg", "sprite", "pos" },
	pool_sprite = { "sprite", "pos", "!bg" },

	pool_layer = { "sprite", "pos", "layer" },
})

local renderer_per_pool = {
	pool_circle = Renderers.Circle,
	pool_point = Renderers.Point,
	pool_rect = Renderers.Rect,
	pool_text = Renderers.Text,
	pool_static_text = Renderers.Text,
	pool_bg = Renderers.Sprite,
	pool_sprite = Renderers.Sprite,

	pool_layer = Renderers.Sprite,
}

for k in pairs(renderer_per_pool) do
	if not Renderer.__definition[k] then
		error(k .. " must exists")
	end
end

Renderer.draw_bg = Renderers.Sprite.render_bg

local function get_list(self, e_or_bool)
	if e_or_bool then
		if not (type(e_or_bool) == "boolean" or e_or_bool.__isEntity) then
			error('Assertion failed: type(e_or_bool) == "boolean" or e_or_bool.__isEntity')
		end
	end
	local is_ui = e_or_bool and (type(e_or_bool) == "boolean" or e_or_bool.ui_element)
	return is_ui and self.list_ui or self.list
end

local function fn_sort_z(a, b)
	local a_z, b_z = a.z_index, b.z_index
	if a_z == nil or b_z == nil then
		return
	end
	if a_z.sortable and b_z.sortable then
		return a.pos.y < b.pos.y
	elseif a_z.current and b_z.current then
		return a_z.current < b_z.current
	end
	return a_z.value < b_z.value
end

function Renderer:init(world)
	self.world = world
	self.list, self.list_ui = Ctor.CustomList(), Ctor.CustomList()

	self.list.__id = "list"
	self.list_ui.__id = "list_ui"

	for _, renderer in pairs(Renderers) do
		if renderer.init then
			renderer.init(self)
		end
	end

	Renderers.Sprite.debug_list = self.list
	Renderers.BB.list = self.list
	Renderers.BB.list_ui = self.list_ui

	for pool_id in pairs(self.__definition) do
		local pool = self[pool_id]
		pool.id = pool_id
		pool.onAdded = function(p, e)
			self:pool_on_added(p, e)
		end
		pool.onRemoved = function(p, e)
			self:pool_on_removed(p, e)
		end
	end
end

function Renderer:sort_by_z(list)
	if list.size == 0 then
		return
	end
	list:sort(fn_sort_z)
	for i, e in ipairs(list) do
		local z_index = e.z_index
		if z_index then
			z_index.current = i
		end
	end
end

function Renderer:pool_on_added(pool, e)
	local should_sort = false
	if pool == self.pool_layer or pool == self.pool_sprite then
		Renderers.Sprite.setup_sprite(e)
		should_sort = e.z_index ~= nil
	elseif pool == self.pool_bg then
		Renderers.Sprite.set_bg(e)
	elseif pool == self.pool_text and e.sdf then
		if not e.font_sdf then
			error("sdf must have font_sdf")
		end
		if not not e.font then
			error("sdf must NOT have font")
		end
	elseif pool == self.pool_static_text then
		if not not e.sdf then
			error("static_font can NOT use sdf font")
		end
		e.static_text.obj = love.graphics.newText(e.font.value, e.static_text.value)
	end

	local list = get_list(self, e)
	if list:has(e) then
		Log.warn(e.id.value, "is already in list")
	else
		list:add(e)
		e.renderer = renderer_per_pool[pool.id]
		if should_sort then
			self:sort_by_z(list)
		end
	end
end

function Renderer:pool_on_removed(pool, e)
	local list = get_list(self, e)
	if list:remove(e) then
		self:sort_by_z(list)
	end
end

function Renderer:draw_ui()
	self:draw(true)
end

function Renderer:draw(is_ui)
	if is_ui then
		if not (type(is_ui) == "boolean") then
			error('Assertion failed: type(is_ui) == "boolean"')
		end
	end

	if not is_ui then
		Renderers.Sprite.debug_batching()
	end

	local list = get_list(self, is_ui)
	for _, e in ipairs(list) do
		local culled = e.cullable and e.cullable.value
		local is_not_drawn = e.nf_renderer or e.hidden or culled

		if not is_not_drawn then
			local no_shader, temp_shader = e.no_shader
			if no_shader then
				temp_shader = love.graphics.getShader()
				love.graphics.setShader()
			end

			local color = e.color
			if color then
				love.graphics.setColor(color.value)
			end

			local custom_renderer = e.custom_renderer
			if custom_renderer then
				self.world:emit(custom_renderer.value, e)
			else
				e.renderer.render(e)
			end

			if not is_ui and e.renderer == Renderers.Sprite then
				Renderers.Sprite.debug_batching_update(e)
			end

			if no_shader then
				love.graphics.setShader(temp_shader)
			end
		end
	end
end

function Renderer:cleanup()
	tablex.clear(self.list)
	tablex.clear(self.list_ui)
	for _, renderer in pairs(Renderers) do
		if renderer.cleanup then
			renderer.cleanup()
		end
	end
end



local search = ""

local function show_list(id, list)
	if Slab.BeginTree(id .. " size: " .. #list) then
		Slab.Indent()
		for i, e in ipairs(list) do
			local culled = e.cullable and e.cullable.value
			local is_not_drawn = e.nf_renderer or e.hidden or culled
			local e_id = e.id.value
			if #search == 0 or stringx.contains(e_id, search) then
				if Slab.CheckBox(not is_not_drawn, i) then
					is_not_drawn = not is_not_drawn
					if is_not_drawn then
						e:give("hidden")
					else
						e:remove("hidden")
					end
				end
				Slab.SameLine()
				Slab.Text(e_id)
				Slab.SameLine()
				Slab.Text(e.renderer.id)
			end
		end
		Slab.Unindent()
		Slab.EndTree()
	end
end

function Renderer:debug_update(dt)
	if not self.debug_show then
		return
	end
	self.debug_show = Slab.BeginWindow("renderer", {
		Title = "Renderer",
		IsOpen = self.debug_show,
	})

	if Slab.Input("search", { Text = search }) then
		search = Slab.GetInputText()
	end

	show_list("list", self.list)
	show_list("ui", self.list_ui)

	for _, v in pairs(Renderers) do
		if v.debug_update then
			if Slab.CheckBox(v.debug_show, v.id) then
				v.debug_show = not v.debug_show
			end
			if v.debug_show then
				v.debug_update(dt)
			end
		end
	end
	Slab.EndWindow()
end

function Renderer:debug_draw()
	if not self.debug_show then
		return
	end
	for _, v in pairs(Renderers) do
		if v.debug_show and v.debug_draw then
			v.debug_draw()
		end
	end
end

function Renderer:debug_draw_ui()
	if not self.debug_show then
		return
	end
	local camera = self.world:getResource("camera")
	for _, v in pairs(Renderers) do
		if v.debug_show and v.debug_draw then
			v.debug_draw_ui(camera)
		end
	end
end

return Renderer
