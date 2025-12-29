--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Debris = game:GetService("Debris")

--// CONFIG
local COIN_BAG_MAX = 40
local AutoReset = false
local UNLOCKED = false
local KEY = "JOZEX-MM2-2025" -- Your key
local KEY_LINK = "https://direct-link.net/2552546/CxGwpvRqOVJH"

--// UTILS
local function CreateDraggableFrame(name, size, pos)
    local frame = Instance.new("Frame")
    frame.Name = name
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = game.CoreGui

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0,10)

    -- Title bar
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-60,0,32)
    title.Position = UDim2.fromOffset(10,0)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Color3.new(1,1,1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(28,24)
    minBtn.Position = UDim2.new(1,-34,0,4)
    minBtn.Text = "-"
    minBtn.TextSize = 20
    minBtn.Font = Enum.Font.GothamBold
    minBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    minBtn.TextColor3 = Color3.new(1,1,1)
    minBtn.Parent = frame
    Instance.new("UICorner", minBtn)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1,-20,1,-42)
    content.Position = UDim2.fromOffset(10,36)
    content.BackgroundTransparency = 1
    content.Parent = frame

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        content.Visible = not minimized
        frame.Size = minimized and UDim2.fromOffset(size.X.Offset,36) or size
    end)

    return frame, content
end

--// CREATE KEY UI
local KeyFrame, KeyContent = CreateDraggableFrame("Submit Key", UDim2.fromOffset(260,150), UDim2.fromScale(0.35,0.35))

-- Key Input
local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.fromOffset(200,32)
KeyInput.Position = UDim2.fromOffset(30,10)
KeyInput.PlaceholderText = "Enter Key"
KeyInput.ClearTextOnFocus = false
KeyInput.TextColor3 = Color3.new(1,1,1)
KeyInput.BackgroundColor3 = Color3.fromRGB(45,45,45)
KeyInput.Parent = KeyContent
Instance.new("UICorner", KeyInput)

-- Submit Button
local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.fromOffset(200,32)
SubmitBtn.Position = UDim2.fromOffset(30,50)
SubmitBtn.Text = "Submit Key"
SubmitBtn.Font = Enum.Font.GothamBold
SubmitBtn.TextSize = 14
SubmitBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
SubmitBtn.TextColor3 = Color3.new(1,1,1)
SubmitBtn.Parent = KeyContent
Instance.new("UICorner", SubmitBtn)

-- Copy Link Button
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.fromOffset(200,32)
CopyBtn.Position = UDim2.fromOffset(30,90)
CopyBtn.Text = "Copy Key Link"
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 14
CopyBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
CopyBtn.TextColor3 = Color3.new(1,1,1)
CopyBtn.Parent = KeyContent
Instance.new("UICorner", CopyBtn)

CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(KEY_LINK)
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.fromOffset(200,28)
        notif.Position = UDim2.fromOffset(30,120)
        notif.BackgroundColor3 = Color3.fromRGB(0,120,70)
        notif.TextColor3 = Color3.new(1,1,1)
        notif.Text = "Link copied to clipboard!"
        notif.TextSize = 14
        notif.Font = Enum.Font.GothamBold
        notif.Parent = KeyContent
        Debris:AddItem(notif,3)
    end
end)

--// CREATE MAIN FEATURES UI
local MainFrame, MainContent = CreateDraggableFrame("Main Features", UDim2.fromOffset(260,160), UDim2.fromScale(0.65,0.35))

-- Auto Reset toggle
local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.fromOffset(200,36)
Toggle.Position = UDim2.fromOffset(30,20)
Toggle.Text = "Auto Reset: OFF"
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 14
Toggle.BackgroundColor3 = Color3.fromRGB(90,90,90) -- greyed until key
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Parent = MainContent
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

--// KEY SUBMISSION LOGIC
SubmitBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == KEY then
        UNLOCKED = true
        SubmitBtn.Text = "Key Accepted ✅"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(0,120,70)

        -- Activate main features
        AutoReset = true
        Toggle.Text = "Auto Reset: ON"
        Toggle.BackgroundColor3 = Color3.fromRGB(0,120,70)

        -- Notification
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.fromOffset(200,28)
        notif.Position = UDim2.fromOffset(30,120)
        notif.BackgroundColor3 = Color3.fromRGB(0,120,70)
        notif.TextColor3 = Color3.new(1,1,1)
        notif.Text = "Key accepted! Features activated"
        notif.TextSize = 14
        notif.Font = Enum.Font.GothamBold
        notif.Parent = KeyContent
        Debris:AddItem(notif,3)
    else
        UNLOCKED = false
        SubmitBtn.Text = "Wrong Key ❌"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
        AutoReset = false
        Toggle.Text = "Auto Reset: OFF"
        Toggle.BackgroundColor3 = Color3.fromRGB(90,90,90)
    end
end)

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
            task.wait(6)
        end
    end
end)