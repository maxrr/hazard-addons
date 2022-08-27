include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

local hue = 0

function ENT:Initialize()
	self:SetModel("models/hunter/blocks/cube05x05x05.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetUseType(3)

    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        -- phys:Wake()
    end

    hook.Add("Think", "changeColorOnThink", function()
        if IsValid(self) then
            if hue > 360 then
                hue = 0
            end
            local color = HSVToColor(hue, 1, 1)
            self:SetColor(color)
            hue = hue + 0.5
        else
            hook.Remove("Think", "changeColorOnThink")
        end
    end)

end

// hook.Remove("Think", "changeColorOnThink")
