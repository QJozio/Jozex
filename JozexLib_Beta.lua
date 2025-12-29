--// Rayfield Loader
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Jozex Hub | MM2",
    LoadingTitle = "Jozex Hub",
    LoadingSubtitle = "MM2 Legit Edition",
    ConfigurationSaving = {Enabled = false}
})

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local AimTab = Window:CreateTab("Aimbot", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

--// Toggles / Settings
local AutoKill = false
local AutoShoot = false
local CoinFarm = false
local ESPEnabled = false

local AimbotEnabled = false
local AimbotFOV = 250
local AimbotSmooth = 0.15
local AimPriority = "Murderer"

--// Helpers
local function GetRole(plr)
    if plr.Character then
        if plr.Character:FindFirstChild("Knife") then
            return "Murderer"
        elseif plr.Character:FindFirstChild("Gun") then
            return "Sheriff"
        end
    end
    return "Innocent"
end

local function SafeActivate(tool)
    pcall(function()
        if tool and tool.Parent == LocalPlayer.Character then
            tool:Activate()
        end
    end)
end

--------------------------------------------------
-- ESP
--------------------------------------------------
local ESPObjects = {}

local function CreateESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] then return end
    pcall(function()
        local box = Drawing.new("Square")
        box.Thickness = 1
        box.Transparency = 1
        box.Visible = false
        ESPObjects[plr] = box
    end)
end

local function RemoveESP(plr)
    if ESPObjects[plr] then
        pcall(function() ESPObjects[plr]:Remove() end)
        ESPObjects[plr] = nil
    end
end

for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    for plr,box in pairs(ESPObjects) do
        if ESPEnabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
            if onscreen then
                local size = math.clamp(2000 / pos.Z, 20, 200)
                box.Size = Vector2.new(size, size * 1.5)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size)
                box.Visible = true

                local role = GetRole(plr)
                if role == "Murderer" then
                    box.Color = Color3.fromRGB(255,0,0)
                elseif role == "Sheriff" then
                    box.Color = Color3.fromRGB(0,0,255)
                else
                    box.Color = Color3.fromRGB(0,255,0)
                end
            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)

--------------------------------------------------
-- Aimbot
--------------------------------------------------
local function GetAimbotTarget()
    local best, bestDist = nil, math.huge
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
            if onscreen then
                local dist = (Vector2.new(pos.X, pos.Y) -
                             Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < AimbotFOV and dist < bestDist then
                    local role = GetRole(plr)
                    if AimPriority == "Nearest"
                    or (AimPriority == "Murderer" and role == "Murderer")
                    or (AimPriority == "Sheriff" and role == "Sheriff") then
                        best = hrp
                        bestDist = dist
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end
    local target = GetAimbotTarget()
    if target then
        local camPos = Camera.CFrame.Position
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(camPos, target.Position),
            AimbotSmooth
        )
    end
end)

--------------------------------------------------
-- Auto Coin Farm
--------------------------------------------------
task.spawn(function()
    while task.wait(0.5) do
        if CoinFarm and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _,coin in pairs(Workspace:GetDescendants()) do
                if coin.Name == "Coin_Server" and coin:IsA("BasePart") then
                    pcall(function()
                        LocalPlayer.Character.HumanoidRootPart.CFrame =
                            coin.CFrame + Vector3.new(0,2,0)
                    end)
                end
            end
        end
    end
end)

--------------------------------------------------
-- Auto Combat (Close Range)
--------------------------------------------------
task.spawn(function()
    while task.wait(0.25) do
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end

        for _,plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (char.HumanoidRootPart.Position -
                              plr.Character.HumanoidRootPart.Position).Magnitude
                if dist < 20 then
                    if AutoKill and char:FindFirstChild("Knife") then
                        SafeActivate(char.Knife)
                    elseif AutoShoot and char:FindFirstChild("Gun") then
                        SafeActivate(char.Gun)
                    end
                end
            end
        end
    end
end)

--------------------------------------------------
-- UI
--------------------------------------------------
CombatTab:CreateToggle({
    Name = "Auto Knife (Murderer)",
    CurrentValue = false,
    Callback = function(v) AutoKill = v end
})

CombatTab:CreateToggle({
    Name = "Auto Shoot (Sheriff)",
    CurrentValue = false,
    Callback = function(v) AutoShoot = v end
})

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Callback = function(v) ESPEnabled = v end
})

AimTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(v) AimbotEnabled = v end
})

AimTab:CreateDropdown({
    Name = "Aim Priority",
    Options = {"Murderer","Sheriff","Nearest"},
    CurrentOption = {"Murderer"},
    Callback = function(opt) AimPriority = opt[1] end
})

AimTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {50,600},
    Increment = 10,
    CurrentValue = 250,
    Callback = function(v) AimbotFOV = v end
})

AimTab:CreateSlider({
    Name = "Smoothness",
    Range = {0.05,0.5},
    Increment = 0.05,
    CurrentValue = 0.15,
    Callback = function(v) AimbotSmooth = v end
})

MiscTab:CreateToggle({
    Name = "Auto Collect Coins",
    CurrentValue = false,
    Callback = function(v) CoinFarm = v end
})

MiscTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16,50},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

MiscTab:CreateSlider({
    Name = "JumpPower",
    Range = {50,120},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v)
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end
})