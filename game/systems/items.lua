local ItemsSystem = Concord.system({
	pool = {"item"},
})


local list = {
	flashlight = {
		car = {
			--TODO
			-- "_play_sound_item_unusable",
			"I got this flashlight from the car",
		},
	}
}

function ItemsSystem:init(world)
	self.world = world
	self:initialize_entities()
end

function ItemsSystem:create_items()
	local t = Items.get_acquired()
	for _, v in ipairs(t) do
		Concord.entity(self.world):assemble(Assemblages.Items[v.id])
	end
end

function ItemsSystem:destroy_items()
	for _, e in ipairs(self.pool) do
		e:destroy()
	end
end

function ItemsSystem:initialize_entities()
	if self.e_bg and self.e_prev then return end
	self.e_bg = Concord.entity(self.world)
		:give("id", "item_preview_bg")
		:give("sprite", "bg_inventory")
		:give("transform", 0, vec2(1, 1), vec2(1, 0.5))
		:give("color", {1, 1, 1, 1})
		:give("item_preview")

	self.e_prev = Concord.entity(self.world)
		:give("id", "item_preview")
		:give("color", {1, 1, 1, 1})
		:give("item_preview")
end

function ItemsSystem:create_item_preview(bg_e, item_e)
	if not (bg_e.__isEntity and bg_e.cell_bg) then error("Assertion failed: bg_e.__isEntity and bg_e.cell_bg") end
	if not (item_e.__isEntity and item_e.item) then error("Assertion failed: item_e.__isEntity and item_e.item") end
	local scale = 4
	local pad = 32
	local pad_p = pad * 2
	local bg_pos = bg_e.pos
	local bg_sprite = bg_e.sprite
	local bg_t = bg_e.transform

	local res_id = item_e.sprite.resource_id
	local img = Resources.data.images[res_id]
	local tw = (img:getWidth() + 16) * scale
	local th = (img:getHeight() + 16) * scale

	self.e_bg
		:give("pos", vec2(bg_pos.x - bg_sprite.image_size.x * bg_t.sx - pad, bg_pos.y))
		:give("auto_scale", tw, th)
		:remove("hidden")

	self.e_prev:give("sprite", res_id)
		:give("pos", vec2(bg_pos.x - bg_sprite.image_size.x * bg_t.sx - pad_p, bg_pos.y))
		:give("transform", 0, vec2(scale, scale), vec2(1, 0.5))
		:remove("hidden")
end

function ItemsSystem:item_response(dialogue_t, main, sub)
	if not (type(dialogue_t) == "table") then error("Assertion failed: type(dialogue_t) == \"table\"") end
	if not (type(main) == "string") then error("Assertion failed: type(main) == \"string\"") end
	if not (type(sub) == "string") then error("Assertion failed: type(sub) == \"string\"") end
	self.world:emit("close_inventory", true)
	self.world:emit("on_interact_or_inventory")
	self.world:emit("spawn_dialogue", dialogue_t, main, sub)
end

function ItemsSystem:on_item_use_with(item, other)
	if not (item.__isEntity and item.item) then error("Assertion failed: item.__isEntity and item.item") end
	if other then if not (other.__isEntity and other.interactive) then error("Assertion failed: other.__isEntity and other.interactive") end end
	self.world:emit("set_system_to", "dialogues", true)
	self.world:emit("set_system_to", "inventory", false)
	local item_id = item.item.id
	if not other then
		local dialogue_t = Dialogues.get("common", "item_without")
		self:item_response(dialogue_t, "common", "item_without")
	else
		local other_id = other.id.value
		local t = list[item_id] and list[item_id][other_id]
		if not (not(other.usable_with_item == nil and t ~= nil)) then error("add usable_with_item component?") end
		if not (not(other.usable_with_item ~= nil and t == nil)) then error("add to list?") end
		if other.usable_with_item and t ~= nil then
			self:item_response(t, "_none", "_none")
		else
			local t2 = {string.format("%s can not be used here", item_id)}
			self:item_response(t2, "_none", "_none")
		end
	end
end

function ItemsSystem:on_item_equip(item_e)
	if not (item_e.__isEntity and item_e.item) then error("Assertion failed: item_e.__isEntity and item_e.item") end
	local item = item_e.item
	if item.id == "flashlight" then
		self.world:emit("set_system_to", "dialogues", true)
		self.world:emit("set_system_to", "inventory", false)
		if not item.has_batteries then
			local dialogue_t = Dialogues.get("items", "no_batteries")
			self.world:emit("spawn_dialogue_ex", dialogue_t, "dialogue_to_inventory")
		else
			Items.toggle_equip(item.id)
			self.world:emit("on_toggle_equip_flashlight")
		end
	end
end

return ItemsSystem
