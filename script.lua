-- Delta: Kill Aura Mod Menu (auto tool detect) — fixture
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local CONFIG = {
    RANGE = 20,
    COOLDOWN = 0.2,
    AUTO_EQUIP = true,
}
local enabled = false
local lastAttack = 0
local currentToolName = "auto"

-- ===== GUI =====
local sg = Instance.new("ScreenGui")
sg.Name = "KillAuraMenu"
sg.ResetOnSpawn = false
sg.Parent = lp:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 200)
main.Position = UDim2.new(0, 20, 0, 20)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
title.BorderSizePixel = 0
title.Text = "Kill Aura (Auto Tool)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = main

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 200, 0, 45)
toggleBtn.Position = UDim2.new(0, 20, 0, 50)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 18
toggleBtn.Parent = main

local rangeBox = Instance.new("TextBox")
rangeBox.Size = UDim2.new(0, 200, 0, 35)
rangeBox.Position = UDim2.new(0, 20, 0, 105)
rangeBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
rangeBox.BorderSizePixel = 0
rangeBox.Text = "Range: " .. CONFIG.RANGE
rangeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
rangeBox.Font = Enum.Font.Gotham
rangeBox.TextSize = 14
rangeBox.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 40)
status.Position = UDim2.new(0, 20, 0, 150)
status.BackgroundTransparency = 1
status.Text = "Status: idle | Tool: -"
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextWrapped = true
status.Parent = main

-- ===== AUTO DETECT TOOL =====
local function findBestTool()
    local char = lp.Character
    if not char then return nil end

    -- 1) tool yang sedang dipegang
    local held = char:FindFirstChildOfClass("Tool")
    if held then return held end

    -- 2) tool di backpack
    local bp = lp:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then return t end
        end
    end

    -- 3) tool di karakter (selain held)
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then return t end
    end

    return nil
end

local function getWeapon()
    local char = lp.Character
    if not char then return nil end
    local held = char:FindFirstChildOfClass("Tool")
    if held then return held end
    return findBestTool()
end

local function inRange(targetChar)
    local myChar = lp.Character
    if not myChar then return false end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local tRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return false end
    return (myRoot.Position - tRoot.Position).Magnitude <= CONFIG.RANGE
end

-- Auto equip tool terbaik
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

toggleBtn.MouseButton1Click:Connect(function()
    setEnabled(not enabled)
end)

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
        status.Text = "Status: aktif | Tool: tidak ada"
        return
    end
    currentToolName = weapon.Name

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and inRange(char) then
                pcall(function() weapon:Activate() end)
                lastAttack = tick()
                status.Text = "Status: aktif | Tool: " .. currentToolName
                break
            end
        end
    end
end)

-- Hotkey K
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.K then
        setEnabled(not enabled)
    end
end)
