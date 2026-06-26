local DialoguesSystem = Concord.system()

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
end

function DialoguesSystem:ev_main_camera_setup(cam)
	assert(type(cam) == "table")

	--TODO: finalize values
	local font = Resources.data.fonts.dialogue
	local ww, wh = love.graphics.getDimensions()
	local _, _, _, h = cam:getWindow()
	local barh = h * CAM_BAR_RATIO
	local basey = wh - barh + 12
	local offx = 32

	local cfg = {
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
			padding = 0,
			background_color = Palette.colors.black,
			border_color = Palette.colors.black,
		}

	}

	self.ui = LoveInk.DialogueUI.new(cfg)

	self.ui.on_choice_made = function(index)
		self.current_content = self.dialogue:choose(index)
		self.ui:showContent(self.current_content)
		self:check_if_fin()
	end
end

function DialoguesSystem:start_dialogue(e, e_other)
	assert(e.__isEntity)
	assert(e_other.__isEntity)
	local dialogue_key = e_other.dialogue_key.value
	assert(type(dialogue_key) == "string")

	if self.dialogue:getCurrentKnot() ~= dialogue_key then
		self.e_dialogue = e_other
		self.dialogue:divertTo(dialogue_key)
		self.current_content = self.dialogue:getNext()
		self.ui:showContent(self.current_content)

		-- for now let's just pause the player
		self.world:emit("toggle_component", e, "can_move", false)
		self.world:emit("toggle_component", e, "can_interact", false)
		self.world:emit("toggle_component", e, "can_run", false)

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

function DialoguesSystem:check_if_fin()
	if self.dialogue:getCurrentKnot() == DIALOGUE_FIN then
		self.world:emit("ev_dialogue_fin")
		--TODO: Finalize
		local e_player = self.world:getResource("e_player")
		if e_player then
			self.world:emit("toggle_component", e_player, "can_move", true)
			self.world:emit("toggle_component", e_player, "can_interact", true)
			self.world:emit("toggle_component", e_player, "can_run", true)
		end
		self.current_content = nil
		self.e_dialogue = nil
	end
end

function DialoguesSystem:ev_advance()
	if self.current_content and self.current_content.type == "text" then
		if self.ui:isTextComplete() then
			self.current_content = self.dialogue:getNext()
			self.ui:showContent(self.current_content)
		else
			self.ui:skipTypewriter()
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

	--TODO: if dialogue is active, what entities/systems do we want to pause/block?? How??
	self.ui:update(dt)
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
		-- love.graphics.print(component.prompt, component.x, draw_y)
		love.graphics.printf(component.prompt, component.x, draw_y, component.width, "center")
		draw_y = draw_y + fh + component.spacing
	end

	for i, choice in ipairs(component.choices) do
		local button_y = draw_y + (i - 1) * (component.button_height + component.spacing)
		local is_hovered = (i == component.hovered_index)

		if is_hovered then
			love.graphics.setColor(component.hover_color)
		else
			love.graphics.setColor(component.normal_color)
		end

		local choice_text = type(choice) == "string" and choice or choice[1]
		local tw = component.font:getWidth(choice_text)

		-- TODO: fix coords
		local bx = ((component.x + component.width)/2) - tw/2
		love.graphics.rectangle("fill", bx, button_y, tw, fh)

		love.graphics.setColor(component.border_color)
		love.graphics.rectangle("line", bx, button_y, tw, fh)

		love.graphics.setColor(component.text_color)
		love.graphics.setFont(component.font)

		local text_x = component.x + component.padding
		local text_y = button_y + (component.button_height - fh) / 2

		love.graphics.printf(choice_text, text_x, text_y, component.width, "center")
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
		fn(DialoguesSystem, component)
	end
end

-- TODO: ponder whether we want mouse or key based interactions
function DialoguesSystem:state_mousepressed(mx, my, mb)
	if not self.dialogue then return end
	if self.ui:mousepressed(mx, my, mb) then
		return
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
		Slab.EndWindow()
	end
end

return DialoguesSystem
