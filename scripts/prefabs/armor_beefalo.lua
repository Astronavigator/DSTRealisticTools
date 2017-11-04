local assets=
{
	Asset("ANIM", "anim/armor_beefalo.zip"),
    Asset("ATLAS", "images/inventoryimages/armor_beefalo.xml"),
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour") 
end


local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_beefalo", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.entity:AddNetwork()
    
    if not TheWorld.ismastersim then
        return inst
    end
    inst.entity:SetPristine()
    MakeHauntableLaunch(inst)
    
    inst.AnimState:SetBank("armor_grass")
    inst.AnimState:SetBuild("armor_beefalo")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/armor_beefalo.xml"
	inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/grassarmour"

    inst:AddComponent("insulator")
    inst.components.insulator.insulation = 120 --240

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(400, 0.5)
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
	MakeSmallPropagator(inst)
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
    return inst
end

return Prefab( "common/inventory/armor_beefalo", fn, assets) 
