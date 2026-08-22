-- Spectate System (MM2 Style)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local spectating = nil
local playerList = {}
local currentIndex = 0

-- Цвета
local colors = {
    bg = Color3.fromRGB(0, 0, 0),
    bgTransparent = Color3.fromRGB(0, 0, 0),
    text = Color3.fromRGB(255, 255, 255),
    textMuted = Color3.fromRGB(180, 180, 180),
    button = Color3.fromRGB(40, 40, 40),
    buttonHover = Color3.fromRGB(60, 60, 60),
    accent = Color3.fromRGB(255, 255, 255)
}

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2Spectate"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Основной контейнер (внизу экрана как в MM2)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 80)
MainFrame.Position = UDim2.new(0.5, -200, 1, -100)
MainFrame.BackgroundColor3 = colors.bgTransparent
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Левая стрелка
local LeftArrow = Instance.new("TextButton")
LeftArrow.Size = UDim2.new(0, 50, 0, 50)
LeftArrow.Position = UDim2.new(0, 0, 0.5, -25)
LeftArrow.BackgroundColor3 = colors.button
LeftArrow.BorderSizePixel = 0
LeftArrow.Text = "<"
LeftArrow.TextColor3 = colors.text
LeftArrow.TextSize = 24
LeftArrow.Font = Enum.Font.GothamBold
LeftArrow.Visible = false
LeftArrow.Parent = MainFrame

Instance.new("UICorner", LeftArrow).CornerRadius = UDim.new(0, 8)

LeftArrow.MouseEnter:Connect(function()
    LeftArrow.BackgroundColor3 = colors.buttonHover
end)
LeftArrow.MouseLeave:Connect(function()
    LeftArrow.BackgroundColor3 = colors.button
end)

-- Правая стрелка
local RightArrow = Instance.new("TextButton")
RightArrow.Size = UDim2.new(0, 50, 0, 50)
RightArrow.Position = UDim2.new(1, -50, 0.5, -25)
RightArrow.BackgroundColor3 = colors.button
RightArrow.BorderSizePixel = 0
RightArrow.Text = ">"
RightArrow.TextColor3 = colors.text
RightArrow.TextSize = 24
RightArrow.Font = Enum.Font.GothamBold
RightArrow.Visible = false
RightArrow.Parent = MainFrame

Instance.new("UICorner", RightArrow).CornerRadius = UDim.new(0, 8)

RightArrow.MouseEnter:Connect(function()
    RightArrow.BackgroundColor3 = colors.buttonHover
end)
RightArrow.MouseLeave:Connect(function()
    RightArrow.BackgroundColor3 = colors.button
end)

-- Центральная панель с информацией
local InfoFrame = Instance.new("Frame")
InfoFrame.Size = UDim2.new(1, -120, 0, 60)
InfoFrame.Position = UDim2.new(0, 60, 0.5, -30)
InfoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
InfoFrame.BackgroundTransparency = 0.3
InfoFrame.BorderSizePixel = 0
InfoFrame.Visible = false
InfoFrame.Parent = MainFrame

Instance.new("UICorner", InfoFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", InfoFrame).Color = Color3.fromRGB(60, 60, 70)
Instance.new("UIStroke", InfoFrame).Thickness = 1

-- DisplayName
local DisplayNameLabel = Instance.new("TextLabel")
DisplayNameLabel.Size = UDim2.new(1, 0, 0, 30)
DisplayNameLabel.Position = UDim2.new(0, 0, 0, 5)
DisplayNameLabel.BackgroundTransparency = 1
DisplayNameLabel.Text = "Player Name"
DisplayNameLabel.TextColor3 = colors.text
DisplayNameLabel.TextSize = 20
DisplayNameLabel.Font = Enum.Font.GothamBold
DisplayNameLabel.Parent = InfoFrame

-- Username
local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Size = UDim2.new(1, 0, 0, 20)
UsernameLabel.Position = UDim2.new(0, 0, 1, -22)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = "@username"
UsernameLabel.TextColor3 = colors.textMuted
UsernameLabel.TextSize = 14
UsernameLabel.Font = Enum.Font.Gotham
UsernameLabel.Parent = InfoFrame

-- Кнопка выхода из spectate
local ExitButton = Instance.new("TextButton")
ExitButton.Size = UDim2.new(0, 100, 0, 35)
ExitButton.Position = UDim2.new(0.5, -50, 1, -45)
ExitButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
ExitButton.BorderSizePixel = 0
ExitButton.Text = "Exit Spectate"
ExitButton.TextColor3 = colors.text
ExitButton.TextSize = 14
ExitButton.Font = Enum.Font.GothamBold
ExitButton.Visible = false
ExitButton.Parent = ScreenGui

Instance.new("UICorner", ExitButton).CornerRadius = UDim.new(0, 6)

ExitButton.MouseEnter:Connect(function()
    ExitButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)
ExitButton.MouseLeave:Connect(function()
    ExitButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
end)

-- Функция обновления списка игроков
local function updatePlayerList()
    playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player)
        end
    end
    
    if #playerList > 0 and currentIndex == 0 then
        currentIndex = 1
    elseif currentIndex > #playerList then
        currentIndex = #playerList
    end
end

-- Функция отображения spectate UI
local function showSpectateUI()
    if #playerList == 0 then return end
    
    LeftArrow.Visible = true
    RightArrow.Visible = true
    InfoFrame.Visible = true
    ExitButton.Visible = true
    
    updateDisplay()
end

-- Функция скрытия spectate UI
local function hideSpectateUI()
    LeftArrow.Visible = false
    RightArrow.Visible = false
    InfoFrame.Visible = false
    ExitButton.Visible = false
end

-- Обновление отображения текущего игрока
local function updateDisplay()
    if currentIndex < 1 or currentIndex > #playerList then return end
    
    local player = playerList[currentIndex]
    DisplayNameLabel.Text = player.DisplayName
    UsernameLabel.Text = "@" .. player.Name
    
    -- Начинаем наблюдение
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") then
        local camera = workspace.CurrentCamera
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = character:FindFirstChild("Humanoid")
        spectating = player
    end
end

-- Переключение влево
LeftArrow.MouseButton1Click:Connect(function()
    if #playerList == 0 then return end
    currentIndex = currentIndex - 1
    if currentIndex < 1 then
        currentIndex = #playerList
    end
    updateDisplay()
end)

-- Переключение вправо
RightArrow.MouseButton1Click:Connect(function()
    if #playerList == 0 then return end
    currentIndex = currentIndex + 1
    if currentIndex > #playerList then
        currentIndex = 1
    end
    updateDisplay()
end)

-- Выход из spectate
ExitButton.MouseButton1Click:Connect(function()
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
    end
    
    spectating = nil
    hideSpectateUI()
end)

-- Горячие клавиши (стрелки на клавиатуре)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Left then
        LeftArrow.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.Right then
        RightArrow.MouseButton1Click:Fire()
    end
end)

-- Обновление при добавлении/удалении игроков
Players.PlayerAdded:Connect(function()
    updatePlayerList()
    if spectating then
        showSpectateUI()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    updatePlayerList()
    
    if spectating == player then
        if #playerList > 0 then
            currentIndex = math.min(currentIndex, #playerList)
            updateDisplay()
        else
            spectating = nil
            hideSpectateUI()
        end
    end
end)

-- Обработка респауна наблюдаемого игрока
local function onCharacterAdded(character)
    if spectating and character.Parent == spectating then
        task.wait(0.5)
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            workspace.CurrentCamera.CameraSubject = humanoid
        end
    end
end

-- Подписка на всех игроков
local function connectCharacter(player)
    player.CharacterAdded:Connect(onCharacterAdded)
end

for _, player in pairs(Players:GetPlayers()) do
    connectCharacter(player)
end

Players.PlayerAdded:Connect(connectCharacter)

-- Автоматический показ spectate при смерти локального игрока
LocalPlayer.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    humanoid.Died:Connect(function()
        task.wait(1)
        updatePlayerList()
        if #playerList > 0 then
            showSpectateUI()
        end
    end)
end)

-- Инициализация
task.spawn(function()
    task.wait(1)
    updatePlayerList()
end)