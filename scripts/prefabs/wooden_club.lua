local assets=
{
    Asset("ANIM", "anim/wooden_club.zip"),
    Asset("ANIM", "anim/swap_wooden_club.zip"),
 
    Asset("ATLAS", "images/inventoryimages/wooden_club.xml"),
    Asset("IMAGE", "images/inventoryimages/wooden_club.tex"),
}

local prefabs = 
{
	"large_bone",
}

local function OnAttack(inst, owner, target)

end

local function fn(colour)
 
    local function OnEquip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_wooden_club", "wooden_club")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end
	
	local function onfinished(inst)
		inst:Remove()
	end
    
	local function OnUnequip(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
     
    anim:SetBank("wooden_club")
    anim:SetBuild("wooden_club")
    anim:PlayAnimation("idle")
	
	inst.entity:AddNetwork()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.entity:SetPristine()
	
	inst:AddComponent("lootdropper")
	
	inst:AddTag("sharp")
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(18)
	--inst.components.weapon.OnAttack = OnAttack
	
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(100)
    inst.components.finiteuses:SetUses(100)	
	inst.components.finiteuses:SetOnFinished( onfinished )
	

    inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "wooden_club"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/wooden_club.xml"
     
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	
	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
	MakeSmallPropagator(inst)
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
 
    return inst
end
return  Prefab("common/inventory/wooden_club", fn, assets, prefabs)