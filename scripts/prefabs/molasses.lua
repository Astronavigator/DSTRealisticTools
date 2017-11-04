local Assets=
{
	Asset("ANIM", "anim/molasses.zip"),
	Asset("ATLAS", "images/inventoryimages/molasses.xml"),
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
    
    inst.AnimState:SetBank("molasses")
    inst.AnimState:SetBuild("molasses")
    inst.AnimState:PlayAnimation("idle")
    
	inst:AddTag("preparedfood")	
	inst:AddTag("honeyed")	
		    

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()


    inst:AddComponent("edible")
	inst.components.edible.foodtype = "GENERIC"
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
	inst.components.edible.sanityvalue = TUNING.SANITY_TINY,
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
    inst:AddComponent("bait")
		
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = 2
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
   	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/molasses.xml"

    return inst
end

return Prefab( "common/inventory/molasses", fn, Assets ) 
