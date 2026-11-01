-- Internal Spin Fling (TP ke dalam badan + putar kencang)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local selectedPlayer = nil
local isSpinning = false
local spinConn = nil

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
actionBtn.Text = "Internal Spin: OFF"
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

-- ================= FUNGSI BERSIHKAN =================
local function stopSpin()
    isSpinning = false
    if spinConn then spinConn:Disconnect() end
    
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if myRoot then
        for _, v in pairs(myRoot:GetChildren()) do
            if v:IsA("BodyAngularVelocity") or v:IsA("BodyVelocity") then
                v:Destroy()
            end
        end
    end
    
    local myHum = lp.Character and lp.Character:FindFirstChild("Humanoid")
    if myHum then
        myHum.WalkSpeed = 16
    end

    actionBtn.Text = "Internal Spin: OFF"
    actionBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    status.Text = "Berhenti berputar."
end

-- ================= AKSI SPIN =================
actionBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then
        status.Text = "Target tidak valid/mati!"
        return
    end

    isSpinning = not isSpinning

    if isSpinning then
        actionBtn.Text = "Internal Spin: ON (Stop)"
        actionBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        status.Text = "Menghancurkan " .. selectedPlayer.Name

        local myChar = lp.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar and myChar:FindFirstChild("Humanoid")

        if myRoot and myHum then
            myHum.WalkSpeed = 0 -- Kunci kita biar gak bisa digeser
            
            -- Bersihkan efek lama
            for _, v in pairs(myRoot:GetChildren()) do
                if v:IsA("BodyAngularVelocity") then v:Destroy() end
            end

            -- 1. Pasang Putaran Maksimal ke Karakter Kita
            local bav = Instance.new("BodyAngularVelocity")
            bav.AngularVelocity = Vector3.new(999999, 999999, 999999)
            bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bav.Parent = myRoot

            -- 2. Loop untuk terus menempel di dalam badan target
            spinConn = RunService.Heartbeat:Connect(function()
                local tChar = selectedPlayer.Character
                local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                
                if tRoot and myRoot then
                    -- Paksa posisi kita tepat di tengah (0,0,0) badan mereka
                    myRoot.CFrame = tRoot.CFrame
                    
                    -- Rampas Network Ownership target (biar servernya goyang)
                    pcall(function() tRoot:SetNetworkOwner(lp) end)
                else
                    stopSpin()
                end
            end)
        end
    else
        stopSpin()
    end
end)
