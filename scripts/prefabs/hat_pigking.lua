local assets=
{
	Asset("ANIM", "anim/fa_hat_pigking.zip"),
	Asset("ATLAS", "images/images2.xml"),
}


local function OnUpdateHat(inst)
	if not inst:IsValid() then
		inst.task_hat:Cancel()
		return
	end
	local owner = inst.components.inventoryitem:GetGrandOwner()
	if not (owner and owner:HasTag("player")) then
		return
	end
	local cnt = 0
	if owner.components.leader then
		for k,v in pairs(owner.components.leader.followers) do --k = инстанс (да, ключ указывает на последователя)
			local f = k.components.follower
			if f and k:HasTag("pig") then 
				local timeLeft = math.max(0, (f.targettime or 0) - GetTime())
				if timeLeft<15 then
					f:AddLoyaltyTime(300)
					cnt = cnt+1
				end
			end
		end
	end
	if cnt>0 then
		inst.components.finiteuses:Use(cnt*0.2) --1%
	end
end

local all_rocks = {rock1=1,rock2=1,rock_flintless=1,rock_flintless_med=1,rock_flintless_low=1,rock_moon=1}

--Шапка короля добавляет 4 кусочка золота с валуна
local function OnWorking(inst,data)
	--inst - это игрок (worker), data.target - объект, над которым работаем
	--Џолучаем указатель на шапку
	local hat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	--„обавлЯем лут
	local rock = data.target
	if hat and rock.components.workable.workleft <= 0 then
		if all_rocks[rock.prefab] and rock.components.lootdropper then
			local g = rock.components.lootdropper:SpawnLootPrefab("goldnugget")
			if g then
				g.components.stackable.stacksize = 4
				hat.components.finiteuses:Use(1)
			end
		end
	end
end




local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_hat", -- Symbol to override.
    	"fa_hat_pigking", -- Animation bank we will use to overwrite the symbol.
    	"swap_hat") -- Symbol to overwrite it with.
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
        end
	
	owner.golden_king = true --просто так
	
	--обновляем время следования свиней
	if inst.task_hat then
		inst.task_hat:Cancel()
	end
	inst.task_hat = inst:DoPeriodicTask(10+math.random(),OnUpdateHat)
	
	--Дропаем в валунов больше золота
	owner:ListenForEvent("working", OnWorking)
end

local function onunequip(inst, owner) 
        owner.AnimState:ClearOverrideSymbol("swap_hat")
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
        end
	
	owner.golden_king = false
	
	--останавливаем апдейт (если есть)
	if inst.task_hat then
		inst.task_hat:Cancel()
		inst.task_hat = nil
	end
	
	--Перестаем дропать голду с валунов
	owner:RemoveEventCallback("working", OnWorking)
end

local function on_finished(inst)
	if inst.task_hat then
		inst.task_hat:Cancel()
		local owner = inst.components.inventoryitem:GetGrandOwner()
		if owner then
			owner.golden_king = false
			owner:RemoveEventCallback("working", OnWorking) --убираем халявное золото
		end
	end
	inst.Remove() --и только затем удаляем шапку
end


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
  	inst.entity:AddNetwork() 
  
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("fa_hat_pigking")
    inst.AnimState:SetBuild("fa_hat_pigking")
    inst.AnimState:PlayAnimation("idle")
    
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
    inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(20) --каждый валун -5% (итого 80 золота)
    inst.components.finiteuses:SetUses(20)
	inst.components.finiteuses:SetOnFinished(on_finished)
	
    inst:AddComponent("inspectable")
    
   	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/images2.xml"
	inst.components.inventoryitem.imagename = "hat_pigking"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	-- inst:AddComponent("tradable")
	
	--inst.OnSave = toolOnSave
	--inst.OnLoad = toolOnLoad
	 	
    return inst
end

STRINGS.NAMES.HAT_PIGKING = "Pig's Crown"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.HAT_PIGKING = "I'm not a pig!"
--require "cooking"
--AddIngredientValues({"salo"},{meat=0.5,fat=1})

local mk = rawget(_G,"RegisterRussianName")
if mk then
	mk("HAT_PIGKING","Свиная корона",3)
end

return Prefab( "common/inventory/hat_pigking", fn, assets, prefabs) 
