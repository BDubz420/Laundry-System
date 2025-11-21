
if SERVER then
    local category = "DubzRP - frank3 addons"
    local infoText = [[DubzRP addons made by frank3 - "Thank you for this opportunity"]]
    local iconModel = "models/items/boxbuckshot.mdl"

    local function addEnt(name, class)
        list.Set("SpawnableEntities", class, {
            PrintName = name,
            ClassName = class,
            Category = category,
            Model = iconModel,
            Information = infoText,
            Author = "frank3"
        })
    end

    addEnt("Washer", "frank_washer")
    addEnt("Dryer", "frank_dryer")
    addEnt("Washer Box", "frank_washer_box")
    addEnt("Dryer Box", "frank_dryer_box")
    addEnt("Detergent", "frank_detergent")
    addEnt("Clothes", "frank_clothes")
    addEnt("Laundry Cart", "frank_laundry_cart")
end
