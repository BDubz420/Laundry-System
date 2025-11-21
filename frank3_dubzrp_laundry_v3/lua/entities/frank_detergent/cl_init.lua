
include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    if not SnowDubz_ShouldDraw or not SnowDubz_DrawPanel then return end
    if not SnowDubz_ShouldDraw(self) then return end

    local eye = LocalPlayer():EyeAngles()
    local ang = Angle(0, eye.y - 90, 90)
    local pos = self:GetPos() + Vector(0, 0, 20)

    local lines = {
        {
            text  = "Use",
            value = "Pick Up",
            color = Color(180,255,200),
            dot   = true
        },
        {
            text  = "Goal",
            value = "Put into Washer",
            color = Color(255,255,120),
            dot   = false
        }
    }

    SnowDubz_DrawPanel(pos, ang, 0.06, 220, 100, {
        title        = "Detergent",
        status       = "Put into a Washer.",
        statusColor  = Color(150,200,255),
        progressFrac = 0,
        progressText = nil,
        lines        = lines
    })
end
