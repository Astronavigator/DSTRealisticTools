local assets =
{
	Asset("ANIM", "anim/matches.zip"),
	Asset("ATLAS", "images/inventoryimages/matches.xml"),
	--Asset("ATLAS", "images/inventoryimages/damp_matches.xml"),
	--Asset("IMAGE", "images/inventoryimages/godstaff.tex"),
	
	Asset("ANIM", "anim/campfire.zip"),
}
local prefabs =
{
	"willowfire",
}

--[[
local function OnPutInInventory(inst,owner)
end
--]]


local function make_damp(inst)
	if not inst.damp then --переход в это состо€ние происходит лишь однажды
		inst.AnimState:PlayAnimation("damp")
		--inst.components.inventoryitem.atlasname = "images/inventoryimages/damp_matches.xml"
		inst.components.inventoryitem:ChangeImageName("damp_matches")
		--[[if inst.damp_task then --мониторинг не останавливаетс€! (мониторинг жары также важен)
			inst.damp_task:Cancel()
			inst.damp_task = nil
		end--]]
		inst:RemoveComponent("lighter")
		--inst:RemoveComponent("deployable")
		inst.damp = true
	end
end


local function OnSave(inst,data)
	data.damp = inst.damp
end
local function OnLoad(inst,data)
	if data and data.damp then
		make_damp(inst)
	end
end



local function ondeploy(inst, pt, deployer)
    --inst = inst.components.stackable:Get()
	local fire = SpawnPrefab("willowfire")
	if fire then
		fire.Physics:Teleport(pt:Get())
	end
	if deployer and deployer.components.inventory then
		deployer.components.inventory:GiveItem(inst)
	end
end



local function MonitorDamp(inst)
	if not inst:IsValid() then
		--print("STOP MONITORING MATCHES")
		inst.damp_task:Cancel()
		return
	end
	--мониторим влажность
	local is_wet = inst.components.inventoryitem:IsWet()
	if is_wet then
		if not inst.damp then
			if inst.pre_damp then
				--print("DAMP!!!!")
				--отсыревшие спички
				make_damp(inst)
			else
				--print("PRE_DAMP")
				inst.pre_damp = true
			end
		end
	else
		inst.pre_damp = false
	end
	--мониторим высокую температуру в мире. «агораютс€ на 90 градусах, если не в инвентаре
	local owner = inst.components.inventoryitem:GetGrandOwner()
	local burnable=inst.components.burnable
	if owner and owner:HasTag("player") then
		--nothing
	elseif (not is_wet) and TheWorld.state.temperature>85 and burnable and (not burnable:IsBurning()) and not(burnable:IsSmoldering())
		and math.random()<0.125 --в среднем раз в 3 игровых часа (90 секунд)
	then
		if owner then
			if owner:HasTag("fridge") then
				--если холодильник, то закругл€емс€
				return
			end
			local c = inst.components.inventoryitem.owner.components
			if c.container then
				c.container:DropItem(inst)
			elseif c.inventory then
				c.inventory:DropItem(inst)
			end
		end
		burnable:StartWildfire()
	end

end


local function OnDampDirty(inst)
    inst.damp = inst.net_damp:value()
end

--------PREFAB FUNCTION ------------

local function fn(color)

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	--inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("matches")
	inst.AnimState:SetBuild("matches")
	inst.damp = false
	inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("icebox_valid")

	--inst:AddTag("nopunch")
	
	inst.displaynamefn = function()
		if inst.damp then
			return "Damp Matches"
		else
			return "Matches"
		end
	end

	inst.entity:SetPristine()
	
	inst.net_damp = net_bool(inst.GUID, "damp", "damp_dirty" )
	
	if not TheWorld.ismastersim then
		inst:ListenForEvent("damp_dirty", OnDampDirty)
		return inst
	end

	inst:AddComponent("inspectable")
	inst.components.inspectable.getspecialdescription = function(inst,viewer)
		if not inst.damp then
			return "Nice gift for winter."
		else
			return "Now it's useless junk."
		end
	end

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/matches.xml"
	--inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	
    --[[ Ќельз€ поджигать землю. ’ватит уже баловатьс€ со спичками.
	inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
    inst.components.deployable.ondeploy = ondeploy
	--]]
	
	inst:AddComponent("lighter")
	
	
	inst.pre_damp = false
	inst.damp_task = inst:DoPeriodicTask(10+math.random(),MonitorDamp)
	
	MakeSmallBurnable(inst, TUNING.LONG_BURNABLE)
	MakeSmallPropagator(inst)
	inst.components.burnable:SetOnIgniteFn(make_damp) --да, делаем такими серыми и невзрачными, как при намокании.

	
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.MED_FUEL
	
	return inst
end


STRINGS.NAMES.MATCHES = "Matches"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MATCHES = "Nice gift for winter."
--без рецепта! ѕросто выдаетс€ в стартовом комплекте зимой!!


return Prefab("common/inventory/matches", fn, assets, prefabs)
	--MakePlacer("common/matches_placer", "campfire", "campfire", "preview")
