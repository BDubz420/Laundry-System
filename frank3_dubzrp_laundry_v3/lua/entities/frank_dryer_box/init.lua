
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
