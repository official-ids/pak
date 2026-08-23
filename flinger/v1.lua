--[[
    Fling Player UI — Tora IsMe Style
    Работает на Synapse X, Krnl, Script-Ware, Fluxus и др.
]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

-- ===== НАСТРОЙКИ =====
local UI_CONFIG = {
    ThemeColor = Color3.fromRGB(179, 136, 255), -- фиолетовый
    BackgroundTransparency = 0.15,
    CornerRadius = 12,
}

-- ===== СОЗДАНИЕ ГЛАВНОГО UI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlingPlayerUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- ===== ОСНОВНОЙ КОНТЕЙНЕР =====
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 320)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 46)
mainFrame.BackgroundTransparency = UI_CONFIG.BackgroundTransparency
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Тень (эффект стекла)
local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(1, 0, 1, 0)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.5
shadow.BorderSizePixel = 0
shadow.Position = UDim2.new(0, 8, 0, 8)
shadow.Parent = mainFrame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, UI_CONFIG.CornerRadius)
corner.Parent = mainFrame

-- Размытие (Blur) если поддерживается
pcall(function()
    local blur = Instance.new("BlurEffect")
    blur.Size = 20
    blur.Parent = mainFrame
end)

-- ===== ШАПКА =====
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
header.BackgroundTransparency = 0.3
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, UI_CONFIG.CornerRadius)
headerCorner.Parent = header

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.Position = UDim2.new(0.05, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🎮 Fling Player"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = header

-- Версия (бейдж)
local badge = Instance.new("TextLabel")
badge.Size = UDim2.new(0, 40, 0, 20)
badge.Position = UDim2.new(0.45, 0, 0.3, 0)
badge.BackgroundColor3 = UI_CONFIG.ThemeColor
badge.BackgroundTransparency = 0.2
badge.Text = "v1"
badge.TextColor3 = Color3.fromRGB(255, 255, 255)
badge.TextSize = 11
badge.Font = Enum.Font.GothamBold
badge.TextScaled = true
badge.BorderSizePixel = 0
badge.Parent = header

local badgeCorner = Instance.new("UICorner")
badgeCorner.CornerRadius = UDim.new(1, 0)
badgeCorner.Parent = badge

-- Кнопки управления
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 30, 0, 30)
collapseBtn.Position = UDim2.new(0.86, 0, 0.2, 0)
collapseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
collapseBtn.BackgroundTransparency = 0.9
collapseBtn.Text = "⬇"
collapseBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
collapseBtn.TextSize = 18
collapseBtn.Font = Enum.Font.Gotham
collapseBtn.BorderSizePixel = 0
collapseBtn.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(0.93, 0, 0.2, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundTransparency = 0.9
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.Gotham
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

-- ===== ВЫБОР ИГРОКА =====
local playerFrame = Instance.new("Frame")
playerFrame.Size = UDim2.new(0.9, 0, 0, 80)
playerFrame.Position = UDim2.new(0.05, 0, 0.18, 0)
playerFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
playerFrame.BackgroundTransparency = 0.3
playerFrame.BorderSizePixel = 0
playerFrame.Parent = mainFrame

local playerCorner = Instance.new("UICorner")
playerCorner.CornerRadius = UDim.new(0, 8)
playerCorner.Parent = playerFrame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0, 20)
label.Position = UDim2.new(0.05, 0, 0, 0)
label.BackgroundTransparency = 1
label.Text = "ВЫБОР ИГРОКА"
label.TextColor3 = Color3.fromRGB(136, 136, 170)
label.TextSize = 11
label.TextXAlignment = Enum.TextXAlignment.Left
label.Font = Enum.Font.Gotham
label.Parent = playerFrame

-- Поле ввода
local playerInput = Instance.new("TextBox")
playerInput.Size = UDim2.new(0.7, 0, 0, 30)
playerInput.Position = UDim2.new(0.05, 0, 0.4, 0)
playerInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
playerInput.BackgroundTransparency = 0.9
playerInput.Text = ""
playerInput.TextColor3 = Color3.fromRGB(240, 240, 255)
playerInput.TextSize = 14
playerInput.Font = Enum.Font.Gotham
playerInput.PlaceholderText = "ID / username / name"
playerInput.PlaceholderColor3 = Color3.fromRGB(85, 85, 119)
playerInput.BorderSizePixel = 0
playerInput.ClipsDescendants = true
playerInput.Parent = playerFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(1, 0)
inputCorner.Parent = playerInput

-- ===== КОНТЕЙНЕР С ИГРОКАМИ (чипы) =====
local playersContainer = Instance.new("Frame")
playersContainer.Size = UDim2.new(0.9, 0, 0, 30)
playersContainer.Position = UDim2.new(0.05, 0, 0.55, 0)
playersContainer.BackgroundTransparency = 1
playersContainer.Parent = mainFrame

local playersList = Instance.new("UIListLayout")
playersList.FillDirection = Enum.FillDirection.Horizontal
playersList.HorizontalAlignment = Enum.HorizontalAlignment.Left
playersList.VerticalAlignment = Enum.VerticalAlignment.Center
playersList.Padding = UDim.new(0, 6)
playersList.Parent = playersContainer

-- Список игроков (можно расширить)
local playerNames = {"Tora IsMe", "Floppa", "Shinji", "Asuka", "Rei"}
local selectedPlayer = ""

-- Создание чипов
for _, name in ipairs(playerNames) do
    local chip = Instance.new("TextButton")
    chip.Size = UDim2.new(0, 0, 0, 22)
    chip.BackgroundColor3 = UI_CONFIG.ThemeColor
    chip.BackgroundTransparency = 0.85
    chip.Text = name
    chip.TextColor3 = Color3.fromRGB(200, 176, 255)
    chip.TextSize = 12
    chip.Font = Enum.Font.GothamMedium
    chip.BorderSizePixel = 0
    chip.AutoSizeableX = true
    chip.Padding = UDim.new(0, 12)
    chip.Parent = playersContainer

    local chipCorner = Instance.new("UICorner")
    chipCorner.CornerRadius = UDim.new(1, 0)
    chipCorner.Parent = chip

    chip.MouseButton1Click:Connect(function()
        playerInput.Text = name
        selectedPlayer = name
        updateStatus(name)
    end)
end

-- ===== КНОПКИ ДЕЙСТВИЙ =====
local actionsFrame = Instance.new("Frame")
actionsFrame.Size = UDim2.new(0.9, 0, 0, 50)
actionsFrame.Position = UDim2.new(0.05, 0, 0.58, 0)
actionsFrame.BackgroundTransparency = 1
actionsFrame.Parent = mainFrame

-- Fling кнопка
local flingBtn = Instance.new("TextButton")
flingBtn.Size = UDim2.new(0.45, 0, 0.8, 0)
flingBtn.Position = UDim2.new(0, 0, 0.1, 0)
flingBtn.BackgroundColor3 = UI_CONFIG.ThemeColor
flingBtn.Text = "🚀 Fling"
flingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flingBtn.TextSize = 16
flingBtn.Font = Enum.Font.GothamBold
flingBtn.BorderSizePixel = 0
flingBtn.Parent = actionsFrame

local flingCorner = Instance.new("UICorner")
flingCorner.CornerRadius = UDim.new(1, 0)
flingCorner.Parent = flingBtn

-- Stop кнопка
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.45, 0, 0.8, 0)
stopBtn.Position = UDim2.new(0.5, 10, 0.1, 0)
stopBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.BackgroundTransparency = 0.9
stopBtn.Text = "⏹ Stop"
stopBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
stopBtn.TextSize = 16
stopBtn.Font = Enum.Font.GothamBold
stopBtn.BorderSizePixel = 0
stopBtn.Parent = actionsFrame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(1, 0)
stopCorner.Parent = stopBtn

-- ===== СТАТУС =====
local statusFrame = Instance.new("Frame")
statusFrame.Size = UDim2.new(0.9, 0, 0, 25)
statusFrame.Position = UDim2.new(0.05, 0, 0.82, 0)
statusFrame.BackgroundTransparency = 1
statusFrame.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.5, 0, 1, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Текущий:"
statusLabel.TextColor3 = Color3.fromRGB(102, 102, 170)
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = statusFrame

local currentPlayerDisplay = Instance.new("TextLabel")
currentPlayerDisplay.Size = UDim2.new(0.5, 0, 1, 0)
currentPlayerDisplay.Position = UDim2.new(0.5, 0, 0, 0)
currentPlayerDisplay.BackgroundTransparency = 1
currentPlayerDisplay.Text = "не выбран"
currentPlayerDisplay.TextColor3 = UI_CONFIG.ThemeColor
currentPlayerDisplay.TextSize = 12
currentPlayerDisplay.TextXAlignment = Enum.TextXAlignment.Right
currentPlayerDisplay.Font = Enum.Font.GothamMedium
currentPlayerDisplay.Parent = statusFrame

-- ===== ВИДЖЕТ (свёрнутый) =====
local widgetFrame = Instance.new("Frame")
widgetFrame.Name = "Widget"
widgetFrame.Size = UDim2.new(0, 60, 0, 60)
widgetFrame.Position = UDim2.new(1, -80, 0.9, 0)
widgetFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 46)
widgetFrame.BackgroundTransparency = 0.15
widgetFrame.BorderSizePixel = 0
widgetFrame.Visible = false
widgetFrame.Parent = screenGui

local widgetCorner = Instance.new("UICorner")
widgetCorner.CornerRadius = UDim.new(1, 0)
widgetCorner.Parent = widgetFrame

local widgetIcon = Instance.new("TextLabel")
widgetIcon.Size = UDim2.new(1, 0, 1, 0)
widgetIcon.BackgroundTransparency = 1
widgetIcon.Text = "🎮"
widgetIcon.TextColor3 = UI_CONFIG.ThemeColor
widgetIcon.TextSize = 30
widgetIcon.Font = Enum.Font.Gotham
widgetIcon.Parent = widgetFrame

-- ===== ФУНКЦИИ =====
local function updateStatus(name)
    currentPlayerDisplay.Text = name or "не выбран"
end

local function toggleWidget(show)
    widgetFrame.Visible = show
    mainFrame.Visible = not show
end

local function collapseUI()
    toggleWidget(true)
end

local function expandUI()
    toggleWidget(false)
end

-- ===== ПЕРЕТАСКИВАНИЕ UI =====
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function updateDrag(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    mainFrame.Position = newPos
end

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateDrag(input)
    end
end)

-- ===== ПЕРЕТАСКИВАНИЕ ВИДЖЕТА =====
local widgetDragging = false
local widgetDragStart = nil
local widgetStartPos = nil

widgetFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        widgetDragging = true
        widgetDragStart = input.Position
        widgetStartPos = widgetFrame.Position
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if widgetDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - widgetDragStart
        widgetFrame.Position = UDim2.new(widgetStartPos.X.Scale, widgetStartPos.X.Offset + delta.X, widgetStartPos.Y.Scale, widgetStartPos.Y.Offset + delta.Y)
    end
end)

-- ===== СОБЫТИЯ КНОПОК =====
collapseBtn.MouseButton1Click:Connect(collapseUI)

closeBtn.MouseButton1Click:Connect(function()
    collapseUI()
end)

widgetFrame.MouseButton1Click:Connect(expandUI)

-- Выбор игрока (ввод)
playerInput.FocusLost:Connect(function()
    local val = playerInput.Text
    if val ~= "" then
        selectedPlayer = val
        updateStatus(val)
    end
end)

-- Fling
flingBtn.MouseButton1Click:Connect(function()
    if selectedPlayer == "" then
        currentPlayerDisplay.Text = "⚠️ выбери игрока!"
        wait(1)
        updateStatus(selectedPlayer or "не выбран")
        return
    end
    
    -- Анимация нажатия
    flingBtn.Size = UDim2.new(0.42, 0, 0.75, 0)
    wait(0.1)
    flingBtn.Size = UDim2.new(0.45, 0, 0.8, 0)
    
    -- ЛОГИКА ФЛИНГА
    print("[Fling] 🚀 Fling на " .. selectedPlayer)
    currentPlayerDisplay.Text = "➜ " .. selectedPlayer .. " (fling!)"
    currentPlayerDisplay.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    -- Найди игрока по имени
    local target = nil
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Name == selectedPlayer or plr.DisplayName == selectedPlayer then
            target = plr
            break
        end
    end
    
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local velocity = Vector3.new(math.random(-50, 50), math.random(80, 120), math.random(-50, 50))
        hrp.Velocity = velocity
        hrp:BreakJoints() -- дополнительный эффект
    end
    
    wait(0.8)
    currentPlayerDisplay.Text = selectedPlayer
    currentPlayerDisplay.TextColor3 = UI_CONFIG.ThemeColor
end)

-- Stop
stopBtn.MouseButton1Click:Connect(function()
    stopBtn.Size = UDim2.new(0.42, 0, 0.75, 0)
    wait(0.1)
    stopBtn.Size = UDim2.new(0.45, 0, 0.8, 0)
    
    print("[Fling] ⏹ Stop Fling")
    currentPlayerDisplay.Text = "⏹ " .. (selectedPlayer or "стоп")
    currentPlayerDisplay.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    -- Остановить всех игроков
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
    end
    
    wait(0.6)
    currentPlayerDisplay.Text = selectedPlayer or "не выбран"
    currentPlayerDisplay.TextColor3 = UI_CONFIG.ThemeColor
end)

-- ===== ОТКРЫТИЕ ПО КОМАНДЕ =====
-- Можно открыть через /fling
game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
    if msg == "/fling" then
        if mainFrame.Visible then
            collapseUI()
        else
            expandUI()
        end
    end
end)

-- ===== ИНИЦИАЛИЗАЦИЯ =====
print("🎮 Fling Player загружен! Используй /fling для открытия.")
expandUI() -- Показать UI при старте