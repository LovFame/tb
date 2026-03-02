-- Triggerbot con menú ajustable para Xeno Executor
-- Versión: Dispara en cualquier parte del cuerpo
local Triggerbot = {}
Triggerbot.__index = Triggerbot

function Triggerbot.new()
    local self = setmetatable({}, Triggerbot)
    self.Enabled = false
    self.Precision = 50 -- Precisión por defecto (0-100)
    self.TeamCheck = false
    self.VisibleCheck = true
    self.WallCheck = false
    self.Range = 1000 -- Rango máximo en studs
    self.AimAnywhere = true -- Siempre true, dispara en cualquier parte
    
    -- Crear GUI
    self:CreateGUI()
    return self
end

function Triggerbot:CreateGUI()
    -- ScreenGui principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TriggerbotGUI"
    screenGui.Parent = game.CoreGui
    
    -- Frame principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 250, 0, 280)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.Text = "TRIGGERBOT - XENO"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Botón toggle
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
    toggleBtn.Position = UDim2.new(0.05, 0, 0, 40)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleBtn.Text = "ENABLED: OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.Gotham
    toggleBtn.Parent = mainFrame
    
    -- Slider de precisión
    local precisionLabel = Instance.new("TextLabel")
    precisionLabel.Size = UDim2.new(0.9, 0, 0, 20)
    precisionLabel.Position = UDim2.new(0.05, 0, 0, 90)
    precisionLabel.BackgroundTransparency = 1
    precisionLabel.Text = "PRECISION: " .. self.Precision .. "%"
    precisionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    precisionLabel.TextXAlignment = Enum.TextXAlignment.Left
    precisionLabel.Font = Enum.Font.Gotham
    precisionLabel.Parent = mainFrame
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 20)
    sliderFrame.Position = UDim2.new(0.05, 0, 0, 115)
    sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = mainFrame
    
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(self.Precision / 100, 0, 1, 0)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    sliderBtn.BorderSizePixel = 0
    sliderBtn.Text = ""
    sliderBtn.Parent = sliderFrame
    
    -- Team Check
    local teamCheckBtn = Instance.new("TextButton")
    teamCheckBtn.Size = UDim2.new(0.9, 0, 0, 30)
    teamCheckBtn.Position = UDim2.new(0.05, 0, 0, 145)
    teamCheckBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    teamCheckBtn.Text = "TEAM CHECK: OFF"
    teamCheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    teamCheckBtn.Font = Enum.Font.Gotham
    teamCheckBtn.Parent = mainFrame
    
    -- Visible Check
    local visibleCheckBtn = Instance.new("TextButton")
    visibleCheckBtn.Size = UDim2.new(0.9, 0, 0, 30)
    visibleCheckBtn.Position = UDim2.new(0.05, 0, 0, 180)
    visibleCheckBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    visibleCheckBtn.Text = "VISIBLE CHECK: ON"
    visibleCheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    visibleCheckBtn.Font = Enum.Font.Gotham
    visibleCheckBtn.Parent = mainFrame
    
    -- Wall Check
    local wallCheckBtn = Instance.new("TextButton")
    wallCheckBtn.Size = UDim2.new(0.9, 0, 0, 30)
    wallCheckBtn.Position = UDim2.new(0.05, 0, 0, 215)
    wallCheckBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    wallCheckBtn.Text = "WALL CHECK: OFF"
    wallCheckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    wallCheckBtn.Font = Enum.Font.Gotham
    wallCheckBtn.Parent = mainFrame
    
    -- Botón de cerrar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -30, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        self.Enabled = false
    end)
    
    -- Funcionalidad del slider
    local dragging = false
    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local sliderPos = sliderFrame.AbsolutePosition.X
            local sliderSize = sliderFrame.AbsoluteSize.X
            
            local newWidth = math.clamp((mousePos - sliderPos) / sliderSize, 0, 1)
            sliderBtn.Size = UDim2.new(newWidth, 0, 1, 0)
            self.Precision = math.floor(newWidth * 100)
            precisionLabel.Text = "PRECISION: " .. self.Precision .. "%"
        end
    end)
    
    -- Conexiones de botones
    toggleBtn.MouseButton1Click:Connect(function()
        self.Enabled = not self.Enabled
        toggleBtn.Text = self.Enabled and "ENABLED: ON" or "ENABLED: OFF"
        toggleBtn.BackgroundColor3 = self.Enabled and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(50, 50, 50)
    end)
    
    teamCheckBtn.MouseButton1Click:Connect(function()
        self.TeamCheck = not self.TeamCheck
        teamCheckBtn.Text = self.TeamCheck and "TEAM CHECK: ON" or "TEAM CHECK: OFF"
        teamCheckBtn.BackgroundColor3 = self.TeamCheck and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(50, 50, 50)
    end)
    
    visibleCheckBtn.MouseButton1Click:Connect(function()
        self.VisibleCheck = not self.VisibleCheck
        visibleCheckBtn.Text = self.VisibleCheck and "VISIBLE CHECK: ON" or "VISIBLE CHECK: OFF"
        visibleCheckBtn.BackgroundColor3 = self.VisibleCheck and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(50, 50, 50)
    end)
    
    wallCheckBtn.MouseButton1Click:Connect(function()
        self.WallCheck = not self.WallCheck
        wallCheckBtn.Text = self.WallCheck and "WALL CHECK: ON" or "WALL CHECK: OFF"
        wallCheckBtn.BackgroundColor3 = self.WallCheck and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(50, 50, 50)
    end)
end

function Triggerbot:IsTargetVisible(targetPart)
    if not self.VisibleCheck then return true end
    
    local camera = workspace.CurrentCamera
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("Head") then return false end
    
    local origin = character.Head.Position
    local direction = (targetPart.Position - origin).Unit * self.Range
    
    local ray = Ray.new(origin, direction)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {character, camera})
    
    -- Verificar si el hit pertenece al jugador objetivo
    return hit and hit:IsDescendantOf(targetPart.Parent)
end

function Triggerbot:IsTargetInRange(targetPart)
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    
    local distance = (character.HumanoidRootPart.Position - targetPart.Position).Magnitude
    return distance <= self.Range
end

function Triggerbot:GetTargetUnderCrosshair()
    local player = game.Players.LocalPlayer
    local character = player.Character
    
    if not character or not character:FindFirstChild("Head") then return nil end
    
    local camera = workspace.CurrentCamera
    local mousePos = game:GetService("UserInputService"):GetMouseLocation()
    local unitRay = camera:ScreenPointToRay(mousePos.X, mousePos.Y)
    
    -- Extender el rayo hasta el rango máximo
    local ray = Ray.new(unitRay.Origin, unitRay.Direction * self.Range)
    local hitPart, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, {character, camera})
    
    if hitPart then
        -- Verificar si el hit pertenece a un jugador
        local hitHumanoid = hitPart.Parent:FindFirstChildOfClass("Humanoid")
        if hitHumanoid then
            local hitPlayer = game.Players:GetPlayerFromCharacter(hitPart.Parent)
            if hitPlayer and hitPlayer ~= player then
                -- Team check
                if self.TeamCheck and hitPlayer.Team == player.Team then
                    return nil
                end
                
                -- Verificar rango (aunque el rayo ya tiene rango, verificamos por seguridad)
                if self:IsTargetInRange(hitPart) then
                    -- Aplicar precisión
                    if math.random(1, 100) <= self.Precision then
                        -- Visible check (si está activado, el rayo ya verificó visibilidad)
                        if self.VisibleCheck then
                            -- El rayo ya confirmó que es visible, pero verificamos wall check si está activado
                            if self.WallCheck then
                                -- Aquí podrías agregar lógica adicional para paredes
                                return hitPart
                            else
                                return hitPart
                            end
                        else
                            return hitPart
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

function Triggerbot:Start()
    -- Loop principal
    game:GetService("RunService").RenderStepped:Connect(function()
        if not self.Enabled then return end
        
        local target = self:GetTargetUnderCrosshair()
        if target then
            -- Simular clic
            mouse1click()
            
            -- Pequeña pausa visual (opcional, comenta si quieres máximo rendimiento)
            wait(0.01)
        end
    end)
end

-- Iniciar el triggerbot
local triggerbot = Triggerbot.new()
triggerbot:Start()
