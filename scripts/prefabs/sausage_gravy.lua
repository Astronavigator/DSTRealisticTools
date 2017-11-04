local Assets =
{
	Asset("ANIM", "anim/sausage_gravy.zip"),
    Asset("ATLAS", "images/inventoryimages/sausage_gravy.xml"),
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
	
	inst.AnimState:SetBank("sausage_gravy")
	inst.AnimState:SetBuild("sausage_gravy")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
 	inst:AddTag("catfood")

	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	

	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
	inst.components.edible.hungervalue = TUNING.CALORIES_HUGE*0.8
	inst.components.edible.sanityvalue = TUNING.SANITY_MED,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sausage_gravy.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("bait")
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 3

	return inst
end


return Prefab( "common/inventory/sausage_gravy", fn, Assets )