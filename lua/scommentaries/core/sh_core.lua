comms.types = {
	[1] = {mat = 'comms/check.png', color = Color(0, 204, 102)},
	[2] = {mat = 'comms/info.png', color = Color(0, 102, 204)},
	[3] = {mat = 'comms/warning.png', color = Color(200, 0, 0)},
	[4] = {mat = 'comms/chat.png', color = Color(204, 204, 0)}
}

COMMS_ACTION_SETPOS = 1
COMMS_ACTION_REMOVE = 2
COMMS_ACTION_SETPERMANENT = 3

local pMeta = FindMetaTable('Player')

--[[-------------------------------------------------------------------------
@LANG
---------------------------------------------------------------------------]]

function comms.lang(phrase)
	if !comms.language then
		comms.language = {}
	end

	return comms.language[phrase] or '#UNDEFINED'
end

--[[-------------------------------------------------------------------------
@META
---------------------------------------------------------------------------]]

function pMeta:CanOpenComms()
	local tbl = comms.config.bypassGroup
	if table.HasValue(tbl, self:GetUserGroup()) then
		return true
	else
		if comms.config.useLevelSystem then
			-- TO DO: LEVEL SUPPORT FOR LEVELLING SYSTEMS
		else
			return table.IsEmpty(tbl)
		end
	end

	return false
end

function pMeta:IsCommsAdmin()
	local tbl = comms.config.adminGroups or {}
	if table.IsEmpty(tbl) then
		return self:IsAdmin()
	end

	return table.HasValue(tbl, self:GetUserGroup())
end