-- Brookhaven TP & Spawn 50 C4
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
findC4Btn.Text = "Cari Ulang Asset C4"
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

-- ================= CARI ASSET C4 =================
local function findC4()
    c4Template = nil
    -- Scan Workspace dan ReplicatedStorage
    for _, parent in ipairs({workspace, ReplicatedStorage}) do
        for _, v in ipairs(parent:GetDescendants()) do
            local n = string.lower(v.Name)
            if n == "c4" or n:find("c4") or n:find("bomb") or n:find("explosive") then
                -- Biasanya C4 berupa Tool atau Part
                if v:IsA("Tool") or v:IsA("Model") or v:IsA("Part") then
                    c4Template = v
                    status.Text = "C4 Ditemukan: " .. v.Name
                    return
                end
            end
        end
    end
    status.Text = "Asset C4 tidak ditemukan di map (Hanya Tool/Part)."
end
findC4Btn.MouseButton1Click:Connect(findC4)

-- ================= AKSI LEDAKKAN =================
actionBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then
        status.Text = "Target tidak valid/mati!"
        return
    end
    
    if not c4Template then
        findC4() -- Coba cari dulu kalau belum ada
        if not c4Template then return end
    end
    
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if myRoot and targetRoot then
        -- 1. TP ke target
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
        status.Text = "TP ke " .. selectedPlayer.Name .. " & Meluncurkan C4..."
        
        task.wait(0.5) -- Jeda dikit biar TP selesai
        
        -- 2. Spawn 50 C4
        for i = 1, 50 do
            task.spawn(function()
                local clone = c4Template:Clone()
                clone.Parent = workspace
                
                local offsetX = math.random(-10, 10)
                local offsetZ = math.random(-10, 10)
                
                if clone:IsA("Model") and clone.PrimaryPart then
                    clone:SetPrimaryPartCFrame(targetRoot.CFrame * CFrame.new(offsetX, 2, offsetZ))
                elseif clone:IsA("BasePart") then
                    clone.CFrame = targetRoot.CFrame * CFrame.new(offsetX, 2, offsetZ)
                elseif clone:IsA("Tool") then
                    -- Kalau bentuknya Tool, paksa pindah ke Backpack/Character target (karena Tool harus dipegang)
                    clone.Parent = selectedPlayer.Backpack 
                    -- Coba paksa target equip
                    task.spawn(function()
                        pcall(function() selectedPlayer.Character.Humanoid:EquipTool(clone) end)
                    end)
                end
                
                -- 3. Picu Ledakan (Cari ProximityPrompt atau RemoteEvent di dalam C4)
                task.wait(0.1)
                for _, child in ipairs(clone:GetDescendants()) do
                    if child:IsA("ProximityPrompt") then
                        pcall(function() child:InputHoldBegin() task.wait(0.1) child:InputHoldEnd() end)
                    elseif child:IsA("ClickDetector") then
                        pcall(function() fireclickdetector(child) end)
                    end
                end
            end)
        end
    end
end)
