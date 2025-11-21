
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local MODEL_OPEN   = "models/props/cs_assault/dryer_box2.mdl"
local MODEL_CLOSED = "models/props/cs_assault/dryer_box.mdl"

function ENT:Initialize()
    self.IsClosed = false
    self.ClothesCount = 0
    self:SetModel(MODEL_OPEN)

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetUseType(SIMPLE_USE)
    self._touchCooldown = 0
end

local function SetupSpawn(ply, tr, classname)
    if not tr.Hit then return end

    local ent = ents.Create(classname)
    if not IsValid(ent) then return end

    local ang = Angle(0, ply:EyeAngles().y, 0)
    ent:SetAngles(ang)
    ent:SetPos(tr.HitPos + tr.HitNormal * 12)
    ent:Spawn()
    ent:Activate()

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    return ent
end

function ENT:SpawnFunction(ply, tr, classname)
    return SetupSpawn(ply, tr, classname or "frank_dryer_box")
end

function ENT:AddDriedClothes(ent)
    if self.IsClosed then return false end
    if self.ClothesCount >= 10 then return false end

    self.ClothesCount = self.ClothesCount + 1
    if IsValid(ent) then ent:Remove() end

    if self.ClothesCount >= 10 then
        self:CloseBox()
    end

    return true
end

function ENT:CloseBox()
    if self.IsClosed then return end
    self.IsClosed = true
    self:SetModel(MODEL_CLOSED)
end

local function IsValidUse(ply)
    return IsValid(ply) and ply:IsPlayer() and ply:KeyPressed(IN_USE)
end

function ENT:Use(ply)
    if not IsValidUse(ply) then return end
    if not self.IsClosed and self.ClothesCount > 0 then
        self:CloseBox()
    end
end

function ENT:Touch(ent)
    if self._touchCooldown > CurTime() then return end
    if not IsValid(ent) then return end

    if ent:GetClass() == "frank_clothes" and ent.ClothesState == "dried" then
        self._touchCooldown = CurTime() + 0.1
        self:AddDriedClothes(ent)
    end
end
