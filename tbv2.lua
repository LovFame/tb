-- TRIGGERBOT + HITBOX EXPANDER (CORREGIDO) -- by FAME
-- INTERFAZ MODERNA Y PROFESIONAL

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

-- ==================== NOTIFICACIONES ====================
local function showNotification(title, message, duration, nType)
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
    notifBorder.BorderColor3 = nType == "success" and Color3.fromRGB(0, 255, 0) or
                               nType == "error" and Color3.fromRGB(255, 0, 0) or
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
    notifIcon.Text = nType == "success" and "✅" or nType == "error" and "❌" or "ℹ️"
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
    notifTitle.TextColor3 = nType == "success" and Color3.fromRGB(0, 255, 0) or
                            nType == "error" and Color3.fromRGB(255, 0, 0) or
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

-- ==================== GUI MODERNA Y PROFESIONAL ====================
local gui = Instance.new("ScreenGui")
gui.Name = "FameCheats"
gui.Parent = game:FindFirstChild("CoreGui") or game.Players.LocalPlayer.PlayerGui
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Variables de estado de la GUI
local guiVisible = true
local minimized = false

-- ==================== FUNCIÓN PARA CREAR SOMBRA ====================
local function createShadow(parent, size, transparency)
    local shadow = Instance.new("ImageLabel")
    shadow.Size = size or UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency or 0.4
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = parent
    shadow.ZIndex = parent.ZIndex - 1
    return shadow
end

-- ==================== VENTANA PRINCIPAL ====================
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 620)
main.Position = UDim2.new(0.5, -260, 0.5, -310)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BackgroundTransparency = 0.1  -- Efecto glass
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
main.ClipsDescendants = true
main.ZIndex = 2
main.Visible = true

-- Sombra exterior
createShadow(main, UDim2.new(1, 30, 1, 30), 0.5)

-- Esquinas redondeadas
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = main

-- Gradiente de fondo sutil
local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
})
bgGradient.Rotation = 45
bgGradient.Parent = main

-- ==================== BARRA DE TÍTULO ====================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
titleBar.BackgroundTransparency = 0.2
titleBar.BorderSizePixel = 0
titleBar.Parent = main
titleBar.ZIndex = 3

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 20)
titleCorner.Parent = titleBar

-- Solo redondear esquinas superiores (para que no se vea doble borde)
local titleBarMask = Instance.new("UICorner")
titleBarMask.CornerRadius = UDim.new(0, 20)
titleBarMask.Parent = main

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "FAME CHEATS  •  V2"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar
title.ZIndex = 4

-- Botones de ventana
local function createWindowButton(parent, text, color, hoverColor, posX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = UDim2.new(1, posX, 0.5, -20)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 22
    btn.Parent = parent
    btn.ZIndex = 5

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
    end)

    return btn
end

local closeBtn = createWindowButton(titleBar, "✕", Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 100, 100), -50)
local minimizeBtn = createWindowButton(titleBar, "−", Color3.fromRGB(60, 60, 70), Color3.fromRGB(80, 80, 90), -100)

-- ==================== PESTAÑAS CON ICONOS ====================
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -40, 0, 50)
tabContainer.Position = UDim2.new(0, 20, 0, 75)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = main
tabContainer.ZIndex = 4

local function createTab(name, icon, color, posX)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -10, 1, 0)
    btn.Position = UDim2.new(posX, 0, 0, 0)
    btn.BackgroundColor3 = color
    btn.Text = icon .. "   " .. name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Parent = tabContainer
    btn.ZIndex = 5

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 15)
    btnCorner.Parent = btn

    return btn
end

local triggerTab = createTab("TRIGGER BOT", "⚡", Color3.fromRGB(0, 150, 255), 0)
local hitboxTab = createTab("HITBOX EXPANDER", "📦", Color3.fromRGB(45, 45, 50), 0.5)

-- ==================== CONTENEDOR DE CONTENIDO ====================
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -40, 1, -150)
contentContainer.Position = UDim2.new(0, 20, 0, 135)
contentContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
contentContainer.BackgroundTransparency = 0.2
contentContainer.BorderSizePixel = 0
contentContainer.Parent = main
contentContainer.ZIndex = 4
contentContainer.ClipsDescendants = true

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 15)
contentCorner.Parent = contentContainer

-- Sombra interior (para dar profundidad)
local innerShadow = Instance.new("Frame")
innerShadow.Size = UDim2.new(1, 0, 0, 5)
innerShadow.Position = UDim2.new(0, 0, 0, 0)
innerShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
innerShadow.BackgroundTransparency = 0.8
innerShadow.BorderSizePixel = 0
innerShadow.Parent = contentContainer
innerShadow.ZIndex = 5

local contentScroller = Instance.new("ScrollingFrame")
contentScroller.Size = UDim2.new(1, 0, 1, 0)
contentScroller.BackgroundTransparency = 1
contentScroller.BorderSizePixel = 0
contentScroller.ScrollBarThickness = 6
contentScroller.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
contentScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroller.Parent = contentContainer
contentScroller.ZIndex = 6
contentScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
contentScroller.ElasticBehavior = Enum.ElasticBehavior.Always
contentScroller.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

-- Padding para que el contenido no toque los bordes
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 15)
padding.PaddingRight = UDim.new(0, 15)
padding.PaddingTop = UDim.new(0, 15)
padding.PaddingBottom = UDim.new(0, 15)
padding.Parent = contentScroller

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 15)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = contentScroller
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    contentScroller.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
end)

-- ==================== FUNCIONES DE UI MEJORADAS ====================

-- Toggle moderno con animación y sombra
local function createToggle(text, default, color, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.Parent = contentScroller
    frame.ZIndex = 6

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 250)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 7

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 54, 0, 28)
    toggleBg.Position = UDim2.new(1, -64, 0.5, -14)
    toggleBg.BackgroundColor3 = default and color or Color3.fromRGB(60, 60, 70)
    toggleBg.Parent = frame
    toggleBg.ZIndex = 7

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 24, 0, 24)
    toggleCircle.Position = default and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.Parent = toggleBg
    toggleCircle.ZIndex = 8

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle

    -- Sombra del círculo
    local circleShadow = createShadow(toggleCircle, UDim2.new(1, 4, 1, 4), 0.3)

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
            BackgroundColor3 = state and color or Color3.fromRGB(60, 60, 70)
        }):Play()
        TweenService:Create(toggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
            Position = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
        }):Play()
        if onChange then
            onChange(state)
        end
    end

    button.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return {frame = frame, setState = setState, getState = function() return state end}
end

-- Slider con gradiente y display de valor
local function createSlider(text, value, min, max, suffix, color, onChange)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 65)
    frame.BackgroundTransparency = 1
    frame.Parent = contentScroller
    frame.ZIndex = 6

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 250)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 7

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 70, 0, 25)
    valueLabel.Position = UDim2.new(1, -70, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = value .. (suffix or "")
    valueLabel.TextColor3 = color
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 15
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    valueLabel.ZIndex = 7

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 10)
    sliderBg.Position = UDim2.new(0, 0, 0, 35)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    sliderBg.Parent = frame
    sliderBg.ZIndex = 7

    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg

    local percent = (value - min) / (max - min)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderFill.BackgroundColor3 = color
    sliderFill.Parent = sliderBg
    sliderFill.ZIndex = 8

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    -- Gradiente para el fill
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color),
        ColorSequenceKeypoint.new(1, color:Lerp(Color3.fromRGB(255, 255, 255), 0.3))
    })
    fillGradient.Rotation = 45
    fillGradient.Parent = sliderFill

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
        currentVal = min + (max - min) * newPercent
        valueLabel.Text = math.floor(currentVal * 100) / 100 .. (suffix or "")
        if onChange then
            onChange(currentVal)
        end
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
        valueLabel.Text = math.floor(val * 100) / 100 .. (suffix or "")
    end}
end

-- Botón de selección de tecla con diseño mejorado
local function createKeybindButton(text, defaultKeyText, defaultKey)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.Parent = contentScroller
    frame.ZIndex = 6

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -150, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 250)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 7

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 140, 0, 38)
    button.Position = UDim2.new(1, -140, 0.5, -19)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    button.Text = defaultKeyText
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = frame
    button.ZIndex = 7

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = button

    -- Sombra del botón
    local btnShadow = createShadow(button, UDim2.new(1, 6, 1, 6), 0.3)

    return {frame = frame, button = button}
end

-- Selector de modo (Hold/Toggle) con diseño moderno
local function createModeSelector()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 45)
    frame.BackgroundTransparency = 1
    frame.Parent = contentScroller
    frame.ZIndex = 6

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -150, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "Modo de activación"
    label.TextColor3 = Color3.fromRGB(230, 230, 250)
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    label.ZIndex = 7

    local holdBtn = Instance.new("TextButton")
    holdBtn.Size = UDim2.new(0, 70, 0, 38)
    holdBtn.Position = UDim2.new(1, -140, 0.5, -19)
    holdBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    holdBtn.Text = "HOLD"
    holdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    holdBtn.Font = Enum.Font.GothamBold
    holdBtn.TextSize = 14
    holdBtn.Parent = frame
    holdBtn.ZIndex = 7

    local holdCorner = Instance.new("UICorner")
    holdCorner.CornerRadius = UDim.new(0, 12)
    holdCorner.Parent = holdBtn

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 70, 0, 38)
    toggleBtn.Position = UDim2.new(1, -70, 0.5, -19)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    toggleBtn.Text = "TOGGLE"
    toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.TextSize = 14
    toggleBtn.Parent = frame
    toggleBtn.ZIndex = 7

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggleBtn

    return {frame = frame, holdBtn = holdBtn, toggleBtn = toggleBtn}
end

-- ==================== CONSTRUCCIÓN DE PESTAÑAS ====================
-- Contenido de Trigger Bot
local triggerContent = Instance.new("Frame")
triggerContent.Size = UDim2.new(1, 0, 1, 0)
triggerContent.BackgroundTransparency = 1
triggerContent.Parent = contentScroller
triggerContent.Visible = true
triggerContent.ZIndex = 6

local triggerLayout = Instance.new("UIListLayout")
triggerLayout.Padding = UDim.new(0, 15)
triggerLayout.SortOrder = Enum.SortOrder.LayoutOrder
triggerLayout.Parent = triggerContent

-- Toggle principal
local enableToggle = createToggle("Activar Trigger Bot", false, Color3.fromRGB(0, 150, 255), function(new)
    enabled = new
    showNotification("Trigger Bot", new and "Activado" or "Desactivado", 2, new and "success" or "error")
end)
enableToggle.frame.Parent = triggerContent

-- Keybind y modo
local keybindBtn = createKeybindButton("Tecla de activación", "Right Click", Enum.UserInputType.MouseButton2)
keybindBtn.frame.Parent = triggerContent

local modeSelector = createModeSelector()
modeSelector.frame.Parent = triggerContent

-- Otros toggles
local knifeToggle = createToggle("Ignorar cuchillo", true, Color3.fromRGB(0, 150, 255), function(new)
    knifeCheck = new
end)
knifeToggle.frame.Parent = triggerContent

local forceFieldToggle = createToggle("Ignorar ForceField", false, Color3.fromRGB(0, 150, 255), function(new)
    forceFieldCheck = new
end)
forceFieldToggle.frame.Parent = triggerContent

-- Sliders
local precisionSlider = createSlider("Precisión", 50, 0, 100, "%", Color3.fromRGB(0, 200, 100), function(new)
    precision = new
end)
precisionSlider.frame.Parent = triggerContent

local delaySlider = createSlider("Retardo", 1, 0, 100, "ms", Color3.fromRGB(255, 150, 0), function(new)
    triggerDelay = new
end)
delaySlider.frame.Parent = triggerContent

local distanceSlider = createSlider("Distancia máxima", 500, 0, 5000, "", Color3.fromRGB(200, 100, 255), function(new)
    maxDistance = new
end)
distanceSlider.frame.Parent = triggerContent

-- Contenido de Hitbox Expander
local hitboxContent = Instance.new("Frame")
hitboxContent.Size = UDim2.new(1, 0, 1, 0)
hitboxContent.BackgroundTransparency = 1
hitboxContent.Parent = contentScroller
hitboxContent.Visible = false
hitboxContent.ZIndex = 6

local hitboxLayout = Instance.new("UIListLayout")
hitboxLayout.Padding = UDim.new(0, 15)
hitboxLayout.SortOrder = Enum.SortOrder.LayoutOrder
hitboxLayout.Parent = hitboxContent

local enableHitboxToggle = createToggle("Activar Hitbox Expander", false, Color3.fromRGB(255, 70, 200), function(new)
    getgenv().hitboxEnabled = new
    if new then
        applyHitboxToAll()
        showNotification("Hitbox", "Activado", 2, "success")
    else
        restoreAllOriginal()
        showNotification("Hitbox", "Desactivado", 2, "error")
    end
end)
enableHitboxToggle.frame.Parent = hitboxContent

local teamcheckToggle = createToggle("Team Check (solo enemigos)", false, Color3.fromRGB(255, 70, 200), function(new)
    getgenv().hitboxTeamcheck = new
    if getgenv().hitboxEnabled then
        restoreAllOriginal()
        applyHitboxToAll()
    end
end)
teamcheckToggle.frame.Parent = hitboxContent

local sizeXSlider = createSlider("Tamaño X", 4, 1, 20, "", Color3.fromRGB(255, 70, 200), function(new)
    getgenv().hitboxSizeX = new
    if getgenv().hitboxEnabled then
        applyHitboxToAll()
    end
end)
sizeXSlider.frame.Parent = hitboxContent

local sizeYSlider = createSlider("Tamaño Y", 4, 1, 20, "", Color3.fromRGB(255, 70, 200), function(new)
    getgenv().hitboxSizeY = new
    if getgenv().hitboxEnabled then
        applyHitboxToAll()
    end
end)
sizeYSlider.frame.Parent = hitboxContent

local sizeZSlider = createSlider("Tamaño Z", 4, 1, 20, "", Color3.fromRGB(255, 70, 200), function(new)
    getgenv().hitboxSizeZ = new
    if getgenv().hitboxEnabled then
        applyHitboxToAll()
    end
end)
sizeZSlider.frame.Parent = hitboxContent

local opacitySlider = createSlider("Opacidad", 0.9, 0, 1, "", Color3.fromRGB(255, 70, 200), function(new)
    getgenv().hitboxTransparency = new
    if getgenv().hitboxEnabled then
        applyHitboxToAll()
    end
end)
opacitySlider.frame.Parent = hitboxContent

local autoRefreshToggle = createToggle("Auto Refresh (arreglar respawn)", false, Color3.fromRGB(255, 70, 200), function(new)
    getgenv().hitboxRefreshEnabled = new
end)
autoRefreshToggle.frame.Parent = hitboxContent

local intervalSlider = createSlider("Intervalo (s)", 5, 0.1, 15, "s", Color3.fromRGB(255, 70, 200), function(new)
    getgenv().hitboxRefreshInterval = new
end)
intervalSlider.frame.Parent = hitboxContent

-- ==================== FUNCIONALIDAD DE PESTAÑAS ====================
triggerTab.MouseButton1Click:Connect(function()
    -- Animación de cambio de pestaña
    TweenService:Create(triggerTab, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
    TweenService:Create(hitboxTab, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
    triggerTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    hitboxTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    triggerContent.Visible = true
    hitboxContent.Visible = false
end)

hitboxTab.MouseButton1Click:Connect(function()
    TweenService:Create(hitboxTab, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 70, 200)}):Play()
    TweenService:Create(triggerTab, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
    hitboxTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    triggerTab.TextColor3 = Color3.fromRGB(200, 200, 200)
    triggerContent.Visible = false
    hitboxContent.Visible = true
end)

-- ==================== MODO SELECTOR ====================
modeSelector.holdBtn.MouseButton1Click:Connect(function()
    holdMode = true
    TweenService:Create(modeSelector.holdBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
    TweenService:Create(modeSelector.toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
    modeSelector.holdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeSelector.toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

modeSelector.toggleBtn.MouseButton1Click:Connect(function()
    holdMode = false
    TweenService:Create(modeSelector.toggleBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 150, 0)}):Play()
    TweenService:Create(modeSelector.holdBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
    modeSelector.toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    modeSelector.holdBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
end)

-- ==================== SELECCIÓN DE TECLA ====================
keybindBtn.button.MouseButton1Click:Connect(function()
    isSelectingKey = true
    keybindBtn.button.Text = "Presiona una tecla..."
    TweenService:Create(keybindBtn.button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 150, 0)}):Play()
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
        TweenService:Create(keybindBtn.button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play()
        isSelectingKey = false
    end
end)

-- ==================== CONTROLES DE VENTANA ====================
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
            Size = UDim2.new(0, 520, 0, 80),
            Position = UDim2.new(0.5, -260, 1, -100)
        }):Play()
        contentContainer.Visible = false
        tabContainer.Visible = false
        minimizeBtn.Text = "□"  -- Cambiar icono a restaurar
    else
        TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
            Size = UDim2.new(0, 520, 0, 620),
            Position = UDim2.new(0.5, -260, 0.5, -310)
        }):Play()
        contentContainer.Visible = true
        tabContainer.Visible = true
        minimizeBtn.Text = "−"
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.wait(0.5)
    gui:Destroy()
    enabled = false
end)

-- Atajo para mostrar/ocultar (Ctrl Derecho)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.RightControl and not isSelectingKey then
        guiVisible = not guiVisible
        if guiVisible then
            main.Visible = true
            TweenService:Create(main, TweenInfo.new(0.6, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 520, 0, minimized and 80 or 620),
                BackgroundTransparency = 0.1
            }):Play()
        else
            TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1
            }):Play()
            task.wait(0.3)
            main.Visible = false
        end
    end
end)

-- Animación de entrada
main.Size = UDim2.new(0, 0, 0, 0)
main.BackgroundTransparency = 1
main.Visible = true
task.wait(0.1)
TweenService:Create(main, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 520, 0, 620),
    BackgroundTransparency = 0.1
}):Play()

-- Notificaciones de bienvenida
showNotification("FAME CHEATS V2", "Interfaz moderna cargada", 3, "success")
showNotification("CONTROLES", "CTRL DERECHO para abrir/cerrar", 3, "info")

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
