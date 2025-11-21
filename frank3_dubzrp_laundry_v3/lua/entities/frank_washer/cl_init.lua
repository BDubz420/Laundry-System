
include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    if not SnowDubz_ShouldDraw or not SnowDubz_DrawPanel then return end
    if not SnowDubz_ShouldDraw(self) then return end

    local eye = LocalPlayer():EyeAngles()
    local ang = Angle(0, eye.y - 90, 90)
    local pos = self:GetPos() + Vector(0, 0, 30)

    local required = self.GetRequiredFill and self:GetRequiredFill() or 5
    local fill     = self.GetFillCount and self:GetFillCount() or 0

    local status   = "Add Clothes"
    local color    = Color(255, 180, 180)

    if self.GetIsRunning and self:GetIsRunning() then
        status = "Washing..."
        color  = Color(100, 200, 255)
    elseif self.GetIsReady and self:GetIsReady() then
        status = "READY - Press USE"
        color  = Color(120, 255, 120)
    elseif fill >= required then
        if self.GetHasDetergent and self:GetHasDetergent() then
            status = "Press USE to Wash"
            color  = Color(200, 255, 200)
        else
            status = "Add Detergent"
            color  = Color(255, 220, 120)
        end
    elseif fill > 0 and (not self.GetHasDetergent or not self:GetHasDetergent()) then
        status = "Add Clothes + Detergent"
    end

    local lines = {
        {
            text  = "Required Clothes",
            value = string.format("%d Shirts", required),
            color = Color(180,255,200),
            dot   = true
        },
        {
            text  = "Detergent",
            value = "1 Bottle",
            color = Color(255,255,120),
            dot   = true
        },
        {
            text  = "Output",
            value = "5 Washed Clothes",
            color = Color(200,200,255),
            dot   = false
        }
    }

    local frac = 0
    if required > 0 then
        frac = math.Clamp(fill / required, 0, 1)
    end

    SnowDubz_DrawPanel(pos, ang, 0.07, 260, 130, {
        title        = "Washer",
        status       = status,
        statusColor  = color,
        progressFrac = frac,
        progressText = string.format("%d / %d Shirts", fill, required),
        lines        = lines
    })
end
