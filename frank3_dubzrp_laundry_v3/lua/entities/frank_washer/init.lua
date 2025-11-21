
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
    self:SetOutputCount(0)
    self:SetHasDetergent(false)
    self:SetIsReady(false)
    self:SetIsRunning(false)
    self:SetStartTime(0)
    self:SetEndTime(0)

    self._useCooldown   = 0
    self._touchCooldown = 0
end

local function SetupSpawn(ply, tr, classname)
    if not tr.Hit then return end

    local ent = ents.Create(classname)
    if not IsValid(ent) then return end

    local ang = Angle(0, ply:EyeAngles().y, 0)
    ent:SetAngles(ang)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16)
    ent:Spawn()
    ent:Activate()

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    return ent
end

function ENT:SpawnFunction(ply, tr, classname)
    return SetupSpawn(ply, tr, classname or "frank_washer")
end

local function IsValidClothes(ent)
    return IsValid(ent) and ent:GetClass() == "frank_clothes" and (ent.ClothesState == "unwashed")
end

function ENT:AddUnwashedClothes(ent)
    if self:GetIsRunning() then return end
    local fill = self:GetFillCount()
    local required = self:GetRequiredFill()
    if fill >= required then return end

    self:SetFillCount(fill + 1)
    if IsValid(ent) then ent:Remove() end

    self:UpdateReadyState()
end

function ENT:AddDetergent(ent)
    if self:GetIsRunning() then return end
    if self:GetHasDetergent() then return end

    self:SetHasDetergent(true)
    if IsValid(ent) then ent:Remove() end

    self:UpdateReadyState()
end

function ENT:UpdateReadyState()
    if self:GetIsRunning() then
        self:SetIsReady(false)
        return
    end

    local hasClothes = self:GetFillCount() > 0 and self:GetFillCount() <= self:GetRequiredFill()
    self:SetIsReady(hasClothes and self:GetHasDetergent())
end

local function IsValidUse(ply)
    return IsValid(ply) and ply:IsPlayer() and ply:KeyPressed(IN_USE)
end

local function CreateClothes(state, pos, ang)
    local c = ents.Create("frank_clothes")
    if not IsValid(c) then return end

    c.ClothesState = state
    if state == "washed" and c.SetWasherSkin then
        c:SetWasherSkin()
    elseif state == "dried" and c.SetDriedSkin then
        c:SetDriedSkin()
    elseif state == "unwashed" and c.SetUnwashedSkin then
        c:SetUnwashedSkin()
    end

    c:SetPos(pos)
    c:SetAngles(ang)
    c:Spawn()
    local phys = c:GetPhysicsObject()
    if IsValid(phys) then
        phys:ApplyForceCenter(c:GetForward() * 120 + Vector(0,0,60))
    end
    return c
end

function ENT:DispenseOneCloth()
    if self:GetOutputCount() <= 0 then return end

    self:SetOutputCount(self:GetOutputCount() - 1)
    local origin = self:GetPos() + self:GetForward() * 30 + Vector(0, 0, 20)
    CreateClothes("washed", origin, self:GetAngles())
end

local function RunDuration(load, maxLoad)
    maxLoad = math.max(maxLoad or 1, 1)
    load = math.max(load or 0, 0)

    local fullLoadTime = 10
    local perItemTime = fullLoadTime / maxLoad
    local duration = load * perItemTime

    return math.Clamp(duration, 3, fullLoadTime)
end

function ENT:BeginCycle()
    local duration = RunDuration(self:GetFillCount(), self:GetRequiredFill())

    self:SetIsRunning(true)
    self:SetIsReady(false)
    self:SetStartTime(CurTime())
    self:SetEndTime(CurTime() + duration)

    self:EmitSound("buttons/button3.wav", 75, 100, 1, CHAN_AUTO)

    local loopSound = CreateSound(self, "ambient/machines/machine3.wav")
    if loopSound then
        loopSound:SetSoundLevel(70)
        loopSound:PlayEx(1, 100)
        self._loopSound = loopSound
    end

    local startAng = self:GetAngles()
    local pattern = {
        Angle(0.5, 0.4, -0.3),
        Angle(-0.4, -0.5, 0.5),
        Angle(0.6, -0.4, 0.3),
        Angle(-0.5, 0.4, -0.4)
    }
    local step = 1
    local shakeID = "Frank_WasherShake_" .. self:EntIndex()
    timer.Create(shakeID, 0.1, math.floor(duration / 0.1), function()
        if not IsValid(self) or not self:GetIsRunning() then
            timer.Remove(shakeID)
            return
        end
        self:SetAngles(startAng + pattern[step])
        step = step + 1
        if step > #pattern then step = 1 end
    end)

    timer.Simple(duration, function()
        if not IsValid(self) then return end
        self:FinishCycle()
    end)
end

function ENT:FinishCycle()
    if not self:GetIsRunning() then return end

    if self._loopSound then
        self._loopSound:FadeOut(0.5)
        timer.Simple(0.6, function()
            if IsValid(self._loopSound) then self._loopSound:Stop() end
            self._loopSound = nil
        end)
    end

    self:SetAngles(self._baseAng or self:GetAngles())

    local processed = self:GetFillCount()
    self:SetOutputCount(self:GetOutputCount() + processed)
    self:SetFillCount(0)
    self:SetHasDetergent(false)
    self:SetIsRunning(false)
    self:SetStartTime(0)
    self:SetEndTime(0)
    self:UpdateReadyState()

    self:EmitSound("buttons/button9.wav", 75, 100, 1, CHAN_AUTO)
end

function ENT:Use(ply)
    if not IsValidUse(ply) then return end
    if self._useCooldown > CurTime() then return end
    self._useCooldown = CurTime() + 0.2

    if self:GetOutputCount() > 0 then
        self:DispenseOneCloth()
        return
    end

    if self:GetIsRunning() then return end
    if not self:GetIsReady() then return end

    self._baseAng = self:GetAngles()
    self:BeginCycle()
end

function ENT:Touch(ent)
    if self._touchCooldown > CurTime() then return end
    if IsValidClothes(ent) then
        self._touchCooldown = CurTime() + 0.25
        self:AddUnwashedClothes(ent)
    elseif IsValid(ent) and ent:GetClass() == "frank_detergent" then
        self._touchCooldown = CurTime() + 0.25
        self:AddDetergent(ent)
    end
end

function ENT:Think()
    if self:GetIsRunning() and self:GetEndTime() > 0 and CurTime() >= self:GetEndTime() then
        self:FinishCycle()
    end

    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:OnRemove()
    if self._loopSound then
        self._loopSound:Stop()
        self._loopSound = nil
    end
end
