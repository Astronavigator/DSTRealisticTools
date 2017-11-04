local Assets =
{
	Asset("ANIM", "anim/meatballs_human.zip"),
    Asset("ATLAS", "images/inventoryimages/meatballs_human.xml"),
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
	
	inst.AnimState:SetBank("meatballs_human")
	inst.AnimState:SetBuild("meatballs_human")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
    

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()


	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.healthvalue = TUNING.HEALING_SMALL
	inst.components.edible.hungervalue = TUNING.CALORIES_SMALL*5
	inst.components.edible.sanityvalue = -TUNING.SANITY_TINY,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/meatballs_human.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
	inst:AddTag("humanmeat")

	-- inst:AddComponent("tradable")
	
	return inst
end


return Prefab( "common/inventory/meatballs_human", fn, Assets )