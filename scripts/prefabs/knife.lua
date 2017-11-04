local assets =
{
	-- Animation files used for the item.
	Asset("ANIM", "anim/knife.zip"),

	-- Inventory image and atlas file used for the item.
    Asset("ATLAS", "images/inventoryimages/knife.xml"),
    Asset("IMAGE", "images/inventoryimages/knife.tex"),
}
local prefabs = {
    "knife",
}
local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", -- Symbol to override.
    	"knife", -- Animation bank we will use to overwrite the symbol.
    	"knife") -- Symbol to overwrite it with.
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function init()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("knife")
    inst.AnimState:SetBuild("knife")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
	inst:AddTag("knife")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(15)

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/knife.xml"
    inst.components.inventoryitem.imagename = "knife"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP,0.25)	
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(100)
    inst.components.finiteuses:SetUses(100)
	inst.components.finiteuses:SetOnFinished(inst.Remove)
	inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1) --сколько прочности используется.

    MakeHauntableLaunch(inst)

    return inst
end
return  Prefab("common/inventory/knife", init, assets, prefabs)