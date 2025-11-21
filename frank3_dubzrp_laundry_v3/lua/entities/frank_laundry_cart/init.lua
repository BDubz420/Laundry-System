
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

    self._useCooldown   = 0
    self._touchCooldown = 0
end

local function SetupSpawn(ply, tr, classname)
    if not tr.Hit then return end

    local ent = ents.Create(classname)
    if not IsValid(ent) then return end

    local ang = Angle(0, ply:EyeAngles().y + 90, 0)
    ent:SetAngles(ang)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16)
    ent:Spawn()
    ent:Activate()

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    return ent
end

function ENT:SpawnFunction(ply, tr, classname)
    return SetupSpawn(ply, tr, classname or "frank_laundry_cart")
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
    if self._useCooldown > CurTime() then return end
    self._useCooldown = CurTime() + 0.2

    if self:GetClothesCount() <= 0 then return end

    local ent = self
    local totalClothes = self:GetClothesCount()
    local rewardPer    = math.random(3, 5)
    local total        = totalClothes * rewardPer
    local center       = ent:GetPos() + Vector(0,0,20)

    ent:EmitSound("buttons/bell1.wav", 75, 100, 1, CHAN_AUTO)

    if DarkRP and DarkRP.createMoneyBag then
        local remaining = total
        while remaining > 0 do
            local drop = math.min(10, remaining)
            remaining = remaining - drop
            local pos = center + Vector(math.random(-5,5), math.random(-5,5), 0)
            DarkRP.createMoneyBag(pos, drop)
        end
    end

    ent:SetClothesCount(0)
    ent:SetIsProcessing(false)
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

function ENT:Touch(ent)
    if self._touchCooldown > CurTime() then return end
    if not IsValid(ent) then return end

    if ent:GetClass() == "frank_clothes" and ent.ClothesState == "dried" then
        self._touchCooldown = CurTime() + 0.1
        self:AddDriedClothes(ent)
    elseif ent:GetClass() == "frank_dryer_box" then
        self._touchCooldown = CurTime() + 0.1
        self:AddClosedBox(ent)
    end
end
