-- TRIGGERBOT - DA HOOD (VERSIÓN CORREGIDA)
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Variables
local enabled = false
local knifeCheck = true
local forceFieldCheck = false -- Lo dejamos false por defecto
local holdMode = true
local precision = 50
local triggerDelay = 1
local maxDistance = 500 -- Rango en studs

-- Variables para tecla personalizable
local holdKey = Enum.UserInputType.MouseButton2 -- Click derecho por defecto
local keyPressed = false
local triggerActive = false
local isSelectingKey = false

-- GUI Principal
local gui = Instance.new("ScreenGui")
gui.Name = "TriggerBotGUI"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 380, 0, 420)
main.Position = UDim2.new(0, 50, 0, 50)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

-- Bordes redondeados
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
title.Text = "Trigger Bot / Fame"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

-- Botón de cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -40, 0, 6)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = title

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Botón de minimizar
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 32, 0, 32)
minimizeBtn.Position = UDim2.new(1, -80, 0, 6)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.Parent = title

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 6)
minimizeCorner.Parent = minimizeBtn

-- Contenedor principal con scroll
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -20, 1, -55)
scrollingFrame.Position = UDim2.new(0, 10, 0, 50)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
scrollingFrame.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 15)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scrollingFrame

-- ===== SECCIÓN TRIGGER BOT =====
local triggerSection = Instance.new("Frame")
triggerSection.Size = UDim2.new(1, 0, 0, 35)
triggerSection.BackgroundTransparency = 1
triggerSection.Parent = scrollingFrame

local triggerLine = Instance.new("Frame")
triggerLine.Size = UDim2.new(1, 0, 0, 1)
triggerLine.Position = UDim2.new(0, 0, 1, -1)
triggerLine.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
triggerLine.Parent = triggerSection

local triggerLabel = Instance.new("TextLabel")
triggerLabel.Size = UDim2.new(1, 0, 1, 0)
triggerLabel.BackgroundTransparency = 1
triggerLabel.Text = "# Trigger Bot"
triggerLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
triggerLabel.Font = Enum.Font.GothamBold
triggerLabel.TextSize = 16
triggerLabel.TextXAlignment = Enum.TextXAlignment.Left
triggerLabel.Parent = triggerSection

-- Función para crear checkboxes
local function createCheckbox(text, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.Parent = scrollingFrame
    
    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0, 0, 0.5, -10)
    checkbox.BackgroundColor3 = default and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 50)
    checkbox.BorderSizePixel = 0
    checkbox.Text = ""
    checkbox.Parent = frame
    
    local checkCorner = Instance.new("UICorner")
    checkCorner.CornerRadius = UDim.new(0, 4)
    checkCorner.Parent = checkbox
    
    local checkMark = Instance.new("TextLabel")
    checkMark.Size = UDim2.new(1, 0, 1, 0)
    checkMark.BackgroundTransparency = 1
    checkMark.Text = default and "✓" or ""
    checkMark.TextColor3 = Color3.fromRGB(255, 255, 255)
    checkMark.Font = Enum.Font.GothamBold
    checkMark.TextSize = 16
    checkMark.Parent = checkbox
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -28, 1, 0)
    label.Position = UDim2.new(0, 28, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    return {frame = frame, checkbox = checkbox, checkMark = checkMark, value = default}
end

-- Checkboxes de Trigger Bot
local enableTrigger = createCheckbox("Enable Trigger Bot", false)
local knifeCheckbox = createCheckbox("Knife Check", true)
local forceFieldCheckbox = createCheckbox("Force Field Check", false)

-- ===== CONFIGURACIÓN DE TECLA =====
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(1, 0, 0, 70)
keyFrame.BackgroundTransparency = 1
keyFrame.Parent = scrollingFrame

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, 0, 0, 25)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "Keybind"
keyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
keyLabel.Font = Enum.Font.Gotham
keyLabel.TextSize = 14
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.Parent = keyFrame

-- Botón de modo (Hold/Toggle)
local modeBtn = Instance.new("TextButton")
modeBtn.Size = UDim2.new(0.48, 0, 0, 35)
modeBtn.Position = UDim2.new(0, 0, 0, 30)
modeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
modeBtn.Text = "HOLD"
modeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
modeBtn.Font = Enum.Font.GothamBold
modeBtn.TextSize = 14
modeBtn.Parent = keyFrame

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 6)
modeCorner.Parent = modeBtn

-- Botón para seleccionar tecla
local keySelectBtn = Instance.new("TextButton")
keySelectBtn.Size = UDim2.new(0.48, 0, 0, 35)
keySelectBtn.Position = UDim2.new(0.52, 0, 0, 30)
keySelectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
keySelectBtn.Text = "CLICK DERECHO"
keySelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keySelectBtn.Font = Enum.Font.Gotham
keySelectBtn.TextSize = 13
keySelectBtn.Parent = keyFrame

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 6)
keyCorner.Parent = keySelectBtn

-- ===== SECCIÓN CONFIGURATION =====
local configSection = Instance.new("Frame")
configSection.Size = UDim2.new(1, 0, 0, 35)
configSection.BackgroundTransparency = 1
configSection.Parent = scrollingFrame

local configLine = Instance.new("Frame")
configLine.Size = UDim2.new(1, 0, 0, 1)
configLine.Position = UDim2.new(0, 0, 1, -1)
configLine.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
configLine.Parent = configSection

local configLabel = Instance.new("TextLabel")
configLabel.Size = UDim2.new(1, 0, 1, 0)
configLabel.BackgroundTransparency = 1
configLabel.Text = "# Configuration"
configLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
configLabel.Font = Enum.Font.GothamBold
configLabel.TextSize = 16
configLabel.TextXAlignment = Enum.TextXAlignment.Left
configLabel.Parent = configSection

-- Función para crear sliders
local function createSlider(text, value, min, max, suffix)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = scrollingFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 25)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.5, -10, 0, 25)
    valueLabel.Position = UDim2.new(0.5, 10, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = value .. (suffix or "")
    valueLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    sliderBg.Parent = frame
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(1, 0)
    sliderBgCorner.Parent = sliderBg
    
    local percent = (value - min) / (max - min)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    sliderFill.Parent = sliderBg
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(1, 0)
    sliderFillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(1, 0, 1, 0)
    sliderButton.BackgroundTransparency = 1
    sliderButton.Text = ""
    sliderButton.Parent = sliderBg
    
    return {frame = frame, sliderFill = sliderFill, valueLabel = valueLabel, value = value, min = min, max = max, suffix = suffix, button = sliderButton}
end

-- Sliders de Configuration
local precisionSlider = createSlider("Precision", 50, 0, 100, "")
local delaySlider = createSlider("Trigger Delay (ms)", 1, 0, 100, " ms")
local distanceSlider = createSlider("Max Distance", 500, 0, 5000, "")

-- ===== FUNCIONALIDAD DE CHECKBOXES =====
enableTrigger.checkbox.MouseButton1Click:Connect(function()
    enabled = not enabled
    enableTrigger.value = enabled
    enableTrigger.checkbox.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 50)
    enableTrigger.checkMark.Text = enabled and "✓" or ""
end)

knifeCheckbox.checkbox.MouseButton1Click:Connect(function()
    knifeCheck = not knifeCheck
    knifeCheckbox.value = knifeCheck
    knifeCheckbox.checkbox.BackgroundColor3 = knifeCheck and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 50)
    knifeCheckbox.checkMark.Text = knifeCheck and "✓" or ""
end)

forceFieldCheckbox.checkbox.MouseButton1Click:Connect(function()
    forceFieldCheck = not forceFieldCheck
    forceFieldCheckbox.value = forceFieldCheck
    forceFieldCheckbox.checkbox.BackgroundColor3 = forceFieldCheck and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(45, 45, 50)
    forceFieldCheckbox.checkMark.Text = forceFieldCheck and "✓" or ""
end)

-- ===== FUNCIONALIDAD DE MODO Y TECLA =====
modeBtn.MouseButton1Click:Connect(function()
    holdMode = not holdMode
    modeBtn.Text = holdMode and "HOLD" or "TOGGLE"
    modeBtn.BackgroundColor3 = holdMode and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(255, 150, 0)
end)

keySelectBtn.MouseButton1Click:Connect(function()
    isSelectingKey = true
    keySelectBtn.Text = "PRESIONA TECLA"
    keySelectBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
end)

UserInputService.InputBegan:Connect(function(input)
    if isSelectingKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            holdKey = input.KeyCode
            keySelectBtn.Text = input.KeyCode.Name
            keySelectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            holdKey = Enum.UserInputType.MouseButton1
            keySelectBtn.Text = "CLICK IZQUIERDO"
            keySelectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            holdKey = Enum.UserInputType.MouseButton2
            keySelectBtn.Text = "CLICK DERECHO"
            keySelectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            holdKey = Enum.UserInputType.MouseButton3
            keySelectBtn.Text = "CLICK MEDIO"
            keySelectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        end
        isSelectingKey = false
    end
end)

-- ===== FUNCIONALIDAD DE SLIDERS =====
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
    precisionSlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    precision = math.floor(percent * 100)
    precisionSlider.valueLabel.Text = precision
end)

delaySlider.button.MouseButton1Down:Connect(function(input)
    draggingDelay = true
    local mouseX = input.Position.X
    local bgPos = delaySlider.button.AbsolutePosition.X
    local bgSize = delaySlider.button.AbsoluteSize.X
    local percent = (mouseX - bgPos) / bgSize
    percent = math.clamp(percent, 0, 1)
    delaySlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    triggerDelay = math.floor(percent * 100)
    delaySlider.valueLabel.Text = triggerDelay .. " ms"
end)

distanceSlider.button.MouseButton1Down:Connect(function(input)
    draggingDistance = true
    local mouseX = input.Position.X
    local bgPos = distanceSlider.button.AbsolutePosition.X
    local bgSize = distanceSlider.button.AbsoluteSize.X
    local percent = (mouseX - bgPos) / bgSize
    percent = math.clamp(percent, 0, 1)
    distanceSlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
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
            precisionSlider.valueLabel.Text = precision
        end
        
        if draggingDelay then
            local bgPos = delaySlider.button.AbsolutePosition.X
            local bgSize = delaySlider.button.AbsoluteSize.X
            local percent = (mousePos.X - bgPos) / bgSize
            percent = math.clamp(percent, 0, 1)
            delaySlider.sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            triggerDelay = math.floor(percent * 100)
            delaySlider.valueLabel.Text = triggerDelay .. " ms"
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
        draggingPrecision = false
        draggingDelay = false
        draggingDistance = false
    end
end)

-- ===== SISTEMA DE MINIMIZADO CON CTRL =====
local guiVisible = true

local function isCtrlKey(input)
    return input.KeyCode == Enum.KeyCode.RightControl
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard and isCtrlKey(input) then
        guiVisible = not guiVisible
        gui.Enabled = guiVisible
        
        if guiVisible then
            print("🔓 GUI abierta con CTRL")
        else
            print("🔒 GUI cerrada con CTRL")
        end
        return
    end
end)

-- El botón de minimizar también funciona
minimizeBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    gui.Enabled = false
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
    enabled = false
end)

-- ===== SISTEMA DE ACTIVACIÓN POR TECLA =====
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
        else
            triggerActive = not triggerActive
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if isKeyPressed(input) then
        keyPressed = false
        if holdMode then
            triggerActive = false
        end
    end
end)

-- ===== FUNCIÓN PARA DETECTAR CUCHILLO (CORREGIDA) =====
local function hasKnifeEquipped()
    local character = player.Character
    if not character then return false end
    
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        local toolName = tool.Name:lower()
        -- Lista completa de nombres de cuchillos en Da Hood
        local knifeNames = {
            "knife", "cuchillo", "blade", "combat", "hunting",
            "butterfly", "switchblade", "dagger", "machete", "katana",
            "karambit", "stiletto", "tactical", "throwing"
        }
        
        for _, name in ipairs(knifeNames) do
            if toolName:find(name) then
                print("🔪 Cuchillo detectado: " .. tool.Name) -- Debug
                return true
            end
        end
    end
    return false
end

-- ===== FUNCIÓN PARA CALCULAR DISTANCIA =====
local function getDistanceFromTarget(targetPart)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return math.huge end
    
    local rootPart = character.HumanoidRootPart
    return (rootPart.Position - targetPart.Position).Magnitude
end

-- ===== FUNCIÓN PRINCIPAL DEL TRIGGERBOT =====
local lastShotTime = 0

RunService.Heartbeat:Connect(function()
    -- SOLO dispara si enabled está activado Y la tecla está presionada
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
    
    -- VERIFICACIÓN DE RANGO
    local distance = getDistanceFromTarget(target)
    if distance > maxDistance then
        return
    end
    
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end
    
    local plr = Players:GetPlayerFromCharacter(model)
    if not plr or plr == player then return end
    
    -- KNIFE CHECK - AHORA FUNCIONA
    if knifeCheck and hasKnifeEquipped() then
        return -- No dispara si tiene cuchillo equipado
    end
    
    if math.random(1, 100) <= precision then
        mouse1click()
        lastShotTime = currentTime
    end
end)
