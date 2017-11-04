local assets=
{
	Asset("ANIM", "anim/salo.zip"),
	Asset("ANIM", "anim/swap_salo.zip"),
	Asset("ATLAS", "images/images2.xml"),
}


local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", -- Symbol to override.
    	"swap_salo", -- Animation bank we will use to overwrite the symbol.
    	"staff0") -- Symbol to overwrite it with.
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
  	inst.entity:AddNetwork() 
  
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("salo")
    inst.AnimState:SetBuild("salo")
    inst.AnimState:PlayAnimation("staff0")
    
	inst:AddTag("sharp")
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(11)
	--inst.save_damage = 85
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(500)
    inst.components.finiteuses:SetUses(500)
	inst.components.finiteuses:SetOnFinished(inst.Remove)
	
    inst:AddComponent("inspectable")
    
   	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/images2.xml"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	-- inst:AddComponent("tradable")
	 	
    return inst
end

STRINGS.NAMES.STAFF0 = "Stick"
STRINGS.RECIPE_DESC.STAFF0 = "Just a basic stick."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.STAFF0 = "I need it to make a tool or spear."
--require "cooking"
--AddIngredientValues({"salo"},{meat=0.5,fat=1})

local mk = rawget(_G,"RegisterRussianName")
if mk then
	mk("STAFF0","Древко",4)
end

return Prefab( "common/inventory/staff0", fn, assets, prefabs) 
