local Assets =
{
	Asset("ANIM", "anim/omelette.zip"),
    Asset("ATLAS", "images/inventoryimages/omelette.xml"),
}

local prefabs = 
{
	"mushy_eggs",
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
	
	inst.AnimState:SetBank("omelette")
	inst.AnimState:SetBuild("omelette")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
 
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	

	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.healthvalue = TUNING.HEALING_MEDLARGE
	inst.components.edible.hungervalue = TUNING.CALORIES_LARGE
	inst.components.edible.sanityvalue = TUNING.SANITY_SMALL,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/omelette.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_ONE_DAY)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "mushy_eggs"

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 2

	return inst
end


return Prefab( "common/inventory/omelette", fn, Assets )