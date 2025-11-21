
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local MODEL = "models/props/cs_assault/washer_box.mdl"

function ENT:Initialize()
    self:SetModel(MODEL)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetUseType(SIMPLE_USE)
    self.UseCount = 0
end

local function IsValidUse(ply)
    return IsValid(ply) and ply:IsPlayer() and ply:KeyPressed(IN_USE)
end

local function BreakLikeBox(ent)
    if not IsValid(ent) then return end
    local pos, ang = ent:GetPos(), ent:GetAngles()

    local crate = ents.Create("prop_physics")
    if IsValid(crate) then
        crate:SetModel("models/props_junk/wood_crate001a.mdl")
        crate:SetPos(pos)
        crate:SetAngles(ang)
        crate:Spawn()
        crate:Fire("break", "", 0)
    end

    sound.Play("physics/wood/wood_box_break1.wav", pos, 75, 100, 1)
    ent:Remove()
end

function ENT:Use(ply)
    if not IsValidUse(ply) then return end

    self.UseCount = self.UseCount + 1
    self:EmitSound("physics/cardboard/cardboard_box_impact_soft"..math.random(1,7)..".wav", 70, 100, 1, CHAN_AUTO)

    if self.UseCount >= 2 then
        local count   = math.random(5, 10)
        local origin  = self:GetPos() + self:GetForward() * 20 + Vector(0, 0, 20)
        local forward = self:GetForward()

        for i = 1, count do
            local delay = 0.08 * (i-1)
            timer.Simple(delay, function()
                local c = ents.Create("frank_clothes")
                if IsValid(c) then
                    c.ClothesState = "unwashed"
                    if c.SetUnwashedSkin then c:SetUnwashedSkin() end
                    c:SetPos(origin + forward * (i*6))
                    c:Spawn()
                    local phys = c:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:ApplyForceCenter(forward * 200 + Vector(0,0,80))
                    end
                end
            end)
        end

        BreakLikeBox(self)
    end
end
