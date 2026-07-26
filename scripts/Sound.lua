local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
sg.Name = "SoundServiceSpammer"
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 380)
main.Position = UDim2.new(0.5, -130, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 26)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.BorderSizePixel = 0
title.Text = "SOUND SERVICE SPAMMER"
title.TextColor3 = Color3.fromRGB(255, 120, 50)
title.Font = Enum.Font.GothamBold
title.TextSize = 11
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -26, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

local refreshBtn = Instance.new("TextButton", main)
refreshBtn.Size = UDim2.new(0, 80, 0, 24)
refreshBtn.Position = UDim2.new(0, 10, 0, 32)
refreshBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
refreshBtn.Text = "REFRESH"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 10
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.BorderSizePixel = 0
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 4)

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(0, 150, 0, 24)
status.Position = UDim2.new(0, 100, 0, 32)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(140, 140, 140)
status.Font = Enum.Font.Gotham
status.TextSize = 10
status.TextXAlignment = Enum.TextXAlignment.Left

local listFrame = Instance.new("ScrollingFrame", main)
listFrame.Size = UDim2.new(1, -20, 0, 180)
listFrame.Position = UDim2.new(0, 10, 0, 62)
listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 5)

local uiList = Instance.new("UIListLayout", listFrame)
uiList.Padding = UDim.new(0, 3)
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local spamFrame = Instance.new("Frame", main)
spamFrame.Size = UDim2.new(1, -20, 0, 120)
spamFrame.Position = UDim2.new(0, 10, 0, 248)
spamFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
spamFrame.BorderSizePixel = 0
Instance.new("UICorner", spamFrame).CornerRadius = UDim.new(0, 6)

local spamTitle = Instance.new("TextLabel", spamFrame)
spamTitle.Size = UDim2.new(1, 0, 0, 18)
spamTitle.BackgroundTransparency = 1
spamTitle.Text = "SPAM CONTROLS"
spamTitle.TextColor3 = Color3.fromRGB(255, 150, 50)
spamTitle.Font = Enum.Font.GothamBold
spamTitle.TextSize = 10

local selectedLabel = Instance.new("TextLabel", spamFrame)
selectedLabel.Size = UDim2.new(1, 0, 0, 16)
selectedLabel.Position = UDim2.new(0, 0, 0, 20)
selectedLabel.BackgroundTransparency = 1
selectedLabel.Text = "Selected: None"
selectedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
selectedLabel.Font = Enum.Font.Gotham
selectedLabel.TextSize = 9
selectedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedLabel = Instance.new("TextLabel", spamFrame)
speedLabel.Size = UDim2.new(0, 60, 0, 16)
speedLabel.Position = UDim2.new(0, 0, 0, 40)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Speed:"
speedLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 10
speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedBox = Instance.new("TextBox", spamFrame)
speedBox.Size = UDim2.new(0, 50, 0, 22)
speedBox.Position = UDim2.new(0, 55, 0, 37)
speedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedBox.BorderSizePixel = 0
speedBox.Text = "0.05"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 11
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 4)

local spamBtn = Instance.new("TextButton", spamFrame)
spamBtn.Size = UDim2.new(1, -10, 0, 28)
spamBtn.Position = UDim2.new(0, 5, 0, 65)
spamBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
spamBtn.Text = "START SPAM"
spamBtn.Font = Enum.Font.GothamBold
spamBtn.TextSize = 11
spamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spamBtn.BorderSizePixel = 0
Instance.new("UICorner", spamBtn).CornerRadius = UDim.new(0, 5)

local stopAllBtn = Instance.new("TextButton", spamFrame)
stopAllBtn.Size = UDim2.new(1, -10, 0, 22)
stopAllBtn.Position = UDim2.new(0, 5, 0, 96)
stopAllBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
stopAllBtn.Text = "STOP ALL"
stopAllBtn.Font = Enum.Font.GothamBold
stopAllBtn.TextSize = 10
stopAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
stopAllBtn.BorderSizePixel = 0
Instance.new("UICorner", stopAllBtn).CornerRadius = UDim.new(0, 4)

local selectedSound = nil
local spamActive = false
local spamThread = nil

local function refreshList()
    for _, v in pairs(listFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    
    local soundService = game:GetService("SoundService")
    local sounds = {}
    for _, v in ipairs(soundService:GetChildren()) do
        if v:IsA("Sound") then
            table.insert(sounds, v)
        end
    end
    
    if #sounds == 0 then
        local none = Instance.new("TextLabel", listFrame)
        none.Size = UDim2.new(1, -10, 0, 30)
        none.BackgroundTransparency = 1
        none.Text = "No sounds in SoundService"
        none.TextColor3 = Color3.fromRGB(140, 140, 140)
        none.Font = Enum.Font.Gotham
        none.TextSize = 10
        return
    end
    
    for _, sound in ipairs(sounds) do
        local row = Instance.new("TextButton", listFrame)
        row.Size = UDim2.new(1, -10, 0, 28)
        row.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        row.Text = sound.Name
        row.Font = Enum.Font.Gotham
        row.TextSize = 11
        row.TextColor3 = Color3.fromRGB(255, 255, 255)
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
        
        row.MouseButton1Click:Connect(function()
            if spamActive then return end
            selectedSound = sound
            selectedLabel.Text = "Selected: " .. sound.Name
            selectedLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            sound:Play()
            status.Text = "Played: " .. sound.Name
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
            task.delay(1.5, function()
                if status and status.Parent and status.Text == "Played: " .. sound.Name then
                    status.Text = "Ready"
                    status.TextColor3 = Color3.fromRGB(140, 140, 140)
                end
            end)
        end)
    end
    
    listFrame.CanvasSize = UDim2.new(0, 0, 0, #sounds * 31)
    status.Text = "Loaded: " .. #sounds .. " sounds"
    status.TextColor3 = Color3.fromRGB(140, 140, 140)
end

refreshBtn.MouseButton1Click:Connect(refreshList)

stopAllBtn.MouseButton1Click:Connect(function()
    spamActive = false
    if spamThread then task.cancel(spamThread) end
    spamBtn.Text = "START SPAM"
    spamBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
    status.Text = "Stopped"
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
end)

spamBtn.MouseButton1Click:Connect(function()
    if not selectedSound then
        status.Text = "Select a sound first"
        status.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end
    
    spamActive = not spamActive
    
    if spamActive then
        local delayTime = tonumber(speedBox.Text) or 0.05
        spamBtn.Text = "STOP SPAM"
        spamBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        status.Text = "Spamming: " .. selectedSound.Name .. " @ " .. delayTime .. "s"
        status.TextColor3 = Color3.fromRGB(255, 200, 50)
        
        spamThread = task.spawn(function()
            while spamActive and selectedSound and selectedSound.Parent do
                selectedSound:Play()
                task.wait(delayTime)
            end
            spamActive = false
            spamBtn.Text = "START SPAM"
            spamBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
            if status and status.Parent then
                status.Text = "Ready"
                status.TextColor3 = Color3.fromRGB(140, 140, 140)
            end
        end)
    else
        if spamThread then task.cancel(spamThread) end
        spamBtn.Text = "START SPAM"
        spamBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        status.Text = "Ready"
        status.TextColor3 = Color3.fromRGB(140, 140, 140)
    end
end)

refreshList()