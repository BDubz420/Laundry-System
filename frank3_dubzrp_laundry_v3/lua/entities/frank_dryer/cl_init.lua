
include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    if not SnowDubz_ShouldDraw or not SnowDubz_DrawPanel then return end
    if not SnowDubz_ShouldDraw(self) then return end

    local eye = LocalPlayer():EyeAngles()
    local ang = Angle(0, eye.y - 90, 90)
    local pos = self:GetPos() + Vector(0, 0, 30)

    local required = self.GetRequiredFill and self:GetRequiredFill() or 10
    local fill     = self.GetFillCount and self:GetFillCount() or 0

    local status   = "Add Washed Clothes"
    local color    = Color(255, 200, 160)

    if self.GetIsRunning and self:GetIsRunning() then
        status = "Drying..."
        color  = Color(255, 220, 120)
    elseif self.GetIsReady and self:GetIsReady() then
        status = "READY - Press USE"
        color  = Color(120, 255, 120)
    elseif fill > 0 then
        status = "Loading..."
    end

    local lines = {
        {
            text  = "Required Clothes",
            value = string.format("%d Shirts", required),
            color = Color(180,255,200),
            dot   = true
        },
        {
            text  = "Output",
            value = "Dried Clothes",
            color = Color(200,200,255),
            dot   = false
        }
    }

    local frac = 0
    if required > 0 then
        frac = math.Clamp(fill / required, 0, 1)
    end

    SnowDubz_DrawPanel(pos, ang, 0.07, 260, 120, {
        title        = "Dryer",
        status       = status,
        statusColor  = color,
        progressFrac = frac,
        progressText = string.format("%d / %d Shirts", fill, required),
        lines        = lines
    })
end
