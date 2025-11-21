
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local MODEL = "models/props_c17/FurnitureWashingmachine001a.mdl"

function ENT:Initialize()
    self:SetModel(MODEL)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetUseType(SIMPLE_USE)

    self:SetFillCount(0)
    self:SetRequiredFill(5)
    self:SetHasDetergent(false)
    self:SetIsReady(false)
    self:SetIsRunning(false)
end

function ENT:AddUnwashedClothes(ent)
    if self:GetIsRunning() then return end
    local fill = self:GetFillCount()
    local required = self:GetRequiredFill()
    if fill >= required then return end

    self:SetFillCount(fill + 1)
    if IsValid(ent) then ent:Remove() end

    if self:GetFillCount() >= required and self:GetHasDetergent() then
        self:SetIsReady(true)
    end
end

function ENT:AddDetergent(ent)
    if self:GetIsRunning() then return end
    if self:GetHasDetergent() then return end

    self:SetHasDetergent(true)
    if IsValid(ent) then ent:Remove() end

    if self:GetFillCount() >= self:GetRequiredFill() then
        self:SetIsReady(true)
    end
end

local function IsValidUse(ply)
    return IsValid(ply) and ply:IsPlayer() and ply:KeyPressed(IN_USE)
end

function ENT:Use(ply)
    if not IsValidUse(ply) then return end
    if self:GetIsRunning() then return end
    if not self:GetIsReady() then return end

    self:SetIsRunning(true)
    self:SetIsReady(false)

    self:EmitSound("buttons/button3.wav", 75, 100, 1, CHAN_AUTO)

    local loopSound = CreateSound(self, "ambient/machines/machine3.wav")
    if loopSound then
        loopSound:SetSoundLevel(70)
        loopSound:PlayEx(1, 100)
        self._loopSound = loopSound
    end

    local startPos = self:GetPos()
    local startAng = self:GetAngles()
    self._basePos  = startPos
    self._baseAng  = startAng

    local pattern = {
        Angle(0.5, 0.4, -0.3),
        Angle(-0.4, -0.5, 0.5),
        Angle(0.6, -0.4, 0.3),
        Angle(-0.5, 0.4, -0.4)
    }
    local step = 1
    local shakeID = "Frank_WasherShake_" .. self:EntIndex()
    timer.Create(shakeID, 0.1, math.floor(10 / 0.1), function()
        if not IsValid(self) or not self:GetIsRunning() then
            timer.Remove(shakeID)
            return
        end
        self:SetAngles(startAng + pattern[step])
        step = step + 1
        if step > #pattern then step = 1 end
    end)

    timer.Simple(10, function()
        if not IsValid(self) then return end

        if self._loopSound then
            self._loopSound:FadeOut(0.5)
            timer.Simple(0.6, function()
                if IsValid(self._loopSound) then self._loopSound:Stop() end
                self._loopSound = nil
            end)
        end

        self:SetPos(startPos)
        self:SetAngles(startAng)

        self:EmitSound("buttons/button9.wav", 75, 100, 1, CHAN_AUTO)

        local origin = self:GetPos() + self:GetForward() * 30 + Vector(0, 0, 20)
        for i = 1, 5 do
            timer.Simple(0.1 * (i-1), function()
                if not IsValid(self) then return end
                local c = ents.Create("frank_clothes")
                if IsValid(c) then
                    c.ClothesState = "washed"
                    if c.SetWasherSkin then c:SetWasherSkin() end
                    c:SetPos(origin + self:GetForward() * (i*8))
                    c:Spawn()
                    local phys = c:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:ApplyForceCenter(self:GetForward() * 200 + Vector(0,0,80))
                    end
                end
            end)
        end

        self:SetFillCount(0)
        self:SetHasDetergent(false)
        self:SetIsRunning(false)
    end)
end

function ENT:OnRemove()
    if self._loopSound then
        self._loopSound:Stop()
        self._loopSound = nil
    end
end
