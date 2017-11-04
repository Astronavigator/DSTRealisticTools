local assets=
{
	Asset("ANIM", "anim/armor_meat.zip"),
    Asset("ATLAS", "images/inventoryimages/armor_meat.xml"),
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour") 
end


local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_meat", "swap_body")
	--[[local old_max_health = owner.components.health.maxhealth 
	local old_current_health = owner.components.health.currenthealth 
	owner.components.health:SetMaxHealth(owner.components.health.maxhealth + 150)
	owner.components.health:DoDelta(0, true)
	owner.components.health:SetCurrentHealth(old_current_health * owner.components.health.maxhealth / old_max_health)
	owner.components.health:DoDelta(0, true)--]]
    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
	--[[local old_max_health = owner.components.health.maxhealth 
	local old_current_health = owner.components.health.currenthealth 
	owner.components.health:SetMaxHealth(owner.components.health.maxhealth - 150)	
	owner.components.health:DoDelta(0, true)
	owner.components.health:SetCurrentHealth(old_current_health * owner.components.health.maxhealth / old_max_health)
	owner.components.health:DoDelta(0, true)--]]
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
    inst.AnimState:SetBuild("armor_meat")
    inst.AnimState:PlayAnimation("anim")
    
	inst:AddTag("humanmeat")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/armor_meat.xml"
	inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/metalarmour"

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(700, 0.30)
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable.walkspeedmult = 0.95
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
	
    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.MEAT
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 75
    inst.components.edible.sanityvalue = -TUNING.SANITY_MED	
	
    inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"	

    inst.components.equippable.equippedmoisture = 0.5
    inst.components.equippable.maxequippedmoisture = 32 -- Meter reading rounds up, so set 1 below

	
    return inst
end

return Prefab( "common/inventory/armor_meat", fn, assets) 
