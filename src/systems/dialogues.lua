local DialoguesSystem = Concord.system({
	pool = { "dialogue_item", "text_t" },
	pool_choice = {
		constructor = Ctor.ListByID,
		id = "dialogue_choices",
	},
})

local c_hc = Palette.colors.hovered_choice
local PAD = 32

function DialoguesSystem:init(world)
	self.world = world
	self.is_waiting = false
	self.world:emit("create_dialogue_key")
	self.pool_choice.onAdded = function(pool, e)
		if e.item_id.value ~= Enums.item.choice then
			self.pool_choice:remove(e)
		end
	end
end

function DialoguesSystem:create_tle()
	self.timeline = TLE.Do(function()
		while true do
			local text_t = self.e_dialogue.text_t
			local dialogues = text_t and text_t.value
			local current_line = dialogues and dialogues[text_t.current_index]

			if current_line then
				text_t.current_index = text_t.current_index + 1
				local should_pause = true
				local bool, signal, handle_self = Dialogues.check_signal(current_line)
				Log.trace(
					"Dialogues system",
					"bool", bool,
					"signal", signal,
					"handle_self", handle_self
				)

				if bool then
					self.world:emit(signal, self.e_dialogue, dialogues)
					current_line = ""
					text_t.max_n = text_t.max_n - 1

					if text_t.current_index > text_t.max_n then
						should_pause = false
					end
				end

				if handle_self then
					self.world:emit("show_key", "dialogue", true)
					self.e_dialogue:remove("text_can_proceed"):remove("hidden"):give("text", current_line)
				end

				if should_pause then
					self.timeline:Pause()
				end
			elseif text_t and (text_t.current_index > text_t.max_n) then
				self:on_dialogue_reached_end()
			else
				self.timeline:Pause()
			end
		end
	end)
end

function DialoguesSystem:create_e_dialogue()
	local camera = self.world:getResource("camera")
	if not camera then
		error("camera resource should be set by now")
	end
	local l, _, w, h = camera:getWindow()
	local x = l + PAD
	local y = h - h * 0.15/2
	self.e_dialogue = Concord.entity(self.world)
		:give("id", "dialogue_holder")
		:give("font", "ui")
		:give("color", Palette.get("ui_dialogue"))
		:give("text", "")
		:give("dialogue_item")
		:give("ui_element")
		:give("transform", 0, 1, 1, 0, 0.5)
		:give("layer", "dialogue", 3)
		:give("reflowprint", w - PAD * 2, "left")
		:give("pos", x, y)
	self:create_tle()
end

function DialoguesSystem:update(dt)
	if self.is_waiting then
		return
	end
	if not self.e_dialogue then
		self:create_e_dialogue()
	end
	if Inputs.released("interact") and #self.pool_choice == 0 then
		self:proceed_dialogue()
	end
end

function DialoguesSystem:wait_dialogue(bool)
	if not (type(bool) == "boolean") then
		error('Assertion failed: type(bool) == "boolean"')
	end
	self.is_waiting = bool
end

function DialoguesSystem:spawn_dialogue(dialogues_t, main, sub)
	if not (type(dialogues_t) == "table") then
		error('Assertion failed: type(dialogues_t) == "table"')
	end
	if not (type(main) == "string") then
		error('Assertion failed: type(main) == "string"')
	end
	if not (type(sub) == "string") then
		error('Assertion failed: type(sub) == "string"')
	end
	self.e_dialogue:give("dialogue_meta", main, sub):give("text_t", dialogues_t)
	self:populate_choices(dialogues_t)
	if Dialogues.validate(dialogues_t) then
		self.world:emit("on_interact_or_inventory")
	end
	self.timeline:Unpause()
end

function DialoguesSystem:spawn_dialogue_ex(dialogue_t, signal_after, ...)
	if not (type(dialogue_t) == "table") then
		error('Assertion failed: type(dialogue_t) == "table"')
	end
	if not (#dialogue_t ~= 0) then
		error("Assertion failed: #dialogue_t ~= 0")
	end
	if signal_after then
		if not (type(signal_after) == "string") then
			error('Assertion failed: type(signal_after) == "string"')
		end
	end
	self:spawn_dialogue(dialogue_t, "_none", "_none")
	if signal_after then
		self.e_dialogue:give("on_dialogue_end", signal_after, 0, ...)
	end
end

function DialoguesSystem:on_dialogue_reached_end(e)
	if self.is_waiting then
		self.timeline:Pause()
		return
	end

	e = e or self.e_dialogue
	if e.item_id then
		self.world:emit("destroy_list", "dialogue_choice")
	end

	if e.has_choices then
		e:give("hidden")
		self:show_choices()
	else
		local on_d_end = e.on_dialogue_end
		if on_d_end then
			self.world:emit(on_d_end.signal, unpack(on_d_end.args))
		else
			self.world:emit("on_leave_interact_or_inventory")
			self.world:emit("set_system_to", "inventory", true)
			e:remove("dialogue_meta"):remove("text_t"):remove("text"):remove("item_id"):remove("has_choices")
			self.e_dialogue
				:remove("dialogue_meta")
				:remove("text_t")
				:remove("text")
				:remove("item_id")
				:remove("has_choices")
		end
		self.world:emit("show_key", "dialogue", false)
	end
	self.timeline:Pause()
end

function DialoguesSystem:update_dialogues(new_dialogues_t)
	if not (type(new_dialogues_t) == "table") then
		error('Assertion failed: type(new_dialogues_t) == "table"')
	end
	if not self.e_dialogue.item_id then
		self.e_dialogue:give("text_t", new_dialogues_t)
		self.timeline:Unpause()
	else
		local d = self.e_dialogue.dialogue_meta
		self:spawn_dialogue(new_dialogues_t, d.main, d.sub)
	end
end

function DialoguesSystem:proceed_dialogue()
	for _, e in ipairs(self.pool) do
		--TODO: (Brandon) add devtool
		if e.text_skipped then
			e:remove("text_skipped")
		elseif e.text_can_proceed then
			local rfp = e.reflowprint
			rfp.dt = 0
			rfp.current = 1
			self.timeline:Unpause()
		end
	end
end

function DialoguesSystem:show_choices()
	local d = self.e_dialogue.dialogue_meta
	local l, _, _, h = self.world:getResource("camera"):getWindow()
	local c = self.e_dialogue.has_choices
	local font = Resources.data.fonts.ui
	local y = h - h * 0.15/2
	local p2 = PAD * 2
	local prev_x = l + p2
	local choice_t = self.e_dialogue.text_t.value.choices
	self.world:emit("create_list_group", "dialogue_choices", false, #choice_t)

	for _, str in ipairs(c.value) do
		local id = "choice_" .. str
		local fw = font:getWidth(str)
		local x = prev_x
		prev_x = x + fw + p2
		for _, v in ipairs(choice_t) do
			if v[1] == str then
				choice_t = tablex.copy(v)
				table.remove(choice_t, 1)
				break
			end
		end

		Concord.entity(self.world)
			:assemble(Assemblages.UI.choice, id, str, choice_t, x, y)
			:give("reflowprint", fw + PAD * 2, "left")
			:give("dialogue_meta", d.main, d.sub)
			:give("list_item")
			:give("list_group", "dialogue_choices")
		self:populate_choices(choice_t)
	end

	self.world:emit("set_focus_list", "dialogue_choices")
end

function DialoguesSystem:populate_choices(t)
	if not (type(t) == "table") then
		error('Assertion failed: type(t) == "table"')
	end
	local choices = {}
	if t.choices then
		for _, v in ipairs(t.choices) do
			table.insert(choices, v[1])
		end
	end
	if #choices ~= 0 then
		self.e_dialogue:give("has_choices", unpack(choices))
	end
end

function DialoguesSystem:cleanup()
	self.e_dialogue:destroy()
	for _, e in ipairs(self.pool) do
		e:destroy()
	end
end

DialoguesSystem["on_list_cursor_update_" .. "dialogue_choices"] = function(self, e_hovered)
	if not self.pool_choice:has(e_hovered) then
		return
	end
	self.world:emit("lerp_color", e_hovered, c_hc, 0.25, "circin")
end

DialoguesSystem["on_list_cursor_remove_" .. "dialogue_choices"] = function(self, e_hovered)
	if not self.pool_choice:has(e_hovered) then
		return
	end
	self.world:emit("lerp_color", e_hovered, Palette.get("ui_dialogue"), 0.25, "circin")
end

DialoguesSystem["on_list_item_interact_" .. "dialogue_choices"] = function(self, e_hovered)
	local t = e_hovered.text_t
	local text_t = t.value
	if #text_t == 0 and not text_t.choices then
		self:on_dialogue_reached_end(e_hovered)
		return
	end

	local proceed = true
	local str = text_t[1]
	if str then
		local bool, signal, handle_self = Dialogues.check_signal(str)

		if bool then
			proceed = false
			--entity, table of next dialogues, chosen text
			self.world:emit(signal, e_hovered, text_t, e_hovered.text.value)
			if handle_self then
				t.current_index = t.current_index + 1
				local next_str = text_t[t.current_index]
				if not next_str then
					self:on_dialogue_reached_end(e_hovered)
				end
			end
		end
	end

	self.world:emit("destroy_list", "dialogue_choice")
	self.world:emit("destroy_list", "dialogue_choices")
	if proceed then
		local d = e_hovered.dialogue_meta
		self:spawn_dialogue(text_t, d.main, d.sub)
	end
	if not text_t.choices then
		self.e_dialogue:remove("has_choices")
	end
end

return DialoguesSystem
