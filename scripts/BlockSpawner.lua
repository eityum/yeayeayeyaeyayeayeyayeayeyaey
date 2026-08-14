-- Color Block Spawner - Grid Layers Fast
local player = game:GetService("Players").LocalPlayer
local WS = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local StampAsset = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("StampAsset")

local LPlate, Active
for i, v in pairs(WS.Plates:GetChildren()) do
    if v:FindFirstChild("Owner").Value == player then
        LPlate = v:FindFirstChild("Plate")
        Active = v:FindFirstChild("ActiveParts")
    end
end

local uuid = "{ea9dfeea-65dd-45d7-8409-52630a73544e}"
local spawnCount = 0
local targetCount = 500

local colors = {
    {name = "Cyan", id = 56452470, color = Color3.fromRGB(0, 255, 255)},
    {name = "Blue", id = 56452539, color = Color3.fromRGB(0, 100, 255)},
    {name = "Pink", id = 56452293, color = Color3.fromRGB(255, 150, 200)},
    {name = "Magenta", id = 56452342, color = Color3.fromRGB(255, 0, 255)},
    {name = "Purple", id = 56452411, color = Color3.fromRGB(150, 0, 255)},
    {name = "White", id = 56452868, color = Color3.fromRGB(255, 255, 255)},
    {name = "Orange", id = 56452768, color = Color3.fromRGB(255, 150, 0)},
    {name = "Yellow", id = 56452718, color = Color3.fromRGB(255, 255, 0)},
    {name = "Green", id = 56452651, color = Color3.fromRGB(0, 255, 0)},
    {name = "DkGreen", id = 56452610, color = Color3.fromRGB(0, 150, 0)},
    {name = "Black", id = 56453053, color = Color3.fromRGB(30, 30, 30)},
    {name = "Red", id = 56452821, color = Color3.fromRGB(255, 0, 0)},
    {name = "Gray", id = 56453012, color = Color3.fromRGB(150, 150, 150)},
    {name = "Brown", id = 56452191, color = Color3.fromRGB(139, 69, 19)},
    {name = "DkGray", id = 41324945, color = Color3.fromRGB(80, 80, 80)},
}

local spawnActive = false

local function spawnBlockFast(blockId, worldX, worldY, worldZ)
    local cf = CFrame.new(worldX, worldY, worldZ)
    spawn(function()
        StampAsset:InvokeServer(blockId, cf, uuid, {}, 0)
    end)
end

-- GUI
local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "ColorSpawner"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 280, 0, 250)
frame.Position = UDim2.new(0.5, -140, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextButton", frame)
title.Size = UDim2.new(1, 0, 0, 22)
title.Text = "COLOR SPAWNER (drag)"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Font = Enum.Font.GothamBold
title.TextSize = 10
title.AutoButtonColor = false

local UIS = game:GetService("UserInputService")
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

-- Quantity input
local countLabel = Instance.new("TextLabel", frame)
countLabel.Size = UDim2.new(0, 70, 0, 20)
countLabel.Position = UDim2.new(0, 10, 0, 26)
countLabel.Text = "Amount:"
countLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
countLabel.BackgroundTransparency = 1
countLabel.Font = Enum.Font.Gotham
countLabel.TextSize = 10
countLabel.TextXAlignment = Enum.TextXAlignment.Left

local countBox = Instance.new("TextBox", frame)
countBox.Size = UDim2.new(0, 70, 0, 22)
countBox.Position = UDim2.new(0, 80, 0, 25)
countBox.Text = "500"
countBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
countBox.TextColor3 = Color3.fromRGB(255, 255, 255)
countBox.Font = Enum.Font.Gotham
countBox.TextSize = 10
countBox.BorderSizePixel = 0
Instance.new("UICorner", countBox).CornerRadius = UDim.new(0, 4)

local applyBtn = Instance.new("TextButton", frame)
applyBtn.Size = UDim2.new(0, 50, 0, 22)
applyBtn.Position = UDim2.new(0, 160, 0, 25)
applyBtn.Text = "SET"
applyBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
applyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
applyBtn.Font = Enum.Font.GothamBold
applyBtn.TextSize = 9
applyBtn.BorderSizePixel = 0
Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 4)

applyBtn.MouseButton1Click:Connect(function()
    local n = tonumber(countBox.Text)
    if n and n > 0 then
        targetCount = n
        statusLabel.Text = "Amount set to " .. n
    end
end)

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0, 14)
statusLabel.Position = UDim2.new(0, 0, 0, 50)
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 9

local y = 68
for i, c in ipairs(colors) do
    local col = math.floor((i - 1) / 3)
    local row = (i - 1) % 3
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 85, 0, 22)
    btn.Position = UDim2.new(0, 8 + row * 90, 0, y + col * 26)
    btn.Text = c.name
    btn.BackgroundColor3 = c.color
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        if spawnActive then return end
        spawnActive = true
        spawnCount = 0
        
        local gap = 5
        local cols = 16
        local rows = 16
        local perLayer = 256
        local platePos = LPlate.Position
        local spawnHeight = 100
        
        for i = 1, targetCount do
            local layer = math.floor((i-1) / perLayer)
            local posInLayer = (i-1) % perLayer
            local row = math.floor(posInLayer / cols)
            local col = posInLayer % cols
            local startX = -(cols * gap) / 2 + gap/2
            local startZ = -(rows * gap) / 2 + gap/2
            local worldX = platePos.X + startX + col * gap
            local worldY = spawnHeight + layer * gap
            local worldZ = platePos.Z + startZ + row * gap
            
            spawnBlockFast(c.id, worldX, worldY, worldZ)
            spawnCount = spawnCount + 1
        end
        
        spawnActive = false
        statusLabel.Text = "Spawned " .. spawnCount .. " blocks"
    end)
end
