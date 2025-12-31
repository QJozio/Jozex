-- Jozex Hive Hub Auto Farm v1.0 - Custom UI
-- Bee Swarm Simulator
-- No Rayfield, fully self-contained

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- CONFIG
getgenv().AutoFarm = false
getgenv().ConvertAt = 95
local HIVEHUB_PLACEID = 15579077077

-- ANTI-AFK
player.Idled:Connect(function()
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- TELEPORT TO HIVE HUB IF NOT PRESENT
if not workspace:FindFirstChild("Hub Field") then
    TeleportService:Teleport(HIVEHUB_PLACEID, player)
    return
end

-- HELPERS
local function char() return player.Character or player.CharacterAdded:Wait() end
local function hrp() return char():WaitForChild("HumanoidRootPart") end
local function hum() return char():WaitForChild("Humanoid") end
local function pollenPct()
    local cs = player:FindFirstChild("CoreStats")
    if not cs then return 0 end
    return (cs.Pollen.Value / cs.Capacity.Value) * 100
end
local function claimHive()
    if not player:FindFirstChild("SpawnPos") then
        ReplicatedStorage.Remotes.ClaimHub:FireServer()
        task.wait(1)
    end
end
local function convert()
    if player:FindFirstChild("SpawnPos") then
        hrp().CFrame = player.SpawnPos.Value + Vector3.new(0,3,0)
        task.wait(0.3)
        ReplicatedStorage.Remotes.Convert:FireServer()
    end
end
local function walkTo(pos)
    local path = PathfindingService:CreatePath({AgentRadius=2, AgentHeight=5, AgentCanJump=true})
    path:ComputeAsync(hrp().Position, pos)
    path:MoveTo(hrp())
end
local function nearestToken(radius)
    local h = hrp()
    local nearest, minDist = nil, radius
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:find("Token") or v.Name:find("Pollen")) then
            local dist = (v.Position - h.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = v
            end
        end
    end
    return nearest
end

-- =====================
-- CUSTOM UI
-- =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JozexUI"
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,250,0,180)
Frame.Position = UDim2.new(0,20,0,50)
Frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local function createLabel(text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 20)
    lbl.Position = UDim2.new(0,5,0, y)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Text = text
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 16
    lbl.Parent = Frame
    return lbl
end

createLabel("Jozex Hive Hub Auto Farm", 5)
createLabel("Requires 20+ bees", 25)

-- Toggle Auto Farm Button
local AutoBtn = Instance.new("TextButton")
AutoBtn.Size = UDim2.new(1, -10, 0, 30)
AutoBtn.Position = UDim2.new(0,5,0,55)
AutoBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
AutoBtn.TextColor3 = Color3.fromRGB(255,255,255)
AutoBtn.Text = "Auto Farm: OFF"
AutoBtn.Font = Enum.Font.SourceSansBold
AutoBtn.TextSize = 16
AutoBtn.Parent = Frame
AutoBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    AutoBtn.Text = "Auto Farm: "..(getgenv().AutoFarm and "ON" or "OFF")
end)

-- Convert % Slider
local Slider = Instance.new("TextBox")
Slider.Size = UDim2.new(1, -10, 0, 30)
Slider.Position = UDim2.new(0,5,0,95)
Slider.BackgroundColor3 = Color3.fromRGB(50,50,50)
Slider.TextColor3 = Color3.fromRGB(255,255,255)
Slider.Text = "Convert At %: "..getgenv().ConvertAt
Slider.Font = Enum.Font.SourceSansBold
Slider.TextSize = 16
Slider.ClearTextOnFocus = false
Slider.Parent = Frame
Slider.FocusLost:Connect(function(enter)
    local val = tonumber(Slider.Text:match("%d+"))
    if val then
        getgenv().ConvertAt = math.clamp(val, 60,100)
        Slider.Text = "Convert At %: "..getgenv().ConvertAt
    else
        Slider.Text = "Convert At %: "..getgenv().ConvertAt
    end
end)

-- =====================
-- AUTO FARM LOOP
-- =====================
task.spawn(function()
    while task.wait(0.3) do
        claimHive()
        if getgenv().AutoFarm then
            local field = workspace:FindFirstChild("Hub Field")
            if field then
                walkTo(field.Position + Vector3.new(math.random(-6,6),0,math.random(-6,6)))
            end
            local t = nearestToken(12)
            if t then walkTo(t.Position + Vector3.new(0,2,0)) end
        end
    end
end)

-- AUTO CONVERT LOOP
task.spawn(function()
    while task.wait(1) do
        if getgenv().AutoFarm and pollenPct() >= getgenv().ConvertAt then
            convert()
            task.wait(6)
        end
    end
end)