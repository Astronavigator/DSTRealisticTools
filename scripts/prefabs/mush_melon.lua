local Assets =
{
	Asset("ANIM", "anim/mush_melon.zip"),
    Asset("ATLAS", "images/inventoryimages/mush_melon.xml"),
}

local prefabs = 
{
	"mush_melon_cooked",
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
	
	inst.AnimState:SetBank("mush_melon")
	inst.AnimState:SetBuild("mush_melon")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
	inst:AddTag("honeyed")
	inst:AddTag("catfood")
   

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()

	
	inst:AddComponent("edible")
	inst.components.edible.foodtype = "GENERIC"
	inst.components.edible.healthvalue = 0
	inst.components.edible.hungervalue = TUNING.CALORIES_MED
	inst.components.edible.sanityvalue = TUNING.SANITY_SMALL*3,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/mush_melon.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("cookable")
    inst.components.cookable.product="mush_melon_cooked"

	inst:AddComponent("tradable")
	
	return inst
end



return Prefab( "common/inventory/mush_melon", fn, Assets )