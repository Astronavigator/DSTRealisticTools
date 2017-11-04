--[[Library for injections in game files, prefabs, components, timers, event listeners, world listeners etc

Copyright(c) star

� ����� ��� ���������� ����������� ������ �������������:
modimport "lib_ver.lua"

����� ����� �������� ������ �������� ���� (��� notepad++):
--TheSim,TheNet,require,SpawnPrefab,p,arr,SetSharedLootTable,Vector3,SEASONS,FUELTYPE,ACTIONS,GetTime,AllPlayers,
--FindUpvalue,AddPlayersPostInit,GetWatchWorldStateFn,GetListener,SaveTimers,GetLastTimer,GetLastTimerFn,
--AddHookOnLastTask,AddHookOnComponent,GetTags, AddWorldPostInit, SaveOption, LoadOption,
--SERVER_SIDE, CLIENT_SIDE, DEDICATED_SIDE, ONLY_CLIENT_SIDE


���� ���� 100% �����������, ��� ���������� ����������, �� ������ � ��� ����� �������� ���:
q = GLOBAL.mods.lib

���� ����� ����� ������������� ��� ������� � ���� ������������ ����:
GLOBAL.mods.lib.ExportLib(env)
����� �������, ��� ������� ��� ������ ���� ������� �� ������ ����� ���������� modmain.lua,
� ������ w � state ����� ���������������� ������ ����� ������������ AddPrefabPostInit("forest").

mods - ������ ����� (� �� ��������� ��� ��������).
mods.lib - ������ ���������� (� �������) ��� �������� � ����� ������������ ����, ��� ��� �����.
mods.lib.version - ������ ����������

--]]



--[[
--��� ������ ������, ������ ���, ��������, �� �������������� ������ ���������� ����� ����� � ������ ������� ������� � �����-�����.
if mods.lib then
	return
end
--���������� ����� �������, ��� mods.lib �� ����������. �� ��� ���� � ��������� ������� ���������� ������ �������� �������.
--]]


--������� ������� ������ � ��������, � ����� �����������.
local function GetGlobal(gname,default)
	local res=_G.rawget(_G,gname)
	if res == nil and default ~= nil then
		_G.rawset(_G,gname,default)
		return default
	else
		return res
	end
end

--������ ����� ���������� � ���� ������� "AddPlayersPostInit" 
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
function AddPlayersPostInit(fn) -- <<<--------- ��� ���!
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
function AddPlayersAfterInit(fn) --������� ������ �����
	table.insert(player_afterinit_fns,fn)
end
AddPlayersPostInit(function(inst) --������ ������� ������
	if #player_afterinit_fns > 0 then
		inst:DoTaskInTime(0,function(inst)
			for i=1,#player_afterinit_fns do
				player_afterinit_fns[i](inst)
			end
		end)
	end
end)


--������������� ���� (������������� �� ����� ���������� ������� ���)
--(���������� mods ������ ���� ��� ���������� � lib_ver)
local world_init_fns = mods.lib and mods.lib.world_init_fns or {}

local function AddWorldPostInit(fn) --> ��������� ������� � ������ ������� ��� ������������� ����.
	table.insert(world_init_fns,fn)
end
local was_forest
local function world_init(inst) --> ���������� ���� ������� �������������.
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


--������ �������. ������ ����� �������� ����-�� ��� ���-��, ���� ��� ������, ��� ���������� ������ ���-�� ������.
local EmptyFunction = function() end
--���������� mods ������ ���� ��� ���������� � lib_ver
local static = mods.lib and mods.lib.static or {} --������� � ����������� ��������� (������� ������ ���������������� ������).

--������ ����������� ���� �����, ������� ������� ����������. ����� ��� ������������� TheWorld
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

--������� (������������) ��������������� ������� ��� ������������ ���������

--�������� ��������� �� ������� �� WatchWorldState
-- inst - ������, � �������� ����� �������. event - ��� �������. num �� ��������� 0 - ������� �����������.
--������� �������, ��� ������� �������� �� ������� ���������� � ������ � ������ ���������� ����� ����� ��������� ������� �������.
local function GetWatchWorldStateFn(inst,event,num)
	num = num or 0
	local w = inst.worldstatewatching
	if w and w[event] then
		local count = #w[event] - num
		if count > 0 then
			local fn = w[event][count] --���� ���������, �.�. ������ ����� ��� ���. �� ��� ����� ������.
			return fn, w[event], count
		end
	end
	return EmptyFunction, false
end
--�������� ������������ ����� ������������ ����� ��������� � EmptyFunction, �� ��� ����� �����.


--�������� (�������) ������� ����� ListenForEvent
local function GetListener(inst,event,source,offset) --���������� ���������� �������
	--source - �������� (�������). ��, ��� ����������� � ��������� ��� ����������. ����� ����� (���� �� ������ ������).
	source = source or inst
	offset = offset or 0
	local w = inst.event_listeners --event_listening --���������, ��� � ��������� ���� "event_listeners"
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


--��� ��� ������� ���������� ��� ��������� ���������� ������������ ������� � �������.
--���� � ������������ ������� ����� ������ �������, �� ��������� �� ���������!
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

--��������� ��� �� ��������� ������ � ������������ ���������� (���� �����).
--��� ����������� ����� ������� �������.
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

--�������� ��� �������: �� � ����� ������������ ����������
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
local function GetTags(prefab) --���������� �������� �� ������
	if cook_aliases[prefab] and not cooking.ingredients[prefab] then
		prefab = cook_aliases[prefab] --������� �� �������, ������.
	end
	return cooking.ingredients[prefab] and cooking.ingredients[prefab].tags or {}
end


--���������� � �������� ���������� ��� �������� ���� (� ������������ ����������, ������� ������� �� ������).
--��������, - birdspawner.
local data_players,w = {}
local SaveOption = function(player,option_name,value)
	player.data_player[option_name] = value
end

local LoadOption = function(player,option_name)
	return player.data_player[option_name]
end

AddPlayersAfterInit(function(inst) --������� ���������� ������ � ����� ������� ������
	--������ ����� ������ ������� ������ �� ��.
	--���� ����� ����� ����� ������ �� ��������� �� ���� ��������� AddPlayersAfterInit.
	local data = data_players[inst.userid]
	if not data then
		data = {}
		data_players[inst.userid] = data
	end
	inst.data_player = data -----> ���� �������� ������ � ��� ��.
end)


--���������� �������, ����� ��� ������������ ���� � ������.
--���������� ��������� �� ������� ��������� � ������� �����������

--������� ���������� �������.
--������ ������� ��������� �� ���� 2 ��������� - �����1 � �����2.
--������ ����������� � ���� �������-������, � �������� - ��� ������ (� ��������)
local players_update_fns = {}
local players_update_MAXRANGE = 0 --������� ������������� ���������� (����� ����� ��������� ������������ ����).

--�������������� ��� ������ (���������� ������ 1 ��� ��� ������ ������ �����������)
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
						if dist <= players_update_MAXRANGE then --� �������� ������������ ���� �� ����� �������
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

--������� ����������� ��������� �������.
--range - ���������� ����� ��������, �� ������� ������ ����������� ������� fn ������ 0.5 ���
--�����: ����� ��� ������� (���� �� ���� �����) ���� ������� �� ������ AddPrefabPostInit, ������ ��� ����������� ������������ ������.
local function RegisterPlayersUpdate(range,fn)
	--print("RegisterPlayersUpdate")
	if #players_update_fns == 0 then
		InitializePlayersUpdate() --��������� ������������� (�.�. ����, ��� ���������)
	end
	local new_range = range*range
	players_update_fns[fn] = new_range --����� �������� � �������, ���� ������ ��� �� �������.
	if new_range > players_update_MAXRANGE then
		players_update_MAXRANGE = new_range
	end
end

--��������, ����������� (���� ���� �� ����, �����)
local function UnRegisterPlayersUpdate(fn)
	players_update_fns[fn] = nil
end


--------------------------------------------------------- Q -----------------------------------------------------------------
--����� ���������, ��� ���������� ������ ���������� ������� ����� ������������� �� ��������� �����.
local q = {


--������� ����������

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
_mods = _mods, --����, ����� ����������� ������ ���������� (������ �� ������������ ���� � ������� ��������������� �������)
static = static or {
--��������� ���������� � �������. ���������������� ���� �������. ������������ �������� ����� �������� ����� static

}, --End of static functions



--���������� ��������� ���������� �� ������ �� ������������ � ��� �������.
--member_check - �������� �������, ����� ����� ������ �����������, ��� ��� �� ����� �������.
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
			and ((not member_check) or (type(val)=="table" and val[member_check])) --�������� ��������
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
--���� ������ ������������ �������� nil, �� ���������� �� �������.
--����� ���� ���� ������ ����������� � ���, ��� �������� ���������� �� ����� ���� nil, �� ����� ��������� � ������ ��������.


--������� ������� �������������. ���������� � ������������ ����������, ��� �� ��������� ������ 0.
--[[AddPlayersPostInit = function(fn)
	for i,v in ipairs(_G.DST_CHARACTERLIST) do
		AddPrefabPostInit(v,fn)
	end
	for i,v in ipairs(_G.MODCHARACTERLIST) do
		AddPrefabPostInit(v,fn)
	end
end,--]]
--�������, �������? �������, �� ����������� ���� �������. � ��������� ��� ��� �������� �� ��� ������, �� ������� � ��� �� ����.


--������ ���������� ������!
AddPlayersPostInit = AddPlayersPostInit,
AddPlayersAfterInit = AddPlayersAfterInit,

--���������
GetWatchWorldStateFn = GetWatchWorldStateFn,
GetListener = GetListener,
SaveTimers = SaveTimers,
GetLastTimer = GetLastTimer,
GetLastTimerFn = GetLastTimerFn,
AddHookOnLastTask = AddHookOnLastTask,
AddHookOnComponent = AddHookOnComponent,
GetTags = GetTags,





--������������ ��������� ���������� �� �������� ������������ ����.
--�� ���� ������ ����� ���������� �������.
ExportLib = function(env)
	for k,v in pairs(mods.lib) do
		env[k]=v
	end
	table.insert(_mods,env) --���������� ������������ ���� ����
end,


} --����� ��������� q

--�� ���������� �������������
if TheNet:GetIsServer() then
	q.SERVER_SIDE = true
	if TheNet:GetServerIsDedicated() then
		q.DEDICATED_SIDE = true
	else
		q.CLIENT_SIDE = true --� ��� ������������ ������� ������ �������� "ismastersim".
		--������� ������������ ������ ��� ������������� ������� ����������, �� �������� � "return" ������� �� �������!!
	end
elseif TheNet:GetIsClient() then
	q.SERVER_SIDE = false
	q.CLIENT_SIDE = true
	q.ONLY_CLIENT_SIDE = true
end
--���� �� ������ ��������, ��� ������ �������� �� dedicated, �� SERVER_SIDE ����� nil (�� ���� �� ��������).


--������� ����������/�������� ����
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


if not (mods.lib and mods.lib.AddWorldPostInit) then --������ ������ � ��� ������, ���� � ������ ���� �� �������� �� �� �����.
	--������ � ����� ������. ��������� ���� ��������� �� �������� ������������� � ����� AddWorldPostInit
	AddWorldPostInit(function(inst)
		w=inst --��������� ������������� ���� (����� �������� ���-����� ���������).
		w.data_players = data_players --���� ������ ������� (������������ ������������� �������� ����).
		--��������� ����������� ����������/�������� ������ ������
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
		--������������� ����������� ���� �����.
		for i,v in ipairs(_mods) do
			v.TheWorld = inst
			v.w = inst
			v.state = inst.state --TheWorld.state
		end
	end)
end

mods.lib = q
