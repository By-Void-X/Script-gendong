-- Bring Player & Teleport Script
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local selectedPlayer = nil
local isBringing = false
local bringConnection = nil

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
panel.Size = UDim2.new(0, 220, 0, 200)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1,-20,0,80)
playerList.Position = UDim2.new(0,10,0,10)
playerList.BackgroundColor3 = Color3.fromRGB(35,35,35)
playerList.Parent = panel

local uiList = Instance.new("UIListLayout")
uiList.Parent = playerList

local bringBtn = Instance.new("TextButton")
bringBtn.Size = UDim2.new(1,-20,0,30)
bringBtn.Position = UDim2.new(0,10,0,100)
bringBtn.Text = "Bring (Tarik ke Sini)"
bringBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
bringBtn.TextColor3 = Color3.fromRGB(255,255,255)
bringBtn.Parent = panel

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(1,-20,0,30)
tpBtn.Position = UDim2.new(0,10,0,135)
tpBtn.Text = "Teleport ke Dia"
tpBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
tpBtn.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,20)
status.Position = UDim2.new(0,10,0,170)
status.Text = "Pilih player di atas..."
status.TextColor3 = Color3.fromRGB(200,200,200)
status.BackgroundTransparency = 1
status.Parent = panel

toggle.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

-- Update List Player
local function updateList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 25)
            btn.Text = p.Name
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Parent = playerList
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = p
                status.Text = "Target: " .. p.Name
            end)
        end
    end
    playerList.CanvasSize = UDim2.new(0, 0, 0, #Players:GetPlayers() * 30)
end

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- Fungsi Bring (Spam CFrame)
bringBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then
        status.Text = "Target tidak valid/mati!"
        return
    end
    
    isBringing = not isBringing
    
    if isBringing then
        bringBtn.Text = "Bring: ON (Stop)"
        status.Text = "Menarik " .. selectedPlayer.Name .. "..."
        
        task.spawn(function()
            while isBringing do
                task.wait()
                local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                local targetRoot = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if myRoot and targetRoot then
                    pcall(function()
                        -- Rampas Network Ownership
                        targetRoot:SetNetworkOwner(lp)
                        -- Tarik paksa ke posisi kita
                        targetRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3) -- Taruh di depan kita
                        targetRoot.Velocity = Vector3.new(0,0,0) -- Matikan kecepatan aslinya
                    end)
                end
            end
        end)
    else
        bringBtn.Text = "Bring (Tarik ke Sini)"
        status.Text = "Berhenti menarik."
    end
end)

-- Fungsi Teleport Diri Sendiri ke Target (100% Berhasil)
tpBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then
        status.Text = "Target tidak valid/mati!"
        return
    end
    
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if myRoot and targetRoot then
        -- Teleport diri kita sendiri (Server tidak akan menolak)
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
        status.Text = "Teleport ke " .. selectedPlayer.Name
    end
end)
