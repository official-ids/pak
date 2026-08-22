-- Загрузчик (Loader) для скрипта follow_player_v2.lua
-- Источник: https://github.com/official-ids/pak

local scriptUrl = "https://raw.githubusercontent.com/official-ids/pak/main/follow_player_v2.lua"

print("[Загрузчик] Инициализация процесса загрузки...")

local success, result = pcall(function()
    -- Второй аргумент 'true' включает кэширование, что повышает надежность и скорость повторных загрузок
    return game:HttpGet(scriptUrl, true)
end)

if success then
    print("[Загрузчик] Скрипт успешно получен. Начинается выполнение...")
    
    -- Использование loadstring или load для обеспечения совместимости с различными исполнителями
    local loadFunction = loadstring or load
    if loadFunction then
        loadFunction(result)()
    else
        warn("[Загрузчик] Критическая ошибка: функция loadstring/load недоступна в текущем исполнителе.")
    end
else
    warn("[Загрузчик] Не удалось загрузить скрипт. Причина: " .. tostring(result))
end