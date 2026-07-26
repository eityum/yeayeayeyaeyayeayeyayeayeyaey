-- WorldEdit Wand - Reliable Placement - 4x4x4 Blocks - CoreGui
local UIS = game:GetService("UserInputService")
local WS = game:GetService("Workspace")
local PS = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local StampAsset = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StampAsset")

local player = PS.LocalPlayer
local mouse = player:GetMouse()

local LPlate, Active, plateName, spawnLocation
for i, v in pairs(WS.Plates:GetChildren()) do
    if v:FindFirstChild("Owner").Value == player then
        LPlate = v:FindFirstChild("Plate")
        Active = v:FindFirstChild("ActiveParts")
        plateName = v.Name
        spawnLocation = v:FindFirstChild("SpawnLocation")
    end
end

local pos1, pos2, mode, blockId = nil, nil, "set", 56450668
local uuid = "{c832eeb8-caaa-4b3c-ac7e-741e0d3875b1}"
local wait1, wait2 = false, false

-- GUI
local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "WandTool"
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 250, 0, 212)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local topBar = Instance.new("Frame", frame)
topBar.Size = UDim2.new(1, 0, 0, 26)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextButton", topBar)
title.Size = UDim2.new(0, 200, 0, 20)
title.Position = UDim2.new(0, 8, 0, 3)
title.Text = "🪄 WORLD EDIT WAND"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 10
title.AutoButtonColor = false

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(0, 224, 0, 3)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local drag, dStart, sPos = false, nil, nil
title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; dStart = i.Position; sPos = frame.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if not drag then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - dStart
        frame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
end)

local idLabel = Instance.new("TextLabel", frame)
idLabel.Size = UDim2.new(0, 55, 0, 16)
idLabel.Position = UDim2.new(0, 10, 0, 32)
idLabel.BackgroundTransparency = 1
idLabel.Text = "Block ID:"
idLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
idLabel.Font = Enum.Font.Gotham
idLabel.TextSize = 10
idLabel.TextXAlignment = Enum.TextXAlignment.Left

local idBox = Instance.new("TextBox", frame)
idBox.Size = UDim2.new(0, 80, 0, 22)
idBox.Position = UDim2.new(0, 65, 0, 29)
idBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
idBox.Text = "56450668"
idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
idBox.Font = Enum.Font.Gotham
idBox.TextSize = 11
idBox.BorderSizePixel = 0
Instance.new("UICorner", idBox).CornerRadius = UDim.new(0, 4)

local pos1Btn = Instance.new("TextButton", frame)
pos1Btn.Size = UDim2.new(0, 110, 0, 28)
pos1Btn.Position = UDim2.new(0, 10, 0, 60)
pos1Btn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
pos1Btn.Text = "POS1: Not set"
pos1Btn.Font = Enum.Font.GothamBold
pos1Btn.TextSize = 10
pos1Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
pos1Btn.BorderSizePixel = 0
Instance.new("UICorner", pos1Btn).CornerRadius = UDim.new(0, 5)

local pos2Btn = Instance.new("TextButton", frame)
pos2Btn.Size = UDim2.new(0, 110, 0, 28)
pos2Btn.Position = UDim2.new(0, 130, 0, 60)
pos2Btn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
pos2Btn.Text = "POS2: Not set"
pos2Btn.Font = Enum.Font.GothamBold
pos2Btn.TextSize = 10
pos2Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
pos2Btn.BorderSizePixel = 0
Instance.new("UICorner", pos2Btn).CornerRadius = UDim.new(0, 5)

local modeLabel = Instance.new("TextLabel", frame)
modeLabel.Size = UDim2.new(1, 0, 0, 16)
modeLabel.Position = UDim2.new(0, 10, 0, 94)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = "Mode:"
modeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
modeLabel.Font = Enum.Font.GothamBold
modeLabel.TextSize = 10
modeLabel.TextXAlignment = Enum.TextXAlignment.Left

local modeBtns = {}
local function modeBtn(text, x, m)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 55, 0, 24)
    btn.Position = UDim2.new(0, x, 0, 110)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    table.insert(modeBtns, btn)
    btn.MouseButton1Click:Connect(function()
        mode = m
        for _, b in pairs(modeBtns) do
            b.BackgroundColor3 = b == btn and Color3.fromRGB(100, 180, 100) or Color3.fromRGB(50, 50, 50)
        end
    end)
    return btn
end

local fillModeBtn = modeBtn("Fill", 10, "set")
modeBtn("Walls", 70, "walls")
modeBtn("Floor", 130, "floor")
modeBtn("Line", 190, "line")
fillModeBtn.BackgroundColor3 = Color3.fromRGB(100, 180, 100)

local execBtn = Instance.new("TextButton", frame)
execBtn.Size = UDim2.new(1, -20, 0, 30)
execBtn.Position = UDim2.new(0, 10, 0, 140)
execBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
execBtn.Text = "EXECUTE"
execBtn.Font = Enum.Font.GothamBold
execBtn.TextSize = 13
execBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
execBtn.BorderSizePixel = 0
Instance.new("UICorner", execBtn).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1, 0, 0, 14)
status.Position = UDim2.new(0, 0, 0, 176)
status.BackgroundTransparency = 1
status.Text = "Click POS1/POS2 then click a block"
status.TextColor3 = Color3.fromRGB(180, 180, 180)
status.Font = Enum.Font.Gotham
status.TextSize = 9

pos1Btn.MouseButton1Click:Connect(function()
    wait1, wait2 = true, false
    pos1Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    pos1Btn.Text = "POS1: Click block..."
end)

pos2Btn.MouseButton1Click:Connect(function()
    wait2, wait1 = true, false
    pos2Btn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
    pos2Btn.Text = "POS2: Click block..."
end)

mouse.Button1Down:Connect(function()
    if not mouse.Target then return end
    local p = mouse.Target.Position
    local snap = Vector3.new(math.floor(p.X/4)*4+2, p.Y, math.floor(p.Z/4)*4+2)
    if wait1 then
        pos1 = snap
        pos1Btn.Text = string.format("POS1: %.0f,%.1f,%.0f", pos1.X, pos1.Y, pos1.Z)
        pos1Btn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
        wait1 = false
    elseif wait2 then
        pos2 = snap
        pos2Btn.Text = string.format("POS2: %.0f,%.1f,%.0f", pos2.X, pos2.Y, pos2.Z)
        pos2Btn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        wait2 = false
    end
end)

execBtn.MouseButton1Click:Connect(function()
    if not pos1 or not pos2 then status.Text = "Set both positions!" return end
    blockId = tonumber(idBox.Text) or 56450668
    local minX, maxX = math.min(pos1.X, pos2.X), math.max(pos1.X, pos2.X)
    local minY, maxY = math.min(pos1.Y, pos2.Y), math.max(pos1.Y, pos2.Y)
    local minZ, maxZ = math.min(pos1.Z, pos2.Z), math.max(pos1.Z, pos2.Z)
    
    local positions = {}
    for x = minX, maxX, 4 do
        for y = minY, maxY, 4 do
            for z = minZ, maxZ, 4 do
                local ok = mode == "set"
                if not ok and mode == "walls" then ok = (x==minX or x==maxX or y==minY or y==maxY or z==minZ or z==maxZ)
                elseif not ok and mode == "floor" then ok = (y==minY)
                elseif not ok and mode == "line" then
                    local dx, dy, dz = maxX - minX, maxY - minY, maxZ - minZ
                    local steps = math.max(dx, dy, dz) / 4
                    local lastX, lastY, lastZ
                    for i = 0, steps do
                        local t = steps == 0 and 0 or i / steps
                        local lx = math.floor((minX + dx * t)/4)*4 + 2
                        local ly = math.floor((minY + dy * t)/4)*4 + 2
                        local lz = math.floor((minZ + dz * t)/4)*4 + 2
                        if lx ~= lastX or ly ~= lastY or lz ~= lastZ then
                            positions[#positions+1] = CFrame.new(lx, ly, lz)
                            lastX, lastY, lastZ = lx, ly, lz
                        end
                    end
                    break
                end
                if ok then positions[#positions+1] = CFrame.new(x, y, z) end
            end
        end
    end
    
    local total = #positions
    status.Text = "Placing " .. total .. " blocks..."
    
    for i = 1, total do
        StampAsset:InvokeServer(blockId, positions[i], uuid, {spawnLocation}, 0)
    end
    
    status.Text = "Done! " .. total .. " blocks"
end)
