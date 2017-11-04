local assets=
{ 
    Asset("ANIM", "anim/sling.zip"),
    Asset("ANIM", "anim/swap_sling.zip"), 

    Asset("ATLAS", "images/inventoryimages/sling.xml"),
    Asset("IMAGE", "images/inventoryimages/sling.tex"),
}

local prefabs = 
{
	"slingshot",
}


local function OnFinished(inst)
    inst:Remove()
	owner.components.combat.min_attack_period = owner.components.combat.save_min_attack_period or 0.4
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_sling", "sling")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
	owner.components.combat.save_min_attack_period = owner.components.combat.min_attack_period
	owner.components.combat.min_attack_period = 0.6
end

local function OnUnequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    inst.AnimState:PlayAnimation("idle")
	owner.components.combat.min_attack_period = owner.components.combat.save_min_attack_period or 0.4
end

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle")
end

local function OnAttack(inst, owner, target)
	if owner.components.inventory:Has("slingshot", 1) then
		owner.components.inventory:ConsumeByName("slingshot", 1)
		local bs = SpawnPrefab("slingshot")
		bs.Transform:SetPosition(owner.Transform:GetWorldPosition())
		bs.components.projectile:Throw(owner, target)
	end
end

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    inst.entity:AddNetwork()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.entity:SetPristine()
    MakeHauntableLaunch(inst)

    MakeInventoryPhysics(inst)
    
    anim:SetBank("sling")
    anim:SetBuild("sling")
    anim:PlayAnimation("idle")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(12, 14)
	inst.components.weapon.OnAttack = OnAttack
	
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(30)
    inst.components.finiteuses:SetUses(30)
    
    inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sling"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sling.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )

	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
	MakeSmallPropagator(inst)
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
	
    return inst
end

return  Prefab("common/inventory/sling", fn, assets, prefabs)