local assets=
{ 
    Asset("ANIM", "anim/slingshot.zip"),

    Asset("ATLAS", "images/inventoryimages/slingshot.xml"),
    Asset("IMAGE", "images/inventoryimages/slingshot.tex"),
}

SetSharedLootTable( 'sling_drop',
{
	{'slingshot', 1.0},
})

local prefabs = {}

local function OnThrown(inst, owner, target)
    if target ~= owner then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    end
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
end

local function OnHit(inst, owner, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
        impactfx:FacePoint(inst.Transform:GetWorldPosition())
    end
	inst.components.lootdropper:SpawnLootPrefab('slingshot')
	inst:Remove()
end

local function OnMiss(inst, owner, target)
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.Default )
    inst.Physics:Stop()
end

local function OnEquip(inst, owner) 
    
end

local function OnUnequip(inst, owner) 
    
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
    
    anim:SetBank("slingshot")
    anim:SetBuild("slingshot")
    anim:PlayAnimation("idle")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(10)
    inst.components.weapon:SetRange(12,14)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(35)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile:SetLaunchOffset(Vector3(3, 2, 0))
    inst.components.projectile:SetRange(14)
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable('sling_drop')
	
    inst:AddComponent("inspectable")
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 20

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "slingshot"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/slingshot.xml"
	
    return inst
end

return  Prefab("common/inventory/slingshot", fn, assets, prefabs)