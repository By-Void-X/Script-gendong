-- Brookhaven Universal Explosive Injector
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local selectedPlayer = nil
local selectedTool = nil

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
panel.Size = UDim2.new(0, 260, 0, 380)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

-- List Player
local scrollP = Instance.new("ScrollingFrame")
scrollP.Size = UDim2.new(1,-20,0,100)
scrollP.Position = UDim2.new(0,10,0,10)
scrollP.BackgroundColor3 = Color3.fromRGB(35,35,35)
scrollP.Parent = panel
local uiListP = Instance.new("UIListLayout")
uiListP.Parent = scrollP

-- List Tool (Senjata)
local scrollT = Instance.new("ScrollingFrame")
scrollT.Size = UDim2.new(1,-20,0,100)
scrollT.Position = UDim2.new(0,10,0,120)
scrollT.BackgroundColor3 = Color3.fromRGB(35,35,35)
scrollT.Parent = panel
local uiListT = Instance.new("UIListLayout")
uiListT.Parent = scrollT

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,40)
status.Position = UDim2.new(0,10,0,230)
status.Text = "Pilih Target & Alat"
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(255, 255, 100)
status.BackgroundTransparency = 1
status.Parent = panel

local actionBtn = Instance.new("TextButton")
actionBtn.Size = UDim2.new(1,-20,0,40)
actionBtn.Position = UDim2.new(0,10,0,280)
actionBtn.Text = "TP & Ledakkan Target"
actionBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
actionBtn.TextColor3 = Color3.fromRGB(255,255,255)
actionBtn.Parent = panel

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1,-20,0,30)
scanBtn.Position = UDim2.new(0,10,0,330)
scanBtn.Text = "Scan Ulang Alat (Tool) di Game"
scanBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
scanBtn.TextColor3 = Color3.fromRGB(255,255,255)
scanBtn.Parent = panel

toggle.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

-- ================= LOAD PLAYERS =================
local function updateList()
    for _, child in ipairs(scrollP:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 25)
            btn.Text = p.Name
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Parent = scrollP
            btn.MouseButton1Click:Connect(function()
                for _, otherBtn in ipairs(scrollP:GetChildren()) do
                    if otherBtn:IsA("TextButton") then otherBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end
                end
                btn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
                selectedPlayer = p
                status.Text = "Target: " .. p.Name
            end)
        end
    end
    scrollP.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 30)
end
updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- ================= SCAN TOOLS =================
local function scanTools()
    for _, child in ipairs(scrollT:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    selectedTool = nil
    local count = 0
    
    -- Scan ReplicatedStorage dan Workspace
    for _, parent in ipairs({ReplicatedStorage, workspace}) do
        for _, v in ipairs(parent:GetDescendants()) do
            if v:IsA("Tool") then
                -- Filter biar yg muncul cuma yg berpotensi meledak / nembak
                local n = string.lower(v.Name)
                if n:find("c4") or n:find("bomb") or n:find("grenade") or n:find("dynamite") or n:find("firework") or n:find("rocket") then
                    count = count + 1
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -5, 0, 25)
                    btn.Text = v.Name
                    btn.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    btn.Parent = scrollT
                    btn.MouseButton1Click:Connect(function()
                        for _, otherBtn in ipairs(scrollT:GetChildren()) do
                            if otherBtn:IsA("TextButton") then otherBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 50) end
                        end
                        btn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
                        selectedTool = v
                        status.Text = "Alat dipilih: " .. v.Name
                    end)
                end
            end
        end
    end
    
    scrollT.CanvasSize = UDim2.new(0, 0, 0, count * 30)
    if count == 0 then
        status.Text = "Tidak ada alat peledak ditemukan. Coba scan saat game berjalan."
    end
end
scanBtn.MouseButton1Click:Connect(scanTools)
scanTools()

-- ================= AKSI =================
actionBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then
        status.Text = "Pilih target dulu!"
        return
    end
    if not selectedTool then
        status.Text = "Pilih alat peledak dari daftar!"
        return
    end
    
    local targetChar = selectedPlayer.Character
    local targetHum = targetChar:FindFirstChild("Humanoid")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetBackpack = selectedPlayer:FindFirstChild("Backpack")
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    
    if myRoot and targetRoot and targetHum and targetBackpack then
        -- 1. TP ke target
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
        status.Text = "TP & Injecting " .. selectedTool.Name .. "..."
        
        task.wait(0.2)
        
        -- 2. Inject ke tas target
        for i = 1, 10 do
            task.spawn(function()
                local clone = selectedTool:Clone()
                clone.Parent = targetBackpack
                
                task.wait(0.1)
                
                -- 3. Paksa equip dan aktifkan
                pcall(function()
                    targetHum:EquipTool(clone)
                    task.wait(0.2)
                    clone:Activate() -- Nembak / Ledakkan
                end)
            end)
            task.wait(0.1)
        end
    end
end)
