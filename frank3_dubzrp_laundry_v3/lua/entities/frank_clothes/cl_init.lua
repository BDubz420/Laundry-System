
include("shared.lua")

local function GetStateTitle(ent)
    local mat = ent:GetMaterial() or ""
    if mat == "models/props_canal/canal_bridge_railing_01b" then
        return "Unwashed Clothes", Color(255,180,180)
    elseif mat == "models/props_building_details/courtyard_template001c_bars" then
        return "Washed Clothes", Color(180,220,255)
    else
        return "Dried Clothes", Color(180,255,180)
    end
end

function ENT:Draw()
    self:DrawModel()
    if not SnowDubz_ShouldDraw or not SnowDubz_DrawPanel then return end
    if not SnowDubz_ShouldDraw(self) then return end

    local title, col = GetStateTitle(self)

    local eye = LocalPlayer():EyeAngles()
    local ang = Angle(0, eye.y - 90, 90)
    local pos = self:GetPos() + Vector(0, 0, 18)

    local lines = {
        {
            text  = "Use",
            value = "Pick Up",
            color = Color(200,200,200),
            dot   = true
        }
    }

    SnowDubz_DrawPanel(pos, ang, 0.06, 220, 90, {
        title        = title,
        status       = "Carry to the next machine",
        statusColor  = col,
        progressFrac = 0,
        progressText = nil,
        lines        = lines
    })
end
