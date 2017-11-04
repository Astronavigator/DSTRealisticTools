local assets =
{
    Asset("ANIM", "anim/clan_keys.zip"),
	
    Asset("ATLAS", "images/inventoryimages/yellowkey.xml"),
    Asset("ATLAS", "images/inventoryimages/greenkey.xml"),
    Asset("ATLAS", "images/inventoryimages/bluekey.xml"),
    Asset("ATLAS", "images/inventoryimages/redkey.xml"),
    --Asset("IMAGE", "images/inventoryimages/godstaff.tex"),


}

local function OnPutInInventory(inst,owner)
	if not inst.userid then
		local master = inst.components.inventoryitem:GetGrandOwner()
		if master and master:HasTag("player") and master.userid and master.name then
			inst.userid = master.userid
			inst.owner = master.name
		end
	end
end

local function OnSave(inst,data)
	data.userid = inst.userid
	data.owner = inst.owner
end
local function OnLoad(inst,data)
	if data then
		inst.userid = data.userid
		inst.owner = data.owner
	end
end



--------PREFAB FUNCTION ------------

local function common_fn(color)

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("clan_keys")
    inst.AnimState:SetBuild("clan_keys")
    inst.AnimState:PlayAnimation(color.."key")

	--inst:AddTag("nopunch")

    inst.entity:SetPristine()
    

    if not TheWorld.ismastersim then
        return inst
    end
	

	inst:AddComponent("inspectable")

	inst.userid = nil
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/"..color.."key.xml"
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	
	inst:AddTag("chest_key")
	
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY

	
    
    return inst
end

local function yellow_fn()
	return common_fn("yellow")
end
local function green_fn()
	return common_fn("green")
end
local function red_fn()
	return common_fn("red")
end
local function blue_fn()
	return common_fn("blue")
end

STRINGS.NAMES.YELLOWKEY = "Golden Key"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.YELLOWKEY = "Key from a chest"
STRINGS.NAMES.REDKEY = "Red Key"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.REDKEY = "Key from a chest"
STRINGS.NAMES.BLUEKEY = "Blue Key"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BLUEKEY = "Key from a chest"
STRINGS.NAMES.GREENKEY = "Green Key"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GREENKEY = "Key from a chest"


return Prefab("common/inventory/yellowkey", yellow_fn, assets),
	Prefab("common/inventory/greenkey", green_fn, assets),
	Prefab("common/inventory/redkey", red_fn, assets),
	Prefab("common/inventory/bluekey", blue_fn, assets)