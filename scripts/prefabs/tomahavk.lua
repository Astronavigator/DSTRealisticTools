local assets=
{ 
    Asset("ANIM", "anim/tomahavk.zip"),
    Asset("ANIM", "anim/swap_tomahavk.zip"), 

    Asset("ATLAS", "images/inventoryimages/tomahavk.xml"),
    Asset("IMAGE", "images/inventoryimages/tomahavk.tex"),
}

local prefabs = {}

local function OnFinished(inst)
    inst.AnimState:PlayAnimation("used")
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.Default )
    inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_tomahavk", "tomahavk")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function OnUnequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    inst.AnimState:PlayAnimation("idle")
end


local function OnThrown(inst, owner, target)
    if target ~= owner then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    end
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
end

local function OnHit(inst, owner, target)
    if owner == target then
        OnDropped(inst)
    end
    local impactfx = SpawnPrefab("impact")
    if impactfx then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
        impactfx:FacePoint(inst.Transform:GetWorldPosition())
    end
    if owner and not (inst.components.finiteuses:GetUses() < 1) then
		inst.AnimState:PlayAnimation("idle", true)
        inst.AnimState:SetOrientation( ANIM_ORIENTATION.Default )
    end
end

local function OnMiss(inst, owner, target)
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.Default )
    inst.Physics:Stop()
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
    
    anim:SetBank("tomahavk")
    anim:SetBuild("tomahavk")
    anim:PlayAnimation("idle")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(15)
    inst.components.weapon:SetRange(7,9)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(20)
    inst.components.finiteuses:SetUses(1)
    
    inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile:SetLaunchOffset(Vector3(3, 2, 0))
    inst.components.projectile:SetRange(25)

    inst:AddComponent("inspectable")
    --inst:AddComponent("stackable")
    --inst.components.stackable.maxsize = 10

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "tomahavk"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/tomahavk.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	--inst.components.equippable.equipstack = true

    return inst
end

return  Prefab("common/inventory/tomahavk", fn, assets, prefabs)