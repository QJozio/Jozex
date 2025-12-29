--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Debris = game:GetService("Debris")

--// CONFIG
local KEY = "JOZEX-MM2-2025" -- your key
local KEY_LINK = "https://direct-link.net/2552546/CxGwpvRqOVJH"
local COIN_BAG_MAX = 40

--// FUNCTIONS
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

--// KEY UI
local KeyFrame, KeyContent = CreateDraggableFrame("Enter Key", UDim2.fromOffset(260,150), UDim2.fromScale(0.35,0.35))

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.fromOffset(200,32)
KeyInput.Position = UDim2.fromOffset(30,10)
KeyInput.PlaceholderText = "Enter Key"
KeyInput.ClearTextOnFocus = false
KeyInput.TextColor3 = Color3.new(1,1,1)
KeyInput.BackgroundColor3 = Color3.fromRGB(45,45,45)
KeyInput.Parent = KeyContent
Instance.new("UICorner", KeyInput)

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

--// RAYFIELD MAIN FEATURES UI
local function LoadMainFeatures()
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    local Window = Rayfield:CreateWindow({
       Name = "Jozex Hub | MM2",
       LoadingTitle = "Jozex Hub",
       LoadingSubtitle = "by QJozio",
       ConfigurationSaving = { Enabled = false }
    })

    local MainTab = Window:CreateTab("Main", 4483362458)

    local AutoResetToggle = false

    MainTab:CreateSection("Auto Reset")

    local ToggleButton = MainTab:CreateToggle({
        Name = "Auto Reset (Murderer + Bag Full)",
        CurrentValue = false,
        Flag = "AutoReset",
        Callback = function(value)
            AutoResetToggle = value
        end
    })

    -- Loop for auto-reset
    task.spawn(function()
        while task.wait(0.5) do
            if AutoResetToggle and IsMurderer() and CoinBagFull() then
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
end

--// KEY SUBMISSION LOGIC
SubmitBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == KEY then
        -- Destroy key UI
        KeyFrame:Destroy()

        -- Load main Rayfield features
        LoadMainFeatures()
    else
        SubmitBtn.Text = "Wrong Key ❌"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
end)