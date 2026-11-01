-- Audio Tester (Attach to Head)
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- Kumpulan ID Vine Boom & Meme (Cadangan kalau satu mati)
local soundIDs = {
    "5153845327",  -- Vine Boom (Original)
    "6308606116",  -- Vine Boom (Alternatif)
    "6033123047",  -- Vine Boom (Versi lain)
    "13407555977"  -- Bass Boom
}

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

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,30)
status.Position = UDim2.new(0,10,0,10)
status.Text = "Pilih ID di bawah:"
status.TextColor3 = Color3.fromRGB(255,255,255)
status.BackgroundTransparency = 1
status.Parent = panel

-- Bikin tombol buat tiap ID
local yPos = 40
for i, id in ipairs(soundIDs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,30)
    btn.Position = UDim2.new(0,10,0,yPos)
    btn.Text = "Play ID: " .. id
    btn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = panel
    
    btn.MouseButton1Click:Connect(function()
        local char = lp.Character
        local head = char and char:FindFirstChild("Head")
        
        if head then
            -- Hapus suara lama
            for _, v in pairs(head:GetChildren()) do
                if v:IsA("Sound") then v:Destroy() end
            end
            
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://" .. id
            s.Volume = 10
            s.Parent = head -- Nempel di kepala (paling aman buat server)
            s:Play()
            
            status.Text = "Memutar ID: " .. id
        end
    end)
    yPos = yPos + 35
end

toggle.MouseButton1Click:Connect(function() panel.Visible = not panel.Visible end)
