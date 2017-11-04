local Assets =
{
	Asset("ANIM", "anim/sweet_n_sour.zip"),
    Asset("ATLAS", "images/inventoryimages/sweet_n_sour.xml"),
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
	
	inst.AnimState:SetBank("sweet_n_sour")
	inst.AnimState:SetBuild("sweet_n_sour")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
	inst:AddTag("honeyed")
 

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()


	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL*2
	inst.components.edible.hungervalue = TUNING.CALORIES_HUGE
	inst.components.edible.sanityvalue = TUNING.SANITY_SMALL,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sweet_n_sour.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("bait")
	-- inst:AddComponent("tradable")
	
	return inst
end


return Prefab( "common/inventory/sweet_n_sour", fn, Assets )