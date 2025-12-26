-- [[ 1. THE LIBRARY CODE ]] --
local JozexLib = (function()
    -- Paste the entire JozexLib_Beta.lua code here
    -- (The code I gave you starting with 'local JozexLib = {}')
    -- Make sure it ends with 'return JozexLib'
end)()

-- [[ 2. THE HUB FEATURES ]] --
local Window = JozexLib:CreateWindow("JOZEX UNIVERSAL | BETA")

local MainTab = Window:CreateTab("Movement")
MainTab:AddSlider("Walk Speed", 16, 250, 16, function(v) 
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
end)

MainTab:AddToggle("Infinite Jump", function(s)
    _G.InfJump = s
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.InfJump then
            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
end)

local CombatTab = Window:CreateTab("Combat")
CombatTab:AddToggle("Cam Lock", function(s)
    _G.CamLock = s
    task.spawn(function()
        while _G.CamLock do
            task.wait()
            -- (Cam lock logic here)
        end
    end)
end)
