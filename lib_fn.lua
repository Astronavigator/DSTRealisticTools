--[[Library for injections in game files, prefabs, components, timers, event listeners, world listeners etc

Copyright(c) star

В новый мод необходимо скопировать строку инициализации:
modimport "lib_ver.lua"

Далее можно добавить строку ключевых слов (для notepad++):
--TheSim,TheNet,require,SpawnPrefab,p,arr,SetSharedLootTable,Vector3,SEASONS,FUELTYPE,ACTIONS,GetTime,AllPlayers,
--FindUpvalue,AddPlayersPostInit,GetWatchWorldStateFn,GetListener,SaveTimers,GetLastTimer,GetLastTimerFn,
--AddHookOnLastTask,AddHookOnComponent,GetTags, AddWorldPostInit, SaveOption, LoadOption,
--SERVER_SIDE, CLIENT_SIDE, DEDICATED_SIDE, ONLY_CLIENT_SIDE


Если есть 100% уверенность, что библиотека подключена, то доступ к ней можно получить так:
q = GLOBAL.mods.lib

Либо можно сразу импортировать все функции в свое пространство имен:
GLOBAL.mods.lib.ExportLib(env)
Важно помнить, что функция эта должна быть вызвана на нижнем этапе выполнения modmain.lua,
а всякие w и state будут инициализированы только после срабатывания AddPrefabPostInit("forest").

mods - список модов (и их элементов или обощений).
mods.lib - список переменных (и функций) для экспорта в любое пространство имен, где это нужно.
mods.lib.version - версия библиотеки

--]]



--[[
--Так нельзя делать, потому что, возможно, мы переопределяем старую библиотеку более новой с полной заменой функций и всего-всего.
if mods.lib then
	return
end
--Правильнее всего считать, что mods.lib не определена. Но при этом в некоторых случаях вытягивать оттуда ключевые таблицы.
--]]


--Удобная функция работы с глобалом, в обход ограничений.
local function GetGlobal(gname,default)
	local res=_G.rawget(_G,gname)
	if res == nil and default ~= nil then
		_G.rawset(_G,gname,default)
		return default
	else
		return res
	end
end

--Делаем самую правильную в мире функцию "AddPlayersPostInit" 
GetGlobal("mods",{})
--if not _G.rawget(_G,"mods") then _G.rawset(_G,"mods",{}) end
if not _G.mods.player_preinit_fns then
	_G.mods.player_preinit_fns={}
	--Dirty hack
	local old_MakePlayerCharacter = _G.require("prefabs/player_common")
	local function new_MakePlayerCharacter(...)
		local inst=old_MakePlayerCharacter(...)
		for _,v in ipairs(_G.mods.player_preinit_fns) do
			v(inst)
		end
		return inst
	end
	_G.package.loaded["prefabs/player_common"] = new_MakePlayerCharacter
end

function AddPlayersPreInit(fn)
	table.insert(_G.mods.player_preinit_fns,fn)
end

local player_postinit_fns = {}
function AddPlayersPostInit(fn) -- <<<--------- Вот она!
	table.insert(player_postinit_fns,fn)
end

local done_players = {}
AddPlayersPreInit(function(inst)
	local s = inst.prefab or inst.name
	if not done_players[s] then
		done_players[s] = true
		AddPrefabPostInit(s,function(inst)
			for _,v in ipairs(player_postinit_fns) do
				v(inst)
			end
		end)
	end
end)

local player_afterinit_fns = {}
function AddPlayersAfterInit(fn) --Нулевой таймер после
	table.insert(player_afterinit_fns,fn)
end
AddPlayersPostInit(function(inst) --Задаем нулевой таймер
	if #player_afterinit_fns > 0 then
		inst:DoTaskInTime(0,function(inst)
			for i=1,#player_afterinit_fns do
				player_afterinit_fns[i](inst)
			end
		end)
	end
end)


--Инициализация мира (совместимость со всеми известными ветками ДСТ)
--(переменная mods должна быть уже определена в lib_ver)
local world_init_fns = mods.lib and mods.lib.world_init_fns or {}

local function AddWorldPostInit(fn) --> Добавляет функцию в список функций для инициализации мира.
	table.insert(world_init_fns,fn)
end
local was_forest
local function world_init(inst) --> Собственно сама функция инициализации.
	if was_forest then
		return
	end
	was_forest = true
	for i=1,#world_init_fns do
		world_init_fns[i](inst)
	end
end
AddPrefabPostInit("world",world_init)
AddPrefabPostInit("forest",world_init)


--Пустая функция. Иногда нужно заткнуть кого-то или что-то, чтоб они думали, что продолжают делать что-то важное.
local EmptyFunction = function() end
--переменная mods должна быть уже определена в lib_ver
local static = mods.lib and mods.lib.static or {} --Таблица с неизменными функциями (которые нельзя инициализировать дважды).

--Список пространств имен модов, которые заюзали библиотеку. Нужно для инициализации TheWorld
local _mods = mods.lib and mods.lib._mods or {}


local TheSim=_G.TheSim
local TheNet=_G.TheNet
local require=_G.require
local SpawnPrefab=_G.SpawnPrefab
local p=GetGlobal("p",EmptyFunction) --import from Cheats
local arr=GetGlobal("arr",EmptyFunction) --import from Cheats
local SetSharedLootTable=_G.SetSharedLootTable
local Vector3=_G.Vector3
local SEASONS = _G.SEASONS
local FUELTYPE = _G.FUELTYPE
local ACTIONS = _G.ACTIONS
local GetTime = _G.GetTime
local AllPlayers = _G.AllPlayers

--Базовые (библиотечные) вспомогательные функции для эффективного перехвата

--Получить указатель на функция из WatchWorldState
-- inst - префаб, у которого тырим функцию. event - имя события. num по умолчанию 0 - глубина вытягивания.
--Следует помнить, что функция основана на порядке добавления в массив и должна вызываться сразу после изменений массива функций.
local function GetWatchWorldStateFn(inst,event,num)
	num = num or 0
	local w = inst.worldstatewatching
	if w and w[event] then
		local count = #w[event] - num
		if count > 0 then
			local fn = w[event][count] --Берём последнюю, т.к. скорее всего это она. Ну или будет фигово.
			return fn, w[event], count
		end
	end
	return EmptyFunction, false
end
--Проверку корректности можно осуществлять путем сравнения с EmptyFunction, но это нужно редко.


--Вытянуть (вернуть) функцию после ListenForEvent
local function GetListener(inst,event,source,offset) --аналогично предыдущей функции
	--source - источник (проблем). То, что указывается в листенере при добавлении. Важно знать (если он указан вообще).
	source = source or inst
	offset = offset or 0
	local w = inst.event_listeners --event_listening --Напоминаю, что у источника есть "event_listeners"
	--arr(w)
	if w and w[event] then
		local fns = w[event][source]
		if fns and #fns > offset then
			local fn = fns[#fns-offset]
			return fn, fns, (#fns-offset)
		end
	end
	return EmptyFunction, false
end


--Эти две функции необходимы для перехвата последнего добавленного таймера у префаба.
--Если в конструкторе префаба более одного таймера, то результат НЕ ОПРЕДЕЛЕН!
local saved_timers
local function SaveTimers(inst)
	saved_tasks = {}
	if inst.pendingtasks then
		for k,v in pairs(inst.pendingtasks) do
			saved_tasks[k]=true
		end
	end
end

local function GetLastTimer(inst)
	if inst.pendingtasks then
		for k,v in pairs(inst.pendingtasks) do
			if not saved_tasks[k] then
				return k
			end
		end
	end
end

local function GetLastTimerFn(inst)
	local timer = GetLastTimer(inst)
	return timer and timer.fn
end

--Добавляет хук на последний таймер в конструкторе компонента (ваще жесть).
--Хук срабатывает ПОСЛЕ функции таймера.
local function AddHookOnLastTask(component_name, new_fn)
	local comp = require("components/"..component_name)
	local old_ctor = comp._ctor
	local old_fn
	function comp._ctor(self, inst, ...)
		SaveTimers(inst)
		old_ctor(self, inst, ...)
		local task = GetLastTimer(inst)
		old_fn = task.fn
		task.fn = function(...)
			old_fn(...)
			new_fn(...)
		end
	end
end

--Добавить две функции: до и после конструктора компонента
local function AddHookOnComponent(component_name, before_fn, after_fn)
	local comp = require("components/"..component_name)
	local old_ctor = comp._ctor
	function comp._ctor(self, inst, ...)
		if before_fn then
			before_fn(self,inst,old_ctor)
		end
		local res = old_ctor(self, inst, ...)
		if after_fn then
			after_fn(self,inst,old_ctor)
		end
		return res
	end
end

--our naming conventions aren't completely consistent, sadly
local cook_aliases=
{
	cookedsmallmeat = "smallmeat_cooked",
	cookedmonstermeat = "monstermeat_cooked",
	cookedmeat = "meat_cooked"
}
local cooking = require("cooking")
local function GetTags(prefab) --Возвращает значение из казана
	if cook_aliases[prefab] and not cooking.ingredients[prefab] then
		prefab = cook_aliases[prefab] --Костыль на костыль, однако.
	end
	return cooking.ingredients[prefab] and cooking.ingredients[prefab].tags or {}
end


--Сохранение и загрузка переменных для игрового мира (в существующем компоненте, который никогда не удалят).
--Например, - birdspawner.
local data_players,w = {}
local SaveOption = function(player,option_name,value)
	player.data_player[option_name] = value
end

local LoadOption = function(player,option_name)
	return player.data_player[option_name]
end

AddPlayersAfterInit(function(inst) --Создаем глобальную ссылку в самом префабе игрока
	--Первым делом делаем связную ссылку на БД.
	--Этот вызов будет самым первым по отношению ко всем остальным AddPlayersAfterInit.
	local data = data_players[inst.userid]
	if not data then
		data = {}
		data_players[inst.userid] = data
	end
	inst.data_player = data -----> Сама привязка игрока к его БД.
end)


--Обновление игроков, когда они сравниваются друг с другом.
--Функционал заморожен до первого обращения к функции регистрации

--Функции обновления игроков.
--Каждая функция принимает на вход 2 параметра - игрок1 и игрок2.
--Массив организован в виде функций-ключей, а значения - это рейндж (в квадрате)
local players_update_fns = {}
local players_update_MAXRANGE = 0 --Квадрат максимального расстояния (чтобы сразу исключить неподходящие пары).

--Инициализирует сам апдейт (вызывается только 1 раз при первом вызове регистрации)
local function InitializePlayersUpdate()
	--print("InitializePlayersUpdate")
	AddWorldPostInit(function(w)
		--print("My AddWorldPostInit")
		w:DoPeriodicTask(0.5 + math.random()*0.1,function(w)
			--print("upd0")
			if #AllPlayers > 1 then
				--print("upd1")
				local time_now = GetTime()
				for i=1,#AllPlayers-1 do
					local inst1 = AllPlayers[i]
					for j=i+1,#AllPlayers do
						local inst2 = AllPlayers[j]
						local dist = inst1:GetDistanceSqToInst(inst2)
						--print("upd2 = "..tostring(dist).." "..tostring(players_update_MAXRANGE))
						if dist <= players_update_MAXRANGE then --В пределах досягаемости хотя бы одной функции
							for fn,dst in pairs(players_update_fns) do
								if dist <= dst then
									--print("call fn")
									fn(inst1,inst2,dist,time_now)
								end
							end
						end
					end
				end
			end
		end)
	end)
end

--Функция регистрации сравнения игроков.
--range - расстояние между игроками, на котором должна срабатывать функция fn каждые 0.5 сек
--ВАЖНО: Чтобы эта функция (хотя бы один вызов) была вызвана на стадии AddPrefabPostInit, потому что динамически инициировать нельзя.
local function RegisterPlayersUpdate(range,fn)
	--print("RegisterPlayersUpdate")
	if #players_update_fns == 0 then
		InitializePlayersUpdate() --Первичная инициализация (т.к. есть, что обновлять)
	end
	local new_range = range*range
	players_update_fns[fn] = new_range --Сразу возводим в квадрат, чтоб каждый раз не считать.
	if new_range > players_update_MAXRANGE then
		players_update_MAXRANGE = new_range
	end
end

--Возможно, понадобится (хотя пока не ясно, зачем)
local function UnRegisterPlayersUpdate(fn)
	players_update_fns[fn] = nil
end


--------------------------------------------------------- Q -----------------------------------------------------------------
--Нужно учитывать, что содержимое данной конкретной таблицы будет раскопировано на несколько модов.
local q = {


--Простые переменные

world_init_fns = world_init_fns,
AddWorldPostInit = AddWorldPostInit,
GetGlobal=GetGlobal,
EmptyFunction=EmptyFunction,
TheSim=TheSim,
TheNet=TheNet,
require=require,
SpawnPrefab=SpawnPrefab,
p=p,
arr=arr,
SetSharedLootTable=SetSharedLootTable,
Vector3=Vector3,
SEASONS = SEASONS,
FUELTYPE = FUELTYPE,
ACTIONS = ACTIONS,
GetTime = GetTime,
AllPlayers = AllPlayers,
SaveOption = SaveOption,
LoadOption = LoadOption,
RegisterPlayersUpdate = RegisterPlayersUpdate,
UnRegisterPlayersUpdate = UnRegisterPlayersUpdate,
_mods = _mods, --моды, также запросившие данную библиотеку (точнее их пространства имен в простом индексированном массиве)
static = static or {
--Статичные переменные и функции. Инициализируются лишь однажды. Использовать придется через ключевое слово static

}, --End of static functions



--Вытягивает локальные переменные из модуля по содержащейся в нем функции.
--member_check - свойство таблицы, чтобы иметь полную уверенность, что это та самая таблица.
FindUpvalue = function(fn, upvalue_name, member_check, no_print)
	local info = _G.debug.getinfo(fn, "u")
	local nups = info and info.nups
	if not nups then return end
	local getupvalue = _G.debug.getupvalue
	local s = ''
	--print("FIND "..upvalue_name.."; nups = "..nups)
	for i = 1, nups do
		local name, val = getupvalue(fn, i)
		--s = s .. name .. "\n"
		if (name == upvalue_name)
			and ((not member_check) or (type(val)=="table" and val[member_check])) --Надежная проверка
		then
			--print(s.."FOUND "..tostring(val))
			return val, true
		end
	end
	if not no_print then
		--print(s)
		print("CRITICAL ERROR: Can't find variable "..tostring(upvalue_name).."!")
	end
end,
--Если второе возвращаемое значение nil, то переменная не найдена.
--Также если есть полная уверенность в том, что значение переменной не может быть nil, то можно проверять и первое значение.


--Простая функция инициализации. Совместима с большинством персонажей, ибо их приоритет обычно 0.
--[[AddPlayersPostInit = function(fn)
	for i,v in ipairs(_G.DST_CHARACTERLIST) do
		AddPrefabPostInit(v,fn)
	end
	for i,v in ipairs(_G.MODCHARACTERLIST) do
		AddPrefabPostInit(v,fn)
	end
end,--]]
--Никогда, слышите? Никогда, не используйте этот костыль. Я несколько раз уже наступал на эти грабли, не понимая в чем же дело.


--Только правильный инжект!
AddPlayersPostInit = AddPlayersPostInit,
AddPlayersAfterInit = AddPlayersAfterInit,

--Остальное
GetWatchWorldStateFn = GetWatchWorldStateFn,
GetListener = GetListener,
SaveTimers = SaveTimers,
GetLastTimer = GetLastTimer,
GetLastTimerFn = GetLastTimerFn,
AddHookOnLastTask = AddHookOnLastTask,
AddHookOnComponent = AddHookOnComponent,
GetTags = GetTags,





--Экспортирует структуру переменных на заданное пространство имен.
--По сути просто копия содержания таблицы.
ExportLib = function(env)
	for k,v in pairs(mods.lib) do
		env[k]=v
	end
	table.insert(_mods,env) --запоминаем пространство имен мода
end,


} --конец структуры q

--Но продолжаем инициализацию
if TheNet:GetIsServer() then
	q.SERVER_SIDE = true
	if TheNet:GetServerIsDedicated() then
		q.DEDICATED_SIDE = true
	else
		q.CLIENT_SIDE = true --А это оригинальное решение вечной проблемы "ismastersim".
		--Следует использовать только для инициализации сетевых переменных, не совмещая с "return" выходом из префаба!!
	end
elseif TheNet:GetIsClient() then
	q.SERVER_SIDE = false
	q.CLIENT_SIDE = true
	q.ONLY_CLIENT_SIDE = true
end
--Если на экране заставки, или первая загрузка на dedicated, то SERVER_SIDE будет nil (то есть не известно).


--Функции сохранения/загрузки мира
local old_OnSaveWorld
local old_OnLoadWorld
local function new_OnSaveWorld(...)
	local data = old_OnSaveWorld(...)
	data.data_players = w.data_players
    return data
end

function new_OnLoadWorld(self,data)
	if data.data_players then
		w.data_players = data.data_players
		data_players = data.data_players
	end
	return old_OnLoadWorld(self,data)
end


if not (mods.lib and mods.lib.AddWorldPostInit) then --Делаем только в том случае, если в другом моде не делается то же самое.
	--Делаем в любом случае. Накрайняк есть страховка от двойного использования в самой AddWorldPostInit
	AddWorldPostInit(function(inst)
		w=inst --Локальная инициализация мира (чтобы работали кое-какие процедуры).
		w.data_players = data_players --База данных игроков (долгосрочное общедоступное хранение инфы).
		--Добавляем возможность сохранения/загрузки данных игрока
		if inst.components.birdspawner then
			old_OnSaveWorld = inst.components.birdspawner.OnSave
			old_OnLoadWorld = inst.components.birdspawner.OnLoad
			inst.components.birdspawner.OnSave = new_OnSaveWorld
			inst.components.birdspawner.OnLoad = new_OnLoadWorld
		else
			print("ERROR: no birdspawner in TheWorld")
			SaveOption = EmptyFunction
			LoadOption = EmptyFunction
		end
		--Инициализация пространств имен модов.
		for i,v in ipairs(_mods) do
			v.TheWorld = inst
			v.w = inst
			v.state = inst.state --TheWorld.state
		end
	end)
end

mods.lib = q
