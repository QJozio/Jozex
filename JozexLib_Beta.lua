--// Rayfield Loader
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--// Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

--// Safety check
if not LocalPlayer:FindFirstChild("CoreStats") then
    Rayfield:Notify({
        Title = "Error",
        Content = "CoreStats not found. Join Bee Swarm first.",
        Duration = 5
    })
    return
end

--// Window
local Window = Rayfield:CreateWindow({
    Name = "Jozex Hub | Bee Swarm",
    LoadingTitle = "Jozex Hub",
    LoadingSubtitle = "by QJozio",
    ConfigurationSaving = {
        Enabled = false
    }
})

--// Tabs
local FieldTab = Window:CreateTab("Fields", 4483362458)
local StatsTab = Window:CreateTab("Stats", 4483362458)

--// Variables
local SelectedField = "Sunflower"
local StartHoney = LocalPlayer.CoreStats.Honey.Value
local StartTime = tick()

--// Field Positions
local FieldPositions = {
    ["Sunflower"] = Vector3.new(-208, 4, 185),
    ["Mushroom"] = Vector3.new(-94, 4, 116),
    ["Dandelion"] = Vector3.new(-30, 4, 225),
    ["Blue Flower"] = Vector3.new(114, 4, 101),
    ["Clover"] = Vector3.new(174, 34, 189),
    ["Spider"] = Vector3.new(-372, 20, 124),
    ["Bamboo"] = Vector3.new(93, 20, -25),
    ["Strawberry"] = Vector3.new(-169, 20, -3),
    ["Pine Tree"] = Vector3.new(-317, 70, -215),
    ["Rose"] = Vector3.new(-322, 20, 124)
}

--// FIELDS TAB
FieldTab:CreateSection("Teleports")

FieldTab:CreateDropdown({
    Name = "Select Field",
    Options = {
        "Sunflower","Mushroom","Dandelion","Blue Flower","Clover",
        "Spider","Bamboo","Strawberry","Pine Tree","Rose"
    },
    CurrentOption = {"Sunflower"},
    MultipleOptions = false,
    Callback = function(Option)
        SelectedField = Option[1]
    end
})

FieldTab:CreateButton({
    Name = "Teleport to Field",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local pos = FieldPositions[SelectedField]
            if pos then
                char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
                StartHoney = LocalPlayer.CoreStats.Honey.Value
                StartTime = tick()
                Rayfield:Notify({
                    Title = "Teleported",
                    Content = "Stats reset for "..SelectedField,
                    Duration = 3
                })
            end
        end
    end
})

--// STATS TAB
StatsTab:CreateSection("Hourly Rates")

local HPHLabel = StatsTab:CreateLabel("Honey/HR: Calculating...")
local SessionLabel = StatsTab:CreateLabel("Session: 0")

--// Number Formatter
local function Format(n)
    if n >= 1e12 then
        return string.format("%.2fT", n/1e12)
    elseif n >= 1e9 then
        return string.format("%.2fB", n/1e9)
    elseif n >= 1e6 then
        return string.format("%.2fM", n/1e6)
    elseif n >= 1e3 then
        return string.format("%.1fK", n/1e3)
    else
        return tostring(math.floor(n))
    end
end

--// Update Loop
task.spawn(function()
    while task.wait(1) do
        local elapsed = tick() - StartTime
        if elapsed > 0 then
            local gained = LocalPlayer.CoreStats.Honey.Value - StartHoney
            local rate = (gained / elapsed) * 3600
            HPHLabel:Set("Honey/HR: "..Format(rate))
            SessionLabel:Set("Session: "..Format(gained))
        end
    end
end)