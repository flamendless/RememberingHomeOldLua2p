local Concord = require("modules.concord.concord")

Concord.component("paint")

local c_twp = Concord.component("text_with_paint", function(c)
	c.e_paint = nil
end)

function c_twp:serialize()
	if self.e_paint then
		return {
			paint_key = self.e_paint.key.value,
		}
	else
		return {}
	end
end

function c_twp:deserialize(data)
	self.e_paint = self.__entity:getWorld():getEntityByKey(data.paint_key)
end
