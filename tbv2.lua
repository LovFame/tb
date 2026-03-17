-- TRIGGERBOT + HITBOX EXPANDER (ULTRA MODERNO) - CORREGIDO
-- by FAME - Glassmorphism + Neon

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
if not player then player = Players.PlayerAdded:Wait() end
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
local triggerDelay = 1          -- en ms
local maxDistance = 500

local holdKey = Enum.UserInputType.MouseButton2
local keyPressed = false
local triggerActive = false
local isSelectingKey = false
local guiVisible = true

local notificationDuration = 2
local currentNotifications = {}

-- ==================== VARIABLES HITBOX EXPANDER ====================
getgenv().hitboxEnabled = false
getgenv().hitboxTeamcheck = false
getgenv().hitboxSizeX = 4
getgenv().hitboxSizeY = 4
getgenv().hitboxSizeZ = 4
getgenv().hitboxTransparency = 0.9
getgenv().hitboxRefreshEnabled = false
getgenv().hitboxRefreshInterval = 5

-- Guardado de tamaños originales
local originalSizes = {}

-- ==================== FUNCIONES HITBOX EXPANDER ====================
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

-- ==================== INTERFAZ ULTRA MODERNA ====================
local gui = Instance.new("ScreenGui")
gui.Name = "FameCheats"
gui.Parent = game:FindFirstChild("CoreGui") or player.PlayerGui
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Variables de estado
local guiVisible = true
local minimized = false
local activeTab = "trigger"

-- ==================== NOTIFICACIONES GLASS (AHORA SÍ FUNCIONAN) ====================
local function showNotification(title, message, duration, nType)
    duration = duration or notificationDuration

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 340, 0, 80)
    notif.Position = UDim2.new(1, -360, 0, 20 + (#currentNotifications * 90))
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    notif.BackgroundTransparency = 0.2
    notif.BorderSizePixel = 0
    notif.Parent = gui   -- Ahora gui ya existe
    notif.ZIndex = 100
    notif.ClipsDescendants = true

    -- Efecto glass
    local blur = Instance.new("ImageLabel")
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundTransparency = 1
    blur.Image = "rbxassetid://3570695787"
    blur.ImageColor3 = Color3.fromRGB(255, 255, 255)
    blur.ImageTransparency = 0.95
    blur.ScaleType = Enum.ScaleType.Slice
    blur.Parent = notif

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 16)
    notifCorner.Parent = notif

    local notifBorder = Instance.new("Frame")
    notifBorder.Size = UDim2.new(1, 0, 1, 0)
    notifBorder.BackgroundTransparency = 1
    notifBorder.BorderSizePixel = 2
    notifBorder.BorderColor3 = nType == "success" and Color3.fromRGB(0, 255, 0) or
                               nType == "error" and Color3.fromRGB(255, 0, 0) or
                               Color3.fromRGB(0, 180, 255)
    notifBorder.Parent = notif
    notifBorder.ZIndex = 101

    local notifBorderCorner = Instance.new("UICorner")
    notifBorderCorner.CornerRadius = UDim.new(0, 16)
    notifBorderCorner.Parent = notifBorder

    local notifIcon = Instance.new("TextLabel")
    notifIcon.Size = UDim2.new(0, 40, 1, 0)
    notifIcon.Position = UDim2.new(0, 10, 0, 0)
    notifIcon.BackgroundTransparency = 1
    notifIcon.Text = nType == "success" and "✅" or nType == "error" and "❌" or "⚡"
    notifIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifIcon.Font = Enum.Font.GothamBold
    notifIcon.TextSize = 28
    notifIcon.Parent = notif
    notifIcon.ZIndex = 102

    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -60, 0, 30)
    notifTitle.Position = UDim2.new(0, 55, 0, 10)
    notifTitle.BackgroundTransparency = 1
    notifTitle.Text = title
    notifTitle.TextColor3 = nType == "success" and Color3.fromRGB(0, 255, 0) or
                            nType == "error" and Color3.fromRGB(255, 0, 0) or
                            Color3.fromRGB(0, 180, 255)
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextSize = 18
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    notifTitle.Parent = notif
    notifTitle.ZIndex = 102

    local notifMessage = Instance.new("TextLabel")
    notifMessage.Size = UDim2.new(1, -60, 0, 30)
    notifMessage.Position = UDim2.new(0, 55, 0, 35)
    notifMessage.BackgroundTransparency = 1
    notifMessage.Text = message
    notifMessage.TextColor3 = Color3.fromRGB(220, 220, 240)
    notifMessage.Font = Enum.Font.GothamBlack
    notifMessage.TextSize = 14
    notifMessage.TextXAlignment = Enum.TextXAlignment.Left
    notifMessage.TextWrapped = true
    notifMessage.Parent = notif
    notifMessage.ZIndex = 102

    table.insert(currentNotifications, notif)

    notif.Position = UDim2.new(1, 0, 0, 20 + ((#currentNotifications-1) * 90))
    notif.Rotation = -3
    TweenService:Create(notif, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -360, 0, 20 + ((#currentNotifications-1) * 90)),
        Rotation = 0
    }):Play()

    task.wait(duration)

    TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
        Position = UDim2.new(1, 0, 0, 20 + ((#currentNotifications-1) * 90)),
        Rotation = 3
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
            Position = UDim2.new(1, -360, 0, 20 + ((i-1) * 90))
        }):Play()
    end
end

-- ==================== VENTANA PRINCIPAL (GLASS) ====================
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 500, 0, 640)
main.Position = UDim2.new(0.5, -250, 0.5, -320)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
main.ClipsDescendants = true
main.ZIndex = 2
main.Visible = true

-- Sombra exterior
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 40, 1, 40)
shadow.Position = UDim2.new(0, -20, 0, -20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.7
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(10, 10, 118, 118)
shadow.Parent = main
shadow.ZIndex = 1

-- Esquinas redondeadas
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 24)
mainCorner.Parent = main

-- Efecto glass (blur)
local glassEffect = Instance.new("ImageLabel")
glassEffect.Size = UDim2.new(1, 0, 1, 0)
glassEffect.BackgroundTransparency = 1
glassEffect.Image = "rbxassetid://3570695787"
glassEffect.ImageColor3 = Color3.fromRGB(255, 255, 255)
glassEffect.ImageTransparency = 0.92
glassEffect.ScaleType = Enum.ScaleType.Slice
glassEffect.Parent = main

-- ==================== BARRA SUPERIOR ====================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
titleBar.BackgroundTransparency = 0.95
titleBar.BorderSizePixel = 0
titleBar.Parent = main
titleBar.ZIndex = 4

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 24)
titleCorner.Parent = titleBar

-- Título con gradiente
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FAME CHEATS"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar
title.ZIndex = 5

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 180, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 80, 200))
})
titleGradient.Rotation = 45
titleGradient.Parent = title

-- Botones de ventana
local function createWindowButton(text, posX, color, hoverColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 36, 0, 36)
    btn.Position = UDim2.new(1, posX, 0.5, -18)
    btn.BackgroundColor3 = color
    btn.BackgroundTransparency = 0.3
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.Parent = titleBar
    btn.ZIndex = 5

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor, BackgroundTransparency = 0.1}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color, BackgroundTransparency = 0.3}):Play()
    end)

    return btn
end

local closeBtn = createWindowButton("✕", -50, Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 100, 100))
local minimizeBtn = createWindowButton("−", -90, Color3.fromRGB(100, 100, 120), Color3.fromRGB(130, 130, 150))

-- ==================== SIDEBAR CON GRADIENTE ====================
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 90, 1, -60)
sidebar.Position = UDim2.new(0, 0, 0, 60)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
sidebar.BackgroundTransparency = 0.2
sidebar.BorderSizePixel = 0
sidebar.Parent = main
sidebar.ZIndex = 4

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 20)
sidebarCorner.Parent = sidebar

local sidebarGradient = Instance.new("UIGradient")
sidebarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
})
sidebarGradient.Rotation = 90
sidebarGradient.Parent = sidebar

-- Botones del sidebar con iconos y texto
local function createSidebarButton(icon, text, posY, activeColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = UDim2.new(0.5, -35, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    btn.BackgroundTransparency = 0.5
    btn.Text = ""
    btn.Parent = sidebar
    btn.ZIndex = 5

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 16)
    btnCorner.Parent = btn

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 0, 40)
    iconLabel.Position = UDim2.new(0, 0, 0, 5)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 28
    iconLabel.Parent = btn
    iconLabel.ZIndex = 6

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 0, 20)
    textLabel.Position = UDim2.new(0, 0, 0, 45)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.Font = Enum.Font.GothamBlack
    textLabel.TextSize = 12
    textLabel.Parent = btn
    textLabel.ZIndex = 6

    return btn, iconLabel, textLabel
end

local triggerBtn, triggerIcon, triggerText = createSidebarButton("🛠", "TRIGGER", 20, Color3.fromRGB(0, 180, 255))
local hitboxBtn, hitboxIcon, hitboxText = createSidebarButton("⚙", "HITBOX", 110, Color3.fromRGB(255, 80, 200))

-- Indicador de pestaña activa (barra luminosa)
local activeIndicator = Instance.new("Frame")
activeIndicator.Size = UDim2.new(0, 4, 0, 50)
activeIndicator.Position = UDim2.new(0, 0, 0, 30)
activeIndicator.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
activeIndicator.Parent = sidebar
activeIndicator.ZIndex = 7

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(0, 4)
indicatorCorner.Parent = activeIndicator

-- Efecto de brillo para el indicador
local indicatorGlow = Instance.new("ImageLabel")
indicatorGlow.Size = UDim2.new(1, 10, 1, 10)
indicatorGlow.Position = UDim2.new(0, -5, 0, -5)
indicatorGlow.BackgroundTransparency = 1
indicatorGlow.Image = "rbxassetid://3570695787"
indicatorGlow.ImageColor3 = Color3.fromRGB(0, 180, 255)
indicatorGlow.ImageTransparency = 0.5
indicatorGlow.Parent = activeIndicator
indicatorGlow.ZIndex = 6

-- ==================== CONTENEDOR PRINCIPAL ====================
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -90, 1, -60)
contentContainer.Position = UDim2.new(0, 90, 0, 60)
contentContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
contentContainer.BackgroundTransparency = 0.2
contentContainer.BorderSizePixel = 0
contentContainer.Parent = main
contentContainer.ZIndex = 4
contentContainer.ClipsDescendants = true

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 20)
contentCorner.Parent = contentContainer

local contentScroller = Instance.new("ScrollingFrame")
contentScroller.Size = UDim2.new(1, 0, 1, 0)
contentScroller.BackgroundTransparency = 1
contentScroller.BorderSizePixel = 0
contentScroller.ScrollBarThickness = 6
contentScroller.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
contentScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroller.Parent = contentContainer
contentScroller.ZIndex = 5
contentScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentScroller.ElasticBehavior = Enum.ElasticBehavior.Always
contentScroller.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

-- Padding elegante
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 20)
padding.PaddingRight = UDim.new(0, 20)
padding.PaddingTop = UDim.new(0, 20)
padding.PaddingBottom = UDim.new(0, 20)
padding.Parent = contentScroller

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 15)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = contentScroller
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentScroller.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 40)
end)

-- ==================== COMPONENTES UI MEJORADOS ====================

-- Toggle neon
local function createToggle(text, default, color, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = contentScroller
    frame.ZIndex = 5

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 6

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 56, 0, 28)
    toggleBg.Position = UDim2.new(1, -66, 0.5, -14)
    toggleBg.BackgroundColor3 = default and color or Color3.fromRGB(50, 50, 55)
    toggleBg.Parent = frame
    toggleBg.ZIndex = 6

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 24, 0, 24)
    toggleCircle.Position = default and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.Parent = toggleBg
    toggleCircle.ZIndex = 7

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle

    -- Efecto glow
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 12, 1, 12)
    glow.Position = UDim2.new(0, -6, 0, -6)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://3570695787"
    glow.ImageColor3 = color
    glow.ImageTransparency = default and 0.4 or 1
    glow.Parent = toggleBg
    glow.ZIndex = 5

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = frame
    button.ZIndex = 8

    local state = default

    local function setState(newState)
        state = newState
        TweenService:Create(toggleBg, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
            BackgroundColor3 = state and color or Color3.fromRGB(50, 50, 55)
        }):Play()
        TweenService:Create(toggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
            Position = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
        }):Play()
        TweenService:Create(glow, TweenInfo.new(0.3), {ImageTransparency = state and 0.4 or 1}):Play()
        if onChange then onChange(state) end
    end

    button.MouseButton1Click:Connect(function() setState(not state) end)

    return {frame = frame, setState = setState}
end

-- Slider con diseño premium
local function createSlider(text, value, min, max, suffix, color, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundTransparency = 1
    frame.Parent = contentScroller
    frame.ZIndex = 5

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 6

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 70, 0, 25)
    valueLabel.Position = UDim2.new(1, -70, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = value .. (suffix or "")
    valueLabel.TextColor3 = color
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 16
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    valueLabel.ZIndex = 6

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 40)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderBg.Parent = frame
    sliderBg.ZIndex = 6

    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg

    local percent = (value - min) / (max - min)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderFill.BackgroundColor3 = color
    sliderFill.Parent = sliderBg
    sliderFill.ZIndex = 7

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    -- Gradiente
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, color:Lerp(Color3.fromRGB(255, 255, 255), 0.4))
    })
    fillGradient.Rotation = 45
    fillGradient.Parent = sliderFill

    -- Thumb (punto del slider)
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(percent, -8, 0.5, -8)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.Parent = sliderBg
    thumb.ZIndex = 8

    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    local thumbGlow = Instance.new("ImageLabel")
    thumbGlow.Size = UDim2.new(1, 8, 1, 8)
    thumbGlow.Position = UDim2.new(0, -4, 0, -4)
    thumbGlow.BackgroundTransparency = 1
    thumbGlow.Image = "rbxassetid://3570695787"
    thumbGlow.ImageColor3 = color
    thumbGlow.ImageTransparency = 0.3
    thumbGlow.Parent = thumb
    thumbGlow.ZIndex = 7

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = sliderBg
    button.ZIndex = 9

    local currentVal = value
    local dragging = false

    local function updateFromMouse(mouseX)
        local absX = sliderBg.AbsolutePosition.X
        local width = sliderBg.AbsoluteSize.X
        local newPercent = (mouseX - absX) / width
        newPercent = math.clamp(newPercent, 0, 1)
        sliderFill.Size = UDim2.new(newPercent, 0, 1, 0)
        thumb.Position = UDim2.new(newPercent, -8, 0.5, -8)
        currentVal = min + (max - min) * newPercent
        valueLabel.Text = math.floor(currentVal * 100) / 100 .. (suffix or "")
        if onChange then onChange(currentVal) end
    end

    button.MouseButton1Down:Connect(function(input)
        dragging = true
        updateFromMouse(input.Position.X)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromMouse(UserInputService:GetMouseLocation().X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return {frame = frame, setValue = function(val)
        currentVal = val
        local newPercent = (val - min) / (max - min)
        sliderFill.Size = UDim2.new(newPercent, 0, 1, 0)
        thumb.Position = UDim2.new(newPercent, -8, 0.5, -8)
        valueLabel.Text = math.floor(val * 100) / 100 .. (suffix or "")
    end}
end

-- Selector de tecla con diseño de chip
local function createKeybindButton(text, defaultKeyText, defaultKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = contentScroller
    frame.ZIndex = 5

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -150, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 6

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 140, 0, 38)
    button.Position = UDim2.new(1, -140, 0.5, -19)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    button.BackgroundTransparency = 0.3
    button.Text = defaultKeyText
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBlack
    button.TextSize = 14
    button.Parent = frame
    button.ZIndex = 6

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = button

    -- Sombra del botón
    local btnShadow = Instance.new("ImageLabel")
    btnShadow.Size = UDim2.new(1, 10, 1, 10)
    btnShadow.Position = UDim2.new(0, -5, 0, -5)
    btnShadow.BackgroundTransparency = 1
    btnShadow.Image = "rbxassetid://1316045217"
    btnShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    btnShadow.ImageTransparency = 0.7
    btnShadow.ScaleType = Enum.ScaleType.Slice
    btnShadow.SliceCenter = Rect.new(10, 10, 118, 118)
    btnShadow.Parent = button
    btnShadow.ZIndex = 5

    return {frame = frame, button = button}
end

-- Selector de modo (Hold/Toggle) con diseño de píldoras
local function createModeSelector()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = contentScroller
    frame.ZIndex = 5

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -150, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Mode"
    label.TextColor3 = Color3.fromRGB(240, 240, 255)
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 6

    local holdBtn = Instance.new("TextButton")
    holdBtn.Size = UDim2.new(0, 70, 0, 38)
    holdBtn.Position = UDim2.new(1, -140, 0.5, -19)
    holdBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    holdBtn.BackgroundTransparency = 0.2
    holdBtn.Text = "HOLD"
    holdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    holdBtn.Font = Enum.Font.GothamBold
    holdBtn.TextSize = 14
    holdBtn.Parent = frame
    holdBtn.ZIndex = 6

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 70, 0, 38)
    toggleBtn.Position = UDim2.new(1, -70, 0.5, -19)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    toggleBtn.BackgroundTransparency = 0.3
    toggleBtn.Text = "TOGGLE"
    toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleBtn.Font = Enum.Font.GothamBlack
    toggleBtn.TextSize = 14
    toggleBtn.Parent = frame
    toggleBtn.ZIndex = 6

    for _, btn in ipairs({holdBtn, toggleBtn}) do
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 12)
        btnCorner.Parent = btn
    end

    return {frame = frame, holdBtn = holdBtn, toggleBtn = toggleBtn}
end

-- ==================== CONTENIDO TRIGGER ====================
local triggerContent = Instance.new("Frame")
triggerContent.Size = UDim2.new(1, 0, 1, 0)
triggerContent.BackgroundTransparency = 1
triggerContent.Parent = contentScroller
triggerContent.Visible = true
triggerContent.ZIndex = 5

local triggerLayout = Instance.new("UIListLayout")
triggerLayout.Padding = UDim.new(0, 15)
triggerLayout.SortOrder = Enum.SortOrder.LayoutOrder
triggerLayout.Parent = triggerContent

-- Elementos
local enableToggle = createToggle("Enable Trigger Bot", false, Color3.fromRGB(0, 180, 255), function(new)
    enabled = new
    showNotification("Trigger Bot", new and "Enable" or "Disable", 2, new and "success" or "error")
end)
enableToggle.frame.Parent = triggerContent

local keybindBtn = createKeybindButton("Keybind", "Right Click", Enum.UserInputType.MouseButton2)
keybindBtn.frame.Parent = triggerContent

local modeSelector = createModeSelector()
modeSelector.frame.Parent = triggerContent

local knifeToggle = createToggle("Ignore knife", true, Color3.fromRGB(0, 180, 255), function(new) knifeCheck = new end)
knifeToggle.frame.Parent = triggerContent

local forceFieldToggle = createToggle("Ignore ForceField", false, Color3.fromRGB(0, 180, 255), function(new) forceFieldCheck = new end)
forceFieldToggle.frame.Parent = triggerContent

local precisionSlider = createSlider("Precision", 50, 0, 100, "%", Color3.fromRGB(0, 200, 100), function(new) precision = new end)
precisionSlider.frame.Parent = triggerContent

local delaySlider = createSlider("Delay", 1, 0, 100, "ms", Color3.fromRGB(255, 150, 0), function(new) triggerDelay = new end)
delaySlider.frame.Parent = triggerContent

local distanceSlider = createSlider("Max range", 500, 0, 5000, "", Color3.fromRGB(200, 100, 255), function(new) maxDistance = new end)
distanceSlider.frame.Parent = triggerContent

-- ==================== CONTENIDO HITBOX ====================
local hitboxContent = Instance.new("Frame")
hitboxContent.Size = UDim2.new(1, 0, 1, 0)
hitboxContent.BackgroundTransparency = 1
hitboxContent.Parent = contentScroller
hitboxContent.Visible = false
hitboxContent.ZIndex = 5

local hitboxLayout = Instance.new("UIListLayout")
hitboxLayout.Padding = UDim.new(0, 15)
hitboxLayout.SortOrder = Enum.SortOrder.LayoutOrder
hitboxLayout.Parent = hitboxContent

local enableHitboxToggle = createToggle("Enable Hitbox Expander", false, Color3.fromRGB(255, 80, 200), function(new)
    getgenv().hitboxEnabled = new
    if new then applyHitboxToAll(); showNotification("Hitbox", "Enabled", 2, "success")
    else restoreAllOriginal(); showNotification("Hitbox", "Disabled", 2, "error") end
end)
enableHitboxToggle.frame.Parent = hitboxContent

local teamcheckToggle = createToggle("Team Check (only enemies)", false, Color3.fromRGB(255, 80, 200), function(new)
    getgenv().hitboxTeamcheck = new
    if getgenv().hitboxEnabled then restoreAllOriginal(); applyHitboxToAll() end
end)
teamcheckToggle.frame.Parent = hitboxContent

local sizeXSlider = createSlider("Size X", 4, 1, 20, "", Color3.fromRGB(255, 80, 200), function(new)
    getgenv().hitboxSizeX = new; if getgenv().hitboxEnabled then applyHitboxToAll() end
end)
sizeXSlider.frame.Parent = hitboxContent

local sizeYSlider = createSlider("Size Y", 4, 1, 20, "", Color3.fromRGB(255, 80, 200), function(new)
    getgenv().hitboxSizeY = new; if getgenv().hitboxEnabled then applyHitboxToAll() end
end)
sizeYSlider.frame.Parent = hitboxContent

local sizeZSlider = createSlider("Size Z", 4, 1, 20, "", Color3.fromRGB(255, 80, 200), function(new)
    getgenv().hitboxSizeZ = new; if getgenv().hitboxEnabled then applyHitboxToAll() end
end)
sizeZSlider.frame.Parent = hitboxContent

local opacitySlider = createSlider("Opacity", 0.9, 0, 1, "", Color3.fromRGB(255, 80, 200), function(new)
    getgenv().hitboxTransparency = new; if getgenv().hitboxEnabled then applyHitboxToAll() end
end)
opacitySlider.frame.Parent = hitboxContent

local autoRefreshToggle = createToggle("Auto Refresh", false, Color3.fromRGB(255, 80, 200), function(new)
    getgenv().hitboxRefreshEnabled = new
end)
autoRefreshToggle.frame.Parent = hitboxContent

local intervalSlider = createSlider("Intervalo (s)", 5, 0.1, 15, "s", Color3.fromRGB(255, 80, 200), function(new)
    getgenv().hitboxRefreshInterval = new
end)
intervalSlider.frame.Parent = hitboxContent

-- ==================== FUNCIONALIDAD DE PESTAÑAS ====================
local function setActiveTab(tab)
    activeTab = tab
    if tab == "trigger" then
        TweenService:Create(activeIndicator, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(0, 180, 255)}):Play()
        TweenService:Create(indicatorGlow, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(0, 180, 255)}):Play()
        TweenService:Create(triggerIcon, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(triggerText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(hitboxIcon, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        TweenService:Create(hitboxText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        triggerContent.Visible = true
        hitboxContent.Visible = false
    else
        TweenService:Create(activeIndicator, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 120), BackgroundColor3 = Color3.fromRGB(255, 80, 200)}):Play()
        TweenService:Create(indicatorGlow, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(255, 80, 200)}):Play()
        TweenService:Create(hitboxIcon, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(hitboxText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(triggerIcon, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        TweenService:Create(triggerText, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
        triggerContent.Visible = false
        hitboxContent.Visible = true
    end
end

triggerBtn.MouseButton1Click:Connect(function() setActiveTab("trigger") end)
hitboxBtn.MouseButton1Click:Connect(function() setActiveTab("hitbox") end)

-- ==================== MODO SELECTOR ====================
modeSelector.holdBtn.MouseButton1Click:Connect(function()
    holdMode = true
    TweenService:Create(modeSelector.holdBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 180, 255), BackgroundTransparency = 0.2}):Play()
    TweenService:Create(modeSelector.toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 50), BackgroundTransparency = 0.3}):Play()
    modeSelector.holdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeSelector.toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

modeSelector.toggleBtn.MouseButton1Click:Connect(function()
    holdMode = false
    TweenService:Create(modeSelector.toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 150, 0), BackgroundTransparency = 0.2}):Play()
    TweenService:Create(modeSelector.holdBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 50), BackgroundTransparency = 0.3}):Play()
    modeSelector.toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeSelector.holdBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

-- ==================== SELECCIÓN DE TECLA ====================
keybindBtn.button.MouseButton1Click:Connect(function()
    isSelectingKey = true
    keybindBtn.button.Text = "Press a key..."
    TweenService:Create(keybindBtn.button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 150, 0), BackgroundTransparency = 0.1}):Play()
end)

UserInputService.InputBegan:Connect(function(input)
    if isSelectingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            holdKey = input.KeyCode
            keybindBtn.button.Text = input.KeyCode.Name
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdKey = Enum.UserInputType.MouseButton1
            keybindBtn.button.Text = "Left Click"
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            holdKey = Enum.UserInputType.MouseButton2
            keybindBtn.button.Text = "Right Click"
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            holdKey = Enum.UserInputType.MouseButton3
            keybindBtn.button.Text = "Middle Click"
        end
        TweenService:Create(keybindBtn.button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50), BackgroundTransparency = 0.3}):Play()
        isSelectingKey = false
    end
end)

-- ==================== CONTROLES DE VENTANA ====================
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
            Size = UDim2.new(0, 500, 0, 60),
            Position = UDim2.new(0.5, -250, 1, -80)
        }):Play()
        contentContainer.Visible = false
        sidebar.Visible = false
        minimizeBtn.Text = "□"
    else
        TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
            Size = UDim2.new(0, 500, 0, 640),
            Position = UDim2.new(0.5, -250, 0.5, -320)
        }):Play()
        contentContainer.Visible = true
        sidebar.Visible = true
        minimizeBtn.Text = "−"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.4)
    gui:Destroy()
    enabled = false
end)

-- Atajos: CTRL DERECHO o F6
UserInputService.InputBegan:Connect(function(input)
    if (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.F6) and not isSelectingKey then
        guiVisible = not guiVisible
        if guiVisible then
            main.Visible = true
            TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 500, 0, minimized and 60 or 640),
                BackgroundTransparency = 0.15
            }):Play()
        else
            TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.3)
            main.Visible = false
        end
    end
end)

-- Animación de entrada épica
main.Size = UDim2.new(0, 0, 0, 0)
main.BackgroundTransparency = 1
main.Visible = true
task.wait(0.1)
TweenService:Create(main, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 500, 0, 640),
    BackgroundTransparency = 0.15
}):Play()

showNotification("FAME CHEATS", "Edición Ultra Moderna", 3, "info")
showNotification("CONTROLES", "CTRL DERECHO / F6", 3, "info")

-- ==================== LÓGICA DEL TRIGGERBOT (sin cambios) ====================
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
            else
                triggerActive = not triggerActive
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if isKeyPressed(input) then
        keyPressed = false
        if enabled and holdMode then
            triggerActive = false
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

local lastShotTime = 0
local mousePressed = false

RunService.Heartbeat:Connect(function()
    local shouldTrigger = enabled and triggerActive
    if not shouldTrigger then
        if mousePressed then mouse1release(); mousePressed = false end
        return
    end
    local currentTime = tick()
    if currentTime - lastShotTime < (triggerDelay / 1000) then return end
    local target = getTarget()
    if target then
        if knifeCheck and hasKnifeEquipped() then
            if mousePressed then mouse1release(); mousePressed = false end
            return
        end
        if math.random(1, 100) <= precision then
            shoot()
            lastShotTime = currentTime
            mousePressed = true
        end
    else
        if mousePressed then mouse1release(); mousePressed = false end
    end
end)
