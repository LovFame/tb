-- TRIGGERBOT - DA HOOD (VERSIÓN CORREGIDA - FUNCIONA EL DISPARO)
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Variables
local enabled = false
local knifeCheck = true
local forceFieldCheck = false
local holdMode = true
local precision = 50
local triggerDelay = 1
local maxDistance = 500 

-- Variables para tecla personalizable
local holdKey = Enum.UserInputType.MouseButton2 
local keyPressed = false
local triggerActive = false
local isSelectingKey = false
local guiVisible = true

-- Variables para efectos
local notificationDuration = 2
local currentNotifications = {}

-- Variable para controlar el disparo
local canShoot = true

-- GUI Principal
local gui = Instance.new("ScreenGui")
gui.Name = "TriggerBotGUI"
gui.Parent = game:FindFirstChild("CoreGui") or game.Players.LocalPlayer.PlayerGui
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.IgnoreGuiInset = true
gui.Enabled = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MAIN FRAME (Toda la GUI igual que antes, sin cambios)
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 520)
main.Position = UDim2.new(0.5, -200, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
main.ClipsDescendants = true
main.ZIndex = 2
main.Visible = true

-- Sombra mejorada
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

-- Bordes redondeados
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = main

-- Borde decorativo con gradiente
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

-- Efecto de brillo en el borde
local borderGlow = Instance.new("Frame")
borderGlow.Size = UDim2.new(1, 0, 1, 0)
borderGlow.BackgroundTransparency = 0.95
borderGlow.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
borderGlow.Parent = main
borderGlow.ZIndex = 3

local borderGlowCorner = Instance.new("UICorner")
borderGlowCorner.CornerRadius = UDim.new(0, 16)
borderGlowCorner.Parent = borderGlow

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
title.Text = "⚡ TRIGGER BOT | FAME ⚡"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = main
title.ZIndex = 4

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = title

-- Gradiente del título
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 200, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 150, 255))
})
titleGradient.Rotation = 45
titleGradient.Parent = title

-- Línea decorativa bajo el título
local titleLine = Instance.new("Frame")
titleLine.Size = UDim2.new(0.8, 0, 0, 2)
titleLine.Position = UDim2.new(0.1, 0, 1, -2)
titleLine.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
titleLine.Parent = title
titleLine.ZIndex = 4

local titleLineCorner = Instance.new("UICorner")
titleLineCorner.CornerRadius = UDim.new(1, 0)
titleLineCorner.Parent = titleLine

-- Botón de cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 38, 0, 38)
closeBtn.Position = UDim2.new(1, -48, 0, 11)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 22
closeBtn.Parent = title
closeBtn.ZIndex = 5

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeBtn

-- Botón de minimizar
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

-- Animación de hover para botones
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

-- Contenedor principal con scroll
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

-- Fondo con gradiente mejorado
local gradientBg = Instance.new("UIGradient")
gradientBg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
gradientBg.Rotation = 45
gradientBg.Parent = main

-- Patrón de puntos decorativo
local dots = Instance.new("ImageLabel")
dots.Size = UDim2.new(1, 0, 1, 0)
dots.BackgroundTransparency = 1
dots.Image = "rbxassetid://3570695787"
dots.ImageColor3 = Color3.fromRGB(0, 150, 255)
dots.ImageTransparency = 0.95
dots.ScaleType = Enum.ScaleType.Tile
dots.TileSize = UDim2.new(0, 50, 0, 50)
dots.Parent = main
dots.ZIndex = 2

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 15)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollingFrame

-- Conectar el cambio de CanvasSize automáticamente
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end)

-- = SECCION TRIGGER BOT =
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
triggerLabel.Text = "⚡ TRIGGER BOT"
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

-- Función para crear checkboxes con animación y persistencia de color
local function createCheckbox(text, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = scrollingFrame
    frame.ZIndex = 4
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 24, 0, 24)
    checkbox.Position = UDim2.new(0, 0, 0.5, -12)
    checkbox.BackgroundColor3 = default and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 50)
    checkbox.BorderSizePixel = 0
    checkbox.Text = ""
    checkbox.Parent = frame
    checkbox.ZIndex = 4
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 8)
    checkCorner.Parent = checkbox
    
    local checkGlow = Instance.new("Frame")
    checkGlow.Size = UDim2.new(1, 2, 1, 2)
    checkGlow.Position = UDim2.new(0, -1, 0, -1)
    checkGlow.BackgroundTransparency = 1
    checkGlow.BorderSizePixel = 2
    checkGlow.BorderColor3 = Color3.fromRGB(0, 150, 255)
    checkGlow.Visible = default
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
    label.Font = Enum.Font.Gotham
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 4
    
    -- Hover effect
    checkbox.MouseEnter:Connect(function()
        if checkbox.BackgroundColor3 ~= Color3.fromRGB(0, 150, 255) then
            TweenService:Create(checkbox, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(65, 65, 75),
                Size = UDim2.new(0, 26, 0, 26)
            }):Play()
            checkbox.Position = UDim2.new(0, -1, 0.5, -13)
        end
    end)
    
    checkbox.MouseLeave:Connect(function()
        if checkbox.BackgroundColor3 ~= Color3.fromRGB(0, 150, 255) then
            TweenService:Create(checkbox, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 50),
                Size = UDim2.new(0, 24, 0, 24)
            }):Play()
            checkbox.Position = UDim2.new(0, 0, 0.5, -12)
        end
    end)
    
    return {frame = frame, checkbox = checkbox, checkMark = checkMark, checkGlow = checkGlow, value = default}
end

local enableTrigger = createCheckbox("Enable Trigger Bot", false)
local knifeCheckbox = createCheckbox("Knife Check", true)
local forceFieldCheckbox = createCheckbox("Force Field Check", false)

-- Frame para keybind
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

-- modo (Hold/Toggle)
local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0.48, 0, 0, 45)
modeBtn.Position = UDim2.new(0, 0, 0, 35)
modeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
modeBtn.Text = "HOLD"
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 16
modeBtn.Parent = keyFrame
modeBtn.ZIndex = 4

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

-- Efecto hover para modoBtn
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
keySelectBtn.Text = "CLICK DERECHO"
keySelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keySelectBtn.Font = Enum.Font.Gotham
keySelectBtn.TextSize = 14
keySelectBtn.Parent = keyFrame
keySelectBtn.ZIndex = 4

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

-- Efecto hover para keySelectBtn
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

-- Sección Configuration
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

-- Función para crear sliders con animación
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
    label.Font = Enum.Font.Gotham
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
    
    -- Efecto de brillo
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
    
    -- Puntos indicadores
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

-- Función para mostrar notificaciones mejorada
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
    notifMessage.Font = Enum.Font.Gotham
    notifMessage.TextSize = 13
    notifMessage.TextXAlignment = Enum.TextXAlignment.Left
    notifMessage.TextWrapped = true
    notifMessage.Parent = notif
    notifMessage.ZIndex = 101
    
    table.insert(currentNotifications, notif)
    
    -- Animación de entrada
    notif.Position = UDim2.new(1, 0, 0, 20 + ((#currentNotifications-1) * 80))
    notif.Rotation = -5
    TweenService:Create(notif, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -340, 0, 20 + ((#currentNotifications-1) * 80)),
        Rotation = 0
    }):Play()
    
    -- Animación de salida
    task.wait(duration)
    
    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
        Position = UDim2.new(1, 0, 0, 20 + ((#currentNotifications-1) * 80)),
        Rotation = 5
    }):Play()
    
    task.wait(0.5)
    notif:Destroy()
    
    -- Reorganizar notificaciones
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

-- Eventos de checkboxes con animación
enableTrigger.checkbox.MouseButton1Click:Connect(function()
    enabled = not enabled
    enableTrigger.value = enabled
    
    local targetColor = enabled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 50)
    TweenService:Create(enableTrigger.checkbox, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
    TweenService:Create(enableTrigger.checkGlow, TweenInfo.new(0.3), {Visible = enabled}):Play()
    enableTrigger.checkMark.Text = enabled and "✓" or ""
    
    showNotification("Trigger Bot", enabled and "✅ ACTIVADO" or "❌ DESACTIVADO", 2, enabled and "success" or "error")
end)

knifeCheckbox.checkbox.MouseButton1Click:Connect(function()
    knifeCheck = not knifeCheck
    knifeCheckbox.value = knifeCheck
    
    local targetColor = knifeCheck and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 50)
    TweenService:Create(knifeCheckbox.checkbox, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
    TweenService:Create(knifeCheckbox.checkGlow, TweenInfo.new(0.3), {Visible = knifeCheck}):Play()
    knifeCheckbox.checkMark.Text = knifeCheck and "✓" or ""
end)

forceFieldCheckbox.checkbox.MouseButton1Click:Connect(function()
    forceFieldCheck = not forceFieldCheck
    forceFieldCheckbox.value = forceFieldCheck
    
    local targetColor = forceFieldCheck and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 50)
    TweenService:Create(forceFieldCheckbox.checkbox, TweenInfo.new(0.3), {BackgroundColor3 = targetColor}):Play()
    TweenService:Create(forceFieldCheckbox.checkGlow, TweenInfo.new(0.3), {Visible = forceFieldCheck}):Play()
    forceFieldCheckbox.checkMark.Text = forceFieldCheck and "✓" or ""
end)

modeBtn.MouseButton1Click:Connect(function()
    holdMode = not holdMode
    modeBtn.Text = holdMode and "HOLD" or "TOGGLE"
    
    TweenService:Create(modeBtn, TweenInfo.new(0.3), {
        BackgroundColor3 = holdMode and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 150, 0)
    }):Play()
    
    showNotification("MODE", holdMode and "🔒 HOLD MODE" or "🔄 TOGGLE MODE", 2, "info")
end)

keySelectBtn.MouseButton1Click:Connect(function()
    isSelectingKey = true
    
    TweenService:Create(keySelectBtn, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 150, 0),
        Size = UDim2.new(0.48, 5, 0, 47)
    }):Play()
    TweenService:Create(keyGlow, TweenInfo.new(0.2), {Visible = true}):Play()
    
    keySelectBtn.Text = "🎯 PRESIONA TECLA"
    
    showNotification("KEYBIND", "Presiona cualquier tecla", 3, "info")
end)

UserInputService.InputBegan:Connect(function(input)
    if isSelectingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            holdKey = input.KeyCode
            keySelectBtn.Text = "⌨️ " .. input.KeyCode.Name
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdKey = Enum.UserInputType.MouseButton1
            keySelectBtn.Text = "🖱️ CLICK IZQUIERDO"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            holdKey = Enum.UserInputType.MouseButton2
            keySelectBtn.Text = "🖱️ CLICK DERECHO"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            holdKey = Enum.UserInputType.MouseButton3
            keySelectBtn.Text = "🖱️ CLICK MEDIO"
        end
        
        TweenService:Create(keySelectBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 50),
            Size = UDim2.new(0.48, 0, 0, 45)
        }):Play()
        TweenService:Create(keyGlow, TweenInfo.new(0.2), {Visible = false}):Play()
        
        isSelectingKey = false
        showNotification("KEYBIND", "✓ " .. keySelectBtn.Text, 2, "success")
    end
end)

-- Sliders dragging
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
            showNotification("PRECISION", precision .. "%", 1.5, "info")
        end
        if draggingDelay then
            draggingDelay = false
            showNotification("DELAY", triggerDelay .. "ms", 1.5, "info")
        end
        if draggingDistance then
            draggingDistance = false
            showNotification("RANGE", maxDistance .. " studs", 1.5, "info")
        end
    end
end)

-- Control de visibilidad de GUI con CTRL
local function isCtrlKey(input)
    return input.KeyCode == Enum.KeyCode.RightControl
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and isCtrlKey(input) and not isSelectingKey then
        guiVisible = not guiVisible
        
        if guiVisible then
            main.Visible = true
            TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 400, 0, 520),
                BackgroundTransparency = 0,
            }):Play()
            showNotification("GUI", "🟢 INTERFAZ ABIERTA", 2, "success")
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

-- Animación de entrada inicial
main.Size = UDim2.new(0, 0, 0, 0)
main.BackgroundTransparency = 1
main.Visible = true

task.wait(0.1)
TweenService:Create(main, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 400, 0, 520),
    BackgroundTransparency = 0
}):Play()

-- Función para detectar keypress
local function isKeyPressed(input)
    if typeof(holdKey) == "EnumItem" then
        return input.UserInputType == holdKey
    else
        return input.KeyCode == holdKey
    end
end

UserInputService.InputBegan:Connect(function(input)
    if isKeyPressed(input) then
        keyPressed = true
        if holdMode then
            triggerActive = true
            if enabled then
                -- Efecto visual al activar
                TweenService:Create(enableTrigger.checkbox, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(0, 200, 255)
                }):Play()

            end
        else
            triggerActive = not triggerActive
            if enabled then

            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if isKeyPressed(input) then
        keyPressed = false
        if holdMode then
            triggerActive = false
            if enabled then
                TweenService:Create(enableTrigger.checkbox, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                }):Play()

            end
        end
    end
end)

-- FUNCIÓN PARA DETECTAR CUCHILLO
local function hasKnifeEquipped()
    local character = player.Character
    if not character then return false end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        local toolName = tool.Name:lower()
        
        local knifeNames = {
            "knife", "cuchillo", "cutter", "espada", "sword", "katana", "dagger", "blade"
        }
        
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

local lastShotTime = 0

-- FUNCIÓN DE DISPARO MEJORADA - MÚLTIPLES MÉTODOS
local function shoot()
    -- Método 1: mouse1click (el más común)
    local success, error = pcall(function()
        mouse1click()
    end)
    
    -- Método 2: VirtualInputManager (más potente)
    if not success then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(
                mouse.X, 
                mouse.Y, 
                0, -- Botón izquierdo (0 = izquierdo, 1 = derecho, 2 = medio)
                true, -- Presionar
                game, -- Objeto
                0 -- ID
            )
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(
                mouse.X, 
                mouse.Y, 
                0, 
                false, -- Soltar
                game, 
                0
            )
        end)
    end
    
    -- Método 3: Simular clic mediante UserInputService
    pcall(function()
        UserInputService:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
        task.wait(0.01)
        UserInputService:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
    end)
    
    -- Efecto visual al disparar
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    flash.BackgroundTransparency = 0.7
    flash.Parent = gui
    flash.ZIndex = 1000
    
    TweenService:Create(flash, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    
    -- Efecto de brillo en el botón
    TweenService:Create(enableTrigger.checkbox, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    }):Play()
    
    task.wait(0.1)
    TweenService:Create(enableTrigger.checkbox, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    }):Play()
    
    task.wait(0.05)
    flash:Destroy()
end

RunService.Heartbeat:Connect(function()
    local shouldTrigger = enabled and triggerActive
    
    if not shouldTrigger then return end
    
    local currentTime = tick()
    if currentTime - lastShotTime < (triggerDelay / 1000) then
        return
    end
    
    local target = mouse.Target
    if not target then return end
    
    local model = target.Parent
    if not model then return end
    
    local distance = getDistanceFromTarget(target)
    if distance > maxDistance then
        return
    end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    local plr = Players:GetPlayerFromCharacter(model)
    if not plr or plr == player then return end
    
    -- KNIFE CHECK 
    if knifeCheck and hasKnifeEquipped() then
        return 
    end
    
    if math.random(1, 100) <= precision then
        shoot()
        lastShotTime = currentTime
    end
end)

-- Mensaje de bienvenida
showNotification("TRIGGER BOT", "🚀 Cargado exitosamente", 3, "success")
showNotification("CONTROLES", "CTRL para abrir/cerrar", 3, "info")
showNotification("DISPARO", "Múltiples métodos activados", 3, "info")
