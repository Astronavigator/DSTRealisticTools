local assets=
{
	Asset("ANIM", "anim/salo.zip"),
	Asset("ATLAS", "images/images2.xml"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
  	inst.entity:AddNetwork() 
  
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("salo")
    inst.AnimState:SetBuild("salo")
    inst.AnimState:PlayAnimation("money")
    
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	
    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.WOOD
    inst.components.edible.woodiness = 10
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = 80

    inst:AddComponent("inspectable")
    
   	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/images2.xml"
	
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

	MakeMediumBurnable(inst)
	MakeMediumPropagator(inst)
	-- inst:AddComponent("tradable")
	 	
    return inst
end

STRINGS.NAMES.MONEY = "Money"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SALO = "Haha! Now I'm rich!"
--require "cooking"
--AddIngredientValues({"salo"},{meat=0.5,fat=1})

local mk = rawget(_G,"RegisterRussianName")
if mk then
	mk("MONEY","Деньги",5,"Деньгам")
end

return Prefab( "common/inventory/money", fn, assets, prefabs) 
