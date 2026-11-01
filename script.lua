-- Jail Lockdown System (Spam State + Physical Cage)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local selectedPlayer = nil
local isJailed = false
local jailConnection = nil
local currentCage = nil

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
panel.Size = UDim2.new(0, 220, 0, 250)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-20,0,130)
scroll.Position = UDim2.new(0,10,0,10)
scroll.BackgroundColor3 = Color3.fromRGB(35,35,35)
scroll.Parent = panel

local uiList = Instance.new("UIListLayout")
uiList.Parent = scroll

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,145)
status.Text = "Pilih Target..."
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(255, 255, 100)
status.BackgroundTransparency = 1
status.Parent = panel

local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(1,-20,0,40)
actionBtn.Position = UDim2.new(0,10,0,190)
actionBtn.Text = "Kurung Target: OFF"
actionBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
actionBtn.TextColor3 = Color3.fromRGB(255,255,255)
actionBtn.Parent = panel

toggle.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

-- ================= PLAYER LIST =================
local function updateList()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 30)
            btn.Text = p.Name
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Parent = scroll
            btn.MouseButton1Click:Connect(function()
                for _, otherBtn in ipairs(scroll:GetChildren()) do
                    if otherBtn:IsA("TextButton") then otherBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end
                end
                btn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
                selectedPlayer = p
                status.Text = "Target: " .. p.Name
            end)
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 35)
end
updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- ================= FUNGSI BIKIN KANDANG =================
local function createCage(pos)
    if currentCage then currentCage:Destroy() end
    currentCage = Instance.new("Model")
    currentCage.Name = "JailCage"
    currentCage.Parent = workspace

    -- Bikin 6 sisi kandang (Kotak)
    local size = Vector3.new(6, 6, 6)
    local offsets = {
        Vector3.new(0, 3, 3), Vector3.new(0, 3, -3), -- Depan Belakang
        Vector3.new(3, 3, 0), Vector3.new(-3, 3, 0), -- Kanan Kiri
        Vector3.new(0, 6, 0), Vector3.new(0, 0, 0)   -- Atas Bawah
    }

    for _, offset in ipairs(offsets) do
        local wall = Instance.new("Part")
        wall.Size = size
        wall.Position = pos + offset
        wall.Anchored = true
        wall.CanCollide = true
        wall.Color = Color3.fromRGB(255, 0, 0) -- Warna merah biar keliatan kayak penjara
        wall.Material = Enum.Material.Neon
        wall.Transparency = 0.5
        wall.Parent = currentCage
    end
end

-- ================= FUNGSI BERSIHKAN =================
local function stopJail()
    isJailed = false
    if jailConnection then jailConnection:Disconnect() end
    if currentCage then currentCage:Destroy() end
    
    if selectedPlayer and selectedPlayer.Character then
        local hum = selectedPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            pcall(function() hum.WalkSpeed = 16 end)
        end
    end
    
    actionBtn.Text = "Kurung Target: OFF"
    actionBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    status.Text = "Target dibebaskan."
end

-- ================= AKSI JAIL =================
actionBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then return end

    isJailed = not isJailed

    if isJailed then
        actionBtn.Text = "Kurung Target: ON"
        actionBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        status.Text = "Mengurung " .. selectedPlayer.Name

        -- Loop Spam State
        jailConnection = RunService.Heartbeat:Connect(function()
            local char = selectedPlayer.Character
            if not char then stopJail() return end
            
            local hum = char:FindFirstChild("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            
            if hum and root then
                -- 1. Spam WalkSpeed 0
                hum.WalkSpeed = 0
                
                -- 2. Spam Sit (Bikin dia duduk terus)
                if not hum.Sit then
                    hum.Sit = true
                end
                
                -- 3. Cek Kandang (Bikin kandang di posisi dia)
                if not currentCage or not currentCage.Parent then
                    createCage(root.Position)
                else
                    -- Kalau dia keluar dari kandang (glitch), tarik kandangnya ke dia
                    local cageCenter = currentCage:GetPivot().Position
                    if (cageCenter - root.Position).Magnitude > 5 then
                        createCage(root.Position)
                    end
                end

                -- 4. Usaha Rampas Network Owner (Kadang bikin dia gak bisa gerak)
                pcall(function()
                    root:SetNetworkOwner(lp)
                    root.Velocity = Vector3.new(0, 0, 0) -- Nol kecepatan
                end)
            end
        end)
    else
        stopJail()
    end
end)
