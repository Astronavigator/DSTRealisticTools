local assets =
{
    Asset("ANIM", "anim/anim01.zip"),
}

local function ondaycomplete(inst)
    if inst.chargeleft > 0 then
		inst.chargeleft = inst.chargeleft - 1
		if inst.chargeleft <=0 then
			inst:turn_off()
		end
    end
end

local function onlightning(inst)
	local delta = (math.floor( 7 + math.random() * 2 - inst.chargeleft * 0.1 + 0.5))*2 --примерно с 50 дня дельта станет отрицательной
	if delta < 1 then
		delta = 1 --Но дельта не может быть отрицательной. Она даже не может быть нулевой.
	end
	inst.chargeleft = inst.chargeleft + delta
	if inst.chargeleft > 299 then
		inst.chargeleft = 299 --почти двое суток
	end
	if inst.chargeleft > 0 then
		inst:turn_on()
	end
end

local function OnSave(inst, data)
    if inst.chargeleft > 0 then
        data.chargeleft = inst.chargeleft
    end
end

local function OnLoad(inst, data)
    if data then
        inst.chargeleft = data.chargeleft or 0
		if inst.chargeleft > 0 then
			inst:turn_on()
		end
    end
end


local function turn_task_fn(inst)
	local val = inst.turn_task_val + 1
	inst.turn_task_val = val
	if val == 9 or val == 18 or val == 20 or val == 26 then
		inst.AnimState:PlayAnimation("lamp_nolight")
		inst.Light:Enable(false)
	elseif val==1 or val==2 or val == 17 or val == 19 or val == 25 or val == 27 then
		inst.AnimState:PlayAnimation("lamp_light")
		inst.Light:Enable(true)
		inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/spark")
	end
	if val >= 27 then
		inst.turn_task:Cancel()
		inst.turn_task = nil
	end
end


local MAX_OWN_DAYS = 10 * 480
local OWN_DELTA_MINUS = MAX_OWN_DAYS / (2 * 24 * 60 * 60 * 2) --за 2 суток уходит

local AllPlayers = AllPlayers
local function distsq (x1,y1,x2,y2)
	return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2)
end
--Срабатывает каждый 0.5 сек. Нужно прочекать всех игроков вокруг и пропушить им защиту от пвп.
local function LookUpPlayers(inst)
	local lamp_best = 0 --лучшее значение защиты. Все, кто на расстоянии 1 дня до него, также под белой птичкой.
	for i=1,#AllPlayers do
		local v = AllPlayers[i]
		local x,y,z = v.Transform:GetWorldPosition()
		local dist = distsq(x,z,inst.x,inst.z)
		if dist <= 100 then --10, привыкание
			local t = inst.knownPeople[v.userid]
			if not t then
				t = {score=0}
				inst.knownPeople[v.userid] = t
			end
			t.score = t.score + 0.5 --добавляем время
			if t.score > MAX_OWN_DAYS then --больше 10 дней
				t.score = MAX_OWN_DAYS
			end
			if dist <= 25 and inst.chargeleft > 0 then --защита новичков
				v.lamp_protect = t.score --пушим очки
				v.lamp_inst = inst
				v:PushEvent("pvp_mode",{reason="peace"})
			else
				v.lamp_protect = 0 --иначе в ренже 10 обнуляем
			end
			--А лучшего считаем для всех в большом радиусе.
			if lamp_best < t.score then
				lamp_best = t.score
			end
		end
	end
	--Записываем значение лучше защиты лампы в саму лампу (а ссылки на лампу у всех есть).
	inst.lamp_best = lamp_best
	--Таяние очков. 10 дней в 48 часов
	for k,v in pairs(inst.knownPeople) do
		v.score = v.score - OWN_DELTA_MINUS
		if v.score<=0 then
			inst.knownPeople[k] = nil
		end
	end
end

local function turn_on(inst)
	if inst.turn_task then
		inst.turn_task:Cancel()
	end
	inst.turn_task_val = 0
	inst.turn_task = inst:DoPeriodicTask(0.17,turn_task_fn)
	inst.AnimState:PlayAnimation("lamp_light")
	inst.Light:Enable(true)
	inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/spark")
	if not inst.lookup_players then
		inst.lookup_players = inst:DoPeriodicTask(0.5+math.random()*0.1,LookUpPlayers)
	end
end

local function turn_off(inst)
	if inst.turn_task then
		inst.turn_task:Cancel()
		inst.turn_task = nil
	end
	inst.AnimState:PlayAnimation("lamp_nolight")
	inst.Light:Enable(false)
	inst.SoundEmitter:PlaySound("dontstarve/characters/wx78/spark")
	if inst.lookup_players then
		inst.lookup_players:Cancel()
		inst.lookup_players = nil
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState() 
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, .3)

    inst.MiniMapEntity:SetIcon("camp.tex")

    inst.Light:Enable(false)
    inst.Light:SetRadius(1.5)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235/255,121/255,12/255)

    inst:AddTag("structure")
    inst:AddTag("lightningrod")
	inst:AddTag("newbie_lamp")

    inst.AnimState:SetBank("anim01")
    inst.AnimState:SetBuild("anim01")
    inst.AnimState:PlayAnimation("lamp_nolight")
	

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("lightningstrike", onlightning)
	inst:WatchWorldState("cycles", ondaycomplete)

	inst.knownPeople = {}
	
	--[[
    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
	--]]

    inst:AddComponent("inspectable")

    --MakeSnowCovered(inst)
    --inst:ListenForEvent("onbuilt", onbuilt)

    --MakeHauntableWork(inst)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
	
	inst.turn_on = turn_on
	inst.turn_off = turn_off
	
	inst.chargeleft = 0 --Оставшееся количество дней до полной подзарядки
	
	--Строения защищаем в любом случае, даже в выключенном.
	--Нужно 8 дней, чтобы игрок смог разрушать базу.
	--Максимум можно накопить 10 дней "своячества".
	--Чтобы атаковать другого игрока, нужно быть "своим" на 1 день дольше.
	--10 дней "падают" за 48 часов.
	inst.lookup_players = nil
	inst.x = 0
	inst.z = 0
	inst:DoTaskInTime(0,function(inst)
		local y
		inst.x, y, inst.z = inst.Transform:GetWorldPosition()
	end)
	inst.lamp_best = 0
	

    return inst
end

STRINGS.NAMES.LAMP = "Street Light"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMP = "It must be charged to protect me from other players."
local mk = rawget(_G,"RegisterRussianName")
if mk then
	mk("LAMP","Уличный фонарь")
end

return Prefab("common/objects/lamp", fn, assets)

