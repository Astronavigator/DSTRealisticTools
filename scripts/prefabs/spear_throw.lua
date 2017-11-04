local assets=
{ 
    Asset("ANIM", "anim/spear_throw.zip"),
    Asset("ANIM", "anim/swap_spear_throw.zip"), 

    Asset("ATLAS", "images/inventoryimages/spear_throw.xml"),
    Asset("IMAGE", "images/inventoryimages/spear_throw.tex"),
}

local prefabs = {}

local function OnFinished(inst)
    inst.AnimState:PlayAnimation("used")
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.Default )
    inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_spear_throw", "spear_throw")
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
    inst.AnimState:PlayAnimation("flying", true)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
end

local function OnHit(inst, owner, target)
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
	--[[if target.components.health.currenthealth < 1 and target:HasTag("beefalo") then
		local rnd = math.random(0,100)
		if rnd < 16 then
			target.components.lootdropper:SpawnLootPrefab('large_bone')
		end
	end--]]
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
    
    anim:SetBank("spear_throw")
    anim:SetBuild("spear_throw")
    anim:PlayAnimation("idle")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(20)
    inst.components.weapon:SetRange(6, 8)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(20)
    inst.components.finiteuses:SetUses(20)
    
    inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetHoming(true)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile:SetLaunchOffset(Vector3(3, 2, 0))
    inst.components.projectile:SetRange(10)

    inst:AddComponent("inspectable")
    --inst:AddComponent("stackable")
    --inst.components.stackable.maxsize = 10
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "spear_throw"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/spear_throw.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	inst.components.equippable.equipstack = true

    return inst
end

return  Prefab("common/inventory/spear_throw", fn, assets, prefabs)