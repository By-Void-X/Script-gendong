-- Delta: behind teleport + auto attack + no cooldown + attack speed — fixture
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local CONFIG = {
    OFFSET_BEHIND = 4,       -- stud di belakang target
    OFFSET_UP = 0,
    TP_INTERVAL = 0.25,      -- frekuensi teleport (detik), dikecilkan
    ATTACK_INTERVAL = 0.05,  -- interval serangan (attack speed)
    BASE_ATTACK_SPEED = 1.6, -- pengali attack speed (1 = normal, >1 lebih cepat)
    AUTO_TARGET = true,
}
local enabled = false
local target = nil
local lastTP = 0
local lastAttack = 0

-- ===== GUI =====
local sg = Instance.new("ScreenGui")
sg.Name = "BehindAura"
sg.ResetOnSpawn = false
sg.Parent = lp:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 190)
main.Position = UDim2.new(0, 20, 0, 20)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 200, 0, 40)
toggle.Position = UDim2.new(0, 20, 0, 15)
toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
toggle.BorderSizePixel = 0
toggle.Text = "OFF"
toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 18
toggle.Parent = main

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 200, 0, 30)
speedBox.Position = UDim2.new(0, 20, 0, 65)
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 52)
speedBox.BorderSizePixel = 0
speedBox.Text = "Attack Speed: " .. CONFIG.BASE_ATTACK_SPEED
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 13
speedBox.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 60)
status.Position = UDim2.new(0, 20, 0, 105)
status.BackgroundTransparency = 1
status.Text = "Status: idle"
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.Font = Enum.Font.Gotham
status.TextSize = 13
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
        if plr ~= lp then
            local r = getRoot(plr)
            local h = getHum(plr)
            if r and h and h.Health > 0 then
                local d = (myRoot.Position - r.Position).Magnitude
                if d < bestDist then best, bestDist = plr, d end
            end
        end
    end
    return best
end

-- ===== teleport di belakang =====
local function tpBehind(plr)
    local myRoot = getRoot(lp)
    local tRoot = getRoot(plr)
    if not myRoot or not tRoot then return end
    local look = tRoot.CFrame.LookVector
    local behindPos = tRoot.Position - look * CONFIG.OFFSET_BEHIND + Vector3.new(0, CONFIG.OFFSET_UP, 0)
    myRoot.CFrame = CFrame.new(behindPos, tRoot.Position)
    local hum = getHum(lp)
    if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
end

-- ===== no cooldown: bypass tool cooldown klien =====
local function noCooldown(weapon)
    -- banyak tool menyimpan cooldown di atribut/Value; reset tiap tick
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
local function attack(plr)
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

-- ===== toggle =====
local function setEnabled(v)
    enabled = v
    toggle.Text = v and "ON" or "OFF"
    toggle.BackgroundColor3 = v and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(80, 80, 90)
end

toggle.MouseButton1Click:Connect(function() setEnabled(not enabled) end)

speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text:match("[%d%.]+"))
    if n and n >= 0.1 and n <= 10 then
        CONFIG.BASE_ATTACK_SPEED = n
        speedBox.Text = "Attack Speed: " .. n
    else
        speedBox.Text = "Attack Speed: " .. CONFIG.BASE_ATTACK_SPEED
    end
end)

-- ===== loop utama =====
RunService.Heartbeat:Connect(function()
    if not enabled then return end

    if CONFIG.AUTO_TARGET or not target or not getHum(target) or getHum(target).Health <= 0 then
        target = nearestTarget()
    end
    if not target then
        status.Text = "ON | target: -"
        return
    end

    -- teleport dengan interval kecil (tidak tiap frame)
    if tick() - lastTP >= CONFIG.TP_INTERVAL then
        tpBehind(target)
        lastTP = tick()
    end

    -- attack dengan attack speed
    local interval = CONFIG.ATTACK_INTERVAL / CONFIG.BASE_ATTACK_SPEED
    if tick() - lastAttack >= interval then
        if attack(target) then
            lastAttack = tick()
        end
    end

    local th = getHum(target)
    status.Text = "ON | " .. target.Name .. " | HP: " .. math.floor(th and th.Health or 0)
end)
