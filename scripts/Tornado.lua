-- Tornado Builder - Flipped Shape + All Controls
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local PS = game:GetService("Players")
local LPlayer = PS.LocalPlayer
local char = LPlayer.Character or LPlayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local parts, active, conn, cf = {}, false, nil, CFrame.new()
local speed = 30
local rspeed = math.rad(90)
local dirs = {Forward = 0, Backward = 0, Left = 0, Right = 0, Up = 0, Down = 0}
local rotL, rotR = false, false
local kbd, velConn = false, nil
local tornadoHeight = 30
local tornadoRadius = 20
local tornadoSpinSpeed = 3
local tornadoParts = 300
local cycle = 0

local mo = {}
local function rebuildMo()
    mo = {}
    for i = 0, tornadoParts - 1 do
        local progress = i / tornadoParts
        local y = progress * tornadoHeight * 4
        local radius = tornadoRadius * 4 * (0.3 + progress * 0.7)
        local angle = progress * math.pi * 8
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        table.insert(mo, {pos = Vector3.new(x, y, z), baseAngle = angle, baseRadius = radius, progress = progress})
    end
end
rebuildMo()

local sg = Instance.new("ScreenGui", LPlayer:WaitForChild("PlayerGui"))
sg.Name = "TornadoBuilder"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mf = Instance.new("Frame", sg)
mf.Size = UDim2.new(0, 280, 0, 430)
mf.Position = UDim2.new(0.5, -140, 0.5, -215)
mf.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mf.BorderSizePixel = 0
Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 10)

local function btn(t, x, y, w, h, c)
    local b = Instance.new("TextButton", mf)
    b.Size = UDim2.new(0, w, 0, h); b.Position = UDim2.new(0, x, 0, y); b.BackgroundColor3 = c
    b.Text = t; b.Font = Enum.Font.GothamBold; b.TextSize = 10; b.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5); return b
end

local function label(t, x, y, w, h)
    local l = Instance.new("TextLabel", mf)
    l.Size = UDim2.new(0, w, 0, h); l.Position = UDim2.new(0, x, 0, y)
    l.BackgroundTransparency = 1; l.Text = t; l.TextColor3 = Color3.fromRGB(255, 255, 255); l.TextSize = 10; l.Font = Enum.Font.Gotham; return l
end

local tb = btn("TORNADO (drag)", 0, 0, 280, 26, Color3.fromRGB(25, 25, 25))
tb.AutoButtonColor = false; tb.TextColor3 = Color3.fromRGB(150, 150, 255); tb.TextSize = 12

local drag, dStart, sPos = false, nil, nil
tb.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; dStart = i.Position; sPos = mf.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if not drag then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - dStart
        mf.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
end)

local stat = label("Off", 0, 400, 280, 18)
stat.TextColor3 = Color3.fromRGB(180, 180, 180); stat.TextSize = 11

btn("BUILD TORNADO", 10, 32, 125, 28, Color3.fromRGB(50, 150, 255)).MouseButton1Click:Connect(function()
    for _, b in pairs(parts) do if b and b.Parent then b.Velocity = Vector3.zero; b.CanCollide = true end end
    table.clear(parts); if conn then conn:Disconnect() end; active = false
    rebuildMo()
    local fp = {}
    for _, p in pairs(WS:GetDescendants()) do
        if p:IsA("BasePart") and not p.Anchored and not p:IsDescendantOf(char) and p.Transparency < 0.5 then
            local free = true
            if next(p:GetJoints()) ~= nil then free = false end
            for _, c in pairs(p:GetChildren()) do if c:IsA("JointInstance") or c:IsA("Constraint") then free = false end end
            if free then table.insert(fp, {part = p, dist = (p.Position - root.Position).Magnitude}) end
        end
    end
    if #fp == 0 then stat.Text = "No parts found" return end
    table.sort(fp, function(a, b) return a.dist < b.dist end)
    for i = 1, math.min(#mo, #fp) do table.insert(parts, fp[i].part) end
    cf = root.CFrame * CFrame.new(0, 0, -40)
    cycle = 0; posTornado(); active = true
    stat.Text = "Tornado: " .. #parts .. " parts"
    conn = RS.Heartbeat:Connect(function(dt)
        if not active then return end
        if kbd then root.CFrame = CFrame.new(cf.Position) end
        local mv = Vector3.new(dirs.Right - dirs.Left, dirs.Up - dirs.Down, dirs.Backward - dirs.Forward)
        if mv.Magnitude > 0 then cf += cf:VectorToWorldSpace(mv.Unit) * speed * dt end
        if rotL then cf *= CFrame.Angles(0, rspeed * dt, 0) end
        if rotR then cf *= CFrame.Angles(0, -rspeed * dt, 0) end
        cycle = cycle + dt * tornadoSpinSpeed
        posTornado()
    end)
end)

btn("DESTROY", 145, 32, 125, 28, Color3.fromRGB(255, 80, 80)).MouseButton1Click:Connect(function()
    active = false; if conn then conn:Disconnect() end
    for _, b in pairs(parts) do if b and b.Parent then b.Velocity = Vector3.zero; b.CanCollide = true; for _, v in pairs(b:GetChildren()) do if v:IsA("BodyMover") then v:Destroy() end end end end
    stat.Text = "Off"
end)

local kbdBtn = btn("KBD: OFF", 10, 66, 260, 26, Color3.fromRGB(100, 100, 100))
kbdBtn.MouseButton1Click:Connect(function()
    kbd = not kbd
    if kbd then kbdBtn.Text = "KBD: ON (WASD/QE/ZX)"; kbdBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else kbdBtn.Text = "KBD: OFF"; kbdBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        if velConn then velConn:Disconnect() end
        local et = tick() + 5
        velConn = RS.Heartbeat:Connect(function() if tick() >= et then velConn:Disconnect() return end; root.Velocity = Vector3.zero; root.RotVelocity = Vector3.zero end)
    end
end)

-- Direction buttons (WASD + QE up/down)
local function dirBtn(t, x, y, c, dir)
    local b = btn(t, x, y, 40, 28, c)
    b.TextSize = 12
    b.MouseButton1Down:Connect(function() dirs[dir] = 1 end)
    b.MouseButton1Up:Connect(function() dirs[dir] = 0 end)
    b.MouseLeave:Connect(function() dirs[dir] = 0 end)
end
dirBtn("W", 110, 100, Color3.fromRGB(255, 200, 50), "Forward")
dirBtn("S", 110, 132, Color3.fromRGB(255, 200, 50), "Backward")
dirBtn("A", 65, 116, Color3.fromRGB(255, 100, 100), "Left")
dirBtn("D", 155, 116, Color3.fromRGB(255, 100, 100), "Right")
dirBtn("E", 200, 100, Color3.fromRGB(100, 200, 255), "Up")
dirBtn("Q", 200, 132, Color3.fromRGB(100, 200, 255), "Down")

-- Rotation buttons
local zBtn = btn("Z", 15, 100, 40, 28, Color3.fromRGB(200, 150, 255))
zBtn.MouseButton1Down:Connect(function() rotL = true end)
zBtn.MouseButton1Up:Connect(function() rotL = false end)
zBtn.MouseLeave:Connect(function() rotL = false end)
local xBtn = btn("X", 15, 132, 40, 28, Color3.fromRGB(200, 150, 255))
xBtn.MouseButton1Down:Connect(function() rotR = true end)
xBtn.MouseButton1Up:Connect(function() rotR = false end)
xBtn.MouseLeave:Connect(function() rotR = false end)

-- Settings
local hLabel = label("Height: 30", 10, 170, 140, 18)
local hBox = Instance.new("TextBox", mf)
hBox.Size = UDim2.new(0, 50, 0, 20); hBox.Position = UDim2.new(0, 100, 0, 169)
hBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); hBox.TextColor3 = Color3.fromRGB(255, 255, 255)
hBox.Text = "30"; hBox.Font = Enum.Font.Gotham; hBox.TextSize = 10; hBox.BorderSizePixel = 0
Instance.new("UICorner", hBox).CornerRadius = UDim.new(0, 4)
btn("SET H", 155, 168, 50, 22, Color3.fromRGB(100, 150, 255)).MouseButton1Click:Connect(function()
    local n = tonumber(hBox.Text); if n and n > 0 then tornadoHeight = n; hLabel.Text = "Height: " .. n end
end)

local rLabel = label("Radius: 20", 10, 198, 140, 18)
local rBox = Instance.new("TextBox", mf)
rBox.Size = UDim2.new(0, 50, 0, 20); rBox.Position = UDim2.new(0, 100, 0, 197)
rBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); rBox.TextColor3 = Color3.fromRGB(255, 255, 255)
rBox.Text = "20"; rBox.Font = Enum.Font.Gotham; rBox.TextSize = 10; rBox.BorderSizePixel = 0
Instance.new("UICorner", rBox).CornerRadius = UDim.new(0, 4)
btn("SET R", 155, 196, 50, 22, Color3.fromRGB(100, 150, 255)).MouseButton1Click:Connect(function()
    local n = tonumber(rBox.Text); if n and n > 0 then tornadoRadius = n; rLabel.Text = "Radius: " .. n end
end)

local sLabel2 = label("Spin: 3", 10, 226, 140, 18)
local sBox2 = Instance.new("TextBox", mf)
sBox2.Size = UDim2.new(0, 50, 0, 20); sBox2.Position = UDim2.new(0, 100, 0, 225)
sBox2.BackgroundColor3 = Color3.fromRGB(40, 40, 40); sBox2.TextColor3 = Color3.fromRGB(255, 255, 255)
sBox2.Text = "3"; sBox2.Font = Enum.Font.Gotham; sBox2.TextSize = 10; sBox2.BorderSizePixel = 0
Instance.new("UICorner", sBox2).CornerRadius = UDim.new(0, 4)
btn("SET S", 155, 224, 50, 22, Color3.fromRGB(100, 150, 255)).MouseButton1Click:Connect(function()
    local n = tonumber(sBox2.Text); if n and n > 0 then tornadoSpinSpeed = n; sLabel2.Text = "Spin: " .. n end
end)

local pLabel = label("Parts: 300", 10, 254, 140, 18)
local pBox = Instance.new("TextBox", mf)
pBox.Size = UDim2.new(0, 50, 0, 20); pBox.Position = UDim2.new(0, 100, 0, 253)
pBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); pBox.TextColor3 = Color3.fromRGB(255, 255, 255)
pBox.Text = "300"; pBox.Font = Enum.Font.Gotham; pBox.TextSize = 10; pBox.BorderSizePixel = 0
Instance.new("UICorner", pBox).CornerRadius = UDim.new(0, 4)
btn("SET P", 155, 252, 50, 22, Color3.fromRGB(100, 150, 255)).MouseButton1Click:Connect(function()
    local n = tonumber(pBox.Text); if n and n > 0 then tornadoParts = n; pLabel.Text = "Parts: " .. n end
end)

UIS.InputBegan:Connect(function(i, p)
    if p or not kbd then return end
    if i.KeyCode == Enum.KeyCode.W then dirs.Forward = 1 elseif i.KeyCode == Enum.KeyCode.S then dirs.Backward = 1
    elseif i.KeyCode == Enum.KeyCode.A then dirs.Left = 1 elseif i.KeyCode == Enum.KeyCode.D then dirs.Right = 1
    elseif i.KeyCode == Enum.KeyCode.E then dirs.Up = 1 elseif i.KeyCode == Enum.KeyCode.Q then dirs.Down = 1
    elseif i.KeyCode == Enum.KeyCode.Z then rotL = true elseif i.KeyCode == Enum.KeyCode.X then rotR = true end
end)
UIS.InputEnded:Connect(function(i, p)
    if p or not kbd then return end
    if i.KeyCode == Enum.KeyCode.W then dirs.Forward = 0 elseif i.KeyCode == Enum.KeyCode.S then dirs.Backward = 0
    elseif i.KeyCode == Enum.KeyCode.A then dirs.Left = 0 elseif i.KeyCode == Enum.KeyCode.D then dirs.Right = 0
    elseif i.KeyCode == Enum.KeyCode.E then dirs.Up = 0 elseif i.KeyCode == Enum.KeyCode.Q then dirs.Down = 0
    elseif i.KeyCode == Enum.KeyCode.Z then rotL = false elseif i.KeyCode == Enum.KeyCode.X then rotR = false end
end)

function posTornado()
    if not active then return end
    local bi = 1
    for _, d in pairs(mo) do
        if bi > #parts then break end
        local b = parts[bi]
        if b and b.Parent then
            for _, v in pairs(b:GetChildren()) do if v:IsA("BodyMover") then v:Destroy() end end
            b.RotVelocity = Vector3.zero; b.CanCollide = false; b.Anchored = false
            local angle = d.baseAngle + cycle * (1 + d.progress)
            local radius = d.baseRadius
            local x = math.cos(angle) * radius
            local z = math.sin(angle) * radius
            b.CFrame = cf * CFrame.new(Vector3.new(x, d.pos.Y, z))
        end
        bi = bi + 1
    end
end

LPlayer.CharacterAdded:Connect(function(c)
    char = c; root = char:WaitForChild("HumanoidRootPart")
    sg.Parent = LPlayer:WaitForChild("PlayerGui")
    active = false; if conn then conn:Disconnect() end; table.clear(parts)
end)