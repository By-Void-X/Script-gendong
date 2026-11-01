-- Troll Avatar (Giant, Speed Ram, Clone Spam)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local isGiant = false
local isSpeed = false
local speedConn = nil

-- ================= GUI SETUP =================
local gui = Instance.new("ScreenGui")
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
panel.Size = UDim2.new(0, 220, 0, 200)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

-- FITUR 1: RAKSASA (Nge-block jalan)
local giantBtn = Instance.new("TextButton")
giantBtn.Size = UDim2.new(1,-20,0,40)
giantBtn.Position = UDim2.new(0,10,0,10)
giantBtn.Text = "Mode Raksasa: OFF"
giantBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
giantBtn.TextColor3 = Color3.fromRGB(255,255,255)
giantBtn.Parent = panel

-- FITUR 2: SPEED RAM (Nabrak orang pake kecepatan)
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1,-20,0,40)
speedBtn.Position = UDim2.new(0,10,0,60)
speedBtn.Text = "Speed Ram: OFF"
speedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
speedBtn.Parent = panel

-- FITUR 3: KLONING (Spawn replika di tempat orang)
local cloneBtn = Instance.new("TextButton")
cloneBtn.Size = UDim2.new(1,-20,0,40)
cloneBtn.Position = UDim2.new(0,10,0,110)
cloneBtn.Text = "Spawn Klon Raksasa"
cloneBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
cloneBtn.TextColor3 = Color3.fromRGB(255,255,255)
cloneBtn.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,20)
status.Position = UDim2.new(0,10,0,160)
status.Text = "Siap"
status.TextColor3 = Color3.fromRGB(200,200,200)
status.BackgroundTransparency = 1
status.Parent = panel

toggle.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

-- ================= FITUR RAKSASA =================
giantBtn.MouseButton1Click:Connect(function()
    isGiant = not isGiant
    if isGiant then
        giantBtn.Text = "Mode Raksasa: ON"
        giantBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        giantBtn.Text = "Mode Raksasa: OFF"
        giantBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
    local char = lp.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            if isGiant then
                -- Ubah ukuran tubuh jadi super besar
                hum.BodyDepthScale.Value = 5
                hum.BodyWidthScale.Value = 5
                hum.BodyHeightScale.Value = 5
                hum.HeadScale.Value = 5
            else
                -- Balikin ke normal
                hum.BodyDepthScale.Value = 1
                hum.BodyWidthScale.Value = 1
                hum.BodyHeightScale.Value = 1
                hum.HeadScale.Value = 1
            end
        end
    end
end)

-- ================= FITUR SPEED RAM =================
speedBtn.MouseButton1Click:Connect(function()
    isSpeed = not isSpeed
    if isSpeed then
        speedBtn.Text = "Speed Ram: ON"
        speedBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        -- Loop buat ngebut terus
        speedConn = RunService.Heartbeat:Connect(function()
            local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if root then
                -- Paksa velocity maju dengan kecepatan tinggi
                local moveDir = lp.Character.Humanoid.MoveDirection
                if moveDir.Magnitude > 0 then
                    root.Velocity = moveDir * 500 -- Kecepatan super
                end
            end
        end)
    else
        speedBtn.Text = "Speed Ram: OFF"
        speedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        if speedConn then speedConn:Disconnect() end
    end
end)

-- ================= FITUR SPAWN KLON RAKSASA =================
cloneBtn.MouseButton1Click:Connect(function()
    local char = lp.Character
    if not char then return end
    
    status.Text = "Membuat Klon..."
    
    -- Kloning karakter kita
    local clone = char:Clone()
    clone.Name = "FakePlayer"
    
    -- Hapus script AI bawaan biar diem
    for _, v in pairs(clone:GetDescendants()) do
        if v:IsA("Script") or v:IsA("LocalScript") then
            v:Destroy()
        end
    end
    
    -- Taruh di posisi kita sekarang
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        clone:SetPrimaryPartCFrame(root.CFrame * CFrame.new(0, 0, -5))
    end
    
    -- Bikin raksasa
    local hum = clone:FindFirstChild("Humanoid")
    if hum then
        hum.BodyDepthScale.Value = 5
        hum.BodyWidthScale.Value = 5
        hum.BodyHeightScale.Value = 5
        hum.HeadScale.Value = 5
        hum.WalkSpeed = 0 -- Biar diem
    end
    
    -- Anchored (Kunci di tempat)
    for _, part in pairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = true
        end
    end
    
    clone.Parent = workspace
    status.Text = "Klon berhasil dibuat!"
end)
