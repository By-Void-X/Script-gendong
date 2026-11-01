-- TP & Strong Fling (BodyVelocity)
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local selectedPlayer = nil

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
scroll.Size = UDim2.new(1,-20,0,150)
scroll.Position = UDim2.new(0,10,0,10)
scroll.BackgroundColor3 = Color3.fromRGB(35,35,35)
scroll.Parent = panel

local uiList = Instance.new("UIListLayout")
uiList.Parent = scroll

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,20)
status.Position = UDim2.new(0,10,0,165)
status.Text = "Pilih player di atas..."
status.TextColor3 = Color3.fromRGB(255, 255, 100)
status.BackgroundTransparency = 1
status.Parent = panel

local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(1,-20,0,30)
tpBtn.Position = UDim2.new(0,10,0,190)
tpBtn.Text = "TP ke Player"
tpBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
tpBtn.TextColor3 = Color3.fromRGB(255,255,255)
tpBtn.Parent = panel

local flingBtn = Instance.new("TextButton")
flingBtn.Size = UDim2.new(1,-20,0,30)
flingBtn.Position = UDim2.new(0,10,0,225)
flingBtn.Text = "Lempar (Strong Fling)"
flingBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
flingBtn.TextColor3 = Color3.fromRGB(255,255,255)
flingBtn.Parent = panel

toggle.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

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

tpBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character then
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and targetRoot then
            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
        end
    end
end)

flingBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character then
        local targetChar = selectedPlayer.Character
        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
        
        if targetRoot then
            pcall(function() targetRoot:SetNetworkOwner(lp) end)
            
            -- Hapus fling sebelumnya kalau ada
            for _, v in pairs(targetRoot:GetChildren()) do
                if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") then v:Destroy() end
            end
            
            -- 1. BodyVelocity (Lempar ke atas)
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(0, 500, 0)
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Parent = targetRoot
            
            -- 2. BodyAngularVelocity (Putar gila-gilaan)
            local bav = Instance.new("BodyAngularVelocity")
            bav.AngularVelocity = Vector3.new(9999, 9999, 9999)
            bav.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            bav.Parent = targetRoot
            
            status.Text = "Melempar " .. selectedPlayer.Name .. "!"
        end
    end
end)
