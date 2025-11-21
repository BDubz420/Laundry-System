
include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    if not SnowDubz_ShouldDraw or not SnowDubz_DrawPanel then return end
    if not SnowDubz_ShouldDraw(self) then return end

    local eye = LocalPlayer():EyeAngles()
    local ang = Angle(0, eye.y - 90, 90)
    local pos = self:GetPos() + Vector(0, 0, 30)

    local required   = self.GetRequiredFill and self:GetRequiredFill() or 5
    local fill       = self.GetFillCount and self:GetFillCount() or 0
    local stored     = self.GetOutputCount and self:GetOutputCount() or 0
    local hasSoap    = self.GetHasDetergent and self:GetHasDetergent()
    local running    = self.GetIsRunning and self:GetIsRunning()
    local ready      = self.GetIsReady and self:GetIsReady()
    local startTime  = self.GetStartTime and self:GetStartTime() or 0
    local endTime    = self.GetEndTime and self:GetEndTime() or 0
    local timeLeft   = math.max(0, endTime - CurTime())

    local status   = "Add Clothes"
    local color    = Color(255, 180, 180)

    if running then
        status = string.format("Washing... %.1fs", timeLeft)
        color  = Color(100, 200, 255)
    elseif stored > 0 then
        status = string.format("%d Washed Clothes Ready - Press USE", stored)
        color  = Color(120, 255, 120)
    elseif ready then
        status = "READY - Press USE"
        color  = Color(120, 255, 120)
    elseif fill > 0 and not hasSoap then
        status = "Need Detergent"
        color  = Color(255, 220, 120)
    elseif fill > 0 then
        status = "Add More Clothes or Start"
    end

    local lines = {
        {
            text  = "Capacity",
            value = string.format("Max %d Shirts", required),
            color = Color(180,255,200),
            dot   = true
        },
        {
            text  = "Detergent",
            value = hasSoap and "Added" or "Missing",
            color = hasSoap and Color(120, 255, 120) or Color(255,255,120),
            dot   = true
        },
        {
            text  = "Output",
            value = stored > 0 and string.format("%d Ready", stored) or "Washed Clothes",
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

    SnowDubz_DrawPanel(pos, ang, 0.07, 260, 130, {
        title        = "Washer",
        status       = status,
        statusColor  = color,
        progressFrac = frac,
        progressText = progressText,
        lines        = lines
    })
end
