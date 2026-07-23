-- Color Block Spawner - Fast Batch (150 blocks)
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
local targetCount = 150

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
local spawnConn = nil

local function spawnBlock(blockId)
    local x = math.random(0, 8) * 6
    local z = math.random(0, 8) * 6
    local cf = LPlate.CFrame * CFrame.new(x, 50, z)
    local result, conn2
    conn2 = Active.ChildAdded:Connect(function(child)
        if child:IsA("Model") then result = child; conn2:Disconnect() end
    end)
    StampAsset:InvokeServer(blockId, cf, uuid, {}, 0)
    repeat task.wait() until result
    spawnCount = spawnCount + 1
end

-- GUI
local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "ColorSpawner"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 280, 0, 200)
frame.Position = UDim2.new(0.5, -140, 0.5, -100)
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

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0, 14)
statusLabel.Position = UDim2.new(0, 0, 0, 26)
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 9

local y = 44
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
        local rs = game:GetService("RunService")
        spawnConn = rs.Heartbeat:Connect(function()
            if spawnCount >= targetCount then
                spawnActive = false
                if spawnConn then spawnConn:Disconnect() end
                statusLabel.Text = "Done! " .. targetCount .. " blocks"
                return
            end
            spawnBlock(c.id)
            statusLabel.Text = "Spawning: " .. spawnCount .. "/" .. targetCount
        end)
    end)
end