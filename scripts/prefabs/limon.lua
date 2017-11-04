local Assets =
{
	Asset("ANIM", "anim/limon.zip"),
    Asset("ATLAS", "images/inventoryimages/limon.xml"),
}

local prefabs = 
{
	"limon_cooked",
	"spoiled_food",
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork() 

	MakeInventoryPhysics(inst)
	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	
	inst.AnimState:SetBank("limon")
	inst.AnimState:SetBuild("limon")
	inst.AnimState:PlayAnimation("idle", false)


	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()

	
	inst:AddComponent("edible")
	inst.components.edible.foodtype = "VEGGIE"
	inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
	inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
	inst.components.edible.sanityvalue = 0,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/limon.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("cookable")
    inst.components.cookable.product="limon_cooked"

	inst:AddComponent("tradable")
	
	return inst
end



return Prefab( "common/inventory/limon", fn, Assets )