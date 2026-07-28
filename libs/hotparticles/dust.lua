--[[
module = {
	x=emitterPositionX, y=emitterPositionY,
	[1] = {
		system=particleSystem1,
		kickStartSteps=steps1, kickStartDt=dt1, emitAtStart=count1,
		blendMode=blendMode1, shader=shader1,
		texturePreset=preset1, texturePath=path1,
		shaderPath=path1, shaderFilename=filename1,
		x=emitterOffsetX, y=emitterOffsetY
	},
	[2] = {
		system=particleSystem2,
		...
	},
	...
}
]]
local LG        = love.graphics
local particles = {x=0, y=0}

local image1 = LG.newImage("lightDot.png")
image1:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 23)
ps:setColors(0.05859375, 0.057220458984375, 0.057220458984375, 1, 0.0546875, 0.052978515625, 0.052978515625, 1, 0.03125, 0.0308837890625, 0.0308837890625, 1, 0.0234375, 0.022979736328125, 0.022979736328125, 1)
ps:setDirection(1.5707963705063)
ps:setEmissionArea("ellipse", 133.38374328613, 1.5311908721924, 0, false)
ps:setEmissionRate(9.6631383895874)
ps:setEmitterLifetime(0.79357755184174)
ps:setInsertMode("top")
ps:setLinearAcceleration(-177.65823364258, -31.897844314575, 229.10308837891, 42.921741485596)
ps:setLinearDamping(0.14882259070873, 0.53098428249359)
ps:setOffset(90, 90)
ps:setParticleLifetime(0.58794111013412, 0.99362045526505)
ps:setRadialAcceleration(-98.092254638672, 63.79568862915)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(1.1086366176605)
ps:setSizeVariation(0.50159746408463)
ps:setSpeed(133.94032287598, 465.47378540039)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(0)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=2, kickStartDt=0.39678877592087, emitAtStart=14, blendMode="add", shader=nil, texturePath="lightDot.png", texturePreset="lightDot", shaderPath="", shaderFilename="", x=0, y=0})

return particles
