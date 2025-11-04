local M = {}

local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")
local result_display = require("db-workflow.ui.result_display")

function M.execute(opts)
    local selected_text, line_count = utils.get_visual_selection()
    
    local is_valid, error_msg = utils.validate_selection(selected_text)
    if not is_valid then
        utils.warn(error_msg)
        return
    end

    utils.notify("Выполняем raw запрос: " .. line_count .. " строк")

    local output, err = utils.execute_system_command(config.get_command() .. " -query -raw", selected_text)
    if not output then
        utils.error(err)
        return
    end

    result_display.show("=== Результат raw запроса: ===\n" .. output, "raw")
end

return M
