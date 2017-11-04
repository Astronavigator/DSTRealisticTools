local assets =
{
    Asset("ANIM", "anim/hawk.zip"),
}

local function SetColor(inst,r,g,b,a)
	inst.AnimState:SetMultColour(r,g or r,b or r,a or 1) --RGBA
end

local function UpdateColor(inst)
	local owner = inst.parent
	if not owner then
		return
	end
	if not owner.is_pvpmode then --не пвп режим вообще
		inst:Hide()
	else
		inst:Show()
		if owner.is_pvp_peace then
			inst.AnimState:PlayAnimation("white",true) --Если в пис зоне и все остальные "гости" не круче, чем на 1 день.
		elseif owner.is_pvpmode2 then --первые 50 сек
			--SetColor(inst,1,0,0)
			inst.AnimState:PlayAnimation("red",true)
		else --последние 10 сек
			--SetColor(inst,0.3,0.4,0.7,0.4)
			inst.AnimState:PlayAnimation("yellow",true)
		end
	end	
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --inst.entity:AddNetwork()

    --MakeObstaclePhysics(inst, .2)

    inst.AnimState:SetBank("hawk")
    inst.AnimState:SetBuild("hawk")
    inst.AnimState:PlayAnimation("red",true)
	
	inst.AnimState:SetLayer(LAYER_WORLD_CEILING)


    --[[inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end--]]
	
	inst.SetColor = SetColor
	inst.UpdateColor = UpdateColor
	

    return inst
end

return Prefab("common/objects/hawk", fn, assets)
