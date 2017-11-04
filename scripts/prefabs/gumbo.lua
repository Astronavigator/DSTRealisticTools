local Assets =
{
	Asset("ANIM", "anim/gumbo.zip"),
    Asset("ATLAS", "images/inventoryimages/gumbo.xml"),
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
	
	inst.AnimState:SetBank("gumbo")
	inst.AnimState:SetBuild("gumbo")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
    

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()


	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL*2
	inst.components.edible.hungervalue = TUNING.CALORIES_LARGE
	inst.components.edible.sanityvalue = TUNING.SANITY_TINY
	
	if IsDLCEnabled(REIGN_OF_GIANTS) then inst.components.edible.temperaturedelta = TUNING.HOT_FOOD_BONUS_TEMP*0.5 else end
	if IsDLCEnabled(REIGN_OF_GIANTS) then inst.components.edible.temperatureduration = TUNING.FOOD_TEMP_AVERAGE*2 else end
	
	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/gumbo.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST*1.35)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
	return inst
end


return Prefab( "common/inventory/gumbo", fn, Assets )