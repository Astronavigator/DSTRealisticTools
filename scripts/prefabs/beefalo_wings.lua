local Assets =
{
	Asset("ANIM", "anim/beefalo_wings.zip"),
    Asset("ATLAS", "images/inventoryimages/beefalo_wings.xml"),
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
	
	inst.AnimState:SetBank("beefalo_wings")
	inst.AnimState:SetBuild("beefalo_wings")
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
	inst.components.edible.sanityvalue = TUNING.SANITY_TINY
	
	if IsDLCEnabled(REIGN_OF_GIANTS) then inst.components.edible.temperaturedelta = TUNING.HOT_FOOD_BONUS_TEMP else end
	if IsDLCEnabled(REIGN_OF_GIANTS) then inst.components.edible.temperatureduration = TUNING.FOOD_TEMP_LONG else end
	
	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/beefalo_wings.xml"

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


return Prefab( "common/inventory/beefalo_wings", fn, Assets )