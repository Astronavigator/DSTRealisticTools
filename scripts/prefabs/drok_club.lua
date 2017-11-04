local assets=
{
    Asset("ANIM", "anim/drok_club.zip"),
    Asset("ANIM", "anim/swap_drok_club.zip"),
 
    Asset("ATLAS", "images/inventoryimages/drok_club.xml"),
    Asset("IMAGE", "images/inventoryimages/drok_club.tex"),
}

local prefabs = 
{
}

local function OnAttack(inst, owner, target)

end

local function fn(colour)
	local save_min_attack_period = 0.1
    local function OnEquip(inst, owner)
		inst.owner = owner
        owner.AnimState:OverrideSymbol("swap_object", "swap_drok_club", "drok_club")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
		save_min_attack_period = owner.components.combat.min_attack_period
		owner.components.combat.min_attack_period = 1
    end
	
	local function onfinished(inst)
		inst.owner.components.combat.min_attack_period = save_min_attack_period
		inst:Remove()	
	end
    
	local function OnUnequip(inst, owner)
		inst.owner = nil
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
		owner.components.combat.min_attack_period = save_min_attack_period
    end
 
    local inst = CreateEntity()
	inst.owner = nil
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
     
    anim:SetBank("drok_club")
    anim:SetBuild("drok_club")
    anim:PlayAnimation("idle")
	
	inst.entity:AddNetwork()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.entity:SetPristine()
	
	inst:AddTag("sharp")
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(40)	
	--inst.components.weapon.OnAttack = OnAttack
	
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(100)
    inst.components.finiteuses:SetUses(100)	
	inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "drok_club"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/drok_club.xml"
     
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	
	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.MINE,1.33)
	inst.components.finiteuses:SetConsumption(ACTIONS.MINE, 15)
 
    return inst
end
return  Prefab("common/inventory/drok_club", fn, assets, prefabs)