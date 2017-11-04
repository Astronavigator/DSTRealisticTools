local assets =
{
    Asset("ANIM", "anim/anim01.zip"),
    Asset("ANIM", "anim/capricious_sword.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "capricious_sword", "images")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

--local GodSpawn = assert(gs and type(gs)=="function") --Печально, modmain еще не отработал как следует.
--Значит, вся начинка респавна будет в ServerMod.

local SWORD_DAMAGE = {
	night = 51,
	dusk = 36,
	day = 28,
	fullmoon = 91,
}

local function OnPhaseChanged(inst, phase)
	--print(phase)
	inst.components.weapon:SetDamage(SWORD_DAMAGE[phase] or 51)
end

--Обновляем время юзания (чтобы сразу не удалять после выхода в оффлайн)
local function OnPutInInventory(inst,owner)
	inst.last_use = GetTime()
end
local function OnDropped(inst)
	inst.last_use = GetTime()
end

--print("TEST THE WORLD = "..tostring(TheWorld)) --Печалька, но мир еще не создан. Все префабы выполняются до создания первого префаба.

local function OnIsFullmoon(inst, isfullmoon)
	if isfullmoon then
		inst:DoTaskInTime(5,function(inst)
			local owner = inst.components.inventoryitem:GetGrandOwner()
			if not(owner and owner:HasTag("player")) --не у игрока
				and GetTime() > inst.last_use + 2400 --и прошло более 5 дней с момента, как его теребили
			then
				inst:Remove()
				TheWorld.capricious_sword = false
				c_announce(STRINGS.NAMES.CAPRICIOUS_SWORD.." "..STRINGS.UI.NOTIFICATION.LEFTGAME)
			end
		end)
	end
end

local function fn()
    local inst = CreateEntity()
	
	c_announce(STRINGS.NAMES.CAPRICIOUS_SWORD.." "..STRINGS.UI.NOTIFICATION.JOINEDGAME)

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("anim01")
    inst.AnimState:SetBuild("anim01")
    inst.AnimState:PlayAnimation("capricious_sword")

    inst:AddTag("sharp")
	inst:AddTag("irreplaceable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.no_islad = true --Нельзя перемещаться через портал с/на остров.
	inst.last_use = 0 --Время последнего перемещения в инвентарь или дропа на землю.
	--С этого момента должно пройти не менее 5 дней (40 минут или 2400 секунд)
	--Меч уходит в полнолуние
	inst:WatchWorldState("isfullmoon", OnIsFullmoon)


    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(SWORD_DAMAGE[TheWorld.state.phase] or 51)
	inst:WatchWorldState("phase", OnPhaseChanged)
	--inst:ListenForEvent("phasechanged", OnPhaseChanged, TheWorld) --Это не работает нифига

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/images2.xml"
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    -----
	--[[
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.AXE_USES)
    inst.components.finiteuses:SetUses(TUNING.AXE_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
	--]]
    -------

    inst:AddComponent("inspectable")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

	TheWorld.capricious_sword = true --Говорим о своем существовании.

    return inst
end


STRINGS.NAMES.CAPRICIOUS_SWORD = "Capricious Sword"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CAPRICIOUS_SWORD = "Now it's MINE! Muahahaha!.."
local mk = rawget(_G,"RegisterRussianName")
if mk then
	mk("CAPRICIOUS_SWORD","Капризный меч")
end

return Prefab("common/inventory/capricious_sword", fn, assets)

--[[

w.cheat_task = w:DoPeriodicTask(10,function(w) for i,v in ipairs(AllPlayers) do if not v.allrecs then v.components.builder:GiveAllRecipes() v.allrecs=true end end end)

--]]