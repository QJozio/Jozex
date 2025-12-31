-- Jozex Auto Farm v1.3 (Final Refined)
-- Bee Swarm Simulator
-- Rayfield UI

-- =======================
-- LOAD RAYFIELD
-- =======================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Jozex | Bee Swarm Simulator",
    LoadingTitle = "Jozex",
    LoadingSubtitle = "Final Refined Auto Farm",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Jozex",
        FileName = "Settings"
    }
})

-- =======================
-- SERVICES & PLAYER
-- =======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function getChar()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
    local char = getChar()
    return char:WaitForChild("HumanoidRootPart")
end

-- =======================
-- GLOBAL VARIABLES
-- =======================
getgenv().AutoFarm = false
getgenv().SelectedField = "Sunflower Field"
getgenv().ConvertPercent = 95

-- =======================
-- HELPER FUNCTIONS
-- =======================
local function getFieldCFrame()
    for _, field in pairs(workspace.FlowerZones:GetChildren()) do
        if field.Name == getgenv().SelectedField then
            return field.CFrame
        end
    end
    return nil
end

local function backpackPercent()
    local stats = player:FindFirstChild("CoreStats")
    if not stats then return 0 end
    return (stats.Pollen.Value / stats.Capacity.Value) * 100
end

local function goToHive()
    if player:FindFirstChild("SpawnPos") then
        getHRP().CFrame = player.SpawnPos.Value + Vector3.new(0,3,0)
    end
end

-- =======================
-- UI SETUP
-- =======================
local FarmTab = Window:CreateTab("🌼 Auto Farm", 4483362458)

FarmTab:CreateToggle({
    Name = "Enable Auto Farm",
    CurrentValue = false,
    Callback = function(v)
        getgenv().AutoFarm = v
    end
})

FarmTab:CreateDropdown({
    Name = "Select Field",
    Options = {
        "Sunflower Field",
        "Blue Flower Field",
        "Clover Field",
        "Strawberry Field",
        "Bamboo Field",
        "Pine Tree Forest",
        "Spider Field"
    },
    CurrentOption = "Sunflower Field",
    Callback = function(v)
        getgenv().SelectedField = v
    end
})

FarmTab:CreateSlider({
    Name = "Convert At (%)",
    Range = {60, 100},
    Increment = 5,
    CurrentValue = 95,
    Callback = function(v)
        getgenv().ConvertPercent = v
    end
})

-- =======================
-- AUTO FARM LOOP
-- =======================
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().AutoFarm then
            local cf = getFieldCFrame()
            if cf then
                local hrp = getHRP()
                -- Smooth, random offset to avoid detection / stuck
                local offset = Vector3.new(
                    math.random(-5,5),
                    3,
                    math.random(-5,5)
                )
                hrp.CFrame = CFrame.new(cf.Position + offset)
            end
        end
    end
end)

-- =======================
-- AUTO CONVERT LOOP
-- =======================
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoFarm and backpackPercent() >= getgenv().ConvertPercent then
            goToHive()
            task.wait(7)
        end
    end
end)

-- =======================
-- NOTIFICATION
-- =======================
Rayfield:Notify({
    Title = "Jozex Loaded",
    Content = "Final Refined Auto Farm Ready 🐝",
    Duration = 4
})