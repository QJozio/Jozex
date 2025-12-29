--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIG
local AutoFarmEnabled = true
local TweenSpeed = 50 -- studs per second
local CoinsCollected = 0

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JozexHubAutoFarmUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Semi-transparent background
local Background = Instance.new("Frame")
Background.Size = UDim2.new(1,0,1,0)
Background.Position = UDim2.new(0,0,0,0)
Background.BackgroundColor3 = Color3.fromRGB(0,0,0)
Background.BackgroundTransparency = 0.6
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

-- Counter
local Counter = Instance.new("TextLabel")
Counter.Size = UDim2.new(0,300,0,40)
Counter.Position = UDim2.new(0.5, -150, 1, -50)
Counter.BackgroundTransparency = 1
Counter.TextColor3 = Color3.fromRGB(255,255,255)
Counter.Font = Enum.Font.GothamBold
Counter.TextSize = 24
Counter.Text = "Coins Collected: 0"
Counter.Parent = Background

--// HELPER FUNCTIONS
local function MoveToPosition(pos)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (pos - hrp.Position).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist/TweenSpeed), {CFrame = CFrame.new(pos + Vector3.new(0,3,0))})
    tween:Play()
    tween.Completed:Wait()
end

-- Find the RemoteEvent used by MM2 for collecting coins
local function GetCollectCoinEvent()
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") and obj.Name:lower():find("collect") then
            return obj
        end
    end
end

local CollectCoinEvent = GetCollectCoinEvent()

-- Get coins in the workspace
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

-- Auto-farm function
local function AutoFarm()
    while AutoFarmEnabled do
        local coins = GetCoins()
        for _, coin in ipairs(coins) do
            if AutoFarmEnabled and coin and LocalPlayer.Character then
                MoveToPosition(coin.Position)
                -- Fire the RemoteEvent to collect coin
                if CollectCoinEvent then
                    CollectCoinEvent:FireServer(coin)
                else
                    -- fallback: try touch
                    if LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 0)
                        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 1)
                    end
                end
                CoinsCollected = CoinsCollected + 1
                Counter.Text = "Coins Collected: "..CoinsCollected
                task.wait(0.1)
            end
        end
        task.wait(0.5)
    end
end

-- Start auto farm
task.spawn(AutoFarm)