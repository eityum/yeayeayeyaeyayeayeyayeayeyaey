-- Eityum Hub - Universal Script Hub (Mobile Friendly) - Cool UI + Wand + Minimize
local player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "EityumHub"
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 230, 0, 540)
frame.Position = UDim2.new(0, 10, 0.5, -270)
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

-- Drag handle above the minimized button
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

-- Drag for minimized container
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

-- Minimize button
local minimizeBtn = Instance.new("TextButton", topBar)
minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
minimizeBtn.Position = UDim2.new(0, 166, 0, 3)
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
closeBtn.Position = UDim2.new(0, 196, 0, 3)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 45, 45)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Mobile drag for frame
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

-- Scripts section
local scriptsLabel = Instance.new("TextLabel", frame)
scriptsLabel.Size = UDim2.new(1, -16, 0, 22)
scriptsLabel.Position = UDim2.new(0, 10, 0, 38)
scriptsLabel.Text = "📜 SCRIPTS"
scriptsLabel.TextColor3 = Color3.fromRGB(255, 170, 20)
scriptsLabel.BackgroundTransparency = 1
scriptsLabel.Font = Enum.Font.GothamBold
scriptsLabel.TextSize = 10

local y = 62
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
local function addButton(name, callback)
    colorIndex = colorIndex + 1
    local col = buttonColors[(colorIndex - 1) % #buttonColors + 1]
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -16, 0, 34)
    btn.Position = UDim2.new(0, 8, 0, y)
    btn.Text = "  " .. name
    btn.BackgroundColor3 = col
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
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
    y = y + 40
end

addButton("🤖 Mech Controller", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/robot.lua"))()
end)

addButton("🐍 Cobra Builder", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/Cobra.lua"))()
end)

addButton("〰️ Wiggly Stick", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/Stick.lua"))()
end)

addButton("🌪️ Tornado", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/Tornado.lua"))()
end)

addButton("🧱 Block Spawner", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/BlockSpawner.lua"))()
end)

addButton("📝 Text Blocks", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/TextManipulate.lua"))()
end)

addButton("🔮 Telekinesis", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/TelekinesisByEityum.lua"))()
end)

addButton("🔊 Sound Spammer", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/Sound.lua"))()
end)

addButton("🪄 WorldEdit Wand", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/Wand.lua"))()
end)

addButton("🔧 F3X", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/F3X%20abuse.lua"))()
end)

addButton("😊 SmileyHub", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/refs/heads/main/scripts/SmileyHub.lua"))()
end)

addButton("♾️ Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

-- Credits section
local creditLabel = Instance.new("TextLabel", frame)
creditLabel.Size = UDim2.new(1, -16, 0, 22)
creditLabel.Position = UDim2.new(0, 10, 0, y + 6)
creditLabel.Text = "💛 CREDITS"
creditLabel.TextColor3 = Color3.fromRGB(255, 170, 20)
creditLabel.BackgroundTransparency = 1
creditLabel.Font = Enum.Font.GothamBold
creditLabel.TextSize = 11
y = y + 30

local credits = {
    {name = "Eityum", desc = "Creator & Developer", color = Color3.fromRGB(255, 200, 50)},
    {name = "Claude", desc = "Smiley Hub Original", color = Color3.fromRGB(200, 150, 255)},
    {name = "DeepSeek", desc = "Mech, Cobra, Stick, Tornado", color = Color3.fromRGB(100, 200, 255)},
    {name = "EdgeIY", desc = "Infinite Yield", color = Color3.fromRGB(255, 100, 100)},
}

for _, credit in pairs(credits) do
    local creditFrame = Instance.new("Frame", frame)
    creditFrame.Size = UDim2.new(1, -16, 0, 38)
    creditFrame.Position = UDim2.new(0, 8, 0, y)
    creditFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    creditFrame.BorderSizePixel = 0
    Instance.new("UICorner", creditFrame).CornerRadius = UDim.new(0, 6)
    
    local dot = Instance.new("Frame", creditFrame)
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 10, 0, 15)
    dot.BackgroundColor3 = credit.color
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local nameLabel = Instance.new("TextLabel", creditFrame)
    nameLabel.Size = UDim2.new(1, -24, 0, 18)
    nameLabel.Position = UDim2.new(0, 24, 0, 3)
    nameLabel.Text = credit.name
    nameLabel.TextColor3 = credit.color
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local descLabel = Instance.new("TextLabel", creditFrame)
    descLabel.Size = UDim2.new(1, -24, 0, 14)
    descLabel.Position = UDim2.new(0, 24, 0, 19)
    descLabel.Text = credit.desc
    descLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 9
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    y = y + 44
end

frame.Size = UDim2.new(0, 230, 0, y + 12)
