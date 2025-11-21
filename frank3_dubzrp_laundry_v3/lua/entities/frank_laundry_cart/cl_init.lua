
include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    if not SnowDubz_ShouldDraw or not SnowDubz_DrawPanel then return end
    if not SnowDubz_ShouldDraw(self) then return end

    local eye = LocalPlayer():EyeAngles()
    local ang = Angle(0, eye.y - 90, 90)
    local pos = self:GetPos() + Vector(0, 0, 30)

    local count = self.GetClothesCount and self:GetClothesCount() or 0
    local max   = self.GetMaxClothes and self:GetMaxClothes() or 20

    local status = "Waiting for clothes"
    local color  = Color(200,200,200)
    if count > 0 then
        status = "Press USE to cash out"
        color  = Color(120,255,120)
    end

    local frac = 0
    if max > 0 then
        frac = math.Clamp(count / max, 0, 1)
    end

    local lines = {
        {
            text  = "Each Dried Cloth",
            value = "+1",
            color = Color(200,200,200),
            dot   = true
        },
        {
            text  = "Closed Dryer Box",
            value = "+10",
            color = Color(255,255,120),
            dot   = true
        }
    }

    SnowDubz_DrawPanel(pos, ang, 0.07, 260, 120, {
        title        = "Laundry Cart",
        status       = status,
        statusColor  = color,
        progressFrac = frac,
        progressText = string.format("%d / %d Clothes", count, max),
        lines        = lines
    })
end
