local M = {}

local config = require("db-workflow.core.config")
local config_loader = require("db-workflow.core.config_loader")
local utils = require("db-workflow.core.utils")

local function command_has_flag(cmd, flag)
    -- Ищем флаг как отдельное слово (например: -h, --host, -u, --user)
    -- Учитываем, что флаг может быть в начале строки, после пробела или после равно
    local pattern = "%s" .. flag .. "%f[%=%s]"
    if cmd:match("^" .. flag .. "%f[%=%s]") then
        return true
    end
    return cmd:match(pattern) ~= nil
end

local function command_has_host(cmd)
    return command_has_flag(cmd, "%-h") or command_has_flag(cmd, "%-%-host")
end

local function command_has_port(cmd)
    return command_has_flag(cmd, "%-P") or command_has_flag(cmd, "%-%-port")
end

local function command_has_user(cmd)
    return command_has_flag(cmd, "%-u") or command_has_flag(cmd, "%-%-user")
end

local function command_has_password(cmd)
    return command_has_flag(cmd, "%-p") or command_has_flag(cmd, "%-%-password")
end

local function command_has_database(cmd)
    -- Проверяем, задана ли база данных (последний аргумент без дефиса)
    -- Это эвристика: если в команде уже есть аргумент без - в конце, считаем, что база задана
    local trimmed = vim.trim(cmd)
    local last_token = trimmed:match("([^%s]+)$")
    return last_token and not last_token:match("^%-")
end

-- Функция для построения команды mysql
function M.build_mysql_command()
    local db_config = config_loader.load_config()

    local cmd
    if db_config.command and vim.trim(db_config.command) ~= "" then
        cmd = vim.trim(db_config.command)
    else
        cmd = config.get_mysql_path()
    end

    local parts = { cmd }

    -- Добавляем параметры подключения, если их ещё нет в команде
    if not command_has_host(cmd) and db_config.dbhost then
        table.insert(parts, "-h" .. db_config.dbhost)
    end

    if not command_has_port(cmd) and db_config.dbport then
        table.insert(parts, "-P" .. db_config.dbport)
    end

    if not command_has_user(cmd) and db_config.dbuser then
        table.insert(parts, "-u" .. db_config.dbuser)
    end

    if not command_has_password(cmd) and db_config.dbpassword and db_config.dbpassword ~= "" then
        table.insert(parts, "-p" .. db_config.dbpassword)
    end

    if db_config.dbname and db_config.dbname ~= "" then
        table.insert(parts, db_config.dbname)
    end

    return table.concat(parts, " ")
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

    -- Флаги форматирования и SQL запрос всегда добавляются в конец,
    -- после имени базы данных, чтобы mysql корректно их распознал
    local format_flags
    if not return_raw then
        format_flags = " --table --batch --raw"
    else
        format_flags = " --batch --raw"
    end

    local full_command = mysql_cmd .. format_flags .. " -e " .. vim.fn.shellescape(sql_query)

    -- DEBUG
    vim.notify("DBWorkflow command: " .. full_command, vim.log.levels.WARN)

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
