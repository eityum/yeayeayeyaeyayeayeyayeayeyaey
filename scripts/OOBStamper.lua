-- Stamper OOB Edition - Protected + Reset Velocity
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StampAsset = ReplicatedStorage.Remotes.StampAsset
local DeleteAsset = ReplicatedStorage.Remotes.DeleteAsset
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local LPlate
local ActiveParts
for _, v in pairs(Workspace.Plates:GetChildren()) do
    if v:FindFirstChild("Owner") and v.Owner.Value == player then
        LPlate = v:FindFirstChild("Plate")
        ActiveParts = v:FindFirstChild("ActiveParts")
        break
    end
end

if not LPlate or not ActiveParts then warn("Plate not found") return end

local uuid = "{53b71d9f-03f0-4511-bde3-41bd43751af9}"
local freezeUuid = "{3ee17b14-c66d-4cdd-8500-3782d1dceab5}"

local COLORS = {
    {name = "White", id = 56452868, color = Color3.fromRGB(248, 248, 248)},
    {name = "Red", id = 56452821, color = Color3.fromRGB(196, 40, 28)},
    {name = "Green", id = 56452651, color = Color3.fromRGB(58, 125, 21)},
    {name = "Blue", id = 56452539, color = Color3.fromRGB(33, 84, 185)},
    {name = "Yellow", id = 56452718, color = Color3.fromRGB(253, 234, 141)},
    {name = "Orange", id = 56452768, color = Color3.fromRGB(226, 155, 64)},
    {name = "Purple", id = 56452411, color = Color3.fromRGB(98, 37, 209)},
    {name = "Pink", id = 56452293, color = Color3.fromRGB(255, 102, 204)},
    {name = "Black", id = 56453053, color = Color3.fromRGB(17, 17, 17)},
    {name = "Gray", id = 56453012, color = Color3.fromRGB(163, 162, 165)},
    {name = "Brown", id = 41324954, color = Color3.fromRGB(105, 64, 40)},
    {name = "Cyan", id = 56452470, color = Color3.fromRGB(4, 175, 236)},
}

-- GUI
local CoreGui = game:GetService("CoreGui") or game.CoreGui
local sg = Instance.new("ScreenGui")
sg.Name = "StamperOOB"
sg.Parent = CoreGui

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 240, 0, 290)
frame.Position = UDim2.new(0, 10, 0.5, -145)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextButton", frame)
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "STAMPER OOB (F=Place)"
title.TextColor3 = Color3.fromRGB(255, 150, 50)
title.Font = Enum.Font.GothamBold; title.TextSize = 10; title.AutoButtonColor = false

local drag, dStart, sPos = false, nil, nil
title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        drag = true; dStart = i.Position; sPos = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not drag then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - dStart
        frame.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
end)

-- Block ID
local idBox = Instance.new("TextBox", frame)
idBox.Size = UDim2.new(0, 80, 0, 22); idBox.Position = UDim2.new(0, 65, 0, 30)
idBox.Text = "56450668"; idBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
idBox.Font = Enum.Font.Gotham; idBox.TextSize = 10; idBox.BorderSizePixel = 0
Instance.new("UICorner", idBox).CornerRadius = UDim.new(0, 4)

local idLabel = Instance.new("TextLabel", frame)
idLabel.Size = UDim2.new(0, 55, 0, 22); idLabel.Position = UDim2.new(0, 10, 0, 30)
idLabel.BackgroundTransparency = 1; idLabel.Text = "Block ID:"
idLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
idLabel.Font = Enum.Font.Gotham; idLabel.TextSize = 10; idLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Colors
for i, c in pairs(COLORS) do
    local col = math.floor((i - 1) / 6); local row = (i - 1) % 6
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 32, 0, 18); btn.Position = UDim2.new(0, 10 + row * 37, 0, 56 + col * 22)
    btn.BackgroundColor3 = c.color; btn.Text = ""; btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    btn.MouseButton1Click:Connect(function() idBox.Text = tostring(c.id) end)
end

-- Cursor Toggle
local cursorToggle = Instance.new("TextButton", frame)
cursorToggle.Size = UDim2.new(1, -20, 0, 26); cursorToggle.Position = UDim2.new(0, 10, 0, 104)
cursorToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
cursorToggle.Text = "CURSOR: OFF"; cursorToggle.Font = Enum.Font.GothamBold
cursorToggle.TextSize = 10; cursorToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
cursorToggle.BorderSizePixel = 0
Instance.new("UICorner", cursorToggle).CornerRadius = UDim.new(0, 5)

local cursorActive = false
local cursorConnection = nil
local previewBlock = nil
local targetPos = Vector3.zero
local targetNormal = Vector3.new(0, 1, 0)

cursorToggle.MouseButton1Click:Connect(function()
    cursorActive = not cursorActive
    if cursorActive then
        cursorToggle.Text = "CURSOR: ON"; cursorToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        previewBlock = Instance.new("Part")
        previewBlock.Size = Vector3.new(4, 4, 4); previewBlock.Anchored = true
        previewBlock.CanCollide = false; previewBlock.Transparency = 0.5
        previewBlock.BrickColor = BrickColor.new("White"); previewBlock.Material = Enum.Material.SmoothPlastic
        previewBlock.Parent = Workspace; previewBlock.Name = "PreviewBlock"
        local camera = Workspace.CurrentCamera
        cursorConnection = RunService.RenderStepped:Connect(function()
            if previewBlock and previewBlock.Parent and camera then
                local mousePos = UserInputService:GetMouseLocation()
                local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y, 0)
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {previewBlock, char}
                local result = Workspace:Raycast(ray.Origin, ray.Direction * 5000, rayParams)
                if result then
                    targetNormal = result.Normal
                    local pos = result.Position + result.Normal * 2
                    targetPos = Vector3.new(math.floor(pos.X/4)*4+2, math.floor(pos.Y/4)*4+2, math.floor(pos.Z/4)*4+2)
                    previewBlock.Position = targetPos
                end
            end
        end)
    else
        cursorToggle.Text = "CURSOR: OFF"; cursorToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        if cursorConnection then cursorConnection:Disconnect(); cursorConnection = nil end
        if previewBlock then previewBlock:Destroy(); previewBlock = nil end
    end
end)

-- Place block function - PROTECTED
local function placeBlock(pos, normal)
    local blockId = tonumber(idBox.Text) or 56450668
    local targetCF = CFrame.new(pos)
    local spawnCf = LPlate.CFrame * CFrame.new(0, 50, 0)
    
    local beforeCount = 0
    for _, v in pairs(ActiveParts:GetChildren()) do
        if v:IsA("Model") then beforeCount = beforeCount + 1 end
    end
    
    pcall(function() StampAsset:InvokeServer(blockId, spawnCf, uuid, {}, 0) end)
    
    local newModel = nil
    local start = tick()
    while not newModel and tick() - start < 3 do
        local currentCount = 0
        for _, v in pairs(ActiveParts:GetChildren()) do
            if v:IsA("Model") then currentCount = currentCount + 1 end
        end
        if currentCount > beforeCount then
            for _, v in pairs(ActiveParts:GetChildren()) do
                if v:IsA("Model") and v.PrimaryPart and not v.PrimaryPart.Anchored and v.PrimaryPart.Position.Y > LPlate.Position.Y + 20 and v.PrimaryPart.Position.Y < LPlate.Position.Y + 500 then
                    v.PrimaryPart.Anchored = true
                    newModel = v
                    break
                end
            end
        end
        if not newModel then task.wait(0.05) end
    end
    
    if newModel and newModel.PrimaryPart then
        local part = newModel.PrimaryPart
        part.Anchored = false; part.CanCollide = false
        local bp = Instance.new("BodyPosition")
        bp.Position = pos; bp.MaxForce = Vector3.new(999999, 999999, 999999)
        bp.P = 100000; bp.D = 2000; bp.Parent = part
        task.wait(0.1); bp:Destroy()
        part.CFrame = targetCF; part.Velocity = Vector3.zero; part.RotVelocity = Vector3.zero
        part.Anchored = true; part.CanCollide = true
        
        for i = 1, 10 do
            part.Anchored = true; part.Velocity = Vector3.zero; part.RotVelocity = Vector3.zero
            task.wait(0.1)
        end
        
        pcall(function()
            StampAsset:InvokeServer(56447956, targetCF, freezeUuid, {newModel}, 0)
        end)
    end
end

-- INPUT
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        if not cursorActive then return end
        placeBlock(targetPos, targetNormal)
    end
end)

-- Bottom buttons
local freezeBtn = Instance.new("TextButton", frame)
freezeBtn.Size = UDim2.new(0, 72, 0, 22); freezeBtn.Position = UDim2.new(0, 10, 0, 136)
freezeBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 200)
freezeBtn.Text = "FREEZE"; freezeBtn.Font = Enum.Font.GothamBold
freezeBtn.TextSize = 9; freezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
freezeBtn.BorderSizePixel = 0
Instance.new("UICorner", freezeBtn).CornerRadius = UDim.new(0, 4)
freezeBtn.MouseButton1Click:Connect(function()
    local models = {}
    for _, v in pairs(ActiveParts:GetChildren()) do
        if v:IsA("Model") and v.PrimaryPart and not v.PrimaryPart.Anchored then
            table.insert(models, v)
        end
    end
    local count = #models
    if count == 0 then print("No models to freeze") return end
    StampAsset:InvokeServer(56447956, LPlate.CFrame - Vector3.new(0, 5, 0), freezeUuid, models, 0)
    print("Frozen " .. count .. " models")
end)

local deleteBtn = Instance.new("TextButton", frame)
deleteBtn.Size = UDim2.new(0, 72, 0, 22); deleteBtn.Position = UDim2.new(0, 88, 0, 136)
deleteBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
deleteBtn.Text = "DELETE"; deleteBtn.Font = Enum.Font.GothamBold
deleteBtn.TextSize = 9; deleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
deleteBtn.BorderSizePixel = 0
Instance.new("UICorner", deleteBtn).CornerRadius = UDim.new(0, 4)
deleteBtn.MouseButton1Click:Connect(function()
    local count = 0
    for _, v in pairs(ActiveParts:GetChildren()) do
        if v:IsA("Model") then pcall(function() DeleteAsset:InvokeServer(v) end); count = count + 1 end
    end
    print("Deleted " .. count .. " models")
end)

local unholdBtn = Instance.new("TextButton", frame)
unholdBtn.Size = UDim2.new(0, 72, 0, 22); unholdBtn.Position = UDim2.new(0, 165, 0, 136)
unholdBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
unholdBtn.Text = "UNHOLD"; unholdBtn.Font = Enum.Font.GothamBold
unholdBtn.TextSize = 9; unholdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unholdBtn.BorderSizePixel = 0
Instance.new("UICorner", unholdBtn).CornerRadius = UDim.new(0, 4)
unholdBtn.MouseButton1Click:Connect(function()
    local count = 0
    for _, v in pairs(ActiveParts:GetChildren()) do
        if v:IsA("Model") and v.PrimaryPart then v.PrimaryPart.Anchored = false; count = count + 1 end
    end
    print("Unheld " .. count .. " models")
end)

local resetBtn = Instance.new("TextButton", frame)
resetBtn.Size = UDim2.new(1, -20, 0, 22); resetBtn.Position = UDim2.new(0, 10, 0, 164)
resetBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
resetBtn.Text = "RESET VELOCITY"; resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 9; resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.BorderSizePixel = 0
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 4)
resetBtn.MouseButton1Click:Connect(function()
    local count = 0
    for _, v in pairs(ActiveParts:GetChildren()) do
        if v:IsA("Model") and v.PrimaryPart then
            v.PrimaryPart.Velocity = Vector3.zero
            v.PrimaryPart.RotVelocity = Vector3.zero
            count = count + 1
        end
    end
    print("Reset velocity: " .. count .. " blocks")
end)

local spawnBtn = Instance.new("TextButton", frame)
spawnBtn.Size = UDim2.new(1, -20, 0, 22); spawnBtn.Position = UDim2.new(0, 10, 0, 192)
spawnBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
spawnBtn.Text = "SPAWN GRID"; spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.TextSize = 9; spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnBtn.BorderSizePixel = 0
Instance.new("UICorner", spawnBtn).CornerRadius = UDim.new(0, 4)
spawnBtn.MouseButton1Click:Connect(function()
    local blockId = tonumber(idBox.Text) or 56450668; local total = 100; local spawnHeight = 500
    local platePos = LPlate.Position; local gap = 5; local cols = 16; local rows = 16; local perLayer = 256
    for i = 1, total do
        local layer = math.floor((i-1) / perLayer); local posInLayer = (i-1) % perLayer
        local row = math.floor(posInLayer / cols); local col = posInLayer % cols
        local startX = -(cols * gap) / 2 + gap/2; local startZ = -(rows * gap) / 2 + gap/2
        local cf = CFrame.new(platePos.X + startX + col*gap, spawnHeight + layer*gap, platePos.Z + startZ + row*gap)
        spawn(function() StampAsset:InvokeServer(blockId, cf, uuid, {}, 0) end)
    end
    print("Spawned " .. total .. " blocks")
end)