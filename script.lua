-- Universal_CarryScript_V3.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local carriedPlayer = nil
local isCarrying = false
local currentWeld = nil

local gui = Instance.new("ScreenGui")
gui.Name = "CarryMenuV3"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 60, 0, 30)
toggle.Position = UDim2.new(0, 10, 0, 10)
toggle.Text = "MENU"
toggle.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggle.TextColor3 = Color3.fromRGB(255,255,255)
toggle.Parent = gui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 220, 0, 140)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

local carryBtn = Instance.new("TextButton")
carryBtn.Size = UDim2.new(1,-20,0,40)
carryBtn.Position = UDim2.new(0,10,0,10)
carryBtn.Text = "Paksa Gendong (Hack)"
carryBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
carryBtn.TextColor3 = Color3.fromRGB(255,255,255)
carryBtn.Parent = panel

local dropBtn = Instance.new("TextButton")
dropBtn.Size = UDim2.new(1,-20,0,40)
dropBtn.Position = UDim2.new(0,10,0,60)
dropBtn.Text = "Turunkan"
dropBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
dropBtn.TextColor3 = Color3.fromRGB(255,255,255)
dropBtn.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,105)
status.Text = "Status: Idle"
status.TextColor3 = Color3.fromRGB(200,200,200)
status.BackgroundTransparency = 1
status.Parent = panel

toggle.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

local function getNearestPlayer()
    local nearest = nil
    local shortestDist = 20
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local dist = (myRoot.Position - targetRoot.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                nearest = player
            end
        end
    end
    return nearest
end

-- FUNGSI LEPAS
local function releaseTarget()
    isCarrying = false
    if currentWeld then
        currentWeld:Destroy()
        currentWeld = nil
    end
    if carriedPlayer and carriedPlayer.Character then
        local targetHum = carriedPlayer.Character:FindFirstChild("Humanoid")
        local targetRoot = carriedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHum then
            targetHum.PlatformStand = false
            targetHum.WalkSpeed = 16
            targetHum.JumpPower = 50
        end
        if targetRoot then
            targetRoot.Anchored = false
        end
    end
    carriedPlayer = nil
    status.Text = "Status: Idle"
end

-- FUNGSI GENDONG (NETWORK GRAB)
carryBtn.MouseButton1Click:Connect(function()
    local target = getNearestPlayer()
    if target then
        carriedPlayer = target
        isCarrying = true
        status.Text = "Menggendong: " .. target.Name
        
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local targetChar = target.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local targetHum = targetChar and targetChar:FindFirstChild("Humanoid")
        
        if myRoot and targetRoot and targetHum then
            -- 1. RAMPAS KENDALI DARI SERVER (Network Ownership)
            pcall(function()
                targetRoot:SetNetworkOwner(lp)
            end)
            
            -- 2. MATIKAN KENDALI FISIK TARGET
            targetHum.PlatformStand = true
            targetHum.WalkSpeed = 0
            targetHum.JumpPower = 0
            
            -- 3. WELD (TEMPELKAN)
            if currentWeld then currentWeld:Destroy() end
            currentWeld = Instance.new("WeldConstraint")
            currentWeld.Part0 = myRoot
            currentWeld.Part1 = targetRoot
            currentWeld.Parent = myRoot
        end
    else
        status.Text = "Status: Tidak ada pemain!"
    end
end)

dropBtn.MouseButton1Click:Connect(function()
    releaseTarget()
end)

-- LOOP PENJAGA (Memastikan target tetap nyangkut)
RunService.Heartbeat:Connect(function()
    if isCarrying and carriedPlayer and carriedPlayer.Character then
        local targetRoot = carriedPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHum = carriedPlayer.Character:FindFirstChild("Humanoid")
        
        if targetRoot and targetHum then
            -- Paksa posisi dan status terus-menerus
            pcall(function()
                targetRoot:SetNetworkOwner(lp) -- Rampas terus tiap frame
                targetHum.PlatformStand = true
                targetHum.WalkSpeed = 0
            end)
            
            -- Jika weld terlepas, buat ulang
            if not currentWeld or not currentWeld.Parent then
                local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    currentWeld = Instance.new("WeldConstraint")
                    currentWeld.Part0 = myRoot
                    currentWeld.Part1 = targetRoot
                    currentWeld.Parent = myRoot
                end
            end
        else
            releaseTarget()
        end
    end
end)
