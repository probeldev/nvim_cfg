local M = {}

local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")
local result_display = require("db-workflow.ui.result_display")
local db_executor = require("db-workflow.core.db_executor")  -- Новый модуль

function M.execute(opts)
    local selected_text, line_count = utils.get_visual_selection()
    
    local is_valid, error_msg = utils.validate_selection(selected_text)
    if not is_valid then
        utils.warn(error_msg)
        return
    end

    utils.notify("Выполняем SQL запрос: " .. line_count .. " строк")

    -- Проверяем доступность mysql
    if not db_executor.check_mysql_available() then
        utils.error("Утилита mysql не найдена. Проверьте настройки mysql_path в конфигурации.")
        return
    end

    local output, err = db_executor.execute_query(selected_text, { format = true })
    if not output then
        utils.error(err)
        return
    end

    result_display.show(output, "sql_query_result", "sql")
end

return M
