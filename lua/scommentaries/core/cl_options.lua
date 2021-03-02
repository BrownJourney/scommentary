
local tConvars = {
	["cl_scomms_hud_show"] = {
		default = 1,
		desc = "Enable Simple Commentaries UI"
	},

	["cl_scomms_bind_menu"] = {
		default = comms.config.toggleButton,
		desc = "SComms menu bind"
	},

	["cl_scomms_bind_like"] = {
		default = comms.config.likeButton,
		desc = "SComms like bind"
	},
}

function comms.createConvars()

	for k, v in pairs(tConvars) do

		if GetConVar(k) == nil then

			CreateClientConVar(k, v.default, true, false, v.desc)

		end

	end

end

comms.createConvars()

function comms.addSpawnmenuVGUI()

	local cvar_bind_menu = GetConVar("cl_scomms_bind_menu")
	local cvar_bind_like = GetConVar("cl_scomms_bind_like")

	spawnmenu.AddToolMenuOption("Utilities", "Simple Commentaries", "SCommOptions", "#Options", "", "", function(panel)

		panel:Help("Simple Commentaries options")

		panel:CheckBox("Enable drawing comments", "cl_scomms_hud_show")

		local menuBind = vgui.Create("DBinder")
		menuBind:SetValue(cvar_bind_menu:GetInt())
		menuBind.OnChange = function(self, iNum)

			cvar_bind_menu:SetInt(iNum)

		end

		local likeBind = vgui.Create("DBinder")
		likeBind:SetValue(cvar_bind_like:GetInt())
		likeBind.OnChange = function(self, iNum)

			cvar_bind_like:SetInt(iNum)

		end

		panel:Help("Menu toggle button")
		panel:AddItem(menuBind)
		panel:Help("Like button")
		panel:AddItem(likeBind)

	end)

end

--[[-------------------------------------------------------------------------
CONCOMMAND
---------------------------------------------------------------------------]]

concommand.Add("cl_scomms_reset", function()

	for k, v in pairs(tConvars) do

		local cvar = GetConVar(k)

		if !cvar then

			continue

		end

		cvar:SetInt(v.default)

	end

	print('[SComms] Successfully reset all settings!')

end)

--[[-------------------------------------------------------------------------
HOOK
---------------------------------------------------------------------------]]

hook.Add('PopulateToolMenu', 'comms_addSpawnmenuVGUI', comms.addSpawnmenuVGUI)