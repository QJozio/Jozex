-- [[ JOZEX AFK FIELD FARMER ]] --
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- State
local Farming = false
local StartPosition = nil

-- [[ UI SETUP ]] --
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 70)
Main.Position = UDim2.new(0.5, -100, 0.8, -50) -- Bottom Center
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

-- Draggable Logic
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Main.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Rainbow Border
local RGB = Instance.new("Frame", Main)
RGB.Size = UDim2.new(1, -6, 1, -6)
RGB.Position = UDim2.new(0, 3, 0, 3)
RGB.BackgroundColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", RGB).CornerRadius = UDim.new(0, 8)

local Button = Instance.new("TextButton", RGB)
Button.Size = UDim2.new(1, -4, 1, -4)
Button.Position = UDim2.new(0, 2, 0, 2)
Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Button.Text = "AUTO FARM: OFF"
Button.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red
Button.Font = Enum.Font.GothamBold
Button.TextSize = 14
Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

-- [[ FARMING LOGIC ]] --

-- 1. Anti-AFK (Prevents Disconnect)
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- 2. Tool Activation
task.spawn(function()
    while true do
        if Farming and LocalPlayer.Character then
            -- Find Tool
            local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if Tool then
                Tool:Activate()
            end
        end
        task.wait(0.1) -- Fast swing
    end
end)

-- 3. Movement Pattern
task.spawn(function()
    while true do
        if Farming and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            -- If we just started, save the center position
            if not StartPosition then
                StartPosition = LocalPlayer.Character.HumanoidRootPart.Position
            end
            
            -- Move to a random spot within 15 studs of the start position
            local RandomX = math.random(-15, 15)
            local RandomZ = math.random(-15, 15)
            local TargetPos = StartPosition + Vector3.new(RandomX, 0, RandomZ)
            
            LocalPlayer.Character.Humanoid:MoveTo(TargetPos)
            
            -- Wait until we reach the point or 2 seconds pass
            local MoveTime = 0
            while Farming and (LocalPlayer.Character.HumanoidRootPart.Position - TargetPos).Magnitude > 2 and MoveTime < 2 do
                MoveTime = MoveTime + 0.1
                task.wait(0.1)
            end
        else
            StartPosition = nil -- Reset position if stopped
        end
        task.wait()
    end
end)

-- [[ CONTROLS ]] --
Button.MouseButton1Click:Connect(function()
    Farming = not Farming
    
    if Farming then
        Button.Text = "AUTO FARM: ON"
        Button.TextColor3 = Color3.fromRGB(100, 255, 100) -- Green
        
        -- Set anchor point to current location
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            StartPosition = LocalPlayer.Character.HumanoidRootPart.Position
        end
    else
        Button.Text = "AUTO FARM: OFF"
        Button.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red
        
        -- Stop moving immediately
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:MoveTo(LocalPlayer.Character.HumanoidRootPart.Position)
        end
    end
end)

-- RGB Loop
task.spawn(function()
    local h = 0
    while task.wait() do h = h + 0.005; RGB.BackgroundColor3 = Color3.fromHSV(h, 1, 1) end
end)