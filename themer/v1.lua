-- Spectate System
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local spectating = nil
local guiOpen = true

-- Цветовая схема
local colors = {
    bg = Color3.fromRGB(22, 22, 30),
    bgSecondary = Color3.fromRGB(30, 30, 42),
    accent = Color3.fromRGB(99, 102, 241),
    accentHover = Color3.fromRGB(129, 132, 251),
    danger = Color3.fromRGB(239, 68, 68),
    text = Color3.fromRGB(255, 255, 255),
    textMuted = Color3.fromRGB(156, 163, 175),
    border = Color3.fromRGB(55, 55, 75),
    playerBtn = Color3.fromRGB(40, 40, 55),
    playerBtnHover = Color3.fromRGB(50, 50, 70),
    playerSelected = Color3.fromRGB(99, 102, 241)
}

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpectateSystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Кнопка открытия (плавающая, видна когда GUI закрыт)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(1, -60, 0.5, -25)
OpenBtn.BackgroundColor3 = colors.accent
OpenBtn.BorderSizePixel = 0
OpenBtn.Text = "S"
OpenBtn.TextColor3 = colors.text
OpenBtn.TextSize = 18
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Visible = false
OpenBtn.Parent = ScreenGui

Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", OpenBtn).Color = colors.accentHover

OpenBtn.MouseButton1Click:Connect(function()
    guiOpen = true
    MainFrame.Visible = true
    OpenBtn.Visible = false
    TweenService:Create(MainFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
end)

-- Основная рамка
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 360)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -180)
MainFrame.BackgroundColor3 = colors.bg
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = colors.border
mainStroke.Thickness = 1.5

-- Тень (имитация через рамку)
local shadow = Instance.new("UIStroke", MainFrame)
shadow.Color = Color3.fromRGB(0, 0, 0)
shadow.Thickness = 3
shadow.Transparency = 0.7

-- Заголовок
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = colors.bgSecondary
Header.BorderSizePixel = 0
Header.Parent = MainFrame

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

-- Скрываем нижние скругления заголовка
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 12)
headerFix.Position = UDim2.new(0, 0, 1, -12)
headerFix.BackgroundColor3 = colors.bgSecondary
headerFix.BorderSizePixel = 0
headerFix.Parent = Header

local headerLabel = Instance.new("TextLabel")
headerLabel.Size = UDim2.new(1, -50, 1, 0)
headerLabel.Position = UDim2.new(0, 15, 0, 0)
headerLabel.BackgroundTransparency = 1
headerLabel.Text = "Spectate"
headerLabel.TextColor3 = colors.text
headerLabel.TextSize = 16
headerLabel.Font = Enum.Font.GothamBold
headerLabel.TextXAlignment = Enum.TextXAlignment.Left
headerLabel.Parent = Header

-- Индикатор статуса
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -50, 0, 18)
statusLabel.Position = UDim2.new(0, 15, 1, -22)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Not spectating"
statusLabel.TextColor3 = colors.textMuted
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = Header

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "x"
CloseBtn.TextColor3 = colors.textMuted
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

CloseBtn.MouseEnter:Connect(function()
    CloseBtn.BackgroundColor3 = colors.danger
    CloseBtn.TextColor3 = colors.text
end)
CloseBtn.MouseLeave:Connect(function()
    CloseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    CloseBtn.TextColor3 = colors.textMuted
end)

CloseBtn.MouseButton1Click:Connect(function()
    guiOpen = false
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

-- Список игроков
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -110)
ScrollFrame.Position = UDim2.new(0, 10, 0, 55)
ScrollFrame.BackgroundColor3 = colors.bg
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = colors.accent
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout", ScrollFrame)
listLayout.Padding = UDim.new(0, 6)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Кнопка остановки
local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(1, -20, 0, 38)
StopBtn.Position = UDim2.new(0, 10, 1, -48)
StopBtn.BackgroundColor3 = colors.danger
StopBtn.BorderSizePixel = 0
StopBtn.Text = "Stop Spectating"
StopBtn.TextColor3 = colors.text
StopBtn.TextSize = 13
StopBtn.Font = Enum.Font.GothamBold
StopBtn.Parent = MainFrame

Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 8)

StopBtn.MouseEnter:Connect(function()
    StopBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
end)
StopBtn.MouseLeave:Connect(function()
    StopBtn.BackgroundColor3 = colors.danger
end)

-- Перетаскивание окна
local dragging = false
local dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Функция обновления статуса
local function updateStatus(text)
    statusLabel.Text = text
end

-- Функция наблюдения
local function spectatePlayer(player)
    if not player or player == LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then
        updateStatus("Waiting for character...")
        return
    end
    
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = humanoid
    
    spectating = player
    updateStatus("Spectating: " .. player.Name)
    refreshList()
end

-- Остановка наблюдения
local function stopSpectating()
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
    end
    
    spectating = nil
    updateStatus("Not spectating")
    refreshList()
end

-- Обновление списка игроков
function refreshList()
    -- Удаляем старые кнопки
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Добавляем игроков
    local playerCount = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            playerCount = playerCount + 1
            
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 36)
            btn.BackgroundColor3 = (spectating == player) and colors.playerSelected or colors.playerBtn
            btn.BorderSizePixel = 0
            btn.Text = player.DisplayName
            btn.TextColor3 = colors.text
            btn.TextSize = 13
            btn.Font = Enum.Font.GothamMedium
            btn.Parent = ScrollFrame
            
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            -- Подпись с именем пользователя
            local nameSub = Instance.new("TextLabel")
            nameSub.Size = UDim2.new(1, -20, 0, 14)
            nameSub.Position = UDim2.new(0, 10, 1, -16)
            nameSub.BackgroundTransparency = 1
            nameSub.Text = "@" .. player.Name
            nameSub.TextColor3 = colors.textMuted
            nameSub.TextSize = 10
            nameSub.Font = Enum.Font.Gotham
            nameSub.TextXAlignment = Enum.TextXAlignment.Left
            nameSub.Parent = btn
            
            -- Аватар (инициал)
            local avatar = Instance.new("TextLabel")
            avatar.Size = UDim2.new(0, 28, 0, 28)
            avatar.Position = UDim2.new(0, 8, 0, 4)
            avatar.BackgroundColor3 = colors.accent
            avatar.BorderSizePixel = 0
            avatar.Text = string.sub(player.DisplayName, 1, 1):upper()
            avatar.TextColor3 = colors.text
            avatar.TextSize = 14
            avatar.Font = Enum.Font.GothamBold
            avatar.Parent = btn
            
            Instance.new("UICorner", avatar).CornerRadius = UDim.new(0, 5)
            
            -- Смещаем текст вправо
            btn.Text = ""
            local displayNameLabel = Instance.new("TextLabel")
            displayNameLabel.Size = UDim2.new(1, -50, 0, 18)
            displayNameLabel.Position = UDim2.new(0, 42, 0, 4)
            displayNameLabel.BackgroundTransparency = 1
            displayNameLabel.Text = player.DisplayName
            displayNameLabel.TextColor3 = colors.text
            displayNameLabel.TextSize = 13
            displayNameLabel.Font = Enum.Font.GothamMedium
            displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
            displayNameLabel.Parent = btn
            
            -- Hover эффекты
            btn.MouseEnter:Connect(function()
                if spectating ~= player then
                    btn.BackgroundColor3 = colors.playerBtnHover
                end
            end)
            btn.MouseLeave:Connect(function()
                if spectating ~= player then
                    btn.BackgroundColor3 = colors.playerBtn
                end
            end)
            
            -- Клик
            btn.MouseButton1Click:Connect(function()
                spectatePlayer(player)
            end)
        end
    end
    
    if playerCount == 0 then
        updateStatus("No players to spectate")
    end
end

-- Обработчики событий
StopBtn.MouseButton1Click:Connect(stopSpectating)

Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(function(player)
    if spectating == player then
        stopSpectating()
    end
    task.wait(0.1)
    refreshList()
end)

-- Обработка респауна наблюдаемого игрока
local function onCharacterAdded(character)
    if spectating and character.Parent == spectating then
        task.wait(0.5)
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            workspace.CurrentCamera.CameraSubject = humanoid
            updateStatus("Spectating: " .. spectating.Name)
        end
    end
end

-- Подписка на респаун всех игроков
local function connectCharacter(player)
    player.CharacterAdded:Connect(onCharacterAdded)
end

for _, player in pairs(Players:GetPlayers()) do
    connectCharacter(player)
end

Players.PlayerAdded:Connect(connectCharacter)

-- Респаун локального игрока
LocalPlayer.CharacterAdded:Connect(function()
    if not spectating then
        task.wait(0.5)
        stopSpectating()
    end
end)

-- Инициализация
task.spawn(function()
    task.wait(1)
    refreshList()
end)