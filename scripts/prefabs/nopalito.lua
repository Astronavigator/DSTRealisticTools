local Assets =
{
	Asset("ANIM", "anim/nopalito.zip"),
    Asset("ATLAS", "images/inventoryimages/nopalito.xml"),
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
	
	inst.AnimState:SetBank("nopalito")
	inst.AnimState:SetBuild("nopalito")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
 
 
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()

		
	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.healthvalue = TUNING.HEALING_MED
	inst.components.edible.hungervalue = TUNING.CALORIES_MED*2
	inst.components.edible.sanityvalue = TUNING.SANITY_MED,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/nopalito.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 1

	return inst
end


return Prefab( "common/inventory/nopalito", fn, Assets )