local Assets =
{
	Asset("ANIM", "anim/limongelo.zip"),
    Asset("ATLAS", "images/inventoryimages/limongelo.xml"),
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
	
	inst.AnimState:SetBank("limongelo")
	inst.AnimState:SetBuild("limongelo")
	inst.AnimState:PlayAnimation("OnGround", true)
	-- inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
    

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()


	inst:AddComponent("edible")
	inst.components.edible.foodtype = "GENERIC"
	inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
	inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
	inst.components.edible.sanityvalue = TUNING.SANITY_MED,
	
	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/limongelo.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("tradable")

	return inst
end


return Prefab( "common/inventory/limongelo", fn, Assets )