
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local MODEL = "models/props_junk/garbage_plasticbottle002a.mdl"

function ENT:Initialize()
    self:SetModel(MODEL)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetUseType(SIMPLE_USE)
    self._nextPickup = 0
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
    return SetupSpawn(ply, tr, classname or "frank_detergent")
end

local function PickupUse(self, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if self:IsPlayerHolding() then return end

    if self._nextPickup > CurTime() then return end
    self._nextPickup = CurTime() + 0.2

    ply:PickupObject(self)
    self:EmitSound("physics/cardboard/cardboard_box_impact_soft"..math.random(1,7)..".wav", 60, 100)
end

local function IsValidUse(ply)
    return IsValid(ply) and ply:IsPlayer() and ply:KeyPressed(IN_USE)
end

function ENT:Use(ply)
    if not IsValidUse(ply) then return end
    PickupUse(self, ply)
end

function ENT:Think()
    if self._touchCooldown > CurTime() then
        self:NextThink(CurTime() + 0.1)
        return true
    end

    local pos = self:GetPos()
    for _, ent in ipairs(ents.FindInSphere(pos, 16)) do
        if IsValid(ent) and ent:GetClass() == "frank_washer" then
            ent:AddDetergent(self)
            break
        end
    end

    self._touchCooldown = CurTime() + 0.1
    self:NextThink(CurTime() + 0.2)
    return true
end

function ENT:Touch(ent)
    if self._touchCooldown > CurTime() then return end
    if IsValid(ent) and ent:GetClass() == "frank_washer" then
        self._touchCooldown = CurTime() + 0.1
        ent:AddDetergent(self)
    end
end
