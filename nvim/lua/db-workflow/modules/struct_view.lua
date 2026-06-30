local M = {}

local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")
local structure_display = require("db-workflow.ui.structure_display")  -- Новый дисплей
local db_executor = require("db-workflow.core.db_executor")

function M.show()
    local actions = M.get_available_actions()
    if not actions or #actions == 0 then
        utils.warn("Нет доступных таблиц в базе данных")
        return
    end
    
    telescope_menu.show_table_picker(actions, "🗃️  Выберите таблицу", function(selected_action)
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

    local db_config = require("db-workflow.core.config_loader").load_config()
    local sql_query = "SHOW TABLES"
    
    local success, output, err = pcall(function()
        local out, e = db_executor.execute_query(sql_query, { raw = true })
        return out, e
    end)
    if not success then
        utils.error("Ошибка получения списка таблиц (pcall): " .. tostring(output))
        return {}
    end
    if not output then
        utils.error("Ошибка получения списка таблиц: " .. tostring(err))
        return {}
    end
    
    local actions = {}
    for line in output:gmatch("[^\r\n]+") do
        line = vim.trim(line)
        if line ~= "" and line ~= db_config.dbname then  -- Пропускаем имя базы данных
            local table_name = line:gsub("^%s*'|'%s*$", "")  -- Убираем кавычки если есть
            table.insert(actions, {
                value = table_name,
                display = table_name,
                ordinal = table_name
            })
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

    -- Используем DESCRIBE для получения структуры таблицы
    local sql_query = string.format("DESCRIBE `%s`", action_name)
    
    local success, output = pcall(db_executor.execute_query, sql_query, { format = true })
    if not success or not output then
        utils.error("Ошибка получения структуры таблицы: " .. tostring(output))
        return
    end
    
    -- Используем НОВУЮ функцию для структур (без сплита)
    structure_display.show_structure(output, action_name, "sql")
end

return M
