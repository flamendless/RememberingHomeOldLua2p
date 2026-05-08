local DialoguesSystem = Concord.system()

function DialoguesSystem:init(world)
	self.world = world
end

function DialoguesSystem:state_setup()
	local current_id = string.lower(GameStates.current_id)
	Log.info("Loading dialogues data", current_id)

	local data = Data.Dialogues[current_id]
	self.dialogue = LoveInk.Dialogue.new(data, "start")

	--TODO: customize. Should we defer this to renderer system?
	local cfg = {
		textbox = {
			x = 50,
			y = love.graphics.getHeight() - 180,
			width = love.graphics.getWidth() - 100,
			height = 150,
			typewriter_speed = 40,
			font = love.graphics.newFont(18)
		},
		choicelist = {
			x = 100,
			y = 200,
			width = love.graphics.getWidth() - 200,
			button_height = 50,
			font = love.graphics.newFont(16)
		}

	}
	self.ui = LoveInk.DialogueUI.new(cfg)

	-- self.current_content = self.dialogue:getNext()
	-- self.ui:showContent(self.current_content)

	self.ui.on_choice_made = function(index)
		print("choice made", index)
		self.current_content = self.dialogue:choose(index)
		self.ui:showContent(self.current_content)
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
	end
end

function DialoguesSystem:state_update(dt)
	if self.dialogue:getCurrentKnot() == "fin" then
		self.current_content = nil
	end

	--TODO: use enums for keys instead of strings
	if Inputs.released("interact") then
		self:ev_advance()
	end

	--TODO: if dialogue is active, what entities/systems do we want to pause/block?? How??
	self.ui:update(dt)
end

function DialoguesSystem:state_draw()
	if not self.dialogue:hasEnded() and self.current_content then
		self.ui:draw()
	end
end

-- TODO: ponder whether we want mouse or key based interactions
function DialoguesSystem:state_mousepressed(mx, my, mb)
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
		if Slab.Button("start", { Disabled = start_disabled}) then
			if self.dialogue:getCurrentKnot() == "fin" then
				self.dialogue:divertTo("start")
			end
			self.current_content = self.dialogue:getNext()
			self.ui:showContent(self.current_content)
		end

		--TODO: Maybe store knots in a map so that map[knot_name]count
		Slab.Text("Dialogue:")
			Slab.Indent()
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
