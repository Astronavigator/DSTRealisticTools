local assets =
{
	Asset("ANIM", "anim/blood.zip"),
}



local blood_anim = {"blood1","blood2","blood3","blood4"}
local greenblood_anim = {"greenblood1","greenblood2","greenblood3","greenblood4"}

local function MakeBlood(inst,num,green)
	if green then
		inst.AnimState:PlayAnimation(greenblood_anim[num])
		inst.Light:SetColour(0 / 255, 255 / 255, 0 / 255)
		inst.Light:SetIntensity(.75)
		inst.Light:SetColour(0.3,1,0.3)
		inst.Light:SetFalloff(0.85)
		inst.Light:SetRadius(0.35)
		if TheWorld.state.isnight and not TheWorld.state.isfullmoon then
			inst:DoTaskInTime(1.5,function(inst) --включаем свет не сразу, чтобы чужой мог отбежать и не сбивать ночное зрение.
				if inst:IsValid() then
					inst.Light:Enable(true)
				end
			end)
		else
			inst.Light:Enable(true)
		end
	else
		inst.AnimState:PlayAnimation(blood_anim[num])
	end
	inst.blood_num = num
	inst.green = green
end

--[[local function OnSave(inst,data)
	data.green = inst.green
	data.blood_num = inst.blood_num
end
local function OnLoad(inst,data)
	if data then
		inst.green = data.green
		inst.blood_num = data.blood_num
		MakeBlood(inst,inst.blood_num,inst.green)
	end
end--]]

local function OnUpdateBlood(inst, phase)
	--print("blood onphase")
	inst.phases = inst.phases + 1
	local must_remove
	if inst.phases > 3 then
		local w = TheWorld.state
		if inst.green then 
			if w.isday then
				must_remove = true
			end
		elseif w.isnight and not w.isfullmoon then
			must_remove = true
		end
	end
	if must_remove then
		local player, dist_sq = inst:GetNearestPlayer(false) --включая трупы, которые не успели исчезнуть
		if not(player and dist_sq <30*30) then
			inst:Remove()
		end
	end
end

--зеленая вторая
--x=d("blood") x:MakeBlood(2,true)

local function commonfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	--inst.entity:AddSoundEmitter()
	--inst.entity:AddMiniMapEntity()
	local light = inst.entity:AddLight()
	inst.Light:Enable(false) --по умолчанию выкл

	inst.entity:AddNetwork()

	--MakeInventoryPhysics(inst)
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddTag("notarget")
	inst:AddTag("FX")
	inst.persists = false
	
	inst.MakeBlood = MakeBlood

	inst.AnimState:SetBuild("blood")
	inst.AnimState:SetBank("blood")
	inst.AnimState:PlayAnimation("blood2") --первую никогда не используем. Она слишком незаметна.
	inst.green = false
	inst.blood_num = 2
	inst.phases = 0 --Сколько фаз прошло. Должно быть примерно 4
	--inst:MakeBlood(3,true)
	--inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	--inst.Transform:SetRotation(45)


	--inst.OnSave = OnSave
	--inst.OnLoad = OnLoad
	
	inst:WatchWorldState("phase",OnUpdateBlood)

	return inst
end

return Prefab("common/inventory/blood", commonfn, assets)
	   --MakePlacer("common/telebase_placer", "staff_purple_base_ground", "staff_purple_base_ground", "idle")
