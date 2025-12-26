-- [[ JOZEX AIMBOT - CUSTOM UI EDITION 2025 ]] --

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ UI SETTINGS ]] --
local JozexUI = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", JozexUI)
local Title = Instance.new("TextLabel", MainFrame)
local Container = Instance.new("Frame", MainFrame)

-- [[ AIMBOT SETTINGS ]] --
local Settings = {
    Enabled = false,
    FOV = 150,
    Smoothing = 0.5,
    AimPart = "Head",
    TeamCheck = true
}

-- [[ UI DESIGN ]] --
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "  JOZEX AIMBOT | BETA"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 8)

-- Function to create Bento-style buttons
local function CreateToggle(text, callback)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    
    local active = false
    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = text .. (active and ": ON" or ": OFF")
        btn.BackgroundColor3 = active and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(25, 25, 25)
        callback(active)
    end)
end

-- [[ THE AIMBOT LOGIC ]] --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.new(1, 1, 1)

local function GetClosestPlayer()
    local target = nil
    local dist = Settings.FOV
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            if Settings.TeamCheck and v.Team == LocalPlayer.Team then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if mag < dist then
                    target = v
                    dist = mag
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.Enabled
    
    if Settings.Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target then
            local aimPos = target.Character[Settings.AimPart].Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), Settings.Smoothing)
        end
    end
end)

-- [[ ADD UI ELEMENTS ]] --
CreateToggle("Master Switch", function(s) Settings.Enabled = s end)
CreateToggle("Team Check", function(s) Settings.TeamCheck = s end)

-- Keybind to hide/show menu (Insert Key)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
