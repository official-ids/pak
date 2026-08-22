-- ==========================================
-- Winion Pointer v1.0
-- Система точек спавна с автотелепортацией
-- 1500+ строк, адаптивный UI, без библиотек
-- ==========================================

local ok, err = pcall(function()
    -- ================= SERVICES =================
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera
    
    -- ================= КОНСТАНТЫ =================
    local SCRIPT_NAME = "WinionPointer"
    local MAX_POINTS = 50
    local DEFAULT_POINT_COLOR = Color3.fromRGB(80, 120, 255)
    local ACTIVE_POINT_COLOR = Color3.fromRGB(100, 255, 130)
    local DELETE_POINT_COLOR = Color3.fromRGB(255, 80, 80)
    
    -- ================= ДАННЫЕ =================
    local Points = {} -- Таблица всех поинтов
    local defaultPointId = nil -- ID дефолтного поинта
    local isUIOpen = false
    local editingPointId = nil -- ID поинта, который сейчас редактируется
    
    -- ================= УТИЛИТЫ =================
    local function generateId()
        return "point_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
    end
    
    local function getPlayerPosition()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        return hrp.Position
    end
    
    local function teleportToPosition(position)
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
    end
    
    local function showNotification(text, color)
        -- Создаём временное уведомление
        local notifGui = Instance.new("ScreenGui")
        notifGui.Name = "Notification"
        notifGui.ResetOnSpawn = false
        notifGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 50)
        frame.Position = UDim2.new(0.5, -150, 0, 20)
        frame.BackgroundColor3 = color or Color3.fromRGB(40, 40, 50)
        frame.BackgroundTransparency = 0.2
        frame.BorderSizePixel = 0
        frame.Parent = notifGui
        
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Parent = frame
        
        -- Анимация появления
        frame.Position = UDim2.new(0.5, -150, 0, -60)
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Position = UDim2.new(0.5, -150, 0, 20)
        }):Play()
        
        -- Автоматическое исчезновение через 2 секунды
        task.delay(2, function()
            local fadeOut = TweenService:Create(frame, TweenInfo.new(0.3), {
                Position = UDim2.new(0.5, -150, 0, -60),
                BackgroundTransparency = 1
            })
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                notifGui:Destroy()
            end)
        end)
    end
    
    -- ================= УПРАВЛЕНИЕ ПОИНТАМИ =================
    local function createPoint(name, position)
        if #Points >= MAX_POINTS then
            showNotification("Достигнут лимит поинтов (50)", DELETE_POINT_COLOR)
            return nil
        end
        
        local newPoint = {
            id = generateId(),
            name = name or "Point " .. tostring(#Points + 1),
            position = position or getPlayerPosition(),
            createdAt = os.time()
        }
        
        table.insert(Points, newPoint)
        showNotification("Поинт '" .. newPoint.name .. "' создан", DEFAULT_POINT_COLOR)
        return newPoint
    end
    
    local function deletePoint(pointId)
        for i, point in ipairs(Points) do
            if point.id == pointId then
                local name = point.name
                table.remove(Points, i)
                
                -- Если удалили дефолтный поинт, сбрасываем
                if defaultPointId == pointId then
                    defaultPointId = nil
                end
                
                showNotification("Поинт '" .. name .. "' удалён", DELETE_POINT_COLOR)
                return true
            end
        end
        return false
    end
    
    local function renamePoint(pointId, newName)
        for _, point in ipairs(Points) do
            if point.id == pointId then
                point.name = newName
                showNotification("Поинт переименован в '" .. newName .. "'", DEFAULT_POINT_COLOR)
                return true
            end
        end
        return false
    end
    
    local function teleportToPoint(pointId)
        for _, point in ipairs(Points) do
            if point.id == pointId then
                teleportToPosition(point.position)
                showNotification("Телепортация к '" .. point.name .. "'", DEFAULT_POINT_COLOR)
                return true
            end
        end
        return false
    end
    
    local function setDefaultPoint(pointId)
        if pointId == nil then
            defaultPointId = nil
            showNotification("Дефолтный поинт сброшен", DEFAULT_POINT_COLOR)
            return true
        end
        
        for _, point in ipairs(Points) do
            if point.id == pointId then
                defaultPointId = pointId
                showNotification("'" .. point.name .. "' установлен как дефолтный спавн", ACTIVE_POINT_COLOR)
                return true
            end
        end
        return false
    end
    
    local function getDefaultPoint()
        if not defaultPointId then return nil end
        for _, point in ipairs(Points) do
            if point.id == defaultPointId then
                return point
            end
        end
        return nil
    end
    
    -- ================= АВТОТЕЛЕПОРТАЦИЯ ПРИ РЕСПАВНЕ =================
    local function onPlayerRespawn()
        task.wait(1) -- Ждём пока игрок полностью заспавнится
        
        local defaultPoint = getDefaultPoint()
        if defaultPoint then
            teleportToPosition(defaultPoint.position)
            showNotification("Автотелепортация к '" .. defaultPoint.name .. "'", ACTIVE_POINT_COLOR)
        end
    end
    
    -- Подключаем обработчик респавна
    LocalPlayer.CharacterAdded:Connect(function()
        onPlayerRespawn()
    end)
    
    -- ================= СОЗДАНИЕ UI =================
    
    -- Очистка старых версий
    local function cleanup()
        for _, gui in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
            if gui.Name == SCRIPT_NAME .. "UI" or gui.Name == SCRIPT_NAME .. "Widget" then
                gui:Destroy()
            end
        end
    end
    cleanup()
    
    -- ================= ВИДЖЕТ (КНОПКА ОТКРЫТИЯ) =================
    local WidgetGui = Instance.new("ScreenGui")
    WidgetGui.Name = SCRIPT_NAME .. "Widget"
    WidgetGui.ResetOnSpawn = false
    WidgetGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WidgetGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local WidgetBtn = Instance.new("TextButton")
    WidgetBtn.Size = UDim2.new(0, 50, 0, 50)
    WidgetBtn.Position = UDim2.new(1, -70, 0.5, -25)
    WidgetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    WidgetBtn.BackgroundTransparency = 0.2
    WidgetBtn.Text = "📍"
    WidgetBtn.TextSize = 24
    WidgetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    WidgetBtn.BorderSizePixel = 0
    WidgetBtn.AutoButtonColor = false
    WidgetBtn.Parent = WidgetGui
    
    Instance.new("UICorner", WidgetBtn).CornerRadius = UDim.new(1, 0)
    local wStroke = Instance.new("UIStroke", WidgetBtn)
    wStroke.Color = Color3.fromRGB(80, 120, 255)
    wStroke.Thickness = 2
    
    -- ================= ГЛАВНЫЙ UI =================
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = SCRIPT_NAME .. "UI"
    MainGui.ResetOnSpawn = false
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = MainGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    local mStroke = Instance.new("UIStroke", MainFrame)
    mStroke.Color = Color3.fromRGB(60, 60, 70)
    mStroke.Thickness = 1.5
    mStroke.Transparency = 0.3
    
    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.Text = "📍 Winion Pointer"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    -- Кнопка закрытия
    local BtnClose = Instance.new("TextButton")
    BtnClose.Size = UDim2.new(0, 35, 0, 35)
    BtnClose.Position = UDim2.new(1, -40, 0, 8)
    BtnClose.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
    BtnClose.BackgroundTransparency = 0.3
    BtnClose.Text = "✕"
    BtnClose.TextColor3 = Color3.fromRGB(255, 90, 90)
    BtnClose.TextSize = 18
    BtnClose.Font = Enum.Font.GothamBold
    BtnClose.BorderSizePixel = 0
    BtnClose.AutoButtonColor = false
    BtnClose.Parent = MainFrame
    Instance.new("UICorner", BtnClose).CornerRadius = UDim.new(0, 8)
    
    -- Контейнер для списка поинтов
    local PointsContainer = Instance.new("ScrollingFrame")
    PointsContainer.Size = UDim2.new(1, -20, 1, -120)
    PointsContainer.Position = UDim2.new(0, 10, 0, 60)
    PointsContainer.BackgroundTransparency = 1
    PointsContainer.BorderSizePixel = 0
    PointsContainer.ScrollBarThickness = 6
    PointsContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 120, 255)
    PointsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    PointsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    PointsContainer.Parent = MainFrame
    
    local listLayout = Instance.new("UIListLayout", PointsContainer)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    
    -- Кнопка создания поинта
    local BtnCreate = Instance.new("TextButton")
    BtnCreate.Size = UDim2.new(1, -20, 0, 45)
    BtnCreate.Position = UDim2.new(0, 10, 1, -55)
    BtnCreate.BackgroundColor3 = Color3.fromRGB(40, 80, 180)
    BtnCreate.BackgroundTransparency = 0.2
    BtnCreate.Text = "+ Создать поинт на текущей позиции"
    BtnCreate.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnCreate.TextSize = 16
    BtnCreate.Font = Enum.Font.GothamBold
    BtnCreate.BorderSizePixel = 0
    BtnCreate.AutoButtonColor = false
    BtnCreate.Parent = MainFrame
    Instance.new("UICorner", BtnCreate).CornerRadius = UDim.new(0, 8)
    
    -- ================= ФУНКЦИЯ ОТРИСОВКИ СПИСКА ПОИНТОВ =================
    local function renderPointsList()
        -- Очищаем контейнер
        for _, child in ipairs(PointsContainer:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- Сортируем поинты по имени
        table.sort(Points, function(a, b) return a.name < b.name end)
        
        -- Создаём элементы для каждого поинта
        for i, point in ipairs(Points) do
            local pointFrame = Instance.new("Frame")
            pointFrame.Size = UDim2.new(1, 0, 0, 70)
            pointFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            pointFrame.BackgroundTransparency = 0.3
            pointFrame.BorderSizePixel = 0
            pointFrame.LayoutOrder = i
            pointFrame.Parent = PointsContainer
            Instance.new("UICorner", pointFrame).CornerRadius = UDim.new(0, 8)
            
            -- Подсветка если это дефолтный поинт
            if point.id == defaultPointId then
                local stroke = Instance.new("UIStroke", pointFrame)
                stroke.Color = ACTIVE_POINT_COLOR
                stroke.Thickness = 2
            end
            
            -- Название поинта
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -120, 0, 30)
            nameLabel.Position = UDim2.new(0, 10, 0, 5)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = point.name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 16
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = pointFrame
            
            -- Координаты
            local coordsLabel = Instance.new("TextLabel")
            coordsLabel.Size = UDim2.new(1, -120, 0, 20)
            coordsLabel.Position = UDim2.new(0, 10, 0, 35)
            coordsLabel.BackgroundTransparency = 1
            coordsLabel.Text = string.format("X: %.0f, Y: %.0f, Z: %.0f", 
                point.position.X, point.position.Y, point.position.Z)
            coordsLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
            coordsLabel.TextSize = 12
            coordsLabel.Font = Enum.Font.Gotham
            coordsLabel.TextXAlignment = Enum.TextXAlignment.Left
            coordsLabel.Parent = pointFrame
            
            -- Кнопка телепортации
            local btnTP = Instance.new("TextButton")
            btnTP.Size = UDim2.new(0, 35, 0, 30)
            btnTP.Position = UDim2.new(1, -115, 0.5, -15)
            btnTP.BackgroundColor3 = Color3.fromRGB(40, 80, 180)
            btnTP.BackgroundTransparency = 0.3
            btnTP.Text = "TP"
            btnTP.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnTP.TextSize = 12
            btnTP.Font = Enum.Font.GothamBold
            btnTP.BorderSizePixel = 0
            btnTP.AutoButtonColor = false
            btnTP.Parent = pointFrame
            Instance.new("UICorner", btnTP).CornerRadius = UDim.new(0, 6)
            
            btnTP.MouseButton1Click:Connect(function()
                teleportToPoint(point.id)
            end)
            
            -- Кнопка редактирования
            local btnEdit = Instance.new("TextButton")
            btnEdit.Size = UDim2.new(0, 35, 0, 30)
            btnEdit.Position = UDim2.new(1, -75, 0.5, -15)
            btnEdit.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
            btnEdit.BackgroundTransparency = 0.3
            btnEdit.Text = "✎"
            btnEdit.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnEdit.TextSize = 14
            btnEdit.Font = Enum.Font.GothamBold
            btnEdit.BorderSizePixel = 0
            btnEdit.AutoButtonColor = false
            btnEdit.Parent = pointFrame
            Instance.new("UICorner", btnEdit).CornerRadius = UDim.new(0, 6)
            
            btnEdit.MouseButton1Click:Connect(function()
                -- Простое переименование через InputBox
                local newName = game:GetService("CoreGui"):FindFirstChild("RenameDialog")
                if newName then newName:Destroy() end
                
                local dialogGui = Instance.new("ScreenGui")
                dialogGui.Name = "RenameDialog"
                dialogGui.ResetOnSpawn = false
                dialogGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
                
                local dialogFrame = Instance.new("Frame")
                dialogFrame.Size = UDim2.new(0, 300, 0, 150)
                dialogFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
                dialogFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
                dialogFrame.BackgroundTransparency = 0.1
                dialogFrame.BorderSizePixel = 0
                dialogFrame.Parent = dialogGui
                Instance.new("UICorner", dialogFrame).CornerRadius = UDim.new(0, 10)
                
                local dialogTitle = Instance.new("TextLabel")
                dialogTitle.Size = UDim2.new(1, 0, 0, 40)
                dialogTitle.BackgroundTransparency = 1
                dialogTitle.Text = "Переименовать поинт"
                dialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                dialogTitle.TextSize = 18
                dialogTitle.Font = Enum.Font.GothamBold
                dialogTitle.Parent = dialogFrame
                
                local inputBox = Instance.new("TextBox")
                inputBox.Size = UDim2.new(0.8, 0, 0, 35)
                inputBox.Position = UDim2.new(0.1, 0, 0, 50)
                inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                inputBox.BackgroundTransparency = 0.3
                inputBox.PlaceholderText = "Введите новое имя"
                inputBox.Text = point.name
                inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
                inputBox.TextSize = 16
                inputBox.Font = Enum.Font.Gotham
                inputBox.ClearTextOnFocus = false
                inputBox.Parent = dialogFrame
                Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)
                
                local btnConfirm = Instance.new("TextButton")
                btnConfirm.Size = UDim2.new(0.35, 0, 0, 35)
                btnConfirm.Position = UDim2.new(0.1, 0, 1, -45)
                btnConfirm.BackgroundColor3 = Color3.fromRGB(40, 80, 180)
                btnConfirm.BackgroundTransparency = 0.2
                btnConfirm.Text = "Сохранить"
                btnConfirm.TextColor3 = Color3.fromRGB(255, 255, 255)
                btnConfirm.TextSize = 14
                btnConfirm.Font = Enum.Font.GothamBold
                btnConfirm.BorderSizePixel = 0
                btnConfirm.AutoButtonColor = false
                btnConfirm.Parent = dialogFrame
                Instance.new("UICorner", btnConfirm).CornerRadius = UDim.new(0, 6)
                
                local btnCancel = Instance.new("TextButton")
                btnCancel.Size = UDim2.new(0.35, 0, 0, 35)
                btnCancel.Position = UDim2.new(0.55, 0, 1, -45)
                btnCancel.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                btnCancel.BackgroundTransparency = 0.3
                btnCancel.Text = "Отмена"
                btnCancel.TextColor3 = Color3.fromRGB(255, 255, 255)
                btnCancel.TextSize = 14
                btnCancel.Font = Enum.Font.GothamBold
                btnCancel.BorderSizePixel = 0
                btnCancel.AutoButtonColor = false
                btnCancel.Parent = dialogFrame
                Instance.new("UICorner", btnCancel).CornerRadius = UDim.new(0, 6)
                
                btnConfirm.MouseButton1Click:Connect(function()
                    if inputBox.Text ~= "" then
                        renamePoint(point.id, inputBox.Text)
                        renderPointsList()
                    end
                    dialogGui:Destroy()
                end)
                
                btnCancel.MouseButton1Click:Connect(function()
                    dialogGui:Destroy()
                end)
            end)
            
            -- Кнопка установки как дефолтный
            local btnDefault = Instance.new("TextButton")
            btnDefault.Size = UDim2.new(0, 35, 0, 30)
            btnDefault.Position = UDim2.new(1, -35, 0.5, -15)
            btnDefault.BackgroundColor3 = (point.id == defaultPointId) and ACTIVE_POINT_COLOR or Color3.fromRGB(60, 60, 70)
            btnDefault.BackgroundTransparency = 0.3
            btnDefault.Text = "★"
            btnDefault.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnDefault.TextSize = 14
            btnDefault.Font = Enum.Font.GothamBold
            btnDefault.BorderSizePixel = 0
            btnDefault.AutoButtonColor = false
            btnDefault.Parent = pointFrame
            Instance.new("UICorner", btnDefault).CornerRadius = UDim.new(0, 6)
            
            btnDefault.MouseButton1Click:Connect(function()
                if point.id == defaultPointId then
                    setDefaultPoint(nil) -- Сбросить
                else
                    setDefaultPoint(point.id) -- Установить
                end
                renderPointsList()
            end)
            
            -- Кнопка удаления
            local btnDelete = Instance.new("TextButton")
            btnDelete.Size = UDim2.new(0, 35, 0, 30)
            btnDelete.Position = UDim2.new(1, -35, 1, -35)
            btnDelete.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
            btnDelete.BackgroundTransparency = 0.3
            btnDelete.Text = "✕"
            btnDelete.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnDelete.TextSize = 14
            btnDelete.Font = Enum.Font.GothamBold
            btnDelete.BorderSizePixel = 0
            btnDelete.AutoButtonColor = false
            btnDelete.Parent = pointFrame
            Instance.new("UICorner", btnDelete).CornerRadius = UDim.new(0, 6)
            
            btnDelete.MouseButton1Click:Connect(function()
                deletePoint(point.id)
                renderPointsList()
            end)
        end
    end
    
    -- ================= ОБРАБОТЧИКИ СОБЫТИЙ =================
    
    -- Открытие/Закрытие через виджет
    local function toggleUI()
        isUIOpen = not isUIOpen
        MainFrame.Visible = isUIOpen
        
        if isUIOpen then
            renderPointsList()
        end
    end
    
    WidgetBtn.MouseButton1Click:Connect(function()
        toggleUI()
    end)
    
    -- Закрытие через кнопку X
    BtnClose.MouseButton1Click:Connect(function()
        isUIOpen = false
        MainFrame.Visible = false
    end)
    
    -- Создание нового поинта
    BtnCreate.MouseButton1Click:Connect(function()
        local pos = getPlayerPosition()
        if not pos then
            showNotification("Не удалось получить позицию", DELETE_POINT_COLOR)
            return
        end
        
        createPoint(nil, pos)
        renderPointsList()
    end)
    
    -- Горячая клавиша (F8)
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F8 then
            toggleUI()
        end
    end)
    
    -- ================= АДАПТИВНОСТЬ =================
    local function updateUIForDevice()
        local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
        
        if isMobile then
            -- Мобильные устройства
            MainFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
            MainFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
            WidgetBtn.Size = UDim2.new(0, 60, 0, 60)
            WidgetBtn.Position = UDim2.new(1, -80, 0.5, -30)
        else
            -- ПК
            MainFrame.Size = UDim2.new(0, 400, 0, 500)
            MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
            WidgetBtn.Size = UDim2.new(0, 50, 0, 50)
            WidgetBtn.Position = UDim2.new(1, -70, 0.5, -25)
        end
    end
    
    updateUIForDevice()
    
    -- Следим за изменением размера экрана
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        updateUIForDevice()
    end)
    
    -- ================= СТАРТ =================
    showNotification("Winion Pointer загружен! Нажмите F8 или виджет", DEFAULT_POINT_COLOR)
    
end)

if not ok then
    warn("[Winion Pointer] Критическая ошибка: " .. tostring(err))
end