local M = {}

local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")
local structure_display = require("db-workflow.ui.structure_display")
local db_executor = require("db-workflow.core.db_executor")
local telescope_menu = require("db-workflow.ui.telescope_menu")

function M.show()
    local actions = M.get_available_actions()
    if not actions or #actions == 0 then
        utils.warn("Нет доступных процедур в базе данных")
        return
    end
    
    telescope_menu.show_table_picker(actions, "🔄 Выберите процедуру", function(selected_action)
        if selected_action then
            utils.notify("Загружаем структуру: " .. selected_action)
            M.run_action(selected_action)
        end
    end)
end

-- Экспортируем функцию получения доступных действий
function M.get_available_actions()
    -- Проверяем доступность mysql
    if not utils.is_mysql_available() then
        utils.error("Утилита mysql не найдена. Проверьте настройки mysql_path в конфигурации.")
        return {}
    end

    -- Используем INFORMATION_SCHEMA для получения списка процедур
    local sql_query = [[
        SELECT ROUTINE_NAME 
        FROM INFORMATION_SCHEMA.ROUTINES 
        WHERE ROUTINE_TYPE = 'PROCEDURE' 
        AND ROUTINE_SCHEMA = DATABASE()
        ORDER BY ROUTINE_NAME
    ]]
    
    local success, output = pcall(db_executor.execute_query, sql_query, { raw = true })
    if not success or not output then
        utils.error("Ошибка получения списка процедур: " .. tostring(output))
        return {}
    end
    
    local actions = {}
    local lines = vim.split(output, "\n")
    
    for _, line in ipairs(lines) do
        line = vim.trim(line)
        -- Ищем строки с именами процедур (игнорируем заголовки)
        if line ~= "" and not line:match("ROUTINE_NAME") and not line:match("^[%+|%-]") then
            local procedure_name = line
            if procedure_name and procedure_name ~= "" then
                table.insert(actions, {
                    value = procedure_name,
                    display = procedure_name,
                    ordinal = procedure_name
                })
            end
        end
    end
    
    return actions
end

function M.run_action(action_name)
    -- Проверяем доступность mysql
    if not utils.is_mysql_available() then
        utils.error("Утилита mysql не найдена. Проверьте настройки mysql_path в конфигурации.")
        return
    end

    -- Простой и безопасный метод
    local procedure_body, error_msg = M.get_procedure_simple(action_name)
    if procedure_body then
        structure_display.show_structure(procedure_body, action_name, "sql")
    else
        utils.error("Не удалось получить тело процедуры: " .. error_msg)
    end
end

-- Простой метод через db_executor
function M.get_procedure_simple(action_name)
    local sql_query = string.format("SHOW CREATE PROCEDURE `%s`\\G", action_name)
    
    -- Получаем сырой вывод без обработки
    local success, output = pcall(db_executor.execute_query, sql_query, { 
        raw = true,
        format = false
    })
    
    if not success or not output then
        return nil, "Ошибка запроса: " .. tostring(output)
    end

    -- Очищаем символы возврата каретки сразу
    output = output:gsub("\r", "")

    -- Парсим вертикальный вывод
    local result = string.match(output, "Create Procedure:%s+(.+)")
    if not result then
        return nil, "Не найден 'Create Procedure' в выводе"
    end
    
    local result2 = string.match(result, "(.*)character_set_client:")
    if not result2 then
        -- Если не нашли character_set_client, возвращаем все что после Create Procedure
        result2 = result
    end

    -- Очищаем результат
    local clean_result = M.clean_procedure_body(result2)
    
    return clean_result
end

-- Очистка тела процедуры
function M.clean_procedure_body(body)
    if not body then return nil end
    
    -- Убираем лишние пробелы в начале/конце
    body = vim.trim(body)
    
    -- Убираем возможные символы форматирования
    body = body:gsub("^%*+%s*", ""):gsub("%s*%*+$", "")
    
    -- Убираем пустые строки в начале и конце
    local lines = vim.split(body, "\n")
    local clean_lines = {}
    
    -- Убираем пустые строки в начале
    local start_index = 1
    while start_index <= #lines and vim.trim(lines[start_index]) == "" do
        start_index = start_index + 1
    end
    
    -- Убираем пустые строки в конце
    local end_index = #lines
    while end_index >= start_index and vim.trim(lines[end_index]) == "" do
        end_index = end_index - 1
    end
    
    -- Собираем очищенные строки
    for i = start_index, end_index do
        table.insert(clean_lines, lines[i])
    end
    
    if #clean_lines == 0 then
        return nil
    end
    
    return table.concat(clean_lines, "\n")
end

return M
