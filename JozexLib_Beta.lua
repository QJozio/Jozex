--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

--// CONFIG
local COIN_BAG_MAX = 40
local AutoReset = false
local UNLOCKED = false
local KEY = "JOZEX-MM2-2025" -- Change this to your key
local KEY_LINK = "https://direct-link.net/2552546/CxGwpvRqOVJH"

--// GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2MiniUI"
ScreenGui.Parent = game.CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(260, 220)
Main.Position = UDim2.fromScale(0.35, 0.35)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 10)

--// TITLE BAR
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 32)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "MM2 Helper"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

--// MINIMIZE BUTTON
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromOffset(28, 24)
MinBtn.Position = UDim2.new(1, -34, 0, 4)
MinBtn.Text = "-"
MinBtn.TextSize = 20
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Parent = Main
Instance.new("UICorner", MinBtn)

--// CONTENT FRAME
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -42)
Content.Position = UDim2.fromOffset(10, 36)
Content.BackgroundTransparency = 1
Content.Parent = Main

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    Main.Size = minimized and UDim2.fromOffset(260, 36) or UDim2.fromOffset(260, 220)
end)

--// KEY INPUT
local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.fromOffset(200, 32)
KeyInput.Position = UDim2.fromOffset(30, 10)
KeyInput.PlaceholderText = "Enter Key"
KeyInput.ClearTextOnFocus = false
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.new(1,1,1)
KeyInput.BackgroundColor3 = Color3.fromRGB(45,45,45)
KeyInput.Parent = Content
Instance.new("UICorner", KeyInput)

--// SUBMIT BUTTON
local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.fromOffset(200, 32)
SubmitBtn.Position = UDim2.fromOffset(30, 50)
SubmitBtn.Text = "Submit Key"
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 14
SubmitBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
SubmitBtn.TextColor3 = Color3.new(1,1,1)
SubmitBtn.Parent = Content
Instance.new("UICorner", SubmitBtn)

SubmitBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == KEY then
        UNLOCKED = true
        SubmitBtn.Text = "Key Accepted ✅"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(0,120,70)
    else
        UNLOCKED = false
        SubmitBtn.Text = "Wrong Key ❌"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
end)

--// COPY LINK BUTTON
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.fromOffset(200, 32)
CopyBtn.Position = UDim2.fromOffset(30, 90)
CopyBtn.Text = "Copy Key Link"
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 14
CopyBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
CopyBtn.TextColor3 = Color3.new(1,1,1)
CopyBtn.Parent = Content
Instance.new("UICorner", CopyBtn)

CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(KEY_LINK)
    end
end)

--// TOGGLE BUTTON
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.fromOffset(200, 36)
Toggle.Position = UDim2.fromOffset(30, 140)
Toggle.Text = "Auto Reset: OFF"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14
Toggle.BackgroundColor3 = Color3.fromRGB(45,45,45)
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Parent = Content
Instance.new("UICorner", Toggle)

Toggle.MouseButton1Click:Connect(function()
    if not UNLOCKED then
        Toggle.Text = "Enter Key First!"
        return
    end
    AutoReset = not AutoReset
    Toggle.Text = AutoReset and "Auto Reset: ON" or "Auto Reset: OFF"
    Toggle.BackgroundColor3 = AutoReset and Color3.fromRGB(0,120,70) or Color3.fromRGB(45,45,45)
end)

--// CHECK COIN BAG
local function CoinBagFull()
    local stats = LocalPlayer:FindFirstChild("leaderstats")
    if not stats then return false end
    local coins = stats:FindFirstChild("Coins")
    if not coins then return false end
    return coins.Value >= COIN_BAG_MAX
end

--// CHECK MURDERER
local function IsMurderer()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("Knife") ~= nil
end

--// MAIN LOOP
task.spawn(function()
    while task.wait(0.5) do
        if AutoReset and UNLOCKED and IsMurderer() and CoinBagFull() then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = 0
                end
            end
            task.wait(6) -- anti loop
        end
    end
end)