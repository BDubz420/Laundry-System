
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local MODEL = "models/props/de_tides/vending_tshirt.mdl"

function ENT:Initialize()
    self:SetModel(MODEL)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetUseType(SIMPLE_USE)
    self._nextPickup = 0
    self._nextTouch  = 0

    if not self.ClothesState then
        self.ClothesState = "unwashed"
    end

    if self.ClothesState == "unwashed" then
        self:SetUnwashedSkin()
    elseif self.ClothesState == "washed" then
        self:SetWasherSkin()
    elseif self.ClothesState == "dried" then
        self:SetDriedSkin()
    end
end

local function TryDeposit(self, ent)
    if not IsValid(ent) then return false end

    local class = ent:GetClass()
    local state = self.ClothesState or "dried"

    if state == "unwashed" and class == "frank_washer" then
        ent:AddUnwashedClothes(self)
        return true
    elseif state == "washed" and class == "frank_dryer" then
        ent:AddWashedClothes(self)
        return true
    elseif state == "dried" then
        if class == "frank_dryer_box" then
            return ent.AddDriedClothes and ent:AddDriedClothes(self)
        elseif class == "frank_laundry_cart" then
            return ent.AddDriedClothes and ent:AddDriedClothes(self)
        end
    end

    return false
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
    return SetupSpawn(ply, tr, classname or "frank_clothes")
end

function ENT:SetUnwashedSkin()
    self:SetMaterial("models/props_canal/canal_bridge_railing_01b")
    self.ClothesState = "unwashed"
end

function ENT:SetWasherSkin()
    self:SetMaterial("models/props_building_details/courtyard_template001c_bars")
    self.ClothesState = "washed"
end

function ENT:SetDriedSkin()
    self:SetMaterial("")
    self.ClothesState = "dried"
end

local function PickupUse(self, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if self:IsPlayerHolding() then return end

    if self._nextPickup > CurTime() then return end
    self._nextPickup = CurTime() + 0.2

    ply:PickupObject(self)

    if self.ClothesState == "washed" then
        self:EmitSound("ambient/water/water_slosh4.wav", 70, 100)
    else
        self:EmitSound("physics/cardboard/cardboard_box_impact_soft"..math.random(1,7)..".wav", 60, 100)
    end
end

local function IsValidUse(ply)
    return IsValid(ply) and ply:IsPlayer() and ply:KeyPressed(IN_USE)
end

function ENT:Use(ply)
    if not IsValidUse(ply) then return end
    PickupUse(self, ply)
end

function ENT:Think()
    local pos = self:GetPos()
    local mat = self:GetMaterial() or ""
    local state = "dried"
    if mat == "models/props_canal/canal_bridge_railing_01b" then
        state = "unwashed"
    elseif mat == "models/props_building_details/courtyard_template001c_bars" then
        state = "washed"
    end

    if self._nextTouch > CurTime() then
        self:NextThink(CurTime() + 0.1)
        return true
    end

    for _, ent in ipairs(ents.FindInSphere(pos, 20)) do
        if TryDeposit(self, ent) then
            self._nextTouch = CurTime() + 0.1
            break
        end
    end

    self:NextThink(CurTime() + 0.2)
    return true
end

function ENT:Touch(ent)
    if self._nextTouch > CurTime() then return end
    if TryDeposit(self, ent) then
        self._nextTouch = CurTime() + 0.1
    end
end
