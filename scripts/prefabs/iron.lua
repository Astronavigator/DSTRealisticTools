local assets =
{
	Asset("ANIM", "anim/salo.zip"),
	Asset("ATLAS", "images/images1.xml"),
}



--[[local function shine(inst)
    inst.task = nil
    if not inst.AnimState:IsCurrentAnimation("sparkle") then
        inst.AnimState:PlayAnimation("sparkle")
        inst.AnimState:PushAnimation("idle", true)
    end
    inst.task = inst:DoTaskInTime(4 + math.random() * 5, shine)
end--]]

--------PREFAB FUNCTION ------------

local function fn(color)

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	--inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("salo")
	inst.AnimState:SetBuild("salo")
	inst.AnimState:PlayAnimation("iron")
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "iron1"
	inst.components.inventoryitem.atlasname = "images/images1.xml"
	
	--inst.OnSave = OnSave
	--inst.OnLoad = OnLoad
	
	
	--MakeSmallBurnable(inst, TUNING.LONG_BURNABLE)
	--MakeSmallPropagator(inst)
	--inst.components.burnable:SetOnIgniteFn(make_damp)

	--inst:AddComponent("fuel")
	--inst.components.fuel.fuelvalue = TUNING.MED_FUEL
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = 5 --3
	
	--shine(inst) --сверкает. ня!
	
	return inst
end


STRINGS.NAMES.IRON = "Iron Bar"
STRINGS.RECIPE_DESC.IRON = "Just an iron bar. Very useful."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.IRON = "Some kind of metal"
--без рецепта! Просто выдается в стартовом комплекте зимой!!

local mk = rawget(_G,"RegisterRussianName")
if mk then
	mk("IRON","Железо",4)
end


return Prefab("common/inventory/iron", fn, assets, prefabs)
