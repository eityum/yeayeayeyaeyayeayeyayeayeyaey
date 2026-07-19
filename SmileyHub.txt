-- ============================================================
-- 😊 Smiley Hub v3.1 - NO SHORTENERS VERSION
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportSvc = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")
local lp = Players.LocalPlayer

local function getChar()
    return lp.Character
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ============================================================
-- CONFIG
-- ============================================================
local CFG_FILE = "smiley_hub_v3.json"
local cfg = {
    selectedAssetId   = 56450668,
    selectedAssetGuid = "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}",
    shapeSize         = 10,
    shapeThickness    = 1,
    orbitRadius       = 10,
    rainbowSpeed      = 1,
    flingSpeed        = 1000,
    hitboxSize        = 10,
    walkSpeed         = 16,
    jumpPower         = 50,
    autoClickSpeed    = 5,
    reachSize         = 10,
    lungeCooldown     = 0.01,
    spawnDelay        = 0.001,
}

local function saveCfg()
    pcall(function()
        if isfile and isfile(CFG_FILE) then
            local ok, existing = pcall(function()
                return HttpService:JSONDecode(readfile(CFG_FILE))
            end)
            if ok and existing then
                for k, v in pairs(cfg) do
                    existing[k] = v
                end
                writefile(CFG_FILE, HttpService:JSONEncode(existing))
                return
            end
        end
        writefile(CFG_FILE, HttpService:JSONEncode(cfg))
    end)
end

local function loadCfg()
    pcall(function()
        if isfile and isfile(CFG_FILE) then
            local ok, data = pcall(function()
                return HttpService:JSONDecode(readfile(CFG_FILE))
            end)
            if ok and data then
                for k, v in pairs(data) do
                    cfg[k] = v
                end
            end
        end
    end)
end

loadCfg()

-- ============================================================
-- GUI ROOT
-- ============================================================
-- kill any existing instance of the hub before creating a new one
local existingGui = nil
pcall(function()
    local coreGui = game:GetService("CoreGui")
    existingGui = coreGui:FindFirstChild("SmileyHubV3")
end)
if not existingGui then
    pcall(function()
        existingGui = (gethui and gethui()) and (gethui()):FindFirstChild("SmileyHubV3")
    end)
end
if existingGui then
    existingGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "SmileyHubV3"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local notifHolder = Instance.new("Frame")
notifHolder.Size = UDim2.new(0, 260, 0, 0)
notifHolder.Position = UDim2.new(1, -270, 1, -10)
notifHolder.BackgroundTransparency = 1
notifHolder.AnchorPoint = Vector2.new(0, 1)
notifHolder.Parent = gui

local nLayout = Instance.new("UIListLayout")
nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
nLayout.Padding = UDim.new(0, 4)
nLayout.Parent = notifHolder
nLayout.Changed:Connect(function()
    notifHolder.Size = UDim2.new(0, 260, 0, nLayout.AbsoluteContentSize.Y + 8)
end)

local function notify(msg, col)
    col = col or Color3.fromRGB(180, 140, 30)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 36)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    f.BorderSizePixel = 0
    f.Parent = notifHolder
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = f
    local stroke = Instance.new("UIStroke")
    stroke.Color = col
    stroke.Thickness = 1
    stroke.Parent = f
    local lb = Instance.new("TextLabel")
    lb.Size = UDim2.new(1, -10, 1, 0)
    lb.Position = UDim2.new(0, 6, 0, 0)
    lb.BackgroundTransparency = 1
    lb.Text = msg
    lb.Font = Enum.Font.GothamBold
    lb.TextSize = 11
    lb.TextColor3 = Color3.new(1, 1, 1)
    lb.TextXAlignment = Enum.TextXAlignment.Left
    lb.TextWrapped = true
    lb.Parent = f
    task.delay(3, function()
        TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        task.delay(0.35, function()
            pcall(function()
                f:Destroy()
            end)
        end)
    end)
end

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 600, 0, 420)
main.Position = UDim2.new(0.5, -300, 0.5, -210)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(180, 140, 30)
mainStroke.Thickness = 1.5
mainStroke.Parent = main

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 155, 1, 0)
sidebar.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = sidebar

local sbFill = Instance.new("Frame")
sbFill.Size = UDim2.new(0, 8, 1, 0)
sbFill.Position = UDim2.new(1, -8, 0, 0)
sbFill.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
sbFill.BorderSizePixel = 0
sbFill.Parent = sidebar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 0, 24)
titleLabel.Position = UDim2.new(0, 10, 0, 6)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "😊 Smiley Hub"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.TextColor3 = Color3.fromRGB(220, 175, 30)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = sidebar

local verLabel = Instance.new("TextLabel")
verLabel.Size = UDim2.new(1, -10, 0, 12)
verLabel.Position = UDim2.new(0, 10, 0, 30)
verLabel.BackgroundTransparency = 1
verLabel.Text = "v3.1  |  RShift = hide"
verLabel.Font = Enum.Font.Gotham
verLabel.TextSize = 9
verLabel.TextColor3 = Color3.fromRGB(90, 90, 110)
verLabel.TextXAlignment = Enum.TextXAlignment.Left
verLabel.Parent = sidebar

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.85, 0, 0, 1)
divider.Position = UDim2.new(0.075, 0, 0, 45)
divider.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
divider.BackgroundTransparency = 0.6
divider.BorderSizePixel = 0
divider.Parent = sidebar

local tabScrollFrame = Instance.new("ScrollingFrame")
tabScrollFrame.Position = UDim2.new(0, 3, 0, 48)
tabScrollFrame.Size = UDim2.new(1, -6, 1, -50)
tabScrollFrame.BackgroundTransparency = 1
tabScrollFrame.BorderSizePixel = 0
tabScrollFrame.ScrollBarThickness = 3
tabScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(180, 140, 30)
tabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
tabScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
tabScrollFrame.Parent = sidebar

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabListLayout.Padding = UDim.new(0, 3)
tabListLayout.Parent = tabScrollFrame
tabListLayout.Changed:Connect(function()
    tabScrollFrame.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 6)
end)

-- CONTENT FRAME
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -160, 1, -10)
contentFrame.Position = UDim2.new(0, 158, 0, 5)
contentFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
contentFrame.BorderSizePixel = 0
contentFrame.ClipsDescendants = true
contentFrame.Parent = main

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 6)
contentCorner.Parent = contentFrame

-- CLOSE BUTTON
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 10
closeBtn.Parent = main

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 5)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    pcall(function() tkRenderConn:Disconnect() end)
    gui:Destroy()
end)

-- MINIMIZE BUTTON
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -54, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 14
minBtn.TextColor3 = Color3.new(1, 1, 1)
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 10
minBtn.Parent = main

local minBtnCorner = Instance.new("UICorner")
minBtnCorner.CornerRadius = UDim.new(0, 5)
minBtnCorner.Parent = minBtn

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentFrame.Visible = not minimized
    if minimized then
        main.Size = UDim2.new(0, 158, 0, 420)
    else
        main.Size = UDim2.new(0, 600, 0, 420)
    end
end)

UIS.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)

-- ============================================================
-- TAB SYSTEM
-- ============================================================
local allTabs = {}

local function selectTab(tabData)
    for _, tt in pairs(allTabs) do
        tt.page.Visible = false
        tt.btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        tt.btn.TextColor3 = Color3.fromRGB(180, 180, 180)
        tt.btn.Font = Enum.Font.Gotham
    end
    tabData.page.Visible = true
    tabData.btn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
    tabData.btn.TextColor3 = Color3.fromRGB(15, 15, 15)
    tabData.btn.Font = Enum.Font.GothamBold
end

local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 30)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = tabScrollFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    local btnPadding = Instance.new("UIPadding")
    btnPadding.PaddingLeft = UDim.new(0, 8)
    btnPadding.Parent = btn

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent = contentFrame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 140, 30)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.Parent = page

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = scroll

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll
    layout.Changed:Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
    end)

    local tabData = {btn = btn, page = page, scroll = scroll, layout = layout}
    table.insert(allTabs, tabData)

    btn.MouseButton1Click:Connect(function()
        selectTab(tabData)
    end)

    return tabData
end

-- ============================================================
-- UI HELPERS
-- ============================================================
local function addSection(s, text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextColor3 = Color3.fromRGB(180, 140, 30)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BorderSizePixel = 0
    l.Parent = s
    return l
end

local function addButton(s, label, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = color or Color3.fromRGB(40, 100, 180)
    btn.Text = label
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    btn.Parent = s

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function addToggle(s, label, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    row.BorderSizePixel = 0
    row.Parent = s

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.Parent = row

    local togBtn = Instance.new("TextButton")
    togBtn.Size = UDim2.new(0, 44, 0, 22)
    togBtn.Position = UDim2.new(1, -52, 0.5, -11)
    togBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    togBtn.Text = "OFF"
    togBtn.Font = Enum.Font.GothamBold
    togBtn.TextSize = 11
    togBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
    togBtn.BorderSizePixel = 0
    togBtn.Parent = row

    local togCorner = Instance.new("UICorner")
    togCorner.CornerRadius = UDim.new(0, 5)
    togCorner.Parent = togBtn

    local isOn = false

    local function setState(state)
        isOn = state
        if isOn then
            togBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
            togBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
            togBtn.Text = "ON"
        else
            togBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
            togBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
            togBtn.Text = "OFF"
        end
    end

    togBtn.MouseButton1Click:Connect(function()
        setState(not isOn)
        callback(isOn)
    end)

    return row, setState
end

local function addSlider(s, label, minVal, maxVal, defaultVal, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 52)
    row.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    row.BorderSizePixel = 0
    row.Parent = s

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 6)
    rowCorner.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 24)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label .. ": " .. defaultVal
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 8)
    track.Position = UDim2.new(0, 10, 0, 36)
    track.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    track.BorderSizePixel = 0
    track.Parent = row

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(220, 175, 30)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local sliderConn = nil

    knob.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    sliderConn = RunService.Heartbeat:Connect(function()
        if not row or not row.Parent then
            sliderConn:Disconnect()
            sliderConn = nil
            return
        end
        if not dragging then return end
        local mx = UIS:GetMouseLocation().X
        local pct = math.clamp((mx - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor((minVal + (maxVal - minVal) * pct) * 10000 + 0.5) / 10000
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, -8, 0.5, -8)
        lbl.Text = label .. ": " .. val
        callback(val)
    end)

    return row
end

local function makePlayerList(parentFrame, btnLabel, btnColor, actionFn)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 115)
    container.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    container.BorderSizePixel = 0
    container.Parent = parentFrame

    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 6)
    containerCorner.Parent = container

    local innerScroll = Instance.new("ScrollingFrame")
    innerScroll.Size = UDim2.new(1, -8, 1, -8)
    innerScroll.Position = UDim2.new(0, 4, 0, 4)
    innerScroll.BackgroundTransparency = 1
    innerScroll.BorderSizePixel = 0
    innerScroll.ScrollBarThickness = 3
    innerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    innerScroll.Parent = container

    local innerLayout = Instance.new("UIListLayout")
    innerLayout.Padding = UDim.new(0, 3)
    innerLayout.Parent = innerScroll
    innerLayout.Changed:Connect(function()
        innerScroll.CanvasSize = UDim2.new(0, 0, 0, innerLayout.AbsoluteContentSize.Y + 6)
    end)

    local loopConns = {}

    local function refresh()
        for _, v in pairs(innerScroll:GetChildren()) do
            if v:IsA("Frame") then
                v:Destroy()
            end
        end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= lp then
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, 28)
                row.BackgroundTransparency = 1
                row.Parent = innerScroll

                local rl = Instance.new("UIListLayout")
                rl.FillDirection = Enum.FillDirection.Horizontal
                rl.Padding = UDim.new(0, 3)
                rl.Parent = row

                local ab = Instance.new("TextButton")
                ab.Size = UDim2.new(0.55, 0, 1, 0)
                ab.BackgroundColor3 = btnColor
                ab.Text = btnLabel .. " " .. plr.Name
                ab.Font = Enum.Font.GothamBold
                ab.TextSize = 10
                ab.TextColor3 = Color3.new(1, 1, 1)
                ab.BorderSizePixel = 0
                ab.AutoButtonColor = true
                ab.Parent = row

                local abCorner = Instance.new("UICorner")
                abCorner.CornerRadius = UDim.new(0, 5)
                abCorner.Parent = ab

                ab.MouseButton1Click:Connect(function()
                    actionFn(plr)
                end)

                local lb2 = Instance.new("TextButton")
                lb2.Size = UDim2.new(0.42, 0, 1, 0)
                lb2.BackgroundColor3 = Color3.fromRGB(60, 20, 80)
                lb2.Text = "🔁"
                lb2.Font = Enum.Font.GothamBold
                lb2.TextSize = 11
                lb2.TextColor3 = Color3.new(1, 1, 1)
                lb2.BorderSizePixel = 0
                lb2.AutoButtonColor = true
                lb2.Parent = row

                local lb2Corner = Instance.new("UICorner")
                lb2Corner.CornerRadius = UDim.new(0, 5)
                lb2Corner.Parent = lb2

                local looping = false
                lb2.MouseButton1Click:Connect(function()
                    looping = not looping
                    if looping then
                        lb2.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
                        lb2.TextColor3 = Color3.fromRGB(15, 15, 15)
                        lb2.Text = "⏹"
                        if loopConns[plr.Name] then
                            loopConns[plr.Name]:Disconnect()
                        end
                        loopConns[plr.Name] = RunService.Heartbeat:Connect(function()
                            if not looping then
                                loopConns[plr.Name]:Disconnect()
                                return
                            end
                            actionFn(plr)
                            task.wait(0.5)
                        end)
                    else
                        lb2.BackgroundColor3 = Color3.fromRGB(60, 20, 80)
                        lb2.TextColor3 = Color3.new(1, 1, 1)
                        lb2.Text = "🔁"
                        if loopConns[plr.Name] then
                            loopConns[plr.Name]:Disconnect()
                            loopConns[plr.Name] = nil
                        end
                    end
                end)
            end
        end
    end

    return refresh
end

-- ============================================================
-- CREATE ALL TABS
-- ============================================================
local ScriptsTab  = createTab("📜 Scripts",     1)
local TeleportTab = createTab("📍 Teleport",    2)
local PlayerTab   = createTab("🧍 Player",      3)
local WorldTab    = createTab("🌐 World",        4)
local CombatTab   = createTab("⚔️ Combat",       5)
local BlocksTab   = createTab("🧱 Drop Blocks",  6)
local ExploitTab  = createTab("🔧 Exploit",      7)
local KeybindsTab = createTab("🎮 Keybinds",     8)
local MassiveTab  = createTab("💀 Massive",      9)
local ConfigTab   = createTab("💾 Config",       10)

-- ============================================================
-- SHARED REMOTE + ASSET
-- ============================================================
local BRICK_FREE = 56450668

local selectedAsset = {
    id   = cfg.selectedAssetId,
    guid = cfg.selectedAssetGuid,
}

local function universalStamp(cf, connArg, overrideId, overrideGuid)
    local id   = overrideId   or selectedAsset.id
    local guid = overrideGuid or selectedAsset.guid
    if (guid == nil or guid == "") and id == BRICK_FREE then
        guid = "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
    end
    local conn = connArg or {}
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.StampAsset:InvokeServer(id, cf, guid, conn, 0)
    end)
    pcall(function()
        local r = game:GetService("ReplicatedStorage"):FindFirstChild("Stamp")
        if r then
            r:FireServer(id, cf)
        end
    end)
end

local function spawnBlock(cf, connArg)
    universalStamp(cf, connArg)
end

local function getBaseplate()
    local hrp = getHRP()
    if not hrp then return nil end
    local closest = nil
    local closestDist = math.huge
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:IsDescendantOf(lp.Character or Instance.new("Folder")) then
            local n = v.Name:lower()
            if n:find("base") or n:find("plate") or n:find("plot") or n:find("floor") then
                local d = (v.Position - hrp.Position).Magnitude
                if d < closestDist then
                    closestDist = d
                    closest = v
                end
            end
        end
    end
    return closest
end

-- ============================================================
-- TELEKINESIS ENGINE
-- ============================================================
local TK = {}
TK.heldParts = {}

function TK.makeBP()
    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bp.P = bp.P * 3
    return bp
end

function TK.release()
    for _, e in pairs(TK.heldParts) do
        pcall(function()
            e.bp:Destroy()
        end)
    end
    TK.heldParts = {}
end

local tkRenderConn = RunService.RenderStepped:Connect(function()
    if not gui or not gui.Parent then
        tkRenderConn:Disconnect()
        return
    end
    if #TK.heldParts == 0 then return end
    local cam = workspace.CurrentCamera
    local hrp = getHRP()
    if not hrp then return end
    for _, e in pairs(TK.heldParts) do
        if e.part and e.part.Parent and e.bp and e.bp.Parent then
            e.bp.position = hrp.Position + cam.CFrame.LookVector * e.dist
        end
    end
end)

-- ============================================================
-- SCRIPTS TAB
-- ============================================================
do
    local s = ScriptsTab.scroll

    addSection(s, "── External Scripts ──")

    addButton(s, "▶ Load MaxNo1 Script", Color3.fromRGB(50, 120, 50), function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/linhmcfake/Script/refs/heads/main/MaxNo1.lua"))()
        end)
        notify("▶ MaxNo1 loaded!")
    end)

    addSection(s, "── Stamp Spammer ──")

    local stampSpamId = 56450668
    local stampSpamming = false
    local stampSpamDelay = 0.1

    local ssRow = Instance.new("Frame")
    ssRow.Size = UDim2.new(1, 0, 0, 36)
    ssRow.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    ssRow.BorderSizePixel = 0
    ssRow.Parent = s
    local ssRowCorner = Instance.new("UICorner")
    ssRowCorner.CornerRadius = UDim.new(0, 6)
    ssRowCorner.Parent = ssRow

    local ssInput = Instance.new("TextBox")
    ssInput.Size = UDim2.new(0.68, 0, 1, -8)
    ssInput.Position = UDim2.new(0, 6, 0, 4)
    ssInput.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    ssInput.PlaceholderText = "Stamp ID..."
    ssInput.Text = tostring(stampSpamId)
    ssInput.Font = Enum.Font.Gotham
    ssInput.TextSize = 12
    ssInput.TextColor3 = Color3.new(1, 1, 1)
    ssInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    ssInput.BorderSizePixel = 0
    ssInput.ClearTextOnFocus = false
    ssInput.Parent = ssRow
    local ssInputCorner = Instance.new("UICorner")
    ssInputCorner.CornerRadius = UDim.new(0, 5)
    ssInputCorner.Parent = ssInput

    local ssSetBtn = Instance.new("TextButton")
    ssSetBtn.Size = UDim2.new(0.28, 0, 1, -8)
    ssSetBtn.Position = UDim2.new(0.7, 2, 0, 4)
    ssSetBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
    ssSetBtn.Text = "Set ID"
    ssSetBtn.Font = Enum.Font.GothamBold
    ssSetBtn.TextSize = 12
    ssSetBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
    ssSetBtn.BorderSizePixel = 0
    ssSetBtn.AutoButtonColor = true
    ssSetBtn.Parent = ssRow
    local ssSetBtnCorner = Instance.new("UICorner")
    ssSetBtnCorner.CornerRadius = UDim.new(0, 5)
    ssSetBtnCorner.Parent = ssSetBtn

    ssSetBtn.MouseButton1Click:Connect(function()
        local id = tonumber(ssInput.Text)
        if id then
            stampSpamId = id
            notify("Stamp ID: " .. id)
        end
    end)

    addSlider(s, "Stamp Speed (sec delay)", 0.01, 1, 0.1, function(v)
        stampSpamDelay = v
    end)

    addToggle(s, "💠 Stamp Spam at Mouse", function(on)
        stampSpamming = on
        if on then
            task.spawn(function()
                while stampSpamming do
                    local mouse = lp:GetMouse()
                    universalStamp(CFrame.new(mouse.Hit.Position), {}, stampSpamId, "")
                    task.wait(stampSpamDelay)
                end
            end)
        end
    end)
end

-- ============================================================
-- TELEPORT TAB
-- ============================================================
do
    local s = TeleportTab.scroll

    addSection(s, "── Teleport ──")

    addButton(s, "🖱 Click To Teleport", Color3.fromRGB(40, 90, 160), function()
        local mouse = lp:GetMouse()
        local conn
        conn = mouse.Button1Down:Connect(function()
            local hrp = getHRP()
            if hrp and mouse.Target then
                hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
            conn:Disconnect()
        end)
        notify("Click anywhere to teleport!")
    end)

    addSection(s, "── Teleport to Player ──")

    local function refreshPlayerTPs()
        for _, v in pairs(s:GetChildren()) do
            if v:IsA("TextButton") and v.Name:sub(1, 3) == "TP_" then
                v:Destroy()
            end
        end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= lp then
                local b = addButton(s, "➡ " .. plr.Name, Color3.fromRGB(45, 75, 120), function()
                    local hrp = getHRP()
                    local tc = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and tc then
                        hrp.CFrame = tc.CFrame + Vector3.new(0, 3, 0)
                    end
                end)
                b.Name = "TP_" .. plr.Name
            end
        end
    end

    addButton(s, "↻ Refresh Players", Color3.fromRGB(35, 65, 35), refreshPlayerTPs)
    refreshPlayerTPs()

    addSection(s, "── Waypoints ──")

    local waypointCount = 0
    local waypoints = {}

    addButton(s, "📌 Save Waypoint Here", Color3.fromRGB(60, 55, 120), function()
        local hrp = getHRP()
        if not hrp then return end
        waypointCount = waypointCount + 1
        local pos = hrp.Position
        waypoints[waypointCount] = pos
        local n = waypointCount
        addButton(s, "WP " .. n .. " (" .. math.floor(pos.X) .. "," .. math.floor(pos.Y) .. "," .. math.floor(pos.Z) .. ")", Color3.fromRGB(35, 70, 80), function()
            local h2 = getHRP()
            if h2 then
                h2.CFrame = CFrame.new(waypoints[n] + Vector3.new(0, 3, 0))
            end
        end)
        notify("📌 Waypoint " .. n .. " saved")
    end)
end

-- ============================================================
-- PLAYER TAB
-- ============================================================
do
    local s = PlayerTab.scroll

    addSection(s, "── Movement ──")

    addSlider(s, "Walk Speed", 8, 500, cfg.walkSpeed, function(v)
        cfg.walkSpeed = v
        local h = getHum()
        if h then
            h.WalkSpeed = v
        end
    end)

    addSlider(s, "Jump Power", 7, 500, cfg.jumpPower, function(v)
        cfg.jumpPower = v
        local h = getHum()
        if h then
            h.JumpPower = v
        end
    end)

    addSection(s, "── Abilities ──")

    local ijConn = nil
    addToggle(s, "Infinite Jump", function(on)
        if ijConn then
            ijConn:Disconnect()
            ijConn = nil
        end
        if on then
            ijConn = UIS.JumpRequest:Connect(function()
                local h = getHum()
                if h then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)

    local flyConn = nil
    local flyBV = nil
    local flyBG = nil

    addToggle(s, "Fly (WASD + Space/Ctrl)", function(on)
        if flyConn then
            flyConn:Disconnect()
            flyConn = nil
        end
        if flyBV and flyBV.Parent then
            flyBV:Destroy()
        end
        if flyBG and flyBG.Parent then
            flyBG:Destroy()
        end
        flyBV = nil
        flyBG = nil
        local h = getHum()
        if on then
            local hrp = getHRP()
            if not hrp then return end
            if h then
                h.PlatformStand = true
            end
            flyBV = Instance.new("BodyVelocity")
            flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyBV.Velocity = Vector3.zero
            flyBV.Parent = hrp
            flyBG = Instance.new("BodyGyro")
            flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
            flyBG.P = 9000
            flyBG.Parent = hrp
            flyConn = RunService.Heartbeat:Connect(function()
                local hrp2 = getHRP()
                if not hrp2 or not flyBV or not flyBV.Parent then return end
                local cam = workspace.CurrentCamera
                local dir = Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
                if dir.Magnitude > 0 then
                    flyBV.Velocity = dir.Unit * 60
                else
                    flyBV.Velocity = Vector3.zero
                end
                flyBG.CFrame = cam.CFrame
            end)
        else
            if h then
                h.PlatformStand = false
            end
        end
    end)

    local ncConn = nil
    addToggle(s, "NoClip", function(on)
        if ncConn then
            ncConn:Disconnect()
            ncConn = nil
        end
        if on then
            ncConn = RunService.Stepped:Connect(function()
                local c = getChar()
                if c then
                    for _, p in pairs(c:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
                    end
                end
            end)
        end
    end)

    addToggle(s, "Invisible", function(on)
        local c = getChar()
        if c then
            for _, p in pairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    if on then
                        p.LocalTransparencyModifier = 1
                    else
                        p.LocalTransparencyModifier = 0
                    end
                end
            end
        end
    end)

    addToggle(s, "Anti AFK", function(on)
        if on then
            local vu = game:GetService("VirtualUser")
            RunService.Heartbeat:Connect(function()
                if not on then return end
                pcall(function()
                    vu:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
                    vu:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
                end)
            end)
        end
    end)

    addSection(s, "── Actions ──")

    addButton(s, "💀 Kill Self", Color3.fromRGB(140, 30, 30), function()
        local h = getHum()
        if h then
            h.Health = 0
        end
    end)

    addButton(s, "🔄 Respawn", Color3.fromRGB(60, 60, 80), function()
        lp:LoadCharacter()
    end)

    addSection(s, "── Anti Spike ──")

    local spikeConns = {}
    addToggle(s, "🛡️ Anti Spike", function(on)
        for _, c in pairs(spikeConns) do
            c:Disconnect()
        end
        spikeConns = {}
        if on then
            local function hookChar(char)
                if not char then return end
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        local c = part.Touched:Connect(function(hit)
                            local name = hit.Name:lower()
                            if name:find("spike") or name:find("trap") or name:find("kill") or name:find("damage") or name:find("hurt") then
                                local hrp = getHRP()
                                if hrp then
                                    hrp.CFrame = hrp.CFrame * CFrame.new(0, 10, 0)
                                end
                            end
                        end)
                        table.insert(spikeConns, c)
                    end
                end
            end
            hookChar(getChar())
            table.insert(spikeConns, lp.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                hookChar(char)
            end))
        end
    end)
end

-- ============================================================
-- WORLD TAB
-- ============================================================
do
    local s = WorldTab.scroll

    addSection(s, "── Server ──")

    addButton(s, "🔀 Server Hop", Color3.fromRGB(35, 75, 140), function()
        local ok, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if ok and result and result.data then
            for _, srv in pairs(result.data) do
                if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                    TeleportSvc:TeleportToPlaceInstance(game.PlaceId, srv.id, lp)
                    return
                end
            end
        end
        notify("No server found to hop to")
    end)

    addButton(s, "🔁 Reconnect", Color3.fromRGB(35, 75, 140), function()
        TeleportSvc:Teleport(game.PlaceId, lp)
    end)

    addSection(s, "── World Settings ──")

    addSlider(s, "Time of Day", 0, 24, 12, function(v)
        game:GetService("Lighting").TimeOfDay = v .. ":00:00"
    end)

    addSlider(s, "Gravity", 0, 800, 196, function(v)
        workspace.Gravity = v
    end)

    addToggle(s, "No Fog", function(on)
        if on then
            game:GetService("Lighting").FogEnd = 1e9
        else
            game:GetService("Lighting").FogEnd = 1000
        end
    end)

    addToggle(s, "Fullbright", function(on)
        local l = game:GetService("Lighting")
        if on then
            l.Brightness = 10
            l.GlobalShadows = false
            l.Ambient = Color3.new(1, 1, 1)
        else
            l.Brightness = 1
            l.GlobalShadows = true
            l.Ambient = Color3.fromRGB(127, 127, 127)
        end
    end)

    addSection(s, "── Gravity Quick Picks ──")

    addButton(s, "🧲 Zero G (10s)", Color3.fromRGB(0, 60, 160), function()
        workspace.Gravity = 0
        task.delay(10, function()
            workspace.Gravity = 196
        end)
        notify("🧲 Zero G for 10s")
    end)

    addButton(s, "🔃 Flip Gravity (8s)", Color3.fromRGB(60, 0, 160), function()
        workspace.Gravity = -196
        task.delay(8, function()
            workspace.Gravity = 196
        end)
        notify("🔃 Gravity flipped!")
    end)

    addButton(s, "💫 Hyper Gravity (8s)", Color3.fromRGB(100, 0, 100), function()
        workspace.Gravity = 1200
        task.delay(8, function()
            workspace.Gravity = 196
        end)
        notify("💫 Hyper gravity!")
    end)

    addSection(s, "── Black Hole ──")

    local bhConn = nil
    local bhPart = nil

    addToggle(s, "🕳️ Black Hole (Sucks Parts)", function(on)
        if bhConn then
            bhConn:Disconnect()
            bhConn = nil
        end
        if bhPart then
            bhPart:Destroy()
            bhPart = nil
        end
        if on then
            local hrp = getHRP()
            if not hrp then return end
            bhPart = Instance.new("Part")
            bhPart.Size = Vector3.new(6, 6, 6)
            bhPart.Shape = Enum.PartType.Ball
            bhPart.BrickColor = BrickColor.new("Really black")
            bhPart.Material = Enum.Material.Neon
            bhPart.Anchored = true
            bhPart.CanCollide = false
            bhPart.CFrame = hrp.CFrame * CFrame.new(0, 0, -10)
            bhPart.Parent = workspace
            bhConn = RunService.Heartbeat:Connect(function()
                local h = getHRP()
                if not h then return end
                bhPart.CFrame = h.CFrame * CFrame.new(0, 0, -10)
                for _, v in next, workspace:GetDescendants() do
                    if v:IsA("Part") and not v.Anchored and v.Parent:FindFirstChild("Humanoid") == nil and v ~= bhPart then
                        local dir = (bhPart.Position - v.Position)
                        local dist = dir.Magnitude
                        if dist < 120 then
                            local bv = v:FindFirstChild("__BH")
                            if not bv then
                                bv = Instance.new("BodyVelocity")
                                bv.Name = "__BH"
                                bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                                bv.Parent = v
                            end
                            bv.Velocity = dir.Unit * math.clamp(200 / (dist + 1) * 60, 10, 300)
                        end
                    end
                end
            end)
        end
    end)

    addSection(s, "── Base Color ──")

    local function setBaseColor(col)
        pcall(function()
            game:GetService("ReplicatedStorage").Remotes.BaseCustomization.UpdateBaseColor:FireServer(col)
        end)
    end

    local colorPresets = {
        {"⬛ Black",  Color3.fromRGB(0, 0, 0)},
        {"⬜ White",  Color3.fromRGB(255, 255, 255)},
        {"🔴 Red",    Color3.fromRGB(255, 0, 0)},
        {"🟠 Orange", Color3.fromRGB(255, 140, 0)},
        {"🟡 Yellow", Color3.fromRGB(255, 255, 0)},
        {"🟢 Green",  Color3.fromRGB(0, 200, 0)},
        {"🔵 Blue",   Color3.fromRGB(0, 100, 255)},
        {"🟣 Purple", Color3.fromRGB(150, 0, 255)},
        {"🩷 Pink",   Color3.fromRGB(255, 100, 180)},
        {"🩵 Cyan",   Color3.fromRGB(0, 220, 255)},
    }

    local cgf = Instance.new("Frame")
    cgf.Size = UDim2.new(1, 0, 0, 0)
    cgf.BackgroundTransparency = 1
    cgf.BorderSizePixel = 0
    cgf.Parent = s

    local cgl = Instance.new("UIListLayout")
    cgl.FillDirection = Enum.FillDirection.Horizontal
    cgl.Wraps = true
    cgl.Padding = UDim.new(0, 3)
    cgl.Parent = cgf
    cgl.Changed:Connect(function()
        cgf.Size = UDim2.new(1, 0, 0, cgl.AbsoluteContentSize.Y + 4)
    end)

    for _, p in pairs(colorPresets) do
        local pb = Instance.new("TextButton")
        pb.Size = UDim2.new(0.48, 0, 0, 32)
        pb.BackgroundColor3 = p[2]
        pb.Text = p[1]
        pb.Font = Enum.Font.GothamBold
        pb.TextSize = 11
        if p[2].R + p[2].G + p[2].B < 1.2 then
            pb.TextColor3 = Color3.new(1, 1, 1)
        else
            pb.TextColor3 = Color3.new(0, 0, 0)
        end
        pb.BorderSizePixel = 0
        pb.AutoButtonColor = true
        pb.Parent = cgf
        local pbCorner = Instance.new("UICorner")
        pbCorner.CornerRadius = UDim.new(0, 5)
        pbCorner.Parent = pb
        pb.MouseButton1Click:Connect(function()
            setBaseColor(p[2])
        end)
    end

    local customR = 255
    local customG = 0
    local customB = 0
    addSection(s, "Custom RGB Color")
    addSlider(s, "Red",   0, 255, 255, function(v) customR = math.floor(v) end)
    addSlider(s, "Green", 0, 255, 0,   function(v) customG = math.floor(v) end)
    addSlider(s, "Blue",  0, 255, 0,   function(v) customB = math.floor(v) end)
    addButton(s, "✅ Apply Custom Color", Color3.fromRGB(40, 120, 40), function()
        setBaseColor(Color3.fromRGB(customR, customG, customB))
    end)
    addButton(s, "🎲 Random Color", Color3.fromRGB(80, 45, 110), function()
        setBaseColor(Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
    end)

    addSection(s, "── Rainbow Effects ──")

    local rainbowConn = nil
    local rainbowSpeed = cfg.rainbowSpeed

    addSlider(s, "Rainbow Speed", 0.1, 100, cfg.rainbowSpeed, function(v)
        rainbowSpeed = v
        cfg.rainbowSpeed = v
    end)

    local pulses = {
        {"🌈 Rainbow",           function(t) return Color3.fromHSV(t % 1, 1, 1) end},
        {"⬛⬜ Black & White",    function(t) local v = (math.sin(t * 4) + 1) / 2; return Color3.new(v, v, v) end},
        {"🔴🔵 Red & Blue",      function(t) local v = (math.sin(t * 4) + 1) / 2; return Color3.new(v, 0, 1 - v) end},
        {"🟢🟣 Green & Purple",  function(t) local v = (math.sin(t * 4) + 1) / 2; return Color3.new(v * 0.6, v, (1 - v) * 0.8) end},
        {"🟡🔴 Gold & Red",      function(t) local v = (math.sin(t * 4) + 1) / 2; return Color3.new(1, v * 0.55, 0) end},
        {"🩷🔵 Pink & Blue",     function(t) local v = (math.sin(t * 4) + 1) / 2; return Color3.new(1 - v * 0.6, v * 0.4, v) end},
        {"🩵⬜ Cyan & White",    function(t) local v = (math.sin(t * 4) + 1) / 2; return Color3.new(v, 1, 1) end},
        {"🟠🟡 Orange & Yellow", function(t) local v = (math.sin(t * 4) + 1) / 2; return Color3.new(1, 0.55 + v * 0.45, 0) end},
        {"🔥 Fire",              function(t) local v = (math.sin(t * 6) + 1) / 2; return Color3.new(1, v * 0.6, 0) end},
        {"🌊 Ocean",             function(t) local v = (math.sin(t * 4) + 1) / 2; return Color3.new(0, v * 0.8, 1) end},
        {"☠️ Toxic",             function(t) local v = (math.sin(t * 4) + 1) / 2; return Color3.new(v * 0.5, v, 0) end},
        {"🌸 Sakura",            function(t) local v = (math.sin(t * 4) + 1) / 2; return Color3.new(1, v * 0.6 + 0.4, v * 0.7 + 0.3) end},
        {"🌌 Galaxy",            function(t) local v = (math.sin(t * 4) + 1) / 2; return Color3.new(v * 0.5, 0, v) end},
        {"⚡ Strobe",            function(t) if math.floor(t * 20) % 2 == 0 then return Color3.new(1, 1, 1) else return Color3.new(0, 0, 0) end end},
    }

    for _, pulse in pairs(pulses) do
        local name = pulse[1]
        local fn = pulse[2]
        addToggle(s, name, function(on)
            if rainbowConn then
                rainbowConn:Disconnect()
                rainbowConn = nil
            end
            if on then
                rainbowConn = RunService.Heartbeat:Connect(function()
                    setBaseColor(fn(tick() * rainbowSpeed))
                    task.wait(0.05)
                end)
            end
        end)
    end

    addToggle(s, "🍬 Candy (fast multi-color)", function(on)
        if rainbowConn then
            rainbowConn:Disconnect()
            rainbowConn = nil
        end
        if on then
            local candy = {
                Color3.fromRGB(255, 100, 150),
                Color3.fromRGB(100, 200, 255),
                Color3.fromRGB(255, 220, 50),
                Color3.fromRGB(150, 255, 120),
                Color3.fromRGB(200, 100, 255),
            }
            local ci = 1
            rainbowConn = RunService.Heartbeat:Connect(function()
                setBaseColor(candy[ci])
                ci = ci % #candy + 1
                task.wait(0.1 / math.max(rainbowSpeed, 0.1))
            end)
        end
    end)

    addSection(s, "── Base Material ──")

    local materials = {
        "SmoothPlastic", "Neon", "Glass", "Metal", "Wood",
        "Grass", "Sand", "Marble", "Granite", "Cobblestone",
        "Brick", "Ice", "DiamondPlate", "Foil", "Fabric",
    }

    for _, mat in pairs(materials) do
        addButton(s, mat, Color3.fromRGB(50, 50, 70), function()
            pcall(function()
                game:GetService("ReplicatedStorage").Remotes.BaseCustomization.UpdateBaseMaterial:FireServer(mat)
            end)
        end)
    end
end

-- ============================================================
-- COMBAT TAB
-- ============================================================
do
    local s = CombatTab.scroll

    addSection(s, "── Hitbox / Fling ──")

    local hitboxConn = nil
    local hitboxOrig = {}

    addSlider(s, "Hitbox Size", 1, 60, cfg.hitboxSize, function(v)
        cfg.hitboxSize = v
    end)

    addToggle(s, "Hitbox Expander", function(on)
        if hitboxConn then
            hitboxConn:Disconnect()
            hitboxConn = nil
        end
        if on then
            hitboxConn = RunService.Heartbeat:Connect(function()
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= lp and plr.Character then
                        local tc = plr.Character:FindFirstChild("HumanoidRootPart")
                        if tc then
                            if not hitboxOrig[plr.Name] then
                                hitboxOrig[plr.Name] = tc.Size
                            end
                            tc.Size = Vector3.new(cfg.hitboxSize, cfg.hitboxSize, cfg.hitboxSize)
                        end
                    end
                end
            end)
        else
            for name, sz in pairs(hitboxOrig) do
                local plr = Players:FindFirstChild(name)
                if plr and plr.Character then
                    local tc = plr.Character:FindFirstChild("HumanoidRootPart")
                    if tc then
                        tc.Size = sz
                    end
                end
            end
            hitboxOrig = {}
        end
    end)

    addSlider(s, "Fling Power", 100, 2000, cfg.flingSpeed, function(v)
        cfg.flingSpeed = v
    end)

    addButton(s, "Fling Nearest", Color3.fromRGB(140, 40, 15), function()
        local hrp = getHRP()
        if not hrp then return end
        local nearest = nil
        local nearDist = math.huge
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local tc = plr.Character:FindFirstChild("HumanoidRootPart")
                if tc then
                    local d = (hrp.Position - tc.Position).Magnitude
                    if d < nearDist then
                        nearDist = d
                        nearest = tc
                    end
                end
            end
        end
        if nearest then
            hrp.CFrame = nearest.CFrame
            local bav = Instance.new("BodyAngularVelocity")
            bav.AngularVelocity = Vector3.new(0, cfg.flingSpeed, 0)
            bav.MaxTorque = Vector3.new(0, cfg.flingSpeed * 100, 0)
            bav.P = 1e5
            bav.Parent = hrp
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(math.random(-1, 1) * 120, 80, math.random(-1, 1) * 120)
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = hrp
            task.delay(0.3, function()
                if bav and bav.Parent then bav:Destroy() end
                if bv and bv.Parent then bv:Destroy() end
            end)
        end
    end)

    local spinConn = nil
    addToggle(s, "Spinbot", function(on)
        if spinConn then
            spinConn:Disconnect()
            spinConn = nil
        end
        if on then
            spinConn = RunService.Heartbeat:Connect(function()
                local hrp = getHRP()
                if not hrp then return end
                local bav = hrp:FindFirstChild("HubSpin")
                if not bav then
                    bav = Instance.new("BodyAngularVelocity")
                    bav.Parent = hrp
                end
                bav.Name = "HubSpin"
                bav.AngularVelocity = Vector3.new(0, 800, 0)
                bav.MaxTorque = Vector3.new(0, 1e6, 0)
                bav.P = 1e5
            end)
        else
            local hrp = getHRP()
            if hrp then
                local b = hrp:FindFirstChild("HubSpin")
                if b then b:Destroy() end
            end
        end
    end)

    addSection(s, "── ESP ──")

    local espHighlights = {}
    addToggle(s, "Player ESP", function(on)
        for _, h in pairs(espHighlights) do
            if h and h.Parent then h:Destroy() end
        end
        espHighlights = {}
        if on then
            local function makeESP(plr)
                if plr == lp or not plr.Character then return end
                local h = Instance.new("Highlight")
                h.FillColor = Color3.fromRGB(255, 50, 50)
                h.OutlineColor = Color3.new(1, 1, 1)
                h.FillTransparency = 0.5
                h.Parent = plr.Character
                espHighlights[plr.Name] = h
            end
            for _, plr in pairs(Players:GetPlayers()) do
                makeESP(plr)
            end
            Players.PlayerAdded:Connect(function(p)
                p.CharacterAdded:Connect(function()
                    task.wait(0.5)
                    makeESP(p)
                end)
            end)
        end
    end)

    addSection(s, "── Kill Aura ──")

    local kaSize = Vector3.new(10, 10, 10)
    local kaDeathCheck = true

    addSlider(s, "Kill Aura Size", 1, 60, 10, function(v)
        kaSize = Vector3.new(v, v, v)
        if getgenv().configs then
            getgenv().configs.Size = kaSize
        end
    end)

    addToggle(s, "Only Attack Alive Players", function(on)
        kaDeathCheck = on
        if getgenv().configs then
            getgenv().configs.DeathCheck = on
        end
    end)

    addToggle(s, "⚔️ Kill Aura (need sword)", function(on)
        local connections = getgenv().configs and getgenv().configs.connections
        if connections then
            local Disable = getgenv().configs.Disable
            for i, v in pairs(connections) do
                v:Disconnect()
            end
            Disable:Fire()
            Disable:Destroy()
            table.clear(getgenv().configs)
        end
        if not on then return end

        local Disable = Instance.new("BindableEvent")
        getgenv().configs = {connections = {}, Disable = Disable, Size = kaSize, DeathCheck = kaDeathCheck}
        local Run = true

        local Ignorelist = OverlapParams.new()
        Ignorelist.FilterType = Enum.RaycastFilterType.Include

        local function kaGetChar(plr)
            return (plr or lp).Character
        end

        local function kaGetHum(plr)
            local char = plr:IsA("Model") and plr or kaGetChar(plr)
            if char then return char:FindFirstChildWhichIsA("Humanoid") end
        end

        local function kaIsAlive(h)
            return h and h.Health > 0
        end

        local function kaGetTouchInterest(Tool)
            return Tool and Tool:FindFirstChildWhichIsA("TouchTransmitter", true)
        end

        local function kaGetChars(LocalChar)
            local chars = {}
            for _, p in Players:GetPlayers() do
                table.insert(chars, kaGetChar(p))
            end
            table.remove(chars, table.find(chars, LocalChar))
            return chars
        end

        local function kaAttack(Tool, TouchPart, ToTouch)
            if Tool:IsDescendantOf(workspace) then
                Tool:Activate()
                firetouchinterest(TouchPart, ToTouch, 1)
                firetouchinterest(TouchPart, ToTouch, 0)
            end
        end

        table.insert(getgenv().configs.connections, Disable.Event:Connect(function()
            Run = false
        end))

        task.spawn(function()
            while Run do
                local char = kaGetChar()
                if kaIsAlive(kaGetHum(char)) then
                    local Tool = char and char:FindFirstChildWhichIsA("Tool")
                    local TouchInterest = Tool and kaGetTouchInterest(Tool)
                    if TouchInterest then
                        local TouchPart = TouchInterest.Parent
                        local chars = kaGetChars(char)
                        Ignorelist.FilterDescendantsInstances = chars
                        local hits = workspace:GetPartBoundsInBox(TouchPart.CFrame, TouchPart.Size + getgenv().configs.Size, Ignorelist)
                        for _, v in hits do
                            local Character = v:FindFirstAncestorWhichIsA("Model")
                            if table.find(chars, Character) then
                                if getgenv().configs.DeathCheck then
                                    if kaIsAlive(kaGetHum(Character)) then
                                        kaAttack(Tool, TouchPart, v)
                                    end
                                else
                                    kaAttack(Tool, TouchPart, v)
                                end
                            end
                        end
                    end
                end
                RunService.Heartbeat:Wait()
            end
        end)
        notify("⚔️ Kill Aura ON — equip a sword!")
    end)
end

-- ============================================================
-- DROP BLOCKS TAB
-- ============================================================
do
    local s = BlocksTab.scroll

    addSection(s, "── Asset Chooser ──")


    local assetPresets = {
        {name = "Brick", id = 56450668, guid = "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"},
    }

    local assetLabel = Instance.new("TextLabel")
    assetLabel.Size = UDim2.new(1, 0, 0, 28)
    assetLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    assetLabel.BorderSizePixel = 0
    assetLabel.Text = "Selected: Brick (Free)"
    assetLabel.Font = Enum.Font.GothamBold
    assetLabel.TextSize = 12
    assetLabel.TextColor3 = Color3.fromRGB(220, 175, 30)
    assetLabel.Parent = s
    local assetLabelCorner = Instance.new("UICorner")
    assetLabelCorner.CornerRadius = UDim.new(0, 6)
    assetLabelCorner.Parent = assetLabel

    for _, preset in pairs(assetPresets) do
        addButton(s, preset.name, Color3.fromRGB(30, 60, 100), function()
            selectedAsset = {id = preset.id, guid = preset.guid}
            assetLabel.Text = "Selected: " .. preset.name
            notify("Asset: " .. preset.name)
        end)
    end


    local customRow = Instance.new("Frame")
    customRow.Size = UDim2.new(1, 0, 0, 36)
    customRow.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    customRow.BorderSizePixel = 0
    customRow.Parent = s
    local customRowCorner = Instance.new("UICorner")
    customRowCorner.CornerRadius = UDim.new(0, 6)
    customRowCorner.Parent = customRow

    local customInput = Instance.new("TextBox")
    customInput.Size = UDim2.new(0.68, 0, 1, -8)
    customInput.Position = UDim2.new(0, 6, 0, 4)
    customInput.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    customInput.PlaceholderText = "Enter Asset ID..."
    customInput.Text = ""
    customInput.Font = Enum.Font.Gotham
    customInput.TextSize = 12
    customInput.TextColor3 = Color3.new(1, 1, 1)
    customInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    customInput.BorderSizePixel = 0
    customInput.ClearTextOnFocus = false
    customInput.Parent = customRow
    local customInputCorner = Instance.new("UICorner")
    customInputCorner.CornerRadius = UDim.new(0, 5)
    customInputCorner.Parent = customInput

    local setBtn = Instance.new("TextButton")
    setBtn.Size = UDim2.new(0.28, 0, 1, -8)
    setBtn.Position = UDim2.new(0.7, 2, 0, 4)
    setBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
    setBtn.Text = "Set"
    setBtn.Font = Enum.Font.GothamBold
    setBtn.TextSize = 12
    setBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
    setBtn.BorderSizePixel = 0
    setBtn.AutoButtonColor = true
    setBtn.Parent = customRow
    local setBtnCorner = Instance.new("UICorner")
    setBtnCorner.CornerRadius = UDim.new(0, 5)
    setBtnCorner.Parent = setBtn

    setBtn.MouseButton1Click:Connect(function()
        local id = tonumber(customInput.Text)
        if id then
            selectedAsset = {id = id, guid = "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"}
            assetLabel.Text = "Selected: Custom " .. id
            notify("Asset: " .. id)
        end
    end)

    addSection(s, "── Stamp at Mouse ──")

    local blockStampDelay = 0.05
    local blockStamping = false

    addSlider(s, "Stamp Delay (sec)", 0.01, 1, 0.05, function(v)
        blockStampDelay = v
    end)

    addToggle(s, "💠 Stamp at Mouse (Free)", function(on)
        blockStamping = on
        if on then
            task.spawn(function()
                while blockStamping do
                    local mouse = lp:GetMouse()
                    universalStamp(CFrame.new(mouse.Hit.Position), {})
                    task.wait(blockStampDelay)
                end
            end)
        end
    end)

    addToggle(s, "💠 Stamp at Mouse → Baseplate", function(on)
        blockStamping = on
        if on then
            task.spawn(function()
                while blockStamping do
                    local mouse = lp:GetMouse()
                    local plate = getBaseplate()
                    universalStamp(CFrame.new(mouse.Hit.Position), plate and {plate} or {})
                    task.wait(blockStampDelay)
                end
            end)
        end
    end)

    addSection(s, "── Shape Builder ──")

    local shapeSize = cfg.shapeSize
    local shapeThickness = 1
    local heightOffset = 0

    addSlider(s, "Shape Size", 1, 40, cfg.shapeSize, function(v)
        shapeSize = math.floor(v)
        cfg.shapeSize = v
    end)

    addSlider(s, "Thickness", 1, 6, 1, function(v)
        shapeThickness = math.floor(v)
    end)

    addSlider(s, "Height Offset (studs)", -50, 100, 0, function(v)
        heightOffset = math.floor(v)
    end)

    local spawnDelay = cfg.spawnDelay

    addSlider(s, "Batch Delay (sec between 50 blocks)", 0.0001, 0.1, cfg.spawnDelay, function(v)
        spawnDelay = v
        cfg.spawnDelay = v
    end)

    local shapes = {
        "❤️ Heart",
        "⭕ Circle",
        "🌐 Dome",
        "🔲 Cube",
        "⭐ Star",
        "🔷 Diamond",
        "🌀 Spiral",
        "😊 Smiley",
        "🔺 Pyramid",
        "🌍 Sphere",
        "🏔️ Mountain",
        "🌊 Wave",
        "🧬 DNA Helix",
        "🪐 Saturn Ring",
        "💎 Crystal",
        "🐌 Snail Shell",
        "⚡ Lightning Bolt",
        "🔯 Star of David",
        "🏠 House",
        "🌲 Tree",
        "⬡ Honeycomb",
        "🌀 Vortex",
        "🔮 Crystal Cluster",
        "🌉 Bridge",
        "💀 Skull",
        "🏰 Castle",
        "🍆 Dih",
        "🗼 Tower",
        "💥 Color Blast",
        "🔱 Trident",
        "✝️ Cross",
        "🍩 Torus",
        "🌸 Flower",
        "🍄 Mushroom",
        "❄️ Snowflake",
        "💀 Skull 3D",
        "📡 Satellite Dish",
        "🕸️ Spider Web",
        "🐚 Triple Helix",
        "🏹 Arrow",
        "🔔 Bell",
        "🛸 UFO",
        "🌀 Klein",
        "⚓ Anchor",
        "🧱 Brick Wall",
        "🔵 Bubble Cluster",
        "🌋 Volcano",
        "🎄 Christmas Tree",
        "🎯 Target",
        "🌀 Galaxy Spiral",
        "🧊 Iceberg",
        "💣 Bomb",
        "🔑 Key",
        "🐍 Snake",
        "✈️ Airplane",
        "🏗️ Crane",
        "🪄 Magic Circle",
        "🐉 Dragon",
        "🪜 Staircase",
        "🚀 Rocket",
        "🎸 Guitar",
        "💠 Hex Prism",
        "🏟️ Stadium",
        "🎃 Pumpkin",
        "🤖 Robot",
        "🪤 Cage",
        "⚙️ Gear",
        "🌊 Tsunami",
        "🏯 Pagoda",
        "🌈 Rainbow Arch",
        "🦋 Butterfly",
        "🎡 Ferris Wheel",
        "🧲 Magnet",
        "💫 Comet",
        "🎪 Circus Tent",
        "🔩 Screw",
        "🏄 Pipe Wave",
        "🌀 Mobius",
        "🎋 Bamboo",
    }

    local selectedShape = shapes[1]

    local shapeLabel = Instance.new("TextLabel")
    shapeLabel.Size = UDim2.new(1, 0, 0, 26)
    shapeLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    shapeLabel.BorderSizePixel = 0
    shapeLabel.Text = "Shape: " .. selectedShape
    shapeLabel.Font = Enum.Font.GothamBold
    shapeLabel.TextSize = 11
    shapeLabel.TextColor3 = Color3.fromRGB(220, 175, 30)
    shapeLabel.TextXAlignment = Enum.TextXAlignment.Left
    shapeLabel.Parent = s
    local shapeLabelCorner = Instance.new("UICorner")
    shapeLabelCorner.CornerRadius = UDim.new(0, 6)
    shapeLabelCorner.Parent = shapeLabel
    local shapeLabelPad = Instance.new("UIPadding")
    shapeLabelPad.PaddingLeft = UDim.new(0, 8)
    shapeLabelPad.Parent = shapeLabel

    local gridHolder = Instance.new("Frame")
    gridHolder.Size = UDim2.new(1, 0, 0, 10)
    gridHolder.BackgroundTransparency = 1
    gridHolder.BorderSizePixel = 0
    gridHolder.Parent = s

    local gridFrame = Instance.new("Frame")
    gridFrame.Size = UDim2.new(1, 0, 1, 0)
    gridFrame.BackgroundTransparency = 1
    gridFrame.BorderSizePixel = 0
    gridFrame.Parent = gridHolder

    local gridLayout = Instance.new("UIListLayout")
    gridLayout.FillDirection = Enum.FillDirection.Horizontal
    gridLayout.Wraps = true
    gridLayout.Padding = UDim.new(0, 3)
    gridLayout.Parent = gridFrame
    gridLayout.Changed:Connect(function()
        gridFrame.Size = UDim2.new(1, 0, 0, gridLayout.AbsoluteContentSize.Y + 4)
        gridHolder.Size = UDim2.new(1, 0, 0, gridLayout.AbsoluteContentSize.Y + 4)
    end)

    for _, sh in pairs(shapes) do
        local shBtn = Instance.new("TextButton")
        shBtn.Size = UDim2.new(0, 88, 0, 26)
        if selectedShape == sh then
            shBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
        else
            shBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        end
        shBtn.Text = sh
        shBtn.Font = Enum.Font.GothamBold
        shBtn.TextSize = 9
        shBtn.TextColor3 = Color3.new(1, 1, 1)
        shBtn.BorderSizePixel = 0
        shBtn.AutoButtonColor = false
        shBtn.Parent = gridFrame
        local shBtnCorner = Instance.new("UICorner")
        shBtnCorner.CornerRadius = UDim.new(0, 5)
        shBtnCorner.Parent = shBtn
        shBtn.MouseButton1Click:Connect(function()
            selectedShape = sh
            shapeLabel.Text = "Shape: " .. sh
            for _, c in pairs(gridFrame:GetChildren()) do
                if c:IsA("TextButton") then
                    if c.Text == sh then
                        c.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
                    else
                        c.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                    end
                end
            end
        end)
    end

    -- MAXIMUM SPEED SPAWN SYSTEM
    local spawnQueue = {}

    local lastBuildRecord = {}

    local function flushQueue(conn2)
        if #spawnQueue == 0 then return end
        local queueCopy = spawnQueue
        spawnQueue = {}
        lastBuildRecord = {}
        local hrp = getHRP()
        local origin = hrp and hrp.CFrame or CFrame.new()

        -- deduplicate by position key
        local seen = {}
        local deduped = {}
        for i = 1, #queueCopy do
            local entry = queueCopy[i]
            local cf = entry[1]
            local c2 = entry[2]
            local eid = entry[3]
            local eguid = entry[4]
            local p = cf.Position
            local key = math.floor(p.X) .. "_" .. math.floor(p.Y) .. "_" .. math.floor(p.Z)
            if not seen[key] then
                seen[key] = true
                table.insert(deduped, {cf, c2, eid, eguid})
                local localPos = origin:ToObjectSpace(cf).Position
                table.insert(lastBuildRecord, {localPos.X, localPos.Y, localPos.Z})
            end
        end

        for i = 1, #deduped do
            local cf = deduped[i][1]
            local c2 = deduped[i][2] or conn2 or {}
            local eid = deduped[i][3] or 56450668
            local eguid = deduped[i][4] or "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
            task.spawn(function()
                universalStamp(cf, c2, eid, eguid)
            end)
        end
    end

    local function spawnPoint(origin, x, y, z, conn2)
        table.insert(spawnQueue, {
            origin * CFrame.new(x * 4, y * 4 + heightOffset, z * 4),
            conn2,
            56450668,
            "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
        })
    end

    local function buildShape(origin, conn2)
        local r = shapeSize
        local t = shapeThickness

        if selectedShape == "❤️ Heart" then
            for x = -r, r, 0.6 do
                for y = -r, r, 0.6 do
                    local nx = x / r
                    local ny = y / r
                    local val = (nx * nx + ny * ny - 1) ^ 3 - nx * nx * ny * ny * ny
                    if val <= 0 and val >= -0.15 then
                        spawnPoint(origin, x, y, 0, conn2)
                    end
                end
            end

        elseif selectedShape == "⭕ Circle" then
            for x = -r, r do
                for z = -r, r do
                    local d = math.sqrt(x * x + z * z)
                    if d <= r and d >= r - t then
                        spawnPoint(origin, x, 0, z, conn2)
                    end
                end
            end

        elseif selectedShape == "🌐 Dome" then
            local step = 0.8
            local xi = -r
            while xi <= r do
                local yi = -r
                while yi <= r do
                    local zi = -r
                    while zi <= r do
                        local d = math.sqrt(xi * xi + yi * yi + zi * zi)
                        if d <= r and d >= r - t then
                            spawnPoint(origin, xi, yi + r, zi, conn2)
                        end
                        zi = zi + step
                    end
                    yi = yi + step
                end
                xi = xi + step
            end

        elseif selectedShape == "🔲 Cube" then
            for x = -r, r do
                for y = 0, r * 2 do
                    for z = -r, r do
                        local ax = math.abs(x)
                        local ay = math.abs(y - r)
                        local az = math.abs(z)
                        if (ax >= r - t and ax <= r) or (ay >= r - t and ay <= r) or (az >= r - t and az <= r) then
                            if ax <= r and ay <= r and az <= r then
                                spawnPoint(origin, x, y, z, conn2)
                            end
                        end
                    end
                end
            end

        elseif selectedShape == "⭐ Star" then
            local oR = r
            local iR = r * 0.45
            for angle = 0, 360, 2 do
                local rad = math.rad(angle)
                local lobeT = (math.cos(5 * rad) + 1) / 2
                local sr = iR + (oR - iR) * lobeT
                for tk = 0, t do
                    local tsr = sr - tk
                    if tsr > 0 then
                        spawnPoint(origin, math.floor(tsr * math.cos(rad)), 0, math.floor(tsr * math.sin(rad)), conn2)
                    end
                end
            end

        elseif selectedShape == "🔷 Diamond" then
            for x = -r, r do
                for y = -r, r do
                    for z = -r, r do
                        local md = math.abs(x) + math.abs(y) + math.abs(z)
                        if md <= r and md >= r - t then
                            spawnPoint(origin, x, y + r, z, conn2)
                        end
                    end
                end
            end

        elseif selectedShape == "🌀 Spiral" then
            for i = 0, r * 20 do
                local angle = i * 0.3
                local height = i * 0.15
                for tk = 0, t - 1 do
                    spawnPoint(origin, math.floor(r * math.cos(angle)) + tk, math.floor(height), math.floor(r * math.sin(angle)), conn2)
                end
            end

        elseif selectedShape == "😊 Smiley" then
            for angle = 0, 360, 2 do
                local rad = math.rad(angle)
                for tk = 0, t - 1 do
                    spawnPoint(origin, math.floor((r - tk) * math.cos(rad)), 0, math.floor((r - tk) * math.sin(rad)), conn2)
                end
            end
            local eyeR = math.max(1, math.floor(r * 0.12))
            local leftEyeX = -math.floor(r * 0.35)
            local rightEyeX = math.floor(r * 0.35)
            local eyeZ = -math.floor(r * 0.3)
            for angle = 0, 360, 5 do
                local rad = math.rad(angle)
                spawnPoint(origin, leftEyeX + math.floor(eyeR * math.cos(rad)), 0, eyeZ + math.floor(eyeR * math.sin(rad)), conn2)
                spawnPoint(origin, rightEyeX + math.floor(eyeR * math.cos(rad)), 0, eyeZ + math.floor(eyeR * math.sin(rad)), conn2)
            end
            local smR = math.floor(r * 0.55)
            for angle = 20, 160, 3 do
                local rad = math.rad(angle)
                spawnPoint(origin, math.floor(smR * math.cos(rad)), 0, math.floor(r * 0.2) + math.floor(smR * 0.5 * math.sin(rad)), conn2)
            end

        elseif selectedShape == "🔺 Pyramid" then
            for layer = 0, r do
                local lr = r - layer
                for x = -lr, lr do
                    for z = -lr, lr do
                        if math.abs(x) == lr or math.abs(z) == lr then
                            spawnPoint(origin, x, layer, z, conn2)
                        end
                    end
                end
            end

        elseif selectedShape == "🌍 Sphere" then
            local step = 0.9
            local xi = -r
            while xi <= r do
                local yi = -r
                while yi <= r do
                    local zi = -r
                    while zi <= r do
                        local d = math.sqrt(xi * xi + yi * yi + zi * zi)
                        if d <= r and d >= r - t then
                            spawnPoint(origin, xi, yi + r, zi, conn2)
                        end
                        zi = zi + step
                    end
                    yi = yi + step
                end
                xi = xi + step
            end

        elseif selectedShape == "🏔️ Mountain" then
            for x = -r, r do
                for z = -r, r do
                    local height = math.floor(r - math.sqrt(x * x + z * z))
                    if height > 0 then
                        for y = 0, height do
                            spawnPoint(origin, x, y, z, conn2)
                        end
                    end
                end
            end

        elseif selectedShape == "🌊 Wave" then
            for x = -r * 2, r * 2 do
                for z = -r, r do
                    local y = math.sin(x * 0.3) * math.cos(z * 0.3) * r * 0.5
                    spawnPoint(origin, x, math.floor(y), z, conn2)
                end
            end

        elseif selectedShape == "🧬 DNA Helix" then
            for i = 0, r * 20 do
                local angle = i * 0.2
                local height = i * 0.1
                spawnPoint(origin, math.floor(r * 0.4 * math.cos(angle)), math.floor(height), math.floor(r * 0.4 * math.sin(angle)), conn2)
                spawnPoint(origin, math.floor(r * 0.4 * math.cos(angle + math.pi)), math.floor(height), math.floor(r * 0.4 * math.sin(angle + math.pi)), conn2)
            end

        elseif selectedShape == "🪐 Saturn Ring" then
            for x = -r * 2, r * 2 do
                for z = -r * 2, r * 2 do
                    local d = math.sqrt(x * x + z * z)
                    if d <= r * 2 and d >= r * 1.3 then
                        spawnPoint(origin, x, 0, z, conn2)
                    end
                end
            end

        elseif selectedShape == "💎 Crystal" then
            for layer = 0, r do
                local lr = math.floor(r - layer * (r / (r + 1)))
                for x = -lr, lr do
                    for z = -lr, lr do
                        if math.abs(x) == lr or math.abs(z) == lr then
                            spawnPoint(origin, x, layer, z, conn2)
                            spawnPoint(origin, x, -layer, z, conn2)
                        end
                    end
                end
            end

        elseif selectedShape == "🐌 Snail Shell" then
            for i = 0, r * 30 do
                local angle = i * 0.15
                local radius2 = i * 0.12
                local height2 = math.sin(i * 0.08) * r * 0.3
                spawnPoint(origin, math.floor(radius2 * math.cos(angle)), math.floor(height2), math.floor(radius2 * math.sin(angle)), conn2)
            end

        elseif selectedShape == "⚡ Lightning Bolt" then
            local pts = {{0, 0}, {-r, r}, {-r/2, r}, {-r * 1.5, r * 2}, {r/2, r * 2}, {0, r * 1.5}, {r, r * 3}}
            for i = 1, #pts - 1 do
                local p1 = pts[i]
                local p2 = pts[i + 1]
                local steps = math.floor(math.sqrt((p2[1] - p1[1]) ^ 2 + (p2[2] - p1[2]) ^ 2))
                for j = 0, steps do
                    local frac = j / math.max(steps, 1)
                    spawnPoint(origin, math.floor(p1[1] + (p2[1] - p1[1]) * frac), math.floor(p1[2] + (p2[2] - p1[2]) * frac), 0, conn2)
                end
            end

        elseif selectedShape == "🔯 Star of David" then
            for angle = 0, 360, 2 do
                local rad = math.rad(angle)
                local lobeT = (math.cos(6 * rad) + 1) / 2
                local sr = (r * 0.5) + (r * 0.5) * lobeT
                spawnPoint(origin, math.floor(sr * math.cos(rad)), 0, math.floor(sr * math.sin(rad)), conn2)
            end

        elseif selectedShape == "🏠 House" then
            local doorW = math.max(1, math.floor(r * 0.25))
            local doorH = math.floor(r * 0.6)
            for x = -r, r do
                for z = -r, r do
                    spawnPoint(origin, x, -1, z, conn2)
                end
            end
            for y = 0, r do
                for i = -r, r do
                    spawnPoint(origin, i, y, r, conn2)
                    spawnPoint(origin, r, y, i, conn2)
                    spawnPoint(origin, -r, y, i, conn2)
                    local inDoor = math.abs(i) <= doorW and y <= doorH
                    if not inDoor then
                        spawnPoint(origin, i, y, -r, conn2)
                    end
                end
            end
            for layer = 0, r do
                local lr = r - layer
                for x = -lr, lr do
                    for z = -lr, lr do
                        if math.abs(x) == lr or math.abs(z) == lr then
                            spawnPoint(origin, x, r + layer, z, conn2)
                        end
                    end
                end
            end

        elseif selectedShape == "🌲 Tree" then
            local trunkW = math.max(1, math.floor(r * 0.12))
            local trunkH = math.floor(r * 0.8)
            for y = 0, trunkH do
                for x = -trunkW, trunkW do
                    for z = -trunkW, trunkW do
                        spawnPoint(origin, x, y, z, conn2)
                    end
                end
            end
            for layer = 0, 2 do
                local coneR = math.floor(r * (0.9 - layer * 0.2))
                local coneY = trunkH + layer * math.floor(r * 0.35)
                local coneH = math.floor(r * 0.55)
                for y = 0, coneH do
                    local lr = math.max(1, math.floor(coneR * (1 - (y / coneH))))
                    for x = -lr, lr do
                        for z = -lr, lr do
                            if math.sqrt(x * x + z * z) <= lr then
                                spawnPoint(origin, x, coneY + y, z, conn2)
                            end
                        end
                    end
                end
            end

        elseif selectedShape == "⬡ Honeycomb" then
            local hexR = math.max(2, math.floor(r * 0.45))
            local gap = 1
            local hexW = hexR * 2 + gap
            local hexH = math.floor(hexR * 1.732) + gap
            local function drawHex(cx, cz)
                for angle = 0, 300, 60 do
                    local rad1 = math.rad(angle)
                    local rad2 = math.rad(angle + 60)
                    local x1 = math.floor(cx + hexR * math.cos(rad1))
                    local z1 = math.floor(cz + hexR * math.sin(rad1))
                    local x2 = math.floor(cx + hexR * math.cos(rad2))
                    local z2 = math.floor(cz + hexR * math.sin(rad2))
                    local steps = math.max(1, math.floor(math.sqrt((x2 - x1) ^ 2 + (z2 - z1) ^ 2)))
                    for i = 0, steps do
                        local frac = i / steps
                        spawnPoint(origin, math.floor(x1 + (x2 - x1) * frac), 0, math.floor(z1 + (z2 - z1) * frac), conn2)
                    end
                end
            end
            for row = -r, r do
                local rowOffset = 0
                if row % 2 ~= 0 then
                    rowOffset = math.floor(hexW * 0.5)
                end
                for col = -r, r do
                    local cx = col * hexW + rowOffset
                    local cz = row * hexH
                    if math.sqrt(cx * cx + cz * cz) <= r * hexW * 0.5 then
                        drawHex(cx, cz)
                    end
                end
            end

        elseif selectedShape == "🌀 Vortex" then
            for i = 0, r * 30 do
                local angle = i * 0.2
                local radius = r * (1 - i / (r * 30))
                local height = i * 0.1
                spawnPoint(origin, math.floor(radius * math.cos(angle)), math.floor(height), math.floor(radius * math.sin(angle)), conn2)
            end

        elseif selectedShape == "🔮 Crystal Cluster" then
            local spikes = {{0, 0}, {r * 0.5, r * 0.3}, {-r * 0.4, r * 0.5}, {r * 0.3, -r * 0.4}, {-r * 0.5, -r * 0.3}, {0, r * 0.6}}
            for _, sp in pairs(spikes) do
                local sx = sp[1]
                local sz = sp[2]
                local height = math.random(r / 2, r)
                for y = 0, height do
                    local prog = 1 - (y / height)
                    local rad = math.floor(prog * 2)
                    for x = -rad, rad do
                        for z = -rad, rad do
                            if math.sqrt(x * x + z * z) <= rad then
                                spawnPoint(origin, math.floor(sx) + x, y, math.floor(sz) + z, conn2)
                            end
                        end
                    end
                end
            end

        elseif selectedShape == "🌉 Bridge" then
            local span = r * 2
            local deckY = 6
            local deckW = 6
            local archPeak = math.floor(r * 0.9)
            local towerH = deckY + archPeak + 3
            for x = -span, span, math.max(3, math.floor(span / 5)) do
                for y = 0, deckY do
                    spawnPoint(origin, x, y, -deckW, conn2)
                    spawnPoint(origin, x, y, deckW, conn2)
                end
            end
            for x = -span, span do
                for z = -deckW, deckW do
                    spawnPoint(origin, x, deckY, z, conn2)
                end
            end
            for _, ex in pairs({-math.floor(span * 0.6), math.floor(span * 0.6)}) do
                for y = 0, towerH do
                    for dz = -1, 1 do
                        spawnPoint(origin, ex, y, -deckW - 1 + dz, conn2)
                        spawnPoint(origin, ex, y, deckW + 1 + dz, conn2)
                    end
                end
                for z = -deckW - 1, deckW + 1 do
                    spawnPoint(origin, ex, towerH, z, conn2)
                    spawnPoint(origin, ex, towerH - 1, z, conn2)
                end
            end
            for x = -span, span do
                local tv = (x + span) / (span * 2)
                local archH = math.floor(archPeak * 4 * tv * (1 - tv))
                spawnPoint(origin, x, deckY + archH, -deckW - 1, conn2)
                spawnPoint(origin, x, deckY + archH, deckW + 1, conn2)
            end

        elseif selectedShape == "💀 Skull" then
            local cranR = r
            for x = -cranR, cranR do
                for z = -cranR, cranR do
                    local d = math.sqrt(x * x + z * z)
                    if d <= cranR and d >= cranR - t then
                        spawnPoint(origin, x, 0, z, conn2)
                    end
                end
            end
            for x = -cranR, cranR do
                for z = -cranR, cranR do
                    if math.sqrt(x * x + z * z) <= cranR - t then
                        spawnPoint(origin, x, 0, z, conn2)
                    end
                end
            end
            local eyeR = math.max(2, math.floor(r * 0.25))
            local eyeZ = -math.floor(r * 0.2)
            local leftEyeX = -math.floor(r * 0.35)
            local rightEyeX = math.floor(r * 0.35)
            for x = -eyeR, eyeR do
                for z = -eyeR, eyeR do
                    local d = math.sqrt(x * x + z * z)
                    if d >= eyeR - 1 and d <= eyeR then
                        spawnPoint(origin, leftEyeX + x, 1, eyeZ + z, conn2)
                        spawnPoint(origin, rightEyeX + x, 1, eyeZ + z, conn2)
                    end
                end
            end

        elseif selectedShape == "🏰 Castle" then
            for i = -r, r do
                for y = 0, r do
                    local battlement = y >= r - 1 and i % 3 == 0
                    if not battlement then
                        spawnPoint(origin, i, y, -r, conn2)
                        spawnPoint(origin, i, y, r, conn2)
                        spawnPoint(origin, -r, y, i, conn2)
                        spawnPoint(origin, r, y, i, conn2)
                    end
                end
            end
            local towerH = r + 5
            local corners = {{-r, -r}, {r, -r}, {-r, r}, {r, r}}
            for _, corner in pairs(corners) do
                local tx = corner[1]
                local tz = corner[2]
                local tr = math.max(3, math.floor(r * 0.3))
                for angle = 0, 360, 15 do
                    local rad = math.rad(angle)
                    for y = 0, towerH do
                        local battlement2 = y >= towerH - 1 and math.floor(angle / 30) % 2 == 0
                        if not battlement2 then
                            spawnPoint(origin, tx + math.floor(tr * math.cos(rad)), y, tz + math.floor(tr * math.sin(rad)), conn2)
                        end
                    end
                end
                for layer = 0, tr do
                    local lr = tr - layer
                    for angle2 = 0, 360, 20 do
                        local rad2 = math.rad(angle2)
                        spawnPoint(origin, tx + math.floor(lr * math.cos(rad2)), towerH + layer, tz + math.floor(lr * math.sin(rad2)), conn2)
                    end
                end
            end

        elseif selectedShape == "🍆 Dih" then
            local shaft_r = math.max(2, math.floor(r * 0.35))
            local shaft_h = math.floor(r * 1.8)
            local head_r = math.max(3, math.floor(r * 0.5))
            local ball_r = math.max(2, math.floor(r * 0.3))
            for y = 0, shaft_h do
                for x = -shaft_r, shaft_r do
                    for z = -shaft_r, shaft_r do
                        local d = math.sqrt(x * x + z * z)
                        if d <= shaft_r and d >= shaft_r - t then
                            spawnPoint(origin, x, y, z, conn2)
                        end
                    end
                end
            end
            for x = -head_r, head_r do
                for y = -head_r, head_r do
                    for z = -head_r, head_r do
                        local d = math.sqrt(x * x + y * y + z * z)
                        if d <= head_r and d >= head_r - t then
                            spawnPoint(origin, x, shaft_h + y + head_r, z, conn2)
                        end
                    end
                end
            end
            local ballOffsets = {-shaft_r - ball_r + 1, shaft_r + ball_r - 1}
            for _, bx in pairs(ballOffsets) do
                for x = -ball_r, ball_r do
                    for y = -ball_r, ball_r do
                        for z = -ball_r, ball_r do
                            local d = math.sqrt(x * x + y * y + z * z)
                            if d <= ball_r and d >= ball_r - t then
                                spawnPoint(origin, bx + x, y, z, conn2)
                            end
                        end
                    end
                end
            end

        elseif selectedShape == "🗼 Tower" then
            local towerW = math.max(3, math.floor(r * 0.5))
            local towerH = r * 3
            local doorW = math.max(1, math.floor(towerW * 0.4))
            local doorH = math.floor(r * 0.6)
            local floorEvery = math.max(3, math.floor(r * 0.5))
            for y = 0, towerH do
                for i = -towerW, towerW do
                    local inDoor = math.abs(i) <= doorW and y <= doorH
                    if not inDoor then
                        spawnPoint(origin, i, y, -towerW, conn2)
                    end
                    spawnPoint(origin, i, y, towerW, conn2)
                    spawnPoint(origin, -towerW, y, i, conn2)
                    spawnPoint(origin, towerW, y, i, conn2)
                    if y % floorEvery == 0 and y > 0 and y < towerH then
                        for x = -towerW + 1, towerW - 1 do
                            for z2 = -towerW + 1, towerW - 1 do
                                spawnPoint(origin, x, y, z2, conn2)
                            end
                        end
                    end
                end
            end
            for i = -towerW, towerW, 2 do
                spawnPoint(origin, i, towerH + 1, -towerW, conn2)
                spawnPoint(origin, i, towerH + 1, towerW, conn2)
                spawnPoint(origin, -towerW, towerH + 1, i, conn2)
                spawnPoint(origin, towerW, towerH + 1, i, conn2)
            end
            local flagBase = towerH + 2
            for y = flagBase, flagBase + 4 do
                spawnPoint(origin, 0, y, 0, conn2)
            end
            for z2 = 1, 3 do
                spawnPoint(origin, 0, flagBase + 4, z2, conn2)
                spawnPoint(origin, 0, flagBase + 3, z2, conn2)
            end

        elseif selectedShape == "💥 Color Blast" then
            for ring = 1, r do
                local ringY = math.floor(math.sin(ring / r * math.pi) * r * 0.5)
                for angle = 0, 360, 5 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, math.floor(ring * math.cos(rad)), ringY, math.floor(ring * math.sin(rad)), conn2)
                end
            end
            local spikeH = math.floor(r * 1.5)
            for y = 0, spikeH do
                local sr = math.max(0, math.floor((1 - y / spikeH) * math.floor(r * 0.3)))
                if sr == 0 then
                    spawnPoint(origin, 0, y, 0, conn2)
                else
                    for angle = 0, 360, 15 do
                        local rad = math.rad(angle)
                        spawnPoint(origin, math.floor(sr * math.cos(rad)), y, math.floor(sr * math.sin(rad)), conn2)
                    end
                end
            end
            for i = 0, 7 do
                local angle = math.rad(i * 45)
                for dist = 1, math.floor(r * 0.8) do
                    local dropH = math.floor(math.sin(dist / (r * 0.8) * math.pi) * r * 0.4)
                    spawnPoint(origin, math.floor(dist * math.cos(angle)), dropH, math.floor(dist * math.sin(angle)), conn2)
                end
            end

        elseif selectedShape == "🔱 Trident" then
            for y = 0, r * 2 do
                spawnPoint(origin, 0, y, 0, conn2)
            end
            local prongs = {-math.floor(r * 0.5), 0, math.floor(r * 0.5)}
            for _, px in pairs(prongs) do
                for y = r, r * 2 + math.floor(r * 0.4) do
                    spawnPoint(origin, px, y, 0, conn2)
                end
            end
            for x = -math.floor(r * 0.5), math.floor(r * 0.5) do
                spawnPoint(origin, x, r, 0, conn2)
            end

        elseif selectedShape == "✝️ Cross" then
            for y = -r, r do
                spawnPoint(origin, 0, y, 0, conn2)
            end
            for x = -r, r do
                spawnPoint(origin, x, math.floor(r * 0.3), 0, conn2)
            end

        elseif selectedShape == "🍩 Torus" then
            local outerR = r
            local tubeR = math.max(2, math.floor(r * 0.3))
            for phi = 0, 360, 5 do
                local phiR = math.rad(phi)
                for theta = 0, 360, 10 do
                    local thetaR = math.rad(theta)
                    local cx = (outerR + tubeR * math.cos(thetaR)) * math.cos(phiR)
                    local cy = tubeR * math.sin(thetaR)
                    local cz = (outerR + tubeR * math.cos(thetaR)) * math.sin(phiR)
                    spawnPoint(origin, math.floor(cx), math.floor(cy + outerR), math.floor(cz), conn2)
                end
            end

        elseif selectedShape == "🌸 Flower" then
            local petalR = math.floor(r * 0.6)
            local numPetals = 6
            for angle = 0, 360, 5 do
                local rad = math.rad(angle)
                local pr = math.floor(r * 0.25)
                spawnPoint(origin, math.floor(pr * math.cos(rad)), 0, math.floor(pr * math.sin(rad)), conn2)
            end
            for p = 0, numPetals - 1 do
                local baseAngle = math.rad(p * (360 / numPetals))
                local pcx = math.floor(r * 0.55 * math.cos(baseAngle))
                local pcz = math.floor(r * 0.55 * math.sin(baseAngle))
                for angle = 0, 360, 8 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, pcx + math.floor(petalR * 0.45 * math.cos(rad)), 0, pcz + math.floor(petalR * 0.45 * math.sin(rad)), conn2)
                end
            end
            for y = -r, -1 do
                spawnPoint(origin, 0, y, 0, conn2)
            end

        elseif selectedShape == "🍄 Mushroom" then
            local stemW = math.max(2, math.floor(r * 0.2))
            local stemH = math.floor(r * 0.8)
            local capR = r
            local capH = math.floor(r * 0.6)
            for y = 0, stemH do
                for x = -stemW, stemW do
                    for z = -stemW, stemW do
                        if math.sqrt(x * x + z * z) <= stemW then
                            spawnPoint(origin, x, y, z, conn2)
                        end
                    end
                end
            end
            for y = 0, capH do
                local lr = math.floor(capR * math.sqrt(1 - (y / capH) ^ 2))
                for x = -lr, lr do
                    for z = -lr, lr do
                        if math.sqrt(x * x + z * z) <= lr then
                            spawnPoint(origin, x, stemH + y, z, conn2)
                        end
                    end
                end
            end

        elseif selectedShape == "❄️ Snowflake" then
            for arm = 0, 5 do
                local armAngle = math.rad(arm * 60)
                for dist = 0, r do
                    local x = math.floor(dist * math.cos(armAngle))
                    local z = math.floor(dist * math.sin(armAngle))
                    spawnPoint(origin, x, 0, z, conn2)
                    if dist % 3 == 0 and dist > 0 then
                        local branchLen = math.floor((r - dist) * 0.5)
                        for bl = 1, branchLen do
                            spawnPoint(origin, x + math.floor(bl * math.cos(armAngle + math.rad(45))), 0, z + math.floor(bl * math.sin(armAngle + math.rad(45))), conn2)
                            spawnPoint(origin, x + math.floor(bl * math.cos(armAngle - math.rad(45))), 0, z + math.floor(bl * math.sin(armAngle - math.rad(45))), conn2)
                        end
                    end
                end
            end

        elseif selectedShape == "💀 Skull 3D" then
            local step = 0.9
            local xi = -r
            while xi <= r do
                local yi = -r
                while yi <= r do
                    local zi = -r
                    while zi <= r do
                        local d = math.sqrt(xi * xi + yi * yi + zi * zi)
                        if d <= r and d >= r - t then
                            spawnPoint(origin, xi, yi + r, zi, conn2)
                        end
                        zi = zi + step
                    end
                    yi = yi + step
                end
                xi = xi + step
            end
            local eyeR = math.floor(r * 0.28)
            local leftEyeX = -math.floor(r * 0.4)
            local rightEyeX = math.floor(r * 0.4)
            for x = -eyeR, eyeR do
                for y = -eyeR, eyeR do
                    local d = math.sqrt(x * x + y * y)
                    if d <= eyeR then
                        spawnPoint(origin, leftEyeX + x, r * 0.8 + y, -r + 1, conn2)
                        spawnPoint(origin, rightEyeX + x, r * 0.8 + y, -r + 1, conn2)
                    end
                end
            end

        elseif selectedShape == "📡 Satellite Dish" then
            for x = -r, r do
                for z = -r, r do
                    local d = math.sqrt(x * x + z * z)
                    if d <= r then
                        local y = math.floor(d * d / r * 0.5)
                        if y <= math.floor(r * 0.6) then
                            spawnPoint(origin, x, y, z, conn2)
                        end
                    end
                end
            end
            for angle = 0, 360, 4 do
                local rad = math.rad(angle)
                spawnPoint(origin, math.floor(r * math.cos(rad)), math.floor(r * 0.5), math.floor(r * math.sin(rad)), conn2)
            end
            for y = -r, 0 do
                spawnPoint(origin, 0, y, 0, conn2)
            end
            for x = -2, 2 do
                spawnPoint(origin, x, -r, 0, conn2)
                spawnPoint(origin, x, -r, 2, conn2)
            end

        elseif selectedShape == "🕸️ Spider Web" then
            local spokes = 8
            for i = 0, spokes - 1 do
                local angle = math.rad(i * (360 / spokes))
                for dist = 0, r do
                    spawnPoint(origin, math.floor(dist * math.cos(angle)), 0, math.floor(dist * math.sin(angle)), conn2)
                end
            end
            local rings = 5
            for ring = 1, rings do
                local ringR = math.floor(ring * (r / rings))
                for angle = 0, 360, 6 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, math.floor(ringR * math.cos(rad)), 0, math.floor(ringR * math.sin(rad)), conn2)
                end
            end

        elseif selectedShape == "🐚 Triple Helix" then
            for i = 0, r * 20 do
                local angle = i * 0.2
                local height = i * 0.1
                for strand = 0, 2 do
                    local offset = strand * (math.pi * 2 / 3)
                    spawnPoint(origin, math.floor(r * 0.4 * math.cos(angle + offset)), math.floor(height), math.floor(r * 0.4 * math.sin(angle + offset)), conn2)
                end
            end

        elseif selectedShape == "🏹 Arrow" then
            for y = 0, r * 2 do
                spawnPoint(origin, 0, y, 0, conn2)
            end
            for layer = 0, r do
                local lr = r - layer
                for x = -lr, lr do
                    if math.abs(x) == lr or layer == 0 then
                        spawnPoint(origin, x, r * 2 + layer, 0, conn2)
                    end
                end
            end
            for x = -math.floor(r * 0.5), math.floor(r * 0.5) do
                spawnPoint(origin, x, math.floor(r * 0.2), 0, conn2)
            end
            for x = -math.floor(r * 0.3), math.floor(r * 0.3) do
                spawnPoint(origin, x, 0, 0, conn2)
            end

        elseif selectedShape == "🔔 Bell" then
            local step = 0.9
            local xi = -r
            while xi <= r do
                local yi = 0
                while yi <= r do
                    local zi = -r
                    while zi <= r do
                        local dx = xi
                        local dz = zi
                        local horizD = math.sqrt(dx * dx + dz * dz)
                        local bellR = r * (0.3 + 0.7 * math.sqrt(yi / r))
                        if math.abs(horizD - bellR) < 1.5 then
                            spawnPoint(origin, xi, yi, zi, conn2)
                        end
                        zi = zi + step
                    end
                    yi = yi + step
                end
                xi = xi + step
            end
            for angle = 0, 360, 4 do
                local rad = math.rad(angle)
                spawnPoint(origin, math.floor(r * math.cos(rad)), 0, math.floor(r * math.sin(rad)), conn2)
            end
            for y = -math.floor(r * 0.3), -1 do
                spawnPoint(origin, 0, y, 0, conn2)
            end
            local clapperY = -math.floor(r * 0.3) - 1
            spawnPoint(origin, 0, clapperY, 0, conn2)
            spawnPoint(origin, 1, clapperY, 0, conn2)
            spawnPoint(origin, -1, clapperY, 0, conn2)

        elseif selectedShape == "🛸 UFO" then
            for x = -r, r do
                for z = -r, r do
                    local d = math.sqrt(x * x + z * z)
                    if d <= r then
                        local diskH = math.floor(math.sqrt(math.max(0, 1 - (d / r) ^ 2)) * r * 0.25)
                        for y = -diskH, diskH do
                            spawnPoint(origin, x, y, z, conn2)
                        end
                    end
                end
            end
            local dR = math.floor(r * 0.45)
            local step = 0.9
            local xi = -dR
            while xi <= dR do
                local yi = 0
                while yi <= dR do
                    local zi = -dR
                    while zi <= dR do
                        local d = math.sqrt(xi * xi + yi * yi + zi * zi)
                        if d <= dR and d >= dR - t and yi >= 0 then
                            spawnPoint(origin, xi, yi + math.floor(r * 0.25), zi, conn2)
                        end
                        zi = zi + step
                    end
                    yi = yi + step
                end
                xi = xi + step
            end
            for angle = 0, 360, 15 do
                local rad = math.rad(angle)
                spawnPoint(origin, math.floor((r - 1) * math.cos(rad)), 0, math.floor((r - 1) * math.sin(rad)), conn2)
            end

        elseif selectedShape == "🌀 Klein" then
            local tubeR = math.floor(r * 0.2)
            for i = 0, math.floor(math.pi * 2 * 100) do
                local t2 = i / 100
                local cx = r * math.cos(t2) * (1 + math.sin(t2) * 0.5)
                local cy = r * math.sin(t2)
                local cz = r * math.cos(t2) * 0.5
                for j = 0, math.floor(math.pi * 2 * 10) do
                    local phi = j / 10
                    local nx = math.cos(phi)
                    local ny = math.sin(phi)
                    spawnPoint(origin, math.floor(cx + tubeR * nx), math.floor(cy + tubeR * ny), math.floor(cz), conn2)
                end
            end

        elseif selectedShape == "⚓ Anchor" then
            local ringR = math.floor(r * 0.3)
            for angle = 0, 360, 8 do
                local rad = math.rad(angle)
                spawnPoint(origin, math.floor(ringR * math.cos(rad)), r * 2 - 1 + math.floor(ringR * 0.3 * math.sin(rad)), 0, conn2)
            end
            for y = 0, r * 2 do
                spawnPoint(origin, 0, y, 0, conn2)
            end
            for x = -math.floor(r * 0.7), math.floor(r * 0.7) do
                spawnPoint(origin, x, math.floor(r * 1.4), 0, conn2)
            end
            for side = -1, 1, 2 do
                for angle = 0, 90, 5 do
                    local rad = math.rad(angle)
                    local ax = math.floor(side * math.floor(r * 0.6) * math.sin(rad))
                    local ay = math.floor(r * 0.6 * math.cos(rad)) - math.floor(r * 0.6)
                    spawnPoint(origin, ax, ay, 0, conn2)
                end
            end

        elseif selectedShape == "🧱 Brick Wall" then
            local wallW = r * 2
            local wallH = r
            for y = 0, wallH do
                local offset = (y % 2 == 0) and 0 or 2
                for x = -wallW, wallW, 4 do
                    for bx = 0, 3 do
                        spawnPoint(origin, x + bx + offset, y, 0, conn2)
                    end
                end
                spawnPoint(origin, 0, y, 1, conn2)
            end

        elseif selectedShape == "🔵 Bubble Cluster" then
            local bubbles = {
                {0, 0, 0, math.floor(r * 0.5)},
                {r, 0, 0, math.floor(r * 0.4)},
                {-r, 0, 0, math.floor(r * 0.35)},
                {0, r, 0, math.floor(r * 0.3)},
                {math.floor(r * 0.6), math.floor(r * 0.6), 0, math.floor(r * 0.25)},
                {-math.floor(r * 0.5), math.floor(r * 0.7), 0, math.floor(r * 0.2)},
                {0, -math.floor(r * 0.6), math.floor(r * 0.4), math.floor(r * 0.3)},
            }
            for _, bubble in pairs(bubbles) do
                local bx = bubble[1]
                local by = bubble[2]
                local bz = bubble[3]
                local br = bubble[4]
                local step = 0.9
                local xi = -br
                while xi <= br do
                    local yi = -br
                    while yi <= br do
                        local zi = -br
                        while zi <= br do
                            local d = math.sqrt(xi * xi + yi * yi + zi * zi)
                            if d <= br and d >= br - t then
                                spawnPoint(origin, bx + math.floor(xi), by + math.floor(yi) + br, bz + math.floor(zi), conn2)
                            end
                            zi = zi + step
                        end
                        yi = yi + step
                    end
                    xi = xi + step
                end
            end

        elseif selectedShape == "🌋 Volcano" then
            local baseR = r
            local topR = math.floor(r * 0.4)
            local height = math.floor(r * 1.5)
            for y = 0, height do
                local prog = y / height
                local lr = math.floor(baseR - (baseR - topR) * prog)
                for angle = 0, 360, 5 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, math.floor(lr * math.cos(rad)), y, math.floor(lr * math.sin(rad)), conn2)
                end
            end
            local craterDepth = math.floor(r * 0.5)
            for y = height, height - craterDepth, -1 do
                local prog = (height - y) / craterDepth
                local cr = math.floor(topR * 0.2 + topR * 0.5 * prog)
                for angle = 0, 360, 8 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, math.floor(cr * math.cos(rad)), y, math.floor(cr * math.sin(rad)), conn2)
                end
            end

        elseif selectedShape == "🎄 Christmas Tree" then
            local trunkW = math.max(1, math.floor(r * 0.12))
            local trunkH = math.floor(r * 0.3)
            for y = 0, trunkH do
                for x = -trunkW, trunkW do
                    for z = -trunkW, trunkW do
                        spawnPoint(origin, x, y, z, conn2)
                    end
                end
            end
            local layers = 4
            for layer = 0, layers - 1 do
                local coneR = math.floor(r * (1 - layer * 0.18))
                local coneBase = trunkH + layer * math.floor(r * 0.45)
                local coneH = math.floor(r * 0.55)
                for y = 0, coneH do
                    local lr = math.floor(coneR * (1 - y / coneH))
                    if lr < 1 then lr = 1 end
                    for x = -lr, lr do
                        for z = -lr, lr do
                            if math.sqrt(x * x + z * z) <= lr then
                                spawnPoint(origin, x, coneBase + y, z, conn2)
                            end
                        end
                    end
                end
            end
            local starY = trunkH + layers * math.floor(r * 0.45) + math.floor(r * 0.55)
            for angle = 0, 360, 36 do
                local rad = math.rad(angle)
                local lobeT = (math.cos(5 * rad) + 1) / 2
                local sr = math.floor(r * 0.15) + math.floor(r * 0.15) * lobeT
                spawnPoint(origin, math.floor(sr * math.cos(rad)), starY, math.floor(sr * math.sin(rad)), conn2)
            end
            spawnPoint(origin, 0, starY, 0, conn2)

        elseif selectedShape == "🎯 Target" then
            local rings = 5
            for ring = 1, rings do
                local ringR = math.floor(ring * (r / rings))
                for angle = 0, 360, 4 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, math.floor(ringR * math.cos(rad)), 0, math.floor(ringR * math.sin(rad)), conn2)
                end
            end
            spawnPoint(origin, 0, 0, 0, conn2)
            for x = -r, r do
                spawnPoint(origin, x, 0, 0, conn2)
            end
            for z = -r, r do
                spawnPoint(origin, 0, 0, z, conn2)
            end

        elseif selectedShape == "🌀 Galaxy Spiral" then
            local arms = 3
            for arm = 0, arms - 1 do
                local armOffset = (arm / arms) * math.pi * 2
                for i = 0, r * 15 do
                    local angle = i * 0.25 + armOffset
                    local dist = i * (r / (r * 15))
                    local x = math.floor(dist * math.cos(angle))
                    local z = math.floor(dist * math.sin(angle))
                    spawnPoint(origin, x, 0, z, conn2)
                end
            end
            for angle = 0, 360, 6 do
                local rad = math.rad(angle)
                spawnPoint(origin, math.floor(math.floor(r * 0.15) * math.cos(rad)), 0, math.floor(math.floor(r * 0.15) * math.sin(rad)), conn2)
            end

        elseif selectedShape == "🧊 Iceberg" then
            local step = 0.9
            local xi = -r
            while xi <= r do
                local yi = -r
                while yi <= r do
                    local zi = -r
                    while zi <= r do
                        local d = math.sqrt(xi * xi + yi * yi + zi * zi)
                        if d <= r and d >= r - t then
                            if yi + r >= r then
                                spawnPoint(origin, xi, yi + r, zi, conn2)
                            end
                        end
                        zi = zi + step
                    end
                    yi = yi + step
                end
                xi = xi + step
            end
            for x = -r, r do
                for z = -r, r do
                    if math.sqrt(x * x + z * z) <= r then
                        spawnPoint(origin, x, r, z, conn2)
                    end
                end
            end

        elseif selectedShape == "💣 Bomb" then
            local bombR = r
            local step = 0.9
            local xi = -bombR
            while xi <= bombR do
                local yi = -bombR
                while yi <= bombR do
                    local zi = -bombR
                    while zi <= bombR do
                        local d = math.sqrt(xi * xi + yi * yi + zi * zi)
                        if d <= bombR and d >= bombR - t then
                            spawnPoint(origin, xi, yi + bombR, zi, conn2)
                        end
                        zi = zi + step
                    end
                    yi = yi + step
                end
                xi = xi + step
            end
            for y = bombR * 2, bombR * 2 + math.floor(r * 0.5) do
                spawnPoint(origin, 0, y, 0, conn2)
            end
            for y = bombR * 2 + math.floor(r * 0.5), bombR * 2 + math.floor(r * 0.8) do
                spawnPoint(origin, math.floor((y - bombR * 2 - math.floor(r * 0.5)) * 0.5), y, 0, conn2)
            end

        elseif selectedShape == "🔑 Key" then
            local keyR = math.floor(r * 0.5)
            for angle = 0, 360, 6 do
                local rad = math.rad(angle)
                spawnPoint(origin, math.floor(keyR * math.cos(rad)), r * 2 + math.floor(keyR * math.sin(rad)), 0, conn2)
            end
            local innerR = math.floor(keyR * 0.5)
            for angle = 0, 360, 8 do
                local rad = math.rad(angle)
                spawnPoint(origin, math.floor(innerR * math.cos(rad)), r * 2 + math.floor(innerR * math.sin(rad)), 0, conn2)
            end
            for y = 0, r * 2 do
                spawnPoint(origin, 0, y, 0, conn2)
            end
            for x = 0, math.floor(r * 0.4) do
                spawnPoint(origin, x, math.floor(r * 0.4), 0, conn2)
                spawnPoint(origin, x, math.floor(r * 0.7), 0, conn2)
            end
            for y = math.floor(r * 0.4), math.floor(r * 0.7) do
                spawnPoint(origin, math.floor(r * 0.4), y, 0, conn2)
            end

        elseif selectedShape == "🐍 Snake" then
            local segLen = math.floor(r * 0.5)
            local amplitude = math.floor(r * 0.6)
            local totalH = r * 3
            for y = 0, totalH do
                local prog = y / totalH
                local x = math.floor(math.sin(prog * math.pi * 6) * amplitude)
                spawnPoint(origin, x, y, 0, conn2)
                spawnPoint(origin, x + 1, y, 0, conn2)
                spawnPoint(origin, x - 1, y, 0, conn2)
            end
            local headY = totalH
            local headX = math.floor(math.sin((totalH / totalH) * math.pi * 6) * amplitude)
            for hx = headX - 2, headX + 2 do
                for hy = headY, headY + 3 do
                    spawnPoint(origin, hx, hy, 0, conn2)
                end
            end
            spawnPoint(origin, headX - 3, headY + 1, 0, conn2)
            spawnPoint(origin, headX + 3, headY + 1, 0, conn2)

        elseif selectedShape == "✈️ Airplane" then
            -- fuselage runs along Z axis (forward) so plane points forward
            local fuseL = r * 2
            local fuseR = math.max(2, math.floor(r * 0.18))
            -- hollow cylindrical fuselage along Z
            for z = 0, fuseL do
                for angle = 0, 360, 10 do
                    local rad = math.rad(angle)
                    local x = math.floor(fuseR * math.cos(rad))
                    local y = math.floor(fuseR * math.sin(rad))
                    spawnPoint(origin, x, y + fuseR, z, conn2)
                end
            end
            -- nose cone at front (high Z)
            for layer = 0, fuseR do
                local nr = fuseR - layer
                for angle = 0, 360, 12 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, math.floor(nr * math.cos(rad)), math.floor(nr * math.sin(rad)) + fuseR, fuseL + layer, conn2)
                end
            end
            -- main wings spread along X, attached at mid-Z
            local wingSpan = math.floor(r * 1.4)
            local wingZ = math.floor(fuseL * 0.4)
            for wx = fuseR, wingSpan do
                local sweep = math.floor((wx - fuseR) * 0.3)
                local wingThick = math.max(1, math.floor((wingSpan - wx) * 0.12))
                for wy = -wingThick, wingThick do
                    if math.abs(wy) == wingThick or wy == 0 then
                        spawnPoint(origin, wx, wy + fuseR, wingZ + sweep, conn2)
                        spawnPoint(origin, -wx, wy + fuseR, wingZ + sweep, conn2)
                    end
                end
            end
            -- horizontal tail fins at back (low Z)
            local tailSpan = math.floor(r * 0.6)
            local tailZ = math.floor(fuseL * 0.1)
            for tx = fuseR, tailSpan do
                local tsweep = math.floor((tx - fuseR) * 0.4)
                local tailThick = math.max(1, math.floor((tailSpan - tx) * 0.1))
                for ty = -tailThick, tailThick do
                    if math.abs(ty) == tailThick or ty == 0 then
                        spawnPoint(origin, tx, ty + fuseR, tailZ + tsweep, conn2)
                        spawnPoint(origin, -tx, ty + fuseR, tailZ + tsweep, conn2)
                    end
                end
            end
            -- vertical tail fin sticks up from back
            for vy = 1, math.floor(r * 0.55) do
                local vsweep = math.floor(vy * 0.3)
                spawnPoint(origin, 0, fuseR + fuseR + vy, tailZ + vsweep, conn2)
                spawnPoint(origin, 1, fuseR + fuseR + vy, tailZ + vsweep, conn2)
                spawnPoint(origin, -1, fuseR + fuseR + vy, tailZ + vsweep, conn2)
            end
            -- hollow engine cylinders hanging under wings
            local engR = math.max(1, math.floor(fuseR * 0.6))
            local engX = math.floor(wingSpan * 0.5)
            local engZ = wingZ
            for ez = 0, math.floor(r * 0.4) do
                for angle = 0, 360, 15 do
                    local rad = math.rad(angle)
                    local ex = math.floor(engR * math.cos(rad))
                    local ey = math.floor(engR * math.sin(rad))
                    spawnPoint(origin, engX + ex, ey + fuseR - fuseR, engZ + ez, conn2)
                    spawnPoint(origin, -engX + ex, ey + fuseR - fuseR, engZ + ez, conn2)
                end
            end

        elseif selectedShape == "🐉 Dragon" then
            local tubeR = math.max(2, math.floor(r * 0.15))

            local function hollowTube(x1, y1, z1, x2, y2, z2, tr)
                local dx = x2 - x1
                local dy = y2 - y1
                local dz = z2 - z1
                local segLen = math.max(1, math.floor(math.sqrt(dx*dx + dy*dy + dz*dz)))
                for i = 0, segLen do
                    local frac = i / segLen
                    local cx = math.floor(x1 + dx * frac)
                    local cy = math.floor(y1 + dy * frac)
                    local cz = math.floor(z1 + dz * frac)
                    for angle = 0, 360, 15 do
                        local rad = math.rad(angle)
                        spawnPoint(origin, cx + math.floor(tr * math.cos(rad)), cy, cz + math.floor(tr * math.sin(rad)), conn2)
                    end
                end
            end

            -- body spine segments forming S-curve
            hollowTube(0, 0, 0,                        0, r, 0,                      tubeR)
            hollowTube(0, r, 0,                        math.floor(r*0.4), r*2, math.floor(r*0.2), tubeR)
            hollowTube(math.floor(r*0.4), r*2, math.floor(r*0.2), 0, r*3, 0,        tubeR)
            hollowTube(0, r*3, 0,                      -math.floor(r*0.3), r*4, 0,   tubeR)

            -- neck thinner
            local neckR = math.max(1, math.floor(tubeR * 0.75))
            hollowTube(-math.floor(r*0.3), r*4, 0,    math.floor(r*0.3), r*4+math.floor(r*0.8), math.floor(r*0.3), neckR)

            -- hollow sphere head
            local headX = math.floor(r*0.3)
            local headY = r*4 + math.floor(r*0.8)
            local headZ = math.floor(r*0.3)
            local headR = math.max(2, math.floor(tubeR * 1.6))
            local hstep = 0.9
            local hxi = -headR
            while hxi <= headR do
                local hyi = -headR
                while hyi <= headR do
                    local hzi = -headR
                    while hzi <= headR do
                        local hd = math.sqrt(hxi*hxi + hyi*hyi + hzi*hzi)
                        if hd <= headR and hd >= headR - t then
                            spawnPoint(origin, headX + math.floor(hxi), headY + math.floor(hyi), headZ + math.floor(hzi), conn2)
                        end
                        hzi = hzi + hstep
                    end
                    hyi = hyi + hstep
                end
                hxi = hxi + hstep
            end

            -- hollow snout
            local snoutL = math.floor(headR * 1.2)
            local snoutR = math.max(1, math.floor(headR * 0.5))
            for sy = 0, snoutL do
                local sr = math.max(1, math.floor(snoutR * (1 - sy / snoutL * 0.5)))
                for angle = 0, 360, 20 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, headX + math.floor(sr * math.cos(rad)), headY - headR + math.floor(sr * 0.3), headZ + snoutL + sy + math.floor(sr * math.sin(rad)), conn2)
                end
            end

            -- horns
            for hy2 = 0, math.floor(r * 0.35) do
                spawnPoint(origin, headX - math.floor(headR*0.5), headY + headR + hy2, headZ + math.floor(hy2*0.4), conn2)
                spawnPoint(origin, headX + math.floor(headR*0.5), headY + headR + hy2, headZ + math.floor(hy2*0.4), conn2)
            end

            -- hollow swept wings
            local wingBaseY2 = math.floor(r * 1.5)
            local wingSpan2 = math.floor(r * 1.2)
            for wx = 0, wingSpan2 do
                local prog = wx / wingSpan2
                local wingSweepY = math.floor(prog * r * 0.5)
                local wingSweepZ = math.floor(prog * r * 0.2)
                local wingThick = math.max(1, math.floor((1 - prog) * tubeR * 0.8))
                for wt = -wingThick, wingThick do
                    if math.abs(wt) == wingThick then
                        spawnPoint(origin, tubeR + wx, wingBaseY2 + wingSweepY, wt + wingSweepZ, conn2)
                        spawnPoint(origin, -(tubeR + wx), wingBaseY2 + wingSweepY, wt + wingSweepZ, conn2)
                    end
                end
                spawnPoint(origin, tubeR + wx, wingBaseY2 + wingSweepY, wingSweepZ, conn2)
                spawnPoint(origin, -(tubeR + wx), wingBaseY2 + wingSweepY, wingSweepZ, conn2)
            end

            -- tail spike hollow cone
            for ty = 0, math.floor(r * 0.8) do
                local tailProgR = math.max(1, math.floor(tubeR * (1 - ty / (r * 0.8))))
                for angle = 0, 360, 20 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, -math.floor(r*0.3) + math.floor(tailProgR*math.cos(rad)), r*4 - ty, math.floor(tailProgR*math.sin(rad)), conn2)
                end
            end

            -- hollow leg stubs
            local legR = math.max(1, math.floor(tubeR * 0.6))
            local legL = math.floor(r * 0.4)
            local legPositions = {
                {math.floor(tubeR*0.8), math.floor(r*0.6), 0},
                {-math.floor(tubeR*0.8), math.floor(r*0.6), 0},
                {math.floor(tubeR*0.8), math.floor(r*2.2), 0},
                {-math.floor(tubeR*0.8), math.floor(r*2.2), 0},
            }
            for _, legPos in pairs(legPositions) do
                for ly = 0, legL do
                    for angle = 0, 360, 20 do
                        local rad = math.rad(angle)
                        spawnPoint(origin, legPos[1] + math.floor(legR*math.cos(rad)), legPos[2] - ly, legPos[3] + math.floor(legR*math.sin(rad)), conn2)
                    end
                end
                for cx2 = -legR, legR do
                    for cz2 = -legR, legR do
                        if math.sqrt(cx2*cx2 + cz2*cz2) <= legR then
                            spawnPoint(origin, legPos[1] + cx2, legPos[2] - legL, legPos[3] + cz2, conn2)
                        end
                    end
                end
            end

        elseif selectedShape == "🪜 Staircase" then
            local stepW = math.max(2, math.floor(r * 0.6))
            for step = 0, r - 1 do
                for x = -stepW, stepW do
                    spawnPoint(origin, x, step, step, conn2)
                    spawnPoint(origin, x, step - 1, step, conn2)
                end
            end

        elseif selectedShape == "🚀 Rocket" then
            local bodyH = math.floor(r * 2)
            local bodyR = math.max(2, math.floor(r * 0.35))
            for y = 0, bodyH do
                for angle = 0, 360, 12 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, math.floor(bodyR * math.cos(rad)), y, math.floor(bodyR * math.sin(rad)), conn2)
                end
            end
            for layer = 0, math.floor(r * 0.8) do
                local nr = math.floor(bodyR * (1 - layer / math.floor(r * 0.8)))
                if nr < 1 then
                    spawnPoint(origin, 0, bodyH + layer, 0, conn2)
                else
                    for angle = 0, 360, 15 do
                        local rad = math.rad(angle)
                        spawnPoint(origin, math.floor(nr * math.cos(rad)), bodyH + layer, math.floor(nr * math.sin(rad)), conn2)
                    end
                end
            end
            for _, dir in pairs({{1, 0}, {-1, 0}, {0, 1}, {0, -1}}) do
                for fy = 0, math.floor(r * 0.6) do
                    local fw = math.floor(math.floor(r * 0.5) * (1 - fy / math.floor(r * 0.6)))
                    for fi = 0, fw do
                        spawnPoint(origin, dir[1] * (bodyR + fi), fy, dir[2] * (bodyR + fi), conn2)
                    end
                end
            end

        elseif selectedShape == "🎸 Guitar" then
            local bodyR1 = math.floor(r * 0.55)
            local bodyR2 = math.floor(r * 0.4)
            local body2Y = math.floor(r * 0.9)
            for angle = 0, 360, 5 do
                local rad = math.rad(angle)
                spawnPoint(origin, math.floor(bodyR1 * math.cos(rad)), 0, math.floor(bodyR1 * math.sin(rad)), conn2)
                spawnPoint(origin, math.floor(bodyR2 * math.cos(rad)), body2Y, math.floor(bodyR2 * math.sin(rad)), conn2)
            end
            local neckW = math.max(1, math.floor(r * 0.1))
            local neckStart = body2Y + bodyR2
            local neckH = math.floor(r * 1.2)
            for y = neckStart, neckStart + neckH do
                for x = -neckW, neckW do
                    spawnPoint(origin, x, y, 0, conn2)
                end
            end
            local headW = math.floor(r * 0.3)
            local headH = math.floor(r * 0.2)
            local headY = neckStart + neckH
            for y = headY, headY + headH do
                for x = -headW, headW do
                    spawnPoint(origin, x, y, 0, conn2)
                end
            end

        elseif selectedShape == "💠 Hex Prism" then
            local hexR = r
            local height = math.floor(r * 1.5)
            for y = 0, height do
                for angle = 0, 300, 60 do
                    local rad1 = math.rad(angle)
                    local rad2 = math.rad(angle + 60)
                    local x1 = math.floor(hexR * math.cos(rad1))
                    local z1 = math.floor(hexR * math.sin(rad1))
                    local x2 = math.floor(hexR * math.cos(rad2))
                    local z2 = math.floor(hexR * math.sin(rad2))
                    local steps = math.max(1, math.floor(math.sqrt((x2 - x1) ^ 2 + (z2 - z1) ^ 2)))
                    for i = 0, steps do
                        local frac = i / steps
                        spawnPoint(origin, math.floor(x1 + (x2 - x1) * frac), y, math.floor(z1 + (z2 - z1) * frac), conn2)
                    end
                end
            end

        elseif selectedShape == "🏟️ Stadium" then
            local semiA = r
            local semiB = math.floor(r * 0.6)
            local wallH = math.floor(r * 0.5)
            for angle = 0, 360, 3 do
                local rad = math.rad(angle)
                local ox = math.floor(semiA * math.cos(rad))
                local oz = math.floor(semiB * math.sin(rad))
                for y = 0, wallH do
                    spawnPoint(origin, ox, y, oz, conn2)
                end
            end
            for x = -semiA, semiA do
                for z = -semiB, semiB do
                    if (x / semiA) ^ 2 + (z / semiB) ^ 2 <= 1 then
                        spawnPoint(origin, x, 0, z, conn2)
                    end
                end
            end

        elseif selectedShape == "🎃 Pumpkin" then
            local step = 0.85
            local xi = -r
            while xi <= r do
                local yi = -r
                while yi <= r do
                    local zi = -r
                    while zi <= r do
                        local d = math.sqrt(xi * xi + yi * yi + zi * zi)
                        if d <= r and d >= r - t then
                            local angle = math.deg(math.atan2(zi, xi))
                            local ridge = math.abs((angle % 60) - 30)
                            if ridge <= 8 then
                                spawnPoint(origin, math.floor(xi), math.floor(yi + r), math.floor(zi), conn2)
                            end
                        end
                        zi = zi + step
                    end
                    yi = yi + step
                end
                xi = xi + step
            end
            for y = r * 2, r * 2 + math.floor(r * 0.4) do
                spawnPoint(origin, 0, y, 0, conn2)
                spawnPoint(origin, 1, y, 0, conn2)
            end

        elseif selectedShape == "🤖 Robot" then
            local headW = math.floor(r * 0.45)
            local headH = math.floor(r * 0.4)
            local headY = math.floor(r * 1.6)
            for i = -headW, headW do
                for y = headY, headY + headH do
                    spawnPoint(origin, i, y, headW, conn2)
                    spawnPoint(origin, i, y, -headW, conn2)
                    spawnPoint(origin, headW, y, i, conn2)
                    spawnPoint(origin, -headW, y, i, conn2)
                end
            end
            local bodyW = math.floor(r * 0.6)
            local bodyH = math.floor(r * 0.8)
            local bodyY = math.floor(r * 0.7)
            for i = -bodyW, bodyW do
                for y = bodyY, bodyY + bodyH do
                    spawnPoint(origin, i, y, bodyW, conn2)
                    spawnPoint(origin, i, y, -bodyW, conn2)
                    spawnPoint(origin, bodyW, y, i, conn2)
                    spawnPoint(origin, -bodyW, y, i, conn2)
                end
            end
            local armH = math.floor(r * 0.7)
            for y = 0, armH do
                spawnPoint(origin, bodyW + 1, bodyY + bodyH - y, 0, conn2)
                spawnPoint(origin, -bodyW - 1, bodyY + bodyH - y, 0, conn2)
            end
            local legH = math.floor(r * 0.65)
            local legOff = math.floor(bodyW * 0.4)
            for y = 0, legH do
                spawnPoint(origin, legOff, bodyY - y, 0, conn2)
                spawnPoint(origin, -legOff, bodyY - y, 0, conn2)
            end

        elseif selectedShape == "🪤 Cage" then
            local cageW = r
            local cageH = math.floor(r * 1.5)
            local barSpacing = math.max(2, math.floor(r * 0.25))
            for y = 0, cageH do
                spawnPoint(origin, cageW, y, cageW, conn2)
                spawnPoint(origin, cageW, y, -cageW, conn2)
                spawnPoint(origin, -cageW, y, cageW, conn2)
                spawnPoint(origin, -cageW, y, -cageW, conn2)
            end
            for y = 0, cageH, barSpacing do
                for i = -cageW, cageW do
                    spawnPoint(origin, i, y, cageW, conn2)
                    spawnPoint(origin, i, y, -cageW, conn2)
                    spawnPoint(origin, cageW, y, i, conn2)
                    spawnPoint(origin, -cageW, y, i, conn2)
                end
            end
            for x = -cageW, cageW, barSpacing do
                for y = 0, cageH do
                    spawnPoint(origin, x, y, cageW, conn2)
                    spawnPoint(origin, x, y, -cageW, conn2)
                end
            end
            for z = -cageW, cageW, barSpacing do
                for y = 0, cageH do
                    spawnPoint(origin, cageW, y, z, conn2)
                    spawnPoint(origin, -cageW, y, z, conn2)
                end
            end
            for x = -cageW, cageW do
                for z = -cageW, cageW do
                    spawnPoint(origin, x, 0, z, conn2)
                end
            end

        elseif selectedShape == "⚙️ Gear" then
            local innerR = math.floor(r * 0.5)
            local outerR = r
            local toothCount = 10
            local gearH = math.max(1, t)
            for y = 0, gearH do
                for angle = 0, 360, 5 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, math.floor(innerR * math.cos(rad)), y, math.floor(innerR * math.sin(rad)), conn2)
                    spawnPoint(origin, math.floor(outerR * math.cos(rad)), y, math.floor(outerR * math.sin(rad)), conn2)
                end
                for spoke = 0, toothCount - 1 do
                    local srad = math.rad(spoke * (360 / toothCount))
                    for dist = innerR, outerR do
                        spawnPoint(origin, math.floor(dist * math.cos(srad)), y, math.floor(dist * math.sin(srad)), conn2)
                    end
                end
                for tooth = 0, toothCount - 1 do
                    local trad = math.rad(tooth * (360 / toothCount) + (360 / (toothCount * 2)))
                    local toothLen = math.floor(r * 0.25)
                    for td = 0, toothLen do
                        local tr2 = outerR + td
                        spawnPoint(origin, math.floor(tr2 * math.cos(trad)), y, math.floor(tr2 * math.sin(trad)), conn2)
                        spawnPoint(origin, math.floor(tr2 * math.cos(trad + math.rad(10))), y, math.floor(tr2 * math.sin(trad + math.rad(10))), conn2)
                    end
                end
            end

        elseif selectedShape == "🌊 Tsunami" then
            local wallW = r * 2
            local baseH = math.floor(r * 0.3)
            local peakH = math.floor(r * 1.8)
            for x = -wallW, wallW do
                local prog = (x + wallW) / (wallW * 2)
                local waveH = math.floor(baseH + (peakH - baseH) * math.sin(prog * math.pi))
                for y = 0, waveH do
                    spawnPoint(origin, x, y, 0, conn2)
                    spawnPoint(origin, x, y, 1, conn2)
                end
                if waveH > math.floor(peakH * 0.7) then
                    local curlAmount = math.floor((waveH - math.floor(peakH * 0.7)) * 0.6)
                    for curl = 0, curlAmount do
                        spawnPoint(origin, x, waveH, -curl, conn2)
                    end
                end
            end

        elseif selectedShape == "🏯 Pagoda" then
            local tiers = 5
            local baseW = r
            for tier = 0, tiers - 1 do
                local tw = baseW - tier * math.floor(r * 0.15)
                if tw < 1 then tw = 1 end
                local tierY = tier * math.floor(r * 0.55)
                local tierH = math.floor(r * 0.35)
                for y = tierY, tierY + tierH do
                    for i = -tw, tw do
                        spawnPoint(origin, i, y, tw, conn2)
                        spawnPoint(origin, i, y, -tw, conn2)
                        spawnPoint(origin, tw, y, i, conn2)
                        spawnPoint(origin, -tw, y, i, conn2)
                    end
                end
                local roofBase = tw + math.floor(r * 0.2)
                local roofTop = tierY + tierH
                for layer = 0, roofBase do
                    local lr = roofBase - layer
                    for i = -lr, lr do
                        spawnPoint(origin, i, roofTop + layer, lr, conn2)
                        spawnPoint(origin, i, roofTop + layer, -lr, conn2)
                        spawnPoint(origin, lr, roofTop + layer, i, conn2)
                        spawnPoint(origin, -lr, roofTop + layer, i, conn2)
                    end
                end
            end

        elseif selectedShape == "🌈 Rainbow Arch" then
            for angle = 0, 180, 3 do
                local rad = math.rad(angle)
                for tk = 0, t - 1 do
                    local ar = r - tk
                    for z = -t, t do
                        spawnPoint(origin, math.floor(ar * math.cos(rad)), math.floor(ar * math.sin(rad)), z, conn2)
                    end
                end
            end

        elseif selectedShape == "🦋 Butterfly" then
            for i = 0, 1080 do
                local theta = math.rad(i / 3)
                local scale = (math.exp(math.sin(theta)) - 2 * math.cos(4 * theta) + math.sin((2 * theta - math.pi) / 24) ^ 5) * r * 0.3
                spawnPoint(origin, math.floor(scale * math.sin(theta)), 0, math.floor(scale * math.cos(theta)), conn2)
            end

        elseif selectedShape == "🎡 Ferris Wheel" then
            for angle = 0, 360, 3 do
                local rad = math.rad(angle)
                for tk = 0, t - 1 do
                    spawnPoint(origin, math.floor((r - tk) * math.cos(rad)), math.floor((r - tk) * math.sin(rad)), 0, conn2)
                end
            end
            for i = 0, 7 do
                local rad = math.rad(i * 45)
                for dist = 0, r do
                    spawnPoint(origin, math.floor(dist * math.cos(rad)), math.floor(dist * math.sin(rad)), 0, conn2)
                end
            end
            for x = -2, 2 do
                for y = -2, 2 do
                    if math.sqrt(x * x + y * y) <= 2 then
                        spawnPoint(origin, x, y, 0, conn2)
                    end
                end
            end

        elseif selectedShape == "🧲 Magnet" then
            local armR = math.max(2, math.floor(r * 0.25))
            local armH = math.floor(r * 1.5)
            local sp = math.floor(r * 0.7)
            for _, ax in pairs({-sp, sp}) do
                for y = 0, armH do
                    for x = -armR, armR do
                        for z = -armR, armR do
                            if math.sqrt(x * x + z * z) <= armR then
                                spawnPoint(origin, ax + x, y, z, conn2)
                            end
                        end
                    end
                end
            end
            for angle = 0, 180, 5 do
                local rad = math.rad(angle)
                for tk = 0, armR do
                    spawnPoint(origin, math.floor(sp * math.cos(rad)), armH + math.floor(sp * math.sin(rad)) + tk, 0, conn2)
                end
            end

        elseif selectedShape == "💫 Comet" then
            local hR = math.floor(r * 0.4)
            local step2 = 0.9
            local xi = -hR
            while xi <= hR do
                local yi = -hR
                while yi <= hR do
                    local zi = -hR
                    while zi <= hR do
                        local d = math.sqrt(xi * xi + yi * yi + zi * zi)
                        if d <= hR and d >= hR - t then
                            spawnPoint(origin, xi, yi + hR * 2, zi, conn2)
                        end
                        zi = zi + step2
                    end
                    yi = yi + step2
                end
                xi = xi + step2
            end
            for i = 0, r * 2 do
                local spread = math.floor(i * 0.4)
                local ht = hR * 2 - i
                for x = -spread, spread do
                    if math.random() < 0.5 then
                        spawnPoint(origin, x, math.floor(ht), 0, conn2)
                    end
                end
            end

        elseif selectedShape == "🎪 Circus Tent" then
            local cH = math.floor(r * 1.4)
            for y = 0, cH do
                local lr = math.floor(r * (1 - y / cH))
                if lr < 1 then lr = 1 end
                for angle = 0, 360, 6 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, math.floor(lr * math.cos(rad)), y, math.floor(lr * math.sin(rad)), conn2)
                end
            end
            for y = cH, cH + math.floor(r * 0.3) do
                spawnPoint(origin, 0, y, 0, conn2)
            end
            for i = 0, 5 do
                local rad = math.rad(i * 60)
                local px = math.floor(r * math.cos(rad))
                local pz = math.floor(r * math.sin(rad))
                for y = 0, math.floor(r * 0.5) do
                    spawnPoint(origin, px, -y, pz, conn2)
                end
            end

        elseif selectedShape == "🔩 Screw" then
            local sR = math.floor(r * 0.3)
            local sH = r * 3
            for y = 0, sH do
                for angle = 0, 360, 15 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, math.floor(sR * math.cos(rad)), y, math.floor(sR * math.sin(rad)), conn2)
                end
            end
            local tR = sR + t
            for i = 0, sH * 4 do
                local a = i * (math.pi * 2 / 4)
                local y2 = i / 4
                spawnPoint(origin, math.floor(tR * math.cos(a)), math.floor(y2), math.floor(tR * math.sin(a)), conn2)
            end
            for x = -sR * 2, sR * 2 do
                for z = -sR * 2, sR * 2 do
                    if math.sqrt(x * x + z * z) <= sR * 1.8 then
                        spawnPoint(origin, x, sH, z, conn2)
                        spawnPoint(origin, x, sH + 1, z, conn2)
                    end
                end
            end

        elseif selectedShape == "🏄 Pipe Wave" then
            local pR = math.max(2, math.floor(r * 0.3))
            for x = -r * 2, r * 2 do
                local cy = math.floor(math.sin(x * 0.2) * r * 0.5)
                for angle = 0, 360, 15 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, x, cy + math.floor(pR * math.sin(rad)), math.floor(pR * math.cos(rad)), conn2)
                end
            end

        elseif selectedShape == "🌀 Mobius" then
            for u = 0, 360, 4 do
                for v = -t, t do
                    local uR = math.rad(u)
                    local vF = v / (t * 2 + 1)
                    local x = (r + vF * math.cos(uR / 2)) * math.cos(uR)
                    local y = vF * math.sin(uR / 2)
                    local z = (r + vF * math.cos(uR / 2)) * math.sin(uR)
                    spawnPoint(origin, math.floor(x), math.floor(y + r * 0.3), math.floor(z), conn2)
                end
            end

        elseif selectedShape == "🎋 Bamboo" then
            local bR = math.max(2, math.floor(r * 0.18))
            local bH = r * 3
            local seg = math.max(3, math.floor(r * 0.4))
            for y = 0, bH do
                local nR = (y % seg < 2) and bR + 1 or bR
                for angle = 0, 360, 12 do
                    local rad = math.rad(angle)
                    spawnPoint(origin, math.floor(nR * math.cos(rad)), y, math.floor(nR * math.sin(rad)), conn2)
                end
            end
            for i = 1, math.floor(bH / seg) do
                local lY = i * seg
                local side = (i % 2 == 0) and 1 or -1
                for l = 0, math.floor(r * 0.5) do
                    spawnPoint(origin, side * (bR + l), lY + l, 0, conn2)
                end
            end
        end
    end


    -- ============================================================
    -- BUILD TYPE SELECTOR
    -- ============================================================
    addButton(s, "🧱 Spawn Test Block", Color3.fromRGB(60, 60, 60), function()
        local hrp = getHRP()
        if not hrp then return end
        spawnBlock(hrp.CFrame * CFrame.new(0, 8, 0))
    end)

    addButton(s, "🔨 Build Shape (Free)", Color3.fromRGB(40, 100, 40), function()
        local hrp = getHRP()
        if not hrp then return end
        spawnQueue = {}
        buildShape(hrp.CFrame, {})
        flushQueue({})
        notify("Building " .. selectedShape .. "...")
    end)

    addButton(s, "🔨 Build Shape → Baseplate", Color3.fromRGB(30, 60, 130), function()
        local hrp = getHRP()
        if not hrp then return end
        local plate = getBaseplate()
        spawnQueue = {}
        if plate then
            buildShape(hrp.CFrame, {plate})
            flushQueue({plate})
        else
            buildShape(hrp.CFrame, {})
            flushQueue({})
        end
        notify("Building " .. selectedShape .. " → baseplate")
    end)

    addButton(s, "🔨 Build on MY HRP ⚠️", Color3.fromRGB(100, 30, 80), function()
        local hrp = getHRP()
        if not hrp then return end
        spawnQueue = {}
        buildShape(hrp.CFrame, {hrp})
        flushQueue({hrp})
    end)

    addButton(s, "🎲 Random Shape", Color3.fromRGB(80, 45, 110), function()
        local hrp = getHRP()
        if not hrp then return end
        local randomShape = shapes[math.random(1, #shapes)]
        selectedShape = randomShape
        shapeLabel.Text = "Shape: " .. randomShape
        for _, c in pairs(gridFrame:GetChildren()) do
            if c:IsA("TextButton") then
                if c.Text == randomShape then
                    c.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
                else
                    c.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                end
            end
        end
        spawnQueue = {}
        buildShape(hrp.CFrame, {})
        flushQueue({})
        notify("🎲 Building random: " .. randomShape)
    end)

    -- ============================================================
    -- SAVE / LOAD BUILD SYSTEM
    -- ============================================================
    addSection(s, "── 💾 Save / Load Build ──")

    local BUILD_SAVE_FILE = "smiley_hub_builds.json"
    local savedBuilds = {}

    local function loadSavedBuilds()
        pcall(function()
            if isfile and isfile(BUILD_SAVE_FILE) then
                local ok, data = pcall(function()
                    return HttpService:JSONDecode(readfile(BUILD_SAVE_FILE))
                end)
                if ok and data then
                    savedBuilds = data
                end
            end
        end)
    end

    local function saveBuildsToDisk()
        pcall(function()
            writefile(BUILD_SAVE_FILE, HttpService:JSONEncode(savedBuilds))
        end)
    end

    loadSavedBuilds()

    local saveBuildNameRow = Instance.new("Frame")
    saveBuildNameRow.Size = UDim2.new(1, 0, 0, 36)
    saveBuildNameRow.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    saveBuildNameRow.BorderSizePixel = 0
    saveBuildNameRow.Parent = s
    local saveBuildNameRowCorner = Instance.new("UICorner")
    saveBuildNameRowCorner.CornerRadius = UDim.new(0, 6)
    saveBuildNameRowCorner.Parent = saveBuildNameRow

    local saveBuildInput = Instance.new("TextBox")
    saveBuildInput.Size = UDim2.new(0.68, 0, 1, -8)
    saveBuildInput.Position = UDim2.new(0, 6, 0, 4)
    saveBuildInput.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    saveBuildInput.PlaceholderText = "Build save name..."
    saveBuildInput.Text = ""
    saveBuildInput.Font = Enum.Font.Gotham
    saveBuildInput.TextSize = 12
    saveBuildInput.TextColor3 = Color3.new(1, 1, 1)
    saveBuildInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    saveBuildInput.BorderSizePixel = 0
    saveBuildInput.ClearTextOnFocus = false
    saveBuildInput.Parent = saveBuildNameRow
    local saveBuildInputCorner = Instance.new("UICorner")
    saveBuildInputCorner.CornerRadius = UDim.new(0, 5)
    saveBuildInputCorner.Parent = saveBuildInput

    local saveBuildBtn = Instance.new("TextButton")
    saveBuildBtn.Size = UDim2.new(0.28, 0, 1, -8)
    saveBuildBtn.Position = UDim2.new(0.7, 2, 0, 4)
    saveBuildBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    saveBuildBtn.Text = "💾 Save"
    saveBuildBtn.Font = Enum.Font.GothamBold
    saveBuildBtn.TextSize = 12
    saveBuildBtn.TextColor3 = Color3.new(1, 1, 1)
    saveBuildBtn.BorderSizePixel = 0
    saveBuildBtn.AutoButtonColor = true
    saveBuildBtn.Parent = saveBuildNameRow
    local saveBuildBtnCorner = Instance.new("UICorner")
    saveBuildBtnCorner.CornerRadius = UDim.new(0, 5)
    saveBuildBtnCorner.Parent = saveBuildBtn

    -- the actual list of saved blocks is recorded during flushQueue

    saveBuildBtn.MouseButton1Click:Connect(function()
        local name = saveBuildInput.Text
        if name == "" then
            notify("Enter a build name first!", Color3.fromRGB(200, 50, 50))
            return
        end
        if #lastBuildRecord == 0 then
            notify("Build something first!", Color3.fromRGB(200, 50, 50))
            return
        end
        local buildData = {
            name = name,
            shape = selectedShape,
            size = shapeSize,
            thickness = shapeThickness,
            assetId = selectedAsset.id,
            assetGuid = selectedAsset.guid,
            points = lastBuildRecord,
        }
        savedBuilds[name] = buildData
        saveBuildsToDisk()
        notify("💾 Build '" .. name .. "' saved! (" .. #lastBuildRecord .. " blocks)", Color3.fromRGB(40, 200, 80))
    end)

    local buildsListFrame = Instance.new("Frame")
    buildsListFrame.Size = UDim2.new(1, 0, 0, 130)
    buildsListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    buildsListFrame.BorderSizePixel = 0
    buildsListFrame.Parent = s
    local buildsListCorner = Instance.new("UICorner")
    buildsListCorner.CornerRadius = UDim.new(0, 6)
    buildsListCorner.Parent = buildsListFrame

    local buildsScroll = Instance.new("ScrollingFrame")
    buildsScroll.Size = UDim2.new(1, -8, 1, -8)
    buildsScroll.Position = UDim2.new(0, 4, 0, 4)
    buildsScroll.BackgroundTransparency = 1
    buildsScroll.BorderSizePixel = 0
    buildsScroll.ScrollBarThickness = 3
    buildsScroll.ScrollBarImageColor3 = Color3.fromRGB(180, 140, 30)
    buildsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    buildsScroll.Parent = buildsListFrame

    local buildsLayout = Instance.new("UIListLayout")
    buildsLayout.Padding = UDim.new(0, 3)
    buildsLayout.Parent = buildsScroll
    buildsLayout.Changed:Connect(function()
        buildsScroll.CanvasSize = UDim2.new(0, 0, 0, buildsLayout.AbsoluteContentSize.Y + 6)
    end)

    local function refreshBuildsList()
        for _, v in pairs(buildsScroll:GetChildren()) do
            if v:IsA("Frame") then
                v:Destroy()
            end
        end
        for name, buildData in pairs(savedBuilds) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 28)
            row.BackgroundTransparency = 1
            row.Parent = buildsScroll

            local rowLayout = Instance.new("UIListLayout")
            rowLayout.FillDirection = Enum.FillDirection.Horizontal
            rowLayout.Padding = UDim.new(0, 3)
            rowLayout.Parent = row

            local loadBtn = Instance.new("TextButton")
            loadBtn.Size = UDim2.new(0.55, 0, 1, 0)
            loadBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 160)
            loadBtn.Text = "▶ " .. name
            loadBtn.Font = Enum.Font.GothamBold
            loadBtn.TextSize = 10
            loadBtn.TextColor3 = Color3.new(1, 1, 1)
            loadBtn.BorderSizePixel = 0
            loadBtn.AutoButtonColor = true
            loadBtn.Parent = row
            local loadBtnCorner = Instance.new("UICorner")
            loadBtnCorner.CornerRadius = UDim.new(0, 5)
            loadBtnCorner.Parent = loadBtn

            loadBtn.MouseButton1Click:Connect(function()
                local hrp = getHRP()
                if not hrp then return end
                local conn2 = {}
                local remote = game:GetService("ReplicatedStorage").Remotes.StampAsset
                local bid = buildData.assetId
                local bguid = buildData.assetGuid
                local origin = hrp.CFrame
                notify("▶ Loading build '" .. name .. "' (" .. #buildData.points .. " blocks)...")
                for _, pt in pairs(buildData.points) do
                    local cf = origin * CFrame.new(pt[1], pt[2], pt[3])
                    coroutine.wrap(function()
                        pcall(function()
                            remote:InvokeServer(bid, cf, bguid, conn2, 0)
                        end)
                    end)()
                end
            end)

            local deleteBtn = Instance.new("TextButton")
            deleteBtn.Size = UDim2.new(0.42, 0, 1, 0)
            deleteBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
            deleteBtn.Text = "🗑 Delete"
            deleteBtn.Font = Enum.Font.GothamBold
            deleteBtn.TextSize = 10
            deleteBtn.TextColor3 = Color3.new(1, 1, 1)
            deleteBtn.BorderSizePixel = 0
            deleteBtn.AutoButtonColor = true
            deleteBtn.Parent = row
            local deleteBtnCorner = Instance.new("UICorner")
            deleteBtnCorner.CornerRadius = UDim.new(0, 5)
            deleteBtnCorner.Parent = deleteBtn

            deleteBtn.MouseButton1Click:Connect(function()
                savedBuilds[name] = nil
                saveBuildsToDisk()
                row:Destroy()
                notify("🗑 Deleted '" .. name .. "'")
            end)
        end
    end

    addButton(s, "↻ Refresh Saves List", Color3.fromRGB(35, 65, 35), refreshBuildsList)
    refreshBuildsList()

    addSection(s, "── 🔤 Block Art ──")

    -- PIXEL FONT: each char is 5 rows of 5-bit numbers
    -- bit 4 = leftmost pixel, bit 0 = rightmost pixel
    local PIXEL_FONT = {}

    -- Numbers
    PIXEL_FONT["0"] = {14, 17, 17, 17, 14}
    PIXEL_FONT["1"] = {4, 12, 4, 4, 14}
    PIXEL_FONT["2"] = {14, 17, 6, 8, 31}
    PIXEL_FONT["3"] = {30, 1, 6, 1, 30}
    PIXEL_FONT["4"] = {17, 17, 31, 1, 1}
    PIXEL_FONT["5"] = {31, 16, 30, 1, 30}
    PIXEL_FONT["6"] = {14, 16, 30, 17, 14}
    PIXEL_FONT["7"] = {31, 1, 2, 4, 4}
    PIXEL_FONT["8"] = {14, 17, 14, 17, 14}
    PIXEL_FONT["9"] = {14, 17, 15, 1, 14}

    -- English A-Z
    PIXEL_FONT["A"] = {14, 17, 31, 17, 17}
    PIXEL_FONT["B"] = {30, 17, 30, 17, 30}
    PIXEL_FONT["C"] = {15, 16, 16, 16, 15}
    PIXEL_FONT["D"] = {30, 17, 17, 17, 30}
    PIXEL_FONT["E"] = {31, 16, 30, 16, 31}
    PIXEL_FONT["F"] = {31, 16, 30, 16, 16}
    PIXEL_FONT["G"] = {15, 16, 19, 17, 15}
    PIXEL_FONT["H"] = {17, 17, 31, 17, 17}
    PIXEL_FONT["I"] = {31, 4, 4, 4, 31}
    PIXEL_FONT["J"] = {31, 1, 1, 17, 14}
    PIXEL_FONT["K"] = {17, 18, 28, 18, 17}
    PIXEL_FONT["L"] = {16, 16, 16, 16, 31}
    PIXEL_FONT["M"] = {17, 27, 21, 17, 17}
    PIXEL_FONT["N"] = {17, 25, 21, 19, 17}
    PIXEL_FONT["O"] = {14, 17, 17, 17, 14}
    PIXEL_FONT["P"] = {30, 17, 30, 16, 16}
    PIXEL_FONT["Q"] = {14, 17, 21, 18, 13}
    PIXEL_FONT["R"] = {30, 17, 30, 18, 17}
    PIXEL_FONT["S"] = {15, 16, 14, 1, 30}
    PIXEL_FONT["T"] = {31, 4, 4, 4, 4}
    PIXEL_FONT["U"] = {17, 17, 17, 17, 14}
    PIXEL_FONT["V"] = {17, 17, 17, 10, 4}
    PIXEL_FONT["W"] = {17, 17, 21, 27, 17}
    PIXEL_FONT["X"] = {17, 10, 4, 10, 17}
    PIXEL_FONT["Y"] = {17, 10, 4, 4, 4}
    PIXEL_FONT["Z"] = {31, 2, 4, 8, 31}

    -- Russian Cyrillic А-Я (uppercase)
    PIXEL_FONT["А"] = {14, 17, 31, 17, 17}
    PIXEL_FONT["Б"] = {31, 16, 30, 17, 30}
    PIXEL_FONT["В"] = {30, 17, 30, 17, 30}
    PIXEL_FONT["Г"] = {31, 16, 16, 16, 16}
    PIXEL_FONT["Д"] = {14, 10, 10, 31, 17}
    PIXEL_FONT["Е"] = {31, 16, 30, 16, 31}
    PIXEL_FONT["Ё"] = {31, 16, 30, 16, 31}
    PIXEL_FONT["Ж"] = {21, 21, 31, 21, 21}
    PIXEL_FONT["З"] = {30, 1, 14, 1, 30}
    PIXEL_FONT["И"] = {17, 19, 21, 25, 17}
    PIXEL_FONT["Й"] = {17, 19, 21, 25, 17}
    PIXEL_FONT["К"] = {17, 18, 28, 18, 17}
    PIXEL_FONT["Л"] = {15, 9, 9, 9, 17}
    PIXEL_FONT["М"] = {17, 27, 21, 17, 17}
    PIXEL_FONT["Н"] = {17, 17, 31, 17, 17}
    PIXEL_FONT["О"] = {14, 17, 17, 17, 14}
    PIXEL_FONT["П"] = {31, 17, 17, 17, 17}
    PIXEL_FONT["Р"] = {30, 17, 30, 16, 16}
    PIXEL_FONT["С"] = {15, 16, 16, 16, 15}
    PIXEL_FONT["Т"] = {31, 4, 4, 4, 4}
    PIXEL_FONT["У"] = {17, 17, 15, 1, 14}
    PIXEL_FONT["Ф"] = {14, 31, 10, 31, 14}
    PIXEL_FONT["Х"] = {17, 10, 4, 10, 17}
    PIXEL_FONT["Ц"] = {17, 17, 17, 31, 3}
    PIXEL_FONT["Ч"] = {17, 17, 15, 1, 1}
    PIXEL_FONT["Ш"] = {21, 21, 21, 21, 31}
    PIXEL_FONT["Щ"] = {21, 21, 21, 31, 3}
    PIXEL_FONT["Ъ"] = {24, 24, 30, 25, 30}
    PIXEL_FONT["Ы"] = {17, 17, 29, 21, 29}
    PIXEL_FONT["Ь"] = {16, 16, 30, 17, 30}
    PIXEL_FONT["Э"] = {30, 1, 15, 1, 30}
    PIXEL_FONT["Ю"] = {22, 21, 31, 21, 22}
    PIXEL_FONT["Я"] = {15, 17, 15, 5, 17}

    -- Lowercase Russian
    PIXEL_FONT["а"] = {14, 17, 31, 17, 17}
    PIXEL_FONT["б"] = {31, 16, 30, 17, 30}
    PIXEL_FONT["в"] = {30, 17, 30, 17, 30}
    PIXEL_FONT["г"] = {31, 16, 16, 16, 16}
    PIXEL_FONT["д"] = {14, 10, 10, 31, 17}
    PIXEL_FONT["е"] = {31, 16, 30, 16, 31}
    PIXEL_FONT["ё"] = {31, 16, 30, 16, 31}
    PIXEL_FONT["ж"] = {21, 21, 31, 21, 21}
    PIXEL_FONT["з"] = {30, 1, 14, 1, 30}
    PIXEL_FONT["и"] = {17, 19, 21, 25, 17}
    PIXEL_FONT["й"] = {17, 19, 21, 25, 17}
    PIXEL_FONT["к"] = {17, 18, 28, 18, 17}
    PIXEL_FONT["л"] = {15, 9, 9, 9, 17}
    PIXEL_FONT["м"] = {17, 27, 21, 17, 17}
    PIXEL_FONT["н"] = {17, 17, 31, 17, 17}
    PIXEL_FONT["о"] = {14, 17, 17, 17, 14}
    PIXEL_FONT["п"] = {31, 17, 17, 17, 17}
    PIXEL_FONT["р"] = {30, 17, 30, 16, 16}
    PIXEL_FONT["с"] = {15, 16, 16, 16, 15}
    PIXEL_FONT["т"] = {31, 4, 4, 4, 4}
    PIXEL_FONT["у"] = {17, 17, 15, 1, 14}
    PIXEL_FONT["ф"] = {14, 31, 10, 31, 14}
    PIXEL_FONT["х"] = {17, 10, 4, 10, 17}
    PIXEL_FONT["ц"] = {17, 17, 17, 31, 3}
    PIXEL_FONT["ч"] = {17, 17, 15, 1, 1}
    PIXEL_FONT["ш"] = {21, 21, 21, 21, 31}
    PIXEL_FONT["щ"] = {21, 21, 21, 31, 3}
    PIXEL_FONT["ъ"] = {24, 24, 30, 25, 30}
    PIXEL_FONT["ы"] = {17, 17, 29, 21, 29}
    PIXEL_FONT["ь"] = {16, 16, 30, 17, 30}
    PIXEL_FONT["э"] = {30, 1, 15, 1, 30}
    PIXEL_FONT["ю"] = {22, 21, 31, 21, 22}
    PIXEL_FONT["я"] = {15, 17, 15, 5, 17}

    -- Lowercase English
    PIXEL_FONT["a"] = {14, 17, 31, 17, 17}
    PIXEL_FONT["b"] = {30, 17, 30, 17, 30}
    PIXEL_FONT["c"] = {15, 16, 16, 16, 15}
    PIXEL_FONT["d"] = {30, 17, 17, 17, 30}
    PIXEL_FONT["e"] = {31, 16, 30, 16, 31}
    PIXEL_FONT["f"] = {31, 16, 30, 16, 16}
    PIXEL_FONT["g"] = {15, 16, 19, 17, 15}
    PIXEL_FONT["h"] = {17, 17, 31, 17, 17}
    PIXEL_FONT["i"] = {31, 4, 4, 4, 31}
    PIXEL_FONT["j"] = {31, 1, 1, 17, 14}
    PIXEL_FONT["k"] = {17, 18, 28, 18, 17}
    PIXEL_FONT["l"] = {16, 16, 16, 16, 31}
    PIXEL_FONT["m"] = {17, 27, 21, 17, 17}
    PIXEL_FONT["n"] = {17, 25, 21, 19, 17}
    PIXEL_FONT["o"] = {14, 17, 17, 17, 14}
    PIXEL_FONT["p"] = {30, 17, 30, 16, 16}
    PIXEL_FONT["q"] = {14, 17, 21, 18, 13}
    PIXEL_FONT["r"] = {30, 17, 30, 18, 17}
    PIXEL_FONT["s"] = {15, 16, 14, 1, 30}
    PIXEL_FONT["t"] = {31, 4, 4, 4, 4}
    PIXEL_FONT["u"] = {17, 17, 17, 17, 14}
    PIXEL_FONT["v"] = {17, 17, 17, 10, 4}
    PIXEL_FONT["w"] = {17, 17, 21, 27, 17}
    PIXEL_FONT["x"] = {17, 10, 4, 10, 17}
    PIXEL_FONT["y"] = {17, 10, 4, 4, 4}
    PIXEL_FONT["z"] = {31, 2, 4, 8, 31}

    -- Special characters
    PIXEL_FONT[" "] = {0, 0, 0, 0, 0}
    PIXEL_FONT["!"] = {4, 4, 4, 0, 4}
    PIXEL_FONT["?"] = {14, 1, 6, 0, 4}
    PIXEL_FONT["."] = {0, 0, 0, 0, 4}
    PIXEL_FONT[","] = {0, 0, 0, 4, 8}
    PIXEL_FONT["-"] = {0, 0, 31, 0, 0}
    PIXEL_FONT["+"] = {4, 4, 31, 4, 4}
    PIXEL_FONT["="] = {0, 31, 0, 31, 0}
    PIXEL_FONT["*"] = {21, 14, 31, 14, 21}
    PIXEL_FONT["/"] = {1, 2, 4, 8, 16}
    PIXEL_FONT["\\"] = {16, 8, 4, 2, 1}
    PIXEL_FONT["("] = {6, 8, 8, 8, 6}
    PIXEL_FONT[")"] = {12, 2, 2, 2, 12}
    PIXEL_FONT["<"] = {6, 8, 16, 8, 6}
    PIXEL_FONT[">"] = {24, 4, 2, 4, 24}
    PIXEL_FONT["@"] = {14, 17, 23, 21, 14}
    PIXEL_FONT["#"] = {10, 31, 10, 31, 10}
    PIXEL_FONT["$"] = {14, 26, 14, 11, 14}
    PIXEL_FONT["%"] = {17, 2, 4, 8, 17}
    PIXEL_FONT["^"] = {4, 10, 17, 0, 0}
    PIXEL_FONT["&"] = {12, 18, 12, 18, 13}
    PIXEL_FONT["_"] = {0, 0, 0, 0, 31}
    PIXEL_FONT["~"] = {0, 9, 22, 0, 0}
    PIXEL_FONT[":"] = {0, 4, 0, 4, 0}
    PIXEL_FONT[";"] = {0, 4, 0, 4, 8}
    PIXEL_FONT["'"] = {4, 4, 0, 0, 0}
    PIXEL_FONT["\""] = {10, 10, 0, 0, 0}
    PIXEL_FONT["["] = {14, 8, 8, 8, 14}
    PIXEL_FONT["]"] = {14, 2, 2, 2, 14}
    PIXEL_FONT["{"] = {6, 8, 24, 8, 6}
    PIXEL_FONT["}"] = {12, 2, 3, 2, 12}

    local blockArtScale = 4
    local blockArtHeightOff = 10
    local blockArtText = ""

    local baRow = Instance.new("Frame")
    baRow.Size = UDim2.new(1, 0, 0, 36)
    baRow.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    baRow.BorderSizePixel = 0
    baRow.Parent = s
    local baRowCorner = Instance.new("UICorner")
    baRowCorner.CornerRadius = UDim.new(0, 6)
    baRowCorner.Parent = baRow

    local baInput = Instance.new("TextBox")
    baInput.Size = UDim2.new(1, -10, 1, -8)
    baInput.Position = UDim2.new(0, 5, 0, 4)
    baInput.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    baInput.PlaceholderText = "Type text here (EN/RU/special)..."
    baInput.Text = ""
    baInput.Font = Enum.Font.Gotham
    baInput.TextSize = 12
    baInput.TextColor3 = Color3.new(1, 1, 1)
    baInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    baInput.BorderSizePixel = 0
    baInput.ClearTextOnFocus = false
    baInput.Parent = baRow
    local baInputCorner = Instance.new("UICorner")
    baInputCorner.CornerRadius = UDim.new(0, 5)
    baInputCorner.Parent = baInput

    baInput:GetPropertyChangedSignal("Text"):Connect(function()
        blockArtText = baInput.Text
    end)

    addSlider(s, "Pixel Size (studs)", 2, 20, 4, function(v)
        blockArtScale = v
    end)

    addSlider(s, "Text Height Offset (above head)", 0, 50, 10, function(v)
        blockArtHeightOff = math.floor(v)
    end)


    local blockArtLineSpacing = 8

    addSlider(s, "Line Spacing (studs)", 4, 40, 8, function(v)
        blockArtLineSpacing = math.floor(v)
    end)

    local function buildBlockArt(origin, conn2)
        local charW = 5
        local charH = 5
        local pixelSpacing = blockArtScale
        local letterGap = pixelSpacing
        local charSpacing = (charW * pixelSpacing) + letterGap
        local lineHeight = (charH * pixelSpacing) + blockArtLineSpacing

        -- split text by \n for multiline
        local lines = {}
        local current = ""
        for i = 1, #blockArtText do
            local c = blockArtText:sub(i, i)
            if c == "\n" then
                table.insert(lines, current)
                current = ""
            else
                current = current .. c
            end
        end
        table.insert(lines, current)

        local baseHeight = blockArtHeightOff + 7

        for lineIndex, lineText in ipairs(lines) do
            local lineY = baseHeight + (#lines - lineIndex) * lineHeight
            local charX = 0

            for i = 1, #lineText do
                local char = lineText:sub(i, i)
                local pixels = PIXEL_FONT[char]
                if pixels then
                    for row = 1, charH do
                        local rowBits = pixels[row]
                        for col = 0, charW - 1 do
                            local bitPos = charW - 1 - col
                            local isSet = math.floor(rowBits / (2 ^ bitPos)) % 2 == 1
                            if isSet then
                                local sx = charX + col * pixelSpacing
                                local sy = lineY + (charH - row) * pixelSpacing
                                table.insert(spawnQueue, {
                                    origin * CFrame.new(sx, sy, 0),
                                    conn2,
                                    56450668,
                                    "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                                })
                            end
                        end
                    end
                end
                charX = charX + charSpacing
            end
        end
    end

    addButton(s, "🔤 Build Text (Free)", Color3.fromRGB(40, 100, 40), function()
        local hrp = getHRP()
        if not hrp then return end
        if blockArtText == "" then
            notify("Type something in the text box first!")
            return
        end
        spawnQueue = {}
        buildBlockArt(hrp.CFrame, {})
        flushQueue({})
        notify("Building text...")
    end)

    addButton(s, "🔤 Build Text → Baseplate", Color3.fromRGB(30, 60, 130), function()
        local hrp = getHRP()
        if not hrp then return end
        if blockArtText == "" then
            notify("Type something in the text box first!")
            return
        end
        local plate = getBaseplate()
        local conn2 = plate and {plate} or {}
        spawnQueue = {}
        buildBlockArt(hrp.CFrame, conn2)
        flushQueue(conn2)
        notify("Building text...")
    end)

    addSection(s, "── 🗑️ Block Eraser ──")

    local eraserRadius = 10
    local eraserConn = nil

    local function deleteBlock(part)
        pcall(function()
            local model = part:FindFirstAncestorOfClass("Model")
            if model then
                game:GetService("ReplicatedStorage").Remotes.DeleteAsset:InvokeServer(model)
            end
        end)
    end

    local function getNilBlock(name, class)
        for _, v in next, getnilinstances() do
            if v.ClassName == class and v.Name == name then
                return v
            end
        end
    end

    local function deleteBlockNil(part)
        pcall(function()
            local model = part:FindFirstAncestorOfClass("Model")
            if not model then
                local nilBlock = getNilBlock("Block - Brick", "Model")
                if nilBlock then
                    game:GetService("ReplicatedStorage").Remotes.DeleteAsset:InvokeServer(nilBlock)
                end
                return
            end
            game:GetService("ReplicatedStorage").Remotes.DeleteAsset:InvokeServer(model)
        end)
    end

    addSlider(s, "Eraser Radius (studs)", 4, 80, 10, function(v)
        eraserRadius = math.floor(v)
    end)

    addToggle(s, "🗑️ Eraser (hold mouse over blocks)", function(on)
        if eraserConn then
            eraserConn:Disconnect()
            eraserConn = nil
        end
        if on then
            eraserConn = RunService.Heartbeat:Connect(function()
                local mouse = lp:GetMouse()
                if not mouse.Target then return end
                local hitPos = mouse.Hit.Position
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") then
                        if (v.Position - hitPos).Magnitude <= eraserRadius then
                            if not v:IsDescendantOf(lp.Character or Instance.new("Folder")) then
                                deleteBlockNil(v)
                            end
                        end
                    end
                end
            end)
        end
    end)

    addButton(s, "🗑️ Erase All Blocks Near Me", Color3.fromRGB(140, 30, 30), function()
        local hrp = getHRP()
        if not hrp then return end
        local count = 0
        local toDelete = {}
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                if (v.Position - hrp.Position).Magnitude <= eraserRadius * 5 then
                    if not v:IsDescendantOf(lp.Character or Instance.new("Folder")) then
                        table.insert(toDelete, v)
                    end
                end
            end
        end
        for _, v in pairs(toDelete) do
            deleteBlockNil(v)
            count = count + 1
        end
        notify("🗑️ Deleted " .. count .. " blocks!")
    end)


    addSection(s, "── 🎨 Custom Shape Creator ──")

    -- Mode: "default" = 16x16, "wide" = 32x16
    local csMode = "default"
    local cs3D = false
    local COLS_DEFAULT = 16
    local COLS_WIDE = 32
    local ROWS = 16
    local DEPTH = 8
    local csCurrentLayer = 1

    -- grid[layer][row][col] = bool
    local csGrid = {}
    local function initGrid()
        csGrid = {}
        for layer = 1, DEPTH do
            csGrid[layer] = {}
            for row = 1, ROWS do
                csGrid[layer][row] = {}
                for col = 1, COLS_WIDE do
                    csGrid[layer][row][col] = false
                end
            end
        end
    end
    initGrid()

    local csGridButtons = {}
    local csDrawing = false
    local csDrawValue = true

    -- Mode selector row
    local csModeRow = Instance.new("Frame")
    csModeRow.Size = UDim2.new(1, 0, 0, 30)
    csModeRow.BackgroundTransparency = 1
    csModeRow.BorderSizePixel = 0
    csModeRow.Parent = s

    local csModeRowLayout = Instance.new("UIListLayout")
    csModeRowLayout.FillDirection = Enum.FillDirection.Horizontal
    csModeRowLayout.Padding = UDim.new(0, 4)
    csModeRowLayout.Parent = csModeRow

    local modeButtons = {}
    local modeNames = {"Default (16x16)", "Wide (32x16)"}
    local modeKeys = {"default", "wide"}

    local function refreshGrid()
        -- will rebuild grid UI after mode change
    end

    for mi, mname in ipairs(modeNames) do
        local mb = Instance.new("TextButton")
        mb.Size = UDim2.new(0.48, 0, 1, 0)
        mb.BackgroundColor3 = (modeKeys[mi] == csMode) and Color3.fromRGB(180, 140, 30) or Color3.fromRGB(35, 35, 50)
        mb.TextColor3 = (modeKeys[mi] == csMode) and Color3.fromRGB(15, 15, 15) or Color3.new(1, 1, 1)
        mb.Text = mname
        mb.Font = Enum.Font.GothamBold
        mb.TextSize = 10
        mb.BorderSizePixel = 0
        mb.AutoButtonColor = false
        mb.Parent = csModeRow
        local mbCorner = Instance.new("UICorner")
        mbCorner.CornerRadius = UDim.new(0, 6)
        mbCorner.Parent = mb
        local mk = modeKeys[mi]
        mb.MouseButton1Click:Connect(function()
            csMode = mk
            for _, b in pairs(modeButtons) do
                b.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
                b.TextColor3 = Color3.new(1, 1, 1)
            end
            mb.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
            mb.TextColor3 = Color3.fromRGB(15, 15, 15)
            rebuildGridUI()
        end)
        table.insert(modeButtons, mb)
    end

    -- 3D mode toggle
    local cs3DRow, cs3DSetState = addToggle(s, "🧊 3D Mode (multiple layers)", function(on)
        cs3D = on
        if cs3DLayerRow then
            cs3DLayerRow.Visible = on
        end
    end)

    -- Layer selector (only visible in 3D mode)
    local cs3DLayerRow = Instance.new("Frame")
    cs3DLayerRow.Size = UDim2.new(1, 0, 0, 30)
    cs3DLayerRow.BackgroundTransparency = 1
    cs3DLayerRow.BorderSizePixel = 0
    cs3DLayerRow.Visible = false
    cs3DLayerRow.Parent = s

    local cs3DLayerLayout = Instance.new("UIListLayout")
    cs3DLayerLayout.FillDirection = Enum.FillDirection.Horizontal
    cs3DLayerLayout.Padding = UDim.new(0, 3)
    cs3DLayerLayout.Parent = cs3DLayerRow

    local layerLabel = Instance.new("TextLabel")
    layerLabel.Size = UDim2.new(0.3, 0, 1, 0)
    layerLabel.BackgroundTransparency = 1
    layerLabel.Text = "Layer: 1"
    layerLabel.Font = Enum.Font.GothamBold
    layerLabel.TextSize = 11
    layerLabel.TextColor3 = Color3.fromRGB(220, 175, 30)
    layerLabel.BorderSizePixel = 0
    layerLabel.Parent = cs3DLayerRow

    local layerPrevBtn = Instance.new("TextButton")
    layerPrevBtn.Size = UDim2.new(0.15, 0, 1, 0)
    layerPrevBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    layerPrevBtn.Text = "◀"
    layerPrevBtn.Font = Enum.Font.GothamBold
    layerPrevBtn.TextSize = 12
    layerPrevBtn.TextColor3 = Color3.new(1, 1, 1)
    layerPrevBtn.BorderSizePixel = 0
    layerPrevBtn.AutoButtonColor = true
    layerPrevBtn.Parent = cs3DLayerRow
    local layerPrevBtnCorner = Instance.new("UICorner")
    layerPrevBtnCorner.CornerRadius = UDim.new(0, 5)
    layerPrevBtnCorner.Parent = layerPrevBtn

    local layerNextBtn = Instance.new("TextButton")
    layerNextBtn.Size = UDim2.new(0.15, 0, 1, 0)
    layerNextBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    layerNextBtn.Text = "▶"
    layerNextBtn.Font = Enum.Font.GothamBold
    layerNextBtn.TextSize = 12
    layerNextBtn.TextColor3 = Color3.new(1, 1, 1)
    layerNextBtn.BorderSizePixel = 0
    layerNextBtn.AutoButtonColor = true
    layerNextBtn.Parent = cs3DLayerRow
    local layerNextBtnCorner = Instance.new("UICorner")
    layerNextBtnCorner.CornerRadius = UDim.new(0, 5)
    layerNextBtnCorner.Parent = layerNextBtn

    -- Grid holder
    local csGridHolder = Instance.new("Frame")
    csGridHolder.Size = UDim2.new(1, 0, 0, 180)
    csGridHolder.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    csGridHolder.BorderSizePixel = 0
    csGridHolder.ClipsDescendants = true
    csGridHolder.Parent = s
    local csGridHolderCorner = Instance.new("UICorner")
    csGridHolderCorner.CornerRadius = UDim.new(0, 6)
    csGridHolderCorner.Parent = csGridHolder

    local csGridFrame = Instance.new("Frame")
    csGridFrame.BackgroundTransparency = 1
    csGridFrame.BorderSizePixel = 0
    csGridFrame.Parent = csGridHolder

    -- brush mode: "regular" or "layer"
    local csBrushMode = "regular"

    -- brush mode selector
    local csBrushRow = Instance.new("Frame")
    csBrushRow.Size = UDim2.new(1, 0, 0, 28)
    csBrushRow.BackgroundTransparency = 1
    csBrushRow.BorderSizePixel = 0
    csBrushRow.Parent = s

    local csBrushLayout = Instance.new("UIListLayout")
    csBrushLayout.FillDirection = Enum.FillDirection.Horizontal
    csBrushLayout.Padding = UDim.new(0, 4)
    csBrushLayout.Parent = csBrushRow

    local brushLabel = Instance.new("TextLabel")
    brushLabel.Size = UDim2.new(0.3, 0, 1, 0)
    brushLabel.BackgroundTransparency = 1
    brushLabel.Text = "Brush:"
    brushLabel.Font = Enum.Font.GothamBold
    brushLabel.TextSize = 11
    brushLabel.TextColor3 = Color3.fromRGB(220, 175, 30)
    brushLabel.BorderSizePixel = 0
    brushLabel.Parent = csBrushRow

    local brushRegBtn = Instance.new("TextButton")
    brushRegBtn.Size = UDim2.new(0.32, 0, 1, 0)
    brushRegBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
    brushRegBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
    brushRegBtn.Text = "✏️ Regular"
    brushRegBtn.Font = Enum.Font.GothamBold
    brushRegBtn.TextSize = 10
    brushRegBtn.BorderSizePixel = 0
    brushRegBtn.AutoButtonColor = false
    brushRegBtn.Parent = csBrushRow
    local brushRegBtnCorner = Instance.new("UICorner")
    brushRegBtnCorner.CornerRadius = UDim.new(0, 5)
    brushRegBtnCorner.Parent = brushRegBtn

    local brushLayerBtn = Instance.new("TextButton")
    brushLayerBtn.Size = UDim2.new(0.32, 0, 1, 0)
    brushLayerBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    brushLayerBtn.TextColor3 = Color3.new(1, 1, 1)
    brushLayerBtn.Text = "🧱 Layer"
    brushLayerBtn.Font = Enum.Font.GothamBold
    brushLayerBtn.TextSize = 10
    brushLayerBtn.BorderSizePixel = 0
    brushLayerBtn.AutoButtonColor = false
    brushLayerBtn.Parent = csBrushRow
    local brushLayerBtnCorner = Instance.new("UICorner")
    brushLayerBtnCorner.CornerRadius = UDim.new(0, 5)
    brushLayerBtnCorner.Parent = brushLayerBtn

    brushRegBtn.MouseButton1Click:Connect(function()
        csBrushMode = "regular"
        brushRegBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
        brushRegBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
        brushLayerBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        brushLayerBtn.TextColor3 = Color3.new(1, 1, 1)
    end)

    brushLayerBtn.MouseButton1Click:Connect(function()
        csBrushMode = "layer"
        brushLayerBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
        brushLayerBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
        brushRegBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        brushRegBtn.TextColor3 = Color3.new(1, 1, 1)
    end)

    -- depth color for layer brush: 0=empty, 1-8=increasingly brighter/warmer
    local function getDepthColor(depth)
        if depth <= 0 then
            return Color3.fromRGB(35, 35, 50)
        end
        local t = (depth - 1) / (DEPTH - 1)
        local r2 = math.floor(60 + t * 195)
        local g2 = math.floor(20 + t * 120)
        local b2 = math.floor(50 - t * 40)
        return Color3.fromRGB(r2, g2, b2)
    end

    local function rebuildGridUI()
        for _, v in pairs(csGridFrame:GetChildren()) do
            v:Destroy()
        end
        csGridButtons = {}

        local cols = csMode == "wide" and COLS_WIDE or COLS_DEFAULT
        local cellSize = csMode == "wide" and 8 or 11
        local cellGap = 1
        local totalW = cols * (cellSize + cellGap) - cellGap
        local totalH = ROWS * (cellSize + cellGap) - cellGap
        local holderH = totalH + 10

        csGridHolder.Size = UDim2.new(1, 0, 0, holderH)
        csGridFrame.Size = UDim2.new(0, totalW, 0, totalH)
        csGridFrame.Position = UDim2.new(0.5, -math.floor(totalW / 2), 0, 5)

        for row = 1, ROWS do
            csGridButtons[row] = {}
            for col = 1, cols do
                local cell = Instance.new("TextButton")
                cell.Size = UDim2.new(0, cellSize, 0, cellSize)
                cell.Position = UDim2.new(0, (col - 1) * (cellSize + cellGap), 0, (row - 1) * (cellSize + cellGap))
                local val = csGrid[csCurrentLayer][row][col]
                if type(val) == "number" then
                    cell.BackgroundColor3 = getDepthColor(val)
                else
                    cell.BackgroundColor3 = val and Color3.fromRGB(180, 140, 30) or Color3.fromRGB(35, 35, 50)
                end
                cell.BorderSizePixel = 0
                cell.Text = ""
                cell.AutoButtonColor = false
                cell.Parent = csGridFrame

                local r = row
                local c = col

                cell.MouseButton1Down:Connect(function()
                    csDrawing = true
                    if csBrushMode == "layer" then
                        -- layer brush: increment depth on click, max DEPTH
                        local cur = type(csGrid[csCurrentLayer][r][c]) == "number" and csGrid[csCurrentLayer][r][c] or (csGrid[csCurrentLayer][r][c] and 1 or 0)
                        local newDepth = math.min(cur + 1, DEPTH)
                        csGrid[csCurrentLayer][r][c] = newDepth
                        cell.BackgroundColor3 = getDepthColor(newDepth)
                        csDrawValue = newDepth
                    else
                        local cur = csGrid[csCurrentLayer][r][c]
                        local isSet = (type(cur) == "number" and cur > 0) or (cur == true)
                        csDrawValue = not isSet
                        csGrid[csCurrentLayer][r][c] = csDrawValue
                        cell.BackgroundColor3 = csDrawValue and Color3.fromRGB(180, 140, 30) or Color3.fromRGB(35, 35, 50)
                    end
                end)

                cell.MouseEnter:Connect(function()
                    if not csDrawing then return end
                    if csBrushMode == "layer" then
                        local cur = type(csGrid[csCurrentLayer][r][c]) == "number" and csGrid[csCurrentLayer][r][c] or (csGrid[csCurrentLayer][r][c] and 1 or 0)
                        local newDepth = math.min(cur + 1, DEPTH)
                        csGrid[csCurrentLayer][r][c] = newDepth
                        cell.BackgroundColor3 = getDepthColor(newDepth)
                    else
                        csGrid[csCurrentLayer][r][c] = csDrawValue
                        cell.BackgroundColor3 = csDrawValue and Color3.fromRGB(180, 140, 30) or Color3.fromRGB(35, 35, 50)
                    end
                end)

                UIS.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        csDrawing = false
                    end
                end)

                csGridButtons[row][col] = cell
            end
        end
    end

    rebuildGridUI()

    layerPrevBtn.MouseButton1Click:Connect(function()
        if csCurrentLayer > 1 then
            csCurrentLayer = csCurrentLayer - 1
            layerLabel.Text = "Layer: " .. csCurrentLayer
            rebuildGridUI()
        end
    end)

    layerNextBtn.MouseButton1Click:Connect(function()
        if csCurrentLayer < DEPTH then
            csCurrentLayer = csCurrentLayer + 1
            layerLabel.Text = "Layer: " .. csCurrentLayer
            rebuildGridUI()
        end
    end)

    -- Build function
    local function buildCustomShape(conn2)
        local hrp = getHRP()
        if not hrp then return end
        spawnQueue = {}
        local cols = csMode == "wide" and COLS_WIDE or COLS_DEFAULT

        if csBrushMode == "layer" then
            -- layer brush mode: each cell's depth value = how many Z layers to stack
            for row = 1, ROWS do
                for col = 1, cols do
                    local val = csGrid[1][row][col]
                    local depth = type(val) == "number" and val or (val and 1 or 0)
                    for d = 0, depth - 1 do
                        local x = (col - 1) * blockArtScale
                        local y = (ROWS - row) * blockArtScale + blockArtHeightOff + 7
                        local z = d * blockArtScale
                        table.insert(spawnQueue, {
                            hrp.CFrame * CFrame.new(x, y, z),
                            conn2,
                            56450668,
                            "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                        })
                    end
                end
            end
        else
            -- regular mode: 3D uses separate layers
            local maxLayer = cs3D and DEPTH or 1
            for layer = 1, maxLayer do
                for row = 1, ROWS do
                    for col = 1, cols do
                        local val = csGrid[layer][row][col]
                        local isSet = (type(val) == "number" and val > 0) or (val == true)
                        if isSet then
                            local x = (col - 1) * blockArtScale
                            local y = (ROWS - row) * blockArtScale + blockArtHeightOff + 7
                            local z = (layer - 1) * blockArtScale
                            table.insert(spawnQueue, {
                                hrp.CFrame * CFrame.new(x, y, z),
                                conn2,
                                56450668,
                                "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                            })
                        end
                    end
                end
            end
        end
        flushQueue(conn2)
    end

    -- Button row
    local csActionRow = Instance.new("Frame")
    csActionRow.Size = UDim2.new(1, 0, 0, 34)
    csActionRow.BackgroundTransparency = 1
    csActionRow.BorderSizePixel = 0
    csActionRow.Parent = s

    local csActionLayout = Instance.new("UIListLayout")
    csActionLayout.FillDirection = Enum.FillDirection.Horizontal
    csActionLayout.Padding = UDim.new(0, 3)
    csActionLayout.Parent = csActionRow

    local csClearBtn = Instance.new("TextButton")
    csClearBtn.Size = UDim2.new(0.24, 0, 1, 0)
    csClearBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 30)
    csClearBtn.Text = "🗑 Clear"
    csClearBtn.Font = Enum.Font.GothamBold
    csClearBtn.TextSize = 10
    csClearBtn.TextColor3 = Color3.new(1, 1, 1)
    csClearBtn.BorderSizePixel = 0
    csClearBtn.AutoButtonColor = true
    csClearBtn.Parent = csActionRow
    local csClearBtnCorner = Instance.new("UICorner")
    csClearBtnCorner.CornerRadius = UDim.new(0, 6)
    csClearBtnCorner.Parent = csClearBtn

    csClearBtn.MouseButton1Click:Connect(function()
        local cols = csMode == "wide" and COLS_WIDE or COLS_DEFAULT
        for layer = 1, DEPTH do
            for row = 1, ROWS do
                for col = 1, cols do
                    csGrid[layer][row][col] = false
                end
            end
        end
        rebuildGridUI()
        notify("Grid cleared!")
    end)

    local csBuildFreeBtn = Instance.new("TextButton")
    csBuildFreeBtn.Size = UDim2.new(0.24, 0, 1, 0)
    csBuildFreeBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
    csBuildFreeBtn.Text = "🔨 Free"
    csBuildFreeBtn.Font = Enum.Font.GothamBold
    csBuildFreeBtn.TextSize = 10
    csBuildFreeBtn.TextColor3 = Color3.new(1, 1, 1)
    csBuildFreeBtn.BorderSizePixel = 0
    csBuildFreeBtn.AutoButtonColor = true
    csBuildFreeBtn.Parent = csActionRow
    local csBuildFreeBtnCorner = Instance.new("UICorner")
    csBuildFreeBtnCorner.CornerRadius = UDim.new(0, 6)
    csBuildFreeBtnCorner.Parent = csBuildFreeBtn

    csBuildFreeBtn.MouseButton1Click:Connect(function()
        buildCustomShape({})
        notify("Building custom shape (free)!")
    end)

    local csBuildBpBtn = Instance.new("TextButton")
    csBuildBpBtn.Size = UDim2.new(0.24, 0, 1, 0)
    csBuildBpBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 130)
    csBuildBpBtn.Text = "🔨 Plate"
    csBuildBpBtn.Font = Enum.Font.GothamBold
    csBuildBpBtn.TextSize = 10
    csBuildBpBtn.TextColor3 = Color3.new(1, 1, 1)
    csBuildBpBtn.BorderSizePixel = 0
    csBuildBpBtn.AutoButtonColor = true
    csBuildBpBtn.Parent = csActionRow
    local csBuildBpBtnCorner = Instance.new("UICorner")
    csBuildBpBtnCorner.CornerRadius = UDim.new(0, 6)
    csBuildBpBtnCorner.Parent = csBuildBpBtn

    csBuildBpBtn.MouseButton1Click:Connect(function()
        local plate = getBaseplate()
        local conn2 = plate and {plate} or {}
        buildCustomShape(conn2)
        notify("Building custom shape → baseplate!")
    end)

    local csBuildHrpBtn = Instance.new("TextButton")
    csBuildHrpBtn.Size = UDim2.new(0.24, 0, 1, 0)
    csBuildHrpBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 80)
    csBuildHrpBtn.Text = "🔨 HRP ⚠️"
    csBuildHrpBtn.Font = Enum.Font.GothamBold
    csBuildHrpBtn.TextSize = 10
    csBuildHrpBtn.TextColor3 = Color3.new(1, 1, 1)
    csBuildHrpBtn.BorderSizePixel = 0
    csBuildHrpBtn.AutoButtonColor = true
    csBuildHrpBtn.Parent = csActionRow
    local csBuildHrpBtnCorner = Instance.new("UICorner")
    csBuildHrpBtnCorner.CornerRadius = UDim.new(0, 6)
    csBuildHrpBtnCorner.Parent = csBuildHrpBtn

    csBuildHrpBtn.MouseButton1Click:Connect(function()
        local hrp = getHRP()
        if not hrp then return end
        buildCustomShape({hrp})
        notify("Building custom shape → HRP!")
    end)


    addSection(s, "── Circle / Dome Builder ──")

    local circleRadius = 10
    local circleHeight = 1
    local circleThickness = 1
    local circleFilled = false
    local domeOffset = 0

    addSlider(s, "Radius", 1, 50, 10, function(v)
        circleRadius = math.floor(v)
    end)

    addSlider(s, "Wall Height", 1, 20, 1, function(v)
        circleHeight = math.floor(v)
    end)

    addSlider(s, "Wall Thickness", 1, 5, 1, function(v)
        circleThickness = math.floor(v)
    end)

    addSlider(s, "Height Offset (studs)", -50, 50, 0, function(v)
        domeOffset = math.floor(v)
    end)

    addToggle(s, "Filled (Solid Disc)", function(on)
        circleFilled = on
    end)

    addButton(s, "⭕ Build Circle / Ring", Color3.fromRGB(30, 100, 160), function()
        local hrp = getHRP()
        if not hrp then return end
        local origin = hrp.CFrame
        local plate = getBaseplate()
        local conn2 = {}
        if plate then conn2 = {plate} end
        for y = 0, circleHeight - 1 do
            for x = -(circleRadius + circleThickness), (circleRadius + circleThickness) do
                for z = -(circleRadius + circleThickness), (circleRadius + circleThickness) do
                    local dist = math.sqrt(x * x + z * z)
                    local inShape = false
                    if circleFilled then
                        inShape = dist <= circleRadius
                    else
                        inShape = dist <= circleRadius and dist >= circleRadius - circleThickness
                    end
                    if inShape then
                        task.spawn(function()
                            pcall(function()
                                universalStamp(origin * CFrame.new(x * 4, y * 4 + domeOffset, z * 4), conn2, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                            end)
                        end)
                    end
                end
            end
        end
    end)

    local function buildDome(conn2)
        local hrp = getHRP()
        if not hrp then return end
        local origin = hrp.CFrame
        local r2 = circleRadius
        local t2 = circleThickness
        local step = 0.8
        local xi = -r2
        while xi <= r2 do
            local yi = -r2
            while yi <= r2 do
                local zi = -r2
                while zi <= r2 do
                    local d = math.sqrt(xi * xi + yi * yi + zi * zi)
                    if d <= r2 and d >= r2 - t2 then
                        local cx = xi
                        local cy = yi
                        local cz = zi
                        task.spawn(function()
                            pcall(function()
                                universalStamp(origin * CFrame.new(cx * 4, (cy + r2) * 4 + domeOffset, cz * 4), conn2, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                            end)
                        end)
                    end
                    zi = zi + step
                end
                yi = yi + step
            end
            xi = xi + step
        end
    end

    addButton(s, "🌐 Dome → Baseplate", Color3.fromRGB(60, 30, 130), function()
        local plate = getBaseplate()
        if plate then
            buildDome({plate})
        else
            buildDome({})
        end
    end)

    addButton(s, "🧍 Dome → MY HRP ⚠️", Color3.fromRGB(100, 30, 30), function()
        local hrp = getHRP()
        if not hrp then return end
        buildDome({hrp})
    end)

    addSection(s, "── Block Armor ──")

    addButton(s, "⚔️ FULL SUIT", Color3.fromRGB(160, 90, 10), function()
        local c = getChar()
        if not c then return end
        local function armorLimb(partName, offsets)
            local part = c:FindFirstChild(partName)
            if not part then return end
            for _, off in pairs(offsets) do
                task.spawn(function()
                    pcall(function()
                        universalStamp(part.CFrame * CFrame.new(off), {part}, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                    end)
                end)
            end
        end
        armorLimb("Head",          {Vector3.new(0,4,0),  Vector3.new(4,0,0),  Vector3.new(-4,0,0), Vector3.new(0,0,4),  Vector3.new(0,0,-4)})
        armorLimb("UpperTorso",    {Vector3.new(0,0,4),  Vector3.new(0,0,-4), Vector3.new(6,0,0),  Vector3.new(-6,0,0)})
        armorLimb("Torso",         {Vector3.new(0,0,4),  Vector3.new(0,0,-4), Vector3.new(6,0,0),  Vector3.new(-6,0,0)})
        armorLimb("RightUpperArm", {Vector3.new(4,0,0),  Vector3.new(0,4,0),  Vector3.new(0,-4,0)})
        armorLimb("LeftUpperArm",  {Vector3.new(-4,0,0), Vector3.new(0,4,0),  Vector3.new(0,-4,0)})
        armorLimb("Right Arm",     {Vector3.new(4,0,0),  Vector3.new(0,4,0),  Vector3.new(0,-4,0)})
        armorLimb("Left Arm",      {Vector3.new(-4,0,0), Vector3.new(0,4,0),  Vector3.new(0,-4,0)})
        armorLimb("RightUpperLeg", {Vector3.new(4,0,0),  Vector3.new(0,-4,0)})
        armorLimb("LeftUpperLeg",  {Vector3.new(-4,0,0), Vector3.new(0,-4,0)})
        armorLimb("Right Leg",     {Vector3.new(4,0,0),  Vector3.new(0,-4,0)})
        armorLimb("Left Leg",      {Vector3.new(-4,0,0), Vector3.new(0,-4,0)})
    end)

    addSection(s, "── Floating Island ──")

    local islandSize = 10
    local islandHeight = 50

    addSlider(s, "Island Size (blocks)", 5, 30, 10, function(v)
        islandSize = math.floor(v)
    end)

    addSlider(s, "Island Height", 10, 200, 50, function(v)
        islandHeight = math.floor(v)
    end)

    addButton(s, "🏝️ Instant Floating Island", Color3.fromRGB(20, 160, 80), function()
        local hrp = getHRP()
        if not hrp then return end
        local base = hrp.CFrame
        local half = math.floor(islandSize / 2)
        local plate = getBaseplate()
        local conn2 = {}
        if plate then conn2 = {plate} end
        for x = -half, half do
            for z = -half, half do
                coroutine.wrap(function()
                    pcall(function()
                        universalStamp(base * CFrame.new(x * 4, islandHeight, z * 4), conn2, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                    end)
                end)()
            end
        end
        notify("🏝️ Island spawned!")
    end)

    addSection(s, "── OP Spawns ──")

    addButton(s, "🌧️ Block Rain (15s)", Color3.fromRGB(0, 60, 120), function()
        local rainConn
        rainConn = RunService.Heartbeat:Connect(function()
            local hrp = getHRP()
            if not hrp then
                rainConn:Disconnect()
                return
            end
            for i = 1, 24 do
                task.spawn(function()
                    universalStamp(
                        CFrame.new(
                            hrp.Position.X + math.random(-80, 80),
                            hrp.Position.Y + math.random(100, 250),
                            hrp.Position.Z + math.random(-80, 80)
                        ),
                        {},
                        56450668,
                        "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                    )
                end)
            end
            task.wait(0.05)
        end)
        task.delay(15, function()
            rainConn:Disconnect()
            notify("Rain stopped")
        end)
        notify("⛈️ Block rain 15s!")
    end)

    addButton(s, "🌪️ Block Tornado", Color3.fromRGB(80, 30, 130), function()
        local hrp = getHRP()
        if not hrp then return end
        local base = hrp.CFrame
        coroutine.wrap(function()
            for layer = 1, 15 do
                local radius = layer * 3
                local height = layer * 4
                local bc = layer * 8
                for i = 0, bc - 1 do
                    local angle = (i / bc) * math.pi * 2
                    universalStamp(
                        base * CFrame.new(math.cos(angle) * radius, height, math.sin(angle) * radius),
                        {},
                        56450668,
                        "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                    )
                    task.wait(0.01)
                end
            end
        end)()
    end)

    addButton(s, "☄️ Meteor Drop", Color3.fromRGB(160, 60, 0), function()
        local hrp = getHRP()
        if not hrp then return end
        local base = CFrame.new(hrp.Position + Vector3.new(0, 300, 0))
        for x = -8, 8 do
            for y = -8, 8 do
                for z = -8, 8 do
                    if math.sqrt(x * x + y * y + z * z) <= 8 then
                        coroutine.wrap(function()
                            universalStamp(
                                base * CFrame.new(x * 4, y * 4, z * 4),
                                {},
                                56450668,
                                "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                            )
                        end)()
                    end
                end
            end
        end
        notify("☄️ Meteor!")
    end)

    addSection(s, "── 🌈 Rainbow Tower ──")

    local rainbowBlocks = {
        {id = 56452411, guid = "{f95046e9-18a1-4753-ad86-3709b2ab9f77}"},
        {id = 56452539, guid = "{ff7dac8b-f978-44f1-83a4-22ab3883ded0}"},
        {id = 56452610, guid = "{1d90dc38-b323-4917-b0d1-6ed4ddb3f140}"},
        {id = 56452651, guid = "{7d368abf-332d-45be-aaa8-1401481370b4}"},
        {id = 56452293, guid = "{e2159d72-5ad3-429d-8a92-4890734501e9}"},
        {id = 56452342, guid = "{182aa2a8-66d4-4673-a41d-984b4d5acfc1}"},
        {id = 56452821, guid = "{2ff32399-0ac5-41c6-83ea-c4bb5b13d7c1}"},
    }

    local rbTowerW = 5
    local rbFloorEvery = 4
    local rbMaxFloors = 10

    addSlider(s, "Tower Width", 1, 15, 5, function(v)
        rbTowerW = math.floor(v)
    end)

    addSlider(s, "Floor Every N", 1, 8, 4, function(v)
        rbFloorEvery = math.floor(v)
    end)

    addSlider(s, "Max Floors", 1, 240, 10, function(v)
        rbMaxFloors = math.floor(v)
    end)

    addButton(s, "🌈 Build Rainbow Tower", Color3.fromRGB(180, 100, 30), function()
        local hrp = getHRP()
        if not hrp then return end
        local origin = hrp.CFrame
        local towerH = rbMaxFloors * rbFloorEvery
        local plate = getBaseplate()
        local conn2 = plate and {plate} or {}
        for y = 0, towerH do
            local block = rainbowBlocks[(math.floor(y / rbFloorEvery) % #rainbowBlocks) + 1]
            for i = -rbTowerW, rbTowerW do
                coroutine.wrap(function()
                    universalStamp(origin * CFrame.new(i * 4, y * 4, -rbTowerW * 4), conn2, block.id, block.guid)
                    universalStamp(origin * CFrame.new(i * 4, y * 4,  rbTowerW * 4), conn2, block.id, block.guid)
                    universalStamp(origin * CFrame.new(-rbTowerW * 4, y * 4, i * 4), conn2, block.id, block.guid)
                    universalStamp(origin * CFrame.new( rbTowerW * 4, y * 4, i * 4), conn2, block.id, block.guid)
                end)()
            end
            if y % rbFloorEvery == 0 and y > 0 then
                for x = -rbTowerW + 1, rbTowerW - 1 do
                    for z = -rbTowerW + 1, rbTowerW - 1 do
                        coroutine.wrap(function()
                            universalStamp(origin * CFrame.new(x * 4, y * 4, z * 4), conn2, block.id, block.guid)
                        end)()
                    end
                end
            end
        end
        notify("🌈 Rainbow Tower building!")
    end)

    addSection(s, "── Turbo Spawn ──")

    local turboConn = nil
    addToggle(s, "TURBO Block Spam", function(on)
        if turboConn then
            turboConn:Disconnect()
            turboConn = nil
        end
        if on then
            turboConn = RunService.Heartbeat:Connect(function()
                local hrp = getHRP()
                if not hrp then return end
                for i = 1, 5 do
                    universalStamp(
                        hrp.CFrame * CFrame.new(math.random(-8, 8), math.random(0, 12), math.random(-8, 8)),
                        {},
                        56450668,
                        "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                    )
                end
            end)
        end
    end)
end

-- ============================================================
-- EXPLOIT TAB
-- ============================================================
do
    local s = ExploitTab.scroll

    addSection(s, "── Telekinesis Tool ──")

    addSlider(s, "Sim Distance", 512, 10000, 2048, function(v)
        pcall(function()
            lp.SimulationRadius = v
            lp.MaxSimulationRadius = v
        end)
        notify("Sim distance: " .. v)
    end)

    addButton(s, "🔮 Give Telekinesis Tool", Color3.fromRGB(80, 40, 180), function()
        local selectionbox = Instance.new("SelectionBox")
        selectionbox.LineThickness = 0.3
        selectionbox.Color3 = Color3.fromRGB(255, 255, 255)
        selectionbox.Parent = lp.Character

        local mas = Instance.new("Model")
        mas.Parent = game:GetService("Lighting")

        local Tool0 = Instance.new("Tool")
        Tool0.Name = "Telekinesis V5"
        Tool0.Grip = CFrame.new(0, 0, 1, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        Tool0.GripPos = Vector3.new(0, 0, 1)
        Tool0.Parent = mas

        local Part1 = Instance.new("Part")
        Part1.Name = "Handle"
        Part1.CFrame = CFrame.new(-3.5, 5.3, -3.5, 1, 0, 0, 0, -1, 0, 0, 0, -1)
        Part1.Transparency = 1
        Part1.Size = Vector3.new(1, 1, 1)
        Part1.BottomSurface = Enum.SurfaceType.Smooth
        Part1.TopSurface = Enum.SurfaceType.Smooth
        Part1.Locked = true
        Part1.Parent = Tool0

        local function makeBP2()
            local bp = Instance.new("BodyPosition")
            bp.maxForce = Vector3.new(1e9, 1e9, 1e9)
            bp.P = bp.P * 3
            return bp
        end

        local objects = {}
        local keymouse = nil
        local mousedown = false

        local function releaseAll()
            for _, e in pairs(objects) do
                pcall(function()
                    e.bp:Destroy()
                end)
            end
            objects = {}
            selectionbox.Adornee = nil
        end

        local function onButton1Down(mouse)
            local target = mouse.Target
            if target == nil or target.Anchored then return end
            releaseAll()
            mousedown = true
            local bp = makeBP2()
            local d = (target.Position - Part1.Position).Magnitude
            table.insert(objects, {part = target, bp = bp, dist = d})
            selectionbox.Adornee = target
        end

        local tkToolConn = RunService.RenderStepped:Connect(function()
            if not Tool0 or not Tool0.Parent then
                tkToolConn:Disconnect()
                return
            end
            if mousedown and #objects > 0 and keymouse then
                local lv = CFrame.new(Part1.Position, keymouse.Hit.p)
                for _, entry in pairs(objects) do
                    if entry.part and entry.part.Parent then
                        entry.bp.Parent = entry.part
                        entry.bp.position = Part1.Position + lv.LookVector * entry.dist
                    end
                end
            end
        end)

        local function onKeyDown(key)
            key = key:lower()
            if key == "q" then
                for _, e in pairs(objects) do
                    e.dist = math.max(5, e.dist - 5)
                end
            end
            if key == "e" then
                for _, e in pairs(objects) do
                    e.dist = e.dist + 5
                end
            end
            if key == "y" then
                for _, e in pairs(objects) do
                    e.dist = 100
                end
            end
            if key == "j" then
                for _, e in pairs(objects) do
                    e.dist = 5000
                end
            end
            if key == "x" then
                for _, e in pairs(objects) do
                    e.dist = 15
                end
            end
            if key == "f" then
                for _, e in pairs(objects) do
                    e.dist = 125
                end
            end
            if key == "g" then
                for _, entry in pairs(objects) do
                    if entry.part and entry.part.Parent then
                        local bav = Instance.new("BodyAngularVelocity")
                        bav.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                        bav.AngularVelocity = Vector3.new(100000, 100000, 100000)
                        bav.Parent = entry.part
                    end
                end
            end
        end

        Tool0.Equipped:Connect(function(mouse)
            keymouse = mouse
            mouse.Button1Down:Connect(function()
                onButton1Down(mouse)
            end)
            mouse.Button1Up:Connect(function()
                mousedown = false
                releaseAll()
            end)
            mouse.Button2Down:Connect(function()
                onButton1Down(mouse)
            end)
            mouse.KeyDown:Connect(function(key)
                onKeyDown(key)
            end)
        end)

        Tool0.Unequipped:Connect(function()
            mousedown = false
            releaseAll()
        end)

        for _, v in pairs(mas:GetChildren()) do
            v.Parent = lp.Backpack
        end
        mas:Destroy()
        notify("Telekinesis given! Q/E=dist Y=launch G=spin")
    end)

    addSection(s, "── Sword Exploits ──")

    local lungeCooldown = cfg.lungeCooldown

    addSlider(s, "Lunge Cooldown (sec)", 0.0001, 1, cfg.lungeCooldown, function(v)
        lungeCooldown = v
        cfg.lungeCooldown = v
    end)

    local lungeConn = nil
    addToggle(s, "Spam Lunge (Instakill)", function(on)
        if lungeConn then
            lungeConn:Disconnect()
            lungeConn = nil
        end
        if on then
            lungeConn = RunService.Heartbeat:Connect(function()
                local function findSword(p)
                    for _, v in pairs(p:GetChildren()) do
                        if v:IsA("Tool") and v:FindFirstChild("UpdateDamage") then
                            return v
                        end
                    end
                end
                local sword = findSword(lp.Backpack)
                if not sword then
                    local c = getChar()
                    if c then
                        sword = findSword(c)
                    end
                end
                if sword then
                    pcall(function()
                        sword.UpdateDamage:FireServer("Lunge")
                    end)
                end
                task.wait(lungeCooldown)
            end)
        end
    end)

    addSection(s, "── Pull / Freeze Players ──")

    local function pullPlayer(plr)
        local tc = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not tc then return end
        local myHRP = getHRP()
        if not myHRP then return end
        pcall(function()
            universalStamp(myHRP.CFrame, {tc}, 41324919, "")
        end)
    end

    local function freezePlayer(plr)
        local tc = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        if not tc then return end
        pcall(function()
            universalStamp(getHRP().CFrame * CFrame.new(0, -10, 0), {tc}, 56447956, "")
        end)
    end

    local refreshPull = makePlayerList(s, "🧲 Pull", Color3.fromRGB(20, 60, 120), pullPlayer)
    addButton(s, "↻ Refresh Pull", Color3.fromRGB(35, 65, 35), refreshPull)
    refreshPull()

    local refreshFreeze = makePlayerList(s, "🧊 Freeze", Color3.fromRGB(20, 80, 150), freezePlayer)
    addButton(s, "↻ Refresh Freeze", Color3.fromRGB(35, 65, 35), refreshFreeze)
    refreshFreeze()

    addSection(s, "── Freeze All ──")

    local freezeAllConn = nil
    addToggle(s, "🧊 Freeze ALL Players (Loop)", function(on)
        if freezeAllConn then
            freezeAllConn:Disconnect()
            freezeAllConn = nil
        end
        if on then
            freezeAllConn = RunService.Heartbeat:Connect(function()
                local hrp = getHRP()
                if not hrp then return end
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= lp and plr.Character then
                        local tc = plr.Character:FindFirstChild("HumanoidRootPart")
                        if tc then
                            pcall(function()
                                universalStamp(hrp.CFrame * CFrame.new(0, -10, 0), {tc}, 56447956, "")
                            end)
                        end
                    end
                end
                task.wait(0.3)
            end)
        end
    end)

    addButton(s, "🧊 Freeze ALL (Once)", Color3.fromRGB(20, 80, 150), function()
        local hrp = getHRP()
        if not hrp then return end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local tc = plr.Character:FindFirstChild("HumanoidRootPart")
                if tc then
                    pcall(function()
                        universalStamp(hrp.CFrame * CFrame.new(0, -10, 0), {tc}, 56447956, "")
                    end)
                end
            end
        end
        notify("🧊 Froze all players!")
    end)
end

-- ============================================================
-- KEYBINDS TAB
-- ============================================================
do
    local s = KeybindsTab.scroll

    addSection(s, "── Auto Clicker ──")

    local acDelay = 1 / cfg.autoClickSpeed
    local acConn = nil

    addSlider(s, "Click Speed (per sec)", 1, 20, cfg.autoClickSpeed, function(v)
        acDelay = 1 / v
        cfg.autoClickSpeed = v
    end)

    addToggle(s, "Auto Clicker", function(on)
        if acConn then
            acConn:Disconnect()
            acConn = nil
        end
        if on then
            acConn = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local vu = game:GetService("VirtualInputManager")
                    vu:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    vu:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end)
                task.wait(acDelay)
            end)
        end
    end)

    addSection(s, "── Key Spammer ──")

    local keyDelay = 0.1

    addSlider(s, "Key Spam Speed (per sec)", 1, 20, 5, function(v)
        keyDelay = 1 / v
    end)

    addButton(s, "Spam E Key (20x)", Color3.fromRGB(60, 60, 110), function()
        coroutine.wrap(function()
            for i = 1, 20 do
                pcall(function()
                    local vu = game:GetService("VirtualInputManager")
                    vu:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    vu:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end)
                task.wait(keyDelay)
            end
        end)()
    end)
end

-- ============================================================
-- MASSIVE TAB
-- ============================================================
do
    local s = MassiveTab.scroll

    addSection(s, "── Server Destroyers ──")

    addButton(s, "💀 SEVERE CRASH (10M blocks)", Color3.fromRGB(180, 0, 0), function()
        local hrp = getHRP()
        if not hrp then return end
        local cf = hrp.CFrame
        notify("💀 Spawning 10M blocks...")
        for i = 1, 10000000 do
            task.spawn(function()
                universalStamp(
                    cf * CFrame.new(math.random(-500, 500), math.random(0, 200), math.random(-500, 500)),
                    {},
                    56450668,
                    "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                )
            end)
        end
    end)

    addButton(s, "☢️ SERVER NUKE (100M parts)", Color3.fromRGB(120, 0, 0), function()
        local hrp = getHRP()
        if not hrp then return end
        local cf = hrp.CFrame
        local nukeConn = nil
        local count = 0
        notify("☢️ NUKING...")
        nukeConn = RunService.Heartbeat:Connect(function()
            for i = 1, 10000 do
                task.spawn(function()
                    universalStamp(
                        cf * CFrame.new(math.random(-1000, 1000), math.random(0, 500), math.random(-1000, 1000)),
                        {},
                        56450668,
                        "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                    )
                end)
                count = count + 1
            end
            if count >= 100000000 then
                nukeConn:Disconnect()
            end
        end)
    end)

    addButton(s, "⚰️ Bury The Server", Color3.fromRGB(60, 20, 20), function()
        local hrp = getHRP()
        if not hrp then return end
        notify("⚰️ Burying server with MEGA RAIN...")
        local buryConn
        buryConn = RunService.Heartbeat:Connect(function()
            local h = getHRP()
            if not h then
                buryConn:Disconnect()
                return
            end
            for i = 1, 100 do
                coroutine.wrap(function()
                    universalStamp(
                        CFrame.new(
                            h.Position.X + math.random(-200, 200),
                            h.Position.Y + math.random(50, 400),
                            h.Position.Z + math.random(-200, 200)
                        ),
                        {},
                        56450668,
                        "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                    )
                end)()
            end
        end)
        task.delay(10, function()
            pcall(function()
                buryConn:Disconnect()
            end)
            notify("⚰️ Burial complete")
        end)
    end)

    addButton(s, "📦 Shrinking Death Box", Color3.fromRGB(140, 0, 80), function()
        local hrp = getHRP()
        if not hrp then return end
        local base = hrp.CFrame
        coroutine.wrap(function()
            for r2 = 30, 3, -3 do
                for i = -r2, r2 do
                    for h = 0, 12 do
                        coroutine.wrap(function()
                            pcall(function()
                                universalStamp(base * CFrame.new(r2 * 4, h * 4, i * 4), {}, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                                universalStamp(base * CFrame.new(-r2 * 4, h * 4, i * 4), {}, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                                universalStamp(base * CFrame.new(i * 4, h * 4, r2 * 4), {}, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                                universalStamp(base * CFrame.new(i * 4, h * 4, -r2 * 4), {}, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                            end)
                        end)()
                    end
                end
                notify("📦 Box r=" .. r2, Color3.fromRGB(200, 50, 50))
                task.wait(2)
            end
        end)()
    end)

    addButton(s, "⚔️ PVP Arena", Color3.fromRGB(120, 60, 0), function()
        local hrp = getHRP()
        if not hrp then return end
        local base = hrp.CFrame
        local r2 = 20
        local plate = getBaseplate()
        local conn2 = {}
        if plate then conn2 = {plate} end
        for x = -r2, r2 do
            for z = -r2, r2 do
                coroutine.wrap(function()
                    pcall(function()
                        universalStamp(base * CFrame.new(x * 4, -4, z * 4), conn2, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                    end)
                end)()
            end
        end
        for h = 0, 10 do
            for i = -r2, r2 do
                coroutine.wrap(function()
                    pcall(function()
                        universalStamp(base * CFrame.new(i * 4, h * 4, r2 * 4), conn2, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                        universalStamp(base * CFrame.new(i * 4, h * 4, -r2 * 4), conn2, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                        universalStamp(base * CFrame.new(r2 * 4, h * 4, i * 4), conn2, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                        universalStamp(base * CFrame.new(-r2 * 4, h * 4, i * 4), conn2, 56450668, "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}")
                    end)
                end)()
            end
        end
        notify("⚔️ Arena built!")
    end)

    addButton(s, "🌐 Random Maze", Color3.fromRGB(0, 80, 80), function()
        local hrp = getHRP()
        if not hrp then return end
        local base = hrp.CFrame
        local plate = getBaseplate()
        local conn2 = {}
        if plate then conn2 = {plate} end
        for x = -20, 20 do
            for z = -20, 20 do
                if math.random() > 0.65 then
                    local wallHeight = math.random(2, 5)
                    for y = 0, wallHeight do
                        coroutine.wrap(function()
                            universalStamp(
                                base * CFrame.new(x * 8, y * 4, z * 8),
                                conn2,
                                56450668,
                                "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                            )
                        end)()
                    end
                end
            end
        end
        notify("🌐 Maze generated!")
    end)

    addSection(s, "── Lag Machine ──")

    local bsId = 56450668
    local bsGuid = "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"

    local bsRow = Instance.new("Frame")
    bsRow.Size = UDim2.new(1, 0, 0, 36)
    bsRow.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    bsRow.BorderSizePixel = 0
    bsRow.Parent = s
    local bsRowCorner = Instance.new("UICorner")
    bsRowCorner.CornerRadius = UDim.new(0, 6)
    bsRowCorner.Parent = bsRow

    local bsInput = Instance.new("TextBox")
    bsInput.Size = UDim2.new(0.68, 0, 1, -8)
    bsInput.Position = UDim2.new(0, 6, 0, 4)
    bsInput.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
    bsInput.PlaceholderText = "Asset ID override..."
    bsInput.Text = ""
    bsInput.Font = Enum.Font.Gotham
    bsInput.TextSize = 12
    bsInput.TextColor3 = Color3.new(1, 1, 1)
    bsInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    bsInput.BorderSizePixel = 0
    bsInput.ClearTextOnFocus = false
    bsInput.Parent = bsRow
    local bsInputCorner = Instance.new("UICorner")
    bsInputCorner.CornerRadius = UDim.new(0, 5)
    bsInputCorner.Parent = bsInput

    local bsSetBtn = Instance.new("TextButton")
    bsSetBtn.Size = UDim2.new(0.28, 0, 1, -8)
    bsSetBtn.Position = UDim2.new(0.7, 2, 0, 4)
    bsSetBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 30)
    bsSetBtn.Text = "Set ID"
    bsSetBtn.Font = Enum.Font.GothamBold
    bsSetBtn.TextSize = 12
    bsSetBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
    bsSetBtn.BorderSizePixel = 0
    bsSetBtn.AutoButtonColor = true
    bsSetBtn.Parent = bsRow
    local bsSetBtnCorner = Instance.new("UICorner")
    bsSetBtnCorner.CornerRadius = UDim.new(0, 5)
    bsSetBtnCorner.Parent = bsSetBtn

    bsSetBtn.MouseButton1Click:Connect(function()
        local id = tonumber(bsInput.Text)
        if id then
            bsId = id
        end
    end)

    local bsConn = nil
    addToggle(s, "♾️ INFINITE LAG LOOP", function(on)
        if bsConn then
            bsConn:Disconnect()
            bsConn = nil
        end
        if on then
            bsConn = RunService.Heartbeat:Connect(function()
                local hrp = getHRP()
                if not hrp then return end
                for i = 1, 10 do
                    coroutine.wrap(function()
                        universalStamp(
                            hrp.CFrame * CFrame.new(math.random(-30, 30), math.random(0, 20), math.random(-30, 30)),
                            {},
                            56450668,
                            "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}"
                        )
                    end)()
                end
            end)
        end
    end)

    addSection(s, "── Fling ──")

    local flingSpeed2 = 1000

    addSlider(s, "Fling Power", 100, 2000, 1000, function(v)
        flingSpeed2 = v
    end)

    addButton(s, "Fling Nearest", Color3.fromRGB(140, 40, 15), function()
        local hrp = getHRP()
        if not hrp then return end
        local nearest = nil
        local nearDist = math.huge
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local tc = plr.Character:FindFirstChild("HumanoidRootPart")
                if tc then
                    local d = (hrp.Position - tc.Position).Magnitude
                    if d < nearDist then
                        nearDist = d
                        nearest = tc
                    end
                end
            end
        end
        if nearest then
            hrp.CFrame = nearest.CFrame
            local bav = Instance.new("BodyAngularVelocity")
            bav.AngularVelocity = Vector3.new(0, flingSpeed2, 0)
            bav.MaxTorque = Vector3.new(0, flingSpeed2 * 100, 0)
            bav.P = 1e5
            bav.Parent = hrp
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(math.random(-1, 1) * 120, 80, math.random(-1, 1) * 120)
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = hrp
            task.delay(0.3, function()
                if bav and bav.Parent then bav:Destroy() end
                if bv and bv.Parent then bv:Destroy() end
            end)
        end
    end)

    addSection(s, "── Black Hole ──")

    local massiveBhConn = nil
    local massiveBhPart = nil

    addToggle(s, "🕳️ BLACK HOLE (Sucks All Parts)", function(on)
        if massiveBhConn then
            massiveBhConn:Disconnect()
            massiveBhConn = nil
        end
        if massiveBhPart then
            massiveBhPart:Destroy()
            massiveBhPart = nil
        end
        if on then
            local hrp = getHRP()
            if not hrp then return end
            massiveBhPart = Instance.new("Part")
            massiveBhPart.Size = Vector3.new(8, 8, 8)
            massiveBhPart.Shape = Enum.PartType.Ball
            massiveBhPart.BrickColor = BrickColor.new("Really black")
            massiveBhPart.Material = Enum.Material.Neon
            massiveBhPart.Anchored = true
            massiveBhPart.CanCollide = false
            massiveBhPart.CFrame = hrp.CFrame
            massiveBhPart.Parent = workspace
            massiveBhConn = RunService.Heartbeat:Connect(function()
                local h = getHRP()
                if not h then return end
                massiveBhPart.CFrame = h.CFrame * CFrame.new(0, 4, -12)
                local bhPos = massiveBhPart.Position
                for _, v in next, workspace:GetDescendants() do
                    if not v:IsA("BasePart") then continue end
                    if v.Anchored then continue end
                    if v == massiveBhPart then continue end
                    if v.Parent and v.Parent:FindFirstChildOfClass("Humanoid") then continue end
                    local dist = (v.Position - bhPos).Magnitude
                    if dist > 150 then continue end
                    local dir = (bhPos - v.Position).Unit
                    local speed = math.clamp(200 / (dist + 1) * 60, 10, 300)
                    local bv = v:FindFirstChild("__BH_BV")
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "__BH_BV"
                        bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
                        bv.Parent = v
                    end
                    bv.Velocity = dir * speed
                end
            end)
        end
    end)
end

-- ============================================================
-- CONFIG TAB
-- ============================================================
do
    local s = ConfigTab.scroll

    addSection(s, "── Save / Load ──")

    addButton(s, "💾 Save Config", Color3.fromRGB(40, 120, 40), function()
        saveCfg()
        notify("💾 Config saved!", Color3.fromRGB(40, 200, 80))
    end)

    addButton(s, "📂 Load Config", Color3.fromRGB(40, 80, 160), function()
        loadCfg()
        notify("📂 Config loaded!", Color3.fromRGB(80, 140, 255))
    end)

    addButton(s, "🗑 Reset to Defaults", Color3.fromRGB(140, 30, 30), function()
        cfg = {
            selectedAssetId   = 56450668,
            selectedAssetGuid = "{141ca1eb-2c9f-40a1-92db-f07269dfb3ed}",
            shapeSize         = 10,
            shapeThickness    = 1,
            orbitRadius       = 10,
            rainbowSpeed      = 1,
            flingSpeed        = 1000,
            hitboxSize        = 10,
            walkSpeed         = 16,
            jumpPower         = 50,
            autoClickSpeed    = 5,
            reachSize         = 10,
            lungeCooldown     = 0.01,
            spawnDelay        = 0.001,
        }
        notify("Config reset to defaults")
    end)

    addSection(s, "── About ──")

    local aboutLabel = Instance.new("TextLabel")
    aboutLabel.Size = UDim2.new(1, 0, 0, 100)
    aboutLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    aboutLabel.BorderSizePixel = 0
    aboutLabel.Font = Enum.Font.GothamBold
    aboutLabel.TextSize = 12
    aboutLabel.TextColor3 = Color3.fromRGB(220, 175, 30)
    aboutLabel.TextXAlignment = Enum.TextXAlignment.Left
    aboutLabel.TextYAlignment = Enum.TextYAlignment.Top
    aboutLabel.TextWrapped = true
    aboutLabel.Parent = s
    local aboutCorner = Instance.new("UICorner")
    aboutCorner.CornerRadius = UDim.new(0, 6)
    aboutCorner.Parent = aboutLabel
    local aboutPad = Instance.new("UIPadding")
    aboutPad.PaddingLeft = UDim.new(0, 10)
    aboutPad.Parent = aboutLabel
    aboutLabel.Text = "😊 Smiley Hub v4.3\n82 shapes | Kill Aura | Rainbow Tower\nStamp at Mouse | Anchored Mode | Sim Distance\nRShift = toggle"
end

-- ====================================================
-- OPEN DEFAULT TAB
-- ====================================================
task.wait(0.3)
selectTab(ScriptsTab)
notify("😊 Smiley Hub v4.3 — 82 shapes!", Color3.fromRGB(220, 175, 30))
print("[Smiley Hub v4.3] Loaded!")
