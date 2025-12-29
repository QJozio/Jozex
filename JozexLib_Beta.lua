--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIG
local AutoFarmEnabled = true
local CoinsCollected = 0
local CoinBagLimit = 40 -- max coins before reset
local CoinCollectDelay = 0.05 -- delay between each coin collect

-- UI (Optional, simple)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2AutoFarmUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Counter = Instance.new("TextLabel")
Counter.Size = UDim2.new(0, 250, 0, 40)
Counter.Position = UDim2.new(0.5, -125, 0, 20)
Counter.BackgroundTransparency = 1
Counter.TextColor3 = Color3.fromRGB(0, 255, 0)
Counter.Font = Enum.Font.GothamBold
Counter.TextSize = 24
Counter.Text = "Coins Collected: 0"
Counter.Parent = ScreenGui

-- GET REMOTEEVENT FOR COINS
local CollectCoinEvent
for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") and obj.Name:lower():find("collect") then
        CollectCoinEvent = obj
        break
    end
end

-- HELPER FUNCTIONS
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

local function TeleportToCoin(coin)
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and coin then
        hrp.CFrame = CFrame.new(coin.Position + Vector3.new(0,3,0)) -- teleport slightly above
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
                    -- TELEPORT to coin
                    TeleportToCoin(coin)

                    -- Fire RemoteEvent to collect
                    if CollectCoinEvent then
                        CollectCoinEvent:FireServer(coin)
                    else
                        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            firetouchinterest(hrp, coin, 0)
                            firetouchinterest(hrp, coin, 1)
                        end
                    end

                    CoinsCollected += 1
                    Counter.Text = "Coins Collected: "..CoinsCollected
                    task.wait(CoinCollectDelay)
                end
            end
        end
        task.wait(0.2)
    end
end)