local comms = comms;
comms.blur = Material('pp/blurscreen')
comms.mat = Material('comms/icon.png')
comms.like = Material('comms/thumb-up.png')
comms.data = comms.data or {}

COMMS_MENU_CATEGORIES = 0
COMMS_MENU_CREATE = 1
COMMS_MENU_CONTROL = 2
COMMS_MENU_LOGS = 3

comms.title = {

	[COMMS_MENU_CATEGORIES] = {txt = comms.lang('category_cats')},

	[COMMS_MENU_CREATE] = {txt = comms.lang('category_create'), drawFunc = function(w, h, alpha)

		draw.SimpleText(comms.lang('text_self'), 'Bj_Commentary_Default', 5, h * 0.1, Color(255, 255, 255, 255 * alpha))

		draw.SimpleText(comms.lang('text_type'), 'Bj_Commentary_Default', 5, h * 0.45, Color(255, 255, 255, 255 * alpha))

		if comms.config.allowCustomizeDuration then

			draw.SimpleText(comms.lang('text_duration'), 'Bj_Commentary_Default', 5, h * 0.35, Color(255, 255, 255, 255 * alpha))

		end

	end},

	[COMMS_MENU_CONTROL] = {txt = comms.lang('category_control'), drawFunc = function(w, h, alpha) end},

	[COMMS_MENU_LOGS] = {txt = comms.lang('category_logs'), drawFunc = function(w, h, alpha) end, admin = true}

}

--[[-------------------------------------------------------------------------
FONTS
---------------------------------------------------------------------------]]

surface.CreateFont( 'Bj_Commentary_Smaller', {
	font = comms.config.fontName,
	extended = true,
	size = 17,
	weight = 200,
} )


surface.CreateFont( 'Bj_Commentary_Small', {
	font = comms.config.fontName,
	extended = true,
	size = 20,
	weight = 200,
} )

surface.CreateFont( 'Bj_Commentary_Notify', {
	font = comms.config.fontName,
	extended = true,
	size = 28,
	weight = 200,
} )

surface.CreateFont( 'Bj_Commentary_Default', {
	font = comms.config.fontName,
	extended = true,
	size = 32,
	weight = 300,
} )

surface.CreateFont( 'Bj_Commentary_Large', {
	font = comms.config.fontName,
	extended = true,
	size = 40,
	weight = 400,
} )

--[[-------------------------------------------------------------------------
EXTENDED FUNCTIONALITY
---------------------------------------------------------------------------]]

function surface.DrawParsed(text, font, x, y, colour, alignx, aligny)

	local r, g, b = colour.r, colour.g, colour.b

	local a

	if colour.a then

		a = math.Round(colour.a)

	else
		a = 255

	end

	local parsed = markup.Parse( "<font="..font.."><colour="..r..", "..g..", "..b..", "..a..">"..text.."</colour></font>" )

	if colour.a then

		parsed:Draw(x, y, alignx, aligny, colour.a)

	else
		parsed:Draw(x, y, alignx, aligny)

	end

end

--[[-------------------------------------------------------------------------
COMMENTARY DRAW
---------------------------------------------------------------------------]]

function comms.ConvertToDate(time)

	return os.date('%d/%m/%Y', time)

end

function comms.ConvertTimeLeft(time)

	local time_left = time - os.time()

	local weeks_left = math.floor(time_left / 6048800)

	time_left = math.Clamp(time_left - weeks_left * 6048800, 0, 6048800 * 2)

	local days_left = math.floor(time_left / 86400)

	local hours_left = math.floor(time_left / 3600)

	local minutes_left = math.floor(time_left / 60)

	local total = days_left..' '..comms.lang('text_days')

	if days_left == 0 then

		total = hours_left..' '..comms.lang('text_hours')

	end

	if hours_left == 0 then

		total = minutes_left..' '..comms.lang('text_minutes')

	end

	if time == -1 then

		total = comms.lang('text_infinite')

	end

	return total

end

function comms.Draw()


	if !GetConVar('cl_scomms_hud_show'):GetBool() then

		return

	end

	LocalPlayer().CanLike = false

	for i = 1, #comms.data do

		local v = comms.data[i]

		if !v.date then continue end

		local dist = LocalPlayer():GetPos():DistToSqr(v.pos)

		local font_default, font_big, font_small = 'Bj_Commentary_Default', 'Bj_Commentary_Large', 'Bj_Commentary_Small'

		local offset = Vector( 0, 0, 40 )

		local ang = LocalPlayer():EyeAngles()

		local pos = v.pos + offset + ang:Up()

		ang:RotateAroundAxis( ang:Forward(), 90 )

		ang:RotateAroundAxis( ang:Right(), 90 )

		if dist > comms.config.drawDistance then

			continue

		end

		local alpha = -(dist - comms.config.drawDistance / 4) / (comms.config.drawDistance / 4)

		local comMat = Material(comms.types[v._type or 1].mat)
		local comColor = comms.types[v._type or 1].color

		if alpha >= 0.9 then

			LocalPlayer().CanLike = true

		end
		
		cam.Start3D2D( pos, Angle(0, ang.y, 90), 0.05 * comms.config.sizeMultiplier )

			local sender

			if v.showSender then

				sender = v.sender

			else

				sender = comms.lang('text_unknown'):upper()

			end

			if LocalPlayer():IsCommsAdmin() then

				sender = sender .. ' (' .. v.sid .. ')'

			end

			surface.SetFont(font_big)

			local w1, h1 = surface.GetTextSize(sender, font_big)
			
			surface.SetMaterial(comMat)

			surface.SetDrawColor(255, 255, 255, 255 * alpha)

			surface.DrawTexturedRect(-88, 0, 64, 64)

			draw.SimpleTextOutlined(sender, font_big, 5, 0 - h1, Color(comColor.r, comColor.g, comColor.b, 255 * alpha), nil, nil, 1, Color(0, 0, 0, 50 * alpha))

			local spl = v.text:Split(' ')
			local str = ''
			for i = 1, #spl do

				local sep = ' '

				if i % 8 == 0 and i != #spl then

					sep = '\n'

				end

				str = str .. spl[i] .. sep

			end

			surface.SetFont(font_default)

			local wide, height = surface.GetTextSize(str)

			local iTotalHeight = height

			surface.DrawParsed(str, font_default, 5, 0, Color(255, 255, 255, 255 * alpha))

			local sDate = comms.ConvertToDate(v.date)

			surface.SetFont(font_small)

			local wi, he = surface.GetTextSize(sDate)

			local sTotal = comms.ConvertTimeLeft(v.removeTime)

			local iLikeHeight

			if v.removeTime != -1 then

				draw.SimpleText(sDate, font_small, 5, iTotalHeight + 7, Color(255, 255, 255, 255 * alpha))

				draw.SimpleText(comms.lang('text_removing'):format(sTotal), font_small, 5, iTotalHeight + he + 5, Color(255, 255, 255, 255 * alpha), nil, nil, 1, Color(0, 0, 0))

				iLikeHeight = iTotalHeight + he + 30

			else

				iLikeHeight = iTotalHeight + he

			end

			if comms.config.enableLikes then

				surface.SetMaterial(comms.like)

				surface.SetDrawColor(255, 255, 255, 255 * alpha)

				surface.DrawTexturedRect(5, iLikeHeight, 32, 32)

				draw.SimpleText(v.likes, font_big, 40, iLikeHeight, Color(255, 255, 255, 255 * alpha))

			end

			local designed_wide 

			if w1 > wide then

				designed_wide = w1

			else

				designed_wide = wide

			end

			surface.SetDrawColor(comColor.r, comColor.g, comColor.b, alpha * 255)

			surface.DrawLine(0, 0, designed_wide, 0)

			surface.DrawLine(0, iTotalHeight + 5, designed_wide, iTotalHeight + 5)

			surface.DrawLine(0, 0, 0, 1300)

		cam.End3D2D()

	end

end

comms.DrawAlpha = 0

function comms.LikeHUD()

	local w, h = ScrW(), ScrH()

	if !LocalPlayer().CanLike then

		comms.DrawAlpha = math.max(comms.DrawAlpha - FrameTime() * 300, 0)
	
	else

		comms.DrawAlpha = math.min(comms.DrawAlpha + FrameTime() * 300, 255)

	end

	draw.SimpleText(comms.lang('text_buttonlike'):format(input.GetKeyName(GetConVar('cl_scomms_bind_like'):GetInt()):upper()), 'Bj_Commentary_Small', w / 2, h * 0.8 + comms.config.likeHUDOffset, Color(0, 204, 204, comms.DrawAlpha), TEXT_ALIGN_CENTER)

end

function comms.addLike()

	net.Start('comms_performlike')

	net.SendToServer()

end

function comms.KeyPress(pl, key)

	if pl != LocalPlayer() then

		return

	end

	if key == GetConVar('cl_scomms_bind_menu'):GetInt() then

		comms.menuPopup()

	elseif key == GetConVar('cl_scomms_bind_like'):GetInt() then

		comms.addLike()

	end

end

function comms.DrawBlur( p, a, d, alpha )

	local x, y = p:LocalToScreen(sx or 0, sy or 0)

	surface.SetDrawColor( 255, 255, 255, alpha or 255 )

	surface.SetMaterial( comms.blur )

	for i = 1, d do

		comms.blur:SetFloat( '$blur', (i / d ) * ( a ) )

		comms.blur:Recompute()

		render.UpdateScreenEffectTexture()

		surface.DrawTexturedRect( x * -1, y * -1, ScrW() - (sw or 0), ScrH() - (sh or 0) )

	end

end

local function buttonHover(element, text, color)

	element:SetText('')
	element.alpha = 10
	element.Paint = function(self, w, h)

		local clr = color_white
		local speed = 400 / (1 / FrameTime())
		local minAlpha = 10

		if self.hovered then

			self.alpha = self.alpha + speed
			clr = color_black
			if self.alpha > 255 then self.alpha = 255 end

		else

			self.alpha = self.alpha - speed
			if self.alpha < color.a then self.alpha = color.a end

		end

		draw.RoundedBox(0, 0, 0, w, h, Color(color.r, color.g, color.b, self.alpha))
		draw.SimpleText(text, 'Bj_Commentary_Default', w / 2, h / 2, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	end
	element.OnCursorExited = function(self) self.hovered = false end
	element.OnCursorEntered = function(self) self.hovered = true end

end

function comms.menuPopup()

	if !LocalPlayer():CanOpenComms() then

		return

	end

	if IsValid(comms.mPanel) then

		return

	end

	comms.selectedType = -1

	local w, h = ScrW(), ScrH()

	local mPanel = vgui.Create('DFrame')
	comms.mPanel = mPanel
	mPanel:SetSize(w, h)
	mPanel:SetTitle('')
	mPanel:SetDraggable(false)
	mPanel:ShowCloseButton(false)
	mPanel:MakePopup()
	mPanel:SetBackgroundBlur(true)
	mPanel.alpha = 0
	mPanel.Think = function(self)

		self.alpha = math.Clamp(self.alpha + FrameTime() * 3, 0, 1)

	end
	mPanel.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150 * self.alpha))
		comms.DrawBlur( self, 1, 1, 255 * self.alpha )
	end

	local ctaWindow = vgui.Create('DPanel', mPanel)
	comms.ctaWindow = ctaWindow
	ctaWindow:SetSize(w * 0.25, h * 0.7)
	local cx, cy = w / 2 - ctaWindow:GetWide() / 2, h / 2 - ctaWindow:GetTall() / 2
	ctaWindow:SetPos(cx, cy - w * 0.1)
	ctaWindow:MoveTo(cx, cy, 0.5, 0, 0.5)
	ctaWindow.Paint = function(self, w, h)

		local alpha = self:GetParent().alpha

		draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 250 * alpha))
		surface.SetDrawColor(200, 200, 200, 100)
		surface.DrawOutlinedRect(0, 0, w, h)

		local txt, drawFunc = '', function() end

		if comms.title[comms.section] then

			txt = comms.title[comms.section].txt or ''
			drawFunc = comms.title[comms.section].drawFunc or function() end

		end

		draw.SimpleText(txt, 'Bj_Commentary_Default', 50, 6, Color(255, 255, 255, 255 * alpha))


		drawFunc(w, h, alpha)
	end

	local bReturn = vgui.Create('DButton', ctaWindow)
	bReturn:SetText('')
	bReturn:SetSize(32, 32)
	bReturn:SetPos(6, 6)
	bReturn.skippable = true
	bReturn.DoClick = function(self)

		comms.OpenSection(COMMS_MENU_CATEGORIES)

	end
	bReturn.Paint = function(self, w, h)

		surface.SetMaterial(comms.mat)
		surface.SetDrawColor(255, 255, 255)
		surface.DrawTexturedRect(0, 0, w, h)

	end

	local bClose = vgui.Create('DButton', ctaWindow)
	bClose:SetSize(w * 0.03, h * 0.03)
	bClose:SetPos(ctaWindow:GetWide() - bClose:GetWide() - 1, 1)
	bClose:SetText('')
	bClose.alpha = 0
	bClose.skippable = true
	bClose.DoClick = function(self)

		mPanel:Remove()

	end

	buttonHover(bClose, 'x', Color(232, 60, 8, 0))

	comms.OpenSection(COMMS_MENU_CATEGORIES)

end

function comms.OpenSection(section, bData)

	local w, h = ScrW(), ScrH()

	local ctaWindow = comms.ctaWindow

	if !IsValid(ctaWindow) then

		return

	end	

	for k, v in pairs(ctaWindow:GetChildren()) do

		if v.skippable then continue end

		v:Remove()

	end

	local function handleData(data)

		if IsValid(comms.scroll) then

			comms.scroll:Remove()


		else

			local inputSteamid = vgui.Create('DTextEntry', ctaWindow)
			inputSteamid:SetSize(ctaWindow:GetWide() - 10, ctaWindow:GetTall() * 0.05)
			inputSteamid:SetPos(5, h * 0.06)
			inputSteamid:SetText('')
			inputSteamid.OnChange = function(self)

				local value = self:GetText()
				local tFiltered = {}
				for i = 1, #comms.data do

					if !comms.data[i].sid:find(value) then
						continue
					end

					tFiltered[i] = comms.data[i]

				end

				handleData(tFiltered)

			end

		end

		local scroll = vgui.Create('DScrollPanel', ctaWindow)
		comms.scroll = scroll
		scroll:SetSize(ctaWindow:GetWide(), ctaWindow:GetTall() - h * 0.102)
		scroll:SetPos(0, h * 0.1)

		local sbar = scroll:GetVBar()
		sbar:SetWide(5)

		function sbar:Paint(w, h)
		end

		function sbar.btnUp:Paint(w, h)
		end

		function sbar.btnDown:Paint(w, h)
		end

		function sbar.btnGrip:Paint(w, h)

			draw.RoundedBox(0, 0, 0, w, h, color_white)

		end

		for k, v in pairs(data) do

			local bCommentary = vgui.Create('DButton', scroll)
			bCommentary:SetText('')
			bCommentary:Dock(TOP)
			bCommentary:DockMargin(5, 5, 5, 5)
			bCommentary:SetTall(ctaWindow:GetTall() * 0.08)
			bCommentary.progress = 0
			local bCommentary_Color = Color(100, 100, 100, 10)
			local bUnderline_Color = Color(30, 30, 30, 255)
			bCommentary.DoClick = function(self)

				comms.OpenCommentary(k)

			end
			bCommentary.Paint = function(self, w, h)

				draw.RoundedBox(0, 0, 0, w * 0.1, h, bCommentary_Color)
				draw.SimpleText('#' .. k, 'Bj_Commentary_Smaller', 5, h / 2, color_white, nil, TEXT_ALIGN_CENTER)

				draw.RoundedBox(0, w * 0.11, 0, w * 0.5, h, bCommentary_Color)
				draw.SimpleText(v.sid, 'Bj_Commentary_Smaller', w * 0.12, h / 2, color_white, nil, TEXT_ALIGN_CENTER)

				draw.RoundedBox(0, w * 0.62, 0, w * 0.38, h, bCommentary_Color)
				draw.SimpleText(v.sender, 'Bj_Commentary_Smaller', w * 0.63, h / 2, color_white, nil, TEXT_ALIGN_CENTER)

				draw.RoundedBox(0, 0, h - 2, w, 2, bUnderline_Color)


			end

		end

	end

	comms.section = section

	local callback = {
		[COMMS_MENU_CATEGORIES] = function()

			for k, v in pairs(comms.title) do

				if k == COMMS_MENU_CATEGORIES then
					continue
				end

				if v.admim then

					if !LocalPlayer():IsCommsAdmin() then

						continue

					end

				end

				local iTop = 5

				if k == 1 then

					iTop = h * 0.05

				end

				local bCategory = vgui.Create('DButton', ctaWindow)
				bCategory:SetText('')
				bCategory:Dock(TOP)
				bCategory:DockMargin(5, iTop, 5, 5)
				bCategory:SetTall(ctaWindow:GetTall() * 0.2)
				bCategory.progress = 0
				local bCategory_Color = Color(100, 100, 100, 10)
				local bUnderline_Color = Color(30, 30, 30, 255)
				bCategory.DoClick = function(self)

					comms.OpenSection(k)

				end
				bCategory.Paint = function(self, w, h)

					draw.RoundedBox(0, 0, 0, w, h, bCategory_Color)

					draw.RoundedBox(0, 0, h - 2, w, 2, bUnderline_Color)
					draw.RoundedBox(0, 0, h - 2, w * self.progress, 2, color_white)

					local iSpeed = FrameTime() * 5
					if self.hover then
						self.progress = math.min(self.progress + iSpeed, 1)
					else
						self.progress = math.max(self.progress - iSpeed, 0)
					end

					draw.SimpleText(v.txt or '', 'Bj_Commentary_Default', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				end

				bCategory.OnCursorEntered = function(self) self.hover = true end
				bCategory.OnCursorExited = function(self) self.hover = false end

			end

		end,

		[COMMS_MENU_CREATE] = function()

			local inputText = vgui.Create('DTextEntry', ctaWindow)
			inputText:SetText('')
			inputText:SetPos(5, ctaWindow:GetTall() * 0.15)
			inputText:SetSize(ctaWindow:GetWide() - 10, ctaWindow:GetTall() * 0.3)
			inputText:SetMultiline(true)
			inputText:SetFont('Bj_Commentary_Small')
			inputText:SetDrawLanguageID(false)
			inputText:SetAllowNonAsciiCharacters( true )

			local iDays = comms.config.commentaryDuration

			if comms.config.allowCustomizeDuration or LocalPlayer():IsCommsAdmin() then

				inputText:SetTall(ctaWindow:GetTall() * 0.2)

				local labelDays = vgui.Create('DLabel', ctaWindow)
				labelDays:SetPos(5, ctaWindow:GetTall() * 0.4)
				labelDays:SetFont('Bj_Commentary_Small')
				labelDays:SetText( iDays .. ' ' .. comms.lang('text_days'))
				labelDays:SetTextColor(color_white)
				labelDays:SizeToContents()

				local function createDayMover(text, value, x, y)

					local bDayMover = vgui.Create('DButton', ctaWindow)
					bDayMover:SetSize(ctaWindow:GetWide() * 0.1, ctaWindow:GetTall() * 0.035)
					bDayMover:SetPos(x, y)
					bDayMover:SetText('')
					bDayMover.DoClick = function(self, w, h)

						iDays = math.Clamp(iDays + value, 1, comms.config.commentaryDuration)

						labelDays:SetText(iDays .. ' ' .. comms.lang('text_days'))

					end
					bDayMover.Paint = function(self, w, h)

						draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100, 20))

						draw.SimpleText(text, 'Bj_Commentary_Small', w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

					end

				end

				createDayMover('<', -1, ctaWindow:GetWide() * 0.2, ctaWindow:GetTall() * 0.4)
				createDayMover('>', 1, ctaWindow:GetWide() * 0.32, ctaWindow:GetTall() * 0.4)

			end

			local gridTypes = vgui.Create('DGrid', ctaWindow)
			gridTypes:SetPos(5, ctaWindow:GetTall() * 0.5)
			gridTypes:SetCols(4)
			gridTypes:SetColWide(ctaWindow:GetWide() * 0.25 - 5)
			gridTypes:SetRowHeight(72)

			for k, v in ipairs(comms.types) do

				local bType = vgui.Create('DButton')
				bType:SetText('')
				bType:SetSize(72, 72)
				bType.alpha = 0
				local bMat = Material(v.mat)
				bType.Paint = function(self, w, h)

					surface.SetMaterial(bMat)
					surface.SetDrawColor(255, 255, 255)
					surface.DrawTexturedRect(w / 2 - 32, h / 2 - 32, 64, 64)

					if self.hover or self.selected then

						self.alpha = math.Clamp(self.alpha + FrameTime() * 300, 0,  255)

					else

						self.alpha = math.Clamp(self.alpha - FrameTime() * 500, 0, 255)

					end

					draw.RoundedBox(0, 0, h - 3, w, 3, Color(255, 255, 255, self.alpha))

				end
				bType.OnCursorEntered = function(self) self.hover = true end
				bType.OnCursorExited = function(self) self.hover = false end
				bType.DoClick = function(self)

					for k, v in pairs(gridTypes:GetChildren()) do
						
						v.selected = false

					end

					comms.selectedType = k

					self.selected = true

					comms:AddSimple(comms.lang('notify_changedtype'), 1, 5)

				end
				gridTypes:AddItem(bType)

			end

			local cAnonymously = vgui.Create('DCheckBox', ctaWindow)
			cAnonymously:SetSize(ctaWindow:GetWide(), ctaWindow:GetTall() * 0.08)
			cAnonymously:SetPos(5, ctaWindow:GetTall() * 0.66)
			cAnonymously:SetValue()

			cAnonymously.Paint = function(self, w, h)
				local alpha = 255
				draw.RoundedBox(0, 0, 0, 20, 20, Color(0, 0, 0, alpha - 150))

				if self:GetChecked() == true then
					draw.RoundedBox(0, 0, 0, 20, 20, Color(184, 134, 11, alpha))
				end

				draw.SimpleText(comms.lang('check_anon'), 'Bj_Commentary_Small', 30, 0, Color(255, 255, 255, alpha))

				surface.SetDrawColor(200, 200, 200, alpha - 155)
				surface.DrawOutlinedRect(0, 0, 20, 20)
			end

			local cPermanent

			if LocalPlayer():IsCommsAdmin() then

				cPermanent = vgui.Create('DCheckBox', ctaWindow)
				cPermanent:SetSize(ctaWindow:GetWide(), ctaWindow:GetTall() * 0.08)
				cPermanent:SetPos(5, ctaWindow:GetTall() * 0.74)
				cPermanent:SetValue()

				cPermanent.Paint = function(self, w, h)
					local alpha = 255
					draw.RoundedBox(0, 0, 0, 20, 20, Color(0, 0, 0, alpha - 150))

					if self:GetChecked() == true then
						draw.RoundedBox(0, 0, 0, 20, 20, Color(184, 134, 11, alpha))
					end

					draw.SimpleText(comms.lang('check_perm'), 'Bj_Commentary_Small', 30, 0, Color(255, 255, 255, alpha))

					surface.SetDrawColor(200, 200, 200, alpha - 155)
					surface.DrawOutlinedRect(0, 0, 20, 20)
				end

			end

			local bApply = vgui.Create('DButton', ctaWindow)
			bApply:SetText('')
			bApply:SetSize(ctaWindow:GetWide() * 0.9, ctaWindow:GetTall() * 0.15)
			bApply:SetPos(ctaWindow:GetWide() / 2 - bApply:GetWide() / 2, ctaWindow:GetTall() * 0.8)
			bApply.DoClick = function(self)

				local cText = inputText:GetText()

				if cText:len() == 0 then

					comms:AddSimple(comms.lang('notify_fieldempty'), 2, 5)
					return

				end

				if utf8.len(cText) < 10 then

					comms:AddSimple(comms.lang('notify_fieldsmall'), 2, 5)
					return

				end

				if utf8.len(cText) > 200 then

					comms:AddSimple(comms.lang('notify_fieldlarge'), 2, 5)
					return

				end

				if comms.selectedType == -1 then

					comms:AddSimple(comms.lang('notify_niltype'), 2, 5)
					return

				end

				local bPerm = IsValid(cPermanent) and cPermanent:GetChecked() or false

				net.Start('comms_Add')
				
					net.WriteString(cText)
					net.WriteUInt(comms.selectedType, 4)
					net.WriteBool(cAnonymously:GetChecked())
					net.WriteBool(bPerm)
					net.WriteUInt(iDays, 32)

				net.SendToServer()

				comms.mPanel:Remove()

			end
			buttonHover(bApply, comms.lang('text_submit'), Color(76, 153, 0, 10))

		end,

		[COMMS_MENU_CONTROL] = function()

			local tFiltered = {}

			for i = 1, #comms.data do

				if comms.data[i].sid != LocalPlayer():SteamID() and comms.data[i].sid != 'STEAM_0:0:0' then

					continue

				end

				tFiltered[i] = comms.data[i]

			end

			handleData(tFiltered)

		end,

		[COMMS_MENU_LOGS] = function()

			handleData(comms.data)

		end
	}

	if !callback[section] then

		return

	end

	callback[section]()

end

function comms.OpenCommentary(id)

	local w, h = ScrW(), ScrH()

	local ctaWindow = comms.ctaWindow

	local tData = comms.data[id]

	if !tData then

		return

	end

	for k, v in pairs(ctaWindow:GetChildren()) do

		if v.skippable then continue end

		v:Remove()

	end

	local sAnonymous = tData.showSender and comms.lang('text_no') or comms.lang('text_yes')
	local sWrap = '\n\n'

	local lTextData = vgui.Create('DLabel', ctaWindow)
	lTextData:SetWide(ctaWindow:GetWide() - 10)
	lTextData:SetPos(5, h * 0.05 + 5)
	lTextData:SetWrap(true)
	lTextData:SetAutoStretchVertical(true)
	lTextData:SetTextColor(color_white)
	lTextData:SetFont('Bj_Commentary_Small')
	lTextData:SetText(string.format('%s: ' .. tData.sender .. sWrap .. 'SteamID: ' .. tData.sid .. sWrap .. '%s: ' .. tData.likes .. sWrap.. '%s: ' .. sAnonymous .. sWrap .. '%s: ' .. comms.ConvertToDate(tData.date) .. sWrap .. '%s: ' .. comms.ConvertTimeLeft(tData.removeTime) .. sWrap .. '%s: ' .. tData.text, comms.lang('text_creator'), comms.lang('text_likes'), comms.lang('text_anon'), comms.lang('text_datecreation'), comms.lang('text_timetoremove'), comms.lang('text_comm')))

	local bRemove = vgui.Create('DButton', ctaWindow)
	bRemove:Dock(BOTTOM)
	bRemove:DockMargin(5, 5, 5, 5)
	bRemove:SetTall(ctaWindow:GetTall() * 0.08)
	bRemove.DoClick = function(self)

		local dMenu = vgui.Create('DMenu')

		dMenu:AddOption( comms.lang('text_submit'), function()  

			comms.bRemoved = true

			net.Start('comms_action')
				net.WriteUInt(id, 32)
				net.WriteUInt(COMMS_ACTION_REMOVE, 3)
			net.SendToServer()

		end)

		dMenu:AddOption( comms.lang('text_cancel'), function() end )
		dMenu:Open()
		dMenu:SetPos(gui.MouseX(), gui.MouseY())

	end
	buttonHover(bRemove, comms.lang('text_remove'), Color(232, 60, 8, 10))

	if LocalPlayer():IsCommsAdmin() then

		if tData.removeTime != -1 then

			local bSetPermanent = vgui.Create('DButton', ctaWindow)
			bSetPermanent:Dock(BOTTOM)
			bSetPermanent:DockMargin(5, 5, 5, 5)
			bSetPermanent:SetTall(ctaWindow:GetTall() * 0.08)
			bSetPermanent.DoClick = function(self)

				net.Start('comms_action')
					net.WriteUInt(id, 32)
					net.WriteUInt(COMMS_ACTION_SETPERMANENT, 3)
				net.SendToServer()

				bSetPermanent:Remove()

			end
			buttonHover(bSetPermanent, comms.lang('text_permanent'), Color(128, 128, 128, 10))

		end

		local bSetPos = vgui.Create('DButton', ctaWindow)
		bSetPos:Dock(BOTTOM)
		bSetPos:DockMargin(5, 5, 5, 5)
		bSetPos:SetTall(ctaWindow:GetTall() * 0.08)
		bSetPos.DoClick = function(self)

			net.Start('comms_action')
				net.WriteUInt(id, 32)
				net.WriteUInt(COMMS_ACTION_SETPOS, 3)
			net.SendToServer()

		end
		buttonHover(bSetPos, comms.lang('text_moveto'), Color(128, 128, 128, 10))

		local bCopy = vgui.Create('DButton', ctaWindow)
		bCopy:Dock(BOTTOM)
		bCopy:DockMargin(5, 5, 5, 5)
		bCopy:SetTall(ctaWindow:GetTall() * 0.08)
		bCopy.DoClick = function(self)

			SetClipboardText(tData.sid)

			comms:AddSimple(comms.lang('notify_copysid'), 1, 5)

		end
		buttonHover(bCopy, comms.lang('text_copysid'), Color(128, 128, 128, 10))

	end


end

--[[-------------------------------------------------------------------------
NOTIFICATIONS
---------------------------------------------------------------------------]]

comms.Notifications = comms.Notifications or {}
comms.notifyFont = 'Bj_Commentary_Notify'

comms.Colors = {
	[1] = Color(102, 204, 0),
	[2] = Color(153, 0, 0),
	[3] = Color(204, 204, 0)
}

function comms.paintFunction(panel, data, w, h, uniqid)

	local _type, height = data._type, data.height
	local font = comms.notifyFont
	
	if !panel.alpha then
		panel.alpha = 0
	end


	if panel.removing then

		panel.alpha = panel.alpha - FrameTime() * 1000

		if panel.alpha <= 0 then

			panel:Remove()

		end

	else

		panel.alpha = math.Clamp(panel.alpha + FrameTime() * 1000, 0, 255)

	end

	if height[1] == '' then return end

	local clr = comms.Colors[_type] or Color(0, 0, 0)

	draw.RoundedBox(0, 0, 0, w, h, Color(clr.r, clr.g, clr.b, panel.alpha))
	comms.DrawBlur(panel, 2, 2, panel.alpha)
	draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, math.Clamp(panel.alpha, 0, 240)))

	surface.SetFont(font)

	for i = 1, #height do

		local id = uniqid..i

		local text = height[i]

		local wid, hei = surface.GetTextSize(text, font)

		draw.SimpleText(text, font, 10, 5 + ((i - 1) * hei), Color(255, 255, 255, panel.alpha))

	end

	surface.SetDrawColor(200, 200, 200, math.Clamp(panel.alpha, 0, 100) )

	surface.DrawOutlinedRect(0, 0, w, h)

end

function comms:AddSimple(text, type, dur, pan)
	local info = {text = text, type = type, duration = dur}
	comms:AddNotify(info, pan)
end

function comms:AddNotify(info, panel)

	local w, h = ScrW(), ScrH()

	comms.BasePosition = {x = w - 30, y = h - 20}

	local font = comms.notifyFont

	panel = panel or nil

	local text = info.text
	local _type = info.type
	local dur = info.duration

	MsgC(Color(255, 255, 255), text..'\n')

	surface.SetFont(font)

	local txt = string.Split(text, '\n')

	local wid, hei = surface.GetTextSize(txt[1], font)

	local width, heidsa = surface.GetTextSize(text, font)

	local height = string.Split(text, '\n')

	local nPanel = vgui.Create('DPanel', panel)

	self.NextSound = CurTime() + 0.5

	local tall = 5 + hei * #height + hei / 2

	if tall < 40 then

		tall = 40

	end

	nPanel:SetSize(width + 20, tall)
	nPanel:SetDrawOnTop(true)

	local baseposy

	if #self.Notifications != 0 then

		local size = self.Notifications[#self.Notifications]['size']

		local posy = self.Notifications[#self.Notifications].posy

		baseposy = posy - size

		nPanel:SetPos(self.BasePosition.x - nPanel:GetWide(), baseposy - nPanel:GetTall())

	else

		baseposy = self.BasePosition.y

		nPanel:SetPos(self.BasePosition.x - nPanel:GetWide(), self.BasePosition.y -  nPanel:GetTall())

	end

	local nInfo = {}

	nInfo['panels'] = {nPanel, mPanel}
	nInfo['posy'] = baseposy
	nInfo['size'] = nPanel:GetTall()
	nInfo['uniq_id'] = math.random(1, 99999999)..'_kbz_'..math.random(1, 99999999)

	table.insert(self.Notifications, nInfo)

	local data = {_type = _type, height = height}

	function nPanel:Paint(w, h)

		comms.paintFunction(self, data, w, h, nInfo['uniq_id'])

	end

	timer.Simple(dur, function()

		for k, v in pairs(nInfo['panels']) do

			if IsValid(v) then

				v.removing = true

			end

		end

		for k, v in pairs(self.Notifications) do

			if v.uniq_id == nInfo['uniq_id'] then

				table.remove(self.Notifications, k)

				break

			end

		end

		for k, v in pairs(self.Notifications) do

			if #self.Notifications > 0 then

				if k != 1 then

					local size = self.Notifications[k - 1]['size']

					local posy = self.Notifications[k - 1].posy

					local baseposy = posy - size

					self.Notifications[k].posy = baseposy

					for _, panel in pairs(self.Notifications[k].panels) do

						if IsValid(panel) then

							panel:MoveTo(self.BasePosition.x - panel:GetWide(), baseposy - panel:GetTall(), .5)

						end

					end
				else

					self.Notifications[k].posy = self.BasePosition.y

					for _, panel in pairs(self.Notifications[k].panels) do

						if IsValid(panel) then

							panel:MoveTo(self.BasePosition.x - panel:GetWide(), self.BasePosition.y - panel:GetTall(), .5)

						end

					end

				end

			end

		end

	end)

end

net.Receive('comms_notification', function()

	local tbl = {
		text = net.ReadString(),
		type = net.ReadUInt(3),
		duration = net.ReadUInt(32)
	}

	comms:AddNotify(tbl)

end)


--[[-------------------------------------------------------------------------
HOOKS
---------------------------------------------------------------------------]]

hook.Add( 'PostDrawTranslucentRenderables', 'comms.Draw', comms.Draw )

hook.Add( 'HUDPaint', 'comms.LikeHUD', comms.LikeHUD )

hook.Add( 'PlayerButtonDown', 'comms.KeyPress', comms.KeyPress )

comms.pressCD = 0

hook.Add( 'Think', 'workaroundthink', function()

	if !game.SinglePlayer() then

		return

	end

	if comms.pressCD >= CurTime() then

		return

	end

	if input.IsKeyDown(GetConVar('cl_scomms_bind_menu'):GetInt()) then

		comms.pressCD = CurTime() + 0.5

		comms.menuPopup()

	end

	if input.IsKeyDown(GetConVar('cl_scomms_bind_like'):GetInt()) then

		comms.pressCD = CurTime() + 0.5

		comms.addLike()

	end

end )


--[[-------------------------------------------------------------------------
NET
---------------------------------------------------------------------------]]

net.Receive('comms_update', function()

	local count = net.ReadUInt(32)

	for i = 1, count do

		local tbl = {
			sender = net.ReadString(),
			sid = net.ReadString(),
			showSender = net.ReadBool(),
			text = net.ReadString(),
			_type = net.ReadUInt(3),
			pos = net.ReadVector(),
			date = net.ReadUInt(32),
			removeTime = net.ReadInt(32),
			likes = net.ReadUInt(32)
		}

		comms.data[i] = tbl

	end

end)

net.Receive('comms_new', function()

	local tbl = {
		sender = net.ReadString(),
		sid = net.ReadString(),
		showSender = net.ReadBool(),
		text = net.ReadString(),
		_type = net.ReadUInt(3),
		pos = net.ReadVector(),
		date = net.ReadUInt(32),
		removeTime = net.ReadInt(32),
		likes = 0
	}
	
	table.insert(comms.data, tbl)

end)

net.Receive('comms_remove', function()

	local id = net.ReadUInt(32)

	table.remove(comms.data, id)

	if (comms.section == COMMS_MENU_LOGS or comms.section == COMMS_MENU_CONTROL) and comms.bRemoved then

		comms.OpenSection(comms.section)

		comms.bRemoved = false

	end

end)

net.Receive('comms_perm', function()

	local id = net.ReadUInt(32)

	comms.data[id].removeTime = -1

end)

net.Receive('comms_updateLikes', function()

	local id = net.ReadUInt(32)
	local likes = net.ReadUInt(32)

	comms.data[id].likes = comms.data[id].likes + 1

end)