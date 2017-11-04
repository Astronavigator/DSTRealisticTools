local assets =
{
    Asset("ANIM", "anim/nightmare_timepiece.zip"),
}



local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("nightmare_watch")
    inst.AnimState:SetBuild("nightmare_timepiece")
    inst.AnimState:PlayAnimation("idle_1")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    --inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("inventoryitem")

    --MakeHauntableLaunch(inst)

    --[[if GetNightmareClock() then
        inst:ListenForEvent("phasechange", function(world, data) phasechange(inst, data) end, TheWorld)
        phasechange(inst, {newphase = GetNightmareClock():GetPhase()})
    end]]

    --inst.OnSave = onsave
    --inst.OnLoad = onload

    return inst
end

return Prefab("common/inventory/nightmare_timepiece", fn, assets)