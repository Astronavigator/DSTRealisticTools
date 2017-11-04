local Assets =
{
	Asset("ANIM", "anim/cactus_cake.zip"),
    Asset("ATLAS", "images/inventoryimages/cactus_cake.xml"),
}

local prefabs = 
{
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
	
	inst.AnimState:SetBank("cactus_cake")
	inst.AnimState:SetBuild("cactus_cake")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")


	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()

	
	inst:AddComponent("edible")
	inst.components.edible.foodtype = "VEGGIE"
	inst.components.edible.healthvalue = TUNING.HEALING_MED*0.5
	inst.components.edible.hungervalue = TUNING.CALORIES_HUGE*0.8
	inst.components.edible.sanityvalue = TUNING.SANITY_MED,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/cactus_cake.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("bait")
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 1

	return inst
end


return Prefab( "common/inventory/cactus_cake", fn, Assets )