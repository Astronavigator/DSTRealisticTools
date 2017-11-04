local Assets =
{
	Asset("ANIM", "anim/coldcuts.zip"),
    Asset("ATLAS", "images/inventoryimages/coldcuts.xml"),
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
	
	inst.AnimState:SetBank("coldcuts")
	inst.AnimState:SetBuild("coldcuts")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
    

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()


	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
	inst.components.edible.hungervalue = TUNING.CALORIES_LARGE
	inst.components.edible.sanityvalue = TUNING.SANITY_TINY
	
	if IsDLCEnabled(REIGN_OF_GIANTS) then inst.components.edible.temperaturedelta = TUNING.COLD_FOOD_BONUS_TEMP else end
	if IsDLCEnabled(REIGN_OF_GIANTS) then inst.components.edible.temperatureduration = TUNING.FOOD_TEMP_AVERAGE else end
	
	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/coldcuts.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	return inst
end


return Prefab( "common/inventory/coldcuts", fn, Assets )