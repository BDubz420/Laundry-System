
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local MODEL = "models/props_wasteland/laundry_cart001.mdl"

function ENT:Initialize()
    self:SetModel(MODEL)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetUseType(SIMPLE_USE)

    self:SetClothesCount(0)
    self:SetMaxClothes(20)
    self:SetIsProcessing(false)
end

function ENT:AddDriedClothes(ent)
    if self:GetIsProcessing() then return false end
    local count = self:GetClothesCount()
    local max   = self:GetMaxClothes()
    if count >= max then return false end

    self:SetClothesCount(count + 1)
    if IsValid(ent) then ent:Remove() end

    self:EmitSound("physics/cardboard/cardboard_box_impact_soft"..math.random(1,7)..".wav", 70, 100, 1, CHAN_AUTO)
    return true
end

function ENT:AddClosedBox(ent)
    if self:GetIsProcessing() then return false end
    if not ent.IsClosed then return false end

    local count  = self:GetClothesCount()
    local max    = self:GetMaxClothes()
    local amount = ent.ClothesCount or 10

    if count + amount > max then return false end

    self:SetClothesCount(count + amount)
    ent:Remove()

    self:EmitSound("physics/cardboard/cardboard_box_impact_soft"..math.random(1,7)..".wav", 70, 100, 1, CHAN_AUTO)
    return true
end

local function IsValidUse(ply)
    return IsValid(ply) and ply:IsPlayer() and ply:KeyPressed(IN_USE)
end

function ENT:Use(ply)
    if not IsValidUse(ply) then return end
    if self:GetIsProcessing() then return end
    if self:GetClothesCount() < self:GetMaxClothes() then return end

    self:SetIsProcessing(true)
    self:EmitSound("buttons/bell1.wav", 75, 100, 1, CHAN_AUTO)

    local ent = self
    timer.Simple(10, function()
        if not IsValid(ent) then return end
        ent:EmitSound("items/ammo_pickup.wav", 75, 100, 1, CHAN_AUTO)

        local total = math.random(50, 100)
        total = math.floor(total / 10) * 10
        local center = ent:GetPos() + Vector(0,0,20)

        for i = 1, total, 10 do
            local pos = center + Vector(math.random(-5,5), math.random(-5,5), 0)
            if DarkRP and DarkRP.createMoneyBag then
                DarkRP.createMoneyBag(pos, 10)
            end
        end

        ent:SetClothesCount(0)
        ent:SetIsProcessing(false)
    end)
end

function ENT:Think()
    local pos = self:GetPos()
    for _, ent in ipairs(ents.FindInSphere(pos, 24)) do
        if IsValid(ent) and ent:GetClass() == "frank_dryer_box" then
            self:AddClosedBox(ent)
        end
    end

    self:NextThink(CurTime() + 0.3)
    return true
end
