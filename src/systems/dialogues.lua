local DialoguesSystem = Concord.system()

local function create_choice_bloodbar_mid(cfg)
	Log.info("created new choice bloodbar mid")
	return {
		instance = BloodBar({
			speed = 8,
			opacity = 1,
			tint = 2,
			direction = {0, -1},
			enabled = true,
		}),
		x = cfg.choicelist.x + cfg.choicelist.width/2,
		y = cfg.choicelist.y + 36,
		w = 24,
		h = 60,
		tween = nil,
	}
end

function DialoguesSystem:init(world)
	self.world = world
end

function DialoguesSystem:state_setup()
	local current_id = string.lower(GameStates.current_id)
	Log.info("Loading dialogues data", current_id)

	local data = Data.Dialogues[current_id]
	if not data then
		Log.warn("No current id '%s' defined in Dialogues data", current_id)
		return
	end

	self.dialogue = LoveInk.Dialogue.new(data, "start")
	self.choices_history = {}
end

function DialoguesSystem:ev_main_camera_setup(cam)
	assert(type(cam) == "table")

	local font = Resources.data.fonts.dialogue
	local ww, wh = love.graphics.getDimensions()
	local _, _, _, h = cam:getWindow()
	local barh = h * CAM_BAR_RATIO
	local basey = wh - barh + 12
	local offx = 32

	self.cfg = {
		textbox = {
			x = offx,
			y = basey,
			width = ww - offx * 2,
			height = font:getHeight(),
			typewriter_speed = 40,
			font = font,
			padding = 0,
			background_color = Palette.colors.black,
			border_color = Palette.colors.black,
		},
		choicelist = {
			x = offx,
			y = basey,
			width = ww - offx * 2,
			button_height = font:getHeight(),
			font = font,
			padding = 48,
			background_color = Palette.colors.black,
			border_color = Palette.colors.black,
		}

	}

	self.blood_bar_mid = create_choice_bloodbar_mid(self.cfg)
	self.blood_bars = {
		BloodBar({speed = 1, opacity = 0, enabled = true}),
		BloodBar({speed = 1, opacity = 0, enabled = true}),
	}

	self.ui = LoveInk.DialogueUI.new(self.cfg)

	self.ui.on_choice_made = function(index)
		self.current_content = self.dialogue:choose(index)
		self.ui:showContent(self.current_content)
		self:check_if_fin()
	end
end

function DialoguesSystem:start_dialogue(e, e_other, override_dialogue_key)
	assert(e.__isEntity)
	assert(e_other.__isEntity)
	if override_dialogue_key then assert(type(override_dialogue_key) == "string", override_dialogue_key) end
	local dialogue_key = override_dialogue_key or e_other.dialogue_key.value
	assert(type(dialogue_key) == "string")

	if self.dialogue:getCurrentKnot() ~= dialogue_key then
		self.blood_bar_mid = create_choice_bloodbar_mid(self.cfg)

		self.e_dialogue = e_other
		self.dialogue:divertTo(dialogue_key)
		self.current_content = self.dialogue:getNext()
		self.ui:showContent(self.current_content)

		--TODO: Implement pause (b)
		if e_other.dialogue_force_pause then
			for _, key in ipairs(e_other.dialogue_force_pause.values) do
				local e_to_pause = self.world:getEntityByKey(key)
				if e_to_pause then
					e_to_pause:give("paused")
				else
					Log.warning("Key was referenced in dialogue_force_pause but does not exist in world", key)
				end
			end
		end
	end
end

function DialoguesSystem:force_end_dialogue()
	self.dialogue:divertTo(DIALOGUE_FIN)
	self:check_if_fin()
end

function DialoguesSystem:check_if_fin()
	if self.dialogue:getCurrentKnot() == DIALOGUE_FIN then
		self.world:emit("ev_dialogue_fin")
		self.current_content = nil
		self.e_dialogue = nil
	end
end

function DialoguesSystem:ev_advance()
	if self.current_content then
		if self.current_content.type == "text" then
			if self.ui:isTextComplete() then
				self.current_content = self.dialogue:getNext()
				self.ui:showContent(self.current_content)
			else
				self.ui:skipTypewriter()
			end
		elseif self.current_content.type == "choice" then
			self.blood_bar_mid = create_choice_bloodbar_mid(self.cfg)
		end

		self:check_if_fin()
	end
end

function DialoguesSystem:state_update(dt)
	if not self.dialogue then return end

	-- if self.dialogue:getCurrentKnot() == DIALOGUE_FIN then
	-- 	self.current_content = nil
	-- end

	--TODO: use enums for keys instead of strings
	if Inputs.released("interact") then
		self:ev_advance()
	end

	local hovered_index
	local is_repeat_choice
	for _, component in ipairs(self.ui.components) do
		if component.enabled then
			if component.id == "textbox" then
				component:update(dt)

			elseif component.id == "choicelist" then
				hovered_index = component.hovered_index
				if hovered_index then
					if self.choices_history[component] then
						is_repeat_choice = true
					else
						self.choices_history[component] = true
					end
				end

				if Inputs.released("left") then
					component.hovered_index = 1
					hovered_index = 1
					self.blood_bars[hovered_index].data.opacity = 1
				elseif Inputs.released("right") then
					component.hovered_index = 2
					hovered_index = 2
					self.blood_bars[hovered_index].data.opacity = 1
				elseif Inputs.released("interact") then
					if component.hovered_index and component.on_choice then
						component.on_choice(component.hovered_index)
					end
				end
			end
		end
	end

	if not self.blood_bar_mid.tween and hovered_index and not is_repeat_choice then
		self.blood_bar_mid.tween = Flux.to(
			self.blood_bar_mid.instance.data,
			1,
			{ opacity = 0 }
		):onupdate(function()
			self.blood_bar_mid.instance:update(dt)
		end)

		local bb = self.blood_bars[hovered_index]
		Flux.to(bb.data, 0.5, {opacity = 1}):onupdate(function() bb:update(dt) end)
	end

	self.blood_bar_mid.instance:update(dt)

	for i, bb in ipairs(self.blood_bars) do
		local hovered = (i == hovered_index)
		bb.data.speed = hovered and 1.2 or 0.6
		bb.data.tint = hovered and 2 or 1
		bb.data.opacity = hovered and 1.0 or 0
		bb:update(dt)
	end
end

function DialoguesSystem:state_draw()
end

function DialoguesSystem:draw_ui()
	if not self.dialogue then return end
	if self.current_content and not self.dialogue:hasEnded() then
		local f = love.graphics.getFont()
		self:custom_dialogue_ui_draw()
		-- self.ui:draw() -- original
		love.graphics.setFont(f)
	end
end

function DialoguesSystem:custom_textbox_ui_draw(component)
	if not component.visible then return end
	local fh = component.font:getHeight()

	love.graphics.setColor(component.background_color)
	love.graphics.rectangle("fill", component.x, component.y, component.width, component.height)

	love.graphics.setColor(component.border_color)
	love.graphics.rectangle("line", component.x, component.y, component.width, component.height)

	local text_y = component.y + component.padding

	love.graphics.setColor(component.text_color)
	love.graphics.setFont(component.font)

	local max_width = component.width - (component.padding * 2)
	local _, wrapped_text = component.font:getWrap(component.display_text, max_width)

	for _, line in ipairs(wrapped_text) do
		-- love.graphics.print(line, component.x + component.padding, text_y)
		love.graphics.printf(line, component.x + component.padding, text_y, component.width, "center")
		text_y = text_y + fh
	end

	if component.is_complete then
		love.graphics.setColor(1, 1, 1, 0.5 + 0.5 * math.sin(love.timer.getTime() * 4))
		local indicator = Inputs.rev_map.interact
		local indicator_width = component.font:getWidth(indicator)
		love.graphics.print(indicator,
			component.x + component.width - component.padding - indicator_width,
			component.y + component.height - component.padding - fh)
	end
end

function DialoguesSystem:custom_choicelist_ui_draw(component)
	if not component.visible or #component.choices == 0 then return end
	local fh = component.font:getHeight()
	local draw_y = component.y

	if component.prompt then
		love.graphics.setColor(component.text_color)
		love.graphics.setFont(component.font)
		love.graphics.printf(component.prompt, component.x, draw_y, component.width, "center")
		draw_y = draw_y + fh + component.spacing
	end

	local max_tw = 0
	for _, choice in ipairs(component.choices) do
		local choice_text = type(choice) == "string" and choice or choice[1]
		max_tw = math.max(max_tw, component.font:getWidth(choice_text))
	end

	local centerx = component.x + component.width / 2

	self.blood_bar_mid.instance:draw(
		self.blood_bar_mid.x - self.blood_bar_mid.w / 2,
		self.blood_bar_mid.y,
		self.blood_bar_mid.w,
		self.blood_bar_mid.h
	)

	for i, choice in ipairs(component.choices) do
		local choice_text = type(choice) == "string" and choice or choice[1]

		local rw = max_tw + component.padding * 2
		local rh = fh + component.padding/3
		local by = draw_y - rh/6
		local bx = 0

		if i == 1 then
			bx = component.x + component.width / 4 - rw/2
		elseif i == 2 then
			bx = component.x + component.width * 0.75 - rw/2
		end

		local bb = self.blood_bars[i]
		bb:draw(bx, by, rw, rh)

		love.graphics.setColor(component.text_color)
		love.graphics.setFont(component.font)

		local limit = component.width/2
		if i == 1 then
			love.graphics.printf(choice_text, component.x, draw_y, limit, "center")
		elseif i == 2 then
			love.graphics.printf(choice_text, centerx, draw_y, limit, "center")
		end
	end
end

local mapping = {
	textbox = DialoguesSystem.custom_textbox_ui_draw,
	choicelist = DialoguesSystem.custom_choicelist_ui_draw,
}

function DialoguesSystem:custom_dialogue_ui_draw()
	for _, component in ipairs(self.ui.components) do
		local fn = mapping[component.id]
		if DEV then
			assert(fn ~= nil, "unimplemented custom renderer for component " .. component.id)
		end
		fn(self, component)
	end
end

if DEV then
	function DialoguesSystem:debug_update(dt)
		if not self.debug_show then return end

		self.debug_show = Slab.BeginWindow("dialogues", {
			Title = "Dialogues",
			IsOpen = self.debug_show,
		})
		Slab.Text("ID: " .. GameStates.current_id)

		local start_disabled = self.current_content ~= nil
		if Slab.Button("start", { Disabled = start_disabled }) then
			if self.dialogue:getCurrentKnot() == DIALOGUE_FIN then
				self.dialogue:divertTo("start")
			end
			self.current_content = self.dialogue:getNext()
			self.ui:showContent(self.current_content)
		end

		--TODO: Maybe store knots in a map so that map[knot_name]count
		Slab.Text("Dialogue:")
		Slab.Indent()
		if self.e_dialogue then
			Slab.Text("Dialogue Entity ID: " .. self.e_dialogue.id.value)
		end
		Slab.Text("Current Knot: " .. self.dialogue:getCurrentKnot())
		Slab.Text("Visit Count: " .. self.dialogue:getKnotVisitCount(self.dialogue:getCurrentKnot()))
		Slab.Unindent()

		local _ = Slab.CheckBox(self.ui:isTextComplete(), "Is Text Complete")
		if self.current_content then
			Slab.Text("Current Content:")
			Slab.Indent()
			Slab.Text("Type: " .. self.current_content.type)
			Slab.Text("Content: " .. (self.current_content.content or ""))
			Slab.Text("Speaker: " .. (self.current_content.speaker or ""))
			Slab.Unindent()
		end

		-- if self.blood_bar_mid then
		-- 	Slab.Text("BloodBar Mid:")
		-- 	Slab.Indent()
		-- 	Slab.Text("X: " .. self.blood_bar_mid.x)
		-- 	Slab.Text("Y: " .. self.blood_bar_mid.y)
		-- 	Slab.Text("W: " .. self.blood_bar_mid.w)
		-- 	Slab.Text("H: " .. self.blood_bar_mid.h)
		-- 	Slab.Text("Opacity: " .. self.blood_bar_mid.instance.data.opacity)
		-- 	Slab.Text("Tint: " .. self.blood_bar_mid.instance.data.tint)
		-- 	Slab.Unindent()
		-- end
		Slab.EndWindow()
	end
end

return DialoguesSystem
