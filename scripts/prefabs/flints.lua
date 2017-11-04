local assets =
{
	Asset("ANIM", "anim/flints.zip"),
	Asset("ATLAS", "images/images1.xml"),
	
	Asset("ANIM", "anim/anim-ftools.zip"),
	Asset("ANIM", "anim/ftools.zip"), --swap
	--Asset("ANIM", "anim/golds.zip"),
}


local f_anim = {"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15","f16","f17","f18","f19",}

local function commonfn(num)

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	--inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("flints")
	inst.AnimState:SetBuild("flints")
	inst.AnimState:PlayAnimation(f_anim[num])
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = f_anim[num]
	inst.components.inventoryitem.atlasname = "images/images1.xml"
	
	
	--inst.OnSave = OnSave
	--inst.OnLoad = OnLoad
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM --TUNING.STACK_SIZE_MICRO --3
	
	return inst
end

local nm = STRINGS.NAMES
local rec = STRINGS.RECIPE_DESC
local desc = STRINGS.CHARACTERS.GENERIC.DESCRIBE

nm.F1 = 'Blank Flint'
rec.F1 = 'It needs further processing'
desc.F1 = "It's... I'm not sure what is it yet."

nm.F2 = 'Stone Ingot'
desc.F2 = "It's... I'm not sure what is it yet."

nm.F3 = 'Useful Flint'
rec.F3 = 'Good for making a tool'
desc.F3 = "Finally! I can make a tool."

nm.F4 = 'Unlucky Try'
desc.F4 = "Oops :("

nm.F5 = 'Spike'
rec.F5 = "Good for making a spear"
desc.F5 = "Good for making a spear"

nm.F6 = 'Shell'
desc.F6 = 'I hope I will be able to use it somehow'

nm.F7 = 'Askew Spike'
desc.F7 = 'Ah, not again'

nm.F8 = "Bad Spike"
desc.F8 = "Oooh, now it useless! :("

nm.F9 = "Fragment"
desc.F9 = 'Just a trash'

nm.F10 = "Good Spike"
rec.F10 = 'Good idea. How about some luck?'
desc.F10 = "Very good spike. Now I'm a warrior"

nm.F11 = 'Edge'
rec.F11 = 'Hm... I want it for better axe'
desc.F11 = 'Nice! I can make an axe.'

nm.F12 = 'Paddle'
desc.F12 = 'Oh no.... wait, I can make a shovel.'

nm.F13 = 'Half Spike'
rec.F13 = 'Better than nothing'
desc.F13 = 'Well... it almost useless.'

nm.F14 = 'Great Spike'
rec.F14 = "Please.. God.. let me get it"
desc.F14 = 'Yes!!! Yes!! Finally, I will be super hero!'

nm.F15 = 'Cracked Edge'
desc.F15 = 'Today is not my day.'

nm.F16 = 'Sharp Edge'
rec.F16 = 'I already feel more damage'
desc.F16 = "I can't belive! I made it!"

nm.F17 = 'Excellent Rdge'
rec.F17 = 'Chance of one in a million'
desc.F17 = 'Oh, now I feel real power.'

nm.F18 = 'Askew Edge'
desc.F18 = 'Blunder on 1 millimeter'

nm.F19 = 'Fragments'
rec.F19 = 'I can only to break completely'
desc.F19 = 'Totally useless'

---- Useful Flint
nm.F30 = nm.F3
rec.F30 = rec.F3

---- Hald Edge
nm.F40 = nm.F13
rec.F40 = rec.F13

----Fragments
nm.F50 = nm.F19
rec.F50 = rec.F19
nm.F51 = nm.F19
rec.F51 = rec.F19
nm.F52 = nm.F19
rec.F52 = rec.F19

local mk = _G.rawget(_G,"RegisterRussianName")
if mk then
	mk('F1','Кремень-заготовка',3)
	rec.F1 = 'Это нуждается в дальнейшей обработке'
	mk('F2','Кремень-болванка',3)
	--rec.f2 = '
	mk('F3','Колкий кремень',3,"Колкому кремню")
	rec.F3 = 'Из этого я уже смогу сделать инструмент'
	nm.F4 = 'Неудачный кремень'
	mk('F5','Остриё',4,'Острию')
	rec.F5 = 'Прекрасно подойдет для копья'
	mk('F6','Плоский кремень',1,'Плоскому кремню')
	mk('F7','Кривое остриё',4,"Кривому острию")
	mk('F8','Плохое остриё',4,"Плохому острию",1,nil,"Плохим остриём")
	mk('F9','Обломок',1)
	mk('F10','Хорошее остриё',4,"Хорошему острию")
	rec.F11 = 'Хорошая задумка. Но получится ли?'
	mk("F11",'Лезвие',4)
	rec.F11 = 'Годится для топора'
	mk('F12','Лопасть',3)
	mk('F13','Осколок острия',1,1,'Осколку острия')
	rec.F13 = 'Если уж ломать, то до конца'
	mk('F14','Великолепное остриё',4,'Великолепному острию')
	rec.F14 = 'Отлично! Такое копьё пробьёт любую броню'
	mk('F15','Треснувшее лезвие',4)
	mk('F16','Острое лезвие',4)
	rec.F16 = 'Очень редкий кремень для топора'
	mk('F17','Идеальное лезвие',4)
	rec.F17 = 'Такой кремень удаётся отколоть лишь раз в жизни'
	mk('F18','Кривое лезвие',4)
	mk('F19','Осколки',5)
	rec.F19 = 'Остаётся лишь доломать и выкинуть'
	--дубль крафта 1
	--nm.F30='Полезная форма'
	mk('F30','Колкий кремень',3,"Колкому кремню")
	rec.F30 = rec.F3
	--дубль крафта половинки
	nm.F40='Осколок острия'
	rec.F40 = rec.F13
	nm.F53 = nm.F40
	rec.F53 = rec.F13
	--дубли крафта осколков
	nm.F50 = 'Осколки'
	nm.F51 = nm.F50
	nm.F52 = nm.F50
	rec.F50 = rec.F19
	rec.F51 = rec.F19
	rec.F52 = rec.F19
end

--[[for i=1,19 do
	nm["F"..i] = "Flint "..i
	rec["F"..i] = "Rec flint "..i
	desc["F"..i] = "Desc "..i
end--]]

local function fn19()
	local inst = commonfn(19)
	
	if not TheWorld.ismastersim then
		return inst
	end

	--inst:AddComponent("stackable")
	--inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM --TUNING.STACK_SIZE_HUGE --80
	
	return inst
end


-----Инструменты и оружие

local anim_tools = { --таблица со всякими рутинными параметрами, о которых не надо вспоминать.
	axe1={
		swap_anim="axe1", --если не указано inventoryimage, то работает также и названием иконки
		maxanim=2,
		anims={"axe-1-1","axe-1-2"},
		action = ACTIONS.CHOP,
	},
	axe2={
		swap_anim="axe2",
		maxanim=4,
		anims={"axe-2-1","axe-2-2","axe-2-3","axe-2-3"},
		action = ACTIONS.CHOP,
	},
	axe3={
		swap_anim="axe3",
		maxanim=3,
		anims={"axe-3-1","axe-3-2","axe-3-3"},
		action = ACTIONS.CHOP,
	},
	axe4={
		swap_anim="axe4",
		maxanim=2,
		anims={"axe-4-1","axe-4-2"},
		action = ACTIONS.CHOP,
	},
	axe5={
		swap_anim="axe5",
		maxanim=2,
		anims={"axe-5-1","axe-5-2",},
		action = ACTIONS.CHOP,
	},
	spear1={
		swap_anim="spear1",
		maxanim=3,
		anims={"spear-1-1","spear-1-2","spear-1-3"},
		standard_inventoryimage = true,
		inventoryimage = "spear",
	},
	spear2={
		swap_anim="spear2",
		maxanim=2,
		anims={"spear-2-1","spear-2-2"},
	},
	spear3={
		swap_anim="spear3",
		maxanim=2,
		anims={"spear-3-1","spear-3-2"},
	},
	spear4={
		swap_anim="spear4",
		maxanim=1,
		anims={"spear-4-1"},
	},
	shovel1={
		swap_anim="swap_shovel",
		swap_animfile="swap_shovel",
		--bankbuild = "shovel",
		inventoryimage="shovel2",
		maxanim=1,
		anims={"shovel-1"},
		action = ACTIONS.DIG,
	},
	shovel2={
		swap_anim="swap_shovel",
		swap_animfile="swap_shovel",
		--bankbuild = "shovel",
		inventoryimage="shovel3",
		maxanim=1,
		anims={"shovel-2"},
		action = ACTIONS.DIG,
	},
	pickaxe1={
		swap_anim = "swap_pickaxe",
		swap_animfile = "swap_pickaxe",
		bankbuild = "pickaxe",
		maxanim=1,
		anims={"idle"},
		action = ACTIONS.MINE,
		inventoryimage="pickaxe",
		standard_inventoryimage = true,
	}
}

local function onequip(inst, owner)
	--print("swap1 = "..tostring(inst.swap_animfile or "ftools"))
	--print("swap2 = "..tostring(inst.swap_anim))
	owner.AnimState:OverrideSymbol("swap_object", inst.swap_animfile or "ftools", inst.swap_anim) --animfile, foldername
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function toolOnSave(inst,data)
	data.play_anim = inst.play_anim
end
local function toolOnLoad(inst,data)
	if data and data.play_anim and data.play_anim ~= inst.play_anim then
		inst.play_anim = data.play_anim
		inst.AnimState:PlayAnimation(inst.save_t.anims[inst.play_anim])
	end
end

local function common_tool(t,damage,uses,effectiveness) --effectiveness - сила инструмента (по умолчанию 1)
	local inst = CreateEntity()
	

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.play_anim = math.random(1,t.maxanim)
	
	inst.AnimState:SetBank(t.bankbuild or "anim-ftools")
	inst.AnimState:SetBuild(t.bankbuild or "anim-ftools")
	--print("play_anim = "..inst.play_anim)
	--print("Anim = "..tostring(t.anims[inst.play_anim]))
	inst.AnimState:PlayAnimation(t.anims[inst.play_anim])

	inst:AddTag("sharp")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	
	inst.swap_anim = t.swap_anim
	inst.swap_animfile = t.swap_animfile

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(damage)

	inst:AddComponent("inventoryitem")
	if not t.standard_inventoryimage then
		inst.components.inventoryitem.atlasname = "images/images1.xml"
	end
	inst.components.inventoryitem.imagename = t.inventoryimage or t.swap_anim
	
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(uses)
	inst.components.finiteuses:SetUses(uses)
	inst.components.finiteuses:SetOnFinished(inst.Remove)
	-----
	if t.action then
		inst:AddComponent("tool")
		inst.components.tool:SetAction(t.action,effectiveness)
		inst.components.finiteuses:SetConsumption(t.action, 1) --если effectiveness, то в самом компоненте подставится 1
	end
	-------
	-------

	inst:AddComponent("inspectable")
	
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	
	inst.OnSave = toolOnSave
	inst.OnLoad = toolOnLoad
	
	inst.save_t = t

	return inst
end

local function axe1() return common_tool(anim_tools.axe1,23,100,0.5) end
local function axe2() return common_tool(anim_tools.axe2,25,150,0.5) end --1 и 2 лвл почти равноценны
local function axe3() return common_tool(anim_tools.axe3,33,150) end
local function axe4() return common_tool(anim_tools.axe4,50,150,1.5) end
local function axe5()
	local inst = common_tool(anim_tools.axe5,76,150,4) --2,3,4
	inst:AddComponent("shaver")
	return inst
end
local function spear1() return common_tool(anim_tools.spear1,25,150) end --==axe1
local function spear2() return common_tool(anim_tools.spear2,33.5,150) end --==axe2 == axe3/2
local function spear3() return common_tool(anim_tools.spear3,35,400) end --в 4 раза круче. == axe4
local function spear4() return common_tool(anim_tools.spear4,69,300) end --==axe5
local function shovel1() return common_tool(anim_tools.shovel1,17,100,0.25) end
local function shovel2() return common_tool(anim_tools.shovel2,24,100,0.5) end
local function pickaxe1() return common_tool(anim_tools.pickaxe1,27,200,0.5) end --сила 0.5

nm.AXE1 = "Blunt Axe"
rec.AXE1 = "Easy craft but not very useful"
desc.AXE1 = "I need it only for cutting trees."

nm.AXE2 = nm.AXE --"Axe"
rec.AXE2 = rec.AXE
desc.AXE2 = desc.AXE

nm.AXE3 = "Good Axe"
rec.AXE3 = "Useful as tool and as weapon"
desc.AXE3 = "Let me chop the trees."

nm.AXE4 = "Sharp Axe"
rec.AXE4 = "Sharp tool from sharp flint"
desc.AXE4 = "Very good if I need to protect myself."

nm.AXE5 = "Legendary Axe"
rec.AXE5 = "Best axe ever. Also can shave"
desc.AXE5 = "Muahahaha"

nm.SPEAR1 = "Newbie Spear"
rec.SPEAR1 = "Slap together"
desc.SPEAR1 = "My first normal weapon."

nm.SPEAR2 = "Spear"
rec.SPEAR2 = "Balance of price and quality"
desc.SPEAR2 = "Now I can hunt."

nm.SPEAR3 = "Durable Spear"
rec.SPEAR3 = "Strong weapon from strong flint"
desc.SPEAR3 = "Now I can hunt very long time."

nm.SPEAR4 = "Great Spear"
rec.SPEAR4 = "Rare weapon"
desc.SPEAR4 = "It's a very good weapon even in PvP."

nm.SHOVEL1 = "Simple Shovel"
rec.SHOVEL1 = "Slap together"
desc.SHOVEL1 = "It's better to make another shovel."

nm.SHOVEL2 = "Shovel"
rec.SHOVEL2 = "For digging"
desc.SHOVEL2 = "Nothing better for digging."

nm.PICKAXE1 = "Pickaxe"
rec.PICKAXE1 = "VERY useful! Must have."
desc.PICKAXE1 = "Flints and stone are waiting for me."

if mk then
	nm.AXE1 = "Тупой топор"
	rec.AXE1 = "На скорую руку"
	nm.AXE2 = "Топор"
	rec.AXE2 = "Это всегда пригодится"
	nm.AXE3 = "Хороший топор"
	rec.AXE3 = "Хорош, как инструмент и как оружие"
	nm.AXE4 = "Острый топор"
	rec.AXE4 = "Из острого кремня - острый топор"
	nm.AXE5 = "Легендарный топор"
	rec.AXE5 = "Всем топорам топор"
	mk("SPEAR1","Копьё новичка",4,"Копью новичка",1)
	rec.SPEAR1 = "На скорую руку"
	mk("SPEAR2","Копьё",4,"Копью",1,nil,"Копьём")
	rec.SPEAR2 = "Баланс качества и цены"
	mk("SPEAR3","Прочное копьё",4,"Прочному копью")
	rec.SPEAR3 = "Из этого кремня получится очень прочная вещь"
	mk("SPEAR4","Великое копьё",4,"Великому копью")
	rec.SPEAR4 = "Совершенство достигается упорством и трудом"
	mk("SHOVEL1","Простая лопата",3)
	rec.SHOVEL1 = "Больше похоже на весло"
	mk("SHOVEL2","Лопата",3)
	rec.SHOVEL2 = "Чтобы копать"
	mk("PICKAXE1","Кирка",3)
	rec.PICKAXE1 = "В хозяйстве вещь совершенно незаменимая"
end

--print("FLINTS INITIALIZATION FINISHED")

return
	Prefab("common/inventory/f1", function() return commonfn(1) end, assets)
	,Prefab("common/inventory/f2", function() return commonfn(2) end, assets)
	,Prefab("common/inventory/f3", function() return commonfn(3) end, assets)
	,Prefab("common/inventory/f4", function() return commonfn(4) end, assets)
	,Prefab("common/inventory/f5", function() return commonfn(5) end, assets)
	,Prefab("common/inventory/f6", function() return commonfn(6) end, assets)
	,Prefab("common/inventory/f7", function() return commonfn(7) end, assets)
	,Prefab("common/inventory/f8", function() return commonfn(8) end, assets)
	,Prefab("common/inventory/f9", function() return commonfn(9) end, assets)
	,Prefab("common/inventory/f10", function() return commonfn(10) end, assets)
	,Prefab("common/inventory/f11", function() return commonfn(11) end, assets)
	,Prefab("common/inventory/f12", function() return commonfn(12) end, assets)
	,Prefab("common/inventory/f13", function() return commonfn(13) end, assets)
	,Prefab("common/inventory/f14", function() return commonfn(14) end, assets)
	,Prefab("common/inventory/f15", function() return commonfn(15) end, assets)
	,Prefab("common/inventory/f16", function() return commonfn(16) end, assets)
	,Prefab("common/inventory/f17", function() return commonfn(17) end, assets)
	,Prefab("common/inventory/f18", function() return commonfn(18) end, assets)
	,Prefab("common/inventory/f19", fn19, assets)
	
	,Prefab("common/inventory/axe1", axe1, assets)
	,Prefab("common/inventory/axe2", axe2, assets)	
	,Prefab("common/inventory/axe3", axe3, assets)	
	,Prefab("common/inventory/axe4", axe4, assets)	
	,Prefab("common/inventory/axe5", axe5, assets)	
	,Prefab("common/inventory/spear1", spear1, assets)	
	,Prefab("common/inventory/spear2", spear2, assets)	
	,Prefab("common/inventory/spear3", spear3, assets)	
	,Prefab("common/inventory/spear4", spear4, assets)	
	,Prefab("common/inventory/shovel1", shovel1, assets)	
	,Prefab("common/inventory/shovel2", shovel2, assets)	
	,Prefab("common/inventory/pickaxe1", pickaxe1, assets)	
	
	
	