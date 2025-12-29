-- Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Jozex Hub | MM2",
    LoadingTitle = "Jozex Hub",
    LoadingSubtitle = "MM2 Edition",
    ConfigurationSaving = {Enabled = false}
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Tabs
local CombatTab = Window:CreateTab("Combat", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- Toggles
local AutoKill = false
local AutoShoot = false
local CoinFarm = false
local ESPEnabled = false

-------------------------------------------------
-- ROLE DETECTION
-------------------------------------------------
local function GetRole(player)
    if player.Character then
        if player.Character:FindFirstChild("Knife") then
            return "Murderer"
        elseif player.Character:FindFirstChild("Gun") then
            return "Sheriff"
        end
    end
    return "Innocent"
end

-------------------------------------------------
-- ESP
-------------------------------------------------
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Thickness = 1
    box.Transparency = 1
    box.Color = Color3.new(1,1,1)
    ESPObjects[player] = box
end

local function RemoveESP(player)
    if ESPObjects[player] then
        ESPObjects[player]:Remove()
        ESPObjects[player] = nil
    end
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

for _,p in pairs(Players:GetPlayers()) do
    CreateESP(p)
end

RunService.RenderStepped:Connect(function()
    for player,box in pairs(ESPObjects) do
        if ESPEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local size = math.clamp(2000 / pos.Z, 20, 200)
                box.Size = Vector2.new(size, size * 1.5)
                box.Position = Vector2.new(pos.X - size/2, pos.Y - size)
                box.Visible = true

                local role = GetRole(player)
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

-------------------------------------------------
-- AUTO COINS
-------------------------------------------------
task.spawn(function()
    while task.wait(0.5) do
        if CoinFarm then
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

-------------------------------------------------
-- AUTO KILL / SHOOT
-------------------------------------------------
task.spawn(function()
    while task.wait(0.2) do
        if AutoKill or AutoShoot then
            local char = LocalPlayer.Character
            if not char then continue end

            for _,plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (char.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude

                    if dist < 25 then
                        if AutoKill and GetRole(Local