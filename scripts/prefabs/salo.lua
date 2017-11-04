local assets=
{
	Asset("ANIM", "anim/salo.zip"),
	Asset("ATLAS", "images/images2.xml"),
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
    
    inst.AnimState:SetBank("salo")
    inst.AnimState:SetBuild("salo")
    inst.AnimState:PlayAnimation("salo")
    
	--inst:AddTag("preparedfood")	
 
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	
    inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"
    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL*3
    inst.components.edible.hungervalue = TUNING.CALORIES_MED
	inst.components.edible.sanityvalue = TUNING.SANITY_TINY
	
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = 10 --TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
   	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/images2.xml"
	
	inst:AddComponent("tradable")

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	-- inst:AddComponent("tradable")
	 	
    return inst
end

STRINGS.NAMES.SALO = "Lard"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SALO = "It was very very fat pig..."
require "cooking"
AddIngredientValues({"salo"},{meat=0.5,fat=1})

local mk = _G.rawget(_G,"RegisterRussianName")
if mk then
	mk("SALO","Сало",4)
end

return Prefab( "common/inventory/salo", fn, assets, prefabs) 
