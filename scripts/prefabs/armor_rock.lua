local assets=
{
	Asset("ANIM", "anim/armor_rock.zip"),
    Asset("ATLAS", "images/inventoryimages/armor_rock.xml"),
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour") 
end


local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_rock", "swap_body")
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
    inst.AnimState:SetBuild("armor_rock")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/armor_rock.xml"
	inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/metalarmour"

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(900, 0.8)
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable.walkspeedmult = 0.93
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    return inst
end

return Prefab( "common/inventory/armor_rock", fn, assets) 
