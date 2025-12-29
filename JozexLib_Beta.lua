--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- CONFIG
local AutoFarmEnabled = true
local StepSpeed = 16 -- humanoid walk speed per step
local CoinsCollected = 0
local CoinBagLimit = 40 -- max coins before reset

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JozexHubAutoFarmUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Darker, slightly transparent background
local Background = Instance.new("Frame")
Background.Size = UDim2.new(1,0,1,0)
Background.Position = UDim2.new(0,0,0,0)
Background.BackgroundColor3 = Color3.fromRGB(0,0,0) -- black
Background.BackgroundTransparency = 0.4 -- slightly transparent
Background.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0,400,0,50)
Title.Position = UDim2.new(0.5, -200, 0.5, -25)
Title.BackgroundTransparency = 1
Title.Text = "Jozex Hub MM2 AutoFarm"
Title.TextColor3 = Color3.fromRGB(0,255,0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 30
Title.Parent = Background

-- Bottom counter
local Counter = Instance.new("TextLabel")
Counter.Size = UDim2.new(0,300,0,40)
Counter.Position = UDim2.new(0.5, -150, 1, -50)
Counter.BackgroundTransparency = 1
Counter.TextColor3 = Color3.fromRGB(255,255,255)
Counter.Font = Enum.Font.GothamBold
Counter.TextSize = 24
Counter.Text = "Coins Collected: 0"
Counter.Parent = Background

-- HELPER FUNCTIONS
local function GetCollectCoinEvent()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("collect") then
            return obj
        end
    end
end

local CollectCoinEvent = GetCollectCoinEvent()

local function GetCoins()
    local CoinsFolder = Workspace:FindFirstChild("Coins") or Workspace
    local coins = {}
    for _, coin in pairs(CoinsFolder:GetChildren()) do
        if coin:IsA("BasePart") then
            table.insert(coins, coin)
        end
    end
    return coins
end

local function GetBagAmount()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Coins") then
        return stats.Coins.Value
    end
    return 0
end

-- Safe step-by-step movement to prevent flying
local function MoveToSafe(targetPos)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.WalkSpeed = StepSpeed
    while (hrp.Position - targetPos).Magnitude > 2 and AutoFarmEnabled do
        local direction = (targetPos - hrp.Position).Unit
        local nextPos = hrp.Position + direction * 2
        hrp.CFrame = CFrame.new(Vector3.new(nextPos.X, hrp.Position.Y, nextPos.Z))
        task.wait(0.05)
    end
end

-- AUTO FARM LOOP
task.spawn(function()
    while AutoFarmEnabled do
        -- Auto-reset if bag full
        if GetBagAmount() >= CoinBagLimit then
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid").Health = 0
                task.wait(2) -- wait for respawn
            end
        else
            local coins = GetCoins()
            for _, coin in ipairs(coins) do
                if coin and LocalPlayer.Character then
                    MoveToSafe(coin.Position)

                    -- Collect coin via RemoteEvent
                    if CollectCoinEvent then
                        CollectCoinEvent:FireServer(coin)
                    else
                        if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 0)
                            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 1)
                        end
                    end

                    CoinsCollected += 1
                    Counter.Text = "Coins Collected: "..CoinsCollected
                    task.wait(0.1)
                end
            end
        end
        task.wait(0.5)
    end
end)