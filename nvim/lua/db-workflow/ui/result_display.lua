local M = {}

local config = require("db-workflow.core.config")
local buffer_manager = require("db-workflow.core.buffer_manager")
local utils = require("db-workflow.core.utils")

function M.show(output, title_suffix, filetype)
    local buffer_settings = config.get_buffer_settings()
    local window_settings = config.get_window_settings()
    
    local buffer_name = buffer_settings.name
    if title_suffix then
        buffer_name = buffer_name .. "_" .. title_suffix
    end

    local buf, win = buffer_manager.create_result_buffer(buffer_name, filetype)
    
    -- Записываем данные
    local lines = utils.split_lines(output)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Устанавливаем только для чтения
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    
    -- Настраиваем размер окна
    buffer_manager.configure_buffer_size(win, lines, window_settings)
    
    -- Автоматически прокручиваем к началу
    vim.cmd("normal! gg")
    
    -- Настраиваем маппинги
    buffer_manager.setup_buffer_mappings(buf)
    
    utils.notify("Операция завершена! Результат в буфере: " .. buffer_name)
    
    return buf, win
end

return M
