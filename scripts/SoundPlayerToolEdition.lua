-- Sound Player - Tool Edition GUI
local player = game:GetService("Players").LocalPlayer
local CoreGui = game:GetService("CoreGui") or game.CoreGui

if CoreGui:FindFirstChild("SoundPlayer") then
    CoreGui.SoundPlayer:Destroy()
end

local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "SoundPlayer"

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 260, 0, 240)
frame.Position = UDim2.new(0.5, -130, 0.5, -120)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextButton", frame)
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
title.Text = "SOUND PLAYER (drag)"
title.TextColor3 = Color3.fromRGB(255, 150, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
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

local toolLabel = Instance.new("TextLabel", frame)
toolLabel.Size = UDim2.new(0, 80, 0, 20)
toolLabel.Position = UDim2.new(0, 10, 0, 30)
toolLabel.BackgroundTransparency = 1
toolLabel.Text = "Tool Name:"
toolLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
toolLabel.Font = Enum.Font.Gotham
toolLabel.TextSize = 10
toolLabel.TextXAlignment = Enum.TextXAlignment.Left

local toolBox = Instance.new("TextBox", frame)
toolBox.Size = UDim2.new(1, -20, 0, 22)
toolBox.Position = UDim2.new(0, 10, 0, 50)
toolBox.Text = "VIP Sword"
toolBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
toolBox.TextColor3 = Color3.fromRGB(255, 255, 255)
toolBox.Font = Enum.Font.Gotham
toolBox.TextSize = 11
toolBox.BorderSizePixel = 0
Instance.new("UICorner", toolBox).CornerRadius = UDim.new(0, 4)

local soundLabel = Instance.new("TextLabel", frame)
soundLabel.Size = UDim2.new(0, 80, 0, 20)
soundLabel.Position = UDim2.new(0, 10, 0, 78)
soundLabel.BackgroundTransparency = 1
soundLabel.Text = "Sound Name:"
soundLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
soundLabel.Font = Enum.Font.Gotham
soundLabel.TextSize = 10
soundLabel.TextXAlignment = Enum.TextXAlignment.Left

local soundBox = Instance.new("TextBox", frame)
soundBox.Size = UDim2.new(1, -20, 0, 22)
soundBox.Position = UDim2.new(0, 10, 0, 98)
soundBox.Text = "Equip"
soundBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
soundBox.TextColor3 = Color3.fromRGB(255, 255, 255)
soundBox.Font = Enum.Font.Gotham
soundBox.TextSize = 11
soundBox.BorderSizePixel = 0
Instance.new("UICorner", soundBox).CornerRadius = UDim.new(0, 4)

local delayLabel = Instance.new("TextLabel", frame)
delayLabel.Size = UDim2.new(0, 40, 0, 20)
delayLabel.Position = UDim2.new(0, 10, 0, 126)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Delay:"
delayLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextSize = 10
delayLabel.TextXAlignment = Enum.TextXAlignment.Left

local delayBox = Instance.new("TextBox", frame)
delayBox.Size = UDim2.new(0, 60, 0, 22)
delayBox.Position = UDim2.new(0, 50, 0, 124)
delayBox.Text = "0.1"
delayBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
delayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
delayBox.Font = Enum.Font.Gotham
delayBox.TextSize = 11
delayBox.BorderSizePixel = 0
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 4)

local countBtn = Instance.new("TextButton", frame)
countBtn.Size = UDim2.new(1, -20, 0, 28)
countBtn.Position = UDim2.new(0, 10, 0, 152)
countBtn.Text = "COUNT TOOLS"
countBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
countBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
countBtn.Font = Enum.Font.GothamBold
countBtn.TextSize = 10
countBtn.BorderSizePixel = 0
Instance.new("UICorner", countBtn).CornerRadius = UDim.new(0, 5)

local countLabel = Instance.new("TextLabel", frame)
countLabel.Size = UDim2.new(1, -20, 0, 18)
countLabel.Position = UDim2.new(0, 10, 0, 184)
countLabel.BackgroundTransparency = 1
countLabel.Text = "Count: 0"
countLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
countLabel.Font = Enum.Font.GothamBold
countLabel.TextSize = 10
countLabel.TextXAlignment = Enum.TextXAlignment.Center

countBtn.MouseButton1Click:Connect(function()
    local toolName = toolBox.Text
    local count = 0
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool.Name == toolName and tool:FindFirstChild("Handle") then
            count = count + 1
        end
    end
    countLabel.Text = toolName .. ": " .. count
end)

local playBtn = Instance.new("TextButton", frame)
playBtn.Size = UDim2.new(1, -20, 0, 35)
playBtn.Position = UDim2.new(0, 10, 0, 208)
playBtn.Text = "PLAY SOUND"
playBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playBtn.Font = Enum.Font.GothamBold
playBtn.TextSize = 12
playBtn.BorderSizePixel = 0
Instance.new("UICorner", playBtn).CornerRadius = UDim.new(0, 5)

playBtn.MouseButton1Click:Connect(function()
    local toolName = toolBox.Text
    local soundName = soundBox.Text
    local delay = tonumber(delayBox.Text) or 0.1
    local played = 0
    
    local tools = {}
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool.Name == toolName and tool:FindFirstChild("Handle") and tool.Handle:FindFirstChild(soundName) then
            table.insert(tools, tool)
        end
    end
    
    for _, tool in pairs(tools) do
        tool.Handle[soundName]:Play()
        played = played + 1
        if delay > 0 and played < #tools then
            task.wait(delay)
        end
    end
    
    countLabel.Text = toolName .. ": " .. played .. " played"
end)