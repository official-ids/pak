--[[
    =====================================================================
    KENSA AI ASSISTANT
    Полнофункциональный AI-ассистент для Roblox
    Разработчик: @Kensa
    Версия: 2.0.0
    =====================================================================
    
    Описание:
    Этот скрипт создает полнофункционального AI-ассистента с адаптивным
    интерфейсом, виджетом чата, системой генерации скриптов и встроенными
    командами. Ассистент собирает полную информацию об игроке и игре,
    генерирует и выполняет Luau-скрипты по запросу пользователя.
    
    Особенности:
    - Адаптивный дизайн для ПК и мобильных устройств
    - Виджет чата с возможностью перетаскивания
    - AI-генерация и инжект скриптов
    - Встроенные команды (/help, /clear, /stats и др.)
    - Дневные лимиты запросов (100 в день)
    - Сбор полной информации об игроке и игре
    - Поддержка Markdown в сообщениях
    
    =====================================================================
]]

-- =====================================================================
-- РАЗДЕЛ 1: ИНИЦИАЛИЗАЦИЯ СЕРВИСОВ ROBLOX
-- =====================================================================

-- Получение основных сервисов Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local Stats = game:GetService("Stats")

-- Получение локального игрока
local LocalPlayer = Players.LocalPlayer

-- Ожидание PlayerGui
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =====================================================================
-- РАЗДЕЛ 2: КОНФИГУРАЦИЯ ПРИЛОЖЕНИЯ
-- =====================================================================

-- Основная конфигурация приложения
local CONFIG = {
    -- API настройки
    API_URL = "https://api.mistral.ai/v1/chat/completions",
    API_KEY = "v50l52LxJ2BzUK0C6W2nkkt3MNJ9Yova",
    AI_MODEL = "mistral-small-latest",
    MAX_TOKENS = 2048,
    TEMPERATURE = 0.75,
    TOP_P = 0.9,
    
    -- Лимиты
    DAILY_LIMIT = 100,
    REQUEST_TIMEOUT = 30,
    
    -- API для аватаров
    AVATAR_API_URL = "https://thumbnails.roblox.com/v1/users/avatar-headshot",
    AVATAR_SIZE = "150x150",
    AVATAR_FORMAT = "Png",
    
    -- UI настройки
    WINDOW_WIDTH = 500,
    WINDOW_HEIGHT = 650,
    WIDGET_SIZE = 60,
    CORNER_RADIUS = 12,
    
    -- Анимации
    ANIMATION_SPEED = 0.3,
    
    -- Цветовые темы
    THEMES = {
        Dark = {
            Background = Color3.fromRGB(18, 18, 28),
            Surface = Color3.fromRGB(28, 28, 42),
            SurfaceHover = Color3.fromRGB(38, 38, 55),
            Primary = Color3.fromRGB(88, 101, 242),
            PrimaryHover = Color3.fromRGB(108, 121, 252),
            Success = Color3.fromRGB(67, 185, 110),
            Warning = Color3.fromRGB(245, 158, 11),
            Error = Color3.fromRGB(239, 68, 68),
            Text = Color3.fromRGB(255, 255, 255),
            TextSecondary = Color3.fromRGB(160, 160, 180),
            TextMuted = Color3.fromRGB(100, 100, 120),
            Border = Color3.fromRGB(45, 45, 65),
            UserMessage = Color3.fromRGB(88, 101, 242),
            AIMessage = Color3.fromRGB(35, 35, 50),
            CodeBackground = Color3.fromRGB(15, 15, 25),
        },
        Light = {
            Background = Color3.fromRGB(245, 245, 250),
            Surface = Color3.fromRGB(255, 255, 255),
            SurfaceHover = Color3.fromRGB(240, 240, 245),
            Primary = Color3.fromRGB(88, 101, 242),
            PrimaryHover = Color3.fromRGB(78, 91, 232),
            Success = Color3.fromRGB(57, 175, 100),
            Warning = Color3.fromRGB(235, 148, 1),
            Error = Color3.fromRGB(229, 58, 58),
            Text = Color3.fromRGB(20, 20, 30),
            TextSecondary = Color3.fromRGB(80, 80, 100),
            TextMuted = Color3.fromRGB(140, 140, 160),
            Border = Color3.fromRGB(220, 220, 230),
            UserMessage = Color3.fromRGB(88, 101, 242),
            AIMessage = Color3.fromRGB(240, 240, 245),
            CodeBackground = Color3.fromRGB(235, 235, 245),
        },
        Midnight = {
            Background = Color3.fromRGB(10, 10, 20),
            Surface = Color3.fromRGB(20, 20, 35),
            SurfaceHover = Color3.fromRGB(30, 30, 50),
            Primary = Color3.fromRGB(139, 92, 246),
            PrimaryHover = Color3.fromRGB(159, 112, 255),
            Success = Color3.fromRGB(52, 211, 153),
            Warning = Color3.fromRGB(251, 191, 36),
            Error = Color3.fromRGB(248, 113, 113),
            Text = Color3.fromRGB(240, 240, 255),
            TextSecondary = Color3.fromRGB(180, 180, 200),
            TextMuted = Color3.fromRGB(120, 120, 140),
            Border = Color3.fromRGB(40, 40, 60),
            UserMessage = Color3.fromRGB(139, 92, 246),
            AIMessage = Color3.fromRGB(25, 25, 45),
            CodeBackground = Color3.fromRGB(15, 15, 30),
        },
        Ocean = {
            Background = Color3.fromRGB(15, 25, 35),
            Surface = Color3.fromRGB(25, 35, 50),
            SurfaceHover = Color3.fromRGB(35, 45, 65),
            Primary = Color3.fromRGB(56, 189, 248),
            PrimaryHover = Color3.fromRGB(76, 209, 255),
            Success = Color3.fromRGB(52, 211, 153),
            Warning = Color3.fromRGB(251, 191, 36),
            Error = Color3.fromRGB(248, 113, 113),
            Text = Color3.fromRGB(230, 240, 250),
            TextSecondary = Color3.fromRGB(160, 180, 200),
            TextMuted = Color3.fromRGB(100, 120, 140),
            Border = Color3.fromRGB(45, 60, 80),
            UserMessage = Color3.fromRGB(56, 189, 248),
            AIMessage = Color3.fromRGB(30, 40, 55),
            CodeBackground = Color3.fromRGB(20, 30, 45),
        },
        Sunset = {
            Background = Color3.fromRGB(30, 20, 25),
            Surface = Color3.fromRGB(45, 30, 35),
            SurfaceHover = Color3.fromRGB(60, 40, 45),
            Primary = Color3.fromRGB(244, 114, 182),
            PrimaryHover = Color3.fromRGB(254, 134, 192),
            Success = Color3.fromRGB(52, 211, 153),
            Warning = Color3.fromRGB(251, 191, 36),
            Error = Color3.fromRGB(248, 113, 113),
            Text = Color3.fromRGB(255, 230, 240),
            TextSecondary = Color3.fromRGB(200, 170, 180),
            TextMuted = Color3.fromRGB(140, 110, 120),
            Border = Color3.fromRGB(70, 50, 60),
            UserMessage = Color3.fromRGB(244, 114, 182),
            AIMessage = Color3.fromRGB(50, 35, 40),
            CodeBackground = Color3.fromRGB(35, 25, 30),
        },
    },
}

-- =====================================================================
-- РАЗДЕЛ 3: СОСТОЯНИЕ ПРИЛОЖЕНИЯ
-- =====================================================================

-- Глобальное состояние приложения
local AppState = {
    -- UI состояние
    IsChatOpen = false,
    IsWidgetVisible = true,
    CurrentTheme = "Dark",
    WidgetPosition = UDim2.new(0.9, -70, 0.9, -70),
    WindowPosition = UDim2.new(0.5, -250, 0.5, -325),
    
    -- Чат состояние
    ChatHistory = {},
    IsTyping = false,
    MessageCount = 0,
    
    -- Лимиты
    DailyRequests = 0,
    LastResetDate = "",
    LimitsEnabled = true,
    
    -- Игрок информация
    PlayerData = {
        Name = "",
        UserId = 0,
        DisplayName = "",
        Position = Vector3.new(0, 0, 0),
        Health = 100,
        MaxHealth = 100,
        WalkSpeed = 16,
        JumpPower = 50,
        Team = "",
        IsAlive = false,
        CharacterExists = false,
        Inventory = {},
        Tools = {},
        Leaderstats = {},
    },
    
    -- Игра информация
    GameData = {
        PlaceId = 0,
        GameId = 0,
        Name = "",
        Creator = "",
        CreatorId = 0,
        Description = "",
        MaxPlayers = 0,
        CurrentPlayers = 0,
        Genre = "",
        Created = "",
        Updated = "",
        Favorites = 0,
        Visits = 0,
        ServerSize = 0,
    },
    
    -- Настройки
    Settings = {
        SoundEnabled = true,
        AnimationsEnabled = true,
        AutoSave = true,
        ShowTimestamps = true,
        CompactMode = false,
    },
    
    -- Временные данные
    TempData = {
        LastScriptExecuted = "",
        LastCommandTime = 0,
        ErrorCount = 0,
        SuccessCount = 0,
    },
}

-- =====================================================================
-- РАЗДЕЛ 4: УТИЛИТЫ И ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- =====================================================================

-- Функция безопасного создания UI элементов
local function CreateUI(className, properties)
    local element = nil
    
    -- Проверка класса
    if className == "Frame" then
        element = Instance.new("Frame")
    elseif className == "TextLabel" then
        element = Instance.new("TextLabel")
    elseif className == "TextButton" then
        element = Instance.new("TextButton")
    elseif className == "TextBox" then
        element = Instance.new("TextBox")
    elseif className == "ImageLabel" then
        element = Instance.new("ImageLabel")
    elseif className == "ImageButton" then
        element = Instance.new("ImageButton")
    elseif className == "ScrollingFrame" then
        element = Instance.new("ScrollingFrame")
    elseif className == "ViewportFrame" then
        element = Instance.new("ViewportFrame")
    elseif className == "UICorner" then
        element = Instance.new("UICorner")
    elseif className == "UIStroke" then
        element = Instance.new("UIStroke")
    elseif className == "UIPadding" then
        element = Instance.new("UIPadding")
    elseif className == "UIListLayout" then
        element = Instance.new("UIListLayout")
    elseif className == "UIGradient" then
        element = Instance.new("UIGradient")
    elseif className == "ImageColorCorrection" then
        element = Instance.new("ImageColorCorrection")
    else
        element = Instance.new(className)
    end
    
    -- Применение свойств
    if properties then
        for prop, value in pairs(properties) do
            local success, err = pcall(function()
                element[prop] = value
            end)
            if not success then
                warn("[Kensa UI] Ошибка установки свойства " .. prop .. ": " .. tostring(err))
            end
        end
    end
    
    return element
end

-- Функция создания анимации
local function CreateAnimation(element, properties, duration, style)
    local tweenInfo = TweenInfo.new(
        duration or CONFIG.ANIMATION_SPEED,
        style or Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(element, tweenInfo, properties)
    tween:Play()
    
    return tween
end

-- Функция получения текущего времени
local function GetCurrentTime()
    local time = os.time()
    local date = os.date("*t", time)
    return string.format("%02d:%02d:%02d", date.hour, date.min, date.sec)
end

-- Функция получения текущей даты
local function GetCurrentDate()
    return os.date("%Y-%m-%d")
end

-- Функция форматирования чисел
local function FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

-- Функция обрезки строки
local function TruncateString(str, maxLength)
    if #str > maxLength then
        return string.sub(str, 1, maxLength - 3) .. "..."
    end
    return str
end

-- Функция проверки устройства
local function IsMobileDevice()
    local isTouch = UserInputService.TouchEnabled
    local isKeyboard = UserInputService.KeyboardEnabled
    local isMouse = UserInputService.MouseEnabled
    
    -- Мобильное устройство если есть тач и нет клавиатуры/мыши
    if isTouch and not isKeyboard and not isMouse then
        return true
    end
    
    -- Проверка размера экрана
    local viewportSize = Workspace.CurrentCamera.ViewportSize
    if viewportSize.X < 800 or viewportSize.Y < 600 then
        return true
    end
    
    return false
end

-- Функция получения размера экрана
local function GetScreenSize()
    local viewportSize = Workspace.CurrentCamera.ViewportSize
    return viewportSize.X, viewportSize.Y
end

-- =====================================================================
-- РАЗДЕЛ 5: СБОР ИНФОРМАЦИИ ОБ ИГРОКЕ
-- =====================================================================

-- Функция сбора полной информации об игроке
local function CollectPlayerData()
    local playerData = {}
    
    -- Базовая информация
    playerData.Name = LocalPlayer.Name
    playerData.UserId = LocalPlayer.UserId
    playerData.DisplayName = LocalPlayer.DisplayName or LocalPlayer.Name
    playerData.AccountAge = LocalPlayer.AccountAge
    playerData.MembershipType = tostring(LocalPlayer.MembershipType)
    
    -- Информация о персонаже
    local character = LocalPlayer.Character
    playerData.CharacterExists = character ~= nil
    playerData.IsAlive = false
    
    if character then
        -- HumanoidRootPart
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            playerData.Position = hrp.Position
            playerData.PositionString = string.format(
                "X: %.2f, Y: %.2f, Z: %.2f",
                hrp.Position.X,
                hrp.Position.Y,
                hrp.Position.Z
            )
            playerData.CFrame = hrp.CFrame
        else
            playerData.Position = Vector3.new(0, 0, 0)
            playerData.PositionString = "Недоступно"
        end
        
        -- Humanoid
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            playerData.Health = humanoid.Health
            playerData.MaxHealth = humanoid.MaxHealth
            playerData.WalkSpeed = humanoid.WalkSpeed
            playerData.JumpPower = humanoid.JumpPower
            playerData.JumpHeight = humanoid.JumpHeight
            playerData.IsAlive = humanoid.Health > 0
            playerData.HumanoidState = tostring(humanoid:GetState())
            playerData.PlatformStand = humanoid.PlatformStand
            playerData.Sit = humanoid.Sit
            playerData.Ragdoll = humanoid:GetState() == Enum.HumanoidStateType.Physics
        end
        
        -- Инструменты
        playerData.Tools = {}
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    table.insert(playerData.Tools, {
                        Name = tool.Name,
                        ClassName = tool.ClassName,
                        RequiresHandle = tool.RequiresHandle,
                    })
                end
            end
        end
        
        -- Character tools
        local characterTools = character:GetChildren()
        playerData.EquippedTools = {}
        for _, child in ipairs(characterTools) do
            if child:IsA("Tool") then
                table.insert(playerData.EquippedTools, child.Name)
            end
        end
        
        -- Accessories
        playerData.Accessories = {}
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Accessory") then
                table.insert(playerData.Accessories, child.Name)
            end
        end
        
        -- Clothing
        playerData.Clothing = {}
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
                table.insert(playerData.Clothing, {
                    Type = child.ClassName,
                    Name = child.Name,
                })
            end
        end
    end
    
    -- Команда
    if LocalPlayer.Team then
        playerData.Team = LocalPlayer.Team.Name
        playerData.TeamColor = tostring(LocalPlayer.Team.TeamColor)
    else
        playerData.Team = "Без команды"
        playerData.TeamColor = "N/A"
    end
    
    -- Leaderstats
    playerData.Leaderstats = {}
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if playerGui then
        -- Пытаемся найти leaderstats в PlayerGui
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, frame in ipairs(gui:GetDescendants()) do
                    if frame:IsA("TextLabel") and frame.Name:lower():find("stat") then
                        table.insert(playerData.Leaderstats, {
                            Name = frame.Name,
                            Value = frame.Text,
                        })
                    end
                end
            end
        end
    end
    
    -- Ping
    playerData.Ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    
    -- FPS
    playerData.FPS = math.floor(1 / RunService.RenderStepped:Wait())
    
    -- Время в игре
    playerData.TimeInGame = os.time() - (LocalPlayer.DataCost or 0)
    
    -- Сохраняем в состояние
    AppState.PlayerData = playerData
    
    return playerData
end

-- =====================================================================
-- РАЗДЕЛ 6: СБОР ИНФОРМАЦИИ ОБ ИГРЕ
-- =====================================================================

-- Функция сбора полной информации об игре
local function CollectGameData()
    local gameData = {}
    
    -- Базовая информация
    gameData.PlaceId = game.PlaceId
    gameData.GameId = game.GameId
    gameData.JobId = game.JobId
    
    -- Информация из MarketplaceService
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Game)
    end)
    
    if success and info then
        gameData.Name = info.Name
        gameData.Description = info.Description or "Описание недоступно"
        gameData.Creator = info.Creator.Name
        gameData.CreatorId = info.Creator.Id
        gameData.CreatorType = info.Creator.CreatorType
        gameData.Genre = tostring(info.Genre)
        gameData.MaxPlayers = info.MaxPlayers
        gameData.Created = info.Created
        gameData.Updated = info.Updated
        gameData.Favorites = info.FavoritedCount
        gameData.Visits = info.Visits
        gameData.Price = info.Price
    else
        gameData.Name = "Неизвестная игра"
        gameData.Description = "Не удалось получить информацию"
        gameData.Creator = "Неизвестно"
        gameData.CreatorId = 0
        gameData.CreatorType = "Unknown"
        gameData.Genre = "Unknown"
        gameData.MaxPlayers = 0
        gameData.Created = "Unknown"
        gameData.Updated = "Unknown"
        gameData.Favorites = 0
        gameData.Visits = 0
        gameData.Price = 0
    end
    
    -- Текущие игроки
    gameData.CurrentPlayers = #Players:GetPlayers()
    gameData.ServerSize = gameData.CurrentPlayers
    
    -- Список игроков
    gameData.Players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        table.insert(gameData.Players, {
            Name = player.Name,
            DisplayName = player.DisplayName or player.Name,
            Team = player.Team and player.Team.Name or "Без команды",
            CharacterExists = player.Character ~= nil,
        })
    end
    
    -- Workspace информация
    gameData.WorkspaceChildren = #Workspace:GetChildren()
    gameData.TerrainExists = Workspace.Terrain ~= nil
    
    -- Lighting информация
    gameData.TimeOfDay = Lighting.TimeOfDay
    gameData.Brightness = Lighting.Brightness
    gameData.Ambient = tostring(Lighting.Ambient)
    gameData.OutdoorAmbient = tostring(Lighting.OutdoorAmbient)
    gameData.FogEnabled = Lighting.FogEnd > Lighting.FogStart
    gameData.FogColor = tostring(Lighting.FogColor)
    gameData.FogStart = Lighting.FogStart
    gameData.FogEnd = Lighting.FogEnd
    
    -- Сохраняем в состояние
    AppState.GameData = gameData
    
    return gameData
end

-- =====================================================================
-- РАЗДЕЛ 7: СИСТЕМА ЛИМИТОВ
-- =====================================================================

-- Функция проверки и обновления лимитов
local function CheckDailyLimits()
    local today = GetCurrentDate()
    
    -- Проверка необходимости сброса
    if AppState.LastResetDate ~= today then
        AppState.DailyRequests = 0
        AppState.LastResetDate = today
        print("[Kensa AI] Лимиты сброшены на новый день: " .. today)
    end
    
    -- Проверка превышения лимита
    if AppState.DailyRequests >= CONFIG.DAILY_LIMIT then
        return false, "Превышен дневной лимит запросов (" .. CONFIG.DAILY_LIMIT .. "). Попробуйте завтра."
    end
    
    return true, "OK"
end

-- Функция увеличения счетчика запросов
local function IncrementRequestCount()
    AppState.DailyRequests = AppState.DailyRequests + 1
    print("[Kensa AI] Запрос #" .. AppState.DailyRequests .. "/" .. CONFIG.DAILY_LIMIT)
end

-- Функция получения информации о лимитах
local function GetLimitsInfo()
    local remaining = CONFIG.DAILY_LIMIT - AppState.DailyRequests
    local percentage = (AppState.DailyRequests / CONFIG.DAILY_LIMIT) * 100
    
    return {
        Used = AppState.DailyRequests,
        Remaining = remaining,
        Total = CONFIG.DAILY_LIMIT,
        Percentage = string.format("%.1f", percentage),
        ResetDate = AppState.LastResetDate,
    }
end

-- =====================================================================
-- РАЗДЕЛ 8: СОЗДАНИЕ ВИДЖЕТА ЧАТА
-- =====================================================================

-- Создание главного ScreenGui
local MainScreenGui = CreateUI("ScreenGui", {
    Name = "KensaAIGui",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
    Parent = PlayerGui,
})

-- Создание виджета (кружочек)
local WidgetFrame = CreateUI("TextButton", {
    Name = "ChatWidget",
    Size = UDim2.new(0, CONFIG.WIDGET_SIZE, 0, CONFIG.WIDGET_SIZE),
    Position = AppState.WidgetPosition,
    BackgroundColor3 = Color3.fromRGB(88, 101, 242),
    BorderSizePixel = 0,
    Active = true,
    Draggable = false,
    Parent = MainScreenGui,
    Visible = true,
})

-- Скругление виджета
local WidgetCorner = CreateUI("UICorner", {
    CornerRadius = UDim.new(0.5, 0),
    Parent = WidgetFrame,
})

-- Тень виджета
local WidgetStroke = CreateUI("UIStroke", {
    Color = Color3.fromRGB(120, 130, 255),
    Thickness = 2,
    Transparency = 0.3,
    Parent = WidgetFrame,
})

-- Градиент виджета
local WidgetGradient = CreateUI("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(139, 92, 246)),
    }),
    Rotation = 45,
    Parent = WidgetFrame,
})

-- Иконка чата на виджете (символ 💬)
local WidgetIcon = CreateUI("TextLabel", {
    Name = "WidgetIcon",
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "💬",
    TextSize = 28,
    Font = Enum.Font.SourceSansBold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Parent = WidgetFrame,
})

-- Индикатор уведомлений (красная точка)
local NotificationDot = CreateUI("Frame", {
    Name = "NotificationDot",
    Size = UDim2.new(0, 12, 0, 12),
    Position = UDim2.new(1, -6, 0, -6),
    BackgroundColor3 = Color3.fromRGB(239, 68, 68),
    BorderSizePixel = 0,
    Parent = WidgetFrame,
    Visible = false,
})

local NotificationCorner = CreateUI("UICorner", {
    CornerRadius = UDim.new(0.5, 0),
    Parent = NotificationDot,
})

-- =====================================================================
-- РАЗДЕЛ 9: ЛОГИКА ПЕРЕТАСКИВАНИЯ ВИДЖЕТА
-- =====================================================================

local widgetDragging = false
local widgetDragStart = Vector2.new(0, 0)
local widgetStartPosition = UDim2.new(0, 0, 0, 0)
local hasMoved = false

-- Начало перетаскивания
WidgetFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        widgetDragging = true
        hasMoved = false
        widgetDragStart = input.Position
        widgetStartPosition = WidgetFrame.Position
    end
end)

-- Процесс перетаскивания
UserInputService.InputChanged:Connect(function(input)
    if widgetDragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - widgetDragStart
            
            if delta.Magnitude > 5 then
                hasMoved = true
            end
            
            local newX = widgetStartPosition.X.Offset + delta.X
            local newY = widgetStartPosition.Y.Offset + delta.Y
            
            local screenWidth, screenHeight = GetScreenSize()
            newX = math.max(0, math.min(newX, screenWidth - CONFIG.WIDGET_SIZE))
            newY = math.max(0, math.min(newY, screenHeight - CONFIG.WIDGET_SIZE))
            
            WidgetFrame.Position = UDim2.new(0, newX, 0, newY)
            AppState.WidgetPosition = WidgetFrame.Position
        end
    end
end)

-- Завершение - просто сбрасываем флаг
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        widgetDragging = false
    end
end)

-- Добавляем ОТДЕЛЬНЫЙ обработчик для клика (после создания ChatWindow)
-- Это будет в РАЗДЕЛЕ 11 или позже

-- =====================================================================
-- РАЗДЕЛ 10: СОЗДАНИЕ ОСНОВНОГО ОКНА ЧАТА
-- =====================================================================

-- Основное окно чата
local ChatWindow = CreateUI("Frame", {
    Name = "ChatWindow",
    Size = UDim2.new(0, CONFIG.WINDOW_WIDTH, 0, CONFIG.WINDOW_HEIGHT),
    Position = AppState.WindowPosition,
    BackgroundColor3 = Color3.fromRGB(18, 18, 28),
    BorderSizePixel = 0,
    Active = true,
    Draggable = false,
    Parent = MainScreenGui,
    Visible = false,
})

-- Скругление окна
local WindowCorner = CreateUI("UICorner", {
    CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS),
    Parent = ChatWindow,
})

-- Обводка окна
local WindowStroke = CreateUI("UIStroke", {
    Color = Color3.fromRGB(45, 45, 65),
    Thickness = 2,
    Parent = ChatWindow,
})

-- Заголовок окна
local TitleBar = CreateUI("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Color3.fromRGB(28, 28, 42),
    BorderSizePixel = 0,
    Parent = ChatWindow,
})

-- Скругление заголовка
local TitleCorner = CreateUI("UICorner", {
    CornerRadius = UDim.new(0, CONFIG.CORNER_RADIUS),
    Parent = TitleBar,
})

-- Название в заголовке
local TitleLabel = CreateUI("TextLabel", {
    Name = "TitleLabel",
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = " Kensa AI Assistant",
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar,
})

-- Кнопка закрытия
local CloseButton = CreateUI("TextButton", {
    Name = "CloseButton",
    Size = UDim2.new(0, 36, 0, 36),
    Position = UDim2.new(1, -44, 0, 7),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    BorderSizePixel = 0,
    Text = "✕",
    TextSize = 16,
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Parent = TitleBar,
})

local CloseCorner = CreateUI("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = CloseButton,
})

-- Кнопка сворачивания
local MinimizeButton = CreateUI("TextButton", {
    Name = "MinimizeButton",
    Size = UDim2.new(0, 36, 0, 36),
    Position = UDim2.new(1, -88, 0, 7),
    BackgroundColor3 = Color3.fromRGB(60, 60, 80),
    BorderSizePixel = 0,
    Text = "−",
    TextSize = 20,
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Parent = TitleBar,
})

local MinimizeCorner = CreateUI("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = MinimizeButton,
})


-- =====================================================================
-- РАЗДЕЛ 10B: ОБРАБОТКА КЛИКА ПО ВИДЖЕТУ
-- =====================================================================

-- Теперь ChatWindow существует, можем использовать его
local function OpenChatFromWidget()
    if hasMoved then
        hasMoved = false
        return
    end
    
    print("[Kensa AI] Открываем чат из виджета!")
    AppState.IsChatOpen = true
    ChatWindow.Visible = true
    WidgetFrame.Visible = false
    
    task.delay(0.3, function()
        if MessageInput then
            MessageInput:CaptureFocus()
        end
    end)
end

-- Простой клик по виджету
WidgetFrame.MouseButton1Click:Connect(function()
    task.delay(0.1, function()
        if not widgetDragging and not hasMoved then
            OpenChatFromWidget()
        end
        hasMoved = false
    end)
end)

-- =====================================================================
-- РАЗДЕЛ 11: ЛОГИКА ПЕРЕТАСКИВАНИЯ ОКНА
-- =====================================================================

local windowDragging = false
local windowDragStart = Vector2.new(0, 0)
local windowStartPosition = UDim2.new(0, 0, 0, 0)

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        windowDragging = true
        windowDragStart = input.Position
        windowStartPosition = ChatWindow.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                windowDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if windowDragging then
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - windowDragStart
            
            local newX = windowStartPosition.X.Offset + delta.X
            local newY = windowStartPosition.Y.Offset + delta.Y
            
            local screenWidth, screenHeight = GetScreenSize()
            newX = math.max(0, math.min(newX, screenWidth - CONFIG.WINDOW_WIDTH))
            newY = math.max(0, math.min(newY, screenHeight - CONFIG.WINDOW_HEIGHT))
            
            ChatWindow.Position = UDim2.new(0, newX, 0, newY)
            AppState.WindowPosition = ChatWindow.Position
        end
    end
end)

-- Обработчики кнопок
CloseButton.MouseButton1Click:Connect(function()
    CloseChat()
end)

MinimizeButton.MouseButton1Click:Connect(function()
    MinimizeChat()
end)

-- =====================================================================
-- РАЗДЕЛ 12: ОБЛАСТЬ ЧАТА
-- =====================================================================

-- Контейнер для сообщений
local ChatContainer = CreateUI("ScrollingFrame", {
    Name = "ChatContainer",
    Size = UDim2.new(1, -20, 1, -160),
    Position = UDim2.new(0, 10, 0, 55),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 6,
    ScrollBarImageColor3 = Color3.fromRGB(88, 101, 242),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = ChatWindow,
})

-- Список сообщений
local ChatListLayout = CreateUI("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Parent = ChatContainer,
})

-- Отступы
local ChatPadding = CreateUI("UIPadding", {
    PaddingTop = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
    Parent = ChatContainer,
})

-- =====================================================================
-- РАЗДЕЛ 13: ОБЛАСТЬ ВВОДА
-- =====================================================================

-- Контейнер ввода
local InputContainer = CreateUI("Frame", {
    Name = "InputContainer",
    Size = UDim2.new(1, -20, 0, 100),
    Position = UDim2.new(0, 10, 1, -110),
    BackgroundColor3 = Color3.fromRGB(28, 28, 42),
    BorderSizePixel = 0,
    Parent = ChatWindow,
})

local InputCorner = CreateUI("UICorner", {
    CornerRadius = UDim.new(0, 10),
    Parent = InputContainer,
})

local InputStroke = CreateUI("UIStroke", {
    Color = Color3.fromRGB(45, 45, 65),
    Thickness = 1,
    Parent = InputContainer,
})

-- Поле ввода текста
local MessageInput = CreateUI("TextBox", {
    Name = "MessageInput",
    Size = UDim2.new(1, -60, 0, 50),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(18, 18, 28),
    BorderSizePixel = 0,
    PlaceholderText = "Напишите сообщение или команду (/help)...",
    Text = "",
    TextSize = 14,
    Font = Enum.Font.Gotham,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    PlaceholderColor3 = Color3.fromRGB(120, 120, 140),
    ClearTextOnFocus = false,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Parent = InputContainer,
})

local MessageInputCorner = CreateUI("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = MessageInput,
})

local MessageInputPadding = CreateUI("UIPadding", {
    PaddingLeft = UDim.new(0, 12),
    PaddingRight = UDim.new(0, 12),
    PaddingTop = UDim.new(0, 8),
    Parent = MessageInput,
})

-- Кнопка отправки
local SendButton = CreateUI("TextButton", {
    Name = "SendButton",
    Size = UDim2.new(0, 44, 0, 44),
    Position = UDim2.new(1, -52, 0, 53),
    BackgroundColor3 = Color3.fromRGB(88, 101, 242),
    BorderSizePixel = 0,
    Text = "➤",
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Parent = InputContainer,
})

local SendCorner = CreateUI("UICorner", {
    CornerRadius = UDim.new(0, 8),
    Parent = SendButton,
})

-- =====================================================================
-- РАЗДЕЛ 14: ПАРСЕР MARKDOWN
-- =====================================================================

-- Функция парсинга Markdown в RichText
local function ParseMarkdownToRichText(text)
    if not text then return "" end
    
    local result = text
    
    -- Экранирование HTML
    result = string.gsub(result, "&", "&amp;")
    result = string.gsub(result, "<", "&lt;")
    result = string.gsub(result, ">", "&gt;")
    
    -- Блоки кода (многострочные)
    result = string.gsub(result, "```(%w*)\n(.-)```", function(lang, code)
        return '<font face="Code"><font color="#88ff88">' .. code .. '</font></font>'
    end)
    
    -- Инлайн код
    result = string.gsub(result, "`(.-)`", '<font face="Code"><font color="#88ff88">%1</font></font>')
    
    -- Жирный текст
    result = string.gsub(result, "%*%*(.-)%*%*", "<b>%1</b>")
    result = string.gsub(result, "__(.-)__", "<b>%1</b>")
    
    -- Курсив
    result = string.gsub(result, "%*(.-)%*", "<i>%1</i>")
    result = string.gsub(result, "_(.-)_", "<i>%1</i>")
    
    -- Зачеркнутый
    result = string.gsub(result, "~~(.-)~~", "<s>%1</s>")
    
    -- Заголовки
    result = string.gsub(result, "^### (.-)$", '<b><font size="16">%1</font></b>', 0)
    result = string.gsub(result, "^## (.-)$", '<b><font size="18">%1</font></b>', 0)
    result = string.gsub(result, "^# (.-)$", '<b><font size="20">%1</font></b>', 0)
    
    -- Списки
    result = string.gsub(result, "^%- (.-)$", "  • %1")
    result = string.gsub(result, "^%* (.-)$", "  • %1")
    result = string.gsub(result, "^(%d+)%.) (.-)$", "  %1. %2")
    
    -- Ссылки
    result = string.gsub(result, "%[(.-)%]%((.-)%)", '<font color="#56b4f5">%1</font>')
    
    -- Переносы строк
    result = string.gsub(result, "\n", "<br>")
    
    return result
end

-- =====================================================================
-- РАЗДЕЛ 15: СОЗДАНИЕ СООБЩЕНИЙ
-- =====================================================================

-- Функция создания сообщения пользователя
local function CreateUserMessage(text)
    local messageFrame = CreateUI("Frame", {
        Size = UDim2.new(0.85, 0, 0, 0),
        Position = UDim2.new(0.15, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(88, 101, 242),
        BorderSizePixel = 0,
        Parent = ChatContainer,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = AppState.MessageCount,
    })
    
    local messageCorner = CreateUI("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = messageFrame,
    })
    
    local messagePadding = CreateUI("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        Parent = messageFrame,
    })
    
    local messageLabel = CreateUI("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = messageFrame,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    
    AppState.MessageCount = AppState.MessageCount + 1
    
    -- Прокрутка вниз
    task.delay(0.1, function()
        ChatContainer.CanvasPosition = Vector2.new(0, ChatContainer.AbsoluteCanvasSize.Y)
    end)
    
    return messageFrame
end

-- Функция создания сообщения от AI
local function CreateAIMessage(text)
    local messageFrame = CreateUI("Frame", {
        Size = UDim2.new(0.85, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(35, 35, 50),
        BorderSizePixel = 0,
        Parent = ChatContainer,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = AppState.MessageCount,
    })
    
    local messageCorner = CreateUI("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = messageFrame,
    })
    
    local messageStroke = CreateUI("UIStroke", {
        Color = Color3.fromRGB(50, 50, 70),
        Thickness = 1,
        Parent = messageFrame,
    })
    
    local messagePadding = CreateUI("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14),
        Parent = messageFrame,
    })
    
    -- Заголовок AI
    local aiHeader = CreateUI("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "🤖 Kensa AI",
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.fromRGB(139, 92, 246),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = messageFrame,
    })
    
    -- Текст сообщения с Markdown
    local messageLabel = CreateUI("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = ParseMarkdownToRichText(text),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextColor3 = Color3.fromRGB(240, 240, 255),
        TextWrapped = true,
        RichText = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = messageFrame,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    
    AppState.MessageCount = AppState.MessageCount + 1
    
    -- Прокрутка вниз
    task.delay(0.1, function()
        ChatContainer.CanvasPosition = Vector2.new(0, ChatContainer.AbsoluteCanvasSize.Y)
    end)
    
    return messageFrame
end

-- Функция создания системного сообщения
local function CreateSystemMessage(text, messageType)
    local colors = {
        info = Color3.fromRGB(56, 189, 248),
        success = Color3.fromRGB(52, 211, 153),
        warning = Color3.fromRGB(251, 191, 36),
        error = Color3.fromRGB(248, 113, 113),
    }
    
    local icons = {
        info = "ℹ️",
        success = "✅",
        warning = "⚠️",
        error = "",
    }
    
    local messageFrame = CreateUI("Frame", {
        Size = UDim2.new(0.9, 0, 0, 0),
        Position = UDim2.new(0.05, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(25, 25, 40),
        BorderSizePixel = 0,
        Parent = ChatContainer,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = AppState.MessageCount,
    })
    
    local messageCorner = CreateUI("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = messageFrame,
    })
    
    local messageStroke = CreateUI("UIStroke", {
        Color = colors[messageType] or colors.info,
        Thickness = 1,
        Parent = messageFrame,
    })
    
    local messagePadding = CreateUI("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = messageFrame,
    })
    
    local messageLabel = CreateUI("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = icons[messageType] .. " " .. text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextColor3 = colors[messageType] or colors.info,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = messageFrame,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    
    AppState.MessageCount = AppState.MessageCount + 1
    
    task.delay(0.1, function()
        ChatContainer.CanvasPosition = Vector2.new(0, ChatContainer.AbsoluteCanvasSize.Y)
    end)
    
    return messageFrame
end

-- =====================================================================
-- РАЗДЕЛ 16: AI API ИНТЕГРАЦИЯ
-- =====================================================================

-- Функция отправки запроса к AI API
local function SendAIRequest(userMessage, callback)
    -- Проверка лимитов
    local allowed, limitMessage = CheckDailyLimits()
    if not allowed then
        callback(limitMessage)
        return
    end
    
    -- Сбор данных
    local playerData = CollectPlayerData()
    local gameData = CollectGameData()
    
    -- Формирование контекста
    local contextInfo = string.format([[
ИНФОРМАЦИЯ ОБ ИГРОКЕ:
- Имя: %s
- DisplayName: %s
- UserId: %d
- Возраст аккаунта: %d дней
- Тип подписки: %s
- Позиция: %s
- Здоровье: %.0f/%.0f
- Скорость ходьбы: %d
- Сила прыжка: %d
- Команда: %s
- Жив: %s
- Персонаж существует: %s
- Инструменты: %s
- Пинг: %d мс

ИНФОРМАЦИЯ ОБ ИГРЕ:
- Название: %s
- PlaceId: %d
- GameId: %d
- Создатель: %s
- Описание: %s
- Жанр: %s
- Максимум игроков: %d
- Текущих игроков: %d
- Избранное: %d
- Визиты: %d
- Время суток: %s
- Яркость: %.2f
- Туман: %s
]],
        playerData.Name,
        playerData.DisplayName,
        playerData.UserId,
        playerData.AccountAge,
        playerData.MembershipType,
        playerData.PositionString,
        playerData.Health,
        playerData.MaxHealth,
        playerData.WalkSpeed,
        playerData.JumpPower,
        playerData.Team,
        tostring(playerData.IsAlive),
        tostring(playerData.CharacterExists),
        #playerData.Tools > 0 and table.concat(playerData.Tools, ", ") or "Нет",
        playerData.Ping,
        gameData.Name,
        gameData.PlaceId,
        gameData.GameId,
        gameData.Creator,
        TruncateString(gameData.Description, 200),
        gameData.Genre,
        gameData.MaxPlayers,
        gameData.CurrentPlayers,
        gameData.Favorites,
        gameData.Visits,
        gameData.TimeOfDay,
        gameData.Brightness,
        tostring(gameData.FogEnabled)
    )
    
    -- Системный промпт
    local systemPrompt = string.format([[
Ты - Kensa AI, продвинутый AI-ассистент для платформы Roblox, созданный разработчиком @Kensa.

ТВОИ ВОЗМОЖНОСТИ:
1. Отвечать на вопросы об играх Roblox
2. Давать советы по прохождению игр
3. Объяснять игровые механики
4. Генерировать и выполнять Luau-скрипты для помощи игроку
5. Предоставлять информацию об игроке и игре
6. Помогать с навигацией и настройками

ПРАВИЛА ГЕНЕРАЦИИ СКРИПТОВ:
Когда пользователь просит выполнить действие (например, "пройти 15 шагов", "увеличить скорость", "показать аватар"), ты должен создать Luau-скрипт и обернуть его в специальный формат:

[SCRIPT_BEGIN]
-- Твой Luau код здесь
local Players = game:GetService("Players")
local player = Players.LocalPlayer
-- ... код ...
[SCRIPT_END]

ПРИМЕРЫ СКРИПТОВ:

1. Прыжок:
[SCRIPT_BEGIN]
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character
if character then
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Jump = true
    end
end
[SCRIPT_END]

2. Изменение скорости:
[SCRIPT_BEGIN]
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character
if character then
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 25
    end
end
[SCRIPT_END]

3. Движение вперед:
[SCRIPT_BEGIN]
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character
if character then
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if hrp and humanoid then
        local direction = hrp.CFrame.LookVector
        humanoid:Move(direction * 15, true)
    end
end
[SCRIPT_END]

4. Телепортация к игроку:
[SCRIPT_BEGIN]
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local targetPlayer = Players:FindFirstChild("ИМЯ_ИГРОКА")
if targetPlayer and targetPlayer.Character then
    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp and myHrp then
        myHrp.CFrame = hrp.CFrame + Vector3.new(0, 0, 3)
    end
end
[SCRIPT_END]

5. Показать аватар:
[SCRIPT_BEGIN]
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local userId = player.UserId
local url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. userId .. "&size=150x150&format=Png"
local success, result = pcall(function()
    local response = HttpService:GetAsync(url)
    local data = HttpService:JSONDecode(response)
    if data.data and data.data[1] then
        return data.data[1].imageUrl
    end
    return nil
end)
if success and result then
    print("Avatar URL: " .. result)
end
[SCRIPT_END]

ВАЖНЫЕ ПРАВИЛА:
1. ВСЕГДА используй pcall для безопасного выполнения кода
2. ВСЕГДА проверяй существование объектов перед обращением
3. НЕ создавай вредоносные скрипты (читы, ESP, Aimbot, Fling и т.д.)
4. НЕ нарушай правила Roblox
5. Отвечай на русском языке
6. Используй Markdown для форматирования ответов
7. Если действие невозможно, объясни почему

КОНТЕКСТ:
%s

Если пользователь использует команду /help, покажи список всех доступных команд.
Если пользователь использует команду /stats, покажи полную статистику игрока.
Если пользователь использует команду /game, покажи информацию об игре.
Если пользователь использует команду /clear, ответь "CLEAR_CHAT".
Если пользователь использует команду /limits, покажи информацию о лимитах.
]], contextInfo)
    
    -- Формирование сообщений
    local messages = {
        { role = "system", content = systemPrompt }
    }
    
    -- Добавление истории
    local historyStart = math.max(1, #AppState.ChatHistory - 19)
    for i = historyStart, #AppState.ChatHistory do
        table.insert(messages, AppState.ChatHistory[i])
    end
    
    table.insert(messages, { role = "user", content = userMessage })
    
    -- Тело запроса
    local requestBody = {
        model = CONFIG.AI_MODEL,
        messages = messages,
        max_tokens = CONFIG.MAX_TOKENS,
        temperature = CONFIG.TEMPERATURE,
        top_p = CONFIG.TOP_P,
    }
    
    -- Асинхронный HTTP запрос
    task.spawn(function()
        local success, response = pcall(function()
            local headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. CONFIG.API_KEY,
            }
            
            local httpResponse = HttpService:PostAsync(
                CONFIG.API_URL,
                HttpService:JSONEncode(requestBody),
                Enum.HttpContentType.ApplicationJson,
                false,
                headers
            )
            
            return HttpService:JSONDecode(httpResponse)
        end)
        
        if not success then
            callback("🔴 Ошибка соединения с AI:\n" .. tostring(response))
            return
        end
        
        if not response then
            callback("🔴 Пустой ответ от AI")
            return
        end
        
        if response.error then
            callback("🔴 Ошибка API: " .. (response.error.message or "Неизвестная ошибка"))
            return
        end
        
        if response.choices and #response.choices > 0 and response.choices[1].message then
            IncrementRequestCount()
            callback(response.choices[1].message.content)
        else
            callback(" Не удалось получить ответ от AI")
        end
    end)
end

-- =====================================================================
-- РАЗДЕЛ 17: ГЕНЕРАТОР И ИНЖЕКТОР СКРИПТОВ
-- =====================================================================

-- Функция извлечения скрипта из ответа AI
local function ExtractScriptFromResponse(response)
    local scriptBegin = response:find("%[SCRIPT_BEGIN%]")
    local scriptEnd = response:find("%[SCRIPT_END%]")
    
    if scriptBegin and scriptEnd then
        local scriptContent = response:sub(scriptBegin + 14, scriptEnd - 1)
        return scriptContent
    end
    
    return nil
end

-- Функция выполнения скрипта
local function ExecuteScript(scriptContent)
    if not scriptContent or scriptContent == "" then
        return false, "Пустой скрипт"
    end
    
    -- Сохраняем последний выполненный скрипт
    AppState.TempData.LastScriptExecuted = scriptContent
    
    -- Выполнение через loadstring
    local success, result = pcall(function()
        local func, err = loadstring(scriptContent)
        if not func then
            error("Ошибка компиляции: " .. tostring(err))
        end
        return func()
    end)
    
    if success then
        AppState.TempData.SuccessCount = AppState.TempData.SuccessCount + 1
        return true, "Скрипт успешно выполнен"
    else
        AppState.TempData.ErrorCount = AppState.TempData.ErrorCount + 1
        return false, "Ошибка выполнения: " .. tostring(result)
    end
end

-- Функция обработки ответа AI
local function ProcessAIResponse(response, callback)
    -- Проверка на специальные команды
    if response == "CLEAR_CHAT" then
        ClearChat()
        callback("Чат очищен")
        return
    end
    
    -- Извлечение скрипта
    local scriptContent = ExtractScriptFromResponse(response)
    
    if scriptContent then
        -- Выполнение скрипта
        local success, message = ExecuteScript(scriptContent)
        
        if success then
            callback(response .. "\n\n✅ Скрипт успешно выполнен!")
        else
            callback(response .. "\n\n⚠️ Ошибка при выполнении скрипта:\n" .. message)
        end
    else
        callback(response)
    end
end

-- =====================================================================
-- РАЗДЕЛ 18: ВСТРОЕННЫЕ КОМАНДЫ
-- =====================================================================

-- Обработчик встроенных команд
local function HandleBuiltInCommands(message)
    local command = message:lower():gsub("^/", "")
    
    if command == "help" then
        return [[
 **Список команд Kensa AI**

**Общие команды:**
- `/help` - Показать этот список команд
- `/clear` - Очистить чат
- `/stats` - Показать статистику игрока
- `/game` - Показать информацию об игре
- `/limits` - Показать информацию о лимитах
- `/avatar` - Показать ваш аватар
- `/players` - Список игроков на сервере
- `/tools` - Показать ваши инструменты
- `/position` - Показать вашу позицию
- `/theme <название>` - Сменить тему (Dark/Light/Midnight/Ocean/Sunset)
- `/reset` - Сбросить счетчики
- `/about` - Информация о Kensa AI

**Примеры запросов к AI:**
- "Сделай чтобы мой персонаж прыгнул"
- "Увеличь скорость ходьбы до 25"
- "Пройди 15 шагов вперед"
- "Покажи мой аватар"
- "Как пройти этот уровень?"
- "Какие есть секреты в этой игре?"
- "Телепортируй меня к игроку [имя]"

**Ограничения:**
- Дневной лимит: 100 запросов
- AI не создает вредоносные скрипты
- Все действия должны соответствовать правилам Roblox

Напишите любой вопрос или команду, и я помогу! 🚀
]]
    elseif command == "clear" then
        ClearChat()
        return "✅ Чат очищен"
    elseif command == "stats" then
        local playerData = CollectPlayerData()
        return string.format([[
📊 **Статистика игрока**

**Основная информация:**
- Имя: %s
- DisplayName: %s
- UserId: %d
- Возраст аккаунта: %d дней
- Подписка: %s

**Персонаж:**
- Позиция: %s
- Здоровье: %.0f/%.0f
- Скорость: %d
- Прыжок: %d
- Состояние: %s
- Жив: %s

**Инструменты:** %s
**Пинг:** %d мс
        ]],
            playerData.Name,
            playerData.DisplayName,
            playerData.UserId,
            playerData.AccountAge,
            playerData.MembershipType,
            playerData.PositionString,
            playerData.Health,
            playerData.MaxHealth,
            playerData.WalkSpeed,
            playerData.JumpPower,
            playerData.HumanoidState or "N/A",
            tostring(playerData.IsAlive),
            #playerData.Tools > 0 and table.concat(playerData.Tools, ", ") or "Нет",
            playerData.Ping
        )
    elseif command == "game" then
        local gameData = CollectGameData()
        return string.format([[
🎮 **Информация об игре**

**Основное:**
- Название: %s
- PlaceId: %d
- GameId: %d
- JobId: %s

**Создатель:**
- Имя: %s
- ID: %d
- Тип: %s

**Статистика:**
- Жанр: %s
- Макс. игроков: %d
- Текущих игроков: %d
- Избранное: %s
- Визиты: %s

**Описание:**
%s

**Окружение:**
- Время: %s
- Яркость: %.2f
- Туман: %s
        ]],
            gameData.Name,
            gameData.PlaceId,
            gameData.GameId,
            gameData.JobId,
            gameData.Creator,
            gameData.CreatorId,
            gameData.CreatorType,
            gameData.Genre,
            gameData.MaxPlayers,
            gameData.CurrentPlayers,
            FormatNumber(gameData.Favorites),
            FormatNumber(gameData.Visits),
            TruncateString(gameData.Description, 300),
            gameData.TimeOfDay,
            gameData.Brightness,
            tostring(gameData.FogEnabled)
        )
    elseif command == "limits" then
        local limits = GetLimitsInfo()
        return string.format([[
 **Информация о лимитах**

- Использовано: %d / %d
- Осталось: %d
- Процент использования: %s%%
- Дата сброса: %s

Лимиты сбрасываются каждый день в полночь.
        ]],
            limits.Used,
            limits.Total,
            limits.Remaining,
            limits.Percentage,
            limits.ResetDate
        )
    elseif command == "avatar" then
        local userId = LocalPlayer.UserId
        local url = string.format(
            "%s?userIds=%d&size=%s&format=%s",
            CONFIG.AVATAR_API_URL,
            userId,
            CONFIG.AVATAR_SIZE,
            CONFIG.AVATAR_FORMAT
        )
        
        local success, result = pcall(function()
            local response = HttpService:GetAsync(url)
            local data = HttpService:JSONDecode(response)
            if data.data and data.data[1] then
                return data.data[1].imageUrl
            end
            return nil
        end)
        
        if success and result then
            return "📷 **Ваш аватар:**\n\n" .. result
        else
            return "⚠️ Не удалось получить аватар"
        end
    elseif command == "players" then
        local players = Players:GetPlayers()
        local playerList = {}
        for _, player in ipairs(players) do
            local team = player.Team and player.Team.Name or "Без команды"
            local alive = player.Character and "✅" or ""
            table.insert(playerList, string.format("- %s [%s] %s", player.Name, team, alive))
        end
        
        return "👥 **Игроки на сервере** (" .. #players .. "):\n\n" .. table.concat(playerList, "\n")
    elseif command == "tools" then
        local playerData = CollectPlayerData()
        if #playerData.Tools > 0 then
            local toolList = {}
            for _, tool in ipairs(playerData.Tools) do
                table.insert(toolList, "- " .. tool.Name)
            end
            return " **Ваши инструменты:**\n\n" .. table.concat(toolList, "\n")
        else
            return "🎒 У вас нет инструментов"
        end
    elseif command == "position" then
        local playerData = CollectPlayerData()
        return string.format("📍 **Ваша позиция:**\n\n%s", playerData.PositionString)
    elseif command:find("^theme ") then
        local themeName = message:sub(8)
        if CONFIG.THEMES[themeName] then
            ApplyTheme(themeName)
            return "🎨 Тема изменена на: " .. themeName
        else
            local themes = {}
            for name, _ in pairs(CONFIG.THEMES) do
                table.insert(themes, name)
            end
            return "⚠️ Неизвестная тема. Доступные: " .. table.concat(themes, ", ")
        end
    elseif command == "reset" then
        AppState.TempData.ErrorCount = 0
        AppState.TempData.SuccessCount = 0
        return "✅ Счетчики сброшены"
    elseif command == "about" then
        return [[
🤖 **О Kensa AI**

**Версия:** 2.0.0
**Разработчик:** @Kensa
**Модель AI:** mistral-small-latest

**Возможности:**
- AI-ассистент для Roblox
- Генерация и выполнение скриптов
- Адаптивный интерфейс
- Виджет чата
- Встроенные команды
- Дневные лимиты

**Контакты:**
Разработчик: @Kensa

Создано с ❤️ для сообщества Roblox
        ]]
    end
    
    return nil
end

-- =====================================================================
-- РАЗДЕЛ 19: УПРАВЛЕНИЕ ЧАТОМ
-- =====================================================================

-- Функция открытия чата
local function OpenChat()
    if AppState.IsChatOpen then return end
    
    AppState.IsChatOpen = true
    ChatWindow.Visible = true
    WidgetFrame.Visible = false
    
    -- Анимация появления
    ChatWindow.Size = UDim2.new(0, CONFIG.WINDOW_WIDTH * 0.9, 0, CONFIG.WINDOW_HEIGHT * 0.9)
    ChatWindow.Position = UDim2.new(
        0.5 - (CONFIG.WINDOW_WIDTH * 0.9) / 2,
        AppState.WindowPosition.X.Offset,
        0.5 - (CONFIG.WINDOW_HEIGHT * 0.9) / 2,
        AppState.WindowPosition.Y.Offset
    )
    
    CreateAnimation(ChatWindow, {
        Size = UDim2.new(0, CONFIG.WINDOW_WIDTH, 0, CONFIG.WINDOW_HEIGHT),
        Position = AppState.WindowPosition,
    }, 0.3, Enum.EasingStyle.Back)
    
    -- Фокус на поле ввода
    task.delay(0.3, function()
        MessageInput:CaptureFocus()
    end)
end

-- Функция закрытия чата
local function CloseChat()
    if not AppState.IsChatOpen then return end
    
    AppState.IsChatOpen = false
    
    CreateAnimation(ChatWindow, {
        Size = UDim2.new(0, CONFIG.WINDOW_WIDTH * 0.9, 0, CONFIG.WINDOW_HEIGHT * 0.9),
    }, 0.2, Enum.EasingStyle.Quad)
    
    task.delay(0.2, function()
        ChatWindow.Visible = false
        WidgetFrame.Visible = true
    end)
end

-- Функция сворачивания чата
local function MinimizeChat()
    CloseChat()
end

-- Функция очистки чата
local function ClearChat()
    for _, child in ipairs(ChatContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    AppState.ChatHistory = {}
    AppState.MessageCount = 0
end

-- Функция применения темы
local function ApplyTheme(themeName)
    local theme = CONFIG.THEMES[themeName]
    if not theme then return end
    
    AppState.CurrentTheme = themeName
    
    -- Применение цветов
    ChatWindow.BackgroundColor3 = theme.Background
    TitleBar.BackgroundColor3 = theme.Surface
    InputContainer.BackgroundColor3 = theme.Surface
    MessageInput.BackgroundColor3 = theme.Background
    SendButton.BackgroundColor3 = theme.Primary
    
    -- Обновление существующих сообщений
    for _, child in ipairs(ChatContainer:GetChildren()) do
        if child:IsA("Frame") then
            -- Обновление цветов сообщений
        end
    end
end

-- =====================================================================
-- РАЗДЕЛ 20: ЛОГИКА ОТПРАВКИ СООБЩЕНИЙ
-- =====================================================================

-- Функция отправки сообщения
local function SendMessage()
    local text = MessageInput.Text:gsub("^%s*(.-)%s*$", "%1")
    if text == "" then return end
    
    -- Добавление сообщения пользователя
    CreateUserMessage(text)
    table.insert(AppState.ChatHistory, { role = "user", content = text })
    MessageInput.Text = ""
    
    -- Проверка на встроенные команды
    if text:sub(1, 1) == "/" then
        local response = HandleBuiltInCommands(text)
        if response then
            task.delay(0.3, function()
                CreateAIMessage(response)
                table.insert(AppState.ChatHistory, { role = "assistant", content = response })
            end)
            return
        end
    end
    
    -- Индикатор набора
    local typingMessage = CreateAIMessage("🤔 Думаю...")
    AppState.IsTyping = true
    
    -- Отправка запроса к AI
    SendAIRequest(text, function(response)
        typingMessage:Destroy()
        AppState.IsTyping = false
        
        -- Обработка ответа
        ProcessAIResponse(response, function(finalResponse)
            CreateAIMessage(finalResponse)
            table.insert(AppState.ChatHistory, { role = "assistant", content = finalResponse })
        end)
    end)
end

-- Обработчики событий ввода
SendButton.MouseButton1Click:Connect(function()
    SendMessage()
end)

MessageInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        SendMessage()
    end
end)

-- =====================================================================
-- РАЗДЕЛ 21: ПРИВЕТСТВЕННОЕ СООБЩЕНИЕ
-- =====================================================================

-- Функция показа приветственного сообщения
local function ShowWelcomeMessage()
    task.wait(0.5)
    
    local welcomeText = [[
👋 **Добро пожаловать в Kensa AI!**

Я ваш AI-ассистент для Roblox, созданный разработчиком **@Kensa**.

 **Начало работы:**
- Напишите любой вопрос или запрос
- Используйте `/help` для списка команд
- Попросите меня выполнить действие (я создам и запущу скрипт)

💡 **Примеры запросов:**
- "Сделай чтобы мой персонаж прыгнул"
- "Увеличь скорость до 25"
- "Покажи статистику"
- "Какие игроки на сервере?"

⚠️ **Ограничения:**
- 100 запросов в день
- Не создаю вредоносные скрипты
- Все действия в рамках правил Roblox

Напишите что-нибудь, чтобы начать! ✨
    ]]
    
    CreateAIMessage(welcomeText)
    table.insert(AppState.ChatHistory, { role = "assistant", content = welcomeText })
end

-- =====================================================================
-- РАЗДЕЛ 22: ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ
-- =====================================================================

-- Функция обновления информации об игроке
local function UpdatePlayerInfo()
    task.spawn(function()
        while AppState.IsChatOpen do
            CollectPlayerData()
            task.wait(5)
        end
    end)
end

-- Функция проверки обновлений
local function CheckForUpdates()
    print("[Kensa AI] Версия 2.0.0 загружена")
    print("[Kensa AI] Разработчик: @Kensa")
end

-- Функция инициализации
local function Initialize()
    print("[Kensa AI] Инициализация...")
    
    -- Сбор начальных данных
    CollectPlayerData()
    CollectGameData()
    
    -- Проверка устройства
    local isMobile = IsMobileDevice()
    print("[Kensa AI] Мобильное устройство: " .. tostring(isMobile))
    
    -- Адаптация под мобильные устройства
    if isMobile then
        CONFIG.WINDOW_WIDTH = 350
        CONFIG.WINDOW_HEIGHT = 500
        CONFIG.WIDGET_SIZE = 50
        
        ChatWindow.Size = UDim2.new(0, CONFIG.WINDOW_WIDTH, 0, CONFIG.WINDOW_HEIGHT)
        ChatWindow.Position = UDim2.new(0.5, -CONFIG.WINDOW_WIDTH/2, 0.5, -CONFIG.WINDOW_HEIGHT/2)
        
        WidgetFrame.Size = UDim2.new(0, CONFIG.WIDGET_SIZE, 0, CONFIG.WIDGET_SIZE)
    end
    
    -- Запуск обновления информации
    UpdatePlayerInfo()
    
    -- Проверка обновлений
    CheckForUpdates()
    
    -- Показ приветственного сообщения
    ShowWelcomeMessage()
    
    print("[Kensa AI] Инициализация завершена")
end

-- =====================================================================
-- РАЗДЕЛ 23: ЗАПУСК
-- =====================================================================

-- Запуск инициализации
Initialize()

-- Обработчик уничтожения GUI
MainScreenGui.Destroying:Connect(function()
    print("[Kensa AI] GUI уничтожен")
    AppState.ChatHistory = {}
end)

-- =====================================================================
-- КОНЕЦ СКРИПТА
-- =====================================================================