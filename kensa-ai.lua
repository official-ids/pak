--[[
    ESP Script для Roblox
    Адаптировано под современные экзекютеры с поддержкой Drawing API.
    Использует библиотеку Rayfield для UI.
]]

-- Загрузка библиотеки Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Инициализация главного окна
local Window = Rayfield:CreateWindow({
   Name = "ESP System",
   LoadingTitle = "Инициализация ESP",
   LoadingSubtitle = "Система визуализации",
   ConfigurationSaving = {
       Enabled = false,
       FolderName = nil,
       AutoSave = true
   },
   Discord = {
       Enabled = false
   }
})

-- Создание вкладки для настроек
local ESPTab = Window:CreateTab("Настройки ESP", 4483362458)

-- Сервисы и переменные
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Состояния переключателей
local MasterToggle = false
local BoxesEnabled = false
local TracersEnabled = false
local NamesEnabled = false

-- Таблица для хранения Drawing объектов (предотвращение утечек памяти)
local ESP_Data = {}

-- Функция создания Drawing объектов для нового игрока
local function InitializeESP(player)
    if player == LocalPlayer then return end
    if ESP_Data[player] then return end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Filled = false

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.Color = Color3.fromRGB(255, 50, 50)
    
    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Size = 14
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.fromRGB(255, 255, 255)

    -- Сохраняем ссылки для последующего обновления и очистки
    ESP_Data[player] = {
        Box = box,
        Tracer = tracer,
        Name = nameText
    }
end

-- Функция очистки памяти при выходе игрока
local function DestroyESP(player)
    if ESP_Data[player] then
        for _, drawingObj in pairs(ESP_Data[player]) do
            drawingObj.Visible = false
            -- Примечание: в Luau Drawing API объекты удаляются сборщиком мусора 
            -- при отсутствии ссылок. Установка Visible = false и очистка таблицы гарантируют корректную работу.
        end
        ESP_Data[player] = nil
    end
end

-- Инициализация ESP для уже присутствующих игроков
for _, player in pairs(Players:GetPlayers()) do
    InitializeESP(player)
end

-- Подписка на события входа и выхода игроков
Players.PlayerAdded:Connect(InitializeESP)
Players.PlayerRemoving:Connect(DestroyESP)

-- Основной цикл отрисовки (RenderStepped обеспечивает плавность)
RunService.RenderStepped:Connect(function()
    local Camera = workspace.CurrentCamera
    
    for player, drawings in pairs(ESP_Data) do
        local character = player.Character
        
        -- Безопасная проверка существования персонажа и его компонентов
        if MasterToggle and character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Head") and character:FindFirstChild("Humanoid") then
            local rootPart = character.HumanoidRootPart
            local head = character.Head
            local humanoid = character.Humanoid
            
            -- Проверяем, жив ли игрок
            if humanoid.Health > 0 then
                local rootPos, onScreen = Camera:WorldToScreenPoint(rootPart.Position)
                local headPos = Camera:WorldToScreenPoint(head.Position + Vector3.new(0, 0.5, 0))
                local footPos = Camera:WorldToScreenPoint(rootPart.Position - Vector3.new(0, 3, 0))

                if onScreen then
                    -- Вычисление дистанции (с проверкой на наличие персонажа у локального игрока)
                    local distance = 0
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude)
                    end

                    -- 1. Отрисовка Box (Квадрат)
                    if BoxesEnabled then
                        local height = math.abs(headPos.Y - footPos.Y)
                        local width = height * 1.2 -- Пропорции бокса
                        drawings.Box.Size = Vector2.new(width, height)
                        drawings.Box.Position = Vector2.new(rootPos.X - (width / 2), footPos.Y)
                        drawings.Box.Visible = true
                    else
                        drawings.Box.Visible = false
                    end

                    -- 2. Отрисовка Tracer (Линия)
                    if TracersEnabled then
                        drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        drawings.Tracer.Visible = true
                    else
                        drawings.Tracer.Visible = false
                    end

                    -- 3. Отрисовка Name (Имя и дистанция)
                    if NamesEnabled then
                        drawings.Name.Text = player.Name .. " [" .. distance .. "m]"
                        drawings.Name.Position = Vector2.new(rootPos.X, footPos.Y + 15)
                        drawings.Name.Visible = true
                    else
                        drawings.Name.Visible = false
                    end
                else
                    -- Если игрок за пределами экрана, скрываем элементы
                    drawings.Box.Visible = false
                    drawings.Tracer.Visible = false
                    drawings.Name.Visible = false
                end
            else
                -- Если игрок мертв, скрываем элементы
                drawings.Box.Visible = false
                drawings.Tracer.Visible = false
                drawings.Name.Visible = false
            end
        else
            -- Если ESP выключен или персонаж не загружен, скрываем элементы
            drawings.Box.Visible = false
            drawings.Tracer.Visible = false
            drawings.Name.Visible = false
        end
    end
end)

-- Создание элементов UI (Переключатели)
ESPTab:CreateToggle({
    Name = "Главный переключатель ESP",
    CurrentValue = false,
    Flag = "MasterESP",
    Callback = function(Value)
        MasterToggle = Value
    end,
})

ESPTab:CreateToggle({
    Name = "ESP Boxes (Квадраты)",
    CurrentValue = false,
    Flag = "ESPBoxes",
    Callback = function(Value)
        BoxesEnabled = Value
    end,
})

ESPTab:CreateToggle({
    Name = "ESP Tracers (Линии)",
    CurrentValue = false,
    Flag = "ESPTracers",
    Callback = function(Value)
        TracersEnabled = Value
    end,
})

ESPTab:CreateToggle({
    Name = "ESP Names (Имена и дистанция)",
    CurrentValue = false,
    Flag = "ESPNames",
    Callback = function(Value)
        NamesEnabled = Value
    end,
})

-- Уведомление об успешной загрузке
Rayfield:Notify({
    Title = "ESP Загружен",
    Content = "Скрипт успешно инициализирован. Настройте параметры во вкладке ESP.",
    Duration = 5,
    Image = 4483362458,
})