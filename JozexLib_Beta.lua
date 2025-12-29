-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "Mobile Macro Hub",
    LoadingTitle = "Mobile Macro",
    LoadingSubtitle = "by You",
    ConfigurationSaving = { Enabled = false }
})

-- Create Tab
local MacroTab = Window:CreateTab("Macro", 4483362458)

-- Section
MacroTab:CreateSection("Macro Controls")

-- Variables
local MacroEnabled = false
local ActionDelay = 0.1 -- delay between actions
local ExampleButton = workspace:FindFirstChild("ClickButton") -- replace with your object
local RecordedActions = {}
local SelectedFileName = "DefaultMacro"

-- Toggle to start/stop macro
MacroTab:CreateToggle({
    Name = "Enable Macro",
    CurrentValue = false,
    Flag = "MacroToggle",
    Callback = function(Value)
        MacroEnabled = Value
        if MacroEnabled then
            Rayfield:Notify({Title="Macro", Content="Macro started!", Duration=2})
        else
            Rayfield:Notify({Title="Macro", Content="Macro stopped!", Duration=2})
        end
    end
})

-- Slider to control speed
MacroTab:CreateSlider({
    Name = "Action Speed (sec)",
    Range = {0.05, 2},
    Increment = 0.05,
    Suffix = "s",
    CurrentValue = 0.1,
    Flag = "MacroSpeed",
    Callback = function(Value)
        ActionDelay = Value
    end
})

-- TextBox to change selected file name
MacroTab:CreateTextBox({
    Name = "Macro File Name",
    PlaceholderText = "Enter file name",
    Text = SelectedFileName,
    Callback = function(Value)
        SelectedFileName = Value
        Rayfield:Notify({Title="Macro", Content="Selected file: "..SelectedFileName, Duration=2})
    end
})

-- Button to save recorded actions
MacroTab:CreateButton({
    Name = "Save Recorded Actions",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local json = HttpService:JSONEncode(RecordedActions)
        writefile(SelectedFileName..".json", json)
        Rayfield:Notify({Title="Macro", Content="Saved to "..SelectedFileName..".json", Duration=3})
    end
})

-- Button to record the current action once
MacroTab:CreateButton({
    Name = "Record Action",
    Callback = function()
        if ExampleButton and ExampleButton:IsA("BasePart") then
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                table.insert(RecordedActions, {Position = ExampleButton.Position})
                Rayfield:Notify({Title="Macro", Content="Action recorded!", Duration=2})
            end
        end
    end
})

-- Macro loop
task.spawn(function()
    while true do
        if MacroEnabled then
            for _, action in ipairs(RecordedActions) do
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- Teleport to recorded position
                    hrp.CFrame = CFrame.new(action.Position + Vector3.new(0,3,0))
                    -- Fire touch to simulate click
                    if ExampleButton then
                        firetouchinterest(hrp, ExampleButton, 0)
                        firetouchinterest(hrp, ExampleButton, 1)
                    end
                end
                task.wait(ActionDelay)
            end
        else
            task.wait(0.1)
        end
    end
end)