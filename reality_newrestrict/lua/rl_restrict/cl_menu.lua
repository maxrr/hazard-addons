local materials = {
    ["close"] = Material("icon16/cancel.png"),
    ["fullwhite"] = Material("models/debug/debugwhite"),
    //["remove"] = Material("icon16/delete.png"),
    ["remove"] = Material("rl_rest_mats/delete_icon.png"),
    //["add"] = Material("icon16/add.png"),
    ["add"] = Material("rl_rest_mats/add_icon.png"),
    ["save"] = Material("icon16/disk.png"),
    ["cross"] = Material("icon16/cross.png"),
    ["tick"] = Material("icon16/tick.png"),
}

rlr_isMenuOpen = rlr_isMenuOpen or false
local recentPanel = nil
local currFilter = nil
local currentlyModifying = false
local modifyType
local modifyBuffer = {}
local sortByRank = false

local function getTwTh(text, font)
    surface.SetFont(font or "DermaDefault")
    return surface.GetTextSize(text)
end

local function pairsByKeys(t)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

function rlr.openMenu()
    local cl = {
        Color(48, 179, 255), --blue
    }

    rlr_isMenuOpen = true
    local gCacheRemove = {}

    local frame = vgui.Create("DFrame")
    frame:SetSize(600, ScrH() * 0.5)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:SetDeleteOnClose(true)
    frame:SetKeyboardInputEnabled(true)
	frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h + 2, Color(60, 60, 60))
		draw.RoundedBox(8, 0, 0, w, 24, Color(40, 40, 40))
		draw.RoundedBox(0, 0, 19, w, 6, Color(40, 40, 40))
        draw.SimpleText("Restrictions", "DermaDefault", 8, 5, Color(255, 255, 255))

        draw.RoundedBox(4, 5, h - 25, w - 10, 20, Color(48, 179, 255))
	end

    function rlr.closeMenu() frame:Close() end

	local closeButton = vgui.Create("DButton", frame)
	closeButton:SetText("")
	closeButton:SetPos(frame:GetWide() - 18, 6)
	closeButton:SetSize(12, 12)
	closeButton.Paint = function(self, w, h)
        draw.NoTexture()
		surface.SetDrawColor(218, 52, 55)
		surface.DrawTexturedRectRotated(w/2, h/2, w * 1.5, 2, 45)
		surface.DrawTexturedRectRotated(w/2, h/2, w * 1.5, 2, -45)
	end
	closeButton.DoClick = function()
        rlr_isMenuOpen = false
        //currentlyModifying = false
		frame:Remove()
	end

    function rlr.createNewRestriction(sweppanel, panelType, linkedTable, tabs)
        modifyBuffer = modifyBuffer or { false, false }
        modifyType = panelType

        local panel = vgui.Create("DPanel", sweppanel)
        panel:SetSize(tabs:GetWide() - 10, 25)
        panel:SetPos(0, table.Count(linkedTable) * 30)
        if table.Count(rlr[panelType]) >= 13 then panel:SetSize(panel:GetWide() - 20, 25) end

        local nameEntry = vgui.Create("DTextEntry", panel)
        nameEntry:SetPos(5, 2)
        nameEntry:SetSize(200, 21)
        nameEntry:SetText(modifyBuffer[1] or "classname")
        nameEntry:SetUpdateOnType(true)
        function nameEntry:OnValueChange(value)
            if string.find(value, " ") == nil then
                modifyBuffer[1] = value
            else
                modifyBuffer[1] = false
            end
        end

        panel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(48, 179, 255))
            //draw.SimpleText("sample", "HUDSmallNumberDisplay", 8, h / 2, Color(20, 20, 20), 0, 1)
        end

        local list = vgui.Create("DComboBox", panel)
        list:SetSize(110, 21)
        list:SetPos(panel:GetWide() - 171, 2)
        list:SetSortItems(false)
        list:SetValue("no role selected")

        for l, x in pairs(rlr_config.roles.all) do
            local isDefault = (x == modifyBuffer[2])
            list:AddChoice(x, rlr_config.roleIndex(x), isDefault)
        end

        list.OnSelect = function(index, value, data)
            modifyBuffer[2] = data
        end
        list.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200))
        end

        local saveButton = vgui.Create("DButton", panel)
        saveButton:SetSize(30, 16)
        saveButton:SetPos(panel:GetWide() - 57, panel:GetTall() / 2 - saveButton:GetTall() / 2)
        saveButton:SetText("")
        saveButton.Paint = function(self, w, h)
            surface.SetDrawColor(Color(255, 255, 255))
            surface.SetMaterial(materials.save)
            surface.DrawTexturedRect(0, 0, 16, 16)

            surface.SetDrawColor(Color(255, 255, 255))
            surface.SetMaterial(materials.cross)
            if modifyBuffer[1] and modifyBuffer[2] then surface.SetMaterial(materials.tick) end
            surface.DrawTexturedRect(18, 2, 12, 12)
        end
        saveButton.DoClick = function()
            if modifyBuffer[1] and modifyBuffer[2] then
                local info = {}
                info.item = modifyBuffer[1]
                info.rank = modifyBuffer[2]
                info.type = panelType

                net.Start("rl_addRestriction")
                net.WriteTable(info)
                net.SendToServer()

                panel:Remove()
                currentlyModifying = false
                modifyBuffer = {}
            end
        end

        local cancelButton = vgui.Create("DButton", panel)
        cancelButton:SetSize(16, 16)
        cancelButton:SetPos(panel:GetWide() - 20, panel:GetTall() / 2 - cancelButton:GetTall() / 2)
        cancelButton:SetText("")
        cancelButton.Paint = function(self, w, h)
            surface.SetDrawColor(Color(255, 255, 255))
            surface.SetMaterial(materials.remove)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        cancelButton.DoClick = function()
            currentlyModifying = false
            modifyBuffer = {}
            panel:Remove()
        end
    end

    function rlr.refreshMenu(filter)
        for k, v in pairs(gCacheRemove) do v:Remove() end

        local tabs = vgui.Create("DPropertySheet", frame)
        tabs:SetSize(frame:GetWide() - 10, frame:GetTall() - 60)
        tabs:SetPos(5, 30)
        tabs:SetPadding(5)
        tabs.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 19, w, h - 19, Color(40, 40, 40))
        end
        table.insert(gCacheRemove, tabs)

        local valToConcatenate = "alphabetical (a-z)"
        if sortByRank then valToConcatenate = "rank" end
        valToConcatenate = string.upper(valToConcatenate)

        local sortButton = vgui.Create("DButton", tabs)
        sortButton:SetSize(getTwTh(valToConcatenate) + 12, 20)
        sortButton:AlignTop(0)
        sortButton:AlignRight(0)
        sortButton:SetText("")
        sortButton:SetTextColor(Color(200, 200, 200))
        sortButton:SetTooltip("Sorted by: " .. string.upper(valToConcatenate))
        sortButton.Paint = function(s, w, h)
            draw.RoundedBoxEx(4, 0, 0, w, h + 5, Color(40, 40, 40), true, true, false, false)
            draw.SimpleText(valToConcatenate, "DermaDefault", w / 2, h / 2, Color(200, 200, 200), 1, 1)
        end
        sortButton.DoClick = function()
            sortByRank = !sortByRank
            rlr.refreshMenu(currFilter)
            sortButton:Remove()
        end
        table.insert(gCacheRemove, sortButton)

        local createdTabTable = {}

        local weaponpanel = vgui.Create("DScrollPanel", tabs)
        createdTabTable['swep'] = tabs:AddSheet("SWEPs", weaponpanel, "icon16/bomb.png")

        local proppanel = vgui.Create("DScrollPanel", tabs)
        createdTabTable['prop'] = tabs:AddSheet("Props", proppanel, "icon16/building.png")

        local entpanel = vgui.Create("DScrollPanel", tabs)
        createdTabTable['ent'] = tabs:AddSheet("Ents", entpanel, "icon16/shape_handles.png")

        local toolpanel = vgui.Create("DScrollPanel", tabs)
        createdTabTable['tool'] = tabs:AddSheet("Tools", toolpanel, "icon16/wand.png")

        local vehiclepanel = vgui.Create("DScrollPanel", tabs)
        createdTabTable['vehicle'] = tabs:AddSheet("Vehicles", vehiclepanel, "icon16/lorry.png")

        function tabs:OnActiveTabChanged(old, new)
            recentPanel = new:GetText()
        end

        if recentPanel != nil then
            tabs:SwitchToName(recentPanel)
        end

        local childtabs = tabs:GetItems()
        for k, v in pairs(childtabs) do
            v.Tab.Paint = function(self, w, h)
                draw.RoundedBox(4, 3, 0, w - 8, h * 2, Color(40, 40, 40))
            end
        end

        local panels = {weaponpanel, proppanel, entpanel, toolpanel, vehiclepanel}

        for _, sweppanel in pairs(panels) do
            local panelType
            if sweppanel == weaponpanel then
                panelType = "swep"
            elseif sweppanel == proppanel then
                panelType = "prop"
            elseif sweppanel == entpanel then
                panelType = "ent"
            elseif sweppanel == toolpanel then
                panelType = "tool"
            elseif sweppanel == vehiclepanel then
                panelType = "vehicle"
            end

            local cl = {
                Color(48, 179, 255)
            }

            local sbar = sweppanel:GetVBar()
            function sbar:Paint(w, h)
                draw.RoundedBox(0, 0, 10, w, h - 20, Color(40, 40, 40))
            end
            function sbar.btnUp:Paint(w, h)
                draw.RoundedBox(w / 2 - 2, 0, 0, w, h, cl[1])
                draw.RoundedBox(0, 0, h / 2 + 1, w, h / 2, cl[1])
            end
            function sbar.btnDown:Paint(w, h)
                draw.RoundedBox(w / 2 - 2, 0, 0, w, h, cl[1])
                draw.RoundedBox(0, 0, 0, w, h / 2, cl[1])
            end
            function sbar.btnGrip:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, cl[1])
            end

            local linkedTable = table.Copy(rlr[panelType])
            if filter != nil then
                for k, v in pairs(linkedTable) do
                    if string.find(k, filter) == nil then
                        linkedTable[k] = nil
                    end
                end
            end

            /*local temp`Sort` = {}
            for k, v in pairs(linkedTable) do
                table.insert(tempSort, 1, {k, v})
            end

            table.sort(tempSort, function(a, b)
                print(a[1])
                print(b[1])
                print("\n")
                return a[1] > b[1]
            end)

            local newLinkedTable = {}
            for k, v in pairs(tempSort) do
                newLinkedTable[v[1]] = v[2]
            end*/

            local newLinkedTable = {}
            for k, v in pairsByKeys(linkedTable) do
                //print(k)
                //print(v)
                table.insert(newLinkedTable, { title = k, value = v })
            end

            if sortByRank == true then
                table.sort(newLinkedTable, function(a, b)
                    local a_val = rlr_config.roleIndex(a.value)
                    local b_val = rlr_config.roleIndex(b.value)
                    if a_val == b_val then return a.title < b.title else return a_val < b_val end
                end)
            end

            local swepPlace = 0
            for _, q in pairs(newLinkedTable) do
                local k = q.title
                local v = q.value
                swepPlace = swepPlace + 1
                local panel = vgui.Create("DPanel", sweppanel)
                panel:SetSize(tabs:GetWide() - 10, 25)
                panel:SetPos(0, (swepPlace - 1) * 30)
                panel.Paint = function(self, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(48, 179, 255))
                    draw.SimpleText(k, "DermaDefault", 8, h / 2, Color(20, 20, 20), 0, 1)
                end
                if table.Count(linkedTable) >= 13 then panel:SetSize(panel:GetWide() - 20, 25) end

                local list = vgui.Create("DComboBox", panel)
                list:SetSize(110, 21)
                list:SetPos(panel:GetWide() - 171, 2)
                list:SetSortItems(false)

                local defaultFound = false
                local noDefaultCounter = 0

                for l, x in pairs(rlr_config.roles.all) do
                    local default = false
                    if x == v then default = true; defaultFound = true end
                    list:AddChoice(x, rlr_config.roleIndex(x), default)
                end

                if defaultFound == false then
                    noDefaultCounter = noDefaultCounter + 1

                    list.Paint = function(s, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(255, 0, 0))
                    end

                    createdTabTable[panelType].Tab.Paint = function(s, w, h)
                        draw.RoundedBox(4, 3, 0, w - 8, h * 10, Color(255, 0, 0))
                    end
                else
                    list.Paint = function(s, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200))
                    end
                end

                list.OnSelect = function(index, value, data)
                    local info = {}
                    info.item = k
                    info.rank = data
                    info.type = panelType

                    net.Start("rl_modifyRestriction")
                    net.WriteTable(info)
                    net.SendToServer()

                    list.Paint = function(s, w, h)
                        draw.RoundedBox(4, 0, 0, w, h, Color(200, 200, 200))
                    end

                end

                local removeButton = vgui.Create("DButton", panel)
                removeButton:SetSize(16, 16)
                removeButton:SetPos(panel:GetWide() - 20, panel:GetTall() / 2 - removeButton:GetTall() / 2)
                removeButton:SetText("")
                removeButton.Paint = function(self, w, h)
                    surface.SetDrawColor(Color(255, 255, 255))
                    surface.SetMaterial(materials.remove)
                    surface.DrawTexturedRect(0, 0, w, h)
                end
                removeButton.DoClick = function()
                    table.remove(rlr[panelType], swepPlace)

                    local info = {}
                    info.item = k
                    info.type = panelType

                    net.Start("rl_deleteRestriction")
                    net.WriteTable(info)
                    net.SendToServer()
                end
            end

            local addButton = vgui.Create("DButton", sweppanel)
            addButton:SetSize(300, 20)
            addButton:SetPos(tabs:GetWide() / 2 - addButton:GetWide() / 2, table.Count(linkedTable) * 30 + 2)
            addButton:SetText("")
            addButton.Paint = function(self, w, h)
                if !currentlyModifying then
                    addButton:SetPos(tabs:GetWide() / 2 - 8, table.Count(linkedTable) * 30 + 2)
                    surface.SetDrawColor(Color(255, 255, 255))
                    surface.SetMaterial(materials.add)
                    surface.DrawTexturedRect(0, h / 2 - 8, 16, 16)
                else
                    addButton:SetPos(tabs:GetWide() / 2 - self:GetWide() / 2, table.Count(linkedTable) * 30 + 2)
                    draw.RoundedBox(4, 0, 0, w, h, Color(163, 21, 21))
                    draw.SimpleText("CURRENTLY MODIFYING IN '" .. string.upper(modifyType) .. "'", "DermaDefaultBold", w/2 - 1, h/2 - 1, Color(30, 30, 30), 1, 1)
                end
            end
            addButton.DoClick = function()
                if currentlyModifying == false then
                    currentlyModifying = true
                    rlr.createNewRestriction(sweppanel, panelType, linkedTable, tabs)
                end
            end
            if currentlyModifying and panelType == modifyType then
                rlr.createNewRestriction(sweppanel, panelType, linkedTable, tabs)
            end
        end
    end

    local searchBar = vgui.Create("DTextEntry", frame)
    searchBar:SetSize(frame:GetWide() - 10, 20)
    searchBar:SetPos(5, frame:GetTall() - searchBar:GetTall() - 5)
    searchBar:SetDrawBackground(false)
    searchBar:SetText("search")
    searchBar:SetUpdateOnType(true)
    function searchBar:OnValueChange(value)
        currFilter = value
        rlr.refreshMenu(tostring(value))
    end

    rlr.refreshMenu()
end

rlr.hasReceivedTable = rlr.hasReceivedTable or false

net.Receive("rl_openMenu", function()
    if rlr.hasReceivedTable == false then
        net.Start("rl_requestRedump")
        net.WriteBit(true)
        net.SendToServer()
    else
        rlr.openMenu()
    end
end)

net.Receive("rl_dumpTable", function()
    rlr.hasReceivedTable = true
    local info = net.ReadTable()
    rlr.ent = info.ent
    rlr.prop = info.prop
    rlr.swep = info.swep
    rlr.tool = info.tool
    rlr.vehicle = info.vehicle
end)

net.Receive("rl_confirmRestriction", function()
    local info = net.ReadTable()
    local rank = info.rank
    local item = info.item

    local white = Color(255, 255, 255)
    local blue = Color(48, 179, 255)

    local unpackTab = {white, "You have "}
    if info.person != nil then
        unpackTab = {team.GetColor(info.person:Team()), info.person:Nick(), white, " has "}
    end

    if info.change == "modify" or info.change == "add" then
        if rank != "*" then
            local displayrank = rlr_config.roleDisplay(rank)
            if info.person != LocalPlayer() then
                chat.AddText(team.GetColor(info.person:Team()), info.person:Nick(), white, " restricted (", info.type, ") ", blue, item, white, " to rank ", blue, displayrank, white, " and above.")
            else
                chat.AddText(white, "You restricted (", info.type, ") ", blue, item, white, " to rank ", blue, displayrank, white, " and above.")
            end
        else
            if info.person != LocalPlayer() then
                chat.AddText(team.GetColor(info.person:Team()), info.person:Nick(), white, " restricted (", info.type, ") ", blue, item, white, " from ", blue, "all ranks", white, ".")
            else
                chat.AddText(white, "You restricted (", info.type, ") ", blue, item, white, " from ", blue, "all ranks", white, ".")
            end
        end
        rlr[info.type][item] = rank
    end

    if info.change == "delete" then
        if info.person != LocalPlayer() then
            chat.AddText(team.GetColor(info.person:Team()), info.person:Nick(), white, " unrestricted (", info.type, ") ", blue, item, white, ".")
        else
            chat.AddText(white, "You unrestricted (", info.type, ") ", blue, item, white, ".")
        end
        rlr[info.type][item] = nil
    end

    if rlr_isMenuOpen then rlr.refreshMenu(currFilter) end
end)

net.Receive("rl_adminReloadedFiles", function()
    local target = net.ReadTable()[1]
    chat.AddText(Color(255, 255, 255), "Restriction files were reloaded by ", Color(48, 179, 255), target:Nick() or "(no admin)", Color(255, 255, 255), ".")

    if rlr_isMenuOpen then rlr.refreshMenu(currFilter) end
end)

if rlr_isMenuOpen then rlr_isMenuOpen = false; rlr.closeMenu() end
