-- Eityum Hub - Universal Script Hub (Mobile Friendly) - Cool UI
local player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local sg = Instance.new("ScreenGui", CoreGui)
sg.Name = "EityumHub"
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame", sg)
frame.Size = UDim2.new(0, 220, 0, 520)
frame.Position = UDim2.new(0, 10, 0.5, -260)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

-- Gradient top bar
local topBar = Instance.new("Frame", frame)
topBar.Size = UDim2.new(1, 0, 0, 30)
topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextButton", topBar)
title.Size = UDim2.new(0, 160, 0, 24)
title.Position = UDim2.new(0, 8, 0, 3)
title.Text = "🔥 Eityum Hub"
title.TextColor3 = Color3.fromRGB(255, 180, 30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.AutoButtonColor = false

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(0, 188, 0, 3)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Mobile drag
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
scriptsLabel.Size = UDim2.new(1, -16, 0, 20)
scriptsLabel.Position = UDim2.new(0, 8, 0, 36)
scriptsLabel.Text = "📜 SCRIPTS"
scriptsLabel.TextColor3 = Color3.fromRGB(255, 180, 30)
scriptsLabel.BackgroundTransparency = 1
scriptsLabel.Font = Enum.Font.GothamBold
scriptsLabel.TextSize = 10

local y = 58
local buttonColors = {
    Color3.fromRGB(60, 100, 200),  -- Blue
    Color3.fromRGB(200, 70, 70),   -- Red
    Color3.fromRGB(60, 170, 100),  -- Green
    Color3.fromRGB(180, 120, 50),  -- Orange
    Color3.fromRGB(140, 70, 200),  -- Purple
    Color3.fromRGB(50, 160, 180),  -- Teal
    Color3.fromRGB(200, 140, 50),  -- Gold
    Color3.fromRGB(180, 60, 150),  -- Pink
    Color3.fromRGB(80, 130, 200),  -- Steel Blue
    Color3.fromRGB(50, 180, 100),  -- Emerald
    Color3.fromRGB(200, 100, 100), -- Salmon
}

local colorIndex = 0
local function addButton(name, callback)
    colorIndex = colorIndex + 1
    local col = buttonColors[(colorIndex - 1) % #buttonColors + 1]
    
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -16, 0, 32)
    btn.Position = UDim2.new(0, 8, 0, y)
    btn.Text = "  " .. name
    btn.BackgroundColor3 = col
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.new(col.R * 1.2, col.G * 1.2, col.B * 1.2)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = col
    end)
    
    btn.MouseButton1Click:Connect(callback)
    y = y + 38
end

addButton("🤖 Mech Controller", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/robot.lua"))()
end)

addButton("🐍 Cobra Builder", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/Cobra.lua"))()
end)

addButton("〰️ Wiggly Stick", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/Stick.lua"))()
end)

addButton("🌪️ Tornado", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/Tornado.lua"))()
end)

addButton("🧱 Block Spawner", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/BlockSpawner.lua"))()
end)

addButton("📝 Text Blocks", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/TextManipulate.lua"))()
end)

addButton("🔮 Telekinesis", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/TelekinesisByEityum.lua"))()
end)

addButton("🔊 Sound Spammer", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/Sound.lua"))()
end)

addButton("🔧 F3X", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/F3X%20abuse.lua"))()
end)

addButton("😊 SmileyHub", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/eityum/yeayeayeyaeyayeayeyayeayeyaey/main/scripts/SmileyHub.lua"))()
end)

addButton("♾️ Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

-- Credits section
local creditLabel = Instance.new("TextLabel", frame)
creditLabel.Size = UDim2.new(1, -16, 0, 20)
creditLabel.Position = UDim2.new(0, 8, 0, y + 6)
creditLabel.Text = "💛 CREDITS"
creditLabel.TextColor3 = Color3.fromRGB(255, 180, 30)
creditLabel.BackgroundTransparency = 1
creditLabel.Font = Enum.Font.GothamBold
creditLabel.TextSize = 11
y = y + 28

local credits = {
    {name = "Eityum", desc = "Creator & Developer", color = Color3.fromRGB(255, 200, 50)},
    {name = "Claude", desc = "Smiley Hub Original", color = Color3.fromRGB(200, 150, 255)},
    {name = "DeepSeek", desc = "Mech, Cobra, Stick, Tornado", color = Color3.fromRGB(100, 200, 255)},
    {name = "EdgeIY", desc = "Infinite Yield", color = Color3.fromRGB(255, 100, 100)},
}

for _, credit in pairs(credits) do
    local creditFrame = Instance.new("Frame", frame)
    creditFrame.Size = UDim2.new(1, -16, 0, 36)
    creditFrame.Position = UDim2.new(0, 8, 0, y)
    creditFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    creditFrame.BorderSizePixel = 0
    Instance.new("UICorner", creditFrame).CornerRadius = UDim.new(0, 5)
    
    local dot = Instance.new("Frame", creditFrame)
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 8, 0, 15)
    dot.BackgroundColor3 = credit.color
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    
    local nameLabel = Instance.new("TextLabel", creditFrame)
    nameLabel.Size = UDim2.new(1, -20, 0, 18)
    nameLabel.Position = UDim2.new(0, 20, 0, 2)
    nameLabel.Text = credit.name
    nameLabel.TextColor3 = credit.color
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local descLabel = Instance.new("TextLabel", creditFrame)
    descLabel.Size = UDim2.new(1, -20, 0, 14)
    descLabel.Position = UDim2.new(0, 20, 0, 18)
    descLabel.Text = credit.desc
    descLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
    descLabel.BackgroundTransparency = 1
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 9
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    y = y + 40
end

frame.Size = UDim2.new(0, 220, 0, y + 10)
