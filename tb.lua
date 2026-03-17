-- TRIGGERBOT + HITBOX EXPANDER
-- by FAME

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players
local player
local success, Players = pcall(game.GetService, game, "Players")
local player = Players.LocalPlayer
if not player then
    player = Players.PlayerAdded:Wait()
end
local mouse = player:GetMouse()
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local camera = workspace.CurrentCamera

-- ==================== VARIABLES TRIGGERBOT ====================
local enabled = false
local knifeCheck = true
local forceFieldCheck = false
local holdMode = true
local precision = 50
local triggerDelay = 1
local maxDistance = 500

local holdKey = Enum.UserInputType.MouseButton2 
local keyPressed = false
local triggerActive = false
local isSelectingKey = false
local guiVisible = true

local notificationDuration = 2
local currentNotifications = {}

-- ==================== VARIABLE HITBOX EXPANDER ====================
getgenv().hitboxEnabled = false
getgenv().hitboxTeamcheck = false
getgenv().hitboxSizeX = 4
getgenv().hitboxSizeY = 4
getgenv().hitboxSizeZ = 4
getgenv().hitboxTransparency = 0.9
getgenv().hitboxRefreshEnabled = false
getgenv().hitboxRefreshInterval = 5

-- SAVE ORIGINAL SIZE
local originalSizes = {}

-- ==================== FUNCTIONS HITBOX EXPANDER ====================
local function applyHitboxToPlayer(p)
    if not getgenv().hitboxEnabled then return end
    if p == player then return end
    if not p.Character then return end
    if getgenv().hitboxTeamcheck and p.Team == player.Team then return end

    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        if not originalSizes[p] then
            originalSizes[p] = hrp.Size
        end
        hrp.Size = Vector3.new(getgenv().hitboxSizeX, getgenv().hitboxSizeY, getgenv().hitboxSizeZ)
        hrp.Transparency = getgenv().hitboxTransparency
        hrp.CanCollide = false
    end
end

local function restoreOriginalSize(p)
    if originalSizes[p] and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        p.Character.HumanoidRootPart.Size = originalSizes[p]
        p.Character.HumanoidRootPart.Transparency = 1
        originalSizes[p] = nil
    end
end

local function applyHitboxToAll()
    for _, plr in ipairs(Players:GetPlayers()) do
        applyHitboxToPlayer(plr)
    end
end

local function restoreAllOriginal()
    for plr, _ in pairs(originalSizes) do
        restoreOriginalSize(plr)
    end
    originalSizes = {}
end

local function setupHitboxConnections(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.1)
        applyHitboxToPlayer(plr)
    end)
end

for _, plr in ipairs(Players:GetPlayers()) do
    setupHitboxConnections(plr)
end

Players.PlayerAdded:Connect(setupHitboxConnections)

coroutine.wrap(function()
    while true do
        if getgenv().hitboxEnabled and getgenv().hitboxRefreshEnabled then
            applyHitboxToAll()
        end
        task.wait(getgenv().hitboxRefreshInterval)
    end
end)()
-- ==================== GUI ====================
local gui = Instance.new("ScreenGui")
gui.Name = "TriggerBotGUI"
gui.Parent = game:FindFirstChild("CoreGui") or game.Players.LocalPlayer.PlayerGui
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.IgnoreGuiInset = true
gui.Enabled = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 500, 0, 680)
main.Position = UDim2.new(0.5, -250, 0.5, -340)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
main.ClipsDescendants = true
main.ZIndex = 2
main.Visible = true


local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.3
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = main
shadow.ZIndex = 1

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = main

local border = Instance.new("Frame")
border.Size = UDim2.new(1, 0, 1, 0)
border.BackgroundTransparency = 1
border.BorderSizePixel = 2
border.BorderColor3 = Color3.fromRGB(0, 150, 255)
border.Parent = main
border.ZIndex = 3

local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 16)
borderCorner.Parent = border

local borderGlow = Instance.new("Frame")
borderGlow.Size = UDim2.new(1, 0, 1, 0)
borderGlow.BackgroundTransparency = 0.95
borderGlow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
borderGlow.Parent = main
borderGlow.ZIndex = 3

local borderGlowCorner = Instance.new("UICorner")
borderGlowCorner.CornerRadius = UDim.new(0, 16)
borderGlowCorner.Parent = borderGlow

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
title.Text = "TRIGGERBOT | FAME"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = main
title.ZIndex = 4

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = title

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
})
titleGradient.Rotation = 45
titleGradient.Parent = title

local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.new(0.8, 0, 0, 2)
titleLine.Position = UDim2.new(0.1, 0, 1, -2)
titleLine.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
titleLine.Parent = title
titleLine.ZIndex = 4

local titleLineCorner = Instance.new("UICorner")
titleLineCorner.CornerRadius = UDim.new(1, 0)
titleLineCorner.Parent = titleLine

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 38, 0, 38)
closeBtn.Position = UDim2.new(1, -48, 0, 11)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.Parent = title
closeBtn.ZIndex = 5

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeBtn

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 38, 0, 38)
minimizeBtn.Position = UDim2.new(1, -96, 0, 11)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minimizeBtn.Text = "−"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 28
minimizeBtn.Parent = title
minimizeBtn.ZIndex = 5

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 10)
minimizeCorner.Parent = minimizeBtn

local function createHoverEffect(button, color, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = hoverColor or color,
            Size = UDim2.new(0, 40, 0, 40),
        }):Play()
        button.Position = UDim2.new(1, button.Position.X.Offset - 2, 0, 10)
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = button == closeBtn and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(60, 60, 70),
            Size = UDim2.new(0, 38, 0, 38),
        }):Play()
        button.Position = UDim2.new(1, button.Position.X.Offset + 2, 0, 11)
    end)
end

createHoverEffect(closeBtn, Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 100, 100))
createHoverEffect(minimizeBtn, Color3.fromRGB(60, 60, 70), Color3.fromRGB(80, 80, 90))

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -30, 1, -70)
scrollingFrame.Position = UDim2.new(0, 15, 0, 65)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.Parent = main
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ZIndex = 4
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.ElasticBehavior = Enum.ElasticBehavior.Always
scrollingFrame.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

-- PADDING 
local uiPadding = Instance.new("UIPadding")
uiPadding.PaddingRight = UDim.new(0, 11)
uiPadding.Parent = scrollingFrame

local gradientBg = Instance.new("UIGradient")
gradientBg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
gradientBg.Rotation = 45
gradientBg.Parent = main

local dots = Instance.new("ImageLabel")
dots.Size = UDim2.new(1, 0, 1, 0)
dots.BackgroundTransparency = 1
dots.Image = "rbxassetid://10670510697"
dots.ImageColor3 = Color3.fromRGB(0, 150, 255)
dots.ImageTransparency = 0.89
dots.ScaleType = Enum.ScaleType.Tile
dots.TileSize = UDim2.new(0, 50, 0, 50)
dots.Parent = main
dots.ZIndex = 2

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 15)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollingFrame

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end)

-- ==================== TRIGGER BOT ====================
local triggerSection = Instance.new("Frame")
triggerSection.Size = UDim2.new(1, 0, 0, 45)
triggerSection.BackgroundTransparency = 1
triggerSection.Parent = scrollingFrame
triggerSection.ZIndex = 4

local triggerLine = Instance.new("Frame")
triggerLine.Size = UDim2.new(0.3, 0, 0, 3)
triggerLine.Position = UDim2.new(0, 0, 1, -3)
triggerLine.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
triggerLine.Parent = triggerSection
triggerLine.ZIndex = 4

local triggerLineGlow = Instance.new("Frame")
triggerLineGlow.Size = UDim2.new(1, 0, 1, 0)
triggerLineGlow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
triggerLineGlow.BackgroundTransparency = 0.7
triggerLineGlow.Parent = triggerLine
triggerLineGlow.ZIndex = 4

local triggerLineCorner = Instance.new("UICorner")
triggerLineCorner.CornerRadius = UDim.new(1, 0)
triggerLineCorner.Parent = triggerLineGlow

local triggerLabel = Instance.new("TextLabel")
triggerLabel.Size = UDim2.new(1, -40, 1, 0)
triggerLabel.BackgroundTransparency = 1
triggerLabel.Text = "⚔ TRIGGER BOT"
triggerLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
triggerLabel.Font = Enum.Font.GothamBold
triggerLabel.TextSize = 20
triggerLabel.TextXAlignment = Enum.TextXAlignment.Left
triggerLabel.Parent = triggerSection
triggerLabel.ZIndex = 4

local triggerIcon = Instance.new("TextLabel")
triggerIcon.Size = UDim2.new(0, 40, 1, 0)
triggerIcon.Position = UDim2.new(1, -40, 0, 0)
triggerIcon.BackgroundTransparency = 1
triggerIcon.Text = "🎯"
triggerIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
triggerIcon.Font = Enum.Font.GothamBold
triggerIcon.TextSize = 24
triggerIcon.Parent = triggerSection
triggerIcon.ZIndex = 4


local function createCheckbox(text, default, accentColor)
    accentColor = accentColor or Color3.fromRGB(0, 150, 255)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = scrollingFrame
    frame.ZIndex = 4
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 24, 0, 24)
    checkbox.Position = UDim2.new(0, 0, 0.5, -12)
    checkbox.BackgroundColor3 = default and accentColor or Color3.fromRGB(45, 45, 50)
    checkbox.BorderSizePixel = 0
    checkbox.Text = ""
    checkbox.Parent = frame
    checkbox.ZIndex = 4
    checkbox.AutoButtonColor = false
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 8)
    checkCorner.Parent = checkbox
    
 
    local checkGlow = Instance.new("Frame")
    checkGlow.Size = UDim2.new(1, 2, 1, 2)
    checkGlow.Position = UDim2.new(0, -1, 0, -1)
    checkGlow.BackgroundTransparency = 1
    checkGlow.BorderSizePixel = 2
    checkGlow.BorderColor3 = default and accentColor or Color3.fromRGB(80, 80, 100)
    checkGlow.Parent = checkbox
    checkGlow.ZIndex = 5
    
    local checkGlowCorner = Instance.new("UICorner")
    checkGlowCorner.CornerRadius = UDim.new(0, 9)
    checkGlowCorner.Parent = checkGlow
    
    local checkMark = Instance.new("TextLabel")
    checkMark.Size = UDim2.new(1, 0, 1, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Text = default and "✓" or ""
    checkMark.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkMark.Font = Enum.Font.GothamBold
    checkMark.TextSize = 18
    checkMark.Parent = checkbox
    checkMark.ZIndex = 4
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -34, 1, 0)
    label.Position = UDim2.new(0, 32, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 250)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 4
    
    -- Efecto hover
    checkbox.MouseEnter:Connect(function()
        if checkbox.BackgroundColor3 ~= accentColor then
            TweenService:Create(checkbox, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(65, 65, 75),
                Size = UDim2.new(0, 26, 0, 26)
            }):Play()
            checkbox.Position = UDim2.new(0, -1, 0.5, -13)
        end
    end)
    
    checkbox.MouseLeave:Connect(function()
        if checkbox.BackgroundColor3 ~= accentColor then
            TweenService:Create(checkbox, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 50),
                Size = UDim2.new(0, 24, 0, 24)
            }):Play()
            checkbox.Position = UDim2.new(0, 0, 0.5, -12)
        end
    end)
    
    return {
        frame = frame,
        checkbox = checkbox,
        checkMark = checkMark,
        checkGlow = checkGlow,
        value = default,
        accentColor = accentColor
    }
end


local enableTrigger = createCheckbox("Enable Trigger Bot", false, Color3.fromRGB(0, 150, 255))
local knifeCheckbox = createCheckbox("Knife Check", true, Color3.fromRGB(0, 150, 255))
local forceFieldCheckbox = createCheckbox("Force Field Check", false, Color3.fromRGB(0, 150, 255))


local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(1, 0, 0, 85)
keyFrame.BackgroundTransparency = 1
keyFrame.Parent = scrollingFrame
keyFrame.ZIndex = 4

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, 0, 0, 30)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "🔑 KEYBIND CONFIGURATION"
keyLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
keyLabel.Font = Enum.Font.GothamBold
keyLabel.TextSize = 15
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = keyFrame
keyLabel.ZIndex = 4

local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0.48, 0, 0, 45)
modeBtn.Position = UDim2.new(0, 0, 0, 35)
modeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
modeBtn.Text = "HOLD"
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.Font = Enum.Font.GothamBlack
modeBtn.TextSize = 16
modeBtn.Parent = keyFrame
modeBtn.ZIndex = 4
modeBtn.AutoButtonColor = false

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 10)
modeCorner.Parent = modeBtn

local modeGlow = Instance.new("Frame")
modeGlow.Size = UDim2.new(1, 4, 1, 4)
modeGlow.Position = UDim2.new(0, -2, 0, -2)
modeGlow.BackgroundTransparency = 1
modeGlow.BorderSizePixel = 2
modeGlow.BorderColor3 = Color3.fromRGB(0, 150, 255)
modeGlow.Parent = modeBtn
modeGlow.ZIndex = 5

local modeGlowCorner = Instance.new("UICorner")
modeGlowCorner.CornerRadius = UDim.new(0, 11)
modeGlowCorner.Parent = modeGlow

modeBtn.MouseEnter:Connect(function()
    TweenService:Create(modeBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = holdMode and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(255, 170, 0),
        Size = UDim2.new(0.48, 5, 0, 47)
    }):Play()
end)

modeBtn.MouseLeave:Connect(function()
    TweenService:Create(modeBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = holdMode and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 150, 0),
        Size = UDim2.new(0.48, 0, 0, 45)
    }):Play()
end)

local keySelectBtn = Instance.new("TextButton")
keySelectBtn.Size = UDim2.new(0.48, 0, 0, 45)
keySelectBtn.Position = UDim2.new(0.52, 0, 0, 35)
keySelectBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
keySelectBtn.Text = "RIGHT CLICK (DEFAULT)"
keySelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keySelectBtn.Font = Enum.Font.GothamBlack
keySelectBtn.TextSize = 14
keySelectBtn.Parent = keyFrame
keySelectBtn.ZIndex = 4
keySelectBtn.AutoButtonColor = false

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 10)
keyCorner.Parent = keySelectBtn

local keyGlow = Instance.new("Frame")
keyGlow.Size = UDim2.new(1, 4, 1, 4)
keyGlow.Position = UDim2.new(0, -2, 0, -2)
keyGlow.BackgroundTransparency = 1
keyGlow.BorderSizePixel = 2
keyGlow.BorderColor3 = Color3.fromRGB(0, 150, 255)
keyGlow.Visible = false
keyGlow.Parent = keySelectBtn
keyGlow.ZIndex = 5

local keyGlowCorner = Instance.new("UICorner")
keyGlowCorner.CornerRadius = UDim.new(0, 11)
keyGlowCorner.Parent = keyGlow

keySelectBtn.MouseEnter:Connect(function()
    if not isSelectingKey then
        TweenService:Create(keySelectBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 70),
            Size = UDim2.new(0.48, 5, 0, 47)
        }):Play()
    end
end)

keySelectBtn.MouseLeave:Connect(function()
    if not isSelectingKey then
        TweenService:Create(keySelectBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50),
            Size = UDim2.new(0.48, 0, 0, 45)
        }):Play()
    end
end)


local configSection = Instance.new("Frame")
configSection.Size = UDim2.new(1, 0, 0, 45)
configSection.BackgroundTransparency = 1
configSection.Parent = scrollingFrame
configSection.ZIndex = 4

local configLine = Instance.new("Frame")
configLine.Size = UDim2.new(0.3, 0, 0, 3)
configLine.Position = UDim2.new(0, 0, 1, -3)
configLine.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
configLine.Parent = configSection
configLine.ZIndex = 4

local configLineGlow = Instance.new("Frame")
configLineGlow.Size = UDim2.new(1, 0, 1, 0)
configLineGlow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
configLineGlow.BackgroundTransparency = 0.7
configLineGlow.Parent = configLine
configLineGlow.ZIndex = 4

local configLineCorner = Instance.new("UICorner")
configLineCorner.CornerRadius = UDim.new(1, 0)
configLineCorner.Parent = configLineGlow

local configLabel = Instance.new("TextLabel")
configLabel.Size = UDim2.new(1, -40, 1, 0)
configLabel.BackgroundTransparency = 1
configLabel.Text = "⚙️ CONFIGURATION"
configLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
configLabel.Font = Enum.Font.GothamBold
configLabel.TextSize = 20
configLabel.TextXAlignment = Enum.TextXAlignment.Left
configLabel.Parent = configSection
configLabel.ZIndex = 4

local configIcon = Instance.new("TextLabel")
configIcon.Size = UDim2.new(0, 40, 1, 0)
configIcon.Position = UDim2.new(1, -40, 0, 0)
configIcon.BackgroundTransparency = 1
configIcon.Text = "🔧"
configIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
configIcon.Font = Enum.Font.GothamBold
configIcon.TextSize = 24
configIcon.Parent = configSection
configIcon.ZIndex = 4


local function createSlider(text, value, min, max, suffix, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = scrollingFrame
    frame.ZIndex = 4
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 250)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 4
    
    local valueBg = Instance.new("Frame")
    valueBg.Size = UDim2.new(0, 70, 0, 25)
    valueBg.Position = UDim2.new(1, -70, 0, 0)
    valueBg.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    valueBg.Parent = frame
    valueBg.ZIndex = 4
    
    local valueBgCorner = Instance.new("UICorner")
    valueBgCorner.CornerRadius = UDim.new(0, 6)
    valueBgCorner.Parent = valueBg
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = value .. (suffix or "")
    valueLabel.TextColor3 = color or Color3.fromRGB(0, 150, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.Parent = valueBg
    valueLabel.ZIndex = 4
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 10)
    sliderBg.Position = UDim2.new(0, 0, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    sliderBg.Parent = frame
    sliderBg.ZIndex = 4
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local percent = (value - min) / (max - min)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderFill.BackgroundColor3 = color or Color3.fromRGB(0, 150, 255)
    sliderFill.Parent = sliderBg
    sliderFill.ZIndex = 4
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = sliderFill
    
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(1, 0, 1, 0)
    glow.BackgroundTransparency = 0.7
    glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glow.Parent = sliderFill
    glow.ZIndex = 5
    
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, 0, 1, 0)
    sliderButton.BackgroundTransparency = 1
    sliderButton.Text = ""
    sliderButton.Parent = sliderBg
    sliderButton.ZIndex = 5
    
    for i = 0, 4 do
        local point = Instance.new("Frame")
        point.Size = UDim2.new(0, 2, 0, 6)
        point.Position = UDim2.new(i/4, -1, 0.5, -3)
        point.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        point.Parent = sliderBg
        point.ZIndex = 4
        
        local pointCorner = Instance.new("UICorner")
        pointCorner.CornerRadius = UDim.new(1, 0)
        pointCorner.Parent = point
    end
    
    return {frame = frame, sliderFill = sliderFill, valueLabel = valueLabel, value = value, min = min, max = max, suffix = suffix, button = sliderButton}
end

local precisionSlider = createSlider("Precision", 50, 0, 100, "%", Color3.fromRGB(0, 200, 100))
local delaySlider = createSlider("Trigger Delay", 1, 0, 100, "ms", Color3.fromRGB(255, 150, 0))
local distanceSlider = createSlider("Max Distance", 500, 0, 5000, "", Color3.fromRGB(200, 100, 255))

-- ==================== HITBOX EXPANDER ====================
local hitboxSection = Instance.new("Frame")
hitboxSection.Size = UDim2.new(1, 0, 0, 45)
hitboxSection.BackgroundTransparency = 1
hitboxSection.Parent = scrollingFrame
hitboxSection.ZIndex = 4

local hitboxLine = Instance.new("Frame")
hitboxLine.Size = UDim2.new(0.3, 0, 0, 3)
hitboxLine.Position = UDim2.new(0, 0, 1, -3)
hitboxLine.BackgroundColor3 = Color3.fromRGB(255, 70, 200)
hitboxLine.Parent = hitboxSection
hitboxLine.ZIndex = 4

local hitboxLineGlow = Instance.new("Frame")
hitboxLineGlow.Size = UDim2.new(1, 0, 1, 0)
hitboxLineGlow.BackgroundColor3 = Color3.fromRGB(255, 70, 200)
hitboxLineGlow.BackgroundTransparency = 0.7
hitboxLineGlow.Parent = hitboxLine
hitboxLineGlow.ZIndex = 4

local hitboxLineCorner = Instance.new("UICorner")
hitboxLineCorner.CornerRadius = UDim.new(1, 0)
hitboxLineCorner.Parent = hitboxLineGlow

local hitboxLabel = Instance.new("TextLabel")
hitboxLabel.Size = UDim2.new(1, -40, 1, 0)
hitboxLabel.BackgroundTransparency = 1
hitboxLabel.Text = "📦 HITBOX EXPANDER"
hitboxLabel.TextColor3 = Color3.fromRGB(255, 70, 200)
hitboxLabel.Font = Enum.Font.GothamBold
hitboxLabel.TextSize = 20
hitboxLabel.TextXAlignment = Enum.TextXAlignment.Left
hitboxLabel.Parent = hitboxSection
hitboxLabel.ZIndex = 4

local hitboxIcon = Instance.new("TextLabel")
hitboxIcon.Size = UDim2.new(0, 40, 1, 0)
hitboxIcon.Position = UDim2.new(1, -40, 0, 0)
hitboxIcon.BackgroundTransparency = 1
hitboxIcon.Text = "🎯"
hitboxIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
hitboxIcon.Font = Enum.Font.GothamBold
hitboxIcon.TextSize = 24
hitboxIcon.Parent = hitboxSection
hitboxIcon.ZIndex = 4

-- Checkbox: Habilitar hitbox (usamos color rosa)
local enableHitbox = createCheckbox("Enable Hitbox Expander", false, Color3.fromRGB(255, 70, 200))

-- Checkbox: Team check
local teamcheckHitbox = createCheckbox("Team Check (only enemies)", false, Color3.fromRGB(255, 70, 200))

-- Checkbox: Refresco automático
local refreshCheck = createCheckbox("Auto Refresh (fix respawn)", false, Color3.fromRGB(255, 70, 200))

-- Sliders for size x y z
local sizeXSlider = createSlider("Size X", 4, 1, 20, "", Color3.fromRGB(255, 70, 200))
local draggingSizeX = false
sizeXSlider.button.MouseButton1Down:Connect(function(input)
    draggingSizeX = true
    local function update()
        local percent = (UserInputService:GetMouseLocation().X - sizeXSlider.button.AbsolutePosition.X) / sizeXSlider.button.AbsoluteSize.X
        percent = math.clamp(percent, 0, 1)
        sizeXSlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        local val = math.floor(percent * 19) + 1  -- 1 a 20
        getgenv().hitboxSizeX = val
        sizeXSlider.valueLabel.Text = val
        if getgenv().hitboxEnabled then
            applyHitboxToAll()
        end
    end
    update()
    local conn
    conn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and draggingSizeX then
            update()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingSizeX then
            draggingSizeX = false
            conn:Disconnect()
        end
    end)
end)

local sizeYSlider = createSlider("Size Y", 4, 1, 20, "", Color3.fromRGB(255, 70, 200))
local draggingSizeY = false
sizeYSlider.button.MouseButton1Down:Connect(function(input)
    draggingSizeY = true
    local function update()
        local percent = (UserInputService:GetMouseLocation().X - sizeYSlider.button.AbsolutePosition.X) / sizeYSlider.button.AbsoluteSize.X
        percent = math.clamp(percent, 0, 1)
        sizeYSlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        local val = math.floor(percent * 19) + 1
        getgenv().hitboxSizeY = val
        sizeYSlider.valueLabel.Text = val
        if getgenv().hitboxEnabled then
            applyHitboxToAll()
        end
    end
    update()
    local conn
    conn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and draggingSizeY then
            update()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingSizeY then
            draggingSizeY = false
            conn:Disconnect()
        end
    end)
end)

local sizeZSlider = createSlider("Size Z", 4, 1, 20, "", Color3.fromRGB(255, 70, 200))
local draggingSizeZ = false
sizeZSlider.button.MouseButton1Down:Connect(function(input)
    draggingSizeZ = true
    local function update()
        local percent = (UserInputService:GetMouseLocation().X - sizeZSlider.button.AbsolutePosition.X) / sizeZSlider.button.AbsoluteSize.X
        percent = math.clamp(percent, 0, 1)
        sizeZSlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        local val = math.floor(percent * 19) + 1
        getgenv().hitboxSizeZ = val
        sizeZSlider.valueLabel.Text = val
        if getgenv().hitboxEnabled then
            applyHitboxToAll()
        end
    end
    update()
    local conn
    conn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and draggingSizeZ then
            update()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingSizeZ then
            draggingSizeZ = false
            conn:Disconnect()
        end
    end)
end)

-- Slider for opacity
local opacitySlider = createSlider("Opacity", 0.9, 0, 1, "", Color3.fromRGB(255, 70, 200))
opacitySlider.valueLabel.Text = "0.9"
local draggingOpacity = false
opacitySlider.button.MouseButton1Down:Connect(function(input)
    draggingOpacity = true
    local function update()
        local percent = (UserInputService:GetMouseLocation().X - opacitySlider.button.AbsolutePosition.X) / opacitySlider.button.AbsoluteSize.X
        percent = math.clamp(percent, 0, 1)
        opacitySlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        local val = percent  -- 0 - 1
        getgenv().hitboxTransparency = val
        opacitySlider.valueLabel.Text = string.format("%.2f", val)
        if getgenv().hitboxEnabled then
            applyHitboxToAll()
        end
    end
    update()
    local conn
    conn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and draggingOpacity then
            update()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingOpacity then
            draggingOpacity = false
            conn:Disconnect()
        end
    end)
end)

-- Slider for refresh interval
local intervalSlider = createSlider("Refresh Interval (s)", 5, 0.1, 15, "s", Color3.fromRGB(255, 70, 200))
intervalSlider.valueLabel.Text = "5.0s"
local draggingInterval = false
intervalSlider.button.MouseButton1Down:Connect(function(input)
    draggingInterval = true
    local function update()
        local percent = (UserInputService:GetMouseLocation().X - intervalSlider.button.AbsolutePosition.X) / intervalSlider.button.AbsoluteSize.X
        percent = math.clamp(percent, 0, 1)
        intervalSlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        local val = 0.1 + percent * 14.9  -- range 0.1 - 15
        getgenv().hitboxRefreshInterval = val
        intervalSlider.valueLabel.Text = string.format("%.1fs", val)
    end
    update()
    local conn
    conn = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and draggingInterval then
            update()
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingInterval then
            draggingInterval = false
            conn:Disconnect()
        end
    end)
end)

-- ==================== NOTIFICACIONES ====================
local function showNotification(title, message, duration, type)
    duration = duration or notificationDuration
    
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 320, 0, 70)
    notif.Position = UDim2.new(1, -340, 0, 20 + (#currentNotifications * 80))
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    notif.Parent = gui
    notif.ZIndex = 100
    notif.ClipsDescendants = true
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 12)
    notifCorner.Parent = notif
    
    local notifBorder = Instance.new("Frame")
    notifBorder.Size = UDim2.new(1, 0, 1, 0)
    notifBorder.BackgroundTransparency = 1
    notifBorder.BorderSizePixel = 3
    notifBorder.BorderColor3 = type == "success" and Color3.fromRGB(0, 255, 0) or 
                              type == "error" and Color3.fromRGB(255, 0, 0) or 
                              Color3.fromRGB(0, 150, 255)
    notifBorder.Parent = notif
    notifBorder.ZIndex = 101
    
    local notifBorderCorner = Instance.new("UICorner")
    notifBorderCorner.CornerRadius = UDim.new(0, 12)
    notifBorderCorner.Parent = notifBorder
    
    local notifIcon = Instance.new("TextLabel")
    notifIcon.Size = UDim2.new(0, 30, 1, 0)
    notifIcon.Position = UDim2.new(0, 10, 0, 0)
    notifIcon.BackgroundTransparency = 1
    notifIcon.Text = type == "success" and "✅" or type == "error" and "❌" or "ℹ️"
    notifIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifIcon.Font = Enum.Font.GothamBold
    notifIcon.TextSize = 24
    notifIcon.Parent = notif
    notifIcon.ZIndex = 101
    
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -50, 0, 25)
    notifTitle.Position = UDim2.new(0, 45, 0, 10)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = title
    notifTitle.TextColor3 = type == "success" and Color3.fromRGB(0, 255, 0) or 
                           type == "error" and Color3.fromRGB(255, 0, 0) or 
                           Color3.fromRGB(0, 150, 255)
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextSize = 16
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.Parent = notif
    notifTitle.ZIndex = 101
    
    local notifMessage = Instance.new("TextLabel")
    notifMessage.Size = UDim2.new(1, -50, 0, 30)
    notifMessage.Position = UDim2.new(0, 45, 0, 30)
    notifMessage.BackgroundTransparency = 1
    notifMessage.Text = message
    notifMessage.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifMessage.Font = Enum.Font.GothamBlack
    notifMessage.TextSize = 13
    notifMessage.TextXAlignment = Enum.TextXAlignment.Left
    notifMessage.TextWrapped = true
    notifMessage.Parent = notif
    notifMessage.ZIndex = 101
    
    table.insert(currentNotifications, notif)
    
    notif.Position = UDim2.new(1, 0, 0, 20 + ((#currentNotifications-1) * 80))
    notif.Rotation = -5
    TweenService:Create(notif, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -340, 0, 20 + ((#currentNotifications-1) * 80)),
        Rotation = 0
    }):Play()
    
    task.wait(duration)
    
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
        Position = UDim2.new(1, 0, 0, 20 + ((#currentNotifications-1) * 80)),
        Rotation = 5
    }):Play()
    
    task.wait(0.5)
    notif:Destroy()
    
    for i, n in ipairs(currentNotifications) do
        if n == notif then
            table.remove(currentNotifications, i)
            break
        end
    end
    
    for i, n in ipairs(currentNotifications) do
        TweenService:Create(n, TweenInfo.new(0.3), {
            Position = UDim2.new(1, -340, 0, 20 + ((i-1) * 80))
        }):Play()
    end
end

-- Eventos de los checkboxes (Trigger Bot) - CON RESPUESTA INSTANTÁNEA
enableTrigger.checkbox.MouseButton1Down:Connect(function()
    local newState = not enableTrigger.value
    enableTrigger.checkbox.BackgroundColor3 = newState and enableTrigger.accentColor or Color3.fromRGB(45, 45, 50)
    enableTrigger.checkGlow.BorderColor3 = newState and enableTrigger.accentColor or Color3.fromRGB(80, 80, 100)
    enableTrigger.checkMark.Text = newState and "✓" or ""
end)

enableTrigger.checkbox.MouseButton1Click:Connect(function()
    enabled = not enabled
    enableTrigger.value = enabled
    -- Aseguramos que los colores coincidan (por si el clic fue muy rápido y no se ejecutó el Down)
    enableTrigger.checkbox.BackgroundColor3 = enabled and enableTrigger.accentColor or Color3.fromRGB(45, 45, 50)
    enableTrigger.checkGlow.BorderColor3 = enabled and enableTrigger.accentColor or Color3.fromRGB(80, 80, 100)
    enableTrigger.checkMark.Text = enabled and "✓" or ""
end)

knifeCheckbox.checkbox.MouseButton1Down:Connect(function()
    local newState = not knifeCheckbox.value
    knifeCheckbox.checkbox.BackgroundColor3 = newState and knifeCheckbox.accentColor or Color3.fromRGB(45, 45, 50)
    knifeCheckbox.checkGlow.BorderColor3 = newState and knifeCheckbox.accentColor or Color3.fromRGB(80, 80, 100)
    knifeCheckbox.checkMark.Text = newState and "✓" or ""
end)

knifeCheckbox.checkbox.MouseButton1Click:Connect(function()
    knifeCheck = not knifeCheck
    knifeCheckbox.value = knifeCheck
    knifeCheckbox.checkbox.BackgroundColor3 = knifeCheck and knifeCheckbox.accentColor or Color3.fromRGB(45, 45, 50)
    knifeCheckbox.checkGlow.BorderColor3 = knifeCheck and knifeCheckbox.accentColor or Color3.fromRGB(80, 80, 100)
    knifeCheckbox.checkMark.Text = knifeCheck and "✓" or ""
end)

forceFieldCheckbox.checkbox.MouseButton1Down:Connect(function()
    local newState = not forceFieldCheckbox.value
    forceFieldCheckbox.checkbox.BackgroundColor3 = newState and forceFieldCheckbox.accentColor or Color3.fromRGB(45, 45, 50)
    forceFieldCheckbox.checkGlow.BorderColor3 = newState and forceFieldCheckbox.accentColor or Color3.fromRGB(80, 80, 100)
    forceFieldCheckbox.checkMark.Text = newState and "✓" or ""
end)

forceFieldCheckbox.checkbox.MouseButton1Click:Connect(function()
    forceFieldCheck = not forceFieldCheck
    forceFieldCheckbox.value = forceFieldCheck
    forceFieldCheckbox.checkbox.BackgroundColor3 = forceFieldCheck and forceFieldCheckbox.accentColor or Color3.fromRGB(45, 45, 50)
    forceFieldCheckbox.checkGlow.BorderColor3 = forceFieldCheck and forceFieldCheckbox.accentColor or Color3.fromRGB(80, 80, 100)
    forceFieldCheckbox.checkMark.Text = forceFieldCheck and "✓" or ""
end)

-- Eventos para hitbox checkboxes
enableHitbox.checkbox.MouseButton1Down:Connect(function()
    local newState = not enableHitbox.value
    enableHitbox.checkbox.BackgroundColor3 = newState and enableHitbox.accentColor or Color3.fromRGB(45, 45, 50)
    enableHitbox.checkGlow.BorderColor3 = newState and enableHitbox.accentColor or Color3.fromRGB(80, 80, 100)
    enableHitbox.checkMark.Text = newState and "✓" or ""
end)

enableHitbox.checkbox.MouseButton1Click:Connect(function()
    getgenv().hitboxEnabled = not getgenv().hitboxEnabled
    enableHitbox.value = getgenv().hitboxEnabled
    enableHitbox.checkbox.BackgroundColor3 = getgenv().hitboxEnabled and enableHitbox.accentColor or Color3.fromRGB(45, 45, 50)
    enableHitbox.checkGlow.BorderColor3 = getgenv().hitboxEnabled and enableHitbox.accentColor or Color3.fromRGB(80, 80, 100)
    enableHitbox.checkMark.Text = getgenv().hitboxEnabled and "✓" or ""
    
    if getgenv().hitboxEnabled then
        applyHitboxToAll()
        showNotification("Hitbox", "🟢 ENABLED", 2, "success")
    else
        restoreAllOriginal()
        showNotification("Hitbox", "🔴 DISABLED", 2, "error")
    end
end)

teamcheckHitbox.checkbox.MouseButton1Down:Connect(function()
    local newState = not teamcheckHitbox.value
    teamcheckHitbox.checkbox.BackgroundColor3 = newState and teamcheckHitbox.accentColor or Color3.fromRGB(45, 45, 50)
    teamcheckHitbox.checkGlow.BorderColor3 = newState and teamcheckHitbox.accentColor or Color3.fromRGB(80, 80, 100)
    teamcheckHitbox.checkMark.Text = newState and "✓" or ""
end)

teamcheckHitbox.checkbox.MouseButton1Click:Connect(function()
    getgenv().hitboxTeamcheck = not getgenv().hitboxTeamcheck
    teamcheckHitbox.value = getgenv().hitboxTeamcheck
    teamcheckHitbox.checkbox.BackgroundColor3 = getgenv().hitboxTeamcheck and teamcheckHitbox.accentColor or Color3.fromRGB(45, 45, 50)
    teamcheckHitbox.checkGlow.BorderColor3 = getgenv().hitboxTeamcheck and teamcheckHitbox.accentColor or Color3.fromRGB(80, 80, 100)
    teamcheckHitbox.checkMark.Text = getgenv().hitboxTeamcheck and "✓" or ""
    
    if getgenv().hitboxEnabled then
        restoreAllOriginal()
        applyHitboxToAll()
    end
end)

refreshCheck.checkbox.MouseButton1Down:Connect(function()
    local newState = not refreshCheck.value
    refreshCheck.checkbox.BackgroundColor3 = newState and refreshCheck.accentColor or Color3.fromRGB(45, 45, 50)
    refreshCheck.checkGlow.BorderColor3 = newState and refreshCheck.accentColor or Color3.fromRGB(80, 80, 100)
    refreshCheck.checkMark.Text = newState and "✓" or ""
end)

refreshCheck.checkbox.MouseButton1Click:Connect(function()
    getgenv().hitboxRefreshEnabled = not getgenv().hitboxRefreshEnabled
    refreshCheck.value = getgenv().hitboxRefreshEnabled
    refreshCheck.checkbox.BackgroundColor3 = getgenv().hitboxRefreshEnabled and refreshCheck.accentColor or Color3.fromRGB(45, 45, 50)
    refreshCheck.checkGlow.BorderColor3 = getgenv().hitboxRefreshEnabled and refreshCheck.accentColor or Color3.fromRGB(80, 80, 100)
    refreshCheck.checkMark.Text = getgenv().hitboxRefreshEnabled and "✓" or ""
    
    showNotification("Auto Refresh", getgenv().hitboxRefreshEnabled and "✅ Enabled" or "❌ Disabled", 2, "info")
end)

modeBtn.MouseButton1Click:Connect(function()
    holdMode = not holdMode
    modeBtn.Text = holdMode and "HOLD" or "TOGGLE"
    
    TweenService:Create(modeBtn, TweenInfo.new(0.3), {
        BackgroundColor3 = holdMode and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 150, 0)
    }):Play()
end)

keySelectBtn.MouseButton1Click:Connect(function()
    isSelectingKey = true
    
    TweenService:Create(keySelectBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 150, 0),
        Size = UDim2.new(0.48, 5, 0, 47)
    }):Play()
    TweenService:Create(keyGlow, TweenInfo.new(0.2), {Visible = true}):Play()
    
    keySelectBtn.Text = "PRESS KEY"
end)

UserInputService.InputBegan:Connect(function(input)
    if isSelectingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            holdKey = input.KeyCode
            keySelectBtn.Text = "⌨️ " .. input.KeyCode.Name
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdKey = Enum.UserInputType.MouseButton1
            keySelectBtn.Text = "🖱️ LEFT CLICK"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            holdKey = Enum.UserInputType.MouseButton2
            keySelectBtn.Text = "🖱️ RIGHT CLICK"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            holdKey = Enum.UserInputType.MouseButton3
            keySelectBtn.Text = "🖱️ MIDDLE CLICK"
        end
        
        TweenService:Create(keySelectBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50),
            Size = UDim2.new(0.48, 0, 0, 45)
        }):Play()
        TweenService:Create(keyGlow, TweenInfo.new(0.2), {Visible = false}):Play()
        
        isSelectingKey = false
    end
end)

-- Sliders dragging (Triggerbot)
local draggingPrecision = false
local draggingDelay = false
local draggingDistance = false

precisionSlider.button.MouseButton1Down:Connect(function(input)
    draggingPrecision = true
    local mouseX = input.Position.X
    local bgPos = precisionSlider.button.AbsolutePosition.X
    local bgSize = precisionSlider.button.AbsoluteSize.X
    local percent = (mouseX - bgPos) / bgSize
    percent = math.clamp(percent, 0, 1)
    
    TweenService:Create(precisionSlider.sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    precision = math.floor(percent * 100)
    precisionSlider.valueLabel.Text = precision .. "%"
end)

delaySlider.button.MouseButton1Down:Connect(function(input)
    draggingDelay = true
    local mouseX = input.Position.X
    local bgPos = delaySlider.button.AbsolutePosition.X
    local bgSize = delaySlider.button.AbsoluteSize.X
    local percent = (mouseX - bgPos) / bgSize
    percent = math.clamp(percent, 0, 1)
    
    TweenService:Create(delaySlider.sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    triggerDelay = math.floor(percent * 100)
    delaySlider.valueLabel.Text = triggerDelay .. "ms"
end)

distanceSlider.button.MouseButton1Down:Connect(function(input)
    draggingDistance = true
    local mouseX = input.Position.X
    local bgPos = distanceSlider.button.AbsolutePosition.X
    local bgSize = distanceSlider.button.AbsoluteSize.X
    local percent = (mouseX - bgPos) / bgSize
    percent = math.clamp(percent, 0, 1)
    
    TweenService:Create(distanceSlider.sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    maxDistance = math.floor(percent * 5000)
    distanceSlider.valueLabel.Text = maxDistance
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        
        if draggingPrecision then
            local bgPos = precisionSlider.button.AbsolutePosition.X
            local bgSize = precisionSlider.button.AbsoluteSize.X
            local percent = (mousePos.X - bgPos) / bgSize
            percent = math.clamp(percent, 0, 1)
            precisionSlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            precision = math.floor(percent * 100)
            precisionSlider.valueLabel.Text = precision .. "%"
        end
        
        if draggingDelay then
            local bgPos = delaySlider.button.AbsolutePosition.X
            local bgSize = delaySlider.button.AbsoluteSize.X
            local percent = (mousePos.X - bgPos) / bgSize
            percent = math.clamp(percent, 0, 1)
            delaySlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            triggerDelay = math.floor(percent * 100)
            delaySlider.valueLabel.Text = triggerDelay .. "ms"
        end
        
        if draggingDistance then
            local bgPos = distanceSlider.button.AbsolutePosition.X
            local bgSize = distanceSlider.button.AbsoluteSize.X
            local percent = (mousePos.X - bgPos) / bgSize
            percent = math.clamp(percent, 0, 1)
            distanceSlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            maxDistance = math.floor(percent * 5000)
            distanceSlider.valueLabel.Text = maxDistance
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if draggingPrecision then
            draggingPrecision = false
        end
        if draggingDelay then
            draggingDelay = false
        end
        if draggingDistance then
            draggingDistance = false
        end
    end
end)

-- Visibilidad con Ctrl derecho
local function isCtrlKey(input)
    return input.KeyCode == Enum.KeyCode.RightControl
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and isCtrlKey(input) and not isSelectingKey then
        guiVisible = not guiVisible
        
        if guiVisible then
            main.Visible = true
            TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 500, 0, 680),
                BackgroundTransparency = 0,
            }):Play()
            showNotification("GUI", "🟢 OPEN INTERFACE", 2, "success")
        else
            TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
            }):Play()
            task.wait(0.3)
            main.Visible = false
        end
        return
    end
end)

minimizeBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    
    TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }):Play()
    
    task.wait(0.3)
    main.Visible = false
end)

closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }):Play()
    
    task.wait(0.5)
    gui:Destroy()
    enabled = false
end)

-- Animación de entrada
main.Size = UDim2.new(0, 0, 0, 0)
main.BackgroundTransparency = 1
main.Visible = true

task.wait(0.1)
TweenService:Create(main, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 500, 0, 680),
    BackgroundTransparency = 0
}):Play()

-- Funciones auxiliares para el triggerbot
local function isKeyPressed(input)
    if typeof(holdKey) == "EnumItem" then
        if holdKey.EnumType == Enum.UserInputType then
            return input.UserInputType == holdKey
        elseif holdKey.EnumType == Enum.KeyCode then
            return input.KeyCode == holdKey
        end
    end
    return false
end

UserInputService.InputBegan:Connect(function(input)
    if isKeyPressed(input) then
        keyPressed = true
        if enabled then
            if holdMode then
                triggerActive = true
                TweenService:Create(enableTrigger.checkbox, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(0, 200, 255)
                }):Play()
            else
                triggerActive = not triggerActive
                TweenService:Create(enableTrigger.checkbox, TweenInfo.new(0.2), {
                    BackgroundColor3 = triggerActive and Color3.fromRGB(0, 200, 255) or enableTrigger.accentColor
                }):Play()
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if isKeyPressed(input) then
        keyPressed = false
        if enabled and holdMode then
            triggerActive = false
            TweenService:Create(enableTrigger.checkbox, TweenInfo.new(0.2), {
                BackgroundColor3 = enableTrigger.accentColor
            }):Play()
        end
    end
end)

local function hasKnifeEquipped()
    local character = player.Character
    if not character then return false end
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        local toolName = tool.Name:lower()
        local knifeNames = {"knife", "chicken", "pizza", "cranberry", "meet", "taco", "fists"}
        for _, name in ipairs(knifeNames) do
            if toolName:find(name) then
                return true
            end
        end
    end
    return false
end

local function getDistanceFromTarget(targetPart)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return math.huge end
    local rootPart = character.HumanoidRootPart
    return (rootPart.Position - targetPart.Position).Magnitude
end

local function getTarget()
    if not mouse.Target then return nil end

    local target = mouse.Target
    local model = target:FindFirstAncestorOfClass("Model")
    if not model then return nil end

    local plr = Players:GetPlayerFromCharacter(model)
    if not plr or plr == player then return nil end

    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end

    local distance = getDistanceFromTarget(target)
    if distance > maxDistance then return nil end

    return target
end

local function shoot()
    local success = pcall(mouse1click)
    if success then return end

    success = pcall(function()
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
    end)
    if success then return end

    success = pcall(function()
        UserInputService:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
        task.wait(0.01)
        UserInputService:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
    end)
    if success then return end

    local character = player.Character
    if character then
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
            pcall(function() tool:Click() end)
            local remoteNames = {"Fire", "Shoot", "Remote", "WeaponRemote", "Activate"}
            for _, name in ipairs(remoteNames) do
                local remote = tool:FindFirstChild(name)
                if remote and remote:IsA("RemoteEvent") then
                    pcall(function() remote:FireServer() end)
                end
            end
        end
    end

    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.01)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

-- mainloop
local lastShotTime = 0
local mousePressed = false

RunService.Heartbeat:Connect(function()
    local shouldTrigger = enabled and triggerActive
    if not shouldTrigger then
        if mousePressed then
            mouse1release()
            mousePressed = false
        end
        return
    end

    local currentTime = tick()
    if currentTime - lastShotTime < (triggerDelay / 1000) then
        return
    end

    local target = getTarget()
    if target then
        if knifeCheck and hasKnifeEquipped() then
            if mousePressed then
                mouse1release()
                mousePressed = false
            end
            return
        end

        if math.random(1, 100) <= precision then
            shoot()
            lastShotTime = currentTime
            mousePressed = true
        end
    else
        if mousePressed then
            mouse1release()
            mousePressed = false
        end
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.RightControl then
        if mousePressed then
            mouse1release()
            mousePressed = false
        end
    end
end)

-- last notif
showNotification("TRIGGERBOT", "🚀 LOADED SUCCESSFULLY!", 3, "success")
showNotification("CONTROLES", "CTRL TO OPEN/CLOSE", 3, "info")
showNotification("DISCORD SERVER", "https://discord.gg/ugg6MqEQTa ", 7, "info")
