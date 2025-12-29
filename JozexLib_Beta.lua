--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIG
local AutoFarmEnabled = true
local CoinsCollected = 0
local CoinBagLimit = 40 -- max coins before auto-reset

-- UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JozexHubAutoFarmUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Full-screen darker background
local Background = Instance.new("Frame")
Background.Size = UDim2.new(1,0,1,0) -- full screen
Background.Position = UDim2.new(0,0,0,0)
Background.BackgroundColor3 = Color3.fromRGB(0,0,0) -- black
Background.BackgroundTransparency = 0.2 -- darker but slightly transparent
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

-- GET REMOTEEVENT
local CollectCoinEvent
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") and obj.Name:lower():find("collect") then
        CollectCoinEvent = obj
        break
    end
end

-- HELPER FUNCTION
local function GetBagAmount()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Coins") then
        return stats.Coins.Value
    end
    return 0
end

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
                    -- TELEPORT TO COIN
                    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(coin.Position + Vector3.new(0,3,0)) -- slightly above coin
                    end

                    -- Fire RemoteEvent to collect
                    if CollectCoinEvent then
                        CollectCoinEvent:FireServer(coin)
                    else
                        if hrp then
                            firetouchinterest(hrp, coin, 0)
                            firetouchinterest(hrp, coin, 1)
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