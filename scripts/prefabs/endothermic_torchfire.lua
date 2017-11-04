local texture = "fx/torchfire.tex"
local shader = "shaders/particle.ksh"
local colour_envelope_name = "coldfirecolourenvelope"
local scale_envelope_name = "firescaleenvelope"

local assets =
{
	Asset( "IMAGE", texture ),
	Asset( "SHADER", shader ),
}

local max_scale = 3

local lightColour = {0, 183, 1}
local heats = {-10, -20, -30, -40}
local function GetHeatFn(inst)
	--return heats[inst.components.firefx.level] or -20
	return -40
end


local function IntColour( r, g, b, a )
	return { r / 0.0, g / 183.0, b / 1.0, a / 255.0 }
end

local init = false
local function InitEnvelope()
	if EnvelopeManager and not init then
		init = true
		EnvelopeManager:AddColourEnvelope(
			colour_envelope_name,
			{	{ 0,	IntColour( 0, 183, 1, 255 ) },
				{ 0.49,	IntColour( 0, 183, 1, 255 ) },
				{ 0.5,	IntColour( 0, 183, 1, 255 ) },
				{ 0.51,	IntColour( 0, 183, 1, 255 ) },
				{ 0.75,	IntColour( 0, 183, 1, 255 ) },
				{ 1,	IntColour( 0, 183, 1, 0 ) },
			} )

		EnvelopeManager:AddVector2Envelope(
			scale_envelope_name,
			{
				{ 0,	{ max_scale * 0.5, max_scale } },
				{ 1,	{ max_scale * 0.5 * 0.5, max_scale * 0.5 } },
			} )
	end
end

local max_lifetime = 0.3
--local ground_height = 0.1

local function fn(Sim)
	local inst = CreateEntity()
	inst:AddTag("FX")
	local trans = inst.entity:AddTransform()
	local emitter = inst.entity:AddParticleEmitter()
	inst.entity:AddNetwork()

	InitEnvelope()

	emitter:SetRenderResources( texture, shader )
	emitter:SetMaxNumParticles( 64 )
	emitter:SetMaxLifetime( max_lifetime )
	emitter:SetColourEnvelope( colour_envelope_name )
	emitter:SetScaleEnvelope( scale_envelope_name );
	emitter:SetBlendMode( BLENDMODE.Additive )
	emitter:EnableBloomPass( true )
	emitter:SetUVFrameSize( 1.0 / 4.0, 1.0 )
    --emitter:SetSortOrder(1)

	inst.entity:AddLight()
    inst.Light:Enable(true)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(197/255,197/255,50/255)
    inst.Light:SetFalloff( 0.5 )
    inst.Light:SetRadius( 2 )
    
    
	-----------------------------------------------------
	local tick_time = TheSim:GetTickTime()

	local desired_particles_per_second = 64
	local particles_per_tick = desired_particles_per_second * tick_time

	local emitter = inst.ParticleEmitter

	local num_particles_to_emit = 1

	local sphere_emitter = CreateSphereEmitter( 0.05 )

	local emit_fn = function()
		local vx, vy, vz = 0.01 * UnitRand(), 0, 0.01 * UnitRand()
		local lifetime = max_lifetime * ( 0.9 + UnitRand() * 0.1 )
		local px, py, pz

		px, py, pz = sphere_emitter()
		px = px - 0.1
		py = py + 0.25 -- the 0.2 is to offset the flame particles upwards a bit so they can be used on a torch

		local uv_offset = math.random( 0, 3 ) * 0.25

		emitter:AddParticleUV(
			lifetime,			-- lifetime
			px, py, pz,			-- position
			vx, vy, vz,			-- velocity
			uv_offset, 0		-- uv offset
		)
	end

	

	local updateFunc = function()
		while num_particles_to_emit > 1 do
			emit_fn( emitter )
			num_particles_to_emit = num_particles_to_emit - 1
		end

		num_particles_to_emit = num_particles_to_emit + particles_per_tick
	end

    --inst:AddComponent("heater")
    --inst.components.heater.heatfn = GetHeatFn
    --inst.components.heater.iscooler = true

    inst:AddComponent("firefx")
    inst.components.firefx.levels =
    {
        {anim="level1", sound="dontstarve_DLC001/common/coldfire", radius=2, intensity=.8, falloff=.33, colour = lightColour, soundintensity=.1},
        {anim="level2", sound="dontstarve_DLC001/common/coldfire", radius=3, intensity=.8, falloff=.33, colour = lightColour, soundintensity=.3},
        {anim="level3", sound="dontstarve_DLC001/common/coldfire", radius=4, intensity=.8, falloff=.33, colour = lightColour, soundintensity=.6},
        {anim="level4", sound="dontstarve_DLC001/common/coldfire", radius=5, intensity=.8, falloff=.33, colour = lightColour, soundintensity=1},
    }

	EmitterManager:AddEmitter( inst, nil, updateFunc )

	inst.entity:SetPristine()	

	if not TheWorld.ismastersim then
		return inst
	end

    inst.persists = false
    
    return inst
end

return Prefab( "common/fx/endothermic_torchfire", fn, assets) 
 
