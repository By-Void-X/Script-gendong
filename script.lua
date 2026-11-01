-- Delta: Behind Aura — teleport dekat belakang target + auto attack
-- Fitur: target list, offset input, attack speed, no cooldown, auto/terdekat
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local CONFIG = {
    OFFSET_BEHIND = 1.5,     -- jarak di belakang target (stud)
    OFFSET_UP = 0,
    TP_INTERVAL = 0.2,       -- interval teleport
    ATTACK_INTERVAL = 0.05,  -- dasar interval serangan
    BASE_ATTACK_SPEED = 1.6, -- pengali attack speed
    AUTO_TARGET = true,
}

local enabled = false
local manualTarget = nil
local target = nil
local lastTP = 0
local lastAttack = 0

-- ===== GUI =====
local sg = Instance.new("ScreenGui")
sg.Name = "BehindAura"
sg.ResetOnSpawn = false
sg.Parent = lp:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 250, 0, 430)
main.Position = UDim2.new(0, 20, 0, 20)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
title.BorderSizePixel = 0
title.Text = "Behind Aura"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = main

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 210, 0, 38)
toggle.Position = UDim2.new(0, 20, 0, 40)
toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
toggle.BorderSizePixel = 0
toggle.Text = "OFF"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 17
toggle.Parent = main

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 210, 0, 26)
speedBox.Position = UDim2.new(0, 20, 0, 84)
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
speedBox.BorderSizePixel = 0
speedBox.Text = "Attack Speed: " .. CONFIG.BASE_ATTACK_SPEED
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 12
speedBox.Parent = main

local offsetBox = Instance.new("TextBox")
offsetBox.Size = UDim2.new(0, 210, 0, 26)
offsetBox.Position = UDim2.new(0, 20, 0, 115)
offsetBox.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
offsetBox.BorderSizePixel = 0
offsetBox.Text = "Offset: " .. CONFIG.OFFSET_BEHIND
offsetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
offsetBox.Font = Enum.Font.Gotham
offsetBox.TextSize = 12
offsetBox.Parent = main

local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -40, 0, 20)
listLabel.Position = UDim2.new(0, 20, 0, 148)
listLabel.BackgroundTransparency = 1
listLabel.Text = "Pilih target TP:"
listLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
listLabel.Font = Enum.Font.Gotham
listLabel.TextSize = 12
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = main

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(0, 210, 0, 175)
playerList.Position = UDim2.new(0, 20, 0, 170)
playerList.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 4
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Parent = main

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = playerList
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0, 210, 0, 28)
autoBtn.Position = UDim2.new(0, 20, 0, 353)
autoBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
autoBtn.BorderSizePixel = 0
autoBtn.Text = "Auto Target (terdekat)"
autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBtn.Font = Enum.Font.Gotham
autoBtn.TextSize = 12
autoBtn.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 35)
status.Position = UDim2.new(0, 20, 0, 386)
status.BackgroundTransparency = 1
status.Text = "Status: idle"
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.Font = Enum.Font.Gotham
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextWrapped = true
status.Parent = main

-- ===== util =====
local function getRoot(plr)
    local char = plr and plr.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHum(plr)
    local char = plr and plr.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function isAlive(plr)
    local h = getHum(plr)
    return h and h.Health > 0
end

local function getWeapon()
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
    return nil
end

local function nearestTarget()
    local myRoot = getRoot(lp)
    if not myRoot then return nil end
    local best, bestDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp and isAlive(plr) then
            local r = getRoot(plr)
            if r then
                local d = (myRoot.Position - r.Position).Magnitude
                if d < bestDist then best, bestDist = plr, d end
            end
        end
    end
    return best
end

-- ===== daftar pemain =====
local function refreshPlayers()
    for _, c in ipairs(playerList:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= lp then
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -4, 0, 26)
            b.BackgroundColor3 = (manualTarget == plr)
                and Color3.fromRGB(0, 140, 70)
                or Color3.fromRGB(50, 50, 62)
            b.BorderSizePixel = 0
            b.Text = plr.Name .. (isAlive(plr) and "" or " (mati)")
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.Gotham
            b.TextSize = 12
            b.Parent = playerList
            b.MouseButton1Click:Connect(function()
                manualTarget = plr
                target = plr
                status.Text = "Target dikunci: " .. plr.Name
                refreshPlayers()
            end)
        end
    end

    playerList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

refreshPlayers()
Players.PlayerAdded:Connect(function() task.wait(1) refreshPlayers() end)
Players.PlayerRemoving:Connect(function(plr)
    if manualTarget == plr then
        manualTarget = nil
        target = nil
        status.Text = "Target keluar, kembali ke auto"
    end
    task.wait(0.1)
    refreshPlayers()
end)

task.spawn(function()
    while task.wait(3) do
        refreshPlayers()
    end
end)

-- ===== teleport di belakang =====
local function tpBehind(plr)
    local myRoot = getRoot(lp)
    local tRoot = getRoot(plr)
    if not myRoot or not tRoot then return end

    local look = tRoot.CFrame.LookVector
    local behindDir = -look
    local behindPos = tRoot.Position
        + behindDir * CONFIG.OFFSET_BEHIND
        + Vector3.new(0, CONFIG.OFFSET_UP, 0)

    myRoot.CFrame = CFrame.new(behindPos, tRoot.Position)

    local hum = getHum(lp)
    if hum then
        hum:ChangeState(Enum.HumanoidStateType.Running)
        hum.PlatformStand = false
    end

    myRoot.AssemblyLinearVelocity = Vector3.zero
    myRoot.AssemblyAngularVelocity = Vector3.zero
end

-- ===== no cooldown =====
local function noCooldown(weapon)
    local cd = weapon:FindFirstChild("Cooldown")
    if cd and cd:IsA("ValueBase") then
        pcall(function() cd.Value = 0 end)
    end
    for _, child in ipairs(weapon:GetChildren()) do
        if child:IsA("NumberValue") and string.find(child.Name:lower(), "cooldown") then
            pcall(function() child.Value = 0 end)
        end
    end
end

-- ===== attack =====
local function attack()
    local weapon = getWeapon()
    local hum = getHum(lp)
    if not weapon or not hum then return false end
    if not weapon.Parent then
        pcall(function() hum:EquipTool(weapon) end)
    end
    noCooldown(weapon)
    pcall(function() weapon:Activate() end)
    return true
end

-- ===== input =====
local function setEnabled(v)
    enabled = v
    toggle.Text = v and "ON" or "OFF"
    toggle.BackgroundColor3 = v and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(80, 80, 90)
end

toggle.MouseButton1Click:Connect(function() setEnabled(not enabled) end)

autoBtn.MouseButton1Click:Connect(function()
    manualTarget = nil
    target = nil
    status.Text = "Mode: auto target"
    refreshPlayers()
end)

speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text:match("[%d%.]+"))
    if n and n >= 0.1 and n <= 10 then
        CONFIG.BASE_ATTACK_SPEED = n
        speedBox.Text = "Attack Speed: " .. n
    else
        speedBox.Text = "Attack Speed: " .. CONFIG.BASE_ATTACK_SPEED
    end
end)

offsetBox.FocusLost:Connect(function()
    local n = tonumber(offsetBox.Text:match("[%d%.]+"))
    if n and n >= 0.5 and n <= 10 then
        CONFIG.OFFSET_BEHIND = n
        offsetBox.Text = "Offset: " .. n
    else
        offsetBox.Text = "Offset: " .. CONFIG.OFFSET_BEHIND
    end
end)

-- ===== loop utama =====
RunService.Heartbeat:Connect(function()
    if not enabled then return end

    if manualTarget and isAlive(manualTarget) then
        target = manualTarget
    elseif CONFIG.AUTO_TARGET or not target or not isAlive(target) then
        target = nearestTarget()
    end

    if not target then
        status.Text = "ON | target: -"
        return
    end

    if tick() - lastTP >= CONFIG.TP_INTERVAL then
        tpBehind(target)
        lastTP = tick()
    end

    local interval = CONFIG.ATTACK_INTERVAL / CONFIG.BASE_ATTACK_SPEED
    if tick() - lastAttack >= interval then
        if attack() then
            lastAttack = tick()
        end
    end

    local th = getHum(target)
    status.Text = "ON | " .. target.Name .. " | HP: " .. math.floor(th and th.Health or 0)
        .. " | off: " .. CONFIG.OFFSET_BEHIND
end)
