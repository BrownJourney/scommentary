local comms = comms;
local mPly = FindMetaTable('Player')

function mPly:getUseName()

	if self.SteamName then

		return self:SteamName()

	end

	return self:Name()

end

function comms.InitCommasData()

	if !file.IsDir('commentaries', 'DATA') then

		file.CreateDir('commentaries')

	end

	local empty = util.TableToJSON({})

	file.Write('commentaries/'..game.GetMap()..'.txt', empty)

end

function comms.LoadCommasData()

	local data = file.Read('commentaries/'..game.GetMap()..'.txt', 'DATA')

	if !isstring(data) then

		comms.InitCommasData()

	end

	data = util.JSONToTable(file.Read('commentaries/'..game.GetMap()..'.txt', 'DATA'))

	comms.data = data

	comms.UpdateComm()

end

function comms.GetData()

	if !comms.data then

		return {}

	end

	return comms.data

end

--[[-------------------------------------------------------------------------
---------------------------------------------------------------------------]]

function comms.CountPlayer(ply)

	local name, count = ply:getUseName(), 0

	for i = 1, #comms.GetData() do

		local v = comms.GetData()[i]

		if v.sender == name then

			count = count + 1

		end

	end

	return count
end

function comms.CanLeave(ply)

	local count = comms.CountPlayer(ply)

	return count < (comms.config.playerCommentsLimit or 4)

end

function comms.FindNearby(pos)

	local bestDistance, commID

	for i = 1, #comms.GetData() do

		local v = comms.GetData()[i]

		local dist = pos:Distance(v.pos)

		if !bestDistance or dist < bestDistance then

			bestDistance = dist

			commID = i

		end

	end

	if bestDistance and bestDistance < 500 then

		return true, commID

	end

	return false, commID

end

util.AddNetworkString('comms_notification')

function comms.Notify(ply, text, _type, duration)

	text = text or ''
	_type = tonumber(_type) or 0
	duration = duration or 5

	net.Start('comms_notification')

		net.WriteString(text)
		net.WriteUInt(_type, 3)
		net.WriteUInt(duration, 32)

	net.Send(ply)

end

function comms.LeaveCommentary(ply, sCommentary, iType, bAnonym, bPerm, iDays)

	if !IsValid(ply) then return end

	if !ply:CanOpenComms() then

		return

	end

	if !ply:IsCommsAdmin() then

		bPerm = false

	end

	if sCommentary:len() == 0 then

		return

	end

	if !comms.types[iType] then

		return

	end

	if #comms.GetData() > 300 then

		comms.Notify(ply, comms.lang('notify_serverlimit'))

		return

	end

	if !comms.CanLeave(ply) then

		comms.Notify(ply, comms.lang('notify_accountlimit'), 2, 6)

		return

	end

	local vPos = ply:GetPos()

	if comms.FindNearby(vPos) then

		comms.Notify(ply, comms.lang('notify_nearcomm'), 2, 6)

		return

	end

	if !ply:IsOnGround() then

		comms.Notify(ply, comms.lang('notify_ground'), 2, 5)

		return

	end

	if comms.config.takeMoney and ply.canAfford then

		if !ply:canAfford(comms.config.takeMoneyAmount) then

			comms.Notify(ply, comms.lang('notify_cantafford'), 2, 6)

			return

		end

		ply:addMoney(-comms.config.takeMoneyAmount)

	end

	iDays = (comms.config.allowCustomizeDuration or ply:IsCommsAdmin()) and math.Clamp(iDays, 1, comms.config.commentaryDuration) or comms.config.commentaryDuration

	comms.Notify(ply, comms.lang('notify_commcreation'), 1, 6)

	comms.Append(ply:getUseName(), ply:SteamID(), !bAnonym, bPerm, sCommentary, iType, vPos, iDays)

end

function comms.Save()

	local json = util.TableToJSON(comms.GetData())

	if !json then return end

	file.Write('commentaries/'..game.GetMap()..'.txt', json)

end

util.AddNetworkString('comms_new')

function comms.Append(sender, steamid, bAnon, bPerm, sCommentary, iType, vPos, iDays)

	local data = {
		sender = sender,
		sid = steamid,
		showSender = bAnon,
		text = sCommentary,
		_type = iType,
		pos = vPos,
		date = os.time(),
		removeTime = os.time() + (iDays * 86400),
		likes = 0
	}

	if bPerm then

		data.removeTime = -1

	end

	table.insert(comms.GetData(), data)

	comms.Save()

	net.Start('comms_new')

		net.WriteString(data.sender)
		net.WriteString(data.sid)
		net.WriteBool(data.showSender)
		net.WriteString(data.text)
		net.WriteUInt(data._type, 3)
		net.WriteVector(data.pos)
		net.WriteUInt(data.date, 32)
		net.WriteInt(data.removeTime, 32)

	net.Broadcast()

end

util.AddNetworkString('comms_update')


function comms.UpdateComm(ply)

	net.Start('comms_update')

		net.WriteUInt(#comms.GetData(), 32)

		for i = 1, #comms.GetData() do

			local data = comms.GetData()[i]

			net.WriteString(data.sender)
			net.WriteString(data.sid)
			net.WriteBool(data.showSender)
			net.WriteString(data.text)
			net.WriteUInt(data._type, 3)
			net.WriteVector(data.pos)
			net.WriteUInt(data.date, 32)
			net.WriteInt(data.removeTime, 32)
			net.WriteUInt(data.likes, 32)

		end

	if IsValid(ply) then

		net.Send(ply)

	else

		net.Broadcast()

	end

end

util.AddNetworkString('comms_remove')

function comms.RemoveComm(id)

	table.remove(comms.data, id)

	net.Start('comms_remove')

		net.WriteUInt(id, 32)

	net.Broadcast()
	
	comms.Save()

end

util.AddNetworkString('comms_perm')

function comms.SetPerm(id)

	comms.data[id].removeTime = -1

	net.Start('comms_perm')

		net.WriteUInt(id, 32)

	net.Broadcast()

	comms.Save()

end

util.AddNetworkString('comms_updateLikes')

function comms.LikeComment(ply)

	local bFind, iComm = comms.FindNearby(ply:GetPos())

	if !bFind then

		return

	end

	if !comms.data[iComm] then

		return

	end

	comms.data[iComm].likedPlayers = comms.data[iComm].likedPlayers or {}

	if comms.data[iComm].likedPlayers[ply:SteamID()] then

		comms.Notify(ply, comms.lang('notify_errorlike'), 2, 5)
		return

	end

	if comms.data[iComm].likes >= 25000 then

		comms.lang(ply, 'notify_likelimit', 2, 5)
		return

	end

	comms.data[iComm].likedPlayers[ply:SteamID()] = true

	comms.data[iComm].likes = comms.data[iComm].likes + 1

	comms.Notify(ply, comms.lang('notify_likecomm'), 1, 5)

	ply:DoAnimationEvent(ACT_GMOD_GESTURE_AGREE)

	net.Start('comms_updateLikes')

		net.WriteUInt(iComm, 32)

	net.Broadcast()

end

function comms.Action(ply, id, data)

	local tInfo = comms.data[id]
	if !tInfo then

		comms.Notify(ply, comms.lang('notify_undefined'):format(id), 2, 5)
		return

	end

	local tCallback = {

		[COMMS_ACTION_SETPOS] = function()

			if !ply:IsCommsAdmin() then

				return

			end

			comms.Notify(ply, comms.lang('notify_moveto'):format(id), 1, 5)

			ply:SetPos(tInfo.pos)

		end,

		[COMMS_ACTION_REMOVE] = function()

			if tInfo.sid != ply:SteamID() then

				if !ply:IsCommsAdmin() then

					return

				end

			end

			comms.RemoveComm(id)

			comms.Notify(ply, comms.lang('notify_remove'):format(id), 1, 5)

		end,

		[COMMS_ACTION_SETPERMANENT] = function()

			if !ply:IsCommsAdmin() then

				return

			end

			comms.SetPerm(id)

			comms.Notify(ply, comms.lang('notify_permanent'):format(id), 1, 5)

		end,

	}

	if !tCallback[data] then

		return

	end

	tCallback[data]()

end

function comms.StartThink()

	timer.Create('comms_Think', 5, 0, function()
		
		for k, v in ipairs(comms.GetData()) do

			if v.removeTime != -1 and os.time() >= v.removeTime then

				comms.RemoveComm(k)

			end

		end

	end)

end

--[[-------------------------------------------------------------------------
HOOKS
---------------------------------------------------------------------------]]

hook.Add('InitPostEntity', 'comms_Load', function()

	comms.LoadCommasData()

	comms.StartThink()

end)

hook.Add('PlayerInitialSpawn', 'comms_UpdateForPlayer', function(ply)

	comms.UpdateComm(ply)

end)

--[[-------------------------------------------------------------------------
NET
---------------------------------------------------------------------------]]

util.AddNetworkString('comms_Add')

net.Receive('comms_Add', function(len, ply)

	local sCommentary = net.ReadString()
	local iType = net.ReadUInt(4)
	local bAnonym = net.ReadBool()
	local bPerm = net.ReadBool()
	local iDays = net.ReadUInt(32)

	comms.LeaveCommentary(ply, sCommentary, iType, bAnonym, bPerm, iDays)

end)

util.AddNetworkString('comms_action')

net.Receive('comms_action', function(len, ply)

	local id = net.ReadUInt(32)
	local data = net.ReadUInt(3)

	comms.Action(ply, id, data)

end)

util.AddNetworkString('comms_performlike')

net.Receive('comms_performlike', function(len, ply)

	comms.LikeComment(ply)

end)