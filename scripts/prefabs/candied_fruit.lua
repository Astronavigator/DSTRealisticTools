local Assets =
{
	Asset("ANIM", "anim/candied_fruit.zip"),
    Asset("ATLAS", "images/inventoryimages/candied_fruit.xml"),
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
	
	inst.AnimState:SetBank("candied_fruit")
	inst.AnimState:SetBuild("candied_fruit")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
	inst:AddTag("honeyed")
   

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()


	inst:AddComponent("edible")
	inst.components.edible.foodtype = "VEGGIE"
	inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
	inst.components.edible.hungervalue = TUNING.CALORIES_TINY*3
	inst.components.edible.sanityvalue = TUNING.SANITY_SMALL,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/candied_fruit.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 2

	return inst
end


return Prefab( "common/inventory/candied_fruit", fn, Assets )