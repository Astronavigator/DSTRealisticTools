local Assets =
{
	Asset("ANIM", "anim/mush_melon_cooked.zip"),
    Asset("ATLAS", "images/inventoryimages/mush_melon_cooked.xml"),
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
	
	inst.AnimState:SetBank("mush_melon_cooked")
	inst.AnimState:SetBuild("mush_melon_cooked")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
	inst:AddTag("honeyed")
		    

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()

	
	inst:AddComponent("edible")
	inst.components.edible.foodtype = "GENERIC"
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
	inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
	inst.components.edible.sanityvalue = TUNING.SANITY_MEDLARGE*2,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/mush_melon_cooked.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 2
	
	return inst
end


return Prefab( "common/inventory/mush_melon_cooked", fn, Assets )