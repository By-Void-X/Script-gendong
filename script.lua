-- Universal_CarryScript_V2.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local carriedPlayer = nil
local isCarrying = false

local gui = Instance.new("ScreenGui")
gui.Name = "CarryMenu"
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
panel.Size = UDim2.new(0, 220, 0, 140)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

local carryBtn = Instance.new("TextButton")
carryBtn.Size = UDim2.new(1,-20,0,40)
carryBtn.Position = UDim2.new(0,10,0,10)
carryBtn.Text = "Paksa Gendong Terdekat"
carryBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
carryBtn.TextColor3 = Color3.fromRGB(255,255,255)
carryBtn.Parent = panel

local dropBtn = Instance.new("TextButton")
dropBtn.Size = UDim2.new(1,-20,0,40)
dropBtn.Position = UDim2.new(0,10,0,60)
dropBtn.Text = "Turunkan"
dropBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
dropBtn.TextColor3 = Color3.fromRGB(255,255,255)
dropBtn.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,105)
status.Text = "Status: Idle"
status.TextColor3 = Color3.fromRGB(200,200,200)
status.BackgroundTransparency = 1
status.Parent = panel

toggle.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

local function getNearestPlayer()
    local nearest = nil
    local shortestDist = 15 
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetRoot = player.Character.HumanoidRootPart
            local dist = (myRoot.Position - targetRoot.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                nearest = player
            end
        end
    end
    return nearest
end

carryBtn.MouseButton1Click:Connect(function()
    local target = getNearestPlayer()
    if target then
        carriedPlayer = target
        isCarrying = true
        status.Text = "Nyangkut: " .. target.Name
        
        -- Coba paksa lepas kendali target (Kalau bisa)
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            target.Character.HumanoidRootPart.Anchored = true
        end
    else
        status.Text = "Status: Tidak ada pemain!"
    end
end)

dropBtn.MouseButton1Click:Connect(function()
    isCarrying = false
    if carriedPlayer and carriedPlayer.Character and carriedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        carriedPlayer.Character.HumanoidRootPart.Anchored = false
    end
    carriedPlayer = nil
    status.Text = "Status: Idle"
end)

-- Loop paksa
RunService.Heartbeat:Connect(function()
    if isCarrying and carriedPlayer and carriedPlayer.Character then
        local myChar = lp.Character
        local targetChar = carriedPlayer.Character
        
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        
        if myRoot and targetRoot then
            -- Teleport paksa ke posisi kita
            targetRoot.CFrame = myRoot.CFrame * CFrame.new(0, 2, 1) 
            targetRoot.Velocity = Vector3.new(0,0,0)
            targetRoot.Anchored = true -- Bekukan biar gak bisa ngelawan
        else
            isCarrying = false
            carriedPlayer = nil
            status.Text = "Status: Target hilang/mati"
        end
    end
end)
