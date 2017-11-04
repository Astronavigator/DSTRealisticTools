PrefabFiles = { "flints", "staff0" }
Assets = 
{
	Asset( "IMAGE", "images/images1.tex" ),
	Asset( "ATLAS", "images/images1.xml" ),	
	Asset( "IMAGE", "images/images2.tex" ),
	Asset( "ATLAS", "images/images2.xml" ),	

}


_G=GLOBAL
Recipe=_G.Recipe
RECIPETABS=_G.RECIPETABS
--Ingredient=_G.Ingredient
TECH=_G.TECH
local alpha
local require = GLOBAL.require
local Is_ROG_Enabled = TUNING.LIGHTNING_GOAT_DAMAGE ~= nil
local AllRecipes = _G.AllRecipes
local GetGlobal=function(gname,default)
	local res=_G.rawget(_G,gname)
	if default~=nil and res==nil then
		res = default
		_G.rawset(_G,gname,res)
	end
	return res
end
if not _G.rawget(_G,"mods") then _G.rawset(_G,"mods",{}) end --Для захвата BurnAll
local mods = _G.mods
local Burnie = mods.Burnie and mods.Burnie.tools_loot or {}
local TheNet = _G.TheNet
local CLIENT_SIDE,SERVER_SIDE,DEDICATED_SIDE,ONLY_CLIENT_SIDE



local t = {}
mods.TopMod = t


function AddPlayersPostInit(fn)
	for i,v in ipairs(_G.DST_CHARACTERLIST) do -- DST_CHARACTERLIST + ROG_CHARACTERLIST
		AddPrefabPostInit(v,fn)
	end
	for i,v in ipairs(_G.MODCHARACTERLIST) do
		AddPrefabPostInit(v,fn)
	end
end


--Build system via buff system.
--Крафт при условии наличия или отсутствия тех или иных бафов.
--По аналогии с builder_tag. Функционал должна быть как на клиенте, так и на сервере.
do
	--Список условий для крафта.
	local build_cond = {} --ключ - префаб, строка - имя булевой переменной у игрока

	--Добавляет условие для крафта. cond - это название булевой переменной у инстанса игрока.
	local function AddBuildCondition(prefab,cond)
		build_cond[prefab]=cond
	end
	t.AddBuildCondition = AddBuildCondition --Выносим в глобал для доступа извне.
	t.RemoveRecipe = function(recname)
		table.insert(_G.GAME_MODES.wilderness.invalid_recipes,recname)
	end
	
	--Если необходимо делать открытие/закрытие только на клиенте,
	--то, соответственно, вызываем функцию в расках условия CLIENT_SIDE.
	
	local builder = require "components/builder"
	local old_KnowsRecipe = builder.KnowsRecipe
	function builder:KnowsRecipe(recname,...)
		if build_cond[recname] and not self.inst[build_cond[recname] ] then
			--if table.contains(self.recipes, recname) then --Если рецепт УЖЕ выучен, но нет смысла метаться.
--				return true
			--end
			return false --При наличии условия возвращаем его.
		end
		return old_KnowsRecipe(self,recname,...)
	end
	
	local old_CanBuild = builder.CanBuild
	function builder:CanBuild(recname,...)
		if build_cond[recname] and not self.inst[build_cond[recname] ] then
			return false --При наличии условия возвращаем его.
		end
		return old_CanBuild(self,recname,...)
	end
	
	local old_CanLearn = builder.CanLearn
	function builder:CanLearn(recname,...)
		if build_cond[recname] and not self.inst[build_cond[recname] ] then
			return false --При наличии условия возвращаем его.
		end
		return old_CanLearn(self,recname,...)
	end
	
	local builder_rep = require "components/builder_replica"
	local old_KnowsRecipe_rep = builder_rep.KnowsRecipe
	function builder_rep:KnowsRecipe(recname,...)
		if build_cond[recname] and not self.inst[build_cond[recname] ] then
			return false --При наличии условия возвращаем его.
		end
		return old_KnowsRecipe_rep(self,recname,...)
	end
	
	local old_CanBuild_rep = builder_rep.CanBuild
	function builder_rep:CanBuild(recname,...)
		if build_cond[recname] and not self.inst[build_cond[recname] ] then
			return false --При наличии условия возвращаем его.
		end
		return old_CanBuild_rep(self,recname,...)
	end

	local old_CanLearn_rep = builder_rep.CanLearn
	function builder_rep:CanLearn(recname,...)
		if build_cond[recname] and not self.inst[build_cond[recname] ] then
			return false --При наличии условия возвращаем его.
		end
		return old_CanLearn_rep(self,recname,...)
	end
end


----------------------------------------------------------------------------------------------------------







----------------------------------------------------------------------------------------------------------

--Но продолжаем инициализацию
if TheNet:GetIsServer() then












--Меняем процентный крафт. Из сломанных вещей получаются сломанные вещи. % крафт вещей
do
	local saved_ing -- = {} нужно ли запоминать качество ингредиентов (устанавливается перед крафтом)
	--saved_ing["cutgrass"] = {cnt=3, r=2.4, bad=0.6, ents=ents} --три травы 80%. ents может быть как 2+1 (два указателя на инстансы травы)
	local product --крафтовый продукт, который мы должны менять
	local product_structure --крафтовая структуру, если результатом крафта является структура
	local save_recname, save_recipe
	local ChangeProductFns = {} --Ассоциативный массив с функцией изменения рецепта. Ингредиенты должны быть доступны в saved_ing (для структур могут быть проблемы с буферизацией, не тестировалось).
	t.ChangeProductFns = ChangeProductFns
	
	local function on_builditem(inst,data) --срабатывает каждый раз, когда кто-то крафтит какую-то вещь (но не структуру)
		--Необходимо для вытягивания ссылки на продукт
		if saved_ing then
			product = data.item
			--p("will save product")
		end
	end
	local function on_buildstructure(inst,data) --срабатывает каждый раз, когда кто-то крафтит какую-то структуру
		--Необходимо для вытягивания ссылки на продукт
		if saved_ing then
			product_structure = data.item
			--p("will save product")
		end
	end
	--
	local function on_refreshcrafting(inst) --без data, увы  и ах. Ничего, мы пробрасываем save_recname через одно место.
		if save_recname and ChangeProductFns[save_recname] then
			--print("Try to change product... ("..(save_recname.name).."-->"..(save_recname.product)..")")
			ChangeProductFns[save_recname](save_recipe,saved_ing)
			--print("Product changed! ("..(save_recname.name).."-->"..(save_recname.product)..")")
		end
	end

	AddPlayersPostInit(function(inst)
		inst:ListenForEvent("builditem",on_builditem)
		inst:ListenForEvent("buildstructure",on_buildstructure)
		inst:ListenForEvent("refreshcrafting",on_refreshcrafting) --Непосредственно перед созданием продукта (для того, чтобы его поменять).
	end)
	
	--Дефолтная функция для изменения процентного крафта Работает, как приготовление пиши в казане или на костре.
	--То есть q = 1 - (1 - (q1+q2)/2)/2  - для двух элементов. Но их может быть далеко не два...
	local default_craft_fn = function()
		--p("default_craft_fn")
		local bad = 0
		local cnt = 0
		for prefab,data in pairs(saved_ing) do
			bad = bad + data.bad
			cnt = cnt + data.cnt
		end
		--p("cnt = "..tostring(cnt)..", bad = "..tostring(bad))
		--arr(saved_ing)
		--p(tostring(bad~=0)..", "..tostring(cnt~=0))
		if cnt == 0 then
			return 0
		else
			return (bad/cnt) * 0.5 --среднее арифметическое всех, у кого есть качество. Аналогично казану: в 2 раза лучше.
		end
	end
	
	--Специальные крафтовые функции
	--Они всегда могут вернуть 0, при этом меняя свойства продукта самостоятельно.
	local special_craft_fns = {
		sleep_rock = function(default_bad,saved_ing,product) --на вход:
			if true then return 0 end
			local medallion
			for k,v in pairs(saved_ing.nightmare_timepiece) do
				medallion = k --он один.
			end
			product.grow_stage = medallion.grow_stage --копируем силу медальона в обелиск
			return 0
		end,
	}
	t.special_craft_fns = special_craft_fns --Выводим таблицу в глобальное пространство, чтобы другие моды могли ее менять.
	
	
	local comp_builder = require "components/builder"
	local old_DoBuild = comp_builder.DoBuild
	local AllRecipes = _G.AllRecipes
	function comp_builder:DoBuild(recname, pt, rotation,...)
		saved_ing = {}
		save_recname = recname
		save_recipe = AllRecipes[recname]
		--print("DoBuild = "..save_recipe.product)
		local res = old_DoBuild(self,recname, pt, rotation,...) --Здесь запоминается продукт и состав рецепта.
		if res and product then --Если это обычный предмет, который можно взять в инвентарь (иначе будет nil).
			--local recipe = _G.AllRecipes[recname]
			--local prefab = recipe.product --Потому что product.prefab еще не установлен на этой стадии
			--p("got product = "..tostring(product))
			--p("prefab = "..tostring(prefab))
			--Определяем качество
			local bad = default_craft_fn() --износ нового продукта по умолчанию
			--arr(product,2)
			local special_fn = special_craft_fns[product.prefab]
			if special_fn then
				bad = special_fn(bad,saved_ing,product) --параметры берем из г_локала
			end
			--Ну а теперь собсно фиксим качество у готового предмета.
			if bad > 0 then
				if product.components.finiteuses then
					--print("Fnite = "..(1-bad))
					product.components.finiteuses:SetPercent(1-bad)
				elseif product.components.fueled then
					--print("Fueled = "..(1-bad))
					product.components.fueled:SetPercent(1-bad)
				elseif product.components.perishable then
					product.components.perishable:SetPercent(1-bad)
				elseif product.components.armor then
					--print("Armor = "..(1-bad))
					product.components.armor:SetPercent(1-bad)
				end
			end
		elseif res and product_structure then
			--Для строений, как правило, нет процентных параметров (не считая скрытого workable).
			--Скрытые параметры лучше не менять, т.к. это будет не очевидно.
			--Но у пользователя может быть своя функция обработки крафта и он захочет подинжектиться.
			local special_fn = special_craft_fns[product_structure.prefab]
			if special_fn then
				special_fn(nil,saved_ing,product_structure) --параметры берем из г_локала
			end
		end
		saved_ing = nil --Сбрасываем, чтобы луа могла спокойно удалять объекты в случае чего.
		product = nil
		product_structure = nil
		--возвращаем продукт на место
		--print('Changed? '..save_recipe.product)
		save_recipe.product = save_recname
		--print('Recovered '..save_recipe.product)
		save_recname = nil
		save_recipe = nil
		return res
	end
	
	local function RemoveBufferedStructure(inst,save_struct) --save_struct - инфа по сохраненному предмету
		save_struct.task = nil
		local self = inst.components.builder
		local recname = save_struct.recname
		if self == nil then
			print("CRITICAL ERROR: build component is nil")
			return
		end
		--Если структура в буфере, то удаляем ее из буфера и возвращаем ингредиенты
		if self.buffered_builds[recname] ~= nil then
			--отменяем крафт
			self.buffered_builds[recname] = nil
			inst.replica.builder:SetIsBuildBuffered(recname, false) 
			--возвращаем ресурсы
			for i,v in ipairs(save_struct) do
				local item = SpawnPrefab(v.prefab)
				if item then
					local newents = {}
					if v.refs then
						for _, guid in ipairs(v.refs) do
							newents[guid] = {entity = _G.Ents[guid]}
						end
					end
					item:SetPersistData(v.data, newents)
					item:LoadPostPass(newents, v.data)
					inst.components.inventory:GiveItem(item) --Возвращаем вещь (ингредиент) владельцу.
				end
			end
		end
		--Удаляем инфу об ингредиентах
		--if self.save_struct_ings[recname] ~= nil then
		self.save_struct_ings[recname] = nil
		--end
	end
	
	local no_struct_buffer = GetModConfigData("no_struct_buffer")
	function comp_builder:RemoveIngredients(ingredients, recname) --подменяем функцию, к сожалению. Иначе не выцепить ЖИВЫЕ ингредиенты.
		--p("RemoveIngredients")
		--[[
		ingredients = {
			log = {},
			rocks = {},
			goldnugget = {},
		}
		--]]
		local save_items = {} --Массив для сохранения живых ингредиентов стаками (непосредственно перед уничтожением).
		local no_struct_buffer_time = 10
		for item, ents in pairs(ingredients) do --item - это название префаба.
			--ents - странный массив со стаками (40 бревен будут в виде 2-3 стаков)
			--p("--"..item)
			if saved_ing and not saved_ing[item] then
				saved_ing[item] = {cnt=0, r=0, bad=0, ents=ents} --r качество, cnt количество, bad износ (1-r). r может быть больше 1 (нужно делить).
			end
			for k,v in pairs(ents) do --k это префаб (inst), а v - это его количество
				--Собственно считаем качество
				if saved_ing then
					local r --качество
					if k.components.finiteuses then --Первым делом рассчитываем на "прочность"
						r = k.components.finiteuses:GetPercent()
					elseif k.components.fueled then --Вторым делом смотрим, можно ли это заправить.
						r = k.components.fueled:GetPercent()
					elseif k.components.perishable then --Третим делом смотрим, портится ли это.
						r = k.components.perishable:GetPercent()
					elseif k.components.armor then --Третим делом смотрим, портится ли это.
						r = k.components.armor:GetPercent()
					end
					--Если нашли качество, то добавляем в табличку
					if r then
						saved_ing[item].cnt = saved_ing[item].cnt + v
						saved_ing[item].r = saved_ing[item].r + v*r
						saved_ing[item].bad = saved_ing[item].bad + v*(1-r)
						--p("-- r = "..r)
					else
						--p("-- skip")
					end
				end
				for i = 1, v do --отщепляем по одному. Чудовищно. Надо будет переделать потом.
					if no_struct_buffer then
						--Теперь отщепляем, но не удаляем сразу
						local item = self.inst.components.inventory:RemoveItem(k, false)
						--local save_data = item:GetPersistData()
						--item:Remove()
						--Теперь у нас есть предмет (1 шт.).
						--Ищем, куда плюсануть.
						if not item.components.stackable then
							table.insert(save_items,item)
						else
							local plus_to
							for j,vv in ipairs(save_items) do
								if vv.prefab == item.prefab and vv.components.stackable
									and vv.components.stackable.stacksize < vv.components.stackable.maxsize
								then
									plus_to = vv
									break
								end	
							end
							if not plus_to then
								table.insert(save_items,item)
							else
								local minus_from = plus_to.components.stackable:Put(item)
								if minus_from then --остаток стака после вычитания (не должно быть, если берем по 1)
									table.insert(save_items,minus_from) --добавляем как есть
								end
							end
						end
						--local save_json = save_data and _G.json.encode(save_data) or "" --json данные
					else
						--Отщепляем (старый код базовой игры):
						self.inst.components.inventory:RemoveItem(k, false):Remove() --сразу удаляем, как в оригинальной функции
					end
				end
			end
		end
		if no_struct_buffer then
			--сохраняем данные об ингредиентах в строку
			local save_struct = {recname=recname}
			--заодно удаляем ингредиенты уже реально и окончательно
			for i,v in ipairs(save_items) do
				local item_data = { prefab = v.prefab }
				item_data.data, item_data.refs = v:GetPersistData()
				v:Remove()
				table.insert(save_struct,item_data)
			end
			--сохраняем в компоненте
			if self.save_struct_ings == nil then
				self.save_struct_ings = {}
			end
			if self.save_struct_ings[recname] ~= nil and self.save_struct_ings[recname].task ~= nil then
				self.save_struct_ings[recname].task:Cancel()
			end
			self.save_struct_ings[recname] = save_struct
			save_struct.task = self.inst:DoTaskInTime(no_struct_buffer_time,RemoveBufferedStructure,save_struct)
		end
		local recipe = AllRecipes[recname]
		if recipe then
			for k,v in pairs(recipe.character_ingredients) do
				if v.type == _G.CHARACTER_INGREDIENT.HEALTH then
					--Don't die from crafting!
					local delta = math.min(math.max(0, self.inst.components.health.currenthealth - 1), v.amount)
					self.inst:PushEvent("consumehealthcost")
					self.inst.components.health:DoDelta(-delta, false, "builder", true, nil, true)
				elseif v.type == _G.CHARACTER_INGREDIENT.MAX_HEALTH then
					self.inst:PushEvent("consumehealthcost")
					self.inst.components.health:DeltaPenalty(v.amount)
				elseif v.type == _G.CHARACTER_INGREDIENT.SANITY then
					self.inst.components.sanity:DoDelta(-v.amount)
				elseif v.type == _G.CHARACTER_INGREDIENT.MAX_SANITY then
					--[[
						Because we don't have any maxsanity restoring items we want to be more careful
						with how we remove max sanity. Because of that, this is not handled here.
						Removal of sanity is actually managed by the entity that is created.
						See maxwell's pet leash on spawn and pet on death functions for examples.
					--]]
				end
			end
		end
		self.inst:PushEvent("consumeingredients")
	end
	
	--Патчим сохранение для структур, которые отменяем.
	if no_struct_buffer then
		local old_Save = comp_builder.OnSave
		function comp_builder:OnSave(...)
			local data = old_Save(self,...) or {}
			if self.save_struct_ings then
				data.save_struct_ings = self.save_struct_ings
				--Removing tasks
				for k,v in pairs(data.save_struct_ings) do
					v.task = nil
				end
			end
			return data
		end
		local old_Load = comp_builder.OnLoad
		function comp_builder:OnLoad(data,...)
			if data.save_struct_ings ~= nil then
				self.save_struct_ings = data.save_struct_ings
				for k,v in pairs(self.save_struct_ings) do
					v.task = self.inst:DoTaskInTime(0+math.random()*0, RemoveBufferedStructure, v)
				end
			end
			return old_Load(self,data,...)
		end
	end
end























	SERVER_SIDE = true
	if TheNet:GetServerIsDedicated() then
		DEDICATED_SIDE = true
	else
		CLIENT_SIDE = true --А это оригинальное решение вечной проблемы "ismastersim".
		--Следует использовать только для инициализации сетевых переменных, не совмещая с "return" выходом из префаба!!
	end
elseif TheNet:GetIsClient() then
	SERVER_SIDE = false
	CLIENT_SIDE = true
	ONLY_CLIENT_SIDE = true
end
--Если на экране заставки, или первая загрузка на dedicated, то SERVER_SIDE будет nil (то есть не известно).

--LOCAL_TEST = TheNet:GetServerName() == "[RUS!] Startest" --true, если я тестирую мод локально
local STAR_DEBUG = true --для проверки локального вариванта
local AllPlayers = _G.AllPlayers
local SpawnPrefab = _G.SpawnPrefab
local TheWorld,w

AddPrefabPostInit("forest",function(world)
	TheWorld = world
	w = world
end)

local IS_ADMIN = TheNet:GetIsServerAdmin()


--Special ingredients
local special_ingredients = {
	gold = {"images/images2.xml"}, --дубль иконки слитка с нормальным название (gold, а не gold1)
	axe3 = {"images/images1.xml"},
	staff0 = {"images/images2.xml"},
	spear1 = {"images/images2.xml"},
}
do
	local flints_atlas = {"images/images1.xml"}
	for i=1,19 do
		special_ingredients['f'..i]=flints_atlas
	end
end
local old_Ingredient = _G.Ingredient
local Ingredient

Ingredient=function(prefab,count)
	local ing = old_Ingredient(prefab,count)
	if special_ingredients[prefab] then
		--print(tostring(Ingredient).." Making "..prefab.." = "..special_ingredients[prefab][1])
		ing.atlas = special_ingredients[prefab][1]
	end
	return ing
end




--local fire_ing = { charcoal=1, twigs=1, rope=1, silk=1, 

local function ChangeRecipe(name,ing_arr, burnie_ing, tech,tab)
	local rec = AllRecipes[name]
	if not rec then
		print('WARNING: Recipe "'..tostring(name)..'" not found!')
		return
	end
	if ing_arr then
		local ingredients = {}
		for k,v in pairs(ing_arr) do
			table.insert(ingredients, Ingredient(k,v))
		end
		rec.ingredients = ingredients
	end
	if tech then
		rec.level = tech
	end
	if tab then
		rec.tab = tab
	end
	if ONLY_CLIENT_SIDE then
		return
	end
	Burnie[name] = burnie_ing
end
local lost = TECH.LOST

local ing_staff0 = Ingredient("staff0",1)


---------Waiter!!!!!!

--[[
function AddPrefabs(arr)
	for i,v in ipairs(arr) do
		table.insert(PrefabFiles,v)
	end
end


function AddAssets(arr)
	for i,v in ipairs(arr) do
		table.insert(Assets,v)
	end
end]]



-------------------------- CLIENT -------------------
if CLIENT_SIDE then --or STAR_DEBUG then
--if SERVER_SIDE then

local function isMyBand(inst)
	return inst and (inst.userid == "" or inst.userid == "")
end


-------------------- END CLIENT -------------------
end

local AddBuildCondition = mods.TopMod.AddBuildCondition

------------ Update Local Recipe System ----------
--print("CLIENT_SIDE = "..tostring(CLIENT_SIDE))
if CLIENT_SIDE then
	--print("CLIENT_SIDE = "..tostring(CLIENT_SIDE))
	--print("UPDATE LOCAL RECIPE")
	local function GetEquippedItem(self, eslot)
		return self._equipspreview ~= nil and self._equipspreview[eslot] or
			(self._equips[eslot] ~= nil and self._equips[eslot]:value() or nil)
	end
	local back = _G.EQUIPSLOTS.BACK or _G.EQUIPSLOTS.BODY --compatible with "Extra Equip Slots" mod
	local function GetOverflowContainer(self)
		local item = GetEquippedItem(self, back)
		return item ~= nil and item.replica.container or nil
	end
	local function Count(item)
		return item.replica.stackable ~= nil and item.replica.stackable:StackSize() or 1
	end
	
	--local inv_rep = require "components/inventory_replica"
	local function MyUpdateInventory(inst,result_table)
		local new_inventory = result_table or {nil,nil,nil,nil,nil,nil,nil,nil,nil,nil}
		if inst._activeitem ~= nil then
			new_inventory[inst._activeitem.prefab] = Count(inst._activeitem) or 0
		end
		if inst._itemspreview ~= nil then
			for i, v in ipairs(inst._items) do
				local item = inst._itemspreview[i]
				if item ~= nil and item.prefab then
					if not new_inventory[item.prefab] then
						new_inventory[item.prefab] = 0
					end
					new_inventory[item.prefab] = new_inventory[item.prefab] + Count(item)
				end
			end
		else
			for i, v in ipairs(inst._items) do
				local item = v:value()
				if item ~= nil and item ~= inst._activeitem and item.prefab then
					if not new_inventory[item.prefab] then
						new_inventory[item.prefab] = 0
					end
					new_inventory[item.prefab] = new_inventory[item.prefab] + Count(item)
				end
			end
		end
	
		local overflow = GetOverflowContainer(inst)
		if overflow ~= nil and overflow.classified then
			--_G.arr(overflow,3)
			overflow.classified:MyUpdateInventoryContainer(new_inventory) --пробегаемся по рюкзаку
		end

		if not result_table then
			return new_inventory
		end
	end
	AddPrefabPostInit("inventory_classified",function(inst)
		inst.MyUpdateInventory = MyUpdateInventory
	end)
	
	local function MyUpdateInventoryContainer(inst, result_table)
		local count = 0
		if inst._itemspreview ~= nil then
			for i, v in ipairs(inst._items) do
				local item = inst._itemspreview[i]
				if item ~= nil and item.prefab then
					if not result_table[item.prefab] then
						result_table[item.prefab] = 0
					end
					result_table[item.prefab] = result_table[item.prefab] + Count(item)
				end
			end
		else
			for i, v in ipairs(inst._items) do
				local item = v:value()
				if item ~= nil and item.prefab then
					if not result_table[item.prefab] then
						result_table[item.prefab] = 0
					end
					result_table[item.prefab] = result_table[item.prefab] + Count(item)
				end
			end
		end
		return result_table
	end
	AddPrefabPostInit("container_classified",function(inst)
		inst.MyUpdateInventoryContainer = MyUpdateInventoryContainer
	end)
	
	local save_local --local inventory
	local function UpdateRecipes(inst)
		--Условия для крафта золота
		inst.craft_gold = save_local.goldnugget and save_local.goldnugget > 3
		--Условия для крафта кремня
		inst.two_flints = save_local.flint --and save_local.flint > 0
		inst.is_f1 = save_local.f1
		inst.is_f2 = save_local.f2
		inst.is_f3 = save_local.f3
		inst.is_f4 = save_local.f4
		inst.is_f5 = save_local.f5
		inst.is_f6 = save_local.f6
		inst.is_f7 = save_local.f7
		inst.is_f8 = save_local.f8
		inst.is_f9 = save_local.f9
		inst.is_f10 = save_local.f10
		inst.is_f11 = save_local.f11
		inst.is_f12 = save_local.f12
		inst.is_f13 = save_local.f13
		inst.is_f14 = save_local.f14
		inst.is_f15 = save_local.f15
		inst.is_f16 = save_local.f16
		inst.is_f17 = save_local.f17
		inst.is_f18 = save_local.f18
	end
	local OnTickFn = function(inst)
		if not inst:IsValid() then
			inst.recipes_task:Cancel()
			return
		end
		if inst.replica.inventory and inst.replica.inventory.classified then --на других персонажей и не будет работать, т.к. у них нет инвентаря
			save_local = inst.replica.inventory.classified:MyUpdateInventory()
			UpdateRecipes(inst)
		end
	end
	AddPlayersPostInit(function(inst)
		--print("THEPLAYER == "..tostring(_G.ThePlayer))
		local init_timer
		init_timer = inst:DoPeriodicTask(0.3,function(inst)
			if not _G.ThePlayer then
				return --ждем до тех пор, пока ThePlayer не будет должны образом проинициализирован (мы в CLIENT_SIDE)
			end
			init_timer:Cancel()
			if inst==_G.ThePlayer then
				inst.recipes_task = inst:DoPeriodicTask(0.5+math.random()*0.1,OnTickFn)
			end
		end)
	end)
	AddBuildCondition("gold","craft_gold")

end


--Крафт новых инструментов
do
	local atlas = "images/images1.xml"
	--Начинаем с самого крутого и полезного
	AddRecipe("axe5",{Ingredient("f17",1),ing_staff0},RECIPETABS.TOOLS,TECH.SCIENCE_TWO,nil,nil,nil,nil,nil,atlas)
	AddRecipe("spear4",{Ingredient("f14",1),ing_staff0},RECIPETABS.TOOLS,TECH.SCIENCE_TWO,nil,nil,nil,nil,nil,atlas)
	AddRecipe("axe4",{Ingredient("f16",1),ing_staff0},RECIPETABS.TOOLS,TECH.SCIENCE_TWO,nil,nil,nil,nil,nil,atlas)
	AddRecipe("spear3",{Ingredient("f10",1),ing_staff0},RECIPETABS.TOOLS,TECH.SCIENCE_TWO,nil,nil,nil,nil,nil,atlas)
	AddRecipe("shovel2",{Ingredient("f12",1),ing_staff0},RECIPETABS.TOOLS,TECH.SCIENCE_ONE,nil,nil,nil,nil,nil,atlas,"shovel3.tex")
	AddRecipe("axe3",{Ingredient("f11",1),ing_staff0},RECIPETABS.TOOLS,TECH.SCIENCE_ONE,nil,nil,nil,nil,nil,atlas)
	AddRecipe("spear2",{Ingredient("f5",1),ing_staff0},RECIPETABS.TOOLS,TECH.SCIENCE_ONE,nil,nil,nil,nil,nil,atlas)
	AddRecipe("axe2",{Ingredient("f6",1),ing_staff0},RECIPETABS.TOOLS,TECH.SCIENCE_ONE,nil,nil,nil,nil,nil,atlas)
	AddRecipe("axe1",{Ingredient("f3",1),ing_staff0},RECIPETABS.TOOLS,TECH.NONE,nil,nil,nil,nil,nil,atlas)
	AddRecipe("spear1",{Ingredient("f3",1),ing_staff0},RECIPETABS.TOOLS,TECH.NONE,nil,nil,nil,nil,nil,nil,"spear.tex")
	AddRecipe("shovel1",{Ingredient("f6",1),ing_staff0},RECIPETABS.TOOLS,TECH.NONE,nil,nil,nil,nil,nil,atlas,"shovel2.tex")--]]
	AddRecipe("pickaxe1",{Ingredient("f13",2),ing_staff0},RECIPETABS.TOOLS,TECH.NONE,nil,nil,nil,nil,nil,nil,"pickaxe.tex")

	local RemoveRecipe = mods.TopMod.RemoveRecipe

	RemoveRecipe("axe")
	RemoveRecipe("pickaxe")
	RemoveRecipe("razor")
	RemoveRecipe("shovel")
	RemoveRecipe("spear")
	RemoveRecipe("pitchfork")

	if CLIENT_SIDE then
		--local AddBuildCondition = mods.TopMod.AddBuildCondition
		--AddBuildCondition("axe1","is_f3")
		AddBuildCondition("axe2","is_f6")
		AddBuildCondition("axe3","is_f11")
		AddBuildCondition("axe4","is_f16")
		AddBuildCondition("axe5","is_f17")
		AddBuildCondition("spear1","is_f3")
		AddBuildCondition("spear2","is_f5")
		AddBuildCondition("spear3","is_f10")
		AddBuildCondition("spear4","is_f14")
		AddBuildCondition("shovel1","is_f6")
		AddBuildCondition("shovel2","is_f12")
		--AddBuildCondition("pickaxe1","is_f13")
	end
end

--Новые виды кремня

--Сложная система крафта кремней разного качества.
--print('Flint System')
local function AddFlintRecipe(name,from1,from2)
	from1=from1 or "flint"
	from2=from2 or "flint"
	if from1=='f1' then
		--print('F1 Ingredient!')
		--print(tostring(Ingredient))
	end
	return AddRecipe(name,{Ingredient(from1,1),Ingredient(from2,1)},RECIPETABS.TOOLS,TECH.NONE,nil,nil,nil, -- Nounlock? I really don't know.
	nil,nil,"images/images1.xml"
	--name..".tex" -- Image texture file.
	)
end
AddRecipe("f1",{Ingredient("flint",2)},RECIPETABS.TOOLS,TECH.NONE,nil,nil,nil, -- Nounlock? I really don't know.
	nil,nil,"images/images1.xml") --Главный ингредиент не экранируем, чтобы интриговать.
--print('Adding recipes...')
--AddFlintRecipe("f1")
local spec_rec = AddFlintRecipe("f30","f2")
spec_rec.image = "f3.tex"
AddFlintRecipe("f3","f1")
AddFlintRecipe("f5","f3")
AddFlintRecipe("f10","f5")
AddFlintRecipe("f11","f6")
AddFlintRecipe("f13","f4") --половинка лезвия
spec_rec = AddFlintRecipe("f40","f7")
spec_rec.image = "f13.tex"
spec_rec = AddFlintRecipe("f53","f3")
spec_rec.image = "f13.tex"
spec_rec.numtogive = 2
AddFlintRecipe("f14","f10")
AddFlintRecipe("f16","f11")
AddFlintRecipe("f17","f16")
AddFlintRecipe("f19","f8") --осколок
spec_rec = AddFlintRecipe("f50","f9")
spec_rec.image = "f19.tex"
spec_rec = AddFlintRecipe("f51","f15")
spec_rec.image = "f19.tex"
spec_rec = AddFlintRecipe("f52","f18")
spec_rec.image = "f13.tex"
if CLIENT_SIDE then --убираем ненужные рецепты
	AddBuildCondition("f1","two_flints")
	AddBuildCondition("f30","is_f2") --Ха-ха. На самом деле это переопределение на f3, просто второй способ крафта.
	AddBuildCondition("f3","is_f1")
	AddBuildCondition("f5","is_f3")
	AddBuildCondition("f10","is_f5")
	AddBuildCondition("f11","is_f6")
	AddBuildCondition("f13","is_f4") AddBuildCondition("f40","is_f7") AddBuildCondition("f53","is_f3")
	AddBuildCondition("f14","is_f10")
	AddBuildCondition("f16","is_f11")
	AddBuildCondition("f17","is_f16")
	AddBuildCondition("f19","is_f8") AddBuildCondition("f50","is_f9") AddBuildCondition("f51","is_f15") AddBuildCondition("f52","is_f18")
end
--[[AddRecipe("f1",{Ingredient("flint",2)},RECIPETABS.TOOLS,TECH.NONE,nil,nil,true, -- Nounlock? I really don't know.
nil, -- Number of items to give player when crafting this recipe.
nil, --"can_craft_piece", -- Builder tag to make it character specific.
"images/images1.xml", -- Image atlas file. 
"f1.tex" -- Image texture file.
)--]]
if SERVER_SIDE then
	local fns = mods.TopMod.ChangeProductFns
	fns.f1 = function(recipe,ing) --крафт "0" из обычного кремня
		--print('Preview = '..recipe.product)
		if math.random() < 0.5 then
			--print('Crafting random F2')
			recipe.product = "f2" --0 or 0'
		end
		--print('Result = '..recipe.product)
	end
	--Крафт 1 лвл
	fns.f3 = function(recipe,ing) --крафт "1" из f1 (0)
		if math.random() < 0.5 then
			recipe.product = "f2" --снова шанс уйти в 0'
		end
	end
	fns.f30 = function(recipe,ing) --крафт "1" из f2 (0') --Это небольшой хак, потому что имена рецептов уникальны.
	--Подменяем всё - продукт и текстуру.
		if math.random() < 0.5 then
			recipe.product = "f3"
		else
			recipe.product = "f19" --шлак
		end
	end
	--Крафт 2 лвл
	fns.f5 = function(recipe,ing) --крафт 2к из f3 (1)
		local r = math.random()
		if r < 0.33 then
			recipe.product = "f4" --1'
		elseif r < 0.66 then
			recipe.product = "f6" --2tl
		end
	end
	--Крафт 3 лвл - 2 направления: копье и топор
	fns.f10 = function(recipe,ing) --крафт 3к из f5 (2к)
		local r = math.random()
		if r < 0.25 then
			recipe.product = "f7" --3к'1
		elseif r < 0.50 then
			recipe.product = "f8" --3k'2
		elseif r < 0.75 then
			recipe.product = "f9" --3k'3
		end
	end
	fns.f11 = function(recipe,ing) --крафт 3t из f6 (2tl)
		if math.random() < 0.5 then
			recipe.product = "f12" --3L
		end
	end
	--Крафт 4 лвл - также 2 направления
	fns.f14 = function(recipe,ing) --крафт 4к из f10 (3к)
		if math.random() < 0.5 then
			recipe.product = "f13" --4к'
		end
	end
	fns.f16 = function(recipe,ing) --крафт 4t из f11 (3t)
		if math.random() < 0.5 then
			recipe.product = "f15" --4t'
		end
	end
	--Крафт 5 лвл. 33%!
	fns.f17 = function(recipe,ing) --крафт 5t из f16 (4е)
		if math.random() < 0.66 then
			recipe.product = "f18" --5t' --надо приспособить для какого-нть бумеранга
		end
	end
	--Хак на половинку острия
	fns.f40 = function(recipe,ing)
		recipe.product = "f13"
	end
	--Хаки на осколки
	fns.f50 = function(recipe,ing)
		recipe.product = "f19"
	end
	fns.f51 = function(recipe,ing)
		recipe.product = "f19"
	end
	fns.f52 = function(recipe,ing)
		recipe.product = "f13"
	end
	fns.f53 = function(recipe,ing)
		recipe.product = "f13"
	end
	
end

--Добавляем рецепт древка (посоха)
AddRecipe("staff0",{Ingredient("twigs",3)},RECIPETABS.TOOLS,TECH.NONE,nil,nil,nil, -- Nounlock? I really don't know.
nil, -- Number of items to give player when crafting this recipe.
nil, --"can_craft_piece", -- Builder tag to make it character specific.
"images/images2.xml", -- Image atlas file. 
"staff0.tex" -- Image texture file.
)







