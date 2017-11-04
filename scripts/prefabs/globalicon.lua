local assets = {
	Asset( "ATLAS", "minimap/globalicon.xml" ),	
}

local function fn()
    local inst = CreateEntity()
	
	inst.entity:SetCanSleep(false)
    inst.persists = false
	
	inst:AddTag("FX")

	inst.entity:AddTransform()
	inst.entity:AddMiniMapEntity()
	
	inst.MiniMapEntity:SetIcon("globalicon.tex")
	inst.MiniMapEntity:SetPriority(10)
	inst.MiniMapEntity:SetCanUseCache(false)
	inst.MiniMapEntity:SetDrawOverFogOfWar(true)
	
	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
	
    return inst
end

return Prefab("common/objects/globalicon", fn, assets)
