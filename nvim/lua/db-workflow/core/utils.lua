local M = {}

-- Ленивая загрузка config_loader чтобы избежать циклической зависимости
local config_loader = nil

local function get_config_loader()
    if not config_loader then
        config_loader = require("db-workflow.core.config_loader")
    end
    return config_loader
end

function M.get_visual_selection()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)
    return table.concat(lines, "\n"), #lines
end

function M.execute_system_command(full_command, input)
    -- Добавляем параметры из конфигурации к команде
    local config_args = get_config_loader().get_command_args()
    local full_command_with_config = full_command .. " " .. config_args

    M.notify(full_command_with_config, vim.log.levels.ERROR)
    
    local output = vim.fn.system(full_command_with_config .. " ", input)
    
    if vim.v.shell_error ~= 0 then
        return nil, "Ошибка выполнения команды: код " .. vim.v.shell_error
    end
    
    return output, nil
end

function M.validate_selection(selected_text)
    if selected_text == "" then
        return false, "Нет выделенного текста!"
    end
    return true, nil
end

function M.split_lines(text)
    return vim.split(text, "\n")
end

function M.notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO)
end

function M.warn(message)
    M.notify(message, vim.log.levels.WARN)
end

function M.error(message)
    M.notify(message, vim.log.levels.ERROR)
end

-- Проверка наличия конфигурации
function M.has_db_config()
    return get_config_loader().has_config()
end

-- Получение информации о конфигурации
function M.get_config_info()
    local config_path = get_config_loader().get_config_path()
    if config_path then
        return "📁 " .. config_path
    else
        return "❌ Конфигурационный файл не найден"
    end
end

return M
