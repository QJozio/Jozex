-- Jozex Hive Hub Auto Farm v6.0 - Full Pack (Self-contained)
-- Bee Swarm Simulator
-- Rayfield UI
-- Auto teleport, auto claim hive, pathfinder, auto collect, auto convert, Info tab

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
getgenv().AutoFarm = false
getgenv().ConvertPercent = 95
local HIVEHUB_PLACEID = 15579077077  -- Hive Hub place ID

-- =======================
-- TELEPORT TO HIVE HUB IF NOT PRESENT
-- =======================
if not workspace:FindFirstChild("Hub Field") then
    TeleportService:Teleport(HIVEHUB_PLACEID, player)
    return
end

-- =======================
-- HELPER FUNCTIONS
-- =======================
local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getHumanoid() return getChar():WaitForChild("Humanoid") end

local function backpackPercent()
    local stats = player:FindFirstChild("CoreStats")
    if not stats then return 0 end
    return (stats.Pollen.Value / stats.Capacity.Value) * 100
end

local function convertHive()
    local hrp = getHRP()
    if player:FindFirstChild("SpawnPos") then
        hrp.CFrame = player.SpawnPos.Value + Vector3.new(0,3,0)
        task.wait(0.3)
        local convertRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Convert")
        convertRemote:FireServer()
    end
end

local function claimHive()
    if player:FindFirstChild("SpawnPos") == nil then
        local claimRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ClaimHub")
        claimRemote:FireServer()
        task.wait(1)
    end
end

local function walkTo(pos)
    local hrp = getHRP()
    local humanoid = getHumanoid()
    local path = PathfindingService:CreatePath({AgentRadius=2, AgentHeight=5, AgentCanJump=true})
    path:ComputeAsync(hrp.Position, pos)
    path:MoveTo(hrp)
    path.TraverserFinished:Wait()
end

local function getNearestPickup(radius)
    local hrp = getHRP()
    local nearest
    local minDist = radius
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name:find("Token") or v.Name:find("Pollen") then
            local dist = (v.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = v
            end
        end
    end
    return nearest
end

-- =======================
-- RAYFIELD UI
-- =======================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Jozex | Hive Hub Auto Farm",
    LoadingTitle = "Jozex",
    LoadingSubtitle = "Full Pack Auto Farm",
    ConfigurationSaving = {Enabled = true, FolderName = "Jozex", FileName = "HiveHubSettings"}
})

local Tab = Window:CreateTab("🌼 Auto Farm", 4483362458)
Tab:CreateToggle({Name="Enable Auto Farm", CurrentValue=false, Callback=function(v) getgenv().AutoFarm=v end})
Tab:CreateSlider({Name="Convert At (%)", Range={60,100}, Increment=5, CurrentValue=95, Callback=function(v) getgenv().ConvertPercent=v end})

local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)
InfoTab:CreateLabel({
    Name = "Bee Requirement",
    Text = "⚠️ You need at least 20 bees to use this script effectively.",
    TextSize = 16,
    TextColor = Color3.fromRGB(255, 200, 0)
})
InfoTab:CreateLabel({
    Name = "Usage Notes",
    Text = "This script automates Hive Hub farming.\nMake sure your Hive Hub is unlocked and you have enough bees for max efficiency.",
    TextSize = 14,
    TextColor = Color3.fromRGB(255, 255, 255)
})

Rayfield:Notify({Title="Jozex Hive Hub", Content="Auto Farm Full Pack Loaded 🐝", Duration=5})

-- =======================
-- AUTO FARM LOOP
-- =======================
task.spawn(function()
    while task.wait(0.3) do
        claimHive() -- auto claim if unclaimed
        if getgenv().AutoFarm then
            local hrp = getHRP()
            local hubField = workspace:FindFirstChild("Hub Field")
            if hubField then
                local targetPos = hubField.Position + Vector3.new(math.random(-6,6),0,math.random(-6,6))
                walkTo(targetPos)
            end

            local pickup = getNearestPickup(10)
            if pickup then
                walkTo(pickup.Position + Vector3.new(0,3,0))
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
            convertHive()
            task.wait(7)
        end
    end
end)