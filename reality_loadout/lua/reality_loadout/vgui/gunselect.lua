local PANEL = {}

function PANEL:Init()
    self:SetName("CUSTOM PANEL BIIIIITCH")
    self.sx = 0
    self.sy = 0

    self.CloseButton = vgui.Create("DButton", self):TDLib()
    self.CloseButton:SetSize(40, 40)
    self.CloseButton:SetText("BUTTONBUTTONBUTTON")
    self.CloseButton.DoClick = function()
        self:GetParent():Remove()
    end

    self.CloseButton:GetParent():TDLib():Background(Color(0, 255, 0, 50))
    self.CloseButton:GetParent():GetParent():TDLib():Background(Color(0, 0, 255, 50))

    self:TDLib()
    self:On("OnRemove", function()
        self:GetParent():Remove()
    end)
end

function PANEL:PerformLayout()
    //local pntx, pnty = self:GetParent():GetParent():GetPos()
    //local sx, sy = self:GetPos()
    //self.sx, self.sy = sx + pntx, sy + pnty

    //local btw = 40
    //self.CloseButton:SetPos(btw, 4)
    //self.CloseButton:SetText(btw)
    self.CloseButton:AlignRight(4)
    self.CloseButton:AlignTop(4)
    print(self.CloseButton:GetParent():GetParent())
end

function PANEL:Paint(w, h)
    //BSHADOWS.BeginShadow()
    //draw.RoundedBox(rll.theme.rnd, self.sx, self.sy, w, h, rll.theme.lightgrey)
    //BSHADOWS.EndShadow(1, 2, 2)
end

function PANEL:SetGunList(list)

end

function PANEL:GunChosen()

end

vgui.Register("RealityGunSelect", PANEL, "DScrollPanel")
