local Assets =
{
	Asset("ANIM", "anim/fruit_syrup.zip"),
    Asset("ATLAS", "images/inventoryimages/fruit_syrup.xml"),
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
	
	inst.AnimState:SetBank("fruit_syrup")
	inst.AnimState:SetBuild("fruit_syrup")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
	inst:AddTag("honeyed")
  

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()


	inst:AddComponent("edible")
	inst.components.edible.foodtype = "VEGGIE"
	inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
	inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
	inst.components.edible.sanityvalue = TUNING.SANITY_SUPERTINY,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/fruit_syrup.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("tradable")

	return inst
end


return Prefab( "common/inventory/fruit_syrup", fn, Assets )