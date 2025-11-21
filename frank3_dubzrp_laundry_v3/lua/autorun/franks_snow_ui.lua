-- franks: Dubz-style 3D2D UI helper
if not CLIENT then return end

if not DubzSnowFonts then
    DubzSnowFonts = true

    surface.CreateFont("SnowDubz_Big", {
        font = "Roboto",
        size = 32,
        weight = 800,
        antialias = true,
        extended = true
    })

    surface.CreateFont("SnowDubz_Medium", {
        font = "Roboto",
        size = 22,
        weight = 600,
        antialias = true,
        extended = true
    })

    surface.CreateFont("SnowDubz_Small", {
        font = "Roboto",
        size = 17,
        weight = 500,
        antialias = true,
        extended = true
    })
end

CreateClientConVar("snp_debugui", "0", false, false, "franks snow ui debug")

local MAX_DIST = 250

function SnowDubz_ShouldDraw(ent)
    if not IsValid(ent) then return false end
    local lp = LocalPlayer()
    if not IsValid(lp) then return false end
    local d2 = lp:GetPos():DistToSqr(ent:GetPos())
    if d2 > MAX_DIST * MAX_DIST then return false end
    return true
end

function SnowDubz_DrawPanel(pos, ang, scale, w, h, args)
    local bgCol     = Color(0, 0, 0, 120)
    local outline   = Color(0, 190, 255, 255)
    local shadowCol = Color(0, 0, 0, 120)

    if GetConVar("snp_debugui"):GetBool() then
        bgCol   = Color(40, 0, 0, 230)
        outline = Color(255, 0, 0, 255)
    end

    cam.Start3D2D(pos, ang, scale)
        -- Slightly inset shadow so it doesn't peek out
        surface.SetDrawColor(shadowCol)
        surface.DrawRect(-w/2 + 4, -h/2 + 4, w - 4, h - 4)

        -- Main background
        draw.RoundedBox(8, -w/2 + 1, -h/2 + 1, w - 2, h - 2, bgCol)

        -- Clean outline (2px) matching the background box
        surface.SetDrawColor(outline)
        surface.DrawOutlinedRect(-w/2 + 1, -h/2 + 1, w - 2, h - 2, 2)

        -- Left accent bar, also inset so it doesn't bleed beyond outline
        surface.DrawRect(-w/2 + 3, -h/2 + 3, 5, h - 6)

        if args.title then
            draw.SimpleText(string.upper(args.title), "SnowDubz_Big",
                0, -h/2 + 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end

        if args.status then
            draw.SimpleText(args.status, "SnowDubz_Medium",
                0, -h/2 + 42, args.statusColor or color_white,
                TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end

        local lines = args.lines
        if istable(lines) and #lines > 0 then
            local baseY = -h/2 + 70
            for i, line in ipairs(lines) do
                local y = baseY + (i - 1) * 16
                local col   = line.color or Color(200, 200, 200)
                local text  = line.text  or ""
                local value = line.value or ""

                if line.dot then
                    draw.RoundedBox(4, -w/2 + 12, y - 4, 8, 8, col)
                end

                draw.SimpleText(text, "SnowDubz_Small",
                    -w/2 + 28, y, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                if value ~= "" then
                    draw.SimpleText(value, "SnowDubz_Small",
                        w/2 - 12, y, col, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                end
            end
        end

        local frac = args.progressFrac or 0
        if frac > 0 then
            frac = math.Clamp(frac, 0, 1)
            local barW, barH = w - 40, 14
            local barY = h/2 - 26

            draw.RoundedBox(4, -barW/2, barY, barW, barH, Color(20, 20, 32, 255))
            draw.RoundedBox(4, -barW/2, barY, barW * frac, barH, outline)

            if args.progressText then
                draw.SimpleText(args.progressText, "SnowDubz_Small",
                    0, barY + barH/2, color_white,
                    TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        if GetConVar("snp_debugui"):GetBool() then
            draw.SimpleText("(UI)", "SnowDubz_Small",
                -w/2 + 10, h/2 - 18, Color(200,200,200),
                TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end

-- Default "front" panel orientation based on entity angles
function SnowDubz_GetPanelAngle(ent)
    local ang = ent:GetAngles()
    ang:RotateAroundAxis(ang:Right(), -90)
    ang:RotateAroundAxis(ang:Up(), 90)
    return ang
end
