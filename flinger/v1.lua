--[[
    Fling Player UI - Tora IsMe Style
    Рабочая версия без эмодзи
]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- ===== СОЗДАНИЕ UI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlingPlayer"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- ===== ОСНОВНОЕ ОКНО =====
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 420, 0, 340)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -170)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Скругление
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

-- Размытие (если поддерживается)
pcall(function()
    local blur = Instance.new("BlurEffect")
    blur.Size = 15
    blur.Parent = mainFrame
end)

-- ===== ЗАГОЛОВОК =====
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = header

-- Название
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
titleLabel.Position = UDim2.new(0.05, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Fling Player"
titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = header

-- Кнопка свернуть
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 32, 0, 32)
collapseBtn.Position = UDim2.new(0.85, 0, 0.18, 0)
collapseBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
collapseBtn.BackgroundTransparency = 0.5
collapseBtn.Text = "-"
collapseBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
collapseBtn.TextSize = 22
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.BorderSizePixel = 0
collapseBtn.Parent = header

local collapseCorner = Instance.new("UICorner")
collapseCorner.CornerRadius = UDim.new(1, 0)
collapseCorner.Parent = collapseBtn

-- Кнопка закрыть
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(0.93, 0, 0.18, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
closeBtn.BackgroundTransparency = 0.5
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

-- ===== ВЫБОР ИГРОКА =====
local selectFrame = Instance.new("Frame")
selectFrame.Size = UDim2.new(0.9, 0, 0, 85)
selectFrame.Position = UDim2.new(0.05, 0, 0.17, 0)
selectFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
selectFrame.BackgroundTransparency = 0.3
selectFrame.BorderSizePixel = 0
selectFrame.Parent = mainFrame

local selectCorner = Instance.new("UICorner")
selectCorner.CornerRadius = UDim.new(0, 10)
selectCorner.Parent = selectFrame

-- Лейбл
local selectLabel = Instance.new("TextLabel")
selectLabel.Size = UDim2.new(1, 0, 0, 20)
selectLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
selectLabel.BackgroundTransparency = 1
selectLabel.Text = "ВЫБОР ИГРОКА"
selectLabel.TextColor3 = Color3.fromRGB(130, 130, 180)
selectLabel.TextSize = 11
selectLabel.TextXAlignment = Enum.TextXAlignment.Left
selectLabel.Font = Enum.Font.Gotham
selectLabel.Parent = selectFrame

-- Поле ввода
local inputField = Instance.new("TextBox")
inputField.Size = UDim2.new(0.7, 0, 0, 30)
inputField.Position = UDim2.new(0.05, 0, 0.4, 0)
inputField.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
inputField.BackgroundTransparency = 0.9
inputField.Text = ""
inputField.TextColor3 = Color3.fromRGB(230, 230, 255)
inputField.TextSize = 14
inputField.Font = Enum.Font.Gotham
inputField.PlaceholderText = "Введите имя игрока"
inputField.PlaceholderColor3 = Color3.fromRGB(100, 100, 140)
inputField.BorderSizePixel = 0
inputField.ClipsDescendants = true
inputField.Parent = selectFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(1, 0)
inputCorner.Parent = inputField

-- ===== СПИСОК ИГРОКОВ (чипы) =====
local chipsContainer = Instance.new("Frame")
chipsContainer.Size = UDim2.new(0.9, 0, 0, 28)
chipsContainer.Position = UDim2.new(0.05, 0, 0.68, 0)
chipsContainer.BackgroundTransparency = 1
chipsContainer.Parent = mainFrame

local chipList = Instance.new("UIListLayout")
chipList.FillDirection = Enum.FillDirection.Horizontal
chipList.HorizontalAlignment = Enum.HorizontalAlignment.Left
chipList.VerticalAlignment = Enum.VerticalAlignment.Center
chipList.Padding = UDim.new(0, 6)
chipList.Parent = chipsContainer

-- Список игроков
local playersList = {"Tora IsMe", "Floppa", "Shinji", "Asuka", "Rei"}
local selectedPlayer = ""

-- Создание кнопок-чипов
for _, name in ipairs(playersList) do
    local chip = Instance.new("TextButton")
    chip.Size = UDim2.new(0, 0, 0, 24)
    chip.BackgroundColor3 = Color3.fromRGB(179, 136, 255)
    chip.BackgroundTransparency = 0.85
    chip.Text = name
    chip.TextColor3 = Color3.fromRGB(200, 180, 255)
    chip.TextSize = 12
    chip.Font = Enum.Font.GothamMedium
    chip.BorderSizePixel = 0
    chip.AutoSizeableX = true
    chip.Padding = UDim.new(0, 14)
    chip.Parent = chipsContainer
    
    local chipCorner = Instance.new("UICorner")
    chipCorner.CornerRadius = UDim.new(1, 0)
    chipCorner.Parent = chip
    
    chip.MouseButton1Click:Connect(function()
        inputField.Text = name
        selectedPlayer = name
        updateStatus(name)
    end)
end

-- ===== КНОПКИ ДЕЙСТВИЙ =====
local actionsFrame = Instance.new("Frame")
actionsFrame.Size = UDim2.new(0.9, 0, 0, 50)
actionsFrame.Position = UDim2.new(0.05, 0, 0.6, 0)
actionsFrame.BackgroundTransparency = 1
actionsFrame.Parent = mainFrame

-- Кнопка Fling
local flingBtn = Instance.new("TextButton")
flingBtn.Size = UDim2.new(0.48, 0, 0.8, 0)
flingBtn.Position = UDim2.new(0, 0, 0.1, 0)
flingBtn.BackgroundColor3 = Color3.fromRGB(179, 136, 255)
flingBtn.Text = "FLING"
flingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
flingBtn.TextSize = 16
flingBtn.Font = Enum.Font.GothamBold
flingBtn.BorderSizePixel = 0
flingBtn.Parent = actionsFrame

local flingCorner = Instance.new("UICorner")
flingCorner.CornerRadius = UDim.new(1, 0)
flingCorner.Parent = flingBtn

-- Кнопка Stop
local stopBtn = Instance.new("TextButton")
stopBtn.Size = UDim2.new(0.48, 0, 0.8, 0)
stopBtn.Position = UDim2.new(0.52, 0, 0.1, 0)
stopBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
stopBtn.BackgroundTransparency = 0.9
stopBtn.Text = "STOP"
stopBtn.TextColor3 = Color3.fromRGB(200, 200, 230)
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
statusFrame.Position = UDim2.new(0.05, 0, 0.85, 0)
statusFrame.BackgroundTransparency = 1
statusFrame.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.4, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Текущий:"
statusLabel.TextColor3 = Color3.fromRGB(130, 130, 180)
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = statusFrame

local currentPlayerLabel = Instance.new("TextLabel")
currentPlayerLabel.Size = UDim2.new(0.6, 0, 1, 0)
currentPlayerLabel.Position = UDim2.new(0.4, 0, 0, 0)
currentPlayerLabel.BackgroundTransparency = 1
currentPlayerLabel.Text = "не выбран"
currentPlayerLabel.TextColor3 = Color3.fromRGB(179, 136, 255)
currentPlayerLabel.TextSize = 12
currentPlayerLabel.TextXAlignment = Enum.TextXAlignment.Right
currentPlayerLabel.Font = Enum.Font.GothamMedium
currentPlayerLabel.Parent = statusFrame

-- ===== ВИДЖЕТ (свернутый режим) =====
local widget = Instance.new("Frame")
widget.Name = "Widget"
widget.Size = UDim2.new(0, 60, 0, 60)
widget.Position = UDim2.new(1, -80, 1, -80)
widget.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
widget.BackgroundTransparency = 0.15
widget.BorderSizePixel = 0
widget.Visible = false
widget.Parent = screenGui

local widgetCorner = Instance.new("UICorner")
widgetCorner.CornerRadius = UDim.new(1, 0)
widgetCorner.Parent = widget

local widgetIcon = Instance.new("TextLabel")
widgetIcon.Size = UDim2.new(1, 0, 1, 0)
widgetIcon.BackgroundTransparency = 1
widgetIcon.Text = "F"
widgetIcon.TextColor3 = Color3.fromRGB(179, 136, 255)
widgetIcon.TextSize = 28
widgetIcon.Font = Enum.Font.GothamBold
widgetIcon.Parent = widget

-- ===== ФУНКЦИИ =====
function updateStatus(name)
    currentPlayerLabel.Text = name or "не выбран"
end

function toggleWidget(show)
    widget.Visible = show
    mainFrame.Visible = not show
end

function collapseUI()
    toggleWidget(true)
end

function expandUI()
    toggleWidget(false)
end

-- ===== ПЕРЕТАСКИВАНИЕ =====
local dragData = {
    dragging = false,
    dragStart = nil,
    startPos = nil,
    object = mainFrame
}

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = true
        dragData.dragStart = input.Position
        dragData.startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragData.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragData.dragStart
        mainFrame.Position = UDim2.new(
            dragData.startPos.X.Scale,
            dragData.startPos.X.Offset + delta.X,
            dragData.startPos.Y.Scale,
            dragData.startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = false
    end
end)

-- Перетаскивание виджета
local widgetDragData = {
    dragging = false,
    dragStart = nil,
    startPos = nil
}

widget.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        widgetDragData.dragging = true
        widgetDragData.dragStart = input.Position
        widgetDragData.startPos = widget.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if widgetDragData.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - widgetDragData.dragStart
        widget.Position = UDim2.new(
            widgetDragData.startPos.X.Scale,
            widgetDragData.startPos.X.Offset + delta.X,
            widgetDragData.startPos.Y.Scale,
            widgetDragData.startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        widgetDragData.dragging = false
    end
end)

-- ===== СОБЫТИЯ КНОПОК =====
collapseBtn.MouseButton1Click:Connect(collapseUI)

closeBtn.MouseButton1Click:Connect(function()
    collapseUI()
end)

widget.MouseButton1Click:Connect(expandUI)

-- Выбор игрока из поля ввода
inputField.FocusLost:Connect(function()
    local text = inputField.Text
    if text ~= "" then
        selectedPlayer = text
        updateStatus(text)
    end
end)

-- Fling
flingBtn.MouseButton1Click:Connect(function()
    if selectedPlayer == "" then
        currentPlayerLabel.Text = "ВЫБЕРИ ИГРОКА!"
        currentPlayerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        task.wait(1)
        currentPlayerLabel.Text = selectedPlayer or "не выбран"
        currentPlayerLabel.TextColor3 = Color3.fromRGB(179, 136, 255)
        return
    end
    
    -- Анимация
    flingBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 230)
    task.wait(0.1)
    flingBtn.BackgroundColor3 = Color3.fromRGB(179, 136, 255)
    
    print("[Fling] FLING on " .. selectedPlayer)
    currentPlayerLabel.Text = "FLING: " .. selectedPlayer
    currentPlayerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    
    -- Найти игрока
    local target = nil
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Name == selectedPlayer or plr.DisplayName == selectedPlayer then
            target = plr
            break
        end
    end
    
    if target and target.Character then
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(
                math.random(-60, 60),
                math.random(100, 150),
                math.random(-60, 60)
            )
        end
    end
    
    task.wait(1)
    currentPlayerLabel.Text = selectedPlayer
    currentPlayerLabel.TextColor3 = Color3.fromRGB(179, 136, 255)
end)

-- Stop
stopBtn.MouseButton1Click:Connect(function()
    stopBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    task.wait(0.1)
    stopBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    stopBtn.BackgroundTransparency = 0.9
    
    print("[Fling] STOP")
    currentPlayerLabel.Text = "STOPPED"
    currentPlayerLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    -- Остановить всех
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
    
    task.wait(0.6)
    currentPlayerLabel.Text = selectedPlayer or "не выбран"
    currentPlayerLabel.TextColor3 = Color3.fromRGB(179, 136, 255)
end)

-- ===== КОМАНДА ДЛЯ ОТКРЫТИЯ =====
player.Chatted:Connect(function(msg)
    if msg == "/fling" then
        if mainFrame.Visible then
            collapseUI()
        else
            expandUI()
        end
    end
end)

-- ===== ЗАПУСК =====
expandUI()
print("Fling Player loaded! Use /fling to toggle.")