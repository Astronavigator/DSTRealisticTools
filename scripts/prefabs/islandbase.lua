local assets =
{
	Asset("ANIM", "anim/staff_purple_base_ground.zip"),
}

local prefabs =
{
	--"gemsocket",
	"collapse_small",
}

--d("cactus")
--d("tumbleweedspawner")
--mp("desertpalm")
--x=d("islandbase") x:AddIsland()
local function AddIsland(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	if TheWorld.clansystem then
		local islands = TheWorld.clansystem.islands
		table.insert(islands,{x,y,z})
	end
	inst:AddTag("islandbase")
end

--x=d("islandbase") x:AddSavePoint()
--А эта функция добавляет точку на материк, куда можно спасаться из безвыходного положения с острова (при закрытом портале)
local function AddSavePoint(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	if TheWorld.clansystem then
		local save_points = TheWorld.clansystem.save_points
		table.insert(save_points,{x,y,z})
	end
	inst:AddTag("save_point")
end

local function OnSave(inst,data)
	data.phases = inst.phases
end
local function OnLoad(inst,data)
	if data then
		inst.phases = data.phases or 4
	end
end

local function commonfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	--inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    if not TheWorld.ismastersim then
        return inst
    end

	--inst.MiniMapEntity:SetIcon("telebase.png")

	
    
	inst.AddIsland = AddIsland
	inst.AddSavePoint = AddSavePoint
	inst:AddTag("notarget")
	inst.phases = 4 --Сколько границ фаз нужно пройти, чтобы портал исчез.
	
	inst:DoTaskInTime(0,function(inst) --OnLoad сработает не сразу, а после создания префаба. А мы еще на этапе создания.
		local sys = TheWorld.clansystem
		if sys then
			if sys:CheckIsland(inst) then
				inst:AddTag("islandbase") --Если есть в базе, то добавить тег.
			end
		end
	end)

    inst.AnimState:SetBuild("staff_purple_base_ground")
    inst.AnimState:SetBank("staff_purple_base_ground")
    inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	inst.Transform:SetRotation(45)

	--inst.onteleto = teleport_target
	--inst.canteleto = validteleporttarget

	--inst:AddComponent("inspectable")
	--inst.components.inspectable.getstatus = getstatus

	--inst:AddComponent("workable")
	--inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	--inst.components.workable:SetWorkLeft(4)
	--inst.components.workable:SetOnWorkCallback(onhit)
	--inst.components.workable:SetOnFinishCallback(ondestroyed)

	--MakeHauntableWork(inst)

	--inst:AddComponent("lootdropper")

    --inst:AddComponent("objectspawner")
    --inst.components.objectspawner.onnewobjectfn = NewObject

    --inst:ListenForEvent("onbuilt", OnBuilt)

	--inst:ListenForEvent("onremove", removesockets)
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	return inst
end

return Prefab("common/inventory/islandbase", commonfn, assets, prefabs)
	   --MakePlacer("common/telebase_placer", "staff_purple_base_ground", "staff_purple_base_ground", "idle")
