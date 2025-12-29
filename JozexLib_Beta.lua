--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIG
local AutoFarmEnabled = true
local TweenSpeed = 50 -- studs per second
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
Background.BackgroundColor3 = Color3.fromRGB(0,0,0)
Background.BackgroundTransparency = 0.4
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

-- Safe tween to coin
local function TweenToCoin(coinPos)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPos = coinPos + Vector3.new(0,3,0) -- slightly above coin
    local distance = (targetPos - hrp.Position).Magnitude
    local tweenTime = distance / TweenSpeed

    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()
    tween.Completed:Wait()
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
                    TweenToCoin(coin.Position)

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