-- [[ Rayfield Universal Loader - Fixed 2025 ]] --
getgenv().SecureMode = true -- Helps bypass game UI blocks
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "JOZEX HUB | BETA",
   LoadingTitle = "Jozex Universal",
   LoadingSubtitle = "by QJozio",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "JozexConfigs",
      FileName = "MainConfig"
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false -- NO KEY SYSTEM AS REQUESTED
})

local MainTab = Window:CreateTab("Movement", 4483362458)

MainTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Flag = "WS_Flag",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

MainTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 500},
   Increment = 1,
   CurrentValue = 50,
   Flag = "JP_Flag",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
   end,
})

local CombatTab = Window:CreateTab("Combat", 4483362458)

local CamLock = false
CombatTab:CreateToggle({
   Name = "Cam Lock (Nearest)",
   CurrentValue = false,
   Flag = "CamLock_Flag",
   Callback = function(Value)
      CamLock = Value
      task.spawn(function()
         while CamLock do
            task.wait()
            local target = nil
            local dist = math.huge
            for _, v in pairs(game.Players:GetPlayers()) do
               if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                  local d = (v.Character.Head.Position - game.Players.LocalPlayer.Character.Head.Position).Magnitude
                  if d < dist then target = v; dist = d end
               end
            end
            if target then
               workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.Head.Position)
            end
         end
      end)
   end,
})

Rayfield:Notify({
   Title = "Success!",
   Content = "Jozex Beta Loaded Successfully",
   Duration = 5
})
