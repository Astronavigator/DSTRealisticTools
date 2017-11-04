local assets=
{
	Asset("ANIM", "anim/sup_range.zip")    
}


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    --trans:SetScale(1.55,1.55,1.55)
	inst.sc = function(n) trans:SetScale(n,n,n) end
	--inst.entity:AddNetwork()
	
    anim:SetBank("firefighter_placement")
    anim:SetBuild("sup_range")
    anim:PlayAnimation("idle")
	
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
    anim:SetLayer( LAYER_BACKGROUND )
    anim:SetSortOrder( 3 )
	
	inst.persists = false
    inst:AddTag("fx")
	inst:AddTag("sup_range")
	inst:AddTag("notarget")
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("DECOR")

    --inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end

	--inst:DoTaskInTime(TUNING.RANGE_CHECK_TIME, function() inst:Remove() end)
	
    return inst
end

return Prefab( "common/sup_range", fn, assets) 