-- [[ JOZEX FIELD SELECTION MODULE ]] --
local FieldOptions = {
    ["Sunflower Field"] = Vector3.new(-208, 4, 185),
    ["Mushroom Field"] = Vector3.new(-94, 4, 116),
    ["Dandelion Field"] = Vector3.new(-30, 4, 225),
    ["Blue Flower Field"] = Vector3.new(114, 4, 101),
    ["Clover Field"] = Vector3.new(174, 34, 189),
    ["Spider Field"] = Vector3.new(-372, 20, 124),
    ["Bamboo Field"] = Vector3.new(93, 20, -25),
    ["Strawberry Field"] = Vector3.new(-169, 20, -3),
    ["Pine Tree Forest"] = Vector3.new(-317, 70, -215),
    ["Rose Field"] = Vector3.new(-322, 20, 124)
}

-- Create the UI Section (Example integration into your Lib)
local FieldCategory = Main:CreateCategory("Field Options")

local SelectedField = "None"

FieldCategory:CreateDropdown("Select Field", {"Sunflower", "Mushroom", "Blue Flower", "Clover", "Spider", "Bamboo", "Pine Tree", "Rose"}, function(choice)
    SelectedField = choice
    print("Jozex: Selected Field changed to " .. choice)
end)

FieldCategory:CreateButton("Teleport to Field", function()
    local targetPos = FieldOptions[SelectedField .. " Field"] or FieldOptions[SelectedField]
    
    if targetPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Smooth Teleport (Prevents kick)
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
        
        -- Reset Stat Tracker for the new field
        StartHoney = LocalPlayer.CoreStats.Honey.Value
        StartTime = tick()
        print("Jozex: Stats reset for " .. SelectedField)
    else
        warn("Please select a field first!")
    end
end)