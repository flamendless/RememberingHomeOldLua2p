local ShowKeys = Concord.system()

local function asm(e, key)
	e:give("atlas", Atlases.AtlasKeys.frames[key])
	:give("sprite", "atlas_keys")
	:give("ui_element")
end

function ShowKeys:init(world)
	self.world = world
	self.keys = {}
	self.texts = {}
end

function ShowKeys:create_key_with_text(id, txt, key)
	assert(type(id) == "string")
	assert(type(txt) == "string")
	assert(type(key) == "string")

	local ww, wh = love.graphics.getDimensions()
	self.keys[id] = Concord.entity(self.world)
		:assemble(asm, key)
		:give("id", "key_" .. id)
		:give("pos", ww - 8, wh - 8)
		:give("transform", 0, 1, 1, 0.5, 1)
		:give("quad_transform", 0, 3, 3, 1, 1)
		:give("color", { 1, 1, 1, 1 })

	self.texts[id] = Concord.entity(self.world)
		:give("id", "text_" .. id)
		:give("static_text", txt)
		:give("font", "ui")
		:give("pos", 0, 0)
		:give("color", Palette.get("ui_show_key_text"))
		:give("ui_element")
		:give("transform", 0, 1, 1, 1, 1)
		:give("anchor", self.keys[id], Enums.anchor.right, Enums.anchor.bottom, 16, 0)

	return self.keys[id], self.texts[id]
end

local SPLASH_HAND_SCALE = Assemblages.HandDecal.SPLASH_HAND_SCALE
local SPLASH_HAND_UV_SCALE = Assemblages.HandDecal.SPLASH_HAND_UV_SCALE
local SPLASH_HAND_MARGIN = Assemblages.HandDecal.SPLASH_HAND_MARGIN
local SPLASH_HAND_EFFECTS = Assemblages.HandDecal.SPLASH_HAND_EFFECTS
local SKIP_HAND_TEX = Assemblages.HandDecal.HAND_TEX

local function fade_ui_color(e, duration, on_complete)
	Flux.to(e.color.value, duration, { [4] = 0 }):oncomplete(function()
		e:destroy()
		if on_complete then
			on_complete()
		end
	end)
end

function ShowKeys:sync_skip_labels()
	if not self.skip_hand then
		return
	end
	Assemblages.HandDecal.sync_key_label(self.skip_hand, self.skip_key_label)
end

function ShowKeys:destroy_skip_hand()
	for _, key in ipairs({ "skip_hand", "skip_key_label" }) do
		local e = self.world:getEntityByKey(key)
		if e then
			e:destroy()
		end
	end
	self.skip_hand = nil
	self.skip_key_label = nil
	self.world:__flush()
end

function ShowKeys:show_skip()
	self:destroy_skip_hand()

	local ww, wh = love.graphics.getDimensions()
	local hand_size = SKIP_HAND_TEX * SPLASH_HAND_SCALE
	local half = hand_size / 2
	local hx = ww - SPLASH_HAND_MARGIN - half
	local hy = wh - SPLASH_HAND_MARGIN - half

	self.skip_hand = Concord.entity(self.world):assemble(
		Assemblages.HandDecal.create,
		{
			id = "skip_hand",
			key = "skip_hand",
			x = hx,
			y = hy,
			scale = SPLASH_HAND_SCALE,
			uv_scale = SPLASH_HAND_UV_SCALE,
			rotation = 0,
			blood_amount = SPLASH_HAND_EFFECTS.blood_amount,
			damage_amount = SPLASH_HAND_EFFECTS.damage_amount,
			distort_amount = SPLASH_HAND_EFFECTS.distort_amount,
			ui_element = true,
			skip = true,
		}
	)
	Assemblages.HandDecal.fade_in(self.skip_hand, 1, 0.5)
	Assemblages.HandDecal.pulse_opacity(self.skip_hand, 1, 0, 0, 1)

	self.skip_key_label = Assemblages.HandDecal.create_key_label(
		self.world,
		string.upper(Inputs.rev_map.interact),
		{
			id = "skip_key_label",
			key = "skip_key_label",
			x = hx,
			y = hy,
			hand_scale = SPLASH_HAND_SCALE,
			ui_element = true,
			skip = true,
		}
	)
end

function ShowKeys:fade_skip_hand(duration)
	duration = duration or 0.5

	local hand = self.skip_hand or self.world:getEntityByKey("skip_hand")
	local label = self.skip_key_label or self.world:getEntityByKey("skip_key_label")
	self.skip_hand = nil
	self.skip_key_label = nil

	if hand then
		Assemblages.HandDecal.fade_out(hand, duration)
	end
	if label then
		fade_ui_color(label, duration)
	end
end

function ShowKeys:create_inventory_key()
	if not Settings.current.show_keys then
		return
	end
	self:create_key_with_text("inventory", "Switch to Notes", Inputs.rev_map.inventory)
end

function ShowKeys:create_notes_key()
	if not Settings.current.show_keys then
		return
	end
	self:create_key_with_text("notes", "Switch to Inventory", Inputs.rev_map.inventory)
end

function ShowKeys:create_dialogue_key()
	if not Settings.current.show_keys then return end
	local w, h = love.graphics.getDimensions()
	self.keys.dialogue = Concord.entity(self.world)
		:assemble(asm, Inputs.rev_map.interact)
		:give("id", "dialogue_proceed_key")
		:give("key", "dialogue_proceed_key")
		:give("pos", w - 8, h - 8)
		:give("quad_transform", 0, 2, 2, 0.5, 0.5)
		-- :give("fake_pulse", 3, 3, 0.5)
		:give("color", { 1, 1, 1, 1 })
		:give("hidden")
end

function ShowKeys:create_lighter_key()
	if not Settings.current.show_keys then return end
	local w, h = love.graphics.getDimensions()
	self.keys.lighter = Concord.entity(self.world)
		:assemble(asm, Inputs.rev_map.lighter)
		:give("id", "dialogue_lighter_key")
		:give("key", "dialogue_lighter_key")
		:give("pos", w - 8, h - 8)
		:give("quad_transform", 0, 2, 2, 0.5, 0.5)
		-- :give("fake_pulse", 3, 3, 0.5)
		:give("color", { 1, 1, 1, 1 })
		:give("hidden")
end

function ShowKeys:create_left_key()
	if not Settings.current.show_keys then return end
	local w, h = love.graphics.getDimensions()
	self.keys.left = Concord.entity(self.world)
		:assemble(asm, Inputs.rev_map.left)
		:give("id", "left_proceed_key")
		:give("key", "left_proceed_key")
		:give("pos", w - 8, h - 8)
		:give("quad_transform", 0, 2, 2, 0.5, 0.5)
		:give("color", { 1, 1, 1, 1 })
		:give("hidden")
end

function ShowKeys:create_right_key()
	if not Settings.current.show_keys then return end
	local w, h = love.graphics.getDimensions()
	self.keys.right = Concord.entity(self.world)
		:assemble(asm, Inputs.rev_map.right)
		:give("id", "right_proceed_key")
		:give("key", "right_proceed_key")
		:give("pos", w - 8, h - 8)
		:give("quad_transform", 0, 2, 2, 0.5, 0.5)
		:give("color", { 1, 1, 1, 1 })
		:give("hidden")
end

function ShowKeys:show_key(id, bool)
	if not Settings.current.show_keys then return end
	assert(Enums.show_keys[id], id)
	assert(type(bool) == "boolean")

	local e = self.keys[id]
	assert(e ~= nil, id)

	if not bool then
		e:give("hidden")
	else
		e:remove("hidden")
	end

	local t = self.texts[id]
	if t then
		if not bool then
			t:give("hidden")
		else
			t:remove("hidden")
		end
	end
end

function ShowKeys:show_key_at(id, bool, pos)
	if not Settings.current.show_keys then return end
	assert(Enums.show_keys[id], id)
	assert(type(bool) == "boolean")
	assert(pos:type() == "vec2")

	local e = self.keys[id]
	e.pos.x = pos.x
	e.pos.y = pos.y
	self:show_key(id, bool)
end

function ShowKeys:destroy_key(id)
	if id == "skip" then
		self:fade_skip_hand(0)
		return
	end
	self.keys[id]:destroy()
	local t = self.texts[id]
	if t then
		t:destroy()
	end
	self.world:__flush()
end

function ShowKeys:update(dt)
	self:sync_skip_labels()

	if not Settings.current.show_keys then return end
	for _, e in pairs(self.keys) do
		local fp = e.fake_pulse
		if not e.hidden and fp then
			local qt = e.quad_transform

			if qt.sx > fp.sx then
				fp.dirx = -1
			elseif qt.sx < qt.orig_sx then
				fp.dirx = 1
			end

			if qt.sy > fp.sy then
				fp.diry = -1
			elseif qt.sy < qt.orig_sy then
				fp.diry = 1
			end

			qt.sx = qt.sx + dt * fp.dirx * fp.speed
			qt.sy = qt.sy + dt * fp.diry * fp.speed
		end
	end
end

return ShowKeys
