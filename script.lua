-- Troll & Jail Menu (Invisible, Spin Fling, Drop)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local selectedPlayer = nil
local stalkMode = false
local spinMode = false
local stalkConn, spinConn

-- GUI
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
panel.Size = UDim2.new(0, 220, 0, 300)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1,-20,0,120)
scroll.Position = UDim2.new(0,10,0,10)
scroll.BackgroundColor3 = Color3.fromRGB(35,35,35)
scroll.Parent = panel
local uiList = Instance.new("UIListLayout")
uiList.Parent = scroll

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,20)
status.Position = UDim2.new(0,10,0,135)
status.Text = "Pilih Target..."
status.TextColor3 = Color3.fromRGB(255, 255, 100)
status.BackgroundTransparency = 1
status.Parent = panel

-- TOMBOL STALK
local stalkBtn = Instance.new("TextButton")
stalkBtn.Size = UDim2.new(1,-20,0,30)
stalkBtn.Position = UDim2.new(0,10,0,160)
stalkBtn.Text = "Stalk Mode: OFF"
stalkBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
stalkBtn.TextColor3 = Color3.fromRGB(255,255,255)
stalkBtn.Parent = panel

-- TOMBOL SPIN FLING
local spinBtn = Instance.new("TextButton")
spinBtn.Size = UDim2.new(1,-20,0,30)
spinBtn.Position = UDim2.new(0,10,0,195)
spinBtn.Text = "Spin Fling: OFF"
spinBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
spinBtn.TextColor3 = Color3.fromRGB(255,255,255)
spinBtn.Parent = panel

-- TOMBOL DROP ITEMS
local dropBtn = Instance.new("TextButton")
dropBtn.Size = UDim2.new(1,-20,0,30)
dropBtn.Position = UDim2.new(0,10,0,230)
dropBtn.Text = "Buang Barang Target"
dropBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
dropBtn.TextColor3 = Color3.fromRGB(255,255,255)
dropBtn.Parent = panel

toggle.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

local function updateList()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 25)
            btn.Text = p.Name
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Parent = scroll
            btn.MouseButton1Click:Connect(function()
                for _, o in ipairs(scroll:GetChildren()) do
                    if o:IsA("TextButton") then o.BackgroundColor3 = Color3.fromRGB(60, 60, 60) end
                end
                btn.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
                selectedPlayer = p
                status.Text = "Target: " .. p.Name
            end)
        end
    end
    scroll.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 30)
end
updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- FUNGSI STALK (NGIKUTIN DIAM-DIAM)
stalkBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then return end
    stalkMode = not stalkMode
    
    if stalkMode then
        stalkBtn.Text = "Stalk Mode: ON"
        stalkBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        -- Bikin kita transparan
        if lp.Character then
            for _, v in ipairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("Decal") then
                    v.Transparency = 1
                end
            end
        end
        
        stalkConn = RunService.Heartbeat:Connect(function()
            if not selectedPlayer or not selectedPlayer.Character then return end
            local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if myRoot and targetRoot then
                -- Tempel di belakang target
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2)
            end
        end)
    else
        stalkBtn.Text = "Stalk Mode: OFF"
        stalkBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        if stalkConn then stalkConn:Disconnect() end
        
        -- Balikin transparan
        if lp.Character then
            for _, v in ipairs(lp.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Transparency = 0
                end
            end
        end
    end
end)

-- FUNGSI SPIN FLING
spinBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then return end
    spinMode = not spinMode
    
    if spinMode then
        spinBtn.Text = "Spin Fling: ON"
        spinBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        spinConn = RunService.Heartbeat:Connect(function()
            local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if myRoot and targetRoot then
                -- TP ke badan dia sambil muter kencang
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(math.random(-360,360)), math.rad(math.random(-360,360)), math.rad(math.random(-360,360)))
                myRoot.Velocity = Vector3.new(math.random(-500,500), math.random(-500,500), math.random(-500,500))
            end
        end)
    else
        spinBtn.Text = "Spin Fling: OFF"
        spinBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        if spinConn then spinConn:Disconnect() end
    end
end)

-- FUNGSI BUANG BARANG (DROP TOOL)
dropBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then return end
    
    -- Cari Remote Drop di game
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local n = string.lower(remote.Name)
            if n:find("drop") or n:find("throw") or n:find("unequip") then
                pcall(function()
                    -- Tembak remote drop
                    remote:FireServer()
                end)
            end
        end
    end
    
    -- Cadangan: Hapus barang dari Backpack target secara visual di layar kita
    local backpack = selectedPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function() tool.Parent = workspace end)
            end
        end
    end
    
    status.Text = "Mencoba buang barang " .. selectedPlayer.Name
end)
