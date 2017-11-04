local assets=
{
	Asset("ANIM", "anim/oleo.zip"),
	Asset("ATLAS", "images/inventoryimages/oleo.xml"),
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
    
    inst.AnimState:SetBank("oleo")
    inst.AnimState:SetBuild("oleo")
    inst.AnimState:PlayAnimation("idle")
    
	inst:AddTag("preparedfood")	
 
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	
    inst:AddComponent("edible")
	inst.components.edible.foodtype = "GENERIC"
    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL*3
    inst.components.edible.hungervalue = TUNING.CALORIES_MED
	inst.components.edible.sanityvalue = TUNING.SANITY_TINY,
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
   	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/oleo.xml"

	-- inst:AddComponent("tradable")
	 	
    return inst
end

return Prefab( "common/inventory/oleo", fn, assets, prefabs) 
