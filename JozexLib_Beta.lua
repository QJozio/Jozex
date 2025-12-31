-- Jozex Auto Farm v1.8 (Auto Collect Tokens + Pathfinder)
-- Bee Swarm Simulator
-- Rayfield UI

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Jozex | Bee Swarm Simulator",
    LoadingTitle = "Jozex",
    LoadingSubtitle = "Auto Collect Tokens + Pathfinder",
    ConfigurationSaving = {Enabled = true, FolderName = "Jozex", FileName = "Settings"}
})

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local player = Players.LocalPlayer

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHRP() return getChar():WaitForChild("HumanoidRootPart") end
local function getHumanoid() return getChar():WaitForChild("Humanoid") end

getgenv().AutoFarm = false
getgenv().Field = "Sunflower Field"
getgenv().ConvertPercent = 95

-- Get field
local function getField()
    for _,v in pairs(workspace.FlowerZones:GetChildren()) do
        if v.Name == getgenv().Field then return v end
    end
end

-- Backpack percent
local function backpackPercent()
    local stats = player:FindFirstChild("CoreStats")
    if not stats then return 0 end
    return (stats.Pollen.Value / stats.Capacity.Value) * 100
end

-- Convert at hive
local function convertHive()
    local hrp = getHRP()
    if player:FindFirstChild("SpawnPos") then
        hrp.CFrame = player.SpawnPos.Value + Vector3.new(0,3,0)
        task.wait(0.3)
        local convertRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Convert")
        convertRemote:FireServer()
    end
end

-- Pathfinder walk
local function walkTo(pos)
    local hrp = getHRP()
    local humanoid = getHumanoid()
    local path = PathfindingService:CreatePath({AgentRadius=2, AgentHeight=5, AgentCanJump=true})
    path:ComputeAsync(hrp.Position, pos)
    path:MoveTo(hrp)
    path.TraverserFinished:Wait()
end

-- Find nearest token within radius
local function getNearestToken(radius)
    local hrp = getHRP()
    local nearest
    local minDist = radius
    for _, token in pairs(workspace:GetChildren()) do
        if token.Name:find("Token") and token:IsA("Part") then
            local dist = (token.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = token
            end
        end
    end
    return nearest
end

-- =======================
-- UI
-- =======================
local Tab = Window:CreateTab("🌼 Auto Farm", 4483362458)
Tab:CreateToggle({Name="Enable Auto Farm", CurrentValue=false, Callback=function(v) getgenv().AutoFarm=v end})
Tab:CreateDropdown({Name="Select Field", Options={"Sunflower Field","Blue Flower Field","Clover Field","Strawberry Field","Bamboo Field","Pine Tree Forest"}, CurrentOption="Sunflower Field", Callback=function(v) getgenv().Field=v end})
Tab:CreateSlider({Name="Convert At (%)", Range={60,100}, Increment=5, CurrentValue=95, Callback=function(v) getgenv().ConvertPercent=v end})

-- =======================
-- AUTO FARM LOOP
-- =======================
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().AutoFarm then
            local field = getField()
            if field then
                -- random walk near field
                local targetPos = field.Position + Vector3.new(math.random(-8,8),0,math.random(-8,8))
                walkTo(targetPos)

                -- auto collect token
                local token = getNearestToken(10)
                if token then
                    walkTo(token.Position + Vector3.new(0,3,0)) -- move close to token
                end
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

Rayfield:Notify({Title="Jozex Loaded", Content="Auto Farm + Auto Collect Tokens Active 🐝", Duration=5})