if SERVER then

    hook.Add("ShowSpare2", "rl_loadout_openmenu", function(ply)
        net.Start("rl_loadout_openmenu")
        net.Send(ply)
    end)

elseif CLIENT then
    -- START PLAGIARISM
    -- REFERENCE: https://web.archive.org/web/20190406220210/https://forum.facepunch.com/gmoddev/lcev/HUD-Blur/1/
    local blur = Material("pp/blurscreen")
    local function DrawBlur(panel, amount)
    	local x, y = panel:LocalToScreen(0, 0)
    	local scrW, scrH = ScrW(), ScrH()
    	surface.SetDrawColor(255, 255, 255)
    	surface.SetMaterial(blur)
    	for i = 1, 3 do
    		blur:SetFloat("$blur", (i / 3) * (amount or 6))
    		blur:Recompute()
    		render.UpdateScreenEffectTexture()
    		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
    	end
    end
    -- END PLAGIARISM

    -- START PLAGIARISM
    -- REFERENCE: https://wiki.garrysmod.com/page/cam/PushModelMatrix
    function draw.TextRotated( text, x, y, color, font, ang )
    	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
    	render.PushFilterMin( TEXFILTER.ANISOTROPIC )
    	surface.SetFont( font )
    	surface.SetTextColor( color )
    	surface.SetTextPos( 0, 0 )
    	local textWidth, textHeight = surface.GetTextSize( text )
    	local rad = -math.rad( ang )
    	x = x - ( math.cos( rad ) * textWidth / 2 + math.sin( rad ) * textHeight / 2 )
    	y = y + ( math.sin( rad ) * textWidth / 2 + math.cos( rad ) * textHeight / 2 )
    	local m = Matrix()
    	m:SetAngles( Angle( 0, ang, 0 ) )
    	m:SetTranslation( Vector( x, y, 0 ) )
    	cam.PushModelMatrix( m )
    		surface.DrawText( text )
    	cam.PopModelMatrix()
    	render.PopFilterMag()
    	render.PopFilterMin()
    end
    -- END PLAGIARISM

    -- copied from https://wiki.facepunch.com/gmod/surface.DrawTexturedRectRotated
    function surface.DrawTexturedRectRotatedPoint( x, y, w, h, rot, x0, y0 )
    	local c = math.cos( math.rad( rot ) )
    	local s = math.sin( math.rad( rot ) )
    	local newx = y0 * s - x0 * c
    	local newy = y0 * c + x0 * s
    	surface.DrawTexturedRectRotated( x + newx, y + newy, w, h, rot )
    end
    -- end

    local function findLargestChar(font) -- for testing, can be removed before release
        local sAlphabet = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ#!$%&/;"
        local tAlphabet = string.Split(sAlphabet, "")
        local tLargestCharX = {"", 0}
        local tLargestCharY = {"", 0}

        surface.SetFont(font)
        for k, v in pairs(tAlphabet) do
            local iSizeX, iSizeY = surface.GetTextSize(v)
            if iSizeX >= tLargestCharX[2] then
                tLargestCharX = {v, iSizeX}
            end
            if iSizeY >= tLargestCharY[2] then
                tLargestCharY = {v, iSizeY}
            end
        end
        print(font, tLargestCharX[1] .. ":" .. tLargestCharX[2], tLargestCharY[1] .. ":" .. tLargestCharY[2])
    end

    local function getStringLength(str, font)
        surface.SetFont(font or "DermaDefault")
        return surface.GetTextSize(str)
    end

    local function playButtonSound()
        surface.PlaySound("r_loadout/click.wav")
    end

    local tClassSubs = {
        ['weapon_physgun']      = 'physics gun',
        ['weapon_357']          = '.357 magnum',
        ['weapon_pistol']       = '9mm pistol',
        ['weapon_bugbait']      = 'bugbait',
        ['weapon_crossbow']     = 'crossbow',
        ['weapon_crowbar']      = 'crowbar',
        ['weapon_frag']         = 'grenade',
        ['weapon_physcannon']   = 'gravity gun',
        ['weapon_ar2']          = 'pulse-rifle',
        ['weapon_rpg']          = 'rpg',
        ['weapon_slam']         = 's.l.a.m',
        ['weapon_shotgun']      = 'shotgun',
        ['weapon_smg1']         = 'smg',
        ['weapon_stunstick']    = 'stunstick',
    }

    local function getProperWeaponClassName(class)
        if type(class) != "string" then error("Supplied argument not string (instead " .. type(class) .. ")"); print(class); return end
        if tClassSubs[class] then
            return tClassSubs[class]
        else
            if weapons.Get(class) != nil then
                if weapons.Get(class).PrintName != nil then
                    return language.GetPhrase(weapons.Get(class).PrintName)
                end
            end
        end
    end

    local sRestrictedText = "YOU MUST BE A DONOR TO USE THIS LOADOUT"
    local iProperTextW = -6
    if rll.fontsReady then
        iProperTextW = getStringLength(sRestrictedText, "RLLD15")
    end
    hook.Add("rlld_fontsready", "rlld_settextwide", function()
        iProperTextW = getStringLength(sRestrictedText, "RLLD15")
        timer.Create("rlld_protectfontfromluarefresh", 10, 0, function()
            iProperTextW = getStringLength(sRestrictedText, "RLLD15")
        end)
    end)

    local tPageButtonAssoc = {
        ['home'] = {
            ['settings'] = true,
            ['refresh'] = true,
        },
        ['settings'] = {
            ['home'] = true,
        },
        ['edit'] = {}
    }

    local meta = FindMetaTable("Panel")
    function meta:RLLDSound(snd)
        snd = snd || "r_loadout/click.wav"
        self:On("DoClick", function()
            surface.PlaySound(snd)
        end)
        return self
    end

    function meta:rlldCTEnable(enable)
        self.rlld_tooltip_enable = tobool(enable)
        return enable
    end

    function meta:rlldCTRemove()
        if not IsValid(self) then return end
        if self.RLLDTooltipPanel != nil then
            self.RLLDTooltipPanel.shouldDraw = false
            self.RLLDTooltipPanel:Remove()
            self.RLLDTooltipPanel = nil
        end
        self:rlldCTEnable(false)
    end

    function meta:rlldCustomTooltip(pos, txt, fadespd, col, brd, drop) // panel(p), position(LEFT, RIGHT), text(str), fade speed(int), color(c), border(int), drop shadow(t/f)
        /*if not IsValid(self) then return end
        self:rlldCTRemove()

        self.rlldTooltipNeedsUpdate = true

        if drop == nil then drop = true end
        col     = col || Color(80, 80, 80)
        brd     = brd || 16
        fadespd = fadespd || 20

        self.rlld_tooltip_enable = true

        local sw = 160
        local markup = rlld_mkup_reg(markup.Parse("<font=RLLD15>" .. txt .. " </font>", sw - brd))
        local sh = markup:GetHeight() + brd
        sw = markup:GetWidth() + brd * 2

        self.rlldTooltipMarkup = markup

        self:SetupTransition("TooltipFade", fadespd, function(s)
            return self.rlld_tooltip_enable and s:IsHovered()
        end)
        self:On("Think", function(s)
            if not IsValid(self.RLLDTooltipPanel) or self.rlldTooltipNeedsUpdate then
                if self:IsHovered() then

                    self:GetParent():InvalidateLayout()

                    local x, y = self:LocalToScreen(0, 0)
                    local pw, ph = self:GetSize()
                    local sx, sy = 0, 0
                    local tPts = {}

                    if pos == TOP then
                        sx = x + pw / 2 - sw / 2
                        sy = y - sh - brd
                        tPts = {
                            { x = sx + 5 * sw / 12, y = sy + sh },
                            { x = sx + 7 * sw / 12, y = sy + sh },
                            { x = sx + sw / 2,     y = sy + sh + brd * 2 / 3 },
                        }
                    end

                    if pos == BOTTOM then
                        sx = x + pw / 2 - sw / 2
                        sy = y + ph + brd
                        tPts = {
                            { x = sx + 5 * sw / 12, y = sy },
                            { x = sx + sw / 2,     y = sy - brd * 2 / 3 },
                            { x = sx + 7 * sw / 12, y = sy },
                        }
                    end

                    local tooltippnl = vgui.Create("DPanel"):TDLib():ClearPaint()//:Background(Color(255, 0, 0))
                    tooltippnl:SetSize(sw, sh)
                    tooltippnl:SetPos(sx, sy)
                    tooltippnl:SetZPos(5000)
                    tooltippnl:MakePopup()
                    tooltippnl.shouldDraw = true
                    tooltippnl.Paint = function(s, w, h)

                        if not s.shouldDraw then return end

                        if not s:GetParent() or not s:GetParent().rlld_tooltip_enable then s:Remove() end

                        if drop then BSHADOWS.BeginShadow() end
                        draw.RoundedBox(8, sx, sy, w, h, ColorAlpha(col, self.TooltipFade * 260))

                        surface.SetDrawColor(ColorAlpha(col, self.TooltipFade * 260))
                        draw.NoTexture()
                        surface.DrawPoly(tPts)
                        if drop then BSHADOWS.EndShadow(1, 2, 2) end
                        //draw.DrawText(txt, "RLLD15", w / 2, 5, ColorAlpha(rll.theme.white, self.TooltipFade * 260), TEXT_ALIGN_CENTER)
                        //markup:Draw(w / 2 + 2, h / 2, 1, 1, self.TooltipFade * 260)
                        rlld_mkup_draw(self.rlldTooltipMarkup, w / 2 + 2, h / 2, 1, 1, self.TooltipFade * 260)

                    end

                    tooltippnl:SetDrawOnTop(true)
                    tooltippnl.RLLDParent = self

                    self:On("OnRemove", function()
                        tooltippnl:Remove()
                        self.RLLDTooltipPanel = nil
                    end)

                    tooltippnl:On("OnRemove", function(s2)
                        //s2.RLLDParent.RLLDTooltipPanel = nil
                    end)

                    self.RLLDTooltipPanel = tooltippnl

                end
            else
                if pnl.TooltipFade < 0.01 then
                    if pnl.RLLDTooltipPanel then pnl.RLLDTooltipPanel:Remove() end
                    pnl.RLLDTooltipPanel = nil
                    bTooltipCreated = false
                end
            end
        end)
        return self.RLLDTooltipPanel*/
    end

    local function registerBarButton(pnt, mat, click, col)
        col = col or rll.theme.darkgrey
        local btn = vgui.Create("DButton", pnt):TDLib():ClearPaint():Material(mat, col):RLLDSound()
        btn:SetSize(16, 16)
        btn:Dock(LEFT)
        btn:DockMargin(0, 0, 4, 0)
        btn:SetText("")

        if type(click) == 'string' then
            btn:On("DoClick", function()
                pnt:GetParent():SetPage(click)
            end)
        elseif type(click) == 'function' then
            btn:On("DoClick", click)
        end
        return btn;
    end

    local function splitTable(tab)
        local temp = {}
        for k, v in pairs(tab) do
            temp[v] = true
        end
        return temp
    end

    local tAlphabetTable = splitTable(string.Explode("", "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "))

    local mCloseMaterial = Material("icon16/cross.png")
    local mLockMaterial = Material("r_loadout/lock_icon.png")
    local mColorWheelMaterial = Material("r_loadout/color_wheel_icon.png")
    local mRefreshMaterial = Material("r_loadout/refresh_icon_1.png")
    local mSettingsMaterial = Material("r_loadout/settings_icon_1.png")
    local mBackMaterial = Material("r_loadout/back_icon_2.png")
    local mDeleteMaterial = Material("r_loadout/delete_icon.png")
    local mPasteMaterial = Material("r_loadout/paste_icon_4.png")
    local mAddMaterial = Material("r_loadout/add_icon_2.png")
    local mEditMaterial = Material("r_loadout/edit_icon_2.png")
    local mSelectMaterial = Material("r_loadout/select_icon_3.png")
    local mLoadingMaterial = Material("r_loadout/loading_icon_1.png")
    local mContinueMaterial = Material("r_loadout/continue_icon_1.png")
    local cSelectActiveColor = {rll.theme.darkgrey, rll.theme.medgrey, rll.theme.darkgrey}
    local cSelectDormantColor = {rll.theme.accent, rll.theme.darkgrey, rll.theme.accentlight}
    local frame
    local sLoadoutMenuPage = "home"
    local iLoadoutBeingModified = -1
    local function rlld_openLoadoutMenu()

        if frame then return end
        if not rll.theme or not rll.fontsReady or not rll.data.loadouts then
            chat.AddText(Color(255, 255, 255), "Please wait a moment before opening the loadouts menu.")
            return
        end

        local bDonorLoadoutsAllowed = LocalPlayer():CheckGroup(rl_g_sMinimumDonorRank)

        local tAllButtons = {}

        frame = vgui.Create("DFrame"):TDLib()
        frame:SetSize(750, 450)
        frame:Center()
        frame:MakePopup()
        frame:SetTitle("")
        frame:ShowCloseButton(false)
        frame:SetBackgroundBlur(true)
        frame:SetDraggable(false)
        local sx, sy = frame:GetPos()
        function frame.Paint(s, w, h)
            BSHADOWS.BeginShadow()
            //draw.RoundedBoxEx(rll.theme.rnd, 0, 0, w, 24, rll.theme.accent, true, true, false, false)
            draw.RoundedBoxEx(rll.theme.rnd, sx, sy, w, 24, rll.theme.accent, true, true, false, false)
            //draw.RoundedBoxEx(rll.theme.rnd, 0, 24, w, h - 24, rll.theme.darkgrey, false, false, true, true)
            draw.RoundedBoxEx(rll.theme.rnd, sx, sy + 24, w, h - 24, rll.theme.darkgrey, false, false, true, true)
            BSHADOWS.EndShadow(1, 2, 2)
            draw.SimpleText("Reality's Loadouts", "RLLD15", w / 2, 12, rll.theme.darkgrey, 1, 1)
        end
        rlld_g_MenuFrame = frame
        frame:On("OnRemove", function(s)
            rlld_g_MenuFrame = nil
        end)

        local close = vgui.Create("DButton", frame):TDLib():ClearPaint():RLLDSound()
        close:SetSize(12, 12)
        close:AlignRight(6)
        close:AlignTop(6)
        close:SetText("")
        function close.Paint(s, w, h)
            draw.NoTexture()
    		surface.SetDrawColor(rll.theme.darkgrey)
    		surface.DrawTexturedRectRotated(w/2, h/2, w * 1.5, 3, 45)
    		surface.DrawTexturedRectRotated(w/2, h/2, w * 1.5, 3, -45)
        end
        close:On("DoClick", function()
            frame:Close()
            frame = nil
        end)

        local btnpnl = vgui.Create("DPanel", frame):TDLib():ClearPaint()
        btnpnl:SetSize(frame:GetWide() / 2, 16)
        btnpnl:AlignTop(4)
        btnpnl:AlignLeft(4)

        tAllButtons['settings'] = registerBarButton(btnpnl, mSettingsMaterial, 'settings')
        tAllButtons['refresh'] = registerBarButton(btnpnl, mRefreshMaterial, function() RunConsoleCommand('rlld_refresh') end)
        tAllButtons['home'] = registerBarButton(btnpnl, mBackMaterial, 'home')

        local childpanel = vgui.Create("DPanel", frame):TDLib():ClearPaint()
        childpanel:SetPos(8, 32)
        childpanel:SetSize(frame:GetWide() - 16, frame:GetTall() - 24 - 16)
        frame.cp = childpanel

        function frame:ClearContents()
            for k, v in pairs(childpanel:GetChildren()) do
                v:Remove()
            end
        end

        function frame:SetPage(page)
            sLoadoutMenuPage = page
            if page == "home" then
                frame:ClearContents()
                rlld_attachLoadoutMenuChildren(childpanel, bDonorLoadoutsAllowed)
            elseif page == "settings" then
                frame:ClearContents()
                rlld_attachSettingsMenu(childpanel)
            elseif page == "edit" then
                frame:ClearContents()
                rlld_attachEditMenu(childpanel)
            end

            for k, v in pairs(tAllButtons) do
                v:SetVisible(tPageButtonAssoc[sLoadoutMenuPage][k])
            end
            btnpnl:InvalidateLayout()
        end

        frame:SetPage("home")
    end

    function rlld_attachSettingsMenu(frame)
        local cpickertext = vgui.Create("DLabel", frame):TDLib()
        cpickertext:SetFont("RLLD12")
        cpickertext:SetColor(rll.theme.lightgrey)
        cpickertext:AlignLeft(6)
        cpickertext:AlignTop(6)
        cpickertext:SetText("ACCENT COLOR")
        cpickertext:SizeToContents()

        local cpickerbg = vgui.Create("DPanel", frame):TDLib():ClearPaint()//:Background(rll.theme.accent, 8, false, true, true, true)
        cpickerbg:AlignLeft(6)
        cpickerbg:AlignTop(22)
        cpickerbg:SetSize(240, 200)
        cpickerbg.Paint = function(s, w, h)
            draw.RoundedBoxEx(8, 0, 0, w, h, rll.theme.medgrey, false, true, true, true)
        end

        local cpicker = vgui.Create("DColorMixer", cpickerbg):TDLib()
        cpicker:SetWangs(true)
        cpicker:SetAlphaBar(false)
        cpicker:SetPalette(false)
        cpicker:Dock(FILL)
        cpicker:DockMargin(8, 8, 8, 8)
        cpicker:SetColor(rll.theme.accent)
        cpicker.ValueChanged = function(s, col)
            rll.theme.accent = col
            rll.theme.accentlight = rlld_g_lighten(rll.theme.accent, 0.2)
        end

        local resetbtn = vgui.Create("DButton", cpickerbg):TDLib():ClearPaint():Background(Color(255, 80, 80), 4):RLLDSound()
        resetbtn:SetSize(47, 20)
        resetbtn:AlignRight(8)
        resetbtn:AlignBottom(8)
        resetbtn:SetText("")
        resetbtn:rlldCustomTooltip(TOP, "Click to <color=255,80,80>reset</color> your accent color to its default blue")
        resetbtn:Text("RESET", "RLLD13", rll.theme.darkgrey, TEXT_ALIGN_CENTER, 0, 0, true)
        resetbtn:On("DoClick", function()
            cpicker:SetColor(Color(48, 179, 255))
            rll.theme.accent = Color(48, 179, 255)
            rll.theme.accentlight = rlld_g_lighten(rll.theme.accent, 0.2)
        end)
    end

    function rlld_attachEditMenu(frame)

        local tLoadoutData = table.Copy(rll.data.loadouts[iLoadoutBeingModified])

        local tw, th = draw.SimpleText("EDITING LOADOUT #" .. iLoadoutBeingModified, "RLLD18", 0, 0, rll.theme.white, 1, 1)

        local bgpnl = vgui.Create("DPanel", frame):TDLib():ClearPaint()
        bgpnl:Dock(FILL)
        bgpnl:DockMargin(6, 6, 6, 6)
        bgpnl:InvalidateParent(true)
        bgpnl.Paint = function(s, w, h)
            draw.RoundedBox(8, w / 2 - tw / 2 - 5, 0, tw + 10, th + 4, rll.theme.accent)
            draw.SimpleText("EDITING LOADOUT #" .. iLoadoutBeingModified, "RLLD18", w / 2, 11, rll.theme.darkgrey, 1, 1)
            //draw.RoundedBox(0, w / 2 - tw / 2, 15, tw, 2, rll.theme.medgrey)

            draw.SimpleText("NAME", "RLLD12", 0, 20, rll.theme.lightgrey, 0, 0)
            draw.RoundedBoxEx(8, 0, 34, 230, 22, rll.theme.medgrey, false, true, true, true)
            draw.SimpleText(#s.p_nameentry:GetText() .. "/ 20", "RLLD12", 235, 44, rll.theme.lightgrey, 0, 1)

            draw.SimpleText("WEAPONS  -  " .. #tLoadoutData.weps .. "/ 25", "RLLD12", 0, 65, rll.theme.lightgrey, 0, 0)

            draw.RoundedBoxEx(8, w - 23, 58, 24, 24, rll.theme.medgrey, true, true, false, false)
        end

        local weaponscroll;

        local nameentry = vgui.Create("DTextEntry", bgpnl):TDLib()//:Background(Color(255,0,0), 8, false, true, true, true)
        nameentry:AlignLeft(2)
        nameentry:AlignTop(34)
        nameentry:SetWide(230)
        nameentry:SetDrawBackground(false)
        nameentry:SetText(rll.data.loadouts[iLoadoutBeingModified].name)
        nameentry:SetFont("RLLD15")
        nameentry:SetTextColor(rll.theme.white)
        nameentry:SetUpdateOnType(true)
        nameentry:SetCursorColor(rll.theme.accent)
        local sOldText = nameentry:GetText()
        nameentry.OnChange = function(s)
            local val = s:GetText()
            if #val > 20 then
                s:SetText(sOldText)
                return
            end

            for l, x in pairs(string.Explode("", val)) do
                if not tAlphabetTable[x] then
                    s:SetText(sOldText)
                    return
                end
            end
            sOldText = val

            weaponscroll:RecreateWeaponpanels()
        end
        bgpnl.p_nameentry = nameentry

        local copybtn = vgui.Create("DButton", bgpnl):TDLib():ClearPaint():Material(mPasteMaterial, rll.theme.lightgrey):RLLDSound()//:Background(Color(255, 0, 0))
        copybtn:SetSize(16, 16)
        copybtn:SetPos(bgpnl:GetWide() - 19, 62)
        copybtn:SetText("")
        copybtn:rlldCustomTooltip(TOP, "Click to <color=" .. rll.theme.accent.r .. "," .. rll.theme.accent.g .. "," .. rll.theme.accent.b .. ">copy</color> your equipped weapons to this loadout")

        weaponscroll = vgui.Create("DScrollPanel", bgpnl):TDLib():Background(rll.theme.medgrey, 8, false, false, true, true)
        weaponscroll:SetPos(0, 79)
        weaponscroll:SetSize(bgpnl:GetWide(), 275)
        weaponscroll:SetPadding(8)

        local weaponscrollvbar = weaponscroll:GetVBar()
        weaponscrollvbar:DockMargin(0, 8, 4, 8)
        function weaponscrollvbar.Paint(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, rll.theme.darkgrey)
        end
        function weaponscrollvbar.btnUp.Paint(s, w, h)
            draw.RoundedBoxEx(4, 0, 0, w, h, Color(88, 88, 88), true, true, false, false)
        end
        function weaponscrollvbar.btnDown.Paint(s, w, h)
            draw.RoundedBoxEx(4, 0, 0, w, h, Color(88, 88, 88), false, false, true, true)
        end
        weaponscrollvbar.btnGrip:SetCursor("hand")
        function weaponscrollvbar.btnGrip.Paint(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(80, 80, 80))
        end

        copybtn:On("DoClick", function(s)
            //tLoadoutData.weps = LocalPlayer():GetWeapons()
            local tWeps = LocalPlayer():GetWeapons()
            local tTemp = {}
            for k, v in pairs(tWeps) do
                table.insert(tTemp, v:GetClass())
            end
            tLoadoutData.weps = tTemp
            weaponscroll:RecreateWeaponpanels()
        end)

        rlld_attachWeaponPanels(weaponscroll, tLoadoutData)

        local bottombtnpnl = vgui.Create("DPanel", bgpnl):TDLib():ClearPaint()
        bottombtnpnl:SetSize(bgpnl:GetWide(), 30)
        bottombtnpnl:AlignBottom(0)

        local cancelbtn = vgui.Create("DButton", bottombtnpnl):TDLib():ClearPaint():Background(/*Color(227, 148, 148)*/rll.theme.lightgrey, 8, true, false, true, false):RLLDSound()//:FadeHover(Color(190, 190, 190), nil, 8):RLLDSound()
        cancelbtn:SetSize(bgpnl:GetWide() / 2, bottombtnpnl:GetTall())
        cancelbtn:AlignLeft(0)
        cancelbtn:SetText("")
        cancelbtn:SetupTransition("RLLDFadeHover", 6, function(s) return s:IsHovered() and s:IsEnabled() end)
        cancelbtn:On("DoClick", function()
            frame:GetParent():SetPage("home")
            iLoadoutBeingModified = -1
        end)
        cancelbtn:On("Paint", function(s, w, h)
            draw.RoundedBoxEx(8, 0, 0, w, h, Color(190, 190, 190, s.RLLDFadeHover*255), true, false, true, false)
        end)
        cancelbtn:Text("CANCEL", "RLLD15", rll.theme.darkgrey, TEXT_ALIGN_CENTER, 0, 0, true)

        local cSaveBtnColor = Color(148, 227, 148)
        local cSaveBtnLight = rlld_g_lighten(cSaveBtnColor, 0.1)

        savebtn = vgui.Create("DButton", bottombtnpnl):TDLib():ClearPaint():RLLDSound()//:Background(Color(148, 227, 148), 8, false, true, false, true)
        savebtn:SetSize(bgpnl:GetWide() / 2, bottombtnpnl:GetTall())
        savebtn:AlignRight(0)
        savebtn:SetText("")
        savebtn:SetupTransition("RLLDFadeHover", 6, function(s) return s:IsHovered() and s:IsEnabled() end)
        savebtn:On("Paint", function(s, w, h)
            draw.RoundedBoxEx(8, 0, 0, w, h, cSaveBtnColor, false, true, false, true)

            local col = ColorAlpha(cSaveBtnLight, cSaveBtnLight.a*s.RLLDFadeHover)
            draw.RoundedBoxEx(8, 0, 0, w, h, col, false, true, false, true)
        end)
        //savebtn:FadeHover(Color(255, 0, 0), nil, 8, false, true, false, true)
        savebtn:Text("SAVE", "RLLD15", rll.theme.darkgrey, TEXT_ALIGN_CENTER, 0, 0, true)
        savebtn:On("DoClick", function()
            local allweps = ""
            for k, v in pairs(tLoadoutData.weps) do
                allweps = allweps .. v .. ";"
            end
            allweps = string.TrimRight(allweps, ";")
            LocalPlayer():ConCommand("rlld_modify " .. iLoadoutBeingModified .. " \"" .. nameentry:GetValue() .. "\" \"" .. allweps .. "\"")
        end)
        savebtn.CustomEnable = function(s, e)
            local c = e and 'hand' or 'arrow'
            cSaveBtnColor = e and Color(148, 227, 148) or Color(110, 110, 110)
            cSaveBtnLight = rlld_g_lighten(cSaveBtnColor, 0.1)
            s:SetEnabled(e)
            s:SetCursor(c)
        end
        //savebtn:rlldCustomTooltip(BOTTOM, "You cannot use this button.")

        weaponscroll.RecreateWeaponpanels = function(s)
            for k, v in pairs(s:GetChildren()[1]:GetChildren()) do
                v:Remove()
            end
            rlld_attachWeaponPanels(s, tLoadoutData)

            local iLoadoutWepsTotal = #tLoadoutData.weps

            if #tLoadoutData.weps <= 0 or #tLoadoutData.weps > 25 then
                savebtn:CustomEnable(false)
                savebtn:rlldCTRemove()
                savebtn:rlldCustomTooltip(BOTTOM, "Your loadout <color=255,120,120>must</color> include between 1 and 25 weapons")
            elseif #nameentry:GetValue() == 0 then
                savebtn:CustomEnable(false)
                savebtn:rlldCTRemove()
                savebtn:rlldCustomTooltip(BOTTOM, "You <color=255,120,120>must</color> specify a title for your loadout")
            else
                savebtn:CustomEnable(true)
                savebtn:rlldCTEnable(false)
            end
        end

    end

    function rlld_attachWeaponPanels(weaponscroll, tLoadoutData)
        for k, v in pairs(tLoadoutData.weps) do

            local iBrightnessVal = (80 + (k % 2) * 8)

            local bIsFirst = (k == 1)
            local bIsLast = (k == #tLoadoutData.weps)
            //local bIsLast = false
            local iTopMargin = bIsFirst and 8 or 0
            //local iBottomMargin = bIslast and 8 or 0
            local iBottomMargin = 0
            //local sWeaponName = string.upper(language.GetPhrase(LocalPlayer():GetWeapon(v):GetPrintName()))
            //local sWeaponName = string.upper(weapons.Get(v).PrintName)
            local sProperWeaponClassName = getProperWeaponClassName(tostring(v)) or 'Invalid Weapon'
            local sWeaponName = string.upper(sProperWeaponClassName)

            surface.SetFont("RLLD15")
            local tw, th = surface.GetTextSize(tostring(k))

            local weaponpanel = vgui.Create("DPanel", weaponscroll):TDLib():ClearPaint():Background(Color(iBrightnessVal, iBrightnessVal, iBrightnessVal), 8, bIsFirst, bIsFirst, bIsLast, bIsLast)
            weaponpanel:Dock(TOP)
            weaponpanel:DockMargin(8, iTopMargin, 8, iBottomMargin)
            weaponpanel.rlld_bIsWeaponPanel = true
            weaponpanel:Text(tostring(k), "RLLD15", rll.theme.lightgrey, TEXT_ALIGN_LEFT, 8, 0, true)
            local txcol = rll.theme.white
            if sProperWeaponClassName == 'Invalid Weapon' then txcol = rll.theme.red end
            weaponpanel:Text(sWeaponName .. " (" .. v .. ")", "RLLD15", txcol, TEXT_ALIGN_LEFT, 16 + tw, 0, true)

            local removebtn = vgui.Create("DButton", weaponpanel):TDLib():ClearPaint():Material(mDeleteMaterial, Color(224, 103, 94)):RLLDSound()//:Background(Color(224, 103, 94), 6)
            removebtn:SetSize(16, 16)
            //removebtn:SetPos(weaponscroll:GetWide() - removebtn:GetWide() - 20, 4)
            removebtn:Dock(RIGHT)
            removebtn:DockMargin(0, 4, 4, 4)
            removebtn:SetText("")
            removebtn:On("DoClick", function()
                table.remove(tLoadoutData.weps, k)
                weaponscroll:RecreateWeaponpanels()
            end)
        end

        if #tLoadoutData.weps < 25 then
            local addpnl = vgui.Create("DPanel", weaponscroll):TDLib():ClearPaint()//:Background(rll.theme.darkgrey, 8, false, false, true, true)
            addpnl:Dock(TOP)
            addpnl:DockMargin(8, 0, 8, 0)
            if #tLoadoutData.weps == 0 then addpnl:DockMargin(8, 4, 8, 0) end

            //addpnl:InvalidateParent()
            local addbtn = vgui.Create("DButton", addpnl):TDLib():ClearPaint():Material(mAddMaterial, Color(148, 227, 148))
            addbtn:SetSize(16, 16)
            addbtn:SetPos((weaponscroll:GetWide() - 16) / 2 - 8, addpnl:GetTall() / 2 - 8)
            addbtn:SetText("")
            addbtn.DoClick = function(s)
                s:Hide()
                local disablePanel = vgui.Create("DPanel", frame):TDLib():ClearPaint():Background(Color(50, 50, 50, 220), 8)
                disablePanel:SetSize(frame:GetWide(), frame:GetTall())
                disablePanel:SetPos(0, 0)
                disablePanel:On("OnRemove", function()
                    s:Show()
                end)
                //timer.Simple(5, function() disablePanel:Remove() end)

                // weapon scroll
                local weaponspanel = vgui.Create("DPanel", disablePanel):TDLib()//:HideVBar()//:Background(rll.theme.lightgrey, rll.theme.rnd)
                weaponspanel:SetSize(disablePanel:GetWide() - 80, disablePanel:GetTall() - 104)
                weaponspanel:SetPos(disablePanel:GetWide() / 2 - weaponspanel:GetWide() / 2, disablePanel:GetTall() / 2 - weaponspanel:GetTall() / 2 + 13)
                local sx, sy = weaponspanel:GetPos()
                local psx, psy = frame:GetPos()
                sx = sx + psx
                sy = sy + psy

                weaponspanel.Paint = function(s, w, h)
                    BSHADOWS.BeginShadow()
                    draw.RoundedBox(rll.theme.rnd, sx, sy, w, h, rll.theme.lightgrey)
                    BSHADOWS.EndShadow(1, 2, 2)
                end
                weaponspanel:Text("Select a Weapon", "RLLD15", rll.theme.darkgrey, TEXT_ALIGN_CENTER, 0, -weaponspanel:GetTall() / 2 + 14)

                // loading panel so the user knows it's loading
                local loadingpanel = vgui.Create("DPanel", weaponspanel):TDLib()
                loadingpanel:SetSize(disablePanel:GetWide() - 80, disablePanel:GetTall() - 104)
                loadingpanel:SetPos(0, 0)
                loadingpanel.Paint = function(s, w, h)
                    draw.RoundedBox(rll.theme.rnd, 0, 0, w, h, rll.theme.lightgrey)
                    //draw.SimpleText("LOADING" .. string.rep(".", CurTime() * 10 % 3, ""), "RLLD30", w / 2, h / 2, rll.theme.darkgrey, 1, 1)
                    surface.SetDrawColor(rll.theme.darkgrey)
                    surface.SetMaterial(mLoadingMaterial)
                    surface.DrawTexturedRectRotatedPoint(w / 2, h / 2, 96, 96, (CurTime() * 50 % 60 * 6), 0, 0)
                end

                // helpers
                local bWeaponScrollLoading = true
                local tLoadingElements = {}
                local function doneLoading()
                    bWeaponScrollLoading = false
                    loadingpanel:Remove()
                    for k, v in pairs(tLoadingElements) do
                        v:Show()
                    end
                end

                // debug
                /*timer.Simple(1, function()
                    doneLoading()
                end)*/

                timer.Create("rlld_cancellockout", 10, 1, function()
                    if bWeaponScrollLoading then
                        disablePanel:Remove()
                        LocalPlayer():ChatPrint("[RLLD] Loading took too long. Maybe an error?")
                    end
                end)

                // to allow proper layout first
                timer.Simple(0, function()
                    local closebtn = vgui.Create("DButton", weaponspanel):TDLib()
                    closebtn:Hide()
                    closebtn:SetSize(12, 12)
                    closebtn:AlignRight(6)
                    closebtn:AlignTop(6)
                    closebtn:SetText("")
                    function closebtn.Paint(s, w, h)
                        draw.NoTexture()
                		surface.SetDrawColor(rll.theme.darkgrey)
                		surface.DrawTexturedRectRotated(w/2, h/2, w * 1.5, 3, 45)
                		surface.DrawTexturedRectRotated(w/2, h/2, w * 1.5, 3, -45)
                    end
                    function closebtn.DoClick(s)
                        disablePanel:Remove()
                    end
                    table.insert(tLoadingElements, closebtn)

                    local paddingamt = weaponspanel:GetWide() / 6
                    local constructWeaponClickables = function() end

                    local searchpanel = vgui.Create("DTextEntry", weaponspanel):TDLib()//:ClearPaint():Background(Color(140, 140, 140), rll.theme.rnd)
                    searchpanel:Hide()
                    searchpanel:SetTall(24)
                    searchpanel:Dock(TOP)
                    searchpanel:DockMargin(paddingamt, paddingamt / 4, paddingamt, 0)
                    searchpanel:SetDrawBackground(false)
                    searchpanel:SetCursorColor(rll.theme.darkgrey)
                    searchpanel:SetFont("RLLD15")
                    searchpanel:SetTextColor(rll.theme.darkgrey)
                    //searchpanel:SetText("Search...")
                    searchpanel:SetPlaceholderText("Search (press enter)")
                    searchpanel:SetPlaceholderColor(Color(70, 70, 70))
                    searchpanel:SetUpdateOnType(false)
                    searchpanel.OnValueChange = function(s, val)
                        constructWeaponClickables(val)
                    end
                    table.insert(tLoadingElements, searchpanel)

                    timer.Simple(0.0002, function()
                        local searchpanelx, searchpanely = paddingamt, paddingamt / 4
                        local searchpanelw, searchpanelh = weaponspanel:GetWide() - paddingamt * 2, 24
                        weaponspanel:On("Paint", function(s, w, h)
                            draw.RoundedBox(rll.theme.rnd, searchpanelx - 4, searchpanely, searchpanelw + 8, searchpanelh, Color(140, 140, 140))
                        end)
                    end)

                    local listedscroll = vgui.Create("DScrollPanel", weaponspanel):TDLib()/*:HideVBar()*/:ClearPaint()//:Background(Color(140, 140, 140), rll.theme.rnd)
                    listedscroll:Hide()
                    listedscroll:Dock(FILL)
                    listedscroll:DockMargin(8, 8, 8, 8)
                    listedscroll:DockMargin(8, 8, 8, 8)
                    listedscroll.Paint = function(s, w, h)
                        if s:GetVBar().Enabled then
                            draw.RoundedBox(rll.theme.rnd, 0, 0, w - s:GetVBar():GetWide() * 1.5, h, Color(140, 140, 140))
                        else
                            draw.RoundedBox(rll.theme.rnd, 0, 0, w, h, Color(140, 140, 140))
                        end
                        draw.SimpleText("No weapons found :(", "RLLD15", w / 2, 20, rll.theme.darkgrey, 1, 1)
                    end

                    table.insert(tLoadingElements, listedscroll)
                    local paddingpnl_top = vgui.Create("DPanel", listedscroll):TDLib():ClearPaint()
                    paddingpnl_top:SetTall(8)
                    paddingpnl_top:Dock(TOP)

                    local scrollbar = listedscroll:GetVBar()
                    function scrollbar:Paint(w, h)
                        draw.RoundedBox(0, 0, 10, w, h - 20, Color(150, 150, 150))
                    end
                    function scrollbar.btnUp:Paint(w, h)
                        draw.RoundedBoxEx(4, 0, 0, w, h, Color(140, 140, 140), true, true, false, false)
                    end
                    function scrollbar.btnDown:Paint(w, h)
                        draw.RoundedBoxEx(4, 0, 0, w, h, Color(140, 140, 140), false, false,true, true)
                    end
                    function scrollbar.btnGrip:Paint(w, h)
                        draw.RoundedBox(0, 0, 0, w, h, Color(140, 140, 140))
                    end
                    scrollbar.btnGrip:SetCursor("hand")

                    local tWeaponClickables = {}

                    local continuebutton = vgui.Create("DButton", disablePanel):TDLib():ClearPaint():Material(mContinueMaterial)
                    continuebutton:Hide()
                    continuebutton:SetSize(32, 32)
                    continuebutton:AlignRight(24)
                    continuebutton:AlignBottom(24)
                    continuebutton:SetText("")
                    continuebutton.DoClick = function(s)
                        if s.selectedpanel then
                            if s.selectedpanel.weaponclass then
                                table.insert(tLoadoutData.weps, s.selectedpanel.weaponclass)
                                disablePanel:Remove()
                                weaponscroll:RecreateWeaponpanels()
                            end
                        end
                    end

                    //table.SortByMember(rl_g_tAllWeapons, "ClassName")

                    constructWeaponClickables = function(searchQuery)
                        for k, v in pairs(tWeaponClickables) do
                            v:Remove()
                        end
                        continuebutton:Hide()

                        local toMatch;
                        if searchQuery then
                            toMatch = string.Explode(" ", searchQuery)
                        end

                        local i = 0
                        local firstpanelcreated
                        local lastpanelcreated
                        local selectedpanel
                        for k, v in pairs(rl_g_tAllWeapons_KeyValue) do
                            local class = v
                            local displayname = getProperWeaponClassName(class)


                            if not table.HasValue(tLoadoutData.weps, class) then
                                if searchQuery then
                                    for l, x in pairs(toMatch) do
                                        local haystack = string.lower(class .. " " .. displayname)
                                        if not string.find(haystack, string.lower(x)) then
                                            goto nextiteration
                                        end
                                    end
                                end

                                if not rlld_g_canAccessSwep(v) then goto nextiteration end

                                i = i + 1

                                local c = 160 + (8 * (i % 2))
                                local selectchild = vgui.Create("DButton", listedscroll):TDLib():ClearPaint()//:Background(Color(c, c, c), 8)

                                selectchild.weaponclass = class
                                selectchild.isTopPanel = false
                                selectchild.isBottomPanel = false
                                if not firstpanelcreated then selectchild.isTopPanel = true; firstpanelcreated = selectchild end

                                selectchild:Dock(TOP)
                                selectchild:DockMargin(8, 0, 8, 0)
                                selectchild:SetText("")
                                selectchild.DoClick = function(s)
                                    if selectedpanel then selectedpanel.rlldSelected = false end
                                    s.rlldSelected = true
                                    selectedpanel = s
                                    continuebutton.selectedpanel = selectedpanel
                                    continuebutton:Show()
                                end
                                selectchild.Paint = function(s, w, h)
                                    local bg = Color(c, c, c)
                                    if s.rlldSelected then bg = Color(184, 207, 171) end
                                    if listedscroll:GetVBar().Enabled then
                                        draw.RoundedBoxEx(rll.theme.rnd, 0, 0, w - listedscroll:GetVBar():GetWide() * 0.5, h, bg, selectchild.isTopPanel, selectchild.isTopPanel, selectchild.isBottomPanel, selectchild.isBottomPanel)
                                    else
                                        draw.RoundedBoxEx(rll.theme.rnd, 0, 0, w, h, bg, selectchild.isTopPanel, selectchild.isTopPanel, selectchild.isBottomPanel, selectchild.isBottomPanel)
                                    end

                                    draw.SimpleText(displayname .. " (" .. class .. ") ", "RLLD15", 10, h / 2, rll.theme.darkgrey, 0, 1)
                                end
                                lastpanelcreated = selectchild
                                table.insert(tWeaponClickables, selectchild)
                            end

                            ::nextiteration::
                        end

                        local paddingpnl_bottom = vgui.Create("DPanel", listedscroll):TDLib():ClearPaint()
                        paddingpnl_bottom:SetTall(8)
                        paddingpnl_bottom:Dock(TOP)
                        table.insert(tWeaponClickables, paddingpnl_bottom)

                        if lastpanelcreated then lastpanelcreated.isBottomPanel = true end

                        doneLoading()
                    end

                    constructWeaponClickables()

                end)

                //table.insert(tLoadoutData.weps, "weapon_crowbar")
                //weaponscroll:RecreateWeaponpanels()
            end
        end

        local bufferpnl = vgui.Create("DPanel", weaponscroll):TDLib():ClearPaint()//:Background(Color(255, 0, 0))
        bufferpnl:Dock(TOP)
        bufferpnl:SetHeight(8)
    end

    function rlld_attachLoadoutMenuChildren(frame, bDonorLoadoutsAllowed)
        local scrollframe = vgui.Create("DScrollPanel", frame):TDLib():ClearPaint()
        //scrollframe:SetPos(8, 32)
        //scrollframe:SetSize(frame:GetWide() - 16, frame:GetTall() - 24 - 16)
        scrollframe:SetPos(0, 0)
        scrollframe:SetSize(frame:GetWide(), frame:GetTall())
        frame.rlld_scroll = scrollframe

        local scrollvbar = scrollframe:GetVBar()
        function scrollvbar.Paint(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, rll.theme.medgrey)
        end
        function scrollvbar.btnUp.Paint(s, w, h)
            draw.RoundedBoxEx(4, 0, 0, w, h, rll.theme.accent, true, true, false, false)
        end
        function scrollvbar.btnDown.Paint(s, w, h)
            draw.RoundedBoxEx(4, 0, 0, w, h, rll.theme.accent, false, false, true, true)
        end
        scrollvbar.btnGrip:SetCursor("hand")
        function scrollvbar.btnGrip.Paint(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, rll.theme.accent)
        end

        local iLoadoutPanelScrollbarWidth = 15
        local iLoadoutPanelScrollbarPadding = 5

        local iLoadoutPanelW = scrollframe:GetWide() - (iLoadoutPanelScrollbarWidth + iLoadoutPanelScrollbarPadding)
        local iLoadoutPanelH = 50
        local iLoadoutPanelInBetweenPadding = 6

        local iLoadoutPanelButtonPadding = 5
        local iLoadoutPanelButtonHeight = iLoadoutPanelH - iLoadoutPanelButtonPadding * 2
        local iLoadoutPanelButtonWidth = 70

        for k, v in pairs(rll.data.loadouts) do

            local bIsSelected = false
            local cSelectColor = cSelectDormantColor
            local cNameColor = cNameDormantColor
            if k == rll.data.lastSelected then cSelectColor = cSelectActiveColor; cNameColor = cNameActiveColor; bIsSelected = true end

            local loadoutpanel = vgui.Create("DPanel", scrollframe):TDLib():ClearPaint():Background(rll.theme.medgrey, rll.theme.rnd)
            loadoutpanel:SetSize(iLoadoutPanelW, iLoadoutPanelH)
            loadoutpanel:Dock(TOP)
            loadoutpanel:DockMargin(0, iLoadoutPanelInBetweenPadding / 2, iLoadoutPanelScrollbarPadding, iLoadoutPanelInBetweenPadding / 2)
            loadoutpanel:SetName("RLLD_LPN_NUM_" .. k)
            loadoutpanel:SetMouseInputEnabled(true)
            loadoutpanel:SetupTransition("RLLDFadeHover", 12, function(s) return s:IsHovered() and s:IsEnabled() end)
            /*function loadoutpanel.Paint(s, w, h)

                draw.RoundedBox(rll.theme.rnd, 0, 0, w, h, rll.theme.medgrey)


                if not bDonorLoadoutsAllowed and k <= rl_g_iStandardLoadouts or bDonorLoadoutsAllowed then
                    draw.SimpleText("LOADOUT #" .. k, "RLLD12", 10, 6, rll.theme.lightgrey, 0, 0)
                    draw.SimpleText(v.name, "RLLD30", 10, 17, rll.theme.white, 0, 2)
                    //draw.SimpleText(string.rep("W", 20), "RLLD30", 10, 17, rll.theme.white, 0, 2)
                    draw.SimpleText("EQUIPPED", "RLLD15", 674, h / 2, rll.theme.lightgrey, 1, 1)
                end

            end*/
            loadoutpanel:On("Paint", function(s, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(80, 80, 80, s.RLLDFadeHover*255))

                if not bDonorLoadoutsAllowed and k <= rl_g_iStandardLoadouts or bDonorLoadoutsAllowed then
                    draw.SimpleText("LOADOUT #" .. k, "RLLD12", 10, 6, rll.theme.lightgrey, 0, 0)
                    draw.SimpleText(v.name, "RLLD30", 10, 17, rll.theme.white, 0, 2)
                    //draw.SimpleText(string.rep("W", 20), "RLLD30", 10, 17, rll.theme.white, 0, 2)
                    //draw.SimpleText("EQUIPPED", "RLLD15", 674, h / 2, rll.theme.lightgrey, 1, 1)
                    if k == rll.data.lastSelected then

                        surface.SetDrawColor(110, 110, 110)
                        surface.SetMaterial(mSelectMaterial)
                        surface.DrawTexturedRect(w - 37, 14, 24, 24)

                    end
                end
            end)

            if not bDonorLoadoutsAllowed and k > rl_g_iStandardLoadouts then

                local blockpanel = vgui.Create("DPanel", loadoutpanel):TDLib():ClearPaint()
                blockpanel:Dock(FILL)
                blockpanel:SetCursor("no")
                function blockpanel.Paint(s, w, h)
                    draw.RoundedBox(rll.theme.rnd, 0, 0, w, h, Color(0, 0, 0, 80))
                end

                local iconpanel = vgui.Create("DPanel", blockpanel):TDLib():ClearPaint():Background(rll.theme.accent, rll.theme.rnd)//:FadeHover(rll.theme.accentlight, 8, rll.theme.rnd)
                iconpanel:SetSize(24, 24)
                iconpanel:SetPos(loadoutpanel:GetWide() / 2 - iconpanel:GetWide() / 2, loadoutpanel:GetTall() / 2 - iconpanel:GetTall() / 2)
                iconpanel:SetCursor("no")
                iconpanel.ShouldWidth = 24
                iconpanel.CurrentWidth = 24

                iconpanel:On("Paint", function(s, w, h)

                    if s.CurrentWidth != s.ShouldWidth then
                        s.CurrentWidth = Lerp(10 * FrameTime(), s.CurrentWidth, s.ShouldWidth)
                        s:SetWidth(s.CurrentWidth)
                        s:CenterHorizontal(0.5)
                        s:CenterVertical(0.5)
                    end

                    /*BSHADOWS.BeginShadow()
                    draw.RoundedBox(rll.theme.rnd, sx, sy, w, h, rll.theme.accent)
                    BSHADOWS.EndShadow(1, 2, 2)*/

                    draw.SimpleText(sRestrictedText, "RLLD15", 24, h / 2, rll.theme.medgrey, 0, 1)

                    surface.SetMaterial(mLockMaterial)
                    surface.SetDrawColor(255, 255, 255)
                    surface.DrawTexturedRect(4, 4, 16, 16)

                    if vgui.GetHoveredPanel() == s or vgui.GetHoveredPanel() == blockpanel then
                        s.ShouldWidth = iProperTextW + 30
                    else
                        s.ShouldWidth = 24
                    end
                end)

            else

                local editbutton = vgui.Create("DButton", loadoutpanel):TDLib():ClearPaint():Background(rll.theme.accent, rll.theme.rnd):FadeHover(rll.theme.accentlight, 8, rll.theme.rnd):RLLDSound()
                editbutton:SetSize(iLoadoutPanelButtonHeight, iLoadoutPanelButtonHeight)
                editbutton:AlignRight(iLoadoutPanelButtonPadding * 2 + iLoadoutPanelButtonHeight)
                editbutton:AlignBottom(iLoadoutPanelButtonPadding)
                editbutton:SetText("")
                editbutton:On("Paint", function(s, w, h)
                    //draw.SimpleText("EDIT", "RLLD15", w / 2, h / 2 - 1, rll.theme.darkgrey, 1, 1)
                    surface.SetDrawColor(rll.theme.medgrey)
                    surface.SetMaterial(mEditMaterial)
                    surface.DrawTexturedRect(8, 8, 24, 24)
                end)
                editbutton:On("DoClick", function()
                    //playButtonSound()
                    iLoadoutBeingModified = k
                    frame:GetParent():SetPage('edit')
                end)

                local selectbutton = vgui.Create("DButton", loadoutpanel):TDLib():ClearPaint():Background(rll.theme.accent, rll.theme.rnd):FadeHover(rll.theme.accentlight, 8, rll.theme.rnd):RLLDSound()
                selectbutton:SetSize(iLoadoutPanelButtonHeight, iLoadoutPanelButtonHeight)
                selectbutton:AlignRight(iLoadoutPanelButtonPadding)
                selectbutton:AlignTop(iLoadoutPanelButtonPadding)
                selectbutton:SetText("")
                selectbutton:On("Paint", function(s, w, h)
                    //draw.SimpleText("SELECT", "RLLD15", w / 2, h / 2 - 1, rll.theme.darkgrey, 1, 1)
                    surface.SetDrawColor(rll.theme.medgrey)
                    surface.SetMaterial(mSelectMaterial)
                    surface.DrawTexturedRect(8, 8, 24, 24)
                end)
                selectbutton:On("DoClick", function() RunConsoleCommand("rlld_select", k) end)
                selectbutton:SetVisible(k != rll.data.lastSelected)
                selectbutton.RedoVisibility = function(s)
                    s:SetVisible(k != rll.data.lastSelected)
                end
                loadoutpanel.rlld_select = selectbutton
            end
        end
    end

    net.Receive("rl_loadout_openmenu", rlld_openLoadoutMenu)

    concommand.Add("rlld_openmenu", function()
        rlld_openLoadoutMenu()
    end)

    hook.Add("rlld_select_success", "rlld_select_success_btns", function(iPrev, iCurr)
        if frame != nil and IsValid(frame) then
            local tLpns = frame.cp.rlld_scroll:GetChildren()[1]:GetChildren()
            //PrintTable(tLpns)
            for k, v in pairs(tLpns) do
                if IsValid(v.rlld_select) then
                    v.rlld_select:RedoVisibility()
                end
            end
        end
    end)

    hook.Add("rlld_refresh_success", "rlld_refresh_success_vgui", function()
        if frame != nil and IsValid(frame) then

        end
    end)
end
