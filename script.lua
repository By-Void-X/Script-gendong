-- Auto Remote Carry (On/Off Toggle)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local isCarrying = false
local currentTarget = nil
local grabRemotes = {}
local loopConnection = nil

-- ================= GUI SETUP =================
local gui = Instance.new("ScreenGui")
gui.Name = "AutoRemoteCarry"
gui.ResetOnSpawn = false
gui.Parent = lp:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "MENU"
toggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
toggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
toggleBtn.Parent = gui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 250, 0, 150)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

local carrySwitch = Instance.new("TextButton")
carrySwitch.Size = UDim2.new(1,-20,0,40)
carrySwitch.Position = UDim2.new(0,10,0,10)
carrySwitch.Text = "Auto Gendong: OFF"
carrySwitch.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
carrySwitch.TextColor3 = Color3.fromRGB(255,255,255)
carrySwitch.Parent = panel

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(1,-20,0,30)
scanBtn.Position = UDim2.new(0,10,0,60)
scanBtn.Text = "Scan Ulang Remote"
scanBtn.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,40)
status.Position = UDim2.new(0,10,0,100)
status.Text = "Status: Siap"
status.TextColor3 = Color3.fromRGB(200,200,200)
status.BackgroundTransparency = 1
status.Parent = panel

toggleBtn.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

-- ================= SCAN REMOTES =================
local function scanRemotes()
    table.clear(grabRemotes)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = string.lower(v.Name)
            if n:find("grab") or n:find("pick") or n:find("carry") or n:find("hold") or n:find("interact") then
                table.insert(grabRemotes, v)
            end
        end
    end
    status.Text = "Ditemukan " .. tostring(#grabRemotes) .. " Remote."
end

scanBtn.MouseButton1Click:Connect(scanRemotes)
scanRemotes() -- Panggil pertama kali

-- ================= CARA KERJA =================
local function getNearestPlayer()
    local nearest, dist = nil, 15
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d; nearest = p end
        end
    end
    return nearest
end

carrySwitch.MouseButton1Click:Connect(function()
    isCarrying = not isCarrying
    
    if isCarrying then
        if #grabRemotes == 0 then
            status.Text = "Gagal: Game tidak punya Remote Grab!"
            isCarrying = false
            return
        end
        
        carrySwitch.Text = "Auto Gendong: ON"
        carrySwitch.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        
        -- Loop utama saat ON
        task.spawn(function()
            while isCarrying do
                task.wait(0.3) -- Jeda agar tidak kena rate-limit server
                local target = getNearestPlayer()
                
                if target and target.Character then
                    currentTarget = target
                    status.Text = "Mencoba gendong: " .. target.Name
                    
                    for _, remote in ipairs(grabRemotes) do
                        pcall(function()
                            if remote:IsA("RemoteEvent") then
                                -- Tembak dengan berbagai kemungkinan parameter
                                remote:FireServer(target)
                                remote:FireServer(target.Character)
                                remote:FireServer(target.Character.HumanoidRootPart)
                            elseif remote:IsA("RemoteFunction") then
                                remote:InvokeServer(target)
                                remote:InvokeServer(target.Character)
                            end
                        end)
                    end
                else
                    status.Text = "Tidak ada player di dekatmu."
                end
            end
        end)
        
    else
        carrySwitch.Text = "Auto Gendong: OFF"
        carrySwitch.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        status.Text = "Status: Dimatikan"
        currentTarget = nil
    end
end)
