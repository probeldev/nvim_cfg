local M = {}

local config = require("db-workflow.core.config")
local buffer_manager = require("db-workflow.core.buffer_manager")
local utils = require("db-workflow.core.utils")

function M.show(output, title_suffix, filetype)
    local buffer_settings = config.get_buffer_settings()
    
    -- Генерируем уникальное имя буфера с timestamp
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local buffer_name = "db_workflow://" .. (title_suffix or "result") .. "_" .. timestamp
    
    -- Создаем или переключаемся на буфер
    local buf, win = buffer_manager.create_result_buffer(buffer_name, filetype)
    
    -- Подготавливаем содержимое с заголовком
    local timestamp_display = os.date("%H:%M:%S")
    local header = string.format("=== %s (generated at %s) ===", title_suffix or "Result", timestamp_display)
    local lines = utils.split_lines(output)
    
    -- Вставляем заголовок в начало
    table.insert(lines, 1, "")
    table.insert(lines, 1, header)
    table.insert(lines, 1, string.rep("=", #header))
    
    -- Записываем данные (очищаем буфер сначала)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Устанавливаем только для чтения
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    
    -- Настраиваем маппинги
    buffer_manager.setup_buffer_mappings(buf)
    
    -- Прокручиваем к началу данных (после заголовка)
    vim.api.nvim_win_set_cursor(win, {4, 0})
    
    utils.notify("✅ Данные загружены: " .. (title_suffix or "результат"))
    
    return buf, win
end

function M.show_structure(output, table_name, filetype)
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local buffer_name = "db_workflow://structure/" .. table_name .. "_" .. timestamp
    
    -- Создаем или переключаемся на буфер
    local buf, win = buffer_manager.create_result_buffer(buffer_name, filetype or "sql")
    
    -- Подготавливаем содержимое
    local timestamp_display = os.date("%H:%M:%S")
    local header = string.format("=== Structure: %s (loaded at %s) ===", table_name, timestamp_display)
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
    buffer_manager.setup_buffer_mappings(buf)
    
    -- Прокручиваем к началу данных
    vim.api.nvim_win_set_cursor(win, {5, 0})
    
    utils.notify("✅ Структура загружена: " .. table_name)
    
    return buf, win
end

return M
