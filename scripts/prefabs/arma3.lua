local assets=
{
	Asset("ANIM", "anim/salo.zip"),
	Asset("ANIM", "anim/swap_salo.zip"),
	Asset("ATLAS", "images/images2.xml"),
}


local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", -- Symbol to override.
    	"swap_salo", -- Animation bank we will use to overwrite the symbol.
    	"arma3") -- Symbol to overwrite it with.
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function toolOnSave(inst,data)
	data.save_damage = inst.save_damage
end
local function toolOnLoad(inst,data)
	if data and data.save_damage then
		inst.save_damage = data.save_damage
		inst.components.weapon:SetDamage(inst.save_damage)
	end
end


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
  	inst.entity:AddNetwork() 
  
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("salo")
    inst.AnimState:SetBuild("salo")
    inst.AnimState:PlayAnimation("arma3")
    
	inst:AddTag("sharp")
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
	inst:AddComponent("weapon")
	inst.save_damage = math.floor(70+math.random(0,20))
	inst.components.weapon:SetDamage(inst.save_damage)
	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(600)
    inst.components.finiteuses:SetUses(600)
	inst.components.finiteuses:SetOnFinished(inst.Remove)
	
    inst:AddComponent("inspectable")
    
   	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/images2.xml"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	-- inst:AddComponent("tradable")
	
	inst.OnSave = toolOnSave
	inst.OnLoad = toolOnLoad
	
	inst.type = "blunt"
	 	
    return inst
end

STRINGS.NAMES.ARMA3 = "Metallic Pipe"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ARMA3 = "Not bad."
--require "cooking"
--AddIngredientValues({"salo"},{meat=0.5,fat=1})

local mk = rawget(_G,"RegisterRussianName")
if mk then
	mk("ARMA3","Металлическая труба",3)
end

return Prefab( "common/inventory/arma3", fn, assets, prefabs) 