local assets =
{
	Asset("ANIM", "anim/speartrap.zip"),
	
	Asset("IMAGE", "images/inventoryimages/speartrap.tex"),	
	Asset("ATLAS", "images/inventoryimages/speartrap.xml")
}


local function onfinished_normal(inst)
    
	inst:RemoveComponent("inventoryitem")
    inst:RemoveComponent("mine")
    inst.persists = false
	
    --inst.AnimState:PushAnimation("used", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:DoTaskInTime(3, inst.Remove)
	
end

--legacy save support - mines used to start out activated
local function onload(inst, data)
	if not data or not data.mine then
		inst.components.mine:Reset()
	end
end

local function OnExplode(inst, target)
    inst.AnimState:PlayAnimation("explode") --was trap
    if target then
        inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_trigger")
	    target.components.combat:GetAttacked(inst, inst.damage) --60 * 1.5
        if METRICS_ENABLED then
			FightStat_TrapSprung(inst,target,inst.damage) --60 * 1.5
		end
    end
    if inst.components.finiteuses then
	    inst.components.finiteuses:Use(1)
    end
	
	--auto reset
	--inst:DoTaskInTime(3, onload)
	--inst.components.mine:Reset()
end

local function OnReset(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_reset")
	inst.AnimState:PlayAnimation("idle") --was reset
	inst.AnimState:PushAnimation("idle", false)
end

local function SetSprung(inst)
    inst.AnimState:PlayAnimation("idle") ---was trap_idle
end

local function SetInactive(inst)
    inst.AnimState:PlayAnimation("notset") --was inactive
end

local function OnDropped(inst)
	inst.components.mine:Deactivate()
end

local function ondeploy(inst, pt, deployer)
	inst.components.mine:Reset()
	inst.Physics:Teleport(pt:Get())
end

local function MakeSpearTrap()
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("speartrap.tex")
   
    inst.AnimState:SetBank("speartrap")
    inst.AnimState:SetBuild("speartrap")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("trap")

    if not TheWorld.ismastersim then
        return inst
    end

	inst.damage = 35
    inst.entity:SetPristine()
	
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(10)
    inst.components.finiteuses:SetUses(10)
    inst.components.finiteuses:SetOnFinished(onfinished_normal)	

    inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	inst.components.inventoryitem.atlasname = "images/inventoryimages/speartrap.xml"
	inst.components.inventoryitem.atlas = resolvefilepath("images/inventoryimages/speartrap.xml")
	
	inst:AddComponent("mine")
    inst.components.mine:SetRadius(TUNING.TRAP_TEETH_RADIUS)
    inst.components.mine:SetAlignment("player")
    inst.components.mine:SetOnExplodeFn(OnExplode)
    inst.components.mine:SetOnResetFn(OnReset)
    inst.components.mine:SetOnSprungFn(SetSprung)
    inst.components.mine:SetOnDeactivateFn(SetInactive)
	
	inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LESS)

	inst.components.mine:Deactivate()
    inst.OnLoad = onload
	
	return inst
end

return Prefab("common/speartrap", MakeSpearTrap, assets),
	MakePlacer("common/speartrap_placer", "speartrap", "speartrap", "idle")