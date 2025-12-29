--// Rayfield Loader
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// Window
local Window = Rayfield:CreateWindow({
    Name = "Jozex Hub | Bee Swarm",
    LoadingTitle = "Jozex Hub",
    LoadingSubtitle = "by QJozio",
    ConfigurationSaving = { Enabled = false }
})

--// Tabs
local FieldTab = Window:CreateTab("Fields", 4483362458)
local StatsTab = Window:CreateTab("Stats", 4483362458)

--// Variables
local SelectedField = "Sunflower"
local StartHoney = LocalPlayer.CoreStats.Honey.Value
local StartTime = tick()

--// Field Positions & Radius
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

local FieldRadiusOverride = {
    ["Sunflower"] = 12, ["Mushroom"] = 11, ["Dandelion"] = 13,
    ["Blue Flower"] = 13, ["Clover"] = 15, ["Spider"] = 14,
    ["Bamboo"] = 16, ["Strawberry"] = 14, ["Pine Tree"] = 18,
    ["Rose"] = 14
}

--// Autofarm Variables
local AutoFarm = false
local AutoConvert = true
local AutoClick = false
local CurrentTween = nil
local State = "FARM"
local FIELD_RADIUS = 14
local CONVERT_AT = 0.9 -- 90% backpack

-- Zig-zag movement state
local ZigZagState = {xDir = 1, zDir = 1, step = 4}

--// FIELD TAB
FieldTab:CreateSection("Teleports")

FieldTab:CreateDropdown({
    Name = "Select Field",
    Options = {"Sunflower","Mushroom","Dandelion","Blue Flower","Clover","Spider","Bamboo","Strawberry","Pine Tree","Rose"},
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
            char.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0,5,0))
            StartHoney = LocalPlayer.CoreStats.Honey.Value
            StartTime = tick()
            Rayfield:Notify({Title = "Teleported", Content = "Stats reset for "..SelectedField, Duration = 3})
        end
    end
})

-- Auto Farm Toggle
FieldTab:CreateToggle({
    Name = "Auto Farm (Tween + Convert + ZigZag)",
    CurrentValue = false,
    Callback = function(v)
        AutoFarm = v
        State = "FARM"
        if not v and CurrentTween then
            CurrentTween:Cancel()
            CurrentTween = nil
        end
        Rayfield:Notify({
            Title = "Auto Farm",
            Content = v and "Enabled" or "Disabled",
            Duration = 2
        })
    end
})

-- Auto Click Toggle
FieldTab:CreateToggle({
    Name = "Auto Click Flowers",
    CurrentValue = false,
    Callback = function(v)
        AutoClick = v
        Rayfield:Notify({
            Title = "Auto Click",
            Content = v and "Enabled" or "Disabled",
            Duration = 2
        })
    end
})

--// Stats Tab
StatsTab:CreateSection("Hourly Rates")
local HPHLabel = StatsTab:CreateLabel("Honey/HR: Calculating...")
local SessionLabel = StatsTab:CreateLabel("Session: 0")

--// Number Formatter
local function Format(n)
    if n >= 1e12 then return string.format("%.2fT", n/1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n/1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.1fK", n/1e3)
    else return tostring(math.floor(n)) end
end

--// Stats Update
task.spawn(function()
    while task.wait(1) do
        local Elapsed = tick() - StartTime
        local Gained = LocalPlayer.CoreStats.Honey.Value - StartHoney
        local Rate = (Gained / Elapsed) * 3600
        HPHLabel:Set("Honey/HR: "..Format(Rate))
        SessionLabel:Set("Session: "..Format(Gained))
    end
end)

--// Wall Check
local function IsBlocked(origin, direction, character)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    params.FilterType = Enum.RaycastFilterType.Blacklist
    return workspace:Raycast(origin, direction, params) ~= nil
end

--// Tween Function
local function TweenTo(hrp, target)
    if CurrentTween then CurrentTween:Cancel() end
    local dist = (hrp.Position - target).Magnitude
    local time = math.clamp(dist / 9, 0.4, 1.4)
    CurrentTween = TweenService:Create(hrp, TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(target)})
    CurrentTween:Play()
    CurrentTween.Completed:Wait()
    CurrentTween = nil
end

--// Zig-Zag Target
local function GetZigZagTarget(field)
    local center = FieldPositions[field]
    local radius = FieldRadiusOverride[field] or FIELD_RADIUS

    local xDir = ZigZagState.xDir
    local zDir = ZigZagState.zDir
    local step = ZigZagState.step

    local target = center + Vector3.new(
        (math.random()*radius*0.7 + radius*0.3)*xDir,
        0,
        (math.random()*radius*0.7 + radius*0.3)*zDir
    )

    if (target - center).Magnitude >= radius then
        ZigZagState.xDir = -ZigZagState.xDir
        ZigZagState.zDir = -ZigZagState.zDir
    end

    return target
end

--// AUTO FARM LOOP
task.spawn(function()
    while task.wait(0.15) do
        if not AutoFarm then continue end

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local stats = LocalPlayer:FindFirstChild("CoreStats")
        local fieldPos = FieldPositions[SelectedField]
        if not (char and hrp and humanoid and stats and fieldPos) then continue end

        local pollen = stats.Pollen.Value
        local capacity = stats.Capacity.Value
        local pollenRatio = pollen / capacity

        -- Auto Convert
        if AutoConvert and pollenRatio >= CONVERT_AT then State = "CONVERT" end

        -- CONVERT STATE
        if State == "CONVERT" then
            local hive = workspace.Honeycombs:FindFirstChild(LocalPlayer.Name)
            local plate = hive and hive:FindFirstChild("SpawnPos")
            if plate then
                TweenTo(hrp, plate.Position + Vector3.new(0,3,0))
                task.wait(2)
            end
            State = "FARM"
        end

        -- FARM STATE
        if State == "FARM" and not CurrentTween then
            local target = GetZigZagTarget(SelectedField)
            local dir = target - hrp.Position
            if not IsBlocked(hrp.Position, dir, char) then
                TweenTo(hrp, target)
            end
        end
    end
end)

--// AUTO CLICK LOOP
task.spawn(function()
    while task.wait(0.1) do
        if AutoFarm and AutoClick and State == "FARM" then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end
    end
end)