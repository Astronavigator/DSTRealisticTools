--Down when sane, up when insane.
local assets =
{
    Asset("ANIM", "anim/sleep_rock.zip"),
    Asset("ANIM", "anim/blocker_sanity_fx.zip"),
}

local prefabs =
{
    "sanity_raise",
    "sanity_lower",
}

local COLLISION_SIZE = 1 --must be an int
local NEAR_DIST_SQ = 10 * 10
local FAR_DIST_SQ = 11 * 11

local UPDATE_INTERVAL = 1
local UPDATE_OFFSET = 0 --used to stagger periodic updates across entities

--V2C: Use a shared add/remove wall because regions may overlap
local PF_SHARED = {}

local function AddSharedWall(pathfinder, x, z, inst)
    local id = tostring(x)..","..tostring(z)
    if PF_SHARED[id] == nil then
        PF_SHARED[id] = { [inst] = true }
        pathfinder:AddWall(x, 0, z)
    else
        PF_SHARED[id][inst] = true
    end
end

local function RemoveSharedWall(pathfinder, x, z, inst)
    local id = tostring(x)..","..tostring(z)
    if PF_SHARED[id] ~= nil then
        PF_SHARED[id][inst] = nil
        if next(PF_SHARED[id]) ~= nil then
            return
        end
        PF_SHARED[id] = nil
    end
    pathfinder:RemoveWall(x, 0, z)
end

local function OnIsPathFindingDirty(inst)
    if inst._ispathfinding:value() then
        if inst._pftable == nil then
            inst._pftable = {}
            local pathfinder = TheWorld.Pathfinder
            local x, y, z = inst.Transform:GetWorldPosition()
            x = math.floor(x * 100 + .5) / 100
            z = math.floor(z * 100 + .5) / 100
            for dx = -COLLISION_SIZE, COLLISION_SIZE do
                local x1 = x + dx
                for dz = -COLLISION_SIZE, COLLISION_SIZE do
                    local z1 = z + dz
                    AddSharedWall(pathfinder, x1, z1, inst)
                    table.insert(inst._pftable, { x1, z1 })
                end
            end
        end
    elseif inst._pftable ~= nil then
        local pathfinder = TheWorld.Pathfinder
        for i, v in ipairs(inst._pftable) do
            RemoveSharedWall(pathfinder, v[1], v[2], inst)
        end
        inst._pftable = nil
    end
end

local function InitializePathFinding(inst, isready)
    if isready then
        inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
        OnIsPathFindingDirty(inst)
    else
        inst:DoTaskInTime(0, InitializePathFinding, true)
    end
end

local function turnonpathfinding(inst)
    _ispathfinding:set(true)
end

local function turnoffpathfinding(inst)
    _ispathfinding:set(false)
end

local function setactivephysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
end

local function setinactivephysics(inst)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
end

local function transitionactive(inst)
    inst.active = true
	inst.Light:Enable(inst.active)
    inst.AnimState:PlayAnimation("raise")
    inst.AnimState:PushAnimation("idle_active", true)
    setactivephysics(inst)
    inst._ispathfinding:set(true)
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_up")
    --SpawnPrefab("sanity_raise").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function transitioninactive(inst)
    inst.active = false
	inst.Light:Enable(inst.active)
    inst.AnimState:PlayAnimation("lower")
    inst.AnimState:PushAnimation("idle_inactive", true)
    setinactivephysics(inst)
    inst._ispathfinding:set(false)
    inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_down")
    --SpawnPrefab("sanity_lower").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function UpdateActiveAnim(inst)
	--p("UpdateActiveAnim")
	local stage = inst.show_stage
	if stage == 0 then
		print("ERROR: trying to show active obelisk on stage 0.")
		return
	elseif stage == 1 then --поднимаемся из земли
		inst.AnimState:PlayAnimation("raise1")
		inst.AnimState:PushAnimation("regen1", true)
		inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_up")
	elseif stage > 1 and stage < 6 then
		inst.AnimState:PushAnimation("regen"..stage, true)
	elseif stage == 6 then --поднимаемся на макс. высоту
		inst.AnimState:PlayAnimation("raise2")
		inst.AnimState:PushAnimation("idle_active", true)
		inst.SoundEmitter:PlaySound("dontstarve/sanity/shadowrock_up")
		inst.net_is_active:set(true)
		inst.is_active = true
	end
	--print("SHOW stage = "..stage)
	if inst.my_rocktask then
		inst.my_rocktask:Cancel()
		inst.my_rocktask=nil
	end
	inst.Light:Enable(true)
end

local function setactive(inst, force) --force никогда не наступает
	--p("---set_Active")
    if not force and (inst.active or inst.activatetask ~= nil) then
        return
    end
	
	--p("stage = "..inst.grow_stage..", fuel = "..tostring(inst.fuel)..", show="..tostring(inst.show_stage))
	if inst.grow_stage <= 0 or inst.fuel or inst.show_stage == 0 then --разряжен или на подзарядке - нельзя вылезать
		return
	end
	--p("SUCESS")

    if inst.deactivatetask ~= nil then
        inst.deactivatetask:Cancel()
        inst.deactivatetask = nil
    end

    if true then
        if inst.activatetask ~= nil then
            inst.activatetask:Cancel()
            inst.activatetask = nil
        end

        inst.active = true
		inst.Light:Enable(inst.active)
        --inst.AnimState:PlayAnimation("idle_active")
		UpdateActiveAnim(inst)
        setactivephysics(inst)
        inst._ispathfinding:set(true)
    else
        inst.activatetask = inst:DoTaskInTime(math.random(), transitionactive) 
    end
end

local function setinactive(inst, force)
	--p("----setincative")
    if not force and (not inst.active or inst.deactivatetask ~= nil) then
        return
    end

	--p("SUCCESS")
    if inst.activatetask ~= nil then
        inst.activatetask:Cancel()
        inst.activatetask = nil
    end
	
	inst.net_is_active:set(false)
	inst.is_active = false

    if true then
        if inst.deactivatetask ~= nil then
            inst.deactivatetask:Cancel()
            inst.deactivatetask = nil
        end

        inst.active = false
		inst.Light:Enable(inst.active)
		if inst.show_stage >=6 then
			inst.AnimState:PlayAnimation("lower") --большой обелиск в землю
		else
			inst.AnimState:PlayAnimation("lower2") --средний обелиск в землю
		end
		inst.AnimState:PushAnimation("idle_inactive", true)
        --inst.AnimState:PlayAnimation("idle_inactive")
        setinactivephysics(inst)
        inst._ispathfinding:set(false)
    else
        inst.deactivatetask = inst:DoTaskInTime(math.random(), transitioninactive)  
    end
	inst.show_stage = 0
	if inst.my_rocktask then
		inst.my_rocktask:Cancel()
		inst.my_rocktask=nil
	end
	inst.Light:Enable(false)
end

local DELTA_PLUS = 100 / (3*3 * 7.5 * 48)  --за 3 часа фул реген
local DELTA_MINUS = 100 / (24*3 * 7.5 * 48) --за 24 часа полная растрата

local old_GetAttacked
local function new_GetAttacked(self,attacker, damage, weapon, stimuli, ...)
	if stimuli == "wind" then
		--self.inst:PushEvent("blocked", { attacker = attacker })
		damage = 0 --приведет к блокировке атаки
	elseif self.inst.show_stage == 0 then
		damage = damage * 0.2 --под землей бить в 5 раз сложнее.
	end
	--print("GetAttacked: atckr="..tostring(attacker)..", dmg="..tostring(damage)..", wep="..tostring(weapon)..", stml="..tostring(stimuli))
	return old_GetAttacked(self,attacker, damage, weapon, stimuli, ...)
end

local function refresh(inst)
	--p("---Regen: fuel = "..tostring(inst.fuel))
	if inst.fuel or (inst.show_stage>0 and inst.show_stage < 6) then --если на 0 не заряжено, значит просто кончилась от времени
		--p("+"..DELTA_PLUS)
		inst.grow_stage = inst.grow_stage + DELTA_PLUS
	elseif inst.grow_stage>0 then
		--p("-"..DELTA_MINUS)
		inst.grow_stage = inst.grow_stage - DELTA_MINUS
		if inst.grow_stage<=0 then
			setinactive(inst)
		end
	end
	inst.grow_stage = math.min(math.max(inst.grow_stage,0),100)
	--p("RESULT = "..inst.grow_stage)
    --[[local x, y, z = inst.Transform:GetWorldPosition()
    if inst.active then
        for i, v in ipairs(AllPlayers) do
            if not v:HasTag("notarget") and
                v.components.sanity ~= nil and
                v.components.sanity:IsSane() == inst.activeonsane then
                local p1x, p1y, p1z = v.Transform:GetWorldPosition()
                if distsq(x, z, p1x, p1z) < FAR_DIST_SQ then
                    return
                end
            end
        end
        setinactive(inst)
    else
        for i, v in ipairs(AllPlayers) do
            if not v:HasTag("notarget") and
                v.components.sanity ~= nil and
                v.components.sanity:IsSane() == inst.activeonsane then
                local p1x, p1y, p1z = v.Transform:GetWorldPosition()
                if distsq(x, z, p1x, p1z) < NEAR_DIST_SQ then
                    setactive(inst)
                    return
                end
            end
        end
    end--]]
end


local function onremove(inst)
    inst._ispathfinding:set_local(false)
    OnIsPathFindingDirty(inst)
end

local function OnPhase(inst,phase)
	--p("OnPhase = "..phase)
	if phase == "dusk" then --вечером вылазим из своих нор и начинаем работать. Только вечером!
		if inst.fuel then -- на подзарядке в земле
			if inst.grow_stage > 0 then --если есть хоть капля "силы", то можно дергаться в сторону высовывания из земли.
				inst.fuel = false --вечером "топливо" кончается.
				inst.show_stage = 1
				inst.my_rocktask = inst:DoTaskInTime(0.5+math.random()*4.5,setactive)
			end
		elseif inst.show_stage>0 and inst.show_stage < 6 then --уже не в земле. Обязательно больше 0
			inst.show_stage = inst.show_stage + 1
			inst.my_rocktask = inst:DoTaskInTime(0.5+math.random()*4.5,UpdateActiveAnim)
		end
	end
end

local cook_aliases=
{
	cookedsmallmeat = "smallmeat_cooked",
	cookedmonstermeat = "monstermeat_cooked",
	cookedmeat = "meat_cooked"
}
local cooking = require("cooking")
local function GetTags(prefab) --Возвращает значение из казана
	if cook_aliases[prefab] and not cooking.ingredients[prefab] then
		prefab = cook_aliases[prefab] --Костыль на костыль, однако.
	end
	return cooking.ingredients[prefab] and cooking.ingredients[prefab].tags or {}
end

local function OnSave(inst,data)
	data.grow_stage = inst.grow_stage
	data.fuel = inst.fuel
	data.show_stage = inst.show_stage
end
local function OnLoad(inst,data)
	if data then
		--arr(data)
		inst.grow_stage = data.grow_stage or 0
		inst.fuel = data.fuel or false
		inst.show_stage = data.show_stage or 6
		--p("...OnLoad: fuel="..tostring(inst.fuel)..", grow="..tostring(inst.grow_stage)..", show="..tostring(inst.show_stage))
		if inst.show_stage <=0 then
			setinactive(inst)
		else
			--UpdateActiveAnim(inst)
			setactive(inst)
		end
	end
end

--x=fe("sleep_rock") x.grow_stage=0 x.show_stage = 5 x.fuel=false
local function sleep_rock_desc_fn(inst,viewer)
	if inst.show_stage >=6 and inst.grow_stage > 0 then
		return "It's blocking magic now."
	elseif inst.grow_stage == 0 and not inst.fuel then
		return "It's empty and useless. Touch it."
	else
		return "It's gaining the power."
	end
end

local buildsound="dontstarve/common/place_structure_stone"
local destroysound="dontstarve/common/destroy_stone"
    local function onrepaired(inst)
        inst.SoundEmitter:PlaySound(buildsound)
    end

local function onhit(inst)
	--p("onhit")
	inst.SoundEmitter:PlaySound(destroysound)
	if not (inst.fuel) then	--если не в земле
		setinactive(inst)
		inst.fuel = true --активируем подзарядку
	end
end

local function ondeath(inst,data)
	--генерируем лут и медальон
	local med = SpawnPrefab("nightmare_timepiece")
	if med and med:IsValid() then
		med.grow_stage = inst.grow_stage --копируем силу 1 в 1
		med:UseAmulet(0) --обновляем % на амулете
		local x,y,z = inst.Transform:GetWorldPosition()
		med.Transform:SetPosition(x,0,z) --бросаем сверху
	end
	--jj: почему-то не умирает сам.
	--Поможем ему... :)
	--inst.components.lootdropper:SpawnLootPrefab("cutstone")
	--inst.components.lootdropper:SpawnLootPrefab("cutstone")
	--inst.components.lootdropper:SpawnLootPrefab("nightmarefuel")
	--inst.components.lootdropper:SpawnLootPrefab("nightmarefuel")
	inst:Remove()
end

local OnIsActiveDirty
OnIsActiveDirty = function(inst) --клиентская функция. Проверяем все дела
	inst.is_active = inst.net_is_active:value()
	--p("OnIsActiveDirty = "..tostring(inst.is_active))
	if inst.my_children then
		for k,v in pairs(inst.my_children) do
			if inst.is_active then
				k:Show()
			else
				k:Hide()
			end
		end
	else
		--p("No array")
		inst:DoTaskInTime(3,OnIsActiveDirty)
	end
end

local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
	inst.entity:AddLight()
    inst.entity:AddNetwork()
	

    MakeObstaclePhysics(inst, COLLISION_SIZE)

    inst.MiniMapEntity:SetIcon("obelisk.png")

    inst.AnimState:SetBank("sleep_rock") --SetBank("blocker_sanity")
    inst.AnimState:SetBuild("sleep_rock")
    inst.AnimState:PlayAnimation("idle_inactive")

    setinactivephysics(inst)

    inst._pftable = nil
    inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
    InitializePathFinding(inst, TheWorld.ismastersim)
	
    inst.OnRemoveEntity = onremove
	
	inst:AddTag("invert_magic") --> for blocking magic

    inst.entity:SetPristine()

	inst.is_active = false --пересылка на клиентскую сторону статуса активности блокировки магии
	inst.net_is_active = net_bool(inst.GUID, "is_active", "on_isactive_dirty")
    if not TheWorld.ismastersim then
		inst:ListenForEvent("on_isactive_dirty", OnIsActiveDirty)
        return inst
    end
	inst:DoTaskInTime(3,function(inst) --удаляем пунктир.
		--p("3 sec task")
		if not inst.is_active then
			--p("not is_active")
			inst.is_active = true
			inst.net_is_active:set(true)
			inst.is_active = false
			inst.net_is_active:set(false)
		end
	end)
	
	inst.Light:Enable(false)	
	inst.Light:SetRadius(1)
	inst.Light:SetFalloff(0.5)
	inst.Light:SetIntensity(.85)
	inst.Light:SetColour(1, 0.5, 0.2)

	--inst:DoTaskInTime(3,setactive)

    inst.active = false
    inst.activatetask = nil
    inst.deactivatetask = nil

    inst:DoPeriodicTask(10 + math.random(), refresh)

    --Stagger updates for next spawned entity
    --[[UPDATE_OFFSET = UPDATE_OFFSET + FRAMES
    if UPDATE_OFFSET > UPDATE_INTERVAL then
        UPDATE_OFFSET = 0
    end--]]

    inst:AddComponent("inspectable")
    --inst.components.inspectable.getstatus = getstatus
	inst.components.inspectable.getspecialdescription = sleep_rock_desc_fn
	
	inst:WatchWorldState("phase", OnPhase)
	
	inst.UseAmulet = function()
		return (inst.grow_stage > 0 and inst.show_stage >=6)
	end
	inst.grow_stage = 1 --начинаем с 1%, какой бы ни бы амулет. Амулет гораздо проще и быстрее регенить.
	inst.show_stage = 0
	inst.fuel = true
	inst.grow_stage_forever = true
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	
        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = MATERIALS.STONE
        inst.components.repairable.onrepaired = onrepaired

        inst:AddComponent("combat")
        inst.components.combat.onhitfn = onhit
		old_GetAttacked = inst.components.combat.GetAttacked
		inst.components.combat.GetAttacked = new_GetAttacked

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(1800)
        inst.components.health:SetCurrentHealth(150)
        --inst.components.health.ondelta = onhealthchange
        inst.components.health.nofadeout = true
		inst.components.health.destroytime = 0
        inst.components.health.canheal = false
        --[[if data.name == "moonrock" then
            inst.components.health:SetAbsorptionAmountFromPlayer(TUNING.MOONROCKWALL_PLAYERDAMAGEMOD)
        end--]]
        inst:AddTag("noauradamage")
		inst:AddTag("wall") --чтобы не атаковать при наличии мода NoWallAttack

        inst.components.health.fire_damage_scale = 0 --огонь не наносит урон

	inst:ListenForEvent("death",ondeath)
	
	inst:AddComponent("lootdropper")

    return inst
end


return Prefab("common/objects/sleep_rock", commonfn, assets, prefabs),
	--MakePlacer("common/sleep_rock_placer", "blocker_sanity", "blocker_sanity", "idle_active") --, true, nil, nil, 1.775)
	MakePlacer("common/sleep_rock_placer", "firefighter_placement", "firefighter_placement", "idle", true, nil, nil, 1.79)

       --Prefab("forest/objects/rocks/sanityrock", sanityrock, assets, prefabs)