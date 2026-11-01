-- Universal_Carry_V4.lua
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local carriedPlayer = nil
local attachments = {}

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
panel.Size = UDim2.new(0, 220, 0, 140)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

local carryBtn = Instance.new("TextButton")
carryBtn.Size = UDim2.new(1,-20,0,40)
carryBtn.Position = UDim2.new(0,10,0,10)
carryBtn.Text = "Sedot Player (Paksa Tarik)"
carryBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
carryBtn.TextColor3 = Color3.fromRGB(255,255,255)
carryBtn.Parent = panel

local dropBtn = Instance.new("TextButton")
dropBtn.Size = UDim2.new(1,-20,0,40)
dropBtn.Position = UDim2.new(0,10,0,60)
dropBtn.Text = "Turunkan"
dropBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
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
    local nearest, shortestDist = nil, 25
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (myRoot.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                nearest = player
            end
        end
    end
    return nearest
end

local function clearAttachments()
    for _, a in ipairs(attachments) do
        if a then a:Destroy() end
    end
    table.clear(attachments)
end

carryBtn.MouseButton1Click:Connect(function()
    local target = getNearestPlayer()
    if target then
        carriedPlayer = target
        status.Text = "Menyedot: " .. target.Name
        
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local targetChar = target.Character
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        
        if myRoot and targetRoot then
            clearAttachments()
            
            -- 1. Set target jadi tanpa massa
            targetRoot.Massless = true
            
            -- 2. Buat baling-baling (Attachment) di dada kita
            local myAttach = Instance.new("Attachment", myRoot)
            table.insert(attachments, myAttach)
            
            -- 3. Buat baling-baling di badan target
            local targetAttach = Instance.new("Attachment", targetRoot)
            table.insert(attachments, targetAttach)
            
            -- 4. Pasang gaya tarik magnet (AlignPosition)
            local align = Instance.new("AlignPosition", myRoot)
            align.Attachment0 = targetAttach
            align.Attachment1 = myAttach
            align.MaxForce = 1000000
            align.Responsiveness = 200
            align.Position = myRoot.Position
            table.insert(attachments, align)
            
            -- 5. Paksa lepas kendali server (Spam Network Owner)
            pcall(function() targetRoot:SetNetworkOwner(lp) end)
        end
    else
        status.Text = "Tidak ada pemain di dekatmu!"
    end
end)

dropBtn.MouseButton1Click:Connect(function()
    if carriedPlayer and carriedPlayer.Character then
        local targetRoot = carriedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then targetRoot.Massless = false end
    end
    clearAttachments()
    carriedPlayer = nil
    status.Text = "Status: Idle"
end)

-- Loop penjaga
RunService.Heartbeat:Connect(function()
    if carriedPlayer and carriedPlayer.Character then
        local targetRoot = carriedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            pcall(function() targetRoot:SetNetworkOwner(lp) end)
        end
    end
end)
