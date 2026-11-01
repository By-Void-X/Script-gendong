-- Global Sound Player (Volume Konstan Tanpa Jarak)
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local lp = Players.LocalPlayer

local currentSound = nil

-- GUI SETUP (Sama kayak sebelumnya)
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
panel.Size = UDim2.new(0, 220, 0, 180)
panel.Position = UDim2.new(0, 10, 0, 50)
panel.BackgroundColor3 = Color3.fromRGB(20,20,20)
panel.Visible = false
panel.Parent = gui

local idBox = Instance.new("TextBox")
idBox.Size = UDim2.new(1,-20,0,35)
idBox.Position = UDim2.new(0,10,0,10)
idBox.Text = ""
idBox.PlaceholderText = "Masukkan Sound ID (Angka)"
idBox.TextColor3 = Color3.fromRGB(255,255,255)
idBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
idBox.Parent = panel

local playBtn = Instance.new("TextButton")
playBtn.Size = UDim2.new(1,-20,0,35)
playBtn.Position = UDim2.new(0,10,0,55)
playBtn.Text = "Putar Suara Global"
playBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
playBtn.TextColor3 = Color3.fromRGB(255,255,255)
playBtn.Parent = panel

local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(1,-20,0,35)
stopBtn.Position = UDim2.new(0,10,0,100)
stopBtn.Text = "Hentikan Suara"
stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
stopBtn.Parent = panel

toggle.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)

-- FUNGSI PLAY
playBtn.MouseButton1Click:Connect(function()
    local id = idBox.Text
    if id == "" or not tonumber(id) then return end

    if currentSound then currentSound:Destroy() end

    currentSound = Instance.new("Sound")
    currentSound.SoundId = "rbxassetid://" .. id
    currentSound.Volume = 10 -- Volume Maksimal
    currentSound.Looped = true
    currentSound.RollOffMode = Enum.RollOffMode.InverseTapered -- Biar gak mengecil jaraknya
    
    -- KUNCINYA DI SINI: Taruh di SoundService biar bunyi di mana-mana
    currentSound.Parent = SoundService 
    currentSound:Play()
end)

-- FUNGSI STOP
stopBtn.MouseButton1Click:Connect(function()
    if currentSound then
        currentSound:Stop()
        currentSound:Destroy()
        currentSound = nil
    end
end)
