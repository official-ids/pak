-- ==========================================
-- Winion Spectate Loader
-- Repository: github.com/official-ids/pak
-- ==========================================

local SCRIPT_URL = "https://raw.githubusercontent.com/official-ids/pak/main/spectater/v1.lua"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. Очистка старого лоадера (если был запущен дважды)
local oldLoader = PlayerGui:FindFirstChild("WinionLoaderUI")
if oldLoader then oldLoader:Destroy() end

-- 2. Создание UI Лоадера
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WinionLoaderUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 110)
Frame.Position = UDim2.new(0.5, -130, 0.5, -55)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(50, 50, 60)
Stroke.Thickness = 1.5
Stroke.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Winion Spectate"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "Подключение к репозиторию..."
Status.TextColor3 = Color3.fromRGB(160, 160, 170)
Status.Font = Enum.Font.Gotham
Status.TextSize = 14
Status.Parent = Frame

local ProgressBg = Instance.new("Frame")
ProgressBg.Size = UDim2.new(0.8, 0, 0, 6)
ProgressBg.Position = UDim2.new(0.1, 0, 1, -20)
ProgressBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ProgressBg.BorderSizePixel = 0
ProgressBg.Parent = Frame
Instance.new("UICorner", ProgressBg).CornerRadius = UDim.new(1, 0)

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0, 0, 1, 0)
ProgressBar.BackgroundColor3 = Color3.fromRGB(80, 120, 255) -- Акцентный цвет
ProgressBar.BorderSizePixel = 0
ProgressBar.Parent = ProgressBg
Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(1, 0)

-- 3. Логика загрузки
task.spawn(function()
    -- Анимация "ожидания" пока идет запрос
    for i = 0, 70, 5 do
        if not ScreenGui.Parent then break end
        TweenService:Create(ProgressBar, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
            Size = UDim2.new(i / 100, 0, 1, 0)
        }):Play()
        task.wait(0.05)
    end

    -- Попытка получить скрипт
    local success, result = pcall(function()
        return game:HttpGet(SCRIPT_URL, true) -- true обходит некоторые фильтры Roblox для raw-ссылок
    end)

    if success and result and result ~= "" then
        Status.Text = "Загрузка завершена! Запуск..."
        Status.TextColor3 = Color3.fromRGB(100, 255, 130)
        TweenService:Create(ProgressBar, TweenInfo.new(0.3), {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(100, 255, 130)
        }):Play()

        task.wait(0.4)

        -- Компиляция и выполнение основного скрипта
        local func, err = loadstring(result)
        if func then
            func()
        else
            warn("[Winion Loader] Ошибка компиляции основного скрипта: " .. tostring(err))
            Status.Text = "Ошибка компиляции!"
            Status.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    else
        warn("[Winion Loader] Не удалось загрузить скрипт. Проверьте интернет или URL.")
        Status.Text = "Ошибка загрузки!"
        Status.TextColor3 = Color3.fromRGB(255, 80, 80)
        TweenService:Create(ProgressBar, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        }):Play()
    end

    -- 4. Очистка UI лоадера через 1.5 секунды после завершения
    task.delay(1.5, function()
        if ScreenGui.Parent then
            local fadeOut = TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            })
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                ScreenGui:Destroy()
            end)
            
            -- Скрываем текст и обводку для плавности
            TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(Status, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        end
    end)
end)