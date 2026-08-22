--[[
    ====================================================================
    ShadowFollow Loader | Public Service Edition
    Автор загрузчика: Winion (@Winion)
    Назначение: Профессиональная загрузка и управление версиями скрипта
    ====================================================================
]]

-- // 1. Конфигурация и Сервисы
local Services = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService")
}

local LocalPlayer = Services.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SCRIPT_URLS = {
    v1 = "https://raw.githubusercontent.com/official-ids/pak/main/follower/v1.lua",
    v2 = "https://raw.githubusercontent.com/official-ids/pak/main/follower/v2.lua"
}

local TIPS = {
    "💡 Совет: Убедитесь, что ваш персонаж полностью заспавнился перед запуском.",
    "💡 Совет: Версия v2 использует улучшенный алгоритм обхода препятствий (Pathfinding).",
    "💡 Совет: Если скрипт не реагирует, попробуйте перезапустить игру и загрузчик.",
    "💡 Совет: Окно загрузчика можно перетаскивать за верхнюю панель.",
    "💡 Совет: Кэширование включено для ускорения повторных загрузок."
}

-- // 2. Очистка предыдущих экземпляров (предотвращение дублирования)
local LOADER_NAME = "ShadowFollow_Loader_GUI"
if PlayerGui:FindFirstChild(LOADER_NAME) then
    PlayerGui[LOADER_NAME]:Destroy()
end

-- // 3. Проверка совместимости экзекьютора
local LoadFunction = loadstring or load
if not LoadFunction then
    warn("[ShadowFollow Loader] КРИТИЧЕСКАЯ ОШИБКА: Ваш экзекьютор не поддерживает loadstring/load.")
    -- Попытка вывести уведомление в случае отсутствия GUI
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Ошибка совместимости",
        Text = "Ваш экзекьютор устарел и не поддерживает функцию loadstring.",
        Duration = 5
    })
    return
end

-- // 4. Создание пользовательского интерфейса (UI)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = LOADER_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

-- Основная рамка
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 280)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Скругление и обводка
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 70)
UIStroke.Thickness = 1
UIStroke.Parent = MainFrame

-- Заголовок
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
TitleLabel.Text = "🚀 ShadowFollow Loader"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = MainFrame
Instance.new("UICorner", TitleLabel).CornerRadius = UDim.new(0, 12)

-- Случайный совет
local TipLabel = Instance.new("TextLabel")
TipLabel.Size = UDim2.new(1, -20, 0, 40)
TipLabel.Position = UDim2.new(0, 10, 0, 45)
TipLabel.BackgroundTransparency = 1
TipLabel.Text = TIPS[math.random(1, #TIPS)]
TipLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
TipLabel.TextSize = 13
TipLabel.Font = Enum.Font.Gotham
TipLabel.TextWrapped = true
TipLabel.Parent = MainFrame

-- Статус бар
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 1, -35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "⏳ Ожидание выбора версии..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Parent = MainFrame

-- Функция создания кнопок (ОБНОВЛЕННАЯ ВЕРСИЯ С АВТО-УДАЛЕНИЕМ)
local function createButton(name, text, version, yPos)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, -40, 0, 45)
    Button.Position = UDim2.new(0, 20, 0, yPos)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Button.Text = text
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextSize = 16
    Button.Font = Enum.Font.GothamBold
    Button.AutoButtonColor = false
    Button.Parent = MainFrame
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(70, 70, 85)
    Stroke.Parent = Button

    -- Анимация наведения
    Button.MouseEnter:Connect(function()
        Services.TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(55, 55, 70)}):Play()
        Stroke.Color = Color3.fromRGB(100, 100, 255)
    end)
    Button.MouseLeave:Connect(function()
        Services.TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 55)}):Play()
        Stroke.Color = Color3.fromRGB(70, 70, 85)
    end)

    -- Логика нажатия и АВТОМАТИЧЕСКОГО УДАЛЕНИЯ при успехе
    Button.MouseButton1Click:Connect(function()
        Button.Interactable = false -- Блокировка повторных нажатий
        StatusLabel.Text = "⏳ Подключение к GitHub и загрузка..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)

        task.spawn(function()
            local success, result = pcall(function()
                return game:HttpGet(SCRIPT_URLS[version], true) -- true = кэширование
            end)

            if success and type(result) == "string" and #result > 50 then
                StatusLabel.Text = "⚙️ Компиляция и внедрение кода..."
                task.wait(0.2) -- Минимальная задержка для плавности UI
                
                local execSuccess, execErr = pcall(function()
                    LoadFunction(result)()
                end)

                if execSuccess then
                    StatusLabel.Text = "✅ Успешно запущено! Удаляю загрузчик..."
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
                    
                    -- Гарантированное безопасное удаление загрузчика через 1 секунду
                    task.delay(1.0, function()
                        if ScreenGui and ScreenGui.Parent then
                            ScreenGui:Destroy()
                        end
                    end)
                else
                    StatusLabel.Text = "❌ Ошибка выполнения: " .. tostring(execErr):sub(1, 40) .. "..."
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    Button.Interactable = true -- Разблокируем кнопку, чтобы можно было повторить попытку
                end
            else
                local errMsg = success and "Получен пустой или поврежденный ответ." or tostring(result)
                StatusLabel.Text = "❌ Ошибка сети: " .. errMsg:sub(1, 45) .. "..."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                Button.Interactable = true
            end
        end)
    end)
end

-- Создание кнопок версий
createButton("BtnV1", "📦 Загрузить Версию 1 (Стабильная)", "v1", 95)
createButton("BtnV2", "⚡ Загрузить Версию 2 (Новая/Advanced)", "v2", 150)

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- // 5. Логика перетаскивания окна (Draggable)
local dragging = false
local dragInput, mousePos, framePos

TitleLabel.InputBegan:Connect(function(input)
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

TitleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

Services.UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale, framePos.X.Offset + delta.X,
            framePos.Y.Scale, framePos.Y.Offset + delta.Y
        )
    end
end)

-- // 6. Анимация появления
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 50)
MainFrame.BackgroundTransparency = 1
Services.TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 0
}):Play()

print("[ShadowFollow Loader] Интерфейс успешно инициализирован и готов к использованию.")