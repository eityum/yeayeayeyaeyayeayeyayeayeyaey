local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local PS = game:GetService("Players")

local LPlayer = PS.LocalPlayer
local char = LPlayer.Character or LPlayer.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- Ball data
local parts = {}
local ballParts = {}
local active = false
local conn = nil
local ballPos = Vector3.zero
local ballVelocity = Vector3.zero
local visualRot = CFrame.identity
local lastBallPos = Vector3.zero

-- Movement
local speed = 8
local dirs = {Forward = 0, Backward = 0, Left = 0, Right = 0}
local rotL, rotR = false, false

-- Squish
local squishAmount = 0
local squishTarget = 0
local squishIntensity = 1
local squishAxis = Vector3.new(0, 1, 0)

-- Physics
local gravity = Vector3.new(0, -196.2, 0)
local terminalVelocity = 150
local physicsDrag = 2

local plateBounds = nil

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.FilterDescendantsInstances = {}

local function rebuildBall()
    ballParts = {}
    local radius = 10
    local resolution = 10
    for lat = 0, resolution do
        local theta = (math.pi * lat) / resolution
        local sinTheta = math.sin(theta)
        local cosTheta = math.cos(theta)
        local actualPoints = math.max(3, math.floor(resolution * 2 * sinTheta))
        for lon = 0, actualPoints do
            local phi = (2 * math.pi * lon) / actualPoints
            table.insert(ballParts, Vector3.new(
                radius * sinTheta * math.cos(phi),
                radius * cosTheta,
                radius * sinTheta * math.sin(phi)
            ))
        end
    end
end
rebuildBall()

local function isPartSafe(p)
    if p.Anchored then return false end
    for _, plr in pairs(PS:GetPlayers()) do
        if plr.Character and p:IsDescendantOf(plr.Character) then return false end
    end
    if next(p:GetJoints()) ~= nil then return false end
    for _, c in pairs(p:GetChildren()) do
        if c:IsA("JointInstance") or c:IsA("Constraint") then return false end
    end
    return true
end

local function getMyPlate()
    local Plates = WS:FindFirstChild("Plates")
    if not Plates then return nil end
    for _, plate in pairs(Plates:GetChildren()) do
        local owner = plate:FindFirstChild("Owner")
        if owner and owner.Value == LPlayer then return plate end
    end
    return nil
end

local function findMyPlateBounds(plate)
    local platePart = plate and plate:FindFirstChild("Plate")
    if not (platePart and platePart:IsA("BasePart")) then return nil end
    local size = platePart.Size
    local pos = platePart.Position
    return {
        minX = pos.X - size.X / 2,
        maxX = pos.X + size.X / 2,
        minZ = pos.Z - size.Z / 2,
        maxZ = pos.Z + size.Z / 2,
        center = pos
    }
end

local function clampToPlate(pos)
    if not plateBounds then return pos end
    local radius = 12
    return Vector3.new(
        math.clamp(pos.X, plateBounds.minX + radius, plateBounds.maxX - radius),
        pos.Y,
        math.clamp(pos.Z, plateBounds.minZ + radius, plateBounds.maxZ - radius)
    )
end

local function getGroundHeight(pos)
    local hit = WS:Raycast(pos + Vector3.new(0, 50, 0), Vector3.new(0, -300, 0), rayParams)
    if hit then return hit.Position.Y end
    return pos.Y - 50
end

-- GUI setup
local sg = Instance.new("ScreenGui", LPlayer:WaitForChild("PlayerGui"))
sg.Name = "NeedohBall"
sg.ResetOnSpawn = false

local mf = Instance.new("Frame", sg)
mf.Size = UDim2.new(0, 280, 0, 440)
mf.Position = UDim2.new(0.5, -140, 0.5, -220)
mf.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mf.BorderSizePixel = 0
Instance.new("UICorner", mf).CornerRadius = UDim.new(0, 10)

local function btn(t, x, y, w, h, c)
    local b = Instance.new("TextButton", mf)
    b.Size = UDim2.new(0, w, 0, h)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = c
    b.Text = t
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

local function label(t, x, y, w, h)
    local l = Instance.new("TextLabel", mf)
    l.Size = UDim2.new(0, w, 0, h)
    l.Position = UDim2.new(0, x, 0, y)
    l.BackgroundTransparency = 1
    l.Text = t
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.TextSize = 10
    l.Font = Enum.Font.Gotham
    return l
end

local tb = btn("NEEDOH BALL (drag)", 0, 0, 280, 26, Color3.fromRGB(25, 25, 25))
tb.AutoButtonColor = false
tb.TextColor3 = Color3.fromRGB(255, 100, 100)
tb.TextSize = 12

local guiDrag, guiStart, guiPos = false, nil, nil
tb.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        guiDrag = true
        guiStart = i.Position
        guiPos = mf.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if not guiDrag then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - guiStart
        mf.Position = UDim2.new(guiPos.X.Scale, guiPos.X.Offset + d.X, guiPos.Y.Scale, guiPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        guiDrag = false
    end
end)

local stat = label("Off", 0, 410, 280, 18)
stat.TextColor3 = Color3.fromRGB(180, 180, 180)

label("Squish Intensity:", 10, 290, 100, 18).TextSize = 9
local squishBox = Instance.new("TextBox", mf)
squishBox.Size = UDim2.new(0, 50, 0, 20)
squishBox.Position = UDim2.new(0, 110, 0, 289)
squishBox.Text = "1"
squishBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
squishBox.TextColor3 = Color3.fromRGB(255, 255, 255)
squishBox.Font = Enum.Font.Gotham
squishBox.TextSize = 10
squishBox.BorderSizePixel = 0

btn("SET", 170, 288, 50, 22, Color3.fromRGB(150, 100, 255)).MouseButton1Click:Connect(function()
    local n = tonumber(squishBox.Text)
    if n then
        squishIntensity = math.clamp(n, 0, 3)
    end
end)

label("Velocity Power:", 10, 320, 100, 18).TextSize = 9
local velBox = Instance.new("TextBox", mf)
velBox.Size = UDim2.new(0, 50, 0, 20)
velBox.Position = UDim2.new(0, 110, 0, 319)
velBox.Text = "50"
velBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
velBox.TextColor3 = Color3.fromRGB(255, 255, 255)
velBox.Font = Enum.Font.Gotham
velBox.TextSize = 10
velBox.BorderSizePixel = 0

btn("SET", 170, 318, 50, 22, Color3.fromRGB(150, 100, 255)).MouseButton1Click:Connect(function()
    local n = tonumber(velBox.Text)
    if n then
        velocityPower = n
    end
end)

label("Gravity:", 10, 350, 100, 18).TextSize = 9
local gravBox = Instance.new("TextBox", mf)
gravBox.Size = UDim2.new(0, 50, 0, 20)
gravBox.Position = UDim2.new(0, 110, 0, 349)
gravBox.Text = "196.2"
gravBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
gravBox.TextColor3 = Color3.fromRGB(255, 255, 255)
gravBox.Font = Enum.Font.Gotham
gravBox.TextSize = 10
gravBox.BorderSizePixel = 0

btn("SET", 170, 348, 50, 22, Color3.fromRGB(150, 100, 255)).MouseButton1Click:Connect(function()
    local n = tonumber(gravBox.Text)
    if n then
        gravity = Vector3.new(0, -math.abs(n), 0)
    end
end)

-- ONLY manual squish buttons
btn("SQUISH LEFT", 10, 380, 125, 28, Color3.fromRGB(255, 150, 50)).MouseButton1Click:Connect(function()
    if not active then return end
    squishAxis = Vector3.new(-1, 0, 0)
    squishTarget = math.min(10, 8 * squishIntensity)
end)

btn("SQUISH RIGHT", 145, 380, 125, 28, Color3.fromRGB(255, 200, 50)).MouseButton1Click:Connect(function()
    if not active then return end
    squishAxis = Vector3.new(1, 0, 0)
    squishTarget = math.min(10, 8 * squishIntensity)
end)

local buildDebounce = false

local function teardownBall()
    active = false
    if conn then
        conn:Disconnect()
        conn = nil
    end
    for _, b in pairs(parts) do
        if b and b.Parent then
            b.Velocity = Vector3.zero
            b.CanCollide = true
            for _, v in pairs(b:GetChildren()) do
                if v:IsA("BodyMover") then
                    v:Destroy()
                end
            end
        end
    end
    table.clear(parts)
    rayParams.FilterDescendantsInstances = {}
end

local posBall

btn("BUILD BALL", 10, 32, 260, 28, Color3.fromRGB(50, 200, 50)).MouseButton1Click:Connect(function()
    if buildDebounce then return end
    buildDebounce = true
    teardownBall()

    local myPlate = getMyPlate()
    if not myPlate then
        stat.Text = "No plate found"
        buildDebounce = false
        return
    end
    plateBounds = findMyPlateBounds(myPlate)
    if not plateBounds then
        stat.Text = "No plate part"
        buildDebounce = false
        return
    end

    local activeParts = myPlate:FindFirstChild("ActiveParts")
    if not activeParts then
        stat.Text = "No ActiveParts"
        buildDebounce = false
        return
    end

    rebuildBall()
    local fp = {}
    for _, p in pairs(activeParts:GetDescendants()) do
        if p:IsA("BasePart") and isPartSafe(p) and p.Transparency < 0.5 then
            table.insert(fp, p)
        end
    end
    if #fp == 0 then
        stat.Text = "No parts"
        buildDebounce = false
        return
    end

    table.sort(fp, function(a, b)
        return (a.Position - root.Position).Magnitude < (b.Position - root.Position).Magnitude
    end)
    for i = 1, math.min(#ballParts, #fp) do
        table.insert(parts, fp[i])
    end
    rayParams.FilterDescendantsInstances = parts

    ballPos = plateBounds.center + Vector3.new(0, 20, 0)
    lastBallPos = ballPos
    visualRot = CFrame.identity
    ballVelocity = Vector3.zero
    squishTarget = 0
    squishAmount = 0
    squishAxis = Vector3.new(0, 1, 0)

    posBall()
    active = true
    stat.Text = "Ball: " .. #parts .. " parts"

    conn = RS.Heartbeat:Connect(function(dt)
        if not active then return end

        local moveWorld = Vector3.new(dirs.Right - dirs.Left, 0, dirs.Forward - dirs.Backward)
        if moveWorld.Magnitude > 0 then
            ballVelocity = ballVelocity + moveWorld.Unit * speed * 2
        end

        if rotL then
            visualRot = visualRot * CFrame.Angles(0, math.rad(90) * dt, 0)
        end
        if rotR then
            visualRot = visualRot * CFrame.Angles(0, -math.rad(90) * dt, 0)
        end

        ballVelocity = ballVelocity + gravity * dt
        if ballVelocity.Y < -terminalVelocity then
            ballVelocity = Vector3.new(ballVelocity.X, -terminalVelocity, ballVelocity.Z)
        end

        ballPos = ballPos + ballVelocity * dt

        local clamped = clampToPlate(ballPos)
        if clamped ~= ballPos then
            ballPos = clamped
            ballVelocity = Vector3.new(0, ballVelocity.Y, 0)
        end

        local groundY = getGroundHeight(ballPos)
        if ballPos.Y - 10 <= groundY then
            ballPos = Vector3.new(ballPos.X, groundY + 10, ballPos.Z)
            if ballVelocity.Y < 0 then
                ballVelocity = Vector3.new(ballVelocity.X * 0.3, 0, ballVelocity.Z * 0.3)
            end
        end

        -- Rolling rotation (horizontal only)
        local deltaPos = ballPos - lastBallPos
        lastBallPos = ballPos
        local horizontalDelta = Vector3.new(deltaPos.X, 0, deltaPos.Z)
        if horizontalDelta.Magnitude > 0.001 then
            local rollAngle = horizontalDelta.Magnitude / 10
            local rollAxis = Vector3.new(0, 1, 0):Cross(horizontalDelta.Unit)
            visualRot = visualRot * CFrame.fromAxisAngle(rollAxis, rollAngle)
        end

        -- Only manual squish decay
        squishTarget = squishTarget * math.max(0, 1 - dt * 2)
        squishAmount = squishAmount + (squishTarget - squishAmount) * dt * 6
        if squishAmount < 0.1 then
            squishAmount = 0
            squishTarget = 0
        end

        ballVelocity = Vector3.new(
            ballVelocity.X * (1 - dt * physicsDrag),
            ballVelocity.Y,
            ballVelocity.Z * (1 - dt * physicsDrag)
        )

        posBall()
    end)

    buildDebounce = false
end)

btn("ADD VELOCITY", 10, 98, 125, 28, Color3.fromRGB(255, 150, 50)).MouseButton1Click:Connect(function()
    if not active then return end
    ballVelocity = ballVelocity + Vector3.new(0, 0, -velocityPower)
end)

btn("RESET VELOCITY", 145, 98, 125, 28, Color3.fromRGB(255, 200, 50)).MouseButton1Click:Connect(function()
    ballVelocity = Vector3.zero
end)

btn("DESTROY", 10, 132, 260, 26, Color3.fromRGB(255, 80, 80)).MouseButton1Click:Connect(function()
    teardownBall()
    stat.Text = "Off"
end)

local kbdBtn = btn("KEYBOARD: OFF", 10, 164, 260, 26, Color3.fromRGB(100, 100, 100))
kbdBtn.MouseButton1Click:Connect(function()
    kbd = not kbd
    if kbd then
        kbdBtn.Text = "KEYBOARD: ON (WASD/Z/X)"
        kbdBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        kbdBtn.Text = "KEYBOARD: OFF"
        kbdBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        for k in pairs(dirs) do
            dirs[k] = 0
        end
        rotL, rotR = false, false
        if velConn then
            velConn:Disconnect()
            velConn = nil
        end
        local endTime = tick() + 1
        velConn = RS.Heartbeat:Connect(function()
            if tick() >= endTime then
                velConn:Disconnect()
                velConn = nil
                return
            end
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        end)
    end
end)

local function dirBtn(t, x, y, c, dir)
    local b = btn(t, x, y, 40, 28, c)
    b.TextSize = 12
    b.MouseButton1Down:Connect(function()
        dirs[dir] = 1
    end)
    b.MouseButton1Up:Connect(function()
        dirs[dir] = 0
    end)
    b.MouseLeave:Connect(function()
        dirs[dir] = 0
    end)
end
dirBtn("W", 110, 196, Color3.fromRGB(255, 200, 50), "Forward")
dirBtn("S", 110, 228, Color3.fromRGB(255, 200, 50), "Backward")
dirBtn("A", 65, 212, Color3.fromRGB(255, 100, 100), "Left")
dirBtn("D", 155, 212, Color3.fromRGB(255, 100, 100), "Right")

local zBtn = btn("Z", 15, 196, 40, 28, Color3.fromRGB(200, 150, 255))
zBtn.MouseButton1Down:Connect(function()
    rotL = true
end)
zBtn.MouseButton1Up:Connect(function()
    rotL = false
end)

local xBtn = btn("X", 15, 228, 40, 28, Color3.fromRGB(200, 150, 255))
xBtn.MouseButton1Down:Connect(function()
    rotR = true
end)
xBtn.MouseButton1Up:Connect(function()
    rotR = false
end)

UIS.InputBegan:Connect(function(i, gpe)
    if gpe or not kbd then return end
    if i.KeyCode == Enum.KeyCode.W then
        dirs.Forward = 1
    elseif i.KeyCode == Enum.KeyCode.S then
        dirs.Backward = 1
    elseif i.KeyCode == Enum.KeyCode.A then
        dirs.Left = 1
    elseif i.KeyCode == Enum.KeyCode.D then
        dirs.Right = 1
    elseif i.KeyCode == Enum.KeyCode.Z then
        rotL = true
    elseif i.KeyCode == Enum.KeyCode.X then
        rotR = true
    end
end)
UIS.InputEnded:Connect(function(i, gpe)
    if gpe or not kbd then return end
    if i.KeyCode == Enum.KeyCode.W then
        dirs.Forward = 0
    elseif i.KeyCode == Enum.KeyCode.S then
        dirs.Backward = 0
    elseif i.KeyCode == Enum.KeyCode.A then
        dirs.Left = 0
    elseif i.KeyCode == Enum.KeyCode.D then
        dirs.Right = 0
    elseif i.KeyCode == Enum.KeyCode.Z then
        rotL = false
    elseif i.KeyCode == Enum.KeyCode.X then
        rotR = false
    end
end)

posBall = function()
    if not active then return end
    for i = 1, #parts do
        local b = parts[i]
        local d = ballParts[i]
        if b and b.Parent and d then
            for _, v in pairs(b:GetChildren()) do
                if v:IsA("BodyMover") then
                    v:Destroy()
                end
            end
            b.RotVelocity = Vector3.zero
            b.CanCollide = false
            b.Anchored = false

            local along = squishAxis * d:Dot(squishAxis)
            local perp = d - along
            local flatten = math.max(0.05, 1 - squishAmount * 0.3 * squishIntensity)
            local pos = perp * (1 + squishAmount * 0.15 * squishIntensity) + along * flatten

            b.CFrame = CFrame.new(ballPos) * visualRot * CFrame.new(pos)
        end
    end
end

LPlayer.CharacterAdded:Connect(function(c)
    char = c
    root = c:WaitForChild("HumanoidRootPart")
    sg.Parent = LPlayer:WaitForChild("PlayerGui")
    teardownBall()
end)