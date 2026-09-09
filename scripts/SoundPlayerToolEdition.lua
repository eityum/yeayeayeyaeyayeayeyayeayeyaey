local player = game:GetService("Players").LocalPlayer
local ws = game:GetService("Workspace")

local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "SoundToolPlayer"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 270)
main.Position = UDim2.new(0.5, -130, 0.5, -135)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 26)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BorderSizePixel = 0
title.Text = "SOUND TOOL PLAYER"
title.TextColor3 = Color3.fromRGB(255, 120, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local toolLabel = Instance.new("TextLabel", main)
toolLabel.Size = UDim2.new(0, 80, 0, 20)
toolLabel.Position = UDim2.new(0, 10, 0, 32)
toolLabel.BackgroundTransparency = 1
toolLabel.Text = "Tool:"
toolLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
toolLabel.Font = Enum.Font.Gotham
toolLabel.TextSize = 10
toolLabel.TextXAlignment = Enum.TextXAlignment.Left

local toolBox = Instance.new("TextBox", main)
toolBox.Size = UDim2.new(1, -20, 0, 22)
toolBox.Position = UDim2.new(0, 10, 0, 52)
toolBox.Text = "3 Sword"
toolBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toolBox.TextColor3 = Color3.fromRGB(255, 255, 255)
toolBox.Font = Enum.Font.Gotham
toolBox.TextSize = 11
toolBox.BorderSizePixel = 0
Instance.new("UICorner", toolBox).CornerRadius = UDim.new(0, 4)

local soundLabel = Instance.new("TextLabel", main)
soundLabel.Size = UDim2.new(0, 80, 0, 20)
soundLabel.Position = UDim2.new(0, 10, 0, 80)
soundLabel.BackgroundTransparency = 1
soundLabel.Text = "Sound:"
soundLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
soundLabel.Font = Enum.Font.Gotham
soundLabel.TextSize = 10
soundLabel.TextXAlignment = Enum.TextXAlignment.Left

local soundBox = Instance.new("TextBox", main)
soundBox.Size = UDim2.new(1, -20, 0, 22)
soundBox.Position = UDim2.new(0, 10, 0, 100)
soundBox.Text = "Lunge"
soundBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
soundBox.TextColor3 = Color3.fromRGB(255, 255, 255)
soundBox.Font = Enum.Font.Gotham
soundBox.TextSize = 11
soundBox.BorderSizePixel = 0
Instance.new("UICorner", soundBox).CornerRadius = UDim.new(0, 4)

local delayLabel = Instance.new("TextLabel", main)
delayLabel.Size = UDim2.new(0, 40, 0, 20)
delayLabel.Position = UDim2.new(0, 10, 0, 128)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Delay:"
delayLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextSize = 10
delayLabel.TextXAlignment = Enum.TextXAlignment.Left

local delayBox = Instance.new("TextBox", main)
delayBox.Size = UDim2.new(0, 60, 0, 22)
delayBox.Position = UDim2.new(0, 50, 0, 126)
delayBox.Text = "0.1"
delayBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
delayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
delayBox.Font = Enum.Font.Gotham
delayBox.TextSize = 11
delayBox.BorderSizePixel = 0
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 4)

local countBtn = Instance.new("TextButton", main)
countBtn.Size = UDim2.new(1, -20, 0, 26)
countBtn.Position = UDim2.new(0, 10, 0, 154)
countBtn.Text = "COUNT TOOLS"
countBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
countBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
countBtn.Font = Enum.Font.GothamBold
countBtn.TextSize = 10
countBtn.BorderSizePixel = 0
Instance.new("UICorner", countBtn).CornerRadius = UDim.new(0, 4)

local countLabel = Instance.new("TextLabel", main)
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
    
    local wsChar = ws:FindFirstChild(player.Name)
    if wsChar then
        for _, tool in pairs(wsChar:GetChildren()) do
            if tool.Name == toolName and tool:FindFirstChild("Handle") then
                count = count + 1
            end
        end
    end
    
    countLabel.Text = toolName .. ": " .. count
end)

local playBtn = Instance.new("TextButton", main)
playBtn.Size = UDim2.new(1, -20, 0, 30)
playBtn.Position = UDim2.new(0, 10, 0, 206)
playBtn.Text = "PLAY ALL"
playBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
playBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playBtn.Font = Enum.Font.GothamBold
playBtn.TextSize = 11
playBtn.BorderSizePixel = 0
Instance.new("UICorner", playBtn).CornerRadius = UDim.new(0, 4)

playBtn.MouseButton1Click:Connect(function()
    local toolName = toolBox.Text
    local soundName = soundBox.Text
    local delay = tonumber(delayBox.Text) or 0.1
    local played = 0
    
    local tools = {}
    
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool.Name == toolName and tool:FindFirstChild("Handle") then
            table.insert(tools, tool)
        end
    end
    
    local wsChar = ws:FindFirstChild(player.Name)
    if wsChar then
        for _, tool in pairs(wsChar:GetChildren()) do
            if tool.Name == toolName and tool:FindFirstChild("Handle") then
                table.insert(tools, tool)
            end
        end
    end
    
    for _, tool in pairs(tools) do
        local handle = tool:FindFirstChild("Handle")
        if handle then
            local sound = handle:FindFirstChild(soundName)
            if sound and sound:IsA("Sound") then
                sound:Play()
                played = played + 1
                if delay > 0 and played < #tools then
                    task.wait(delay)
                end
            end
        end
    end
    
    countLabel.Text = played .. " played"
end)

local spamBtn = Instance.new("TextButton", main)
spamBtn.Size = UDim2.new(1, -20, 0, 26)
spamBtn.Position = UDim2.new(0, 10, 0, 240)
spamBtn.Text = "SPAM"
spamBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
spamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spamBtn.Font = Enum.Font.GothamBold
spamBtn.TextSize = 10
spamBtn.BorderSizePixel = 0
Instance.new("UICorner", spamBtn).CornerRadius = UDim.new(0, 4)

local spamActive = false
local spamThread = nil

spamBtn.MouseButton1Click:Connect(function()
    spamActive = not spamActive
    
    if spamActive then
        local toolName = toolBox.Text
        local soundName = soundBox.Text
        local delay = tonumber(delayBox.Text) or 0.1
        
        spamBtn.Text = "STOP SPAM"
        spamBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        
        spamThread = task.spawn(function()
            while spamActive do
                -- Backpack first
                for _, tool in pairs(player.Backpack:GetChildren()) do
                    if tool.Name == toolName and tool:FindFirstChild("Handle") then
                        local handle = tool:FindFirstChild("Handle")
                        local sound = handle:FindFirstChild(soundName)
                        if sound and sound:IsA("Sound") then
                            sound:Play()
                        end
                    end
                end
                
                -- Workspace character
                local wsChar = ws:FindFirstChild(player.Name)
                if wsChar then
                    for _, tool in pairs(wsChar:GetChildren()) do
                        if tool.Name == toolName and tool:FindFirstChild("Handle") then
                            local handle = tool:FindFirstChild("Handle")
                            local sound = handle:FindFirstChild(soundName)
                            if sound and sound:IsA("Sound") then
                                sound:Play()
                            end
                        end
                    end
                end
                
                task.wait(delay)
            end
        end)
    else
        if spamThread then task.cancel(spamThread) end
        spamBtn.Text = "SPAM"
        spamBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)
