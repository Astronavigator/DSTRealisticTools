local PopupDialogScreen 	= require("screens/popupdialog")
local LobbyScreen	 		= require("screens/lobbyscreen")
local Text 					= require "widgets/text"

local _MOTDScreen = nil

function MOTDMessage()
	local text = _MOTDScreen.inst.welcome_message

	local motd_message = PopupDialogScreen(_MOTDScreen.inst.welcome_message_title, text, {{text="Okay!", cb = function() TheFrontEnd:PopScreen() end}} )
	TheFrontEnd:PushScreen( motd_message )
end

local OnPlayerActivated = function()
	MOTDMessage()
	--print("Player Activated")
end


local MOTDScreen = Class(function(self, inst)
	_MOTDScreen = self
	self.inst = inst
	
	self.inst:ListenForEvent("playeractivated", OnPlayerActivated, TheWorld)
	
	self.inst:StartUpdatingComponent(self)
end)

return MOTDScreen