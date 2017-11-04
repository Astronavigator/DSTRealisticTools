local assets =
{
	Asset("ANIM", "anim/golds.zip"),
	Asset("ANIM", "anim/swap_project.zip"),
	Asset("ATLAS", "images/images1.xml"),
}



local function shine(inst)
	inst.task = nil
	if not inst.AnimState:IsCurrentAnimation("sparkle") then
		inst.AnimState:PlayAnimation("sparkle")
		inst.AnimState:PushAnimation("gold1", true)
	end
	inst.task = inst:DoTaskInTime(4 + math.random() * 5, shine)
end

local function on_resize(inst,data)
	if data.stacksize>=3 and data.oldstacksize < 3 then
		inst.AnimState:PlayAnimation("gold3",true)
		inst.components.inventoryitem:ChangeImageName("gold3")
	elseif data.stacksize<3 and data.oldstacksize >= 3 then
		inst.AnimState:PlayAnimation("gold1",true)
		inst.components.inventoryitem:ChangeImageName("gold1")
	end
end

-- EQUIP FUNCTIONS --

local function OnEquip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_project", "swap_gold")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function OnUnequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    --inst.AnimState:PlayAnimation("gold1",true)
end

-- PROJECTILE FUNCTIONS ---

local function OnThrown(inst, owner, target)
    if target ~= owner then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    end
	if inst.components.stackable then
		print("TROW_STACK_SIZE: "..tostring(inst.components.stackable.stacksize))
	end
    inst.AnimState:PlayAnimation("gold1", true)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
end

local function OnHit(inst, owner, target)
	if inst.components.stackable then
		print("HIT_STACK_SIZE: "..tostring(inst.components.stackable.stacksize))
	end
    if owner == target then
        OnDropped(inst)
    end
    local impactfx = SpawnPrefab("impact")
    if impactfx then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
        impactfx:FacePoint(inst.Transform:GetWorldPosition())
    end
	inst.AnimState:SetOrientation( ANIM_ORIENTATION.Default )
    --[[if owner and not (inst.components.finiteuses:GetUses() < 1) then
		inst.AnimState:PlayAnimation("gold1", true)
        inst.AnimState:SetOrientation( ANIM_ORIENTATION.Default )
    end--]]
end

local function OnMiss(inst, owner, target)
	if inst.components.stackable then
		print("MISS_STACK_SIZE: "..tostring(inst.components.stackable.stacksize))
	end
    inst.AnimState:PlayAnimation("gold1",true)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.Default )
    inst.Physics:Stop()
end

--------PREFAB FUNCTION ------------

local function fn(color)

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	--inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("golds")
	inst.AnimState:SetBuild("golds")
	inst.AnimState:PlayAnimation("gold1",true)
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/images1.xml"
	inst.components.inventoryitem.imagename = "gold1"
	
	--inst.OnSave = OnSave
	--inst.OnLoad = OnLoad
	
	
	--MakeSmallBurnable(inst, TUNING.LONG_BURNABLE)
	--MakeSmallPropagator(inst)
	--inst.components.burnable:SetOnIgniteFn(make_damp)

	--inst:AddComponent("fuel")
	--inst.components.fuel.fuelvalue = TUNING.MED_FUEL
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = 5 --TUNING.STACK_SIZE_MICRO --3
	inst:ListenForEvent("stacksizechange",on_resize)
	
	--shine(inst) --сверкает. ня!
	
	--Теперь это оружие
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(10)
    inst.components.weapon:SetRange(7,9)	
	
	inst:AddComponent("projectile")
	inst.components.projectile:SetSpeed(30)
	inst.components.projectile:SetOnThrownFn(OnThrown)
	inst.components.projectile:SetOnHitFn(OnHit)
	inst.components.projectile:SetHoming(false)
	inst.components.projectile:SetOnMissFn(OnMiss)
	inst.components.projectile:SetLaunchOffset(Vector3(3, 2, 0))
	inst.components.projectile:SetRange(25)

	
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	inst.components.equippable.equipstack = true
	--]]
	
	return inst
end


STRINGS.NAMES.GOLD = "Gold Bar"
STRINGS.RECIPE_DESC.GOLD = "Just a gold bar. Very useful."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GOLD = "So yellow."
local mk = rawget(_G,"RegisterRussianName")
if mk then
	mk("GOLD","Золотой слиток")
end

return Prefab("common/inventory/gold", fn, assets, prefabs)
