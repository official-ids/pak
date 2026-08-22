--[[
    =====================================================================
    KENSA AI ASSISTANT - RAYFIELD EDITION
    Полнофункциональный AI-ассистент для платформы Roblox
    Разработчик: @Kensa
    Версия: 3.0.0
    UI библиотека: Rayfield
    =====================================================================
    
    ОПИСАНИЕ:
    Этот скрипт создает продвинутого AI-ассистента с использованием
    библиотеки Rayfield UI. Ассистент интегрирован с Mistral AI API
    и может генерировать и выполнять Lua-скрипты по запросу пользователя.
    
    ВОЗМОЖНОСТИ:
    - Интеграция с Mistral AI API
    - Генерация и выполнение скриптов
    - Сбор информации об игроке и игре
    - Встроенные команды
    - Дневные лимиты запросов
    - Красивый интерфейс Rayfield
    - Система уведомлений
    - История чата
    - Настройки тем
    
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
local CollectionService = game:GetService("CollectionService")

-- Получение локального игрока
local LocalPlayer = Players.LocalPlayer

-- Ожидание PlayerGui
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =====================================================================
-- РАЗДЕЛ 2: ЗАГРУЗКА RAYFIELD UI
-- =====================================================================

-- Загрузка библиотеки Rayfield
local Rayfield = nil

local success, errorMessage = pcall(function()
    Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not success then
    warn("[Kensa AI] Ошибка загрузки Rayfield: " .. tostring(errorMessage))
    -- Создание уведомления об ошибке
    local ErrorGui = Instance.new("ScreenGui")
    ErrorGui.Name = "KensaAIError"
    ErrorGui.ResetOnSpawn = false
    ErrorGui.Parent = PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 400, 0, 200)
    Frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Frame.BorderSizePixel = 0
    Frame.Parent = ErrorGui
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "Ошибка загрузки Rayfield"
    Title.TextColor3 = Color3.fromRGB(255, 100, 100)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Frame
    
    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(1, -20, 0, 100)
    Message.Position = UDim2.new(0, 10, 0, 45)
    Message.BackgroundTransparency = 1
    Message.Text = "Детали: " .. tostring(errorMessage)
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.TextSize = 13
    Message.Font = Enum.Font.Code
    Message.TextWrapped = true
    Message.Parent = Frame
    
    error("Rayfield не загружен: " .. errorMessage)
end

-- =====================================================================
-- РАЗДЕЛ 3: КОНФИГУРАЦИЯ ПРИЛОЖЕНИЯ
-- =====================================================================

-- Основная конфигурация
local CONFIG = {
    -- API настройки
    API_URL = "https://api.mistral.ai/v1/chat/completions",
    API_KEY = "v50l52LxJ2BzUK0C6W2nkkt3MNJ9Yova",
    AI_MODEL = "mistral-small-latest",
    MAX_TOKENS = 2048,
    TEMPERATURE = 0.75,
    TOP_P = 0.9,
    PRESENCE_PENALTY = 0.0,
    FREQUENCY_PENALTY = 0.0,
    
    -- Лимиты
    DAILY_LIMIT = 100,
    REQUEST_TIMEOUT = 30,
    MAX_HISTORY_SIZE = 50,
    
    -- API для аватаров
    AVATAR_API_URL = "https://thumbnails.roblox.com/v1/users/avatar-headshot",
    AVATAR_SIZE = "150x150",
    AVATAR_FORMAT = "Png",
    
    -- UI настройки
    DEFAULT_THEME = "Default",
    AUTO_SAVE_SETTINGS = false,
    SHOW_NOTIFICATIONS = true,
    NOTIFICATION_DURATION = 8,
    
    -- Скрипты
    SCRIPT_TIMEOUT = 10,
    MAX_SCRIPT_LENGTH = 5000,
}

-- =====================================================================
-- РАЗДЕЛ 4: СОСТОЯНИЕ ПРИЛОЖЕНИЯ
-- =====================================================================

-- Глобальное состояние
local AppState = {
    -- Чат
    ChatHistory = {},
    CurrentMessage = "",
    IsTyping = false,
    MessageCount = 0,
    
    -- Лимиты
    DailyRequests = 0,
    LastResetDate = "",
    TotalRequests = 0,
    SuccessCount = 0,
    ErrorCount = 0,
    
    -- Игрок
    PlayerData = {
        Name = "",
        UserId = 0,
        DisplayName = "",
        AccountAge = 0,
        MembershipType = "",
        Position = "",
        Health = 0,
        MaxHealth = 0,
        WalkSpeed = 0,
        JumpPower = 0,
        Team = "",
        IsAlive = false,
        CharacterExists = false,
        Ping = 0,
        FPS = 0,
    },
    
    -- Игра
    GameData = {
        PlaceId = 0,
        GameId = 0,
        JobId = "",
        Name = "",
        Creator = "",
        CreatorId = 0,
        Description = "",
        MaxPlayers = 0,
        CurrentPlayers = 0,
        Favorites = 0,
        Visits = 0,
    },
    
    -- Настройки
    Settings = {
        SoundEnabled = true,
        NotificationsEnabled = true,
        AutoCollectInfo = true,
        DebugMode = false,
    },
    
    -- Временные данные
    TempData = {
        LastScriptExecuted = "",
        LastCommandTime = 0,
        SessionStartTime = os.time(),
    },
}

-- =====================================================================
-- РАЗДЕЛ 5: УТИЛИТЫ И ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- =====================================================================

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
    if not num then return "0" end
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
    if not str then return "" end
    if #str > maxLength then
        return string.sub(str, 1, maxLength - 3) .. "..."
    end
    return str
end

-- Функция безопасного JSON декодирования
local function SafeJSONDecode(str)
    local success, result = pcall(function()
        return HttpService:JSONDecode(str)
    end)
    return success, result
end

-- Функция безопасного JSON кодирования
local function SafeJSONEncode(data)
    local success, result = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    return success, result
end

-- Функция логирования
local function Log(message, level)
    level = level or "INFO"
    local timestamp = GetCurrentTime()
    local logMessage = string.format("[Kensa AI] [%s] [%s] %s", timestamp, level, message)
    
    if AppState.Settings.DebugMode then
        print(logMessage)
    end
    
    -- Также пишем в warn для важных сообщений
    if level == "ERROR" or level == "WARN" then
        warn(logMessage)
    end
end

-- =====================================================================
-- РАЗДЕЛ 6: СИСТЕМА ЛИМИТОВ
-- =====================================================================

-- Функция проверки и обновления лимитов
local function CheckDailyLimits()
    local today = GetCurrentDate()
    
    -- Проверка необходимости сброса
    if AppState.LastResetDate ~= today then
        AppState.DailyRequests = 0
        AppState.LastResetDate = today
        Log("Лимиты сброшены на новый день: " .. today, "INFO")
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
    AppState.TotalRequests = AppState.TotalRequests + 1
    Log("Запрос #" .. AppState.DailyRequests .. "/" .. CONFIG.DAILY_LIMIT, "INFO")
end

-- Функция получения информации о лимитах
local function GetLimitsInfo()
    local remaining = CONFIG.DAILY_LIMIT - AppState.DailyRequests
    local percentage = 0
    if CONFIG.DAILY_LIMIT > 0 then
        percentage = (AppState.DailyRequests / CONFIG.DAILY_LIMIT) * 100
    end
    
    return {
        Used = AppState.DailyRequests,
        Remaining = remaining,
        Total = CONFIG.DAILY_LIMIT,
        Percentage = string.format("%.1f", percentage),
        ResetDate = AppState.LastResetDate,
        TotalRequests = AppState.TotalRequests,
        SuccessCount = AppState.SuccessCount,
        ErrorCount = AppState.ErrorCount,
    }
end

-- =====================================================================
-- РАЗДЕЛ 7: СБОР ИНФОРМАЦИИ ОБ ИГРОКЕ
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
            playerData.Position = string.format(
                "X: %.2f, Y: %.2f, Z: %.2f",
                hrp.Position.X,
                hrp.Position.Y,
                hrp.Position.Z
            )
            playerData.CFrame = hrp.CFrame
        else
            playerData.Position = "Недоступно"
        end
        
        -- Humanoid
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            playerData.Health = math.floor(humanoid.Health)
            playerData.MaxHealth = humanoid.MaxHealth
            playerData.WalkSpeed = humanoid.WalkSpeed
            playerData.JumpPower = humanoid.JumpPower
            playerData.JumpHeight = humanoid.JumpHeight
            playerData.IsAlive = humanoid.Health > 0
            playerData.HumanoidState = tostring(humanoid:GetState())
            playerData.PlatformStand = humanoid.PlatformStand
            playerData.Sit = humanoid.Sit
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
                    })
                end
            end
        end
        
        -- Экипированные инструменты
        playerData.EquippedTools = {}
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then
                table.insert(playerData.EquippedTools, child.Name)
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
    
    -- Ping
    local success, ping = pcall(function()
        return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    playerData.Ping = success and math.floor(ping) or 0
    
    -- Сохраняем в состояние
    AppState.PlayerData = playerData
    
    Log("Информация об игроке обновлена", "INFO")
    return playerData
end

-- =====================================================================
-- РАЗДЕЛ 8: СБОР ИНФОРМАЦИИ ОБ ИГРЕ
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
    
    -- Сохраняем в состояние
    AppState.GameData = gameData
    
    Log("Информация об игре обновлена: " .. gameData.Name, "INFO")
    return gameData
end

-- =====================================================================
-- РАЗДЕЛ 9: AI API ИНТЕГРАЦИЯ
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
- Здоровье: %d/%d
- Скорость ходьбы: %d
- Сила прыжка: %d
- Команда: %s
- Жив: %s
- Персонаж существует: %s
- Ping: %d мс

ИНФОРМАЦИЯ ОБ ИГРЕ:
- Название: %s
- PlaceId: %d
- GameId: %d
- Создатель: %s
- Жанр: %s
- Максимум игроков: %d
- Текущих игроков: %d
- Избранное: %d
- Визиты: %d
]],
        playerData.Name,
        playerData.DisplayName,
        playerData.UserId,
        playerData.AccountAge,
        playerData.MembershipType,
        playerData.Position,
        playerData.Health,
        playerData.MaxHealth,
        playerData.WalkSpeed,
        playerData.JumpPower,
        playerData.Team,
        tostring(playerData.IsAlive),
        tostring(playerData.CharacterExists),
        playerData.Ping,
        gameData.Name,
        gameData.PlaceId,
        gameData.GameId,
        gameData.Creator,
        gameData.Genre,
        gameData.MaxPlayers,
        gameData.CurrentPlayers,
        gameData.Favorites,
        gameData.Visits
    )
    
    -- Системный промпт
    local systemPrompt = string.format([[
Ты - Kensa AI, продвинутый AI-ассистент для платформы Roblox, созданный разработчиком @Kensa.

ТВОИ ВОЗМОЖНОСТИ:
1. Отвечать на вопросы об играх Roblox
2. Давать советы по прохождению игр
3. Объяснять игровые механики
4. Генерировать и выполнять Lua-скрипты для помощи игроку
5. Предоставлять информацию об игроке и игре
6. Помогать с навигацией и настройками

ПРАВИЛА ГЕНЕРАЦИИ СКРИПТОВ:
Когда пользователь просит выполнить действие, создай Lua-скрипт и оберни его в специальный формат:

[SCRIPT_BEGIN]
-- Твой Lua код здесь
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

3. Показать аватар:
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
3. НЕ создавай вредоносные скрипты (читы, ESP, Aimbot и т.д.)
4. НЕ нарушай правила Roblox
5. Отвечай на русском языке
6. Если действие невозможно, объясни почему

КОНТЕКСТ:
%s

Если пользователь использует команду /help, покажи список всех доступных команд.
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
        presence_penalty = CONFIG.PRESENCE_PENALTY,
        frequency_penalty = CONFIG.FREQUENCY_PENALTY,
    }
    
    -- Асинхронный HTTP запрос
    task.spawn(function()
        Log("Отправка запроса к AI API...", "INFO")
        
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
            Log("Ошибка HTTP запроса: " .. tostring(response), "ERROR")
            callback("Ошибка соединения с AI: " .. tostring(response))
            AppState.ErrorCount = AppState.ErrorCount + 1
            return
        end
        
        if not response then
            Log("Пустой ответ от API", "ERROR")
            callback("Пустой ответ от AI")
            AppState.ErrorCount = AppState.ErrorCount + 1
            return
        end
        
        if response.error then
            Log("Ошибка API: " .. (response.error.message or "Неизвестная"), "ERROR")
            callback("Ошибка API: " .. (response.error.message or "Неизвестная ошибка"))
            AppState.ErrorCount = AppState.ErrorCount + 1
            return
        end
        
        if response.choices and #response.choices > 0 and response.choices[1].message then
            IncrementRequestCount()
            AppState.SuccessCount = AppState.SuccessCount + 1
            Log("Успешный ответ получен", "INFO")
            callback(response.choices[1].message.content)
        else
            Log("Неожиданная структура ответа", "ERROR")
            callback("Не удалось получить ответ от AI")
            AppState.ErrorCount = AppState.ErrorCount + 1
        end
    end)
end

-- =====================================================================
-- РАЗДЕЛ 10: ГЕНЕРАТОР И ИНЖЕКТОР СКРИПТОВ
-- =====================================================================

-- Функция извлечения скрипта из ответа AI
local function ExtractScriptFromResponse(response)
    if not response then return nil end
    
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
    
    -- Проверка длины
    if #scriptContent > CONFIG.MAX_SCRIPT_LENGTH then
        return false, "Скрипт слишком длинный (максимум " .. CONFIG.MAX_SCRIPT_LENGTH .. " символов)"
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
        Log("Скрипт успешно выполнен", "INFO")
        return true, "Скрипт успешно выполнен"
    else
        Log("Ошибка выполнения скрипта: " .. tostring(result), "ERROR")
        return false, "Ошибка выполнения: " .. tostring(result)
    end
end

-- Функция обработки ответа AI
local function ProcessAIResponse(response, callback)
    -- Извлечение скрипта
    local scriptContent = ExtractScriptFromResponse(response)
    
    if scriptContent then
        -- Выполнение скрипта
        local success, message = ExecuteScript(scriptContent)
        
        if success then
            callback(response .. "\n\n[Скрипт успешно выполнен]")
        else
            callback(response .. "\n\n[Ошибка при выполнении скрипта: " .. message .. "]")
        end
    else
        callback(response)
    end
end

-- =====================================================================
-- РАЗДЕЛ 11: ВСТРОЕННЫЕ КОМАНДЫ
-- =====================================================================

-- Обработчик встроенных команд
local function HandleBuiltInCommands(message)
    local command = message:lower():gsub("^/", "")
    
    if command == "help" then
        return [[
Список команд Kensa AI

Общие команды:
- /help - Показать этот список команд
- /clear - Очистить историю чата
- /stats - Показать статистику игрока
- /game - Показать информацию об игре
- /limits - Показать информацию о лимитах
- /avatar - Показать ваш аватар
- /players - Список игроков на сервере
- /tools - Показать ваши инструменты
- /position - Показать вашу позицию
- /reset - Сбросить счетчики
- /about - Информация о Kensa AI

Примеры запросов к AI:
- "Сделай чтобы мой персонаж прыгнул"
- "Увеличь скорость ходьбы до 25"
- "Покажи мой аватар"
- "Как пройти этот уровень?"
- "Какие есть секреты в этой игре?"

Ограничения:
- Дневной лимит: 100 запросов
- AI не создает вредоносные скрипты
- Все действия должны соответствовать правилам Roblox
]]
    elseif command == "clear" then
        AppState.ChatHistory = {}
        AppState.MessageCount = 0
        return "История чата очищена"
    elseif command == "stats" then
        local playerData = CollectPlayerData()
        return string.format([[
Статистика игрока

Основная информация:
- Имя: %s
- DisplayName: %s
- UserId: %d
- Возраст аккаунта: %d дней
- Подписка: %s

Персонаж:
- Позиция: %s
- Здоровье: %d/%d
- Скорость: %d
- Прыжок: %d
- Состояние: %s
- Жив: %s

Ping: %d мс
]],
            playerData.Name,
            playerData.DisplayName,
            playerData.UserId,
            playerData.AccountAge,
            playerData.MembershipType,
            playerData.Position,
            playerData.Health,
            playerData.MaxHealth,
            playerData.WalkSpeed,
            playerData.JumpPower,
            playerData.HumanoidState or "N/A",
            tostring(playerData.IsAlive),
            playerData.Ping
        )
    elseif command == "game" then
        local gameData = CollectGameData()
        return string.format([[
Информация об игре

Основное:
- Название: %s
- PlaceId: %d
- GameId: %d
- JobId: %s

Создатель:
- Имя: %s
- ID: %d
- Тип: %s

Статистика:
- Жанр: %s
- Макс. игроков: %d
- Текущих игроков: %d
- Избранное: %s
- Визиты: %s

Описание:
%s
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
            TruncateString(gameData.Description, 300)
        )
    elseif command == "limits" then
        local limits = GetLimitsInfo()
        return string.format([[
Информация о лимитах

- Использовано: %d / %d
- Осталось: %d
- Процент использования: %s%%
- Дата сброса: %s
- Всего запросов: %d
- Успешных: %d
- Ошибок: %d

Лимиты сбрасываются каждый день в полночь.
]],
            limits.Used,
            limits.Total,
            limits.Remaining,
            limits.Percentage,
            limits.ResetDate,
            limits.TotalRequests,
            limits.SuccessCount,
            limits.ErrorCount
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
            return "Ваш аватар:\n\n" .. result
        else
            return "Не удалось получить аватар"
        end
    elseif command == "players" then
        local players = Players:GetPlayers()
        local playerList = {}
        for _, player in ipairs(players) do
            local team = player.Team and player.Team.Name or "Без команды"
            local alive = player.Character and "[Жив]" or "[Мертв]"
            table.insert(playerList, string.format("- %s [%s] %s", player.Name, team, alive))
        end
        
        return "Игроки на сервере (" .. #players .. "):\n\n" .. table.concat(playerList, "\n")
    elseif command == "tools" then
        local playerData = CollectPlayerData()
        if #playerData.Tools > 0 then
            local toolList = {}
            for _, tool in ipairs(playerData.Tools) do
                table.insert(toolList, "- " .. tool.Name)
            end
            return "Ваши инструменты:\n\n" .. table.concat(toolList, "\n")
        else
            return "У вас нет инструментов"
        end
    elseif command == "position" then
        local playerData = CollectPlayerData()
        return "Ваша позиция:\n\n" .. playerData.Position
    elseif command == "reset" then
        AppState.ErrorCount = 0
        AppState.SuccessCount = 0
        AppState.TotalRequests = 0
        return "Счетчики сброшены"
    elseif command == "about" then
        return [[
О Kensa AI

Версия: 3.0.0
Разработчик: @Kensa
UI библиотека: Rayfield
AI модель: mistral-small-latest

Возможности:
- AI-ассистент для Roblox
- Генерация и выполнение скриптов
- Красивый интерфейс Rayfield
- Встроенные команды
- Дневные лимиты
- Сбор информации об игроке и игре

Контакты:
Разработчик: @Kensa

Создано для сообщества Roblox
]]
    end
    
    return nil
end

-- =====================================================================
-- РАЗДЕЛ 12: СОЗДАНИЕ ИНТЕРФЕЙСА RAYFIELD
-- =====================================================================

-- Создание главного окна
local Window = Rayfield:CreateWindow({
    Name = "Kensa AI Assistant",
    LoadingTitle = "Инициализация Kensa AI",
    LoadingSubtitle = "by @Kensa - Rayfield Edition",
    Theme = CONFIG.DEFAULT_THEME,
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = CONFIG.AUTO_SAVE_SETTINGS,
        FolderName = "KensaAI",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- Создание вкладок
local ChatTab = Window:CreateTab("AI Chat", 4483362458)
local InfoTab = Window:CreateTab("Information", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local AboutTab = Window:CreateTab("About", 4483362458)

-- =====================================================================
-- РАЗДЕЛ 13: ЧАТ ВКЛАДКА
-- =====================================================================

-- Секция чата
local ChatSection = ChatTab:CreateSection("Общение с AI")

-- Поле ввода сообщения
ChatTab:CreateTextBox({
    Name = "Введите сообщение",
    PlaceholderText = "Напишите вопрос или команду (/help)",
    Callback = function(Message)
        if Message == "" or Message == nil then return end
        
        Log("Пользователь отправил: " .. Message, "INFO")
        
        -- Проверка на встроенные команды
        if Message:sub(1, 1) == "/" then
            local response = HandleBuiltInCommands(Message)
            if response then
                if CONFIG.SHOW_NOTIFICATIONS then
                    Rayfield:Notify({
                        Title = "Kensa AI",
                        Content = response,
                        Duration = CONFIG.NOTIFICATION_DURATION,
                    })
                end
                return
            end
        end
        
        -- Отправка к AI
        if CONFIG.SHOW_NOTIFICATIONS then
            Rayfield:Notify({
                Title = "Kensa AI",
                Content = "Думаю...",
                Duration = 2,
            })
        end
        
        SendAIRequest(Message, function(response)
            ProcessAIResponse(response, function(finalResponse)
                if CONFIG.SHOW_NOTIFICATIONS then
                    Rayfield:Notify({
                        Title = "Kensa AI - Ответ",
                        Content = finalResponse,
                        Duration = CONFIG.NOTIFICATION_DURATION,
                    })
                end
                
                -- Сохранение в историю
                table.insert(AppState.ChatHistory, { role = "user", content = Message })
                table.insert(AppState.ChatHistory, { role = "assistant", content = finalResponse })
                
                -- Ограничение размера истории
                while #AppState.ChatHistory > CONFIG.MAX_HISTORY_SIZE do
                    table.remove(AppState.ChatHistory, 1)
                end
                
                AppState.MessageCount = AppState.MessageCount + 2
            end)
        end)
    end,
})

-- Секция быстрых действий
local QuickActionsSection = ChatTab:CreateSection("Быстрые действия")

-- Кнопка прыжка
ChatTab:CreateButton({
    Name = "Прыжок",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Jump = true
                Log("Выполнен прыжок", "INFO")
                if CONFIG.SHOW_NOTIFICATIONS then
                    Rayfield:Notify({
                        Title = "Действие выполнено",
                        Content = "Персонаж прыгнул",
                        Duration = 3,
                    })
                end
            end
        end
    end,
})

-- Кнопка увеличения скорости
ChatTab:CreateButton({
    Name = "Увеличить скорость (x2)",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                local newSpeed = humanoid.WalkSpeed * 2
                humanoid.WalkSpeed = math.min(newSpeed, 50)
                Log("Скорость изменена: " .. humanoid.WalkSpeed, "INFO")
                if CONFIG.SHOW_NOTIFICATIONS then
                    Rayfield:Notify({
                        Title = "Действие выполнено",
                        Content = "Скорость: " .. humanoid.WalkSpeed,
                        Duration = 3,
                    })
                end
            end
        end
    end,
})

-- Кнопка показа аватара
ChatTab:CreateButton({
    Name = "Показать аватар",
    Callback = function()
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
            if CONFIG.SHOW_NOTIFICATIONS then
                Rayfield:Notify({
                    Title = "Ваш аватар",
                    Content = result,
                    Duration = 10,
                })
            end
        else
            if CONFIG.SHOW_NOTIFICATIONS then
                Rayfield:Notify({
                    Title = "Ошибка",
                    Content = "Не удалось получить аватар",
                    Duration = 5,
                })
            end
        end
    end,
})

-- Кнопка телепортации на спавн
ChatTab:CreateButton({
    Name = "Телепорт на спавн",
    Callback = function()
        local character = LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(0, 10, 0)
                Log("Телепортация на спавн", "INFO")
                if CONFIG.SHOW_NOTIFICATIONS then
                    Rayfield:Notify({
                        Title = "Действие выполнено",
                        Content = "Телепортация на спавн",
                        Duration = 3,
                    })
                end
            end
        end
    end,
})

-- =====================================================================
-- РАЗДЕЛ 14: ВКЛАДКА ИНФОРМАЦИИ
-- =====================================================================

-- Секция игрока
local PlayerSection = InfoTab:CreateSection("Информация об игроке")

-- Функция обновления информации
local function UpdateInfoTab()
    local playerData = CollectPlayerData()
    local gameData = CollectGameData()
    
    -- Очистка старых лейблов (простой способ - пересоздание секции)
    -- В Rayfield нет метода очистки, поэтому просто добавляем новые
    
    InfoTab:CreateLabel({Name = "Имя: " .. playerData.Name})
    InfoTab:CreateLabel({Name = "DisplayName: " .. playerData.DisplayName})
    InfoTab:CreateLabel({Name = "UserId: " .. playerData.UserId})
    InfoTab:CreateLabel({Name = "Возраст: " .. playerData.AccountAge .. " дней"})
    InfoTab:CreateLabel({Name = "Подписка: " .. playerData.MembershipType})
    InfoTab:CreateLabel({Name = "Позиция: " .. playerData.Position})
    InfoTab:CreateLabel({Name = "Здоровье: " .. playerData.Health .. "/" .. playerData.MaxHealth})
    InfoTab:CreateLabel({Name = "Скорость: " .. playerData.WalkSpeed})
    InfoTab:CreateLabel({Name = "Прыжок: " .. playerData.JumpPower})
    InfoTab:CreateLabel({Name = "Команда: " .. playerData.Team})
    InfoTab:CreateLabel({Name = "Ping: " .. playerData.Ping .. " мс"})
    InfoTab:CreateLabel({Name = ""}) -- Пустая строка
    InfoTab:CreateLabel({Name = "Игра: " .. gameData.Name})
    InfoTab:CreateLabel({Name = "PlaceId: " .. gameData.PlaceId})
    InfoTab:CreateLabel({Name = "Игроков: " .. gameData.CurrentPlayers .. "/" .. gameData.MaxPlayers})
    InfoTab:CreateLabel({Name = "Создатель: " .. gameData.Creator})
end

-- Кнопка обновления
InfoTab:CreateButton({
    Name = "Обновить информацию",
    Callback = function()
        UpdateInfoTab()
        if CONFIG.SHOW_NOTIFICATIONS then
            Rayfield:Notify({
                Title = "Обновлено",
                Content = "Информация обновлена",
                Duration = 3,
            })
        end
    end,
})

-- =====================================================================
-- РАЗДЕЛ 15: ВКЛАДКА НАСТРОЕК
-- =====================================================================

-- Секция общих настроек
local GeneralSection = SettingsTab:CreateSection("Общие настройки")

-- Уведомления
SettingsTab:CreateToggle({
    Name = "Показывать уведомления",
    CurrentValue = AppState.Settings.NotificationsEnabled,
    Callback = function(Value)
        AppState.Settings.NotificationsEnabled = Value
        Log("Уведомления: " .. tostring(Value), "INFO")
    end,
})

-- Авто-сбор информации
SettingsTab:CreateToggle({
    Name = "Авто-сбор информации",
    CurrentValue = AppState.Settings.AutoCollectInfo,
    Callback = function(Value)
        AppState.Settings.AutoCollectInfo = Value
        Log("Авто-сбор: " .. tostring(Value), "INFO")
    end,
})

-- Debug режим
SettingsTab:CreateToggle({
    Name = "Debug режим",
    CurrentValue = AppState.Settings.DebugMode,
    Callback = function(Value)
        AppState.Settings.DebugMode = Value
        Log("Debug режим: " .. tostring(Value), "INFO")
    end,
})

-- Секция лимитов
local LimitsSection = SettingsTab:CreateSection("Лимиты API")

local limits = GetLimitsInfo()
SettingsTab:CreateLabel({Name = "Использовано: " .. limits.Used .. "/" .. limits.Total})
SettingsTab:CreateLabel({Name = "Осталось: " .. limits.Remaining})
SettingsTab:CreateLabel({Name = "Процент: " .. limits.Percentage .. "%%"})

-- Кнопка сброса статистики
SettingsTab:CreateButton({
    Name = "Сбросить статистику",
    Callback = function()
        AppState.DailyRequests = 0
        AppState.TotalRequests = 0
        AppState.SuccessCount = 0
        AppState.ErrorCount = 0
        if CONFIG.SHOW_NOTIFICATIONS then
            Rayfield:Notify({
                Title = "Готово",
                Content = "Статистика сброшена",
                Duration = 3,
            })
        end
    end,
})

-- =====================================================================
-- РАЗДЕЛ 16: ВКЛАДКА О ПРОГРАММЕ
-- =====================================================================

AboutTab:CreateSection("Информация о программе")

AboutTab:CreateLabel({Name = "Название: Kensa AI Assistant"})
AboutTab:CreateLabel({Name = "Версия: 3.0.0"})
AboutTab:CreateLabel({Name = "Разработчик: @Kensa"})
AboutTab:CreateLabel({Name = "UI библиотека: Rayfield"})
AboutTab:CreateLabel({Name = "AI модель: mistral-small-latest"})
AboutTab:CreateLabel({Name = ""})
AboutTab:CreateLabel({Name = "Возможности:"})
AboutTab:CreateLabel({Name = "- AI-ассистент для Roblox"})
AboutTab:CreateLabel({Name = "- Генерация и выполнение скриптов"})
AboutTab:CreateLabel({Name = "- Красивый интерфейс Rayfield"})
AboutTab:CreateLabel({Name = "- Встроенные команды"})
AboutTab:CreateLabel({Name = "- Дневные лимиты (100 запросов)"})
AboutTab:CreateLabel({Name = "- Сбор информации об игроке и игре"})
AboutTab:CreateLabel({Name = "- Система уведомлений"})
AboutTab:CreateLabel({Name = "- История чата"})
AboutTab:CreateLabel({Name = ""})
AboutTab:CreateLabel({Name = "Создано для сообщества Roblox"})

-- =====================================================================
-- РАЗДЕЛ 17: ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ
-- =====================================================================

-- Функция обновления информации об игроке (периодическая)
local function UpdatePlayerInfoLoop()
    task.spawn(function()
        while true do
            if AppState.Settings.AutoCollectInfo then
                CollectPlayerData()
                CollectGameData()
            end
            task.wait(30) -- Обновление каждые 30 секунд
        end
    end)
end

-- Функция приветствия
local function ShowWelcomeMessage()
    task.delay(1, function()
        if CONFIG.SHOW_NOTIFICATIONS then
            Rayfield:Notify({
                Title = "Добро пожаловать в Kensa AI",
                Content = "Используйте чат для общения с AI или команды /help\n\nЛимит: " .. CONFIG.DAILY_LIMIT .. " запросов в день",
                Duration = 10,
            })
        end
        
        Log("Kensa AI v3.0 запущен", "INFO")
        Log("Разработчик: @Kensa", "INFO")
        Log("UI: Rayfield Library", "INFO")
    end)
end

-- =====================================================================
-- РАЗДЕЛ 18: ИНИЦИАЛИЗАЦИЯ
-- =====================================================================

local function Initialize()
    Log("Инициализация Kensa AI...", "INFO")
    
    -- Сбор начальных данных
    CollectPlayerData()
    CollectGameData()
    
    -- Запуск периодического обновления
    UpdatePlayerInfoLoop()
    
    -- Показ приветствия
    ShowWelcomeMessage()
    
    -- Обновление информации во вкладке
    UpdateInfoTab()
    
    Log("Инициализация завершена", "INFO")
end

-- =====================================================================
-- РАЗДЕЛ 19: ЗАПУСК
-- =====================================================================

-- Запуск инициализации
Initialize()

-- Обработчик уничтожения
game:GetService("RunService").Heartbeat:Connect(function()
    -- Можно добавить дополнительную логику здесь
end)

-- =====================================================================
-- КОНЕЦ СКРИПТА
-- =====================================================================

print("[Kensa AI v3.0] Загружен успешно")
print("[Kensa AI] Разработчик: @Kensa")
print("[Kensa AI] UI: Rayfield Library")