local assets =
{
	Asset("ANIM", "anim/endothermic_torch.zip"),
	Asset("ANIM", "anim/swap_endothermic_torch.zip"),
	Asset("SOUND", "sound/common.fsb"),
}
 
local prefabs =
{
	"endothermic_torchfire",
}	 


local function onequipfueldelta(inst)
    if inst.components.fueled.currentfuel < inst.components.fueled.maxfuel then
        inst.components.fueled:DoDelta(-inst.components.fueled.maxfuel*.01)
    end
end


local function UpdateTemperature(inst)
	if inst and inst:IsValid() and inst.Transform and inst.components.equippable:IsEquipped() then
		--local x,y,z = inst.Transform:GetWorldPosition()
		for _,v in ipairs(AllPlayers) do
			if inst:GetDistanceSqToInst(v) < 2 then
				if v.components.temperature and v.components.temperature.current > 66 then
					local new_temp = v.components.temperature.current - 1.5
					if new_temp<=70 and new_temp>=69 then
						new_temp = 68.5
					end
					v.components.temperature:SetTemperature(new_temp < 66 and 66 or new_temp)
				end
			end
		end
	end
end


local function onequip(inst, owner) 

	--owner.components.combat.damage = TUNING.PICK_DAMAGE 
	inst.components.burnable:Ignite()
	owner.AnimState:OverrideSymbol("swap_object", "swap_endothermic_torch", "swap_torch")
	owner.AnimState:Show("ARM_carry") 
	owner.AnimState:Hide("ARM_normal") 
	
	inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "torch")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")
	inst.SoundEmitter:SetParameter( "endothermic_torch", "intensity", 1 )

	inst.fire = SpawnPrefab( "endothermic_torchfire" )
	local follower = inst.fire.entity:AddFollower()
	follower:FollowSymbol( owner.GUID, "swap_object", 0, -110, 1 )
	--inst.fire.persists = false	
	--take a percent of fuel next frame instead of this one, so we can remove the torch properly if it runs out at that point
	inst:DoTaskInTime(0, onequipfueldelta)
	if not inst.task then
		inst.task = inst:DoPeriodicTask(1+math.random()*0.1,UpdateTemperature)
	end
end



local function onunequip(inst,owner) 
	if inst.task then
		inst.task:Cancel()
		inst.task = nil
	end


    if inst.fire ~= nil then
        inst.fire:Remove()
        inst.fire = nil
    end
	
	inst.components.burnable:Extinguish()
	owner.components.combat.damage = owner.components.combat.defaultdamage 
	owner.AnimState:Hide("ARM_carry") 
	owner.AnimState:Show("ARM_normal")
	inst.SoundEmitter:KillSound("torch")
	inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")		
end



local function onattack(inst, owner, target)
    if not target:HasTag("wall") then
        --owner.components.sanity:DoDelta(1)
		--target = owner
		if target and target.components.temperature then
			local temp = target.components.temperature:GetCurrent()
			if temp<-18 then
				temp = -20
			else
				temp = temp-2
			end
			target.components.temperature:SetTemp(temp)
			target.components.temperature:SetTemp()
			if target.components.moisture then --RoG
				target.components.moisture:DoDelta(3)
			end
		end
		if owner.components.moisture then --RoG
			owner.components.moisture:DoDelta(2)
		elseif owner.components.temperature then
			local temp = owner.components.temperature:GetCurrent()
			if temp<-10 then
				temp = -20
			else
				temp = temp-4
			end
			owner.components.temperature:SetTemp(temp)
			owner.components.temperature:SetTemp()
		end
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	
	anim:SetBank("torch")
	anim:SetBuild("endothermic_torch")
	anim:PlayAnimation("idle")
	MakeInventoryPhysics(inst)
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("endothermic_torch.tex")
	
	inst.entity:SetPristine()	

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.TORCH_DAMAGE)
	inst.components.weapon.onattack=onattack
	--[[	function(attacker, target)
			if target.components.burnable then
				if math.random() < TUNING.TORCH_ATTACK_IGNITE_PERCENT*target.components.burnable.flammability then
					target.components.burnable:Ignite()
				end
			end
		end
	)--]]
	
	
	-----------------------------------
	--inst:AddComponent("lighter")
	-----------------------------------
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/endothermic_torch.xml"
	-----------------------------------
	
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnPocket( function(owner) inst.components.burnable:Extinguish()  end)
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	
    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    inst:AddComponent("insulator")
    inst.components.insulator:SetSummer()
	inst.components.insulator:SetInsulation(120)
	
	-----------------------------------
	
	inst:AddComponent("inspectable")
 
	-----------------------------------
	
	inst:AddComponent("burnable")
	inst.components.burnable.canlight = false
	inst.components.burnable.fxprefab = nil
	--inst.components.burnable:AddFXOffset(Vector3(0,1.5,-.01))
	
	--Can be used as a log in firepit.
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL	
	
	-----------------------------------
	
	inst:AddComponent("fueled")
	

	inst.components.fueled:SetUpdateFn( function()
		if TheWorld and TheWorld.state.israining then
			inst.components.fueled.rate = 1 + TUNING.TORCH_RAIN_RATE * TheWorld.state.precipitationrate
		else
			inst.components.fueled.rate = 1
		end
	end)


    inst.components.fueled:SetSectionCallback(
        function(section)
            if section == 0 then
                --when we burn out
                if inst.components.burnable ~= nil then
                    inst.components.burnable:Extinguish()
                end
                local equippable = inst.components.equippable
                if equippable ~= nil and equippable:IsEquipped() then
                    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
                    if owner ~= nil then
                        local data =
                        {
                            prefab = inst.prefab,
                            equipslot = equippable.equipslot,
                        }
                        inst:Remove()
                        owner:PushEvent("torchranout", data)
                        return
                    end
                end
                inst:Remove()
            end
        end)
	inst.components.fueled:InitializeFuelLevel(TUNING.COLDTORCH_FUEL)
	inst.components.fueled:SetDepletedFn(function(inst) inst:Remove() end)

    --inst:WatchWorldState("israining", onisraining)
    --onisraining(inst, TheWorld.state.israining)

    --MakeHauntableLaunch(inst)	

	return inst
end

return Prefab( "common/inventory/endothermic_torch", fn, assets, prefabs) 
