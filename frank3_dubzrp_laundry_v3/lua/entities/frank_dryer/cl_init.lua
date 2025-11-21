
include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    if not SnowDubz_ShouldDraw or not SnowDubz_DrawPanel then return end
    if not SnowDubz_ShouldDraw(self) then return end

    local eye = LocalPlayer():EyeAngles()
    local ang = Angle(0, eye.y - 90, 90)
    local pos = self:GetPos() + Vector(0, 0, 30)

    local required   = self.GetRequiredFill and self:GetRequiredFill() or 10
    local fill       = self.GetFillCount and self:GetFillCount() or 0
    local stored     = self.GetOutputCount and self:GetOutputCount() or 0
    local running    = self.GetIsRunning and self:GetIsRunning()
    local ready      = self.GetIsReady and self:GetIsReady()
    local startTime  = self.GetStartTime and self:GetStartTime() or 0
    local endTime    = self.GetEndTime and self:GetEndTime() or 0
    local timeLeft   = math.max(0, endTime - CurTime())

    local status   = "Add Washed Clothes"
    local color    = Color(255, 200, 160)

    if running then
        status = "Drying..."
        color  = Color(255, 220, 120)
    elseif stored > 0 then
        status = string.format("%d Dried Clothes Ready - Press USE", stored)
        color  = Color(120, 255, 120)
    elseif ready then
        status = "READY - Press USE"
        color  = Color(120, 255, 120)
    elseif fill > 0 then
        status = "Can Start - Press USE"
        color  = Color(200, 230, 120)
    end

    local lines = {
        {
            text  = "Capacity",
            value = string.format("%d / %d Shirts", fill, required),
            color = Color(180,255,200),
            dot   = true
        },
        {
            text  = "Output",
            value = stored > 0 and string.format("%d Ready", stored) or "Dried Clothes",
            color = Color(200,200,255),
            dot   = false
        }
    }

    local frac = 0
    local progressText = string.format("%d / %d Shirts", fill, required)
    if running and endTime > startTime then
        local duration = endTime - startTime
        frac = 1 - math.Clamp(timeLeft / duration, 0, 1)
        progressText = string.format("Time Left: %.1fs", timeLeft)
    elseif required > 0 then
        frac = math.Clamp(fill / required, 0, 1)
    end

    SnowDubz_DrawPanel(pos, ang, 0.07, 260, 120, {
        title        = "Dryer",
        status       = status,
        statusColor  = color,
        progressFrac = frac,
        progressText = progressText,
        lines        = lines
    })
end
