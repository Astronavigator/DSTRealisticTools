local Assets =
{
	Asset("ANIM", "anim/porridge.zip"),
    Asset("ATLAS", "images/inventoryimages/porridge.xml"),
}

local prefabs = 
{
	"gruel",
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
	
	inst.AnimState:SetBank("porridge")
	inst.AnimState:SetBuild("porridge")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
		    
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	

	inst:AddComponent("edible")
	inst.components.edible.foodtype = "GENERIC"
	inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
	inst.components.edible.hungervalue = TUNING.CALORIES_LARGE
	inst.components.edible.sanityvalue = TUNING.SANITY_SMALL,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/porridge.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "gruel"

	-- inst:AddComponent("tradable")
	
	return inst
end

return Prefab( "common/inventory/porridge", fn, Assets )