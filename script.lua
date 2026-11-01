-- Brookhaven REAL C4 Spammer (Tool Focus)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local selectedPlayer = nil
local c4Template = nil

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
panel.Size = UDim2.new(0, 240, 0, 320)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-20,0,150)
scroll.Position = UDim2.new(0,10,0,10)
scroll.BackgroundColor3 = Color3.fromRGB(35,35,35)
scroll.Parent = panel

local uiList = Instance.new("UIListLayout")
uiList.Parent = scroll

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,40)
status.Position = UDim2.new(0,10,0,165)
status.Text = "Pilih Target..."
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(255, 255, 100)
status.BackgroundTransparency = 1
status.Parent = panel

local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(1,-20,0,40)
actionBtn.Position = UDim2.new(0,10,0,210)
actionBtn.Text = "TP & Ledakkan 50 C4"
actionBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
actionBtn.TextColor3 = Color3.fromRGB(255,255,255)
actionBtn.Parent = panel

local findC4Btn = Instance.new("TextButton")
findC4Btn.Size = UDim2.new(1,-20,0,30)
findC4Btn.Position = UDim2.new(0,10,0,260)
findC4Btn.Text = "Scan C4 (Dari Tas / Game)"
findC4Btn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
findC4Btn.TextColor3 = Color3.fromRGB(255,255,255)
findC4Btn.Parent = panel

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

-- ================= CARI ASSET C4 (FOKUS TOOL) =================
local function findC4()
    c4Template = nil
    
    -- 1. Cek apakah kita sedang megang C4?
    for _, v in ipairs(lp.Character:GetChildren()) do
        if v:IsA("Tool") and (string.lower(v.Name):find("c4") or string.lower(v.Name):find("bomb")) then
            c4Template = v
            status.Text = "C4 Ditemukan di Tangan: " .. v.Name
            return
        end
    end
    
    -- 2. Cek di dalam Backpack kita?
    local backpack = lp:FindFirstChild("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if v:IsA("Tool") and (string.lower(v.Name):find("c4") or string.lower(v.Name):find("bomb")) then
                c4Template = v
                status.Text = "C4 Ditemukan di Tas: " .. v.Name
                return
            end
        end
    end

    -- 3. Kalau nggak ada, cari Tool di ReplicatedStorage
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("Tool") and (string.lower(v.Name):find("c4") or string.lower(v.Name):find("bomb")) then
            c4Template = v
            status.Text = "C4 Ditemukan di Game: " .. v.Name
            return
        end
    end
    
    status.Text = "C4 TIDAK DITEMUKAN. Pastikan kamu punya C4 di tas atau pegang!"
end
findC4Btn.MouseButton1Click:Connect(findC4)

-- ================= AKSI LEDAKKAN =================
actionBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then
        status.Text = "Target tidak valid/mati!"
        return
    end
    
    if not c4Template then
        findC4()
        if not c4Template then return end
    end
    
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local targetChar = selectedPlayer.Character
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHum = targetChar:FindFirstChild("Humanoid")
    local targetBackpack = selectedPlayer:FindFirstChild("Backpack")
    
    if myRoot and targetRoot and targetHum and targetBackpack then
        -- 1. TP ke target
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
        status.Text = "TP ke " .. selectedPlayer.Name .. " & Spawn 50 C4..."
        
        task.wait(0.5)
        
        -- 2. Spawn 50 C4
        for i = 1, 50 do
            task.spawn(function()
                local clone = c4Template:Clone()
                
                -- Paksa masuk ke tas target
                clone.Parent = targetBackpack
                
                task.wait(0.1)
                
                -- Paksa target equip C4 tersebut
                pcall(function()
                    targetHum:EquipTool(clone)
                end)
                
                task.wait(0.1)
                
                -- Paksa aktifkan C4 (Klik)
                pcall(function()
                    clone:Activate()
                end)
                
                -- Picu semua RemoteEvent yang ada di dalam C4 (buat jaga-jaga kalau Activate gak jalan)
                for _, remote in ipairs(clone:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer() end)
                    end
                end
            end)
            task.wait(0.05) -- Jeda antar spawn
        end
    end
end)
