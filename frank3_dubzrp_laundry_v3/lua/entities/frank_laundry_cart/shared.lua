
AddCSLuaFile()
AddCSLuaFile("cl_init.lua")

ENT.Type      = "anim"
ENT.Base      = "base_gmodentity"
ENT.PrintName = "Laundry Cart"
ENT.Author    = "frank3"
ENT.Category  = "Franks Laundry System"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Purpose = [[DubzRP addons made by frank3 - "Thank you for this opportunity"]]
ENT.Instructions = ""


function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ClothesCount")
    self:NetworkVar("Int", 1, "MaxClothes")
    self:NetworkVar("Bool", 0, "IsProcessing")
end
