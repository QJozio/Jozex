--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// CONFIG
local AutoFarmEnabled = true
local TweenSpeed = 50 -- studs per second
local CoinsCollected = 0

-- Adjust to match the coin folder in your MM2 server
local function GetCoinsFolder()
    return Workspace:FindFirstChild("Coins") or Workspace:FindFirstChild("CoinFolder") or Workspace
end

--// UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JozexHubAutoFarmUI"
ScreenGui.Parent = game:GetService("CoreGui")

local Background = Instance.new("Frame")
Background.Size = UDim2.fromScale(1,1)
Background.Position = UDim2.fromScale(0,0)
Background.BackgroundColor3 = Color3.fromRGB(0,0,0)
Background.BackgroundTransparency = 0.6 -- semi-transparent
Background.Parent = ScreenGui

-- Center title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(400,50)
Title.Position = UDim2.fromScale(0.5,0.5) - UDim2.fromOffset(200,25)
Title.BackgroundTransparency = 1
Title.Text = "Jozex Hub MM2 AutoFarm"
Title.TextColor3 = Color3.fromRGB(0,255,0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 30
Title.TextStrokeTransparency = 0
Title.Parent = Background

-- Bottom counter
local Counter = Instance.new("TextLabel")
Counter.Size = UDim2.fromOffset(300,40)
Counter.Position = UDim2.fromScale(0.5,1) - UDim2.fromOffset(150,50)
Counter.BackgroundTransparency = 1
Counter.TextColor3 = Color3.fromRGB(255,255,255)
Counter.Font = Enum.Font.GothamBold
Counter.TextSize = 24
Counter.Text = "Coins Collected: 0"
Counter.Parent = Background

--// FUNCTIONS
local function MoveToCoin(coin)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (coin.Position - hrp.Position).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist/TweenSpeed), {CFrame = CFrame.new(coin.Position + Vector3.new(0,3,0))})
    tween:Play()
    tween.Completed:Wait()
end

local function CollectCoins()
    local CoinsFolder = GetCoinsFolder()
    for _, coin in ipairs(CoinsFolder:GetChildren()) do
        if coin:IsA("BasePart") and LocalPlayer.Character then
            MoveToCoin(coin)
            -- modern MM2 uses TouchInterest, simulate it
            if coin:FindFirstChild("TouchInterest") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 0)
                firetouchinterest(LocalPlayer.Character.HumanoidRootPart, coin, 1)
            end
            CoinsCollected += 1
            Counter.Text = "Coins Collected: "..CoinsCollected
            task.wait(0.1)
        end
    end
end

--// AUTO FARM LOOP
task.spawn(function()
    while AutoFarmEnabled do
        CollectCoins()
        task.wait(0.5)
    end
end)