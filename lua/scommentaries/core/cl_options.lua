
if GetConVar("cl_scomms_hud_show") == nil then
	CreateClientConVar("cl_scomms_hud_show", 1, true, false, "Enable Simple Commentaries UI")
end

if GetConVar("cl_scomms_bind_menu") == nil then
	CreateClientConVar("cl_scomms_bind_menu", comms.config.toggleButton, true, false, "SComms menu bind")
end

if GetConVar("cl_scomms_bind_like") == nil then
	CreateClientConVar("cl_scomms_bind_like", comms.config.likeButton, true, false, "SComms like bind")
end

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
---------------------------------------------------------------------------]]

hook.Add('PopulateToolMenu', 'comms_addSpawnmenuVGUI', comms.addSpawnmenuVGUI)