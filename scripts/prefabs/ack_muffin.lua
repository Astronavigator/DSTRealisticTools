local Assets =
{
	Asset("ANIM", "anim/ack_muffin.zip"),
    Asset("ATLAS", "images/inventoryimages/ack_muffin.xml"),
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
	
	inst.AnimState:SetBank("ack_muffin")
	inst.AnimState:SetBuild("ack_muffin")
	inst.AnimState:PlayAnimation("idle", false)
	
	inst:AddTag("preparedfood")
    

	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()

	
	inst:AddComponent("edible")
	inst.components.edible.foodtype = "GENERIC"
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
	inst.components.edible.hungervalue = TUNING.CALORIES_TINY
	inst.components.edible.sanityvalue = TUNING.SANITY_SUPERTINY,

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/ack_muffin.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
	-- if IsDLCEnabled(REIGN_OF_GIANTS) then inst:AddTag("catfood") else end

	-- inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
	--[[
	GOLD_VALUES=
	    {
	        MEAT = 1,
	        RAREMEAT = 5,
	        TRINKETS=
	        {
	            4,6,4,5,4,5,4,8,7,2,5,8,
	        }
	    },
	]]
		
	return inst
end


return Prefab( "common/inventory/ack_muffin", fn, Assets )