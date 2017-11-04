local assets =
{
    Asset("ANIM", "anim/clanicon.zip"),
}

local function SetIcon(inst,num)
	--[[local anim = (num and num>0) and ("clan"..num) or (num==0 and "noclan" or nil)
	if anim then
		if not(inst.clanicon and inst.clanicon:IsValid()) then
			local icon = _G.SpawnPrefab("clanicon")
			if (inst.clanicon and inst.clanicon:IsValid()) then
				inst.clanicon.
			else
				inst.clanicon = nil
			end
		end
		if (inst.clanicon and inst.clanicon:IsValid()) then
			
		end
	else
	end

	if num and num > 0 then
		inst.AnimState:PlayAnimation("clan"..num)
	elseif num == 0 then
		inst.AnimState:PlayAnimation("noclan")
	else
	end--]]
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --inst.entity:AddSoundEmitter()
    --inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    --MakeObstaclePhysics(inst, .2)

    --inst.MiniMapEntity:SetIcon("sign.png")

    inst.AnimState:SetBank("clanicon")
    inst.AnimState:SetBuild("clanicon")
    inst.AnimState:PlayAnimation("noclan")
	
	--arr(inst.AnimState,2)

    --MakeSnowCoveredPristine(inst)

    --Sneak these into pristine state for optimization
    inst:AddTag("clanicon")

	inst:AddTag("_named")
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
	inst:RemoveTag("_named")
	
	inst.AnimState:SetLayer(LAYER_WORLD_CEILING)
	
	--inst.SetIcon = SetIcon
	
	inst:AddComponent("named")

    --Remove these tags so that they can be added properly when replicating components below
    --inst:RemoveTag("_writeable")

    return inst
end

return Prefab("common/objects/clanicon", fn, assets)
