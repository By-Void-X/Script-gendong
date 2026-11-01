-- Auto Remote Carry V5 (Brute Force)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer

local isCarrying = false
local grabRemotes = {}
local loopConnection = nil

local gui = Instance.new("ScreenGui")
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
carrySwitch.Text = "Brute Force Gendong: OFF"
carrySwitch.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
carrySwitch.TextColor3 = Color3.fromRGB(255,255,255)
carrySwitch.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,80)
status.Position = UDim2.new(0,10,0,60)
status.Text = "Status: Siap"
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(200,200,200)
status.BackgroundTransparency = 1
status.Parent = panel

toggleBtn.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

-- Scan semua Remote (Jangan cuma "grab", kadang namanya "Action", "Interact", dll)
local function scanRemotes()
    table.clear(grabRemotes)
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") or v:IsA("UnreliableRemoteEvent") then
            table.insert(grabRemotes, v)
        end
    end
    status.Text = "Ditemukan " .. tostring(#grabRemotes) .. " Remote Total. Siap ditembak."
end

scanRemotes()

local function getNearestPlayer()
    local nearest, dist = nil, 20
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
        carrySwitch.Text = "Brute Force Gendong: ON"
        carrySwitch.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        status.Text = "Mencoba brute-force semua Remote..."
        
        task.spawn(function()
            while isCarrying do
                task.wait(0.5) -- Jeda 0.5 detik per putaran agar server ga crash
                local target = getNearestPlayer()
                
                if target and target.Character then
                    status.Text = "Nembak target: " .. target.Name
                    
                    for _, remote in ipairs(grabRemotes) do
                        pcall(function()
                            if remote:IsA("RemoteEvent") or remote:IsA("UnreliableRemoteEvent") then
                                -- Tembak dengan berbagai variasi argumen yang mungkin diminta server
                                remote:FireServer(target.Name)
                                remote:FireServer(target)
                                remote:FireServer(target.Character)
                                remote:FireServer(target.UserId)
                                remote:FireServer(true)
                                remote:FireServer("Grab", target)
                                remote:FireServer("Carry", target)
                                remote:FireServer("Equip", target)
                            elseif remote:IsA("RemoteFunction") then
                                remote:InvokeServer(target)
                                remote:InvokeServer(target.Character)
                                remote:InvokeServer(target.Name)
                            end
                        end)
                    end
                else
                    status.Text = "Tidak ada player di dekatmu."
                end
            end
        end)
        
    else
        carrySwitch.Text = "Brute Force Gendong: OFF"
        carrySwitch.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        status.Text = "Status: Dimatikan"
    end
end)
