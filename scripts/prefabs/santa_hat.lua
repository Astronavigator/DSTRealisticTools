
local assets=
{
    Asset("ANIM", "anim/santa_hat.zip"),
    Asset("ATLAS", "images/inventoryimages/santa_hat.xml")
}

        prefabs = {"forcefieldfx"}
 
    local function santa_hat_proc(inst, owner)
        inst:AddTag("forcefield")
        --inst.components.armor:SetAbsorption(SantaHatAbsorption)
        --[[local fx = SpawnPrefab("forcefieldfx")
        fx.entity:SetParent(owner.entity)
        fx.Transform:SetPosition(0, 0.2, 0)
        local fx_hitanim = function()
            fx.AnimState:PlayAnimation("hit")
            fx.AnimState:PushAnimation("idle_loop")
        end
        fx:ListenForEvent("blocked", fx_hitanim, owner)

        inst.components.armor.ontakedamage = function(inst, damage_amount)
            if owner then
                local sanity = owner.components.sanity
                if sanity then
                    local unsaneness = damage_amount * TUNING.ARMOR_SANTA_HAT_DMG_AS_SANITY
                    sanity:DoDelta(-unsaneness, false)
                end
            end
        end--]]

        inst.active = true

        --[[owner:DoTaskInTime(SantaHatForcefieldTime, function()
            fx:RemoveEventCallback("blocked", fx_hitanim, owner)
            fx.kill_fx(fx)
            if inst:IsValid() then
                inst:RemoveTag("forcefield")
                inst.components.armor.ontakedamage = nil
                inst.components.armor:SetAbsorption(SantaHatAbsorption)
                owner:DoTaskInTime(TUNING.SANTA_HAT_COOLDOWN, function() inst.active = false end)
            end
        end)--]]
    end

    local function tryproc(inst, owner)
        if not inst.active and math.random() < SantaHatForcefield then
          santa_hat_proc(inst, owner)
        end
    end 

local function santa_hat_onequip(inst, owner, fname_override)
        owner.AnimState:OverrideSymbol("swap_hat", "santa_hat", "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")
        --inst.procfn = function() tryproc(inst, owner) end
        --owner:ListenForEvent("attacked", inst.procfn)
        if owner:HasTag("player") then
			owner.AnimState:Hide("HEAD")
			--owner.AnimState:Show("HEAD_HAIR")
			owner.AnimState:Show("HEAD_HAT")
		end
		if inst.components.fueled then
			inst.components.fueled:StartConsuming()        
		end
end
 
local function santa_hat_onunequip(inst, owner)
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")
    --owner:RemoveEventCallback("attacked", inst.procfn)
		if owner:HasTag("player") then
	        owner.AnimState:Show("HEAD")
			--owner.AnimState:Hide("HEAD_HAIR")
			owner.AnimState:Hide("HEAD_HAT")
		end
		if inst.components.fueled then
			inst.components.fueled:StopConsuming()        
		end
end
 
 
     local function onequip(inst, owner, fname_override)
        local build = fname_override or fname
        owner.AnimState:OverrideSymbol("swap_hat", build, "swap_hat")
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAT_HAIR")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")
        
        
    end

    local function onunequip(inst, owner)
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAT_HAIR")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")


    end
 
 
 
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("winterhat")
    inst.AnimState:SetBuild("santa_hat")
    inst.AnimState:PlayAnimation("anim")    

        inst:AddTag("hat")
	
	
	
    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

        inst:AddComponent("inventoryitem")
        inst:AddComponent("inspectable")

        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD

        --inst.components.equippable:SetOnEquip( onequip )

        --inst.components.equippable:SetOnUnequip( onunequip )
	
	
	
	inst:AddTag("santa_hat")
    --inst:AddComponent("inspectable")

    --inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/santa_hat.xml"
    --inst:AddComponent("tradable")

    --inst:AddComponent("equippable")
    --inst.components.equippable.equipslot = EQUIPSLOTS.HEAD

    --inst:AddComponent("armor")
    --inst.components.armor:InitCondition(SantaHatDurability, SantaHatAbsorption)

	if inst.components.equippable.dapperness then --RoG
		inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL -- +1.8
	else
		inst:AddComponent("dapperness")
		inst.components.dapperness.dapperness = TUNING.DAPPERNESS_SMALL -- +1.8
	end

	
	

    inst:AddComponent("insulator")
    inst.components.insulator.insulation = TUNING.INSULATION_MED --120


        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel((TUNING.WINTERHAT_PERISHTIME/10)*3)
        inst.components.fueled:SetDepletedFn(inst.Remove)
	

	
    inst.components.equippable:SetOnEquip( santa_hat_onequip )
    inst.components.equippable:SetOnUnequip( santa_hat_onunequip )
    
    return inst
end
 
return Prefab( "common/inventory/santa_hat", fn or simple, assets, prefabs)