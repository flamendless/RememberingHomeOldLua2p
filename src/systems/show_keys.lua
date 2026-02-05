local ShowKeys = Concord.system()

local function Assemble(e, key)
	e:give("atlas", Atlases.AtlasKeys.frames[key]):give("sprite", "atlas_keys"):give("ui_element")
end

function ShowKeys:init(world)
	self.world = world
	self.keys = {}
	self.texts = {}
end

function ShowKeys:create_key_with_text(id, txt, key)
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	if type(txt) ~= "string" then
		error('Assertion failed: type(txt) == "string"')
	end
	local ww, wh = love.graphics.getDimensions()
	self.keys[id] = Concord.entity(self.world)
		:assemble(Assemble, key)
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

function ShowKeys:show_skip()
	local k, t = self:create_key_with_text("skip", "Skip", Inputs.rev_map.interact)
	k:give("color_fade_in_out", 1):give("skip")
	t:give("color_fade_in_out", 1):give("skip")
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
	if not Settings.current.show_keys then
		return
	end
	local w, h = love.graphics.getDimensions()
	self.keys.dialogue = Concord.entity(self.world)
		:assemble(Assemble, Inputs.rev_map.interact)
		:give("id", "dialogue_proceed_key")
		:give("pos", w - 8, h - 8)
		:give("quad_transform", 0, 3, 3, 1, 1)
		:give("color", { 1, 1, 1, 1 })
		:give("hidden")
end

function ShowKeys:show_key(id, bool)
	if not Settings.current.show_keys then
		return
	end
	if type(id) ~= "string" then
		error('Assertion failed: type(id) == "string"')
	end
	if type(bool) ~= "boolean" then
		error('Assertion failed: type(bool) == "boolean"')
	end
	local e = self.keys[id]
	if not (e ~= nil) then
		error("Assertion failed: e ~= nil")
	end
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

function ShowKeys:destroy_key(id)
	self.keys[id]:destroy()
	local t = self.texts[id]
	if t then
		t:destroy()
	end
	self.world:__flush()
end

return ShowKeys
