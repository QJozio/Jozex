-- Jozex Hive Hub Auto Farm v1.1 - Guaranteed Load

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

-- WAIT FOR CHARACTER & HUB FIELD
repeat task.wait() until player.Character and player.Character:FindFirstChild("HumanoidRootPart")
repeat task.wait() until workspace:FindFirstChild("Hub Field")

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
local gui = Instance.new("ScreenGui")
gui.Name = "JozexUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,260,0,180)
frame.Position = UDim2.new(0,20,0,50)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.BorderSizePixel = 0
frame.Parent = gui

local function createLabel(text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-10,0,20)
    lbl.Position = UDim2.new(0,5,0,y)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.Text = text
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 16
    lbl.Parent = frame
    return lbl
end

createLabel("Jozex Hive Hub Auto Farm",5)
createLabel("Requires 20+ bees",25)

-- Toggle Auto Farm
local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(1,-10,0,30)
autoBtn.Position = UDim2.new(0,5,0,55)
autoBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
autoBtn.TextColor3 = Color3.fromRGB(255,255,255)
autoBtn.Text = "Auto Farm: