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

local ps = LG.newParticleSystem(image1, 9)
ps:setColors(0.958984375, 1, 0.25, 0, 0.97705078125, 1, 0.265625, 0.83984375, 0.91152954101563, 1, 0.12890625, 0.5, 1, 0.96902465820313, 0.20703125, 0)
ps:setDirection(-1.5707963705063)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(4.3951864242554)
ps:setEmitterLifetime(0)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(-0.31050637364388, 0.71063297986984)
ps:setOffset(90, 90)
ps:setParticleLifetime(0.13734957575798, 0.54939830303192)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.55240023136139)
ps:setSizeVariation(0.45047923922539)
ps:setSpeed(19.618450164795, 251.52854919434)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(1.8550356626511)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=0, kickStartDt=0, emitAtStart=9, blendMode="alpha", shader=nil, texturePath="lightDot.png", texturePreset="lightDot", shaderPath="", shaderFilename="", x=1.3605442176871, y=0})

return particles
