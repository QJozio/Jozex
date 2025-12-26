-- [[ JOZEX BETA | ALL-IN-ONE UNIVERSAL ]] --

local JozexLib = {}
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- 1. THE ENGINE
function JozexLib:CreateWindow(HubName)
    local Jozex = Instance.new("ScreenGui", CoreGui)
    Jozex.Name = "JozexBetaHub"

    local function Drag(obj)
        local dragging, dragInput, dragStart, startPos
        obj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; dragStart = input.Position; startPos = obj.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        obj.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local Main = Instance.new("Frame", Jozex)
    Main.Size = UDim2.new(0, 420, 0, 300)
    Main.Position = UDim2.new(0.5, -210, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Main)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(0, 150, 255)
    Drag(Main)

    local Mini = Instance.new("TextButton", Jozex)
    Mini.Size = UDim2.new(0, 60, 0, 60); Mini.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
    Mini.Text = "BETA"; Mini.TextColor3 = Color3.new(1,1,1); Mini.Visible = false
    Instance.new("UICorner", Mini); Drag(Mini)
    
    local MinBtn = Instance.new("TextButton", Main)
    MinBtn.Size = UDim2.new(0, 30, 0, 30); MinBtn.Position = UDim2.new(1, -35, 0, 5)
    MinBtn.Text = "-"; MinBtn.BackgroundColor3 = Color3.fromRGB(30,30,30); MinBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", MinBtn)
    
    MinBtn.MouseButton1Click:Connect(function() Main.Visible = false; Mini.Visible = true; Mini.Position = Main.Position end)
    Mini.MouseButton1Click:Connect(function() Main.Visible = true; Mini.Visible = false end)

    local Title = Instance.new("TextLabel", Main)
    Title.Text = "  " .. HubName; Title.Size = UDim2.new(1, 0, 0, 40)
    Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1; Title.Font = Enum.Font.GothamBold; Title.TextXAlignment = Enum.TextXAlignment.Left

    local TabBar = Instance.new("Frame", Main)
    TabBar.Size = UDim2.new(0, 100, 1, -50); TabBar.Position = UDim2.new(0, 10, 0, 45); TabBar.BackgroundTransparency = 1
    
    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -130, 1, -50); Container.Position = UDim2.new(0, 120, 0, 45); Container.BackgroundTransparency = 1

    local first = true
    local Tabs = {}

    function Tabs:CreateTab(TabName)
        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, 0, 1, 0); Page.BackgroundTransparency = 1; Page.Visible = first
        Page.ScrollBarThickness = 0; Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)

        local TabBtn = Instance.new("TextButton", TabBar)
        TabBtn.Size = UDim2.new(1, 0, 0, 35); TabBtn.Text = TabName
        TabBtn.BackgroundColor3 = first and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
        TabBtn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", TabBtn)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(Container:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, b in pairs(TabBar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end end
            Page.Visible = true; TabBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
        end)

        first = false
        local Elements = {}

        function Elements:AddToggle(text, callback)
            local Tgl = Instance.new("TextButton", Page)
            Tgl.Size = UDim2.new(1, 0, 0, 35); Tgl.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Tgl.Text = text .. " : OFF"; Tgl.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", Tgl)
            local s = false
            Tgl.MouseButton1Click:Connect(function()
                s = not s; Tgl.Text = text .. (s and " : ON" or " : OFF")
                Tgl.BackgroundColor3 = s and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(25, 25, 25)
                callback(s)
            end)
        end

        function Elements:AddSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame", Page)
            SliderFrame.Size = UDim2.new(1, 0, 0, 45); SliderFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
            Instance.new("UICorner", SliderFrame)
            
            local Label = Instance.new("TextLabel", SliderFrame)
            Label.Text = text .. " [" .. default .. "]"; Label.Size = UDim2.new(1,0,0,20); Label.TextColor3 = Color3.new(1,1,1); Label.BackgroundTransparency = 1
            
            local Bar = Instance.new("Frame", SliderFrame)
            Bar.Size = UDim2.new(0.8, 0, 0, 5); Bar.Position = UDim2.new(0.1, 0, 0.7, 0); Bar.BackgroundColor3 = Color3.fromRGB(50,50,50)
            
            local Fill = Instance.new("Frame", Bar)
            Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Color3.fromRGB(0,150,255)
            
            Bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local con; con = RunService.RenderStepped:Connect(function()
                        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then con:Disconnect() return end
                        local mousePos = UserInputService:GetMouseLocation().X
                        local barPos = Bar.AbsolutePosition.X
                        local barWidth = Bar.AbsoluteSize.X
                        local percent = math.clamp((mousePos - barPos) / barWidth, 0, 1)
                        Fill.Size = UDim2.new(percent, 0, 1, 0)
                        local val = math.floor(min + (max - min) * percent)
                        Label.Text = text .. " [" .. val .. "]"
                        callback(val)
                    end)
                end
            end)
        end
        return Elements
    end
    return Tabs
end

-- 2. THE AUTOMATIC UI SETUP
local Window = JozexLib:CreateWindow("JOZEX UNIVERSAL | BETA")
local PlayerTab = Window:CreateTab("Movement")
local CombatTab = Window:CreateTab("Combat")

-- Movement Features
PlayerTab:AddSlider("Walk Speed", 16, 250, 16, function(v) 
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v 
end)

PlayerTab:AddSlider("Jump Power", 50, 30
    
