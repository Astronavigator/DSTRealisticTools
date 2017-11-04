local Assets =
{
	Asset("ANIM", "anim/fruit_truffle.zip"),
    Asset("ATLAS", "images/inventoryimages/fruit_truffle.xml"),
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
	
	inst.AnimState:SetBank("fruit_truffle")
	inst.AnimState:SetBuild("fruit_truffle")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
    

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()


	inst:AddComponent("edible")
	inst.components.edible.foodtype = "VEGGIE"
	inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL*2
	inst.components.edible.hungervalue = TUNING.CALORIES_LARGE
	inst.components.edible.sanityvalue = TUNING.SANITY_SMALL,
		
	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/fruit_truffle.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("tradable")

	return inst
end


return Prefab( "common/inventory/fruit_truffle", fn, Assets )