local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "JOZEX HUB | BETA",
   LoadingTitle = "Jozex Universal",
   LoadingSubtitle = "by QJozio",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "JozexHub",
      FileName = "Config"
   }
})

local PlayerTab = Window:CreateTab("Movement", 4483362458) -- Player Icon
local CombatTab = Window:CreateTab("Combat", 4483362458) -- Sword Icon

-- [[ MOVEMENT FEATURES ]] --

PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WS_Slider",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
   end,
})

PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 500},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "JP_Slider",
   Callback = function(Value)
      game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
      game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
   end,
})

-- [[ COMBAT FEATURES ]] --

local CamLockEnabled = false
CombatTab:CreateToggle({
   Name = "Cam Lock (Nearest)",
   CurrentValue = false,
   Flag = "CamLock_1",
   Callback = function(Value)
      CamLockEnabled = Value
      task.spawn(function()
         while CamLockEnabled do
            task.wait()
            local target = nil
            local dist = math.huge
            for _, v in pairs(game.Players:GetPlayers()) do
               if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                  local d = (v.Character.Head.Position - game.Players.LocalPlayer.Character.Head.Position).Magnitude
                  if d < dist then
                     target = v
                     dist = d
                  end
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
   Title = "Jozex Beta Loaded",
   Content = "Universal Script is ready!",
   Duration = 5,
   Image = 4483362458,
})
