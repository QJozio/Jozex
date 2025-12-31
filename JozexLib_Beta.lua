-- HiveHub Auto Farm (Rayfield Edition)
-- Bee Swarm Simulator

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet(
    "https://sirius.menu/rayfield"))()

-- Window
local Window = Rayfield:CreateWindow({
    Name = "HiveHub | Bee Swarm Simulator",
    LoadingTitle = "HiveHub",
    LoadingSubtitle = "Rayfield UI",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HiveHub",
        FileName = "AutoFarm"
    }
})

-- Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

-- Variables
getgenv().AutoFarm = false
getgenv().Field = "Sunflower Field"
getgenv().ConvertAt = 95

-- Get Field Position
local function getField()
    for _,v in pairs(workspace.FlowerZones:GetChildren()) do
        if v.Name == getgenv().Field then
            return v.Position
        end
    end
end

-- Backpack %
local function backpackPercent()
    local stats = player.CoreStats
    return (stats.Pollen.Value / stats.Capacity.Value) * 100
end

------------------------------------------------
-- UI TAB
------------------------------------------------
local FarmTab = Window:CreateTab("🌼 Farming", 4483362458)

-- Toggle Auto Farm
FarmTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Callback = function(Value)
        getgenv().AutoFarm = Value
    end
})

-- Field Dropdown
FarmTab:CreateDropdown({
    Name = "Select Field",
    Options = {
        "Sunflower Field",
        "Blue Flower Field",
        "Clover Field",
        "Strawberry Field",
        "Pine Tree Forest",
        "Bamboo Field",
        "Spider Field",
        "Stump Field"
    },
    CurrentOption = "Sunflower Field",
    Callback = function(Value)
        getgenv().Field = Value
    end
})

-- Convert %
FarmTab:CreateSlider({
    Name = "Convert At (%)",
    Range = {50, 100},
    Increment = 5,
    CurrentValue = 95,
    Callback = function(Value)
        getgenv().ConvertAt = Value
    end
})

------------------------------------------------
-- FARM LOOP
------------------------------------------------
task.spawn(function()
    while true do
        if getgenv().AutoFarm then
            local pos = getField()
            if pos then
                hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            end
        end
        task.wait(0.25)
    end
end)

------------------------------------------------
-- CONVERT LOOP
------------------------------------------------
task.spawn(function()
    while true do
        if getgenv().AutoFarm and backpackPercent() >= getgenv().ConvertAt then
            hrp.CFrame = player.SpawnPos.Value
            task.wait(8)
        end
        task.wait(1)
    end
end)