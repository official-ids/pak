--[[
    Kensa AI Assistant
    Интеграция: Mistral AI (модель: mistral-medium-latest)
    Разработчик: @Kensa
    Описание: AI-ассистент для помощи в играх Roblox
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =====================================================================
-- КОНФИГУРАЦИЯ
-- =====================================================================
local CONFIG = {
    MISTRAL_API_URL = "https://api.mistral.ai/v1/chat/completions",
    MODEL = "mistral-medium-latest",
    MAX_TOKENS = 1024,
    TEMPERATURE = 0.7,
    AVATAR_API = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=%s&size=150x150&format=Png",
}

-- =====================================================================
-- СОСТОЯНИЕ ПРИЛОЖЕНИЯ
-- =====================================================================
local State = {
    APIKey = "",
    ChatHistory = {},
    IsMobile = false,
    Theme = {
        Background = Color3.fromRGB(20, 20, 30),
        Surface = Color3.fromRGB(30, 30, 45),
        Primary = Color3.fromRGB(70, 110, 255),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(50, 50, 70),
    }
}

-- Определение устройства
State.IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- =====================================================================
-- УТИЛИТЫ
-- =====================================================================
local function CreateUI(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

local function GetPlayerContext()
    local context = {
        playerName = LocalPlayer.Name,
        playerId = LocalPlayer.UserId,
        characterExists = LocalPlayer.Character ~= nil,
    }
    
    if LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        
        if hrp then
            context.position = string.format("%.1f, %.1f, %.1f", 
                hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
        end
        
        if humanoid then
            context.health = humanoid.Health
            context.maxHealth = humanoid.MaxHealth
            context.walkSpeed = humanoid.WalkSpeed
            context.jumpPower = humanoid.JumpPower
        end
    end
    
    if LocalPlayer.Team then
        context.team = LocalPlayer.Team.Name
    end
    
    -- Информация об игре
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.GamePass)
    end)
    
    if success and info then
        context.gameName = info.Name
        context.gameCreator = info.Creator.Name
    end
    
    context.playerCount = #Players:GetPlayers()
    
    return context
end

local function GetAvatarImage(userId)
    local url = string.format(CONFIG.AVATAR_API, userId)
    local success, result = pcall(function()
        local response = HttpService:JSONDecode(HttpService:GetAsync(url))
        if response.data and response.data[1] then
            return response.data[1].imageUrl
        end
        return nil
    end)
    
    return success and result or nil
end

-- =====================================================================
-- ПАРСЕР MARKDOWN (БАЗОВАЯ ПОДДЕРЖКА)
-- =====================================================================
local function ParseMarkdown(text)
    -- Roblox поддерживает RichText
    local parsed = text
    
    -- Жирный текст
    parsed = string.gsub(parsed, "%*%*(.-)%*%*", "<b>%1</b>")
    
    -- Курсив
    parsed = string.gsub(parsed, "%*(.-)%*", "<i>%1</i>")
    
    -- Код
    parsed = string.gsub(parsed, "`(.-)`", "<font color='#88ff88'>%1</font>")
    
    -- Заголовки
    parsed = string.gsub(parsed, "^### (.-)$", "<b><font size='16'>%1</font></b>")
    parsed = string.gsub(parsed, "^## (.-)$", "<b><font size='18'>%1</font></b>")
    parsed = string.gsub(parsed, "^# (.-)$", "<b><font size='20'>%1</font></b>")
    
    -- Списки
    parsed = string.gsub(parsed, "^%- (.-)$", "  • %1")
    parsed = string.gsub(parsed, "^%* (.-)$", "  • %1")
    
    return parsed
end

-- =====================================================================
-- СОЗДАНИЕ UI
-- =====================================================================
local ScreenGui = CreateUI("ScreenGui", {
    Name = "KensaAIGui",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = PlayerGui
})

-- Главное окно
local MainFrame = CreateUI("Frame", {
    Name = "MainFrame",
    Size = State.IsMobile and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 500, 0, 600),
    Position = State.IsMobile and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, -250, 0.5, -300),
    BackgroundColor3 = State.Theme.Background,
    BorderSizePixel = 0,
    Parent = ScreenGui
})
CreateUI("UICorner", { CornerRadius = UDim.new(0, State.IsMobile and 0 or 12), Parent = MainFrame })
CreateUI("UIStroke", { Color = State.Theme.Border, Thickness = 2, Parent = MainFrame })

-- Заголовок
local TitleBar = CreateUI("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = State.Theme.Surface,
    BorderSizePixel = 0,
    Parent = MainFrame
})
CreateUI("UICorner", { CornerRadius = UDim.new(0, State.IsMobile and 0 or 12), Parent = TitleBar })

local Title = CreateUI("TextLabel", {
    Size = UDim2.new(1, -100, 1, 0),
    Position = UDim2.new(0, 15, 0, 0),
    BackgroundTransparency = 1,
    Text = "Kensa AI Assistant",
    TextColor3 = State.Theme.Text,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar
})

-- Кнопка закрытия (только для ПК)
if not State.IsMobile then
    local CloseBtn = CreateUI("TextButton", {
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -45, 0, 5),
        BackgroundColor3 = Color3.fromRGB(200, 60, 60),
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        Parent = TitleBar
    })
    CreateUI("UICorner", { CornerRadius = UDim.new(0, 8), Parent = CloseBtn })
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
end

-- Область чата
local ChatContainer = CreateUI("ScrollingFrame", {
    Name = "ChatContainer",
    Size = UDim2.new(1, -20, 1, -160),
    Position = UDim2.new(0, 10, 0, 55),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = MainFrame
})

local ChatLayout = CreateUI("UIListLayout", {
    Padding = UDim.new(0, 10),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = ChatContainer
})

-- Поле ввода
local InputContainer = CreateUI("Frame", {
    Name = "InputContainer",
    Size = UDim2.new(1, -20, 0, 90),
    Position = UDim2.new(0, 10, 1, -100),
    BackgroundColor3 = State.Theme.Surface,
    BorderSizePixel = 0,
    Parent = MainFrame
})
CreateUI("UICorner", { CornerRadius = UDim.new(0, 8), Parent = InputContainer })

local InputBox = CreateUI("TextBox", {
    Size = UDim2.new(1, -20, 0, 50),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = State.Theme.Background,
    BorderSizePixel = 0,
    PlaceholderText = "Спросите Kensa AI...",
    Text = "",
    TextColor3 = State.Theme.Text,
    TextSize = 14,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false,
    TextWrapped = true,
    Parent = InputContainer
})
CreateUI("UICorner", { CornerRadius = UDim.new(0, 6), Parent = InputBox })
CreateUI("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = InputBox })

local SendBtn = CreateUI("TextButton", {
    Size = UDim2.new(0, 80, 0, 30),
    Position = UDim2.new(1, -90, 0, 65),
    BackgroundColor3 = State.Theme.Primary,
    BorderSizePixel = 0,
    Text = "Отправить",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    Parent = InputContainer
})
CreateUI("UICorner", { CornerRadius = UDim.new(0, 6), Parent = SendBtn })

-- =====================================================================
-- СИСТЕМА СООБЩЕНИЙ
-- =====================================================================
local function AddMessage(content, isUser)
    local MessageFrame = CreateUI("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = isUser and State.Theme.Primary or State.Theme.Surface,
        BorderSizePixel = 0,
        Parent = ChatContainer,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    CreateUI("UICorner", { CornerRadius = UDim.new(0, 8), Parent = MessageFrame })
    CreateUI("UIPadding", { 
        PaddingTop = UDim.new(0, 10), 
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = MessageFrame 
    })
    
    local Label = CreateUI("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = isUser and content or ParseMarkdown(content),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        RichText = not isUser,
        Parent = MessageFrame,
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    -- Прокрутка вниз
    task.wait(0.1)
    ChatContainer.CanvasPosition = Vector2.new(0, ChatContainer.AbsoluteCanvasSize.Y)
    
    return MessageFrame
end

-- =====================================================================
-- ИНТЕГРАЦИЯ С MISTRAL AI
-- =====================================================================
local function CallMistralAPI(userMessage)
    if State.APIKey == "" then
        return "Пожалуйста, введите ваш Mistral API ключ в поле ниже."
    end
    
    -- Сбор контекста
    local context = GetPlayerContext()
    local contextStr = HttpService:JSONEncode(context)
    
    -- Системный промпт
    local systemPrompt = string.format([[
Ты - Kensa AI, ассистент от разработчика @Kensa для игр Roblox.

ПРАВИЛА:
1. Ты помогаешь игрокам с легальными действиями в играх
2. Ты МОЖЕШЬ: объяснять механики, давать советы, помогать с навигацией, отвечать на вопросы об игре
3. Ты МОЖЕШЬ выполнять команды: прыжок, движение, изменение WalkSpeed (только в разумных пределах 16-50), изменение JumpPower (50-100)
4. Ты НЕ МОЖЕШЬ: создавать читы, ESP, Aimbot, Fly hack, Noclip, Speed hack (выше 50), Teleport hack, Fling, или любые вредоносные скрипты
5. Если пользователь просит вредоносные функции, вежливо откажись и объясни почему
6. Отвечай на русском языке
7. Используй Markdown для форматирования: **жирный**, *курсив*, `код`, списки

КОНТЕКСТ ИГРОКА:
%s

Если пользователь просит выполнить действие, ответь в формате:
[COMMAND: действие]
Описание действия

Примеры команд:
- [COMMAND: jump] - прыжок
- [COMMAND: walk_speed:30] - установить скорость ходьбы 30
- [COMMAND: jump_power:70] - установить силу прыжка 70
- [COMMAND: move_forward] - движение вперед
- [COMMAND: show_avatar] - показать аватар игрока

Если это не команда, просто ответь текстом.
]], contextStr)
    
    -- Формирование запроса
    local messages = {
        { role = "system", content = systemPrompt }
    }
    
    -- Добавление истории чата (последние 10 сообщений)
    local historyStart = math.max(1, #State.ChatHistory - 9)
    for i = historyStart, #State.ChatHistory do
        table.insert(messages, State.ChatHistory[i])
    end
    
    table.insert(messages, { role = "user", content = userMessage })
    
    local requestBody = {
        model = CONFIG.MODEL,
        messages = messages,
        max_tokens = CONFIG.MAX_TOKENS,
        temperature = CONFIG.TEMPERATURE,
    }
    
    local success, response = pcall(function()
        local headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. State.APIKey
        }
        
        local httpResponse = HttpService:PostAsync(
            CONFIG.MISTRAL_API_URL,
            HttpService:JSONEncode(requestBody),
            Enum.HttpContentType.ApplicationJson,
            false,
            headers
        )
        
        return HttpService:JSONDecode(httpResponse)
    end)
    
    if success and response and response.choices and response.choices[1] then
        return response.choices[1].message.content
    else
        return "Ошибка при обращении к API. Проверьте ваш API ключ и попробуйте снова."
    end
end

-- =====================================================================
-- ВЫПОЛНЕНИЕ КОМАНД
-- =====================================================================
local function ExecuteCommand(command)
    local character = LocalPlayer.Character
    if not character then return false end
    
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not hrp then return false end
    
    if command == "jump" then
        humanoid.Jump = true
        return true
    elseif command:match("^walk_speed:(%d+)$") then
        local speed = tonumber(command:match("^walk_speed:(%d+)$"))
        if speed and speed >= 16 and speed <= 50 then
            humanoid.WalkSpeed = speed
            return true
        end
    elseif command:match("^jump_power:(%d+)$") then
        local power = tonumber(command:match("^jump_power:(%d+)$"))
        if power and power >= 50 and power <= 100 then
            humanoid.JumpPower = power
            return true
        end
    elseif command == "move_forward" then
        humanoid:Move(Vector3.new(0, 0, -1), true)
        return true
    elseif command == "show_avatar" then
        local imageUrl = GetAvatarImage(LocalPlayer.UserId)
        if imageUrl then
            AddMessage("📷 Ваш аватар:\n" .. imageUrl, false)
        end
        return true
    end
    
    return false
end

-- =====================================================================
-- ОБРАБОТКА ОТВЕТОВ
-- =====================================================================
local function ProcessResponse(response)
    -- Проверка на команду
    local commandMatch = response:match("%[COMMAND: (.-)%]")
    
    if commandMatch then
        local success = ExecuteCommand(commandMatch)
        if success then
            local description = response:gsub("%[COMMAND: .-%]", ""):gsub("^%s*(.-)%s*$", "%1")
            AddMessage("✅ Команда выполнена!\n\n" .. description, false)
        else
            AddMessage("⚠️ Не удалось выполнить команду. Убедитесь, что ваш персонаж жив.", false)
        end
    else
        AddMessage(response, false)
    end
end

-- =====================================================================
-- ОБРАБОТКА ОТПРАВКИ СООБЩЕНИЙ
-- =====================================================================
local function SendMessage()
    local text = InputBox.Text:gsub("^%s*(.-)%s*$", "%1")
    if text == "" then return end
    
    -- Проверка на API ключ
    if State.APIKey == "" and text:match("^key:(.+)$") then
        State.APIKey = text:match("^key:(.+)$"):gsub("%s+", "")
        AddMessage("✅ API ключ установлен. Теперь вы можете использовать Kensa AI!", false)
        InputBox.Text = ""
        return
    elseif State.APIKey == "" then
        AddMessage("⚠️ Сначала введите ваш Mistral API ключ:\n\n`key:ваш_ключ_тут`\n\nПолучить ключ: https://console.mistral.ai", false)
        InputBox.Text = ""
        return
    end
    
    -- Добавление сообщения пользователя
    AddMessage(text, true)
    table.insert(State.ChatHistory, { role = "user", content = text })
    InputBox.Text = ""
    
    -- Индикатор загрузки
    local loadingMsg = AddMessage("🤔 Думаю...", false)
    
    -- Запрос к API
    task.spawn(function()
        local response = CallMistralAPI(text)
        loadingMsg:Destroy()
        
        -- Сохранение в историю
        table.insert(State.ChatHistory, { role = "assistant", content = response })
        
        -- Обработка ответа
        ProcessResponse(response)
    end)
end

-- Обработчики событий
SendBtn.MouseButton1Click:Connect(SendMessage)
InputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        SendMessage()
    end
end)

-- =====================================================================
-- ПРИВЕТСТВЕННОЕ СООБЩЕНИЕ
-- =====================================================================
task.wait(0.5)
AddMessage([[
# 👋 Привет! Я Kensa AI

Я ваш ассистент в играх Roblox от разработчика **@Kensa**.

## 🚀 Начало работы

Сначала введите ваш Mistral API ключ:
`key:ваш_ключ_тут`

Получить ключ: https://console.mistral.ai

## 💡 Что я могу

- Отвечать на вопросы об играх
- Помогать с навигацией
- Выполнять команды: прыжок, движение, изменение скорости
- Показывать ваш аватар
- Давать советы по играм

## ⚠️ Ограничения

Я не создаю читы, ESP, Aimbot или другие вредоносные скрипты.

---

*Напишите сообщение, чтобы начать!*
]], false)

-- =====================================================================
-- ПЕРЕТАСКИВАНИЕ ОКНА (ТОЛЬКО ДЛЯ ПК)
-- =====================================================================
if not State.IsMobile then
    local dragging, dragInput, dragStart, startPos
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- =====================================================================
-- ОЧИСТКА ПАМЯТИ
-- =====================================================================
ScreenGui.Destroying:Connect(function()
    State.ChatHistory = {}
end)
