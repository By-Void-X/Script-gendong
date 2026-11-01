-- Server-Sided Explosion Spammer (Visual Only)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local selectedPlayer = nil

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
panel.Size = UDim2.new(0, 240, 0, 300)
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
actionBtn.Text = "TP & Ledakkan (Server Visual)"
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

-- ================= CARI REMOTE EFEK LEDAKAN =================
local explodeRemotes = {}
for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        local n = string.lower(v.Name)
        if n:find("explode") or n:find("boom") or n:find("firework") or n:find("grenade") or n:find("particle") or n:find("effect") or n:find("spawn") then
            table.insert(explodeRemotes, v)
        end
    end
end

-- ================= AKSI LEDAKKAN =================
actionBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then
        status.Text = "Target tidak valid/mati!"
        return
    end
    
    if #explodeRemotes == 0 then
        status.Text = "Gagal: Tidak ada RemoteEvent efek ditemukan!"
        return
    end

    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if myRoot and targetRoot then
        -- 1. TP ke target
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
        status.Text = "Menembak Efek Ledakan ke " .. selectedPlayer.Name .. "..."
        
        -- 2. Spam Remote biar efek ledakannya besar & banyak
        for i = 1, 30 do
            task.spawn(function()
                for _, remote in ipairs(explodeRemotes) do
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            -- Berbagai macam argumen (Posisi, Target, String)
                            remote:FireServer(targetRoot.Position)
                            remote:FireServer(targetRoot)
                            remote:FireServer("Explode", targetRoot.Position)
                        else
                            remote:InvokeServer(targetRoot.Position)
                        end
                    end)
                end
            end)
            task.wait(0.05)
        end
    end
end)
