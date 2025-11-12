local M = {}

local config = require("db-workflow.core.config")
local buffer_manager = require("db-workflow.core.buffer_manager")
local utils = require("db-workflow.core.utils")

-- Отображение структуры в полноэкранном режиме (как раньше)
function M.show_structure(output, table_name, filetype)
    local buffer_settings = config.get_buffer_settings()
    
    local buffer_name = "db_workflow://structure/" .. table_name
    
    -- Создаем или переключаемся на буфер (в новом окне, без сплита)
    local buf = vim.api.nvim_create_buf(false, true)  -- scratch buffer

    -- Настраиваем буфер
    vim.bo[buf].buftype = ""
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = filetype or "sql"
    vim.bo[buf].modifiable = true
    vim.bo[buf].readonly = false

    -- Устанавливаем имя буфера
    vim.api.nvim_buf_set_name(buf, buffer_name)

    -- Открываем буфер в текущем окне
    vim.cmd("edit " .. vim.fn.fnameescape(buffer_name))

    -- Подготавливаем содержимое
    local timestamp = os.date("%H:%M:%S")
    local header = string.format("=== Structure: %s (loaded at %s) ===", table_name, timestamp)
    local lines = utils.split_lines(output)
    
    -- Вставляем красивый заголовок
    local separator = string.rep("=", #header)
    table.insert(lines, 1, "")
    table.insert(lines, 1, header)
    table.insert(lines, 1, separator)
    table.insert(lines, 1, "")
    
    -- Записываем данные
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Устанавливаем только для чтения
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    
    -- Настраиваем маппинги
    local mappings = {
        { 'n', 'q', ':q<CR>', { noremap = true, silent = true } },
        { 'n', '<Esc>', ':q<CR>', { noremap = true, silent = true } },
    }

    for _, mapping in ipairs(mappings) do
        vim.api.nvim_buf_set_keymap(buf, mapping[1], mapping[2], mapping[3], mapping[4])
    end
    
    -- Прокручиваем к началу данных
    vim.api.nvim_win_set_cursor(0, {5, 0})
    
    utils.notify("✅ Структура загружена: " .. table_name)
    
    return buf
end

return M
