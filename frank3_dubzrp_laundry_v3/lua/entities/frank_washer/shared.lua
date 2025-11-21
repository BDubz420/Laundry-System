
AddCSLuaFile()
AddCSLuaFile("cl_init.lua")

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"
ENT.PrintName = "Washer"
ENT.Author    = "frank3"
ENT.Category  = "DubzRP - frank3 addons"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Purpose = [[DubzRP addons made by frank3 - "Thank you for this opportunity"]]
ENT.Instructions = ""


function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "FillCount")
    self:NetworkVar("Int", 1, "RequiredFill")
    self:NetworkVar("Bool", 0, "HasDetergent")
    self:NetworkVar("Bool", 1, "IsReady")
    self:NetworkVar("Bool", 2, "IsRunning")
end
