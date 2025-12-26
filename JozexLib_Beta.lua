-- [[ Rayfield Universal Loader - 2025 Fixed ]] --
getgenv().SecureMode = true -- Bypasses some detections
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "JOZEX HUB | BETA",
   LoadingTitle = "Jozex Universal",
   LoadingSubtitle = "by QJozio",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "JozexConfigs",
      FileName = "Main"
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false -- IMPORTANT: Set to false so it opens instantly
})

local MainTab = Window:CreateTab("Player", 4483362458)

MainTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

MainTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 500},
   Increment = 1,
   CurrentValue = 50,
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
   Content = "Jozex Beta has loaded.",
   Duration = 3
})
