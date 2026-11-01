-- Invisible Bulldozer Ram (Memanfaatkan Fisika)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local isRamming = false
local ramPart = nil
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
panel.Size = UDim2.new(0, 220, 0, 130)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

local ramBtn = Instance.new("TextButton")
ramBtn.Size = UDim2.new(1,-20,0,50)
ramBtn.Position = UDim2.new(0,10,0,10)
ramBtn.Text = "BULLDOZER RAM: OFF"
ramBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ramBtn.TextColor3 = Color3.fromRGB(255,255,255)
ramBtn.Font = Enum.Font.SourceSansBold
ramBtn.TextSize = 18
ramBtn.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,40)
status.Position = UDim2.new(0,10,0,70)
status.Text = "Siap. Tekan tombol saat berlari."
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(200,200,200)
status.BackgroundTransparency = 1
status.Parent = panel

toggle.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

-- ================= FITUR BULLDOZER =================
local function clearBulldozer()
    isRamming = false
    if speedConn then speedConn:Disconnect() end
    if ramPart then ramPart:Destroy() end
    
    local char = lp.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16 -- Balikin kecepatan normal
            hum.JumpPower = 50
        end
    end
end

ramBtn.MouseButton1Click:Connect(function()
    isRamming = not isRamming
    
    if isRamming then
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if root and hum then
            ramBtn.Text = "BULLDOZER RAM: ON"
            ramBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            status.Text = "Anda sekarang jadi Bulldozer! Jalan dan tabrak mereka."
            
            -- 1. Bikin batok raksasa transparan (Hitbox)
            ramPart = Instance.new("Part")
            ramPart.Name = "RamHitbox"
            ramPart.Size = Vector3.new(12, 12, 12) -- Ukuran raksasa
            ramPart.Transparency = 1 -- Gaib (gak keliatan)
            ramPart.CanCollide = true -- TAPI BISA NABRAK
            ramPart.Anchored = false
            ramPart.Massless = true -- Biar gak berat
            ramPart.Parent = char
            
            -- Tempel ke badan kita
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = root
            weld.Part1 = ramPart
            weld.Parent = ramPart
            ramPart.CFrame = root.CFrame
            
            -- 2. Loop Kecepatan Tinggi
            speedConn = RunService.Heartbeat:Connect(function()
                local c = lp.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                local h = c and c:FindFirstChild("Humanoid")
                
                if r and h then
                    h.WalkSpeed = 100 -- Kecepatan lari maksimal (ngebut)
                    
                    -- Jika pemain bergerak, dorong pakai Velocity maksimal
                    local moveDir = h.MoveDirection
                    if moveDir.Magnitude > 0 then
                        r.Velocity = moveDir * 250 -- Kekuatan tabrakan
                        
                        -- Putar hitbox-nya biar makin gila tabrakannya
                        ramPart.CFrame = r.CFrame * CFrame.Angles(math.rad(math.random(-360,360)), math.rad(math.random(-360,360)), math.rad(math.random(-360,360)))
                    else
                        -- Kalau diem, tetep pasang di badan
                        ramPart.CFrame = r.CFrame
                    end
                end
            end)
        end
    else
        clearBulldozer()
        ramBtn.Text = "BULLDOZER RAM: OFF"
        ramBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        status.Text = "Bulldozer dimatikan."
    end
end)

-- Matikan otomatis kalau mati
lp.CharacterAdded:Connect(function()
    clearBulldozer()
    ramBtn.Text = "BULLDOZER RAM: OFF"
    ramBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)
