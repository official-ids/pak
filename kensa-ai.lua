--[[
    =====================================================================
    KENSA AI ASSISTANT - Rayfield Edition
    Разработчик: @Kensa
    Версия: 3.0.0
    UI Library: Rayfield
    =====================================================================
]]

-- Загрузка Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- =====================================================================
-- КОНФИГУРАЦИЯ
-- =====================================================================
local CONFIG = {
    API_URL = "https://api.mistral.ai/v1/chat/completions",
    API_KEY = "v50l52LxJ2BzUK0C6W2nkkt3MNJ9Yova",
    AI_MODEL = "mistral-small-latest",
    MAX_TOKENS = 2048,
    TEMPERATURE = 0.75,
    DAILY_LIMIT = 100,
    AVATAR_API = "https://thumbnails.roblox.com/v1/users/avatar-headshot",
}

-- =====================================================================
-- СОСТОЯНИЕ
-- =====================================================================
local State = {
    ChatHistory = {},
    DailyRequests = 0,
    LastResetDate = "",
    IsTyping = false,
}

-- Сервисы
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

-- =====================================================================
-- УТИЛИТЫ
-- =====================================================================
local function GetCurrentDate()
    return os.date("%Y-%m-%d")
end

local function FormatNumber(num)
    if num >= 1000000 then return string.format("%.1fM", num/1000000)
    elseif num >= 1000 then return string.format("%.1fK", num/1000)
    else return tostring(num) end
end

local function CheckLimits()
    local today = GetCurrentDate()
    if State.LastResetDate ~= today then
        State.DailyRequests = 0
        State.LastResetDate = today
    end
    if State.DailyRequests >= CONFIG.DAILY_LIMIT then
        return false, "Превышен лимит (" .. CONFIG.DAILY_LIMIT .. "/день)"
    end
    return true, "OK"
end

-- =====================================================================
-- СБОР ИНФОРМАЦИИ
-- =====================================================================
local function GetPlayerInfo()
    local info = {
        Name = LocalPlayer.Name,
        UserId = LocalPlayer.UserId,
        DisplayName = LocalPlayer.DisplayName or LocalPlayer.Name,
        AccountAge = LocalPlayer.AccountAge,
    }
    
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hrp then
            info.Position = string.format("%.1f, %.1f, %.1f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
        end
        if humanoid then
            info.Health = math.floor(humanoid.Health)
            info.MaxHealth = humanoid.MaxHealth
            info.WalkSpeed = humanoid.WalkSpeed
            info.JumpPower = humanoid.JumpPower
        end
    end
    
    if LocalPlayer.Team then
        info.Team = LocalPlayer.Team.Name
    end
    
    return info
end

local function GetGameInfo()
    local info = {
        PlaceId = game.PlaceId,
        Name = "Неизвестно",
        Creator = "Неизвестно",
        CurrentPlayers = #Players:GetPlayers(),
    }
    
    local success, data = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Game)
    end)
    
    if success then
        info.Name = data.Name
        info.Creator = data.Creator.Name
        info.MaxPlayers = data.MaxPlayers
        info.Visits = data.Visits
    end
    
    return info
end

-- =====================================================================
-- AI ИНТЕГРАЦИЯ
-- =====================================================================
local function SendToAI(message, callback)
    local allowed, errMsg = CheckLimits()
    if not allowed then
        callback(errMsg)
        return
    end
    
    local playerInfo = GetPlayerInfo()
    local gameInfo = GetGameInfo()
    
    local systemPrompt = string.format([[
Ты - Kensa AI, ассистент для Roblox от @Kensa.

ИНФОРМАЦИЯ:
- Игрок: %s (ID: %d)
- Позиция: %s
- Здоровье: %s/%s
- Скорость: %d
- Игра: %s (PlaceId: %d)
- Игроков на сервере: %d

ПРАВИЛА:
1. Отвечай на русском
2. Для действий используй формат [SCRIPT]код[/SCRIPT]
3. Не создавай читы
4. Будь полезен

Примеры команд:
- "прыгни" -> [SCRIPT]game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Jump = true[/SCRIPT]
- "скорость 25" -> [SCRIPT]game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").WalkSpeed = 25[/SCRIPT]
- "покажи аватар" -> покажи ссылку на аватар
]], 
        playerInfo.Name, playerInfo.UserId,
        playerInfo.Position or "N/A",
        playerInfo.Health or "100", playerInfo.MaxHealth or "100",
        playerInfo.WalkSpeed or 16,
        gameInfo.Name, gameInfo.PlaceId,
        gameInfo.CurrentPlayers
    )
    
    task.spawn(function()
        local success, response = pcall(function()
            local headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. CONFIG.API_KEY,
            }
            
            local body = {
                model = CONFIG.AI_MODEL,
                messages = {
                    {role = "system", content = systemPrompt},
                    {role = "user", content = message}
                },
                max_tokens = CONFIG.MAX_TOKENS,
                temperature = CONFIG.TEMPERATURE,
            }
            
            local httpResp = HttpService:PostAsync(
                CONFIG.API_URL,
                HttpService:JSONEncode(body),
                Enum.HttpContentType.ApplicationJson,
                false,
                headers
            )
            
            return HttpService:JSONDecode(httpResp)
        end)
        
        if success and response and response.choices then
            State.DailyRequests = State.DailyRequests + 1
            callback(response.choices[1].message.content)
        else
            callback(" Ошибка API: " .. tostring(response))
        end
    end)
end

-- =====================================================================
-- ВЫПОЛНЕНИЕ СКРИПТОВ
-- =====================================================================
local function ExecuteScript(code)
    local success, err = pcall(function()
        loadstring(code)()
    end)
    return success, err
end

-- =====================================================================
-- СОЗДАНИЕ UI
-- =====================================================================
local Window = Rayfield:CreateWindow({
    Name = "Kensa AI Assistant",
    LoadingTitle = "Инициализация Kensa AI",
    LoadingSubtitle = "by @Kensa • Rayfield Edition",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = false,
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- Вкладки
local ChatTab = Window:CreateTab(" AI Чат", 4483362458)
local InfoTab = Window:CreateTab("📊 Информация", 4483362458)
local SettingsTab = Window:CreateTab("️ Настройки", 4483362458)

-- =====================================================================
-- ЧАТ ВКЛАДКА
-- =====================================================================
local ChatSection = ChatTab:CreateSection("Общение с AI")

-- Поле ввода
ChatTab:CreateTextbox({
    Name = "Введите сообщение...",
    PlaceholderText = "Напишите вопрос или команду (/help)",
    Callback = function(Message)
        if Message == "" then return end
        
        -- Встроенные команды
        if Message:sub(1, 1) == "/" then
            local cmd = Message:lower():sub(2)
            
            if cmd == "help" then
                Rayfield:Notify({
                    Title = "📚 Команды Kensa AI",
                    Content = "/stats - Статистика\n/game - Info об игре\n/limits - Лимиты\n/clear - Очистить чат\n/avatar - Ваш аватар",
                    Duration = 10,
                })
            elseif cmd == "stats" then
                local p = GetPlayerInfo()
                Rayfield:Notify({
                    Title = "📊 Статистика",
                    Content = string.format("Имя: %s\nЗдоровье: %s/%s\nСкорость: %d\nПрыжок: %d\nКоманда: %s",
                        p.Name, p.Health or 100, p.MaxHealth or 100,
                        p.WalkSpeed or 16, p.JumpPower or 50, p.Team or "Нет"),
                    Duration = 8,
                })
            elseif cmd == "game" then
                local g = GetGameInfo()
                Rayfield:Notify({
                    Title = "🎮 Информация об игре",
                    Content = string.format("Название: %s\nPlaceId: %d\nИгроков: %d/%d\nСоздатель: %s",
                        g.Name, g.PlaceId, g.CurrentPlayers, g.MaxPlayers or 0, g.Creator),
                    Duration = 8,
                })
            elseif cmd == "limits" then
                local allowed, _ = CheckLimits()
                Rayfield:Notify({
                    Title = "📈 Лимиты",
                    Content = string.format("Использовано: %d/%d\nОсталось: %d",
                        State.DailyRequests, CONFIG.DAILY_LIMIT,
                        CONFIG.DAILY_LIMIT - State.DailyRequests),
                    Duration = 6,
                })
            elseif cmd == "clear" then
                State.ChatHistory = {}
                Rayfield:Notify({Title = "✅ Чат очищен", Content = "", Duration = 3})
            else
                Rayfield:Notify({Title = " Неизвестная команда", Content = "Введите /help для списка", Duration = 4})
            end
            return
        end
        
        -- Отправка AI
        ChatTab:CreateLabel({Name = " Kensa AI думает..."})
        
        SendToAI(Message, function(response)
            -- Обработка скриптов
            local scriptCode = response:match("%[SCRIPT%](.-)%[/SCRIPT%]")
            
            if scriptCode then
                local success, err = ExecuteScript(scriptCode)
                if success then
                    Rayfield:Notify({
                        Title = "✅ Скрипт выполнен",
                        Content = response:gsub("%[SCRIPT%].-[/SCRIPT%]", "[Скрипт выполнен]"),
                        Duration = 5,
                    })
                else
                    Rayfield:Notify({
                        Title = "⚠️ Ошибка скрипта",
                        Content = tostring(err),
                        Duration = 5,
                    })
                end
            else
                Rayfield:Notify({
                    Title = "🤖 Kensa AI",
                    Content = response,
                    Duration = 10,
                })
            end
        end)
    end,
})

-- Быстрые действия
ChatTab:CreateSection("Быстрые команды")

ChatTab:CreateButton({
    Name = " Прыжок",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.Jump = true end
        end
    end,
})

ChatTab:CreateButton({
    Name = "⚡ Скорость x2",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = 32 end
        end
    end,
})

ChatTab:CreateButton({
    Name = "👁️ Показать аватар",
    Callback = function()
        local url = CONFIG.AVATAR_API .. "?userIds=" .. LocalPlayer.UserId .. "&size=150x150&format=Png"
        local success, data = pcall(function()
            return HttpService:JSONDecode(HttpService:GetAsync(url))
        end)
        if success and data.data and data.data[1] then
            Rayfield:Notify({
                Title = "📷 Ваш аватар",
                Content = data.data[1].imageUrl,
                Duration = 8,
            })
        end
    end,
})

-- =====================================================================
-- ИНФОРМАЦИЯ ВКЛАДКА
-- =====================================================================
InfoTab:CreateSection("Данные игрока")

local function UpdateInfo()
    local p = GetPlayerInfo()
    local g = GetGameInfo()
    
    InfoTab:CreateLabel({Name = "👤 Имя: " .. p.Name})
    InfoTab:CreateLabel({Name = " DisplayName: " .. p.DisplayName})
    InfoTab:CreateLabel({Name = "❤️ Здоровье: " .. (p.Health or "N/A")})
    InfoTab:CreateLabel({Name = "⚡ Скорость: " .. (p.WalkSpeed or "N/A")})
    InfoTab:CreateLabel({Name = " Игра: " .. g.Name})
    InfoTab:CreateLabel({Name = " Игроков: " .. g.CurrentPlayers})
end

UpdateInfo()

-- =====================================================================
-- НАСТРОЙКИ ВКЛАДКА
-- =====================================================================
SettingsTab:CreateSection("Информация")

SettingsTab:CreateLabel({Name = "📌 Версия: 3.0.0"})
SettingsTab:CreateLabel({Name = "👨‍ Разработчик: @Kensa"})
SettingsTab:CreateLabel({Name = " UI: Rayfield Library"})

SettingsTab:CreateSection("Лимиты API")

local allowed, _ = CheckLimits()
SettingsTab:CreateLabel({
    Name = string.format(" Использовано: %d/%d", State.DailyRequests, CONFIG.DAILY_LIMIT)
})

SettingsTab:CreateButton({
    Name = "🔄 Сбросить статистику",
    Callback = function()
        State.DailyRequests = 0
        Rayfield:Notify({Title = "✅ Готово", Content = "Статистика сброшена", Duration = 3})
    end,
})

-- =====================================================================
-- ПРИВЕТСТВИЕ
-- =====================================================================
task.delay(1, function()
    Rayfield:Notify({
        Title = "👋 Добро пожаловать в Kensa AI!",
        Content = "Используйте чат для общения с AI или команды (/help)\n\nЛимит: " .. CONFIG.DAILY_LIMIT .. " запросов/день",
        Duration = 8,
    })
end)

-- =====================================================================
-- КОНЕЦ
-- =====================================================================
print("[Kensa AI v3.0] Запущен с Rayfield UI")