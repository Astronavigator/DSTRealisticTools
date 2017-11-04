require "prefabutil"
require "tuning"

local assets =
{
	Asset("ANIM",  "anim/stingertrap.zip"), 
	-- Asset("ANIM", "anim/stinger_trap.zip"),
    -- Asset("ATLAS", "images/inventoryimages/stingertrap.xml"),
}

local function onfinished_normal(inst)
    
	inst:RemoveComponent("inventoryitem")
    inst:RemoveComponent("mine")
    inst.persists = false
	
    inst.AnimState:PushAnimation("used", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:DoTaskInTime(3, inst.Remove)
	
end

local function OnExplode(inst, target)
    inst.AnimState:PlayAnimation("trap")
	
    if target then
        inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_trigger")
	    target.components.combat:GetAttacked(inst, TUNING.STINGERTRAP_DAMAGE)
        if METRICS_ENABLED then
			FightStat_TrapSprung(inst,target,TUNING.STINGERTRAP_DAMAGE)
		end
    end
	
    if inst.components.finiteuses then
	    inst.components.finiteuses:Use(1)
    end
	
end

local function OnReset(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_reset")
	inst.AnimState:PlayAnimation("reset")
	inst.AnimState:PushAnimation("idle", false)
end

local function OnResetMax(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/trap_teeth_reset")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:PushAnimation("idle", false)
end

local function SetSprung(inst)
    inst.AnimState:PlayAnimation("trap_idle")
end

local function SetInactive(inst)
    inst.AnimState:PlayAnimation("inactive")
end

local function OnDropped(inst)
	inst.components.mine:Deactivate()
end

local function ondeploy(inst, pt, deployer)
	inst.components.mine:Reset()
	inst.Physics:Teleport(pt:Get())
end

--legacy save support - mines used to start out activated
local function onload(inst, data)
	if not data or not data.mine then
		inst.components.mine:Reset()
	end
end

local function common_fn(bank, build, isinventoryitem)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("toothtrap.png")
   
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddTag("trap")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    inst:AddComponent("inspectable")

    if isinventoryitem then
        inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.atlasname = "images/inventoryimages/stingertrap.xml"
        inst.components.inventoryitem.nobounce = true
        inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    end

    inst:AddComponent("mine")
    inst.components.mine:SetRadius(TUNING.TRAP_TEETH_RADIUS)
	
    inst.components.mine:SetAlignment("player")
    inst.components.mine:SetOnExplodeFn(OnExplode)
    inst.components.mine:SetOnResetFn(OnReset)
    inst.components.mine:SetOnSprungFn(SetSprung)
    inst.components.mine:SetOnDeactivateFn(SetInactive)
    --inst.components.mine:StartTesting()

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.STINGERTRAP_USES)
    inst.components.finiteuses:SetUses(TUNING.STINGERTRAP_USES)
    inst.components.finiteuses:SetOnFinished(onfinished_normal)

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.LESS)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        if inst.components.mine then
            if not inst.components.mine.inactive and not inst.components.mine.issprung then
                if math.random() <= TUNING.HAUNT_CHANCE_HALF then
                    inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
                    local target = FindEntity(inst, TUNING.TRAP_TEETH_RADIUS*1.5, function(dude, inst) return dude.components.combat and not dude:HasTag("playerghost") and not (dude.components.health and dude.components.health:IsDead() and dude.components.combat:CanBeAttacked(inst)) end, nil, {"notraptrigger", "flying"}, {"monster", "character", "animal"})
                    inst.components.mine:Explode(target)
                    return true
                end
            elseif not inst.components.mine.inactive and inst.components.mine.issprung then
                if math.random() <= TUNING.HAUNT_CHANCE_OFTEN then
                    inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
                    inst.components.mine:Reset()
                    return true
                end
            elseif inst.components.mine.inactive then
                Launch(inst, haunter, TUNING.LAUNCH_SPEED_SMALL)
                inst.components.hauntable.hauntvalue = TUNING.HAUNT_TINY
                return true
            end
        end
        return false
    end)

    inst.components.mine:Deactivate()
    inst.OnLoad = onload
	
    return inst
	
end

local function MakeStingerTrapNormal()
    return common_fn("trap_teeth", "stingertrap", true)
end

return 	Prefab( "common/objects/stingertrap",  MakeStingerTrapNormal, assets),
		MakePlacer("common/stingertrap_placer", "trap_teeth", "trap_teeth", "idle" )
		
--return 	Prefab("common/inventory/stingertrap", 	MakeStingerTrapNormal, 			assets),
--		MakePlacer("common/trap_teeth_placer", "trap_teeth", "trap_teeth", "idle")
		-- MakePlacer("common/stingertrap_placer", "stingertrap", "stinertrap", 	"idle")
