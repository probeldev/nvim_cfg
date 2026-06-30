local M = {}

-- Имя конфигурационного файла
local CONFIG_FILE_NAME = "db-workflow.json"

-- Значения по умолчанию
local default_config = {
    provider = "mysql",
    dbhost = "localhost",
    dbport = "3306",
    dbuser = "root",
    dbpassword = "",
    dbname = "test",
    -- Пример кастомной команды (например, docker exec):
    -- command = "docker exec -i my-mysql mysql -hlocalhost -uroot -psecret mydb -e {query}"
    command = nil
}

-- Поиск конфигурационного файла в дереве директорий
function M.find_config_file()
    local current_dir = vim.fn.getcwd()
    local dir = current_dir
    
    -- Проверяем текущую директорию и все родительские
    while dir ~= "" and dir ~= "/" do
        local config_path = dir .. "/" .. CONFIG_FILE_NAME
        if vim.fn.filereadable(config_path) == 1 then
            return config_path
        end
        
        -- Переходим к родительской директории
        local parent_dir = vim.fn.fnamemodify(dir, ":h")
        if parent_dir == dir then
            break
        end
        dir = parent_dir
    end
    
    return nil
end

-- Загрузка конфигурации из файла
function M.load_config()
    local config_path = M.find_config_file()
    
    if not config_path then
        vim.notify("📝 Конфигурационный файл " .. CONFIG_FILE_NAME .. " не найден. Используются настройки по умолчанию.", vim.log.levels.INFO)
        return default_config
    end
    
    local success, file_content = pcall(vim.fn.readfile, config_path)
    if not success or not file_content then
        vim.notify("❌ Не удалось прочитать файл конфигурации: " .. config_path, vim.log.levels.WARN)
        return default_config
    end
    
    local json_text = table.concat(file_content, "\n")
    local ok, config_data = pcall(vim.fn.json_decode, json_text)
    
    if not ok or type(config_data) ~= "table" then
        vim.notify("❌ Ошибка парсинга JSON в файле: " .. config_path, vim.log.levels.WARN)
        return default_config
    end
    
    -- Объединяем с настройками по умолчанию
    local merged_config = vim.tbl_deep_extend("force", {}, default_config, config_data)
    
    vim.notify("✅ Загружена конфигурация из: " .. config_path, vim.log.levels.INFO)
    return merged_config
end

-- Получение аргументов командной строки из конфигурации
function M.get_command_args()
    local db_config = M.load_config()
    local args = {}
    
    -- Добавляем параметры в командную строку
    if db_config.provider then
        table.insert(args, "-provider=" .. db_config.provider)
    end
    
    if db_config.dbhost then
        table.insert(args, "-dbhost=" .. db_config.dbhost)
    end
    
    if db_config.dbport then
        table.insert(args, "-dbport=" .. db_config.dbport)
    end
    
    if db_config.dbuser then
        table.insert(args, "-dbuser=" .. db_config.dbuser)
    end
    
    if db_config.dbpassword then
        table.insert(args, "-dbpassword=" .. db_config.dbpassword)
    end
    
    if db_config.dbname then
        table.insert(args, "-dbname=" .. db_config.dbname)
    end
    
    return table.concat(args, " ")
end

-- Проверка существования конфигурационного файла
function M.has_config()
    return M.find_config_file() ~= nil
end

-- Получение пути к конфигурационному файлу
function M.get_config_path()
    return M.find_config_file()
end

-- Создание шаблонного конфигурационного файла
function M.create_template_config()
    local config_path = vim.fn.getcwd() .. "/" .. CONFIG_FILE_NAME
    
    if vim.fn.filereadable(config_path) == 1 then
        vim.notify("📝 Конфигурационный файл уже существует: " .. config_path, vim.log.levels.WARN)
        return false
    end
    
    local template = {
        "{",
        '  "provider": "mysql",',
        '  "dbhost": "localhost",',
        '  "dbport": "3306",',
        '  "dbuser": "root",',
        '  "dbpassword": "your_password",',
        '  "dbname": "your_database",',
        '  "command": "docker exec -it mysql mysql"',
        "}"
    }
    
    local success = pcall(vim.fn.writefile, template, config_path)
    if success then
        vim.notify("✅ Создан шаблон конфигурационного файла: " .. config_path, vim.log.levels.INFO)
        return true
    else
        vim.notify("❌ Не удалось создать конфигурационный файл: " .. config_path, vim.log.levels.ERROR)
        return false
    end
end

return M
