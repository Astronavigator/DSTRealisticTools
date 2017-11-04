local assets=
{
    Asset("ANIM", "anim/large_bone.zip"),
    Asset("ANIM", "anim/swap_large_bone.zip"),
 
    Asset("ATLAS", "images/inventoryimages/large_bone.xml"),
    Asset("IMAGE", "images/inventoryimages/large_bone.tex"),
}

local prefabs = 
{
	"boneshard",
}

local function fn(colour)
 
    local function OnEquip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_large_bone", "large_bone")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end
	
	local function onfinished(inst)		
		local bs = SpawnPrefab("boneshard")
		if bs and bs:IsValid() then
			bs.Transform:SetPosition(inst.Transform:GetWorldPosition())
			bs.components.stackable.stacksize = 2
		end
		inst:Remove()
	end
    
	local function OnUnequip(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
     
    anim:SetBank("large_bone")
    anim:SetBuild("large_bone")
    anim:PlayAnimation("idle")
	
	inst.entity:AddNetwork()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.entity:SetPristine()
	
	inst:AddTag("sharp")
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(12)
	
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(50)
    inst.components.finiteuses:SetUses(50)
	inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
	--inst:AddComponent("stackable")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "large_bone"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/large_bone.xml"
     
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
 
 	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
	MakeSmallPropagator(inst)
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.MED_FUEL
	
    return inst
end
return  Prefab("common/inventory/large_bone", fn, assets, prefabs)