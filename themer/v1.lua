--[[
    =====================================================================
    WINION SPECTATE SYSTEM
    Версия: 1.0.0
    Разработчик: @Winion (@Winion Virus)
    Описание: Система наблюдения за игроками в стиле MM2 с кастомным красным UI
    Репозиторий: https://github.com/official-ids/Saites
    =====================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =====================================================================
-- 1. НАСТРОЙКИ И ПЕРЕМЕННЫЕ
-- =====================================================================
local THEME_COLOR = Color3.fromRGB(220, 50, 50) -- Красная тема (согласно предпочтениям)
local BG_COLOR = Color3.fromRGB(20, 20, 25)
local TEXT_COLOR = Color3.fromRGB(255, 255, 255)

local spectatingPlayer = nil
local guiOpen = true

-- =====================================================================
-- 2. СОЗДАНИЕ ИНТЕРФЕЙСА (Custom UI)
-- =====================================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WinionSpectateUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Главная панель
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 300)
MainFrame.Position = UDim2.new(0.75, -110, 0.5, -150)
MainFrame.BackgroundColor3 = BG_COLOR
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = THEME_COLOR
mainStroke.Thickness = 2

-- Заголовок (для перетаскивания)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = THEME_COLOR
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
-- Скругляем только нижние углы заголовка, чтобы он сливался с фоном
local titleCorner = Instance.new("UICorner", TitleBar)
titleCorner.CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -30, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "👁️ Winion Spectate"
TitleText.TextColor3 = TEXT_COLOR
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Кнопка закрытия/сворачивания
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = TEXT_COLOR
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Список игроков
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "PlayerList"
ScrollFrame.Size = UDim2.new(1, -10, 1, -85)
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = THEME_COLOR
ScrollFrame.Parent = MainFrame

Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 6)

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.Name

-- Кнопка "Отключить наблюдение"
local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(1, -10, 0, 35)
StopBtn.Position = UDim2.new(0, 5, 1, -40)
StopBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
StopBtn.BorderSizePixel = 0
StopBtn.Text = "Остановить наблюдение"
StopBtn.TextColor3 = TEXT_COLOR
StopBtn.TextSize = 14
StopBtn.Font = Enum.Font.GothamBold
StopBtn.Parent = MainFrame
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 6)

local stopStroke = Instance.new("UIStroke", StopBtn)
stopStroke.Color = Color3.fromRGB(60, 60, 70)
stopStroke.Thickness = 1

-- =====================================================================
-- 3. ЛОГИКА ПЕРЕТАСКИВАНИЯ (DRAG)
-- =====================================================================
local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale, framePos.X.Offset + delta.X,
            framePos.Y.Scale, framePos.Y.Offset + delta.Y
        )
    end
end)

-- =====================================================================
-- 4. ЛОГИКА НАБЛЮДЕНИЯ (SPECTATE)
-- =====================================================================
local function UpdatePlayerList()
    -- Очищаем текущий список
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Добавляем игроков
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local PlayerBtn = Instance.new("TextButton")
            PlayerBtn.Size = UDim2.new(1, -10, 0, 30)
            PlayerBtn.BackgroundColor3 = (spectatingPlayer == player) and THEME_COLOR or Color3.fromRGB(30, 30, 40)
            PlayerBtn.BorderSizePixel = 0
            PlayerBtn.Text = player.Name
            PlayerBtn.TextColor3 = TEXT_COLOR
            PlayerBtn.TextSize = 14
            PlayerBtn.Font = Enum.Font.GothamBold
            PlayerBtn.Parent = ScrollFrame
            
            Instance.new("UICorner", PlayerBtn).CornerRadius = UDim.new(0, 6)
            
            -- Анимация при наведении
            PlayerBtn.MouseEnter:Connect(function()
                if spectatingPlayer ~= player then
                    PlayerBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
                end
            end)
            PlayerBtn.MouseLeave:Connect(function()
                if spectatingPlayer ~= player then
                    PlayerBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                end
            end)

            -- Клик по игроку
            PlayerBtn.MouseButton1Click:Connect(function()
                SpectatePlayer(player)
            end)
        end
    end

    -- Обновляем размер Canvas для скролла
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
    end)
end

local function SpectatePlayer(player)
    -- Безопасная проверка существования персонажа и Humanoid
    if not player or player == LocalPlayer then return end
    
    local character = player.Character
    if character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") then
        local camera = workspace.CurrentCamera
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = character.Humanoid
        
        spectatingPlayer = player
        UpdatePlayerList() -- Обновляем UI, чтобы подсветить выбранного игрока
        
        -- Уведомление в чат (опционально, можно убрать)
        -- print("[Winion Spectate] Наблюдение за: " .. player.Name)
    else
        warn("[Winion Spectate] Не удалось начать наблюдение: персонаж игрока не загружен.")
    end
end

local function StopSpectating()
    local camera = workspace.CurrentCamera
    camera.CameraType = Enum.CameraType.Custom
    
    -- Безопасный возврат камеры к локальному игроку
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        camera.CameraSubject = LocalPlayer.Character.Humanoid
    end
    
    spectatingPlayer = nil
    UpdatePlayerList()
end

-- =====================================================================
-- 5. ОБРАБОТЧИКИ СОБЫТИЙ
-- =====================================================================
CloseBtn.MouseButton1Click:Connect(function()
    guiOpen = not guiOpen
    MainFrame.Visible = guiOpen
end)

StopBtn.MouseButton1Click:Connect(StopSpectating)

-- Автоматическое обновление списка при входе/выходе игроков
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(function(player)
    if spectatingPlayer == player then
        StopSpectating()
    end
    UpdatePlayerList()
end)

-- Инициализация при запуске
task.spawn(function()
    -- Ждем полной загрузки персонажей, чтобы список был актуальным
    task.wait(1)
    UpdatePlayerList()
end)

-- Защита от сброса камеры при респавне локального игрока
LocalPlayer.CharacterAdded:Connect(function()
    if not spectatingPlayer then
        task.wait(0.5)
        StopSpectating()
    end
end)