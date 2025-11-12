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

    local result = string.match(output, "Create Procedure:%s+(.+)")
	local result2 = string.match(result, "(.*)character_set_client:")

    -- Возвращаем как есть, без обработки
    return result2
end

return M
