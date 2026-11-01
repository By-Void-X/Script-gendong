-- Delta: Kill Aura Mod Menu (auto tool, face target, multi-hit) — fixture
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local CONFIG = {
    RANGE = 15,
    COOLDOWN = 0.1,
    AUTO_EQUIP = true,
    MULTI_TARGET = true,
    FACE_TARGET = true,
}
local enabled = false
local lastAttack = 0
local currentToolName = "-"
local hitCount = 0

-- ===== GUI =====
local sg = Instance.new("ScreenGui")
sg.Name = "KillAuraMenu"
sg.ResetOnSpawn = false
sg.Parent = lp:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 250, 0, 260)
main.Position = UDim2.new(0, 20, 0, 20)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
title.BorderSizePixel = 0
title.Text = "Kill Aura Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = main

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 210, 0, 42)
toggleBtn.Position = UDim2.new(0, 20, 0, 45)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Parent = main

local rangeBox = Instance.new("TextBox")
rangeBox.Size = UDim2.new(0, 210, 0, 32)
rangeBox.Position = UDim2.new(0, 20, 0, 95)
rangeBox.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
rangeBox.BorderSizePixel = 0
rangeBox.Text = "Range: " .. CONFIG.RANGE
rangeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
rangeBox.Font = Enum.Font.Gotham
rangeBox.TextSize = 14
rangeBox.Parent = main

local function makeToggle(text, y, getValue, setValue)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 210, 0, 30)
    b.Position = UDim2.new(0, 20, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
    b.BorderSizePixel = 0
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.Text = text .. ": " .. (getValue() and "ON" or "OFF")
    b.Parent = main
    b.MouseButton1Click:Connect(function()
        setValue(not getValue())
        b.Text = text .. ": " .. (getValue() and "ON" or "OFF")
    end)
end

makeToggle("Multi Target", 135, function() return CONFIG.MULTI_TARGET end, function(v) CONFIG.MULTI_TARGET = v end)
makeToggle("Face Target", 170, function() return CONFIG.FACE_TARGET end, function(v) CONFIG.FACE_TARGET = v end)
makeToggle("Auto Equip", 205, function() return CONFIG.AUTO_EQUIP end, function(v) CONFIG.AUTO_EQUIP = v end)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 20)
status.Position = UDim2.new(0, 20, 0, 235)
status.BackgroundTransparency = 1
status.Text = "Status: idle"
status.TextColor3 = Color3.fromRGB(170, 170, 170)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

-- ===== FUNGSI =====
local function findBestTool()
    local char = lp.Character
    if not char then return nil end
    local held = char:FindFirstChildOfClass("Tool")
    if held then return held end
    local bp = lp:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then return t end
        end
    end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then return t end
    end
    return nil
end

local function getWeapon()
    local char = lp.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool") or findBestTool()
end

local function inRange(targetChar)
    local myChar = lp.Character
    if not myChar then return false end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local tRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return false end
    return (myRoot.Position - tRoot.Position).Magnitude <= CONFIG.RANGE
end

local function faceTarget(targetChar)
    if not CONFIG.FACE_TARGET then return end
    local myChar = lp.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local tRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return end
    local dir = (tRoot.Position - myRoot.Position).Unit
    myRoot.CFrame = CFrame.new(myRoot.Position, myRoot.Position + dir)
end

-- Auto equip
task.spawn(function()
    while task.wait(0.5) do
        if not CONFIG.AUTO_EQUIP then continue end
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if char and hum and not char:FindFirstChildOfClass("Tool") then
            local tool = findBestTool()
            if tool then
                pcall(function() hum:EquipTool(tool) end)
            end
        end
    end
end)

-- ===== TOGGLE =====
local function setEnabled(state)
    enabled = state
    if enabled then
        toggleBtn.Text = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    else
        toggleBtn.Text = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    end
end

toggleBtn.MouseButton1Click:Connect(function() setEnabled(not enabled) end)

rangeBox.FocusLost:Connect(function()
    local n = tonumber(rangeBox.Text:match("%d+"))
    if n and n > 0 and n <= 100 then
        CONFIG.RANGE = n
        rangeBox.Text = "Range: " .. n
    else
        rangeBox.Text = "Range: " .. CONFIG.RANGE
    end
end)

-- ===== LOOP =====
RunService.Heartbeat:Connect(function()
    if not enabled then return end
    if tick() - lastAttack < CONFIG.COOLDOWN then return end

    local weapon = getWeapon()
    if not weapon then
        status.Text = "Status: ON | Tool: tidak ada"
        return
    end
    currentToolName = weapon.Name
    hitCount = 0

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and inRange(char) then
                faceTarget(char)
                pcall(function() weapon:Activate() end)
                hitCount += 1
                if not CONFIG.MULTI_TARGET then break end
            end
        end
    end

    if hitCount > 0 then
        lastAttack = tick()
        status.Text = "ON | " .. currentToolName .. " | hit: " .. hitCount
    else
        status.Text = "ON | " .. currentToolName .. " | target: -"
    end
end)

-- Hotkey K
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        setEnabled(not enabled)
    end
end)
