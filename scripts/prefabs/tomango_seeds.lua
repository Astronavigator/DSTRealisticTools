
local assets={
    Asset("ATLAS", "images/inventoryimages/tomango_seeds.xml"),
    Asset("IMAGE", "images/inventoryimages/tomango_seeds.tex"),
}

local prefabs = 
{
	"seeds_cooked",
	"spoiled_food",
}

local function fn_seeds()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork() 

	MakeInventoryPhysics(inst)
	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)

	inst.AnimState:SetBank("seeds")
	inst.AnimState:SetBuild("seeds")
	inst.AnimState:SetRayTestOnBB(true) 
	inst.AnimState:PlayAnimation("idle")
	

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()

		
	inst:AddComponent("edible")
	inst.components.edible.foodtype = "SEEDS" 

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM 

	inst:AddComponent("tradable")
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "tomango_seeds"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/tomango_seeds.xml"
		
	inst.components.edible.healthvalue = TUNING.HEALING_TINY/2
	inst.components.edible.hungervalue = TUNING.CALORIES_TINY

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)	
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"		
	
	inst:AddComponent("cookable")
	inst.components.cookable.product = "seeds_cooked"	
	
	inst:AddComponent("bait")
	
	inst:AddComponent("plantable")
	inst.components.plantable.growtime = TUNING.SEEDS_GROW_TIME	
	inst.components.plantable.product = "tomango"				
	
	return inst
end

return Prefab( "common/inventory/tomango_seeds", fn_seeds, assets)