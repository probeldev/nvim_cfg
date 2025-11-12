local M = {}

local config = require("db-workflow.core.config")
local config_loader = require("db-workflow.core.config_loader")
local utils = require("db-workflow.core.utils")

-- Функция для построения команды mysql
function M.build_mysql_command()
    local db_config = config_loader.load_config()
    
    local cmd_parts = {
        config.get_mysql_path(),
        "-h" .. db_config.dbhost,
        "-P" .. db_config.dbport,
        "-u" .. db_config.dbuser,
        "-p" .. db_config.dbpassword,
        db_config.dbname
    }
    
    return table.concat(cmd_parts, " ")
end

-- Парсинг результата mysql в формат таблицы
local function parse_mysql_output(output)
    local lines = vim.split(output, "\n")
    local result_lines = {}
    
    -- Пропускаем пустые строки в начале
    local start_idx = 1
    while start_idx <= #lines and vim.trim(lines[start_idx]) == "" do
        start_idx = start_idx + 1
    end
    
    -- Находим начало данных (после заголовков)
    for i = start_idx, #lines do
        if lines[i]:match("^%s*%+%-") then  -- строка с разделителями таблицы
            start_idx = i
            break
        end
    end
    
    -- Если не нашли таблицу в формате --table, возвращаем как есть
    if start_idx > #lines or not lines[start_idx]:match("^%s*%+%-") then
        return output
    end
    
    -- Собираем все строки начиная с таблицы
    for i = start_idx, #lines do
        table.insert(result_lines, lines[i])
    end
    
    return table.concat(result_lines, "\n")
end

-- Выполнение SQL запроса
function M.execute_query(sql_query, options)
    options = options or {}
    local format_output = options.format ~= false  -- По умолчанию форматируем
    local return_raw = options.raw == true
    
    local mysql_cmd = M.build_mysql_command()
    
    if not return_raw then
        -- Используем форматирование таблицы
        mysql_cmd = mysql_cmd .. " --table --batch --raw"
    else
        -- Для raw данных используем --batch --raw без форматирования таблицы
        mysql_cmd = mysql_cmd .. " --batch --raw"
    end
    
    -- Выполняем команду с переданным SQL запросом
    local full_command = mysql_cmd .. " -e " .. vim.fn.shellescape(sql_query)
    
    local output = vim.fn.system(full_command)
    
    if vim.v.shell_error ~= 0 then
        return nil, "Ошибка выполнения SQL запроса: " .. output
    end
    
    if not return_raw and format_output then
        output = parse_mysql_output(output)
    end
    
    return output, nil
end

-- Проверка доступности mysql
function M.check_mysql_available()
    local result = vim.fn.system(config.get_mysql_path() .. " --version")
    return vim.v.shell_error == 0
end

-- Проверка подключения к БД
function M.test_connection()
    local mysql_cmd = M.build_mysql_command() .. " -e " .. vim.fn.shellescape("SELECT 1")
    local output = vim.fn.system(mysql_cmd)
    
    if vim.v.shell_error ~= 0 then
        return false, "Ошибка подключения: " .. output
    end
    
    return true, "Подключение успешно"
end

return M
