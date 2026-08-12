-- Telekinesis V5 - Full
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local V3new = Vector3.new
local V3zero = V3new(0, 0, 0)
local huge = math.huge
local max = math.max
local Ins = Instance.new
local White = BrickColor.new("Institutional white")
local delay = task.delay

local mas = Ins("Model", Lighting)
local Tool0 = Ins("Tool")
local Part1 = Ins("Part")

Tool0.Name = "Telekinesis"
Tool0.Parent = mas
Tool0.Grip = CFrame.new(0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1)
Tool0.GripPos = V3new(0, 0, 1)

Part1.Name = "Handle"
Part1.Parent = Tool0
Part1.Size = V3new(1, 1, 1)
Part1.Transparency = 1
Part1.Locked = true
Part1.CanCollide = false
Part1.BrickColor = White

local objects = {}
local keymouse = nil
local mousedown = false
local front = Tool0.Handle
local isFrozen = false

local BPForce = V3new(1e9, 1e9, 1e9)
local BVForceHuge = V3new(huge, huge, huge)
local BGTorque = V3new(huge, huge, huge)

-- Highlight
local highlight = Ins("Highlight")
highlight.Name = "TelekinesisHighlight"
highlight.FillColor = Color3.fromRGB(0, 200, 255)
highlight.OutlineColor = Color3.fromRGB(0, 150, 255)
highlight.FillTransparency = 0.7
highlight.OutlineTransparency = 0
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlight.Parent = Tool0

-- Spin speed
local spinSpeed = 500

-- GUI
local SpinGui = Ins("ScreenGui", player.PlayerGui)
SpinGui.Name = "SpinControl"

local SpinFrame = Ins("Frame", SpinGui)
SpinFrame.Size = UDim2.new(0, 180, 0, 80)
SpinFrame.Position = UDim2.new(0, 10, 0, 10)
SpinFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpinFrame.BorderSizePixel = 0
SpinFrame.Active = true
SpinFrame.Draggable = true
Ins("UICorner", SpinFrame).CornerRadius = UDim.new(0, 6)

local SpinTitle = Ins("TextLabel", SpinFrame)
SpinTitle.Size = UDim2.new(1, 0, 0, 22)
SpinTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpinTitle.Text = "Spin Speed: " .. spinSpeed
SpinTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinTitle.TextSize = 13
SpinTitle.Font = Enum.Font.GothamBold
Ins("UICorner", SpinTitle).CornerRadius = UDim.new(0, 6)

local SpinInput = Ins("TextBox", SpinFrame)
SpinInput.Size = UDim2.new(0, 100, 0, 25)
SpinInput.Position = UDim2.new(0, 10, 0, 30)
SpinInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpinInput.PlaceholderText = "Enter speed..."
SpinInput.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinInput.TextSize = 13
SpinInput.Font = Enum.Font.Gotham
Ins("UICorner", SpinInput).CornerRadius = UDim.new(0, 4)

local SetBtn = Ins("TextButton", SpinFrame)
SetBtn.Size = UDim2.new(0, 55, 0, 25)
SetBtn.Position = UDim2.new(0, 115, 0, 30)
SetBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SetBtn.Text = "Set"
SetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SetBtn.TextSize = 13
SetBtn.Font = Enum.Font.GothamBold
Ins("UICorner", SetBtn).CornerRadius = UDim.new(0, 4)

local CurrentLabel = Ins("TextLabel", SpinFrame)
CurrentLabel.Size = UDim2.new(1, -20, 0, 18)
CurrentLabel.Position = UDim2.new(0, 10, 0, 58)
CurrentLabel.BackgroundTransparency = 1
CurrentLabel.Text = "Current: " .. spinSpeed
CurrentLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
CurrentLabel.TextSize = 11
CurrentLabel.Font = Enum.Font.Gotham

SetBtn.MouseButton1Click:Connect(function()
    local newSpeed = tonumber(SpinInput.Text)
    if newSpeed then
        spinSpeed = newSpeed
        SpinTitle.Text = "Spin Speed: " .. spinSpeed
        CurrentLabel.Text = "Current: " .. spinSpeed
        SpinInput.Text = ""
    end
end)

SpinInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newSpeed = tonumber(SpinInput.Text)
        if newSpeed then
            spinSpeed = newSpeed
            SpinTitle.Text = "Spin Speed: " .. spinSpeed
            CurrentLabel.Text = "Current: " .. spinSpeed
            SpinInput.Text = ""
        end
    end
end)

-- Functions
local function makeBP()
    local bp = Ins("BodyPosition")
    bp.MaxForce = BPForce
    bp.P = bp.P * 3
    return bp
end

local function releaseAll()
    for _, e in pairs(objects) do
        pcall(function() e.bp:Destroy() end)
    end
    objects = {}
    highlight.Adornee = nil
end

local function freezeAll()
    if isFrozen then
        isFrozen = false
        for _, entry in pairs(objects) do
            if entry.part and entry.part.Parent then
                entry.part.Anchored = false
                local bp = makeBP()
                entry.bp = bp
                bp.Parent = entry.part
            end
        end
    else
        isFrozen = true
        for _, entry in pairs(objects) do
            if entry.part and entry.part.Parent then
                pcall(function() entry.bp:Destroy() end)
                entry.part.Velocity = V3zero
                entry.part.RotVelocity = V3zero
                entry.part.Anchored = true
            end
        end
    end
end

local function onButton1Down(mouse)
    if isFrozen then return end
    local target = mouse.Target
    if target == nil or target.Anchored then return end
    releaseAll()
    mousedown = true
    local bp = makeBP()
    local d = (target.Position - Part1.Position).Magnitude
    table.insert(objects, {part = target, bp = bp, dist = d})
    highlight.Adornee = target
end

-- Drag loop
RunService.RenderStepped:Connect(function()
    if not Tool0 or not Tool0.Parent then return end
    if mousedown and #objects > 0 and keymouse and not isFrozen then
        local lv = CFrame.new(Part1.Position, keymouse.Hit.Position)
        for _, entry in pairs(objects) do
            if entry.part and entry.part.Parent then
                if not entry.bp or not entry.bp.Parent then
                    entry.bp = makeBP()
                    entry.bp.Parent = entry.part
                end
                entry.bp.Position = Part1.Position + lv.LookVector * entry.dist
            end
        end
    end
end)

-- Tool events
Tool0.Equipped:Connect(function(mouse)
    keymouse = mouse
    local char = Tool0.Parent
    local human = char:FindFirstChildOfClass("Humanoid")
    if human then
        human.Died:Connect(function()
            mousedown = false
            isFrozen = false
            releaseAll()
            Tool0:Destroy()
            SpinGui:Destroy()
        end)
    end
    
    mouse.Button1Down:Connect(function() onButton1Down(mouse) end)
    mouse.Button1Up:Connect(function()
        mousedown = false
        releaseAll()
    end)
    mouse.KeyDown:Connect(function(key)
        key = key:lower()
        if key == "q" then
            for _, e in pairs(objects) do e.dist = max(5, e.dist - 5) end
        elseif key == "e" then
            for _, e in pairs(objects) do e.dist = e.dist + 5 end
        elseif key == "y" then
            for _, entry in pairs(objects) do
                if entry.part and entry.part.Parent then
                    if entry.part.Anchored then entry.part.Anchored = false end
                    local bv = Ins("BodyVelocity")
                    bv.MaxForce = BVForceHuge
                    bv.Velocity = (keymouse.Hit.Position - entry.part.Position).Unit * 300
                    bv.Parent = entry.part
                    delay(0.5, function() if bv and bv.Parent then bv:Destroy() end end)
                end
            end
            isFrozen = false
            releaseAll()
            mousedown = false
        elseif key == "f" then
            for _, entry in pairs(objects) do
                if entry.part and entry.part.Parent then
                    if entry.part.Anchored then entry.part.Anchored = false end
                    local bv = Ins("BodyVelocity")
                    bv.MaxForce = BVForceHuge
                    bv.Velocity = (keymouse.Hit.Position - entry.part.Position).Unit * 500
                    bv.Parent = entry.part
                    delay(0.5, function() if bv and bv.Parent then bv:Destroy() end end)
                end
            end
            isFrozen = false
            releaseAll()
            mousedown = false
        elseif key == "x" then
            for _, e in pairs(objects) do e.dist = 15 end
        elseif key == "j" then
            for _, e in pairs(objects) do e.dist = 5000 end
        elseif key == "h" then
            for _, entry in pairs(objects) do
                if entry.part and entry.part.Parent then
                    for _, v in pairs(entry.part:GetChildren()) do
                        if v.ClassName == "BodyAngularVelocity" then v:Destroy() end
                    end
                    local av = Ins("BodyAngularVelocity")
                    av.MaxTorque = BGTorque
                    av.AngularVelocity = V3new(0, spinSpeed, 0)
                    av.Parent = entry.part
                end
            end
        elseif key == "r" then
            freezeAll()
        elseif key == "z" then
            isFrozen = false
            releaseAll()
            mousedown = false
        end
    end)
end)

Tool0.Unequipped:Connect(function()
    mousedown = false
    isFrozen = false
    releaseAll()
    keymouse = nil
end)

for _, v in pairs(mas:GetChildren()) do
    v.Parent = player.Backpack
    pcall(function() v:MakeJoints() end)
end
mas:Destroy()
