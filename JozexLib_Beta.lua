--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// CONFIG
local COIN_BAG_MAX = 40

--// HELPER FUNCTIONS
local function CoinBagFull()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if not stats then return false end
    local coins = stats:FindFirstChild("Coins")
    if not coins then return false end
    return coins.Value >= COIN_BAG_MAX
end

local function IsMurderer()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("Knife") ~= nil
end

--// LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Jozex Hub | MM2",
   LoadingTitle = "Jozex Hub",
   LoadingSubtitle = "by QJozio",
   ConfigurationSaving = { Enabled = false }
})

local MainTab = Window:CreateTab("Main", 4483362458)

--// AUTO RESET TOGGLE
local AutoResetToggle = false
MainTab:CreateSection("Auto Reset")

MainTab:CreateToggle({
    Name = "Auto Reset (Murderer + Bag Full)",
    CurrentValue = false,
    Flag = "AutoReset",
    Callback = function(value)
        AutoResetToggle = value
    end
})

--// LOOP FOR AUTO RESET
task.spawn(function()
    while task.wait(0.5) do
        if AutoResetToggle and IsMurderer() and CoinBagFull() then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = 0
                end
            end
            task.wait(6)
        end
    end
end)