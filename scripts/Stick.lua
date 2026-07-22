-- Wiggly Stick Controller - Spacing Setting (10x scale)
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local PS = game:GetService("Players")
local LPlayer = PS.LocalPlayer
local char = LPlayer.Character or LPlayer.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local parts, active, conn, cf = {}, false, nil, CFrame.new()
local speed, rspeed = 30, math.rad(90)
local dirs = {Forward = 0, Backward = 0, Left = 0, Right = 0, Up = 0, Down = 0}
local rotL, rotR, cycle, moving = false, false, 0, false
local kbd, velConn = false, nil
local wobbliness = 5
local curliness = 0
local stickLength = 200
local spacing = 40
local targetPlayer = nil
local trackMode = false

local mo = {}
local function rebuildMo()
    mo = {}
    local actualSpacing = spacing / 10
    local pos = 0
    while pos < stickLength * actualSpacing do
        table.insert(mo, {pos = Vector3.new(0, 0, -pos), tag = "body"})
        pos = pos + actualSpacing
    end
end
rebuildMo()

local sg = Instance.new("ScreenGui", LPlayer:WaitForChild("PlayerGui"))
sg.Name = "StickController"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mf = Instance.new("Frame", sg)
mf.Size = UDim2.new(0, 280, 0, 470)
mf.Position = UDim2.new(0.5, -140, 0.5, -235)
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

local tb = btn("SUPER STICK (drag)", 0, 0, 280, 26, Color3.fromRGB(25, 25, 25))
tb.AutoButtonColor = false; tb.TextColor3 = Color3.fromRGB(255, 200, 100); tb.TextSize = 12

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

local stat = label("Off", 0, 440, 280, 18)
stat.TextColor3 = Color3.fromRGB(180, 180, 180); stat.TextSize = 11

btn("BUILD STICK", 10, 32, 125, 28, Color3.fromRGB(50, 200, 50)).MouseButton1Click:Connect(function()
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
    cf = root.CFrame * CFrame.new(0, 5, 20); cycle = 0; moving = false
    posStick(); active = true; stat.Text = "Stick: " .. #parts .. " parts"
    conn = RS.Heartbeat:Connect(function(dt)
        if not active then return end
        if kbd then root.CFrame = CFrame.new(cf.Position + cf:VectorToWorldSpace(Vector3.new(0, 10, 0))) end
        
        if trackMode and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = targetPlayer.Character.HumanoidRootPart.Position
            local direction = (targetPos - cf.Position).Unit
            local targetCF = CFrame.lookAt(cf.Position, cf.Position + direction)
            cf = cf:Lerp(targetCF, math.min(1, dt * speed / 16))
        end
        
        local mv = Vector3.new(dirs.Right - dirs.Left, dirs.Up - dirs.Down, dirs.Backward - dirs.Forward)
        moving = mv.Magnitude > 0
        if moving then cf += cf:VectorToWorldSpace(mv.Unit) * speed * dt; cycle += dt * 3
        else cycle += dt * 1 end
        if rotL then cf *= CFrame.Angles(0, rspeed * dt, 0) end
        if rotR then cf *= CFrame.Angles(0, -rspeed * dt, 0) end
        posStick()
    end)
end)

btn("DESTROY", 145, 32, 125, 28, Color3.fromRGB(255, 80, 80)).MouseButton1Click:Connect(function()
    active = false; if conn then conn:Disconnect() end
    for _, b in pairs(parts) do if b and b.Parent then b.Velocity = Vector3.zero; b.CanCollide = true; for _, v in pairs(b:GetChildren()) do if v:IsA("BodyMover") then v:Destroy() end end end end
    stat.Text = "Off"
end)

local kbdBtn = btn("KEYBOARD: OFF", 10, 66, 260, 26, Color3.fromRGB(100, 100, 100))
kbdBtn.MouseButton1Click:Connect(function()
    kbd = not kbd
    if kbd then kbdBtn.Text = "KEYBOARD: ON (WASD/QE/ZX)"; kbdBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else kbdBtn.Text = "KEYBOARD: OFF"; kbdBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        if velConn then velConn:Disconnect() end
        local et = tick() + 5
        velConn = RS.Heartbeat:Connect(function() if tick() >= et then velConn:Disconnect() return end; root.Velocity = Vector3.zero; root.RotVelocity = Vector3.zero end)
    end
end)

local function dirBtn(t, x, y, c, dir)
    local b = btn(t, x, y, 40, 28, c)
    b.TextSize = 12
    b.MouseButton1Down:Connect(function() dirs[dir] = 1 end)
    b.MouseButton1Up:Connect(function() dirs[dir] = 0 end)
    b.MouseLeave:Connect(function() dirs[dir] = 0 end)
end
dirBtn("W", 110, 100, Color3.fromRGB(255, 200, 50), "Backward")
dirBtn("S", 110, 132, Color3.fromRGB(255, 200, 50), "Forward")
dirBtn("A", 65, 116, Color3.fromRGB(255, 100, 100), "Left")
dirBtn("D", 155, 116, Color3.fromRGB(255, 100, 100), "Right")
dirBtn("E", 200, 100, Color3.fromRGB(100, 200, 255), "Up")
dirBtn("Q", 200, 132, Color3.fromRGB(100, 200, 255), "Down")

local zBtn = btn("Z", 15, 100, 40, 28, Color3.fromRGB(200, 150, 255))
zBtn.MouseButton1Down:Connect(function() rotL = true end)
zBtn.MouseButton1Up:Connect(function() rotL = false end)
zBtn.MouseLeave:Connect(function() rotL = false end)
local xBtn = btn("X", 15, 132, 40, 28, Color3.fromRGB(200, 150, 255))
xBtn.MouseButton1Down:Connect(function() rotR = true end)
xBtn.MouseButton1Up:Connect(function() rotR = false end)
xBtn.MouseLeave:Connect(function() rotR = false end)

label("Target Player:", 10, 170, 100, 18)
local targetLabel = label("None", 100, 170, 160, 18)
targetLabel.TextColor3 = Color3.fromRGB(255, 200, 50)

local playerList = Instance.new("ScrollingFrame", mf)
playerList.Size = UDim2.new(0, 260, 0, 60)
playerList.Position = UDim2.new(0, 10, 0, 190)
playerList.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
playerList.BorderSizePixel = 0; playerList.ScrollBarThickness = 4
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", playerList).CornerRadius = UDim.new(0, 5)

local function refreshPlayerList()
    for _, child in pairs(playerList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local y = 0
    for _, pl in pairs(PS:GetPlayers()) do
        if pl ~= LPlayer then
            local plBtn = Instance.new("TextButton", playerList)
            plBtn.Size = UDim2.new(1, -8, 0, 20); plBtn.Position = UDim2.new(0, 4, 0, y)
            plBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); plBtn.Text = pl.Name
            plBtn.Font = Enum.Font.Gotham; plBtn.TextSize = 9; plBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            plBtn.BorderSizePixel = 0; Instance.new("UICorner", plBtn).CornerRadius = UDim.new(0, 3)
            plBtn.MouseButton1Click:Connect(function()
                targetPlayer = pl; targetLabel.Text = pl.Name
                for _, c in pairs(playerList:GetChildren()) do if c:IsA("TextButton") then c.BackgroundColor3 = Color3.fromRGB(50, 50, 50) end end
                plBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end)
            y = y + 22
        end
    end
    playerList.CanvasSize = UDim2.new(0, 0, 0, y)
end

local refreshBtn = btn("↻", 220, 168, 50, 20, Color3.fromRGB(100, 100, 100))
refreshBtn.MouseButton1Click:Connect(refreshPlayerList)
refreshPlayerList()

local trackBtn = btn("TRACK: OFF", 10, 256, 260, 26, Color3.fromRGB(100, 100, 100))
trackBtn.MouseButton1Click:Connect(function()
    trackMode = not trackMode
    if trackMode then trackBtn.Text = "TRACK: ON"; trackBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    else trackBtn.Text = "TRACK: OFF"; trackBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100) end
end)

local sLabel = label("Speed: 30", 10, 292, 100, 18)
local sBox = Instance.new("TextBox", mf)
sBox.Size = UDim2.new(0, 50, 0, 20); sBox.Position = UDim2.new(0, 100, 0, 291)
sBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); sBox.TextColor3 = Color3.fromRGB(255, 255, 255)
sBox.Text = "30"; sBox.Font = Enum.Font.Gotham; sBox.TextSize = 10; sBox.BorderSizePixel = 0
Instance.new("UICorner", sBox).CornerRadius = UDim.new(0, 4)
btn("SET", 155, 290, 50, 22, Color3.fromRGB(100, 200, 100)).MouseButton1Click:Connect(function()
    local n = tonumber(sBox.Text); if n and n > 0 then speed = n; sLabel.Text = "Speed: " .. n end
end)

local wLabel = label("Wobbliness: 5", 10, 320, 140, 18)
local wBox = Instance.new("TextBox", mf)
wBox.Size = UDim2.new(0, 50, 0, 20); wBox.Position = UDim2.new(0, 100, 0, 319)
wBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); wBox.TextColor3 = Color3.fromRGB(255, 255, 255)
wBox.Text = "5"; wBox.Font = Enum.Font.Gotham; wBox.TextSize = 10; wBox.BorderSizePixel = 0
Instance.new("UICorner", wBox).CornerRadius = UDim.new(0, 4)
btn("SET W", 155, 318, 50, 22, Color3.fromRGB(150, 100, 255)).MouseButton1Click:Connect(function()
    local n = tonumber(wBox.Text); if n then wobbliness = n; wLabel.Text = "Wobbliness: " .. n end
end)

local curlLabel = label("Curliness: 0", 10, 348, 140, 18)
local curlBox = Instance.new("TextBox", mf)
curlBox.Size = UDim2.new(0, 50, 0, 20); curlBox.Position = UDim2.new(0, 100, 0, 347)
curlBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); curlBox.TextColor3 = Color3.fromRGB(255, 255, 255)
curlBox.Text = "0"; curlBox.Font = Enum.Font.Gotham; curlBox.TextSize = 10; curlBox.BorderSizePixel = 0
Instance.new("UICorner", curlBox).CornerRadius = UDim.new(0, 4)
btn("SET C", 155, 346, 50, 22, Color3.fromRGB(255, 100, 200)).MouseButton1Click:Connect(function()
    local n = tonumber(curlBox.Text); if n then curliness = n; curlLabel.Text = "Curliness: " .. n end
end)

local dLabel = label("Spacing: 40", 10, 376, 140, 18)
local dBox = Instance.new("TextBox", mf)
dBox.Size = UDim2.new(0, 50, 0, 20); dBox.Position = UDim2.new(0, 100, 0, 375)
dBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); dBox.TextColor3 = Color3.fromRGB(255, 255, 255)
dBox.Text = "40"; dBox.Font = Enum.Font.Gotham; dBox.TextSize = 10; dBox.BorderSizePixel = 0
Instance.new("UICorner", dBox).CornerRadius = UDim.new(0, 4)
btn("SET S", 155, 374, 50, 22, Color3.fromRGB(255, 150, 50)).MouseButton1Click:Connect(function()
    local n = tonumber(dBox.Text); if n and n > 0 then spacing = n; dLabel.Text = "Spacing: " .. n end
end)

local lLabel = label("Length: 200", 10, 404, 140, 18)
local lBox = Instance.new("TextBox", mf)
lBox.Size = UDim2.new(0, 50, 0, 20); lBox.Position = UDim2.new(0, 100, 0, 403)
lBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40); lBox.TextColor3 = Color3.fromRGB(255, 255, 255)
lBox.Text = "200"; lBox.Font = Enum.Font.Gotham; lBox.TextSize = 10; lBox.BorderSizePixel = 0
Instance.new("UICorner", lBox).CornerRadius = UDim.new(0, 4)
btn("SET L", 155, 402, 50, 22, Color3.fromRGB(255, 200, 50)).MouseButton1Click:Connect(function()
    local n = tonumber(lBox.Text); if n and n > 0 then stickLength = n; lLabel.Text = "Length: " .. n end
end)

UIS.InputBegan:Connect(function(i, p)
    if p or not kbd then return end
    if i.KeyCode == Enum.KeyCode.W then dirs.Backward = 1 elseif i.KeyCode == Enum.KeyCode.S then dirs.Forward = 1
    elseif i.KeyCode == Enum.KeyCode.A then dirs.Left = 1 elseif i.KeyCode == Enum.KeyCode.D then dirs.Right = 1
    elseif i.KeyCode == Enum.KeyCode.E then dirs.Up = 1 elseif i.KeyCode == Enum.KeyCode.Q then dirs.Down = 1
    elseif i.KeyCode == Enum.KeyCode.Z then rotL = true elseif i.KeyCode == Enum.KeyCode.X then rotR = true end
end)
UIS.InputEnded:Connect(function(i, p)
    if p or not kbd then return end
    if i.KeyCode == Enum.KeyCode.W then dirs.Backward = 0 elseif i.KeyCode == Enum.KeyCode.S then dirs.Forward = 0
    elseif i.KeyCode == Enum.KeyCode.A then dirs.Left = 0 elseif i.KeyCode == Enum.KeyCode.D then dirs.Right = 0
    elseif i.KeyCode == Enum.KeyCode.E then dirs.Up = 0 elseif i.KeyCode == Enum.KeyCode.Q then dirs.Down = 0
    elseif i.KeyCode == Enum.KeyCode.Z then rotL = false elseif i.KeyCode == Enum.KeyCode.X then rotR = false end
end)

function posStick()
    if not active then return end
    local bi = 1
    for _, d in pairs(mo) do
        if bi > #parts then break end
        local b = parts[bi]
        if b and b.Parent then
            for _, v in pairs(b:GetChildren()) do if v:IsA("BodyMover") then v:Destroy() end end
            b.RotVelocity = Vector3.zero; b.CanCollide = false; b.Anchored = false
            local o = d.pos
            local waveX = math.sin(cycle * 2 + o.Z * 0.03) * (moving and wobbliness * 1.6 or wobbliness * 0.6)
            local waveY = math.sin(cycle * 1.5 + o.Z * 0.02) * (wobbliness * 0.4)
            local curlX = math.cos(cycle * 2 + o.Z * 0.02 * curliness) * (wobbliness * 0.8)
            local curlY = math.sin(cycle * 2 + o.Z * 0.02 * curliness) * (wobbliness * 0.8)
            b.CFrame = cf * CFrame.new(o + Vector3.new(waveX + curlX, waveY + curlY, 0))
        end
        bi = bi + 1
    end
end

LPlayer.CharacterAdded:Connect(function(c)
    char = c; hum = char:WaitForChild("Humanoid"); root = char:WaitForChild("HumanoidRootPart")
    sg.Parent = LPlayer:WaitForChild("PlayerGui"); active = false; if conn then conn:Disconnect() end; table.clear(parts)
end)
