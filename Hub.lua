-- Eityum Hub - Universal Script Hub with Tabs + Scroll + Credits Tab (WIDER)
local player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "EityumHub"
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 300, 0, 440)
frame.Position = UDim2.new(0, 10, 0.5, -220)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
frame.Visible = true

-- Minimized button container
local minContainer = Instance.new("Frame", sg)
minContainer.Size = UDim2.new(0, 50, 0, 50)
minContainer.Position = UDim2.new(0, 10, 0.5, -25)
minContainer.BackgroundTransparency = 1
minContainer.Visible = false

local minBtn = Instance.new("TextButton", minContainer)
minBtn.Size = UDim2.new(0, 40, 0, 40)
minBtn.Position = UDim2.new(0, 10, 0, 0)
minBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
minBtn.Text = "🔥"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 18
minBtn.TextColor3 = Color3.fromRGB(255, 170, 20)
minBtn.BorderSizePixel = 0
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 10)

local minDragHandle = Instance.new("TextButton", minContainer)
minDragHandle.Size = UDim2.new(0, 50, 0, 10)
minDragHandle.Position = UDim2.new(0, 0, 0, 0)
minDragHandle.BackgroundColor3 = Color3.fromRGB(255, 170, 20)
minDragHandle.BackgroundTransparency = 0.3
minDragHandle.Text = ""
minDragHandle.BorderSizePixel = 0
Instance.new("UICorner", minDragHandle).CornerRadius = UDim.new(0, 3)

minBtn.MouseButton1Click:Connect(function()
    frame.Position = minContainer.Position
    frame.Visible = true
    minContainer.Visible = false
end)

local minDrag, minDStart, minSPos = false, nil, nil
minDragHandle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        minDrag = true
        minDStart = i.Position
        minSPos = minContainer.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if not minDrag then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        local d = i.Position - minDStart
        minContainer.Position = UDim2.new(minSPos.X.Scale, minSPos.X.Offset + d.X, minSPos.Y.Scale, minSPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        minDrag = false
    end
end)

-- Top bar
local topBar = Instance.new("Frame", frame)
topBar.Size = UDim2.new(1, 0, 0, 32)
topBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local topGlow = Instance.new("Frame", topBar)
topGlow.Size = UDim2.new(1, 0, 0, 2)
topGlow.BackgroundColor3 = Color3.fromRGB(255, 180, 30)
topGlow.BorderSizePixel = 0

local title = Instance.new("TextButton", topBar)
title.Size = UDim2.new(0, 130, 0, 26)
title.Position = UDim2.new(0, 10, 0, 3)
title.Text = "🔥 Eityum Hub"
title.TextColor3 = Color3.fromRGB(255, 170, 20)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 13
title.AutoButtonColor = false

local minimizeBtn = Instance.new("TextButton", topBar)
minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
minimizeBtn.Position = UDim2.new(0, 236, 0, 3)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 30)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 14
minimizeBtn.BorderSizePixel = 0
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)
minimizeBtn.MouseButton1Click:Connect(function()
    minContainer.Position = frame.Position
    frame.Visible = false
    minContainer.Visible = true
end)

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(0, 266, 0, 3)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 45, 45)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
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

-- Tabs
local tabs = {}
local currentTab = "Destructive"
local tabContent = {}

local tabBar = Instance.new("Frame", frame)
tabBar.Size = UDim2.new(1, -16, 0, 28)
tabBar.Position = UDim2.new(0, 8, 0, 38)
tabBar.BackgroundTransparency = 1

local tabNames = {"Destructive", "Tools", "Unanchored", "Credits"}
local tabWidth = (300 - 16) / 4

-- Scrollable content frame
local scrollFrame = Instance.new("ScrollingFrame", frame)
scrollFrame.Size = UDim2.new(1, -8, 1, -72)
scrollFrame.Position = UDim2.new(0, 4, 0, 70)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 3
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
scrollFrame.BorderSizePixel = 0

local scrollContent = Instance.new("Frame", scrollFrame)
scrollContent.Size = UDim2.new(1, 0, 0, 0)
scrollContent.BackgroundTransparency = 1

local buttonColors = {
    Color3.fromRGB(60, 100, 210),
    Color3.fromRGB(210, 65, 65),
    Color3.fromRGB(55, 175, 100),
    Color3.fromRGB(190, 125, 45),
    Color3.fromRGB(145, 65, 210),
    Color3.fromRGB(45, 165, 185),
    Color3.fromRGB(210, 145, 40),
    Color3.fromRGB(185, 55, 155),
    Color3.fromRGB(75, 135, 210),
    Color3.fromRGB(45, 185, 95),
    Color3.fromRGB(210, 95, 95),
    Color3.fromRGB(255, 150, 30),
}

local colorIndex = 0
local y = 0
local function addButton(name, callback)
    colorIndex = colorIndex + 1
    local col = buttonColors[(colorIndex - 1) % #buttonColors + 1]
    
    local btn = Instance.new("TextButton", scrollContent)
    btn.Size = UDim2.new(1, -16, 0, 36)
    btn.Position = UDim2.new(0, 4, 0, y)
    btn.Text = "  " .. name
    btn.BackgroundColor3 = col
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    
    local bar = Instance.new("Frame", btn)
    bar.Size = UDim2.new(0, 3, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    bar.BackgroundTransparency = 0.6
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.new(math.min(col.R*1.3,255), math.min(col.G*1.3,255), math.min(col.B*1.3,255))
        bar.BackgroundTransparency = 0.2
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = col
        bar.BackgroundTransparency = 0.6
    end)
    
    btn.MouseButton1Click:Connect(callback)
    y = y + 42
end

local function clearContent()
    for _, v in pairs(scrollContent:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("Frame") or v:IsA("TextLabel") then
            v:Destroy()
        end
    end
end

local function switchTab(tabName)
    currentTab = tabName
    for name, btn in pairs(tabs) do
        if name == tabName then
            btn.BackgroundColor3 = Color3.fromRGB(255, 170, 20)
            btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        else
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        end
    end
    clearContent()
    y = 0
    colorIndex = 0
    
    if tabName == "Credits" then
        y = 6
        local creditLabel = Instance.new("TextLabel", scrollContent)
        creditLabel.Size = UDim2.new(1, -16, 0, 22)
        creditLabel.Position = UDim2.new(0, 8, 0, y)
        creditLabel.Text = "💛 CREDITS"
        creditLabel.TextColor3 = Color3.fromRGB(255, 170, 20)
        creditLabel.BackgroundTransparency = 1
        creditLabel.Font = Enum.Font.GothamBold
        creditLabel.TextSize = 12
        creditLabel.TextXAlignment = Enum.TextXAlignment.Left
        y = y + 30
        
        local credits = {
            {name = "Eityum", desc = "Creator & Developer", color = Color3.fromRGB(255, 200, 50)},
            {name = "Claude", desc = "Smiley Hub Original", color = Color3.fromRGB(200, 150, 255)},
            {name = "DeepSeek", desc = "Mech, Cobra, Stick, Tornado", color = Color3.fromRGB(100, 200, 255)},
            {name = "EdgeIY", desc = "Infinite Yield", color = Color3.fromRGB(255, 100, 100)},
        }
        
        for _, credit in pairs(credits) do
            local creditFrame = Instance.new("Frame", scrollContent)
            creditFrame.Size = UDim2.new(1, -16, 0, 42)
            creditFrame.Position = UDim2.new(0, 4, 0, y)
            creditFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            creditFrame.BorderSizePixel = 0
            Instance.new("UICorner", creditFrame).CornerRadius = UDim.new(0, 6)
            
            local dot = Instance.new("Frame", creditFrame)
            dot.Size = UDim2.new(0, 8, 0, 8)
            dot.Position = UDim2.new(0, 12, 0, 17)
            dot.BackgroundColor3 = credit.color
            dot.BorderSizePixel = 0
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
            
            local nameLabel = Instance.new("TextLabel", creditFrame)
            nameLabel.Size = UDim2.new(1, -24, 0, 20)
            nameLabel.Position = UDim2.new(0, 24, 0, 3)
            nameLabel.Text = credit.name
            nameLabel.TextColor3 = credit.color
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local descLabel = Instance.new("TextLabel", creditFrame)
            descLabel.Size = UDim2.new(1, -24, 0, 16)
            descLabel.Position = UDim2.new(0, 24, 0, 22)
            descLabel.Text = credit.desc
            descLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
            descLabel.BackgroundTransparency = 1
            descLabel.Font = Enum.Font.Gotham
            descLabel.TextSize = 10
            descLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            y = y + 48
        end
    else
        for _, btnData in pairs(tabContent[tabName]) do
            addButton(btnData.name, btnData.callback)
        end
    end
    
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

for i, name in ipairs(tabNames) do
    local tabBtn = Instance.new("TextButton", tabBar)
    tabBtn.Size = UDim2.new(0, tabWidth - 3, 0, 28)
    tabBtn.Position = UDim2.new(0, (i-1) * tabWidth + 2, 0, 0)
    tabBtn.Text = name
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextSize = 10
    tabBtn.BorderSizePixel = 0
    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 5)
    
    if name == "Destructive" then
        tabBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 20)
        tabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        tabBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
    
    tabBtn.MouseButton1Click:Connect(function() switchTab(name) end)
    tabs[name] = tabBtn
    tabContent[name] = {}
end

-- Fill tabs
tabContent["Destructive"] = {
    {name = "🔧 SoundPlayer Tool", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/SoundPlayerToolEdition.lua"))() end},
    {name = "🔊 Sound Spammer", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/Sound.lua"))() end},
    {name = "💀 Void", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/void.lua"))() end},
    {name = "🔨 OOB Stamper", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/OOBStamper.lua"))() end},
}

tabContent["Tools"] = {
    {name = "♾️ Infinite Yield", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end},
    {name = "😊 SmileyHub", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/SmileyHub.lua"))() end},
    {name = "🪄 WorldEdit Wand", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/Wand.lua"))() end},
    {name = "🧱 Block Spawner", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/BlockSpawner.lua"))() end},
    {name = "🔧 F3X", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/F3X%20abuse.lua"))() end},
}

tabContent["Unanchored"] = {
    {name = "〰️ Wiggly Stick", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/Stick.lua"))() end},
    {name = "🐍 Cobra Builder", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/Cobra.lua"))() end},
    {name = "🤖 Mech Controller", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/robot.lua"))() end},
    {name = "🌪️ Tornado", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/Tornado.lua"))() end},
    {name = "🔮 Telekinesis", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/TelekinesisByEityum.lua"))() end},
    {name = "📝 Text Blocks", callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/TextManipulate.lua"))() end},
}

-- Load initial tab
switchTab("Destructive")
