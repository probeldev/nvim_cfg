local M = {}

-- Ленивая загрузка config_loader чтобы избежать циклической зависимости
local config_loader = nil
local db_executor = nil

local function get_config_loader()
    if not config_loader then
        config_loader = require("db-workflow.core.config_loader")
    end
    return config_loader
end

local function get_db_executor()
    if not db_executor then
        db_executor = require("db-workflow.core.db_executor")
    end
    return db_executor
end

function M.get_visual_selection()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)
    return table.concat(lines, "\n"), #lines
end

-- Удалили старую функцию execute_system_command

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
    level = level or vim.log.levels.INFO
    -- Показываем только предупреждения и ошибки, информационные логи отключаем
    if level < vim.log.levels.WARN then
        return
    end
    vim.notify(message, level)
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

-- Проверка доступности mysql
function M.is_mysql_available()
    return get_db_executor().check_mysql_available()
end

-- Проверка подключения к БД
function M.test_db_connection()
    return get_db_executor().test_connection()
end

return M
