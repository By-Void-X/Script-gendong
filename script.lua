-- Mega Spin Fling (Weld Physics)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local selectedPlayer = nil
local isFlinging = false
local currentWeld = nil

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
actionBtn.Text = "Mulai Spin Fling: OFF"
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
local function stopFling()
    isFlinging = false
    if currentWeld then
        currentWeld:Destroy()
        currentWeld = nil
    end
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = lp.Character.HumanoidRootPart
        for _, v in pairs(myRoot:GetChildren()) do
            if v:IsA("BodyAngularVelocity") or v:IsA("BodyVelocity") then
                v:Destroy()
            end
        end
    end
    actionBtn.Text = "Mulai Spin Fling: OFF"
    actionBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end

-- ================= AKSI FLING =================
actionBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then
        status.Text = "Target tidak valid/mati!"
        return
    end

    isFlinging = not isFlinging

    if isFlinging then
        actionBtn.Text = "Spin Fling: ON (Hentikan)"
        actionBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        status.Text = "Mentransfer Fisika ke " .. selectedPlayer.Name

        local targetChar = selectedPlayer.Character
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")

        if myRoot and targetRoot then
            -- 1. Pindahkan kita ke target
            myRoot.CFrame = targetRoot.CFrame

            -- 2. Pasang Body Velocity & Angular Velocity ke KARAKTER KITA
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(999999, 999999, 999999)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Parent = myRoot

            local bav = Instance.new("BodyAngularVelocity")
            bav.AngularVelocity = Vector3.new(999999, 999999, 999999)
            bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bav.Parent = myRoot

            -- 3. WELD (Ikat badan kita ke badan target)
            if currentWeld then currentWeld:Destroy() end
            currentWeld = Instance.new("WeldConstraint")
            currentWeld.Part0 = myRoot
            currentWeld.Part1 = targetRoot
            currentWeld.Parent = myRoot

            -- 4. Loop Penjaga (Kalau weld lepas atau target kabur, pasang lagi)
            task.spawn(function()
                while isFlinging do
                    task.wait(0.1)
                    local tRoot = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local mRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                    
                    if tRoot and mRoot then
                        pcall(function()
                            -- Coba rampas kendali server terus-terusan
                            tRoot:SetNetworkOwner(lp)
                            
                            -- Kalau weld hilang, buat baru
                            if not currentWeld or not currentWeld.Parent then
                                currentWeld = Instance.new("WeldConstraint")
                                currentWeld.Part0 = mRoot
                                currentWeld.Part1 = tRoot
                                currentWeld.Parent = mRoot
                            end
                            
                            -- Hapus velocity target biar dia gak bisa ngelawan
                            for _, v in pairs(tRoot:GetChildren()) do
                                if v:IsA("BodyVelocity") then v:Destroy() end
                            end
                        end)
                    else
                        stopFling()
                    end
                end
            end)
        end
    else
        stopFling()
        status.Text = "Berhenti Fling."
    end
end)
