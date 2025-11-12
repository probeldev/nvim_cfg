local M = {}

-- Загрузка модулей
local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")
local query = require("db-workflow.modules.query")
local raw_query = require("db-workflow.modules.raw_query")
local struct_view = require("db-workflow.modules.struct_view")
local procedure_view = require("db-workflow.modules.procedure_view")
local telescope_menu = require("db-workflow.ui.telescope_menu")
local config_loader = require("db-workflow.core.config_loader")

function M.setup(user_config)
    config.setup(user_config)
    M.setup_commands()
    
    -- Проверяем наличие Telescope
    if not pcall(require, 'telescope') then
        utils.error("Telescope не установлен. Пожалуйста, установите telescope.nvim для работы плагина.")
        return
    end
    
    -- Автоматически загружаем конфигурацию при старте
    if config_loader.has_config() then
        utils.notify("✅ DB Workflow: Конфигурация загружена")
    else
        utils.notify("💡 DB Workflow: Для настройки подключения к БД создайте файл db-workflow.json", vim.log.levels.INFO)
    end
end

function M.setup_commands()
    -- Главная команда
    vim.api.nvim_create_user_command("DbWorkflow", function()
        M.show_main_menu()
    end, { desc = "Главное меню DB Workflow" })

    -- Индивидуальные команды
    vim.api.nvim_create_user_command("DbWorkflowRunQueryRaw", function(opts)
        raw_query.execute(opts)
    end, { range = true, desc = "Выполнить raw запрос db-workflow" })

    vim.api.nvim_create_user_command("DbWorkflowRunQuery", function(opts)
        query.execute(opts)
    end, { range = true, desc = "Выполнить запрос db-workflow" })

    vim.api.nvim_create_user_command("DbWorkflowShowStruct", function()
        M.show_structure_menu()
    end, { desc = "Показать структуры db-workflow" })

    vim.api.nvim_create_user_command("DbWorkflowShowProcedure", function()
        M.handle_procedure_selection()
    end, { desc = "Показать список процедур" })

    -- Новая команда для создания таблицы
    vim.api.nvim_create_user_command("DbWorkflowNewTable", function()
        M.create_new_table_query()
    end, { desc = "Создать шаблон запроса создания таблицы" })

    -- Новая команда для создания запроса
    vim.api.nvim_create_user_command("DbWorkflowNewQuery", function()
        M.create_new_query()
    end, { desc = "Создать новый SQL запрос" })

    -- Команда для создания конфигурационного файла
    vim.api.nvim_create_user_command("DbWorkflowCreateConfig", function()
        M.create_config_template()
    end, { desc = "Создать шаблон конфигурационного файла" })
end

-- Главное меню
function M.show_main_menu()
    telescope_menu.show_main_menu(function(selected_action)
        M.handle_menu_selection(selected_action)
    end)
end

-- Меню для структуры БД
function M.show_structure_menu()
    telescope_menu.show_structure_menu(function(selected_action)
        M.handle_structure_selection(selected_action)
    end)
end

-- Обработчик выбора в главном меню
function M.handle_menu_selection(action)
    if action == "new_query" then
        M.create_new_query()
    elseif action == "new_table" then
        M.create_new_table_query()
    elseif action == "run_query" then
        M.execute_query_from_menu()
    elseif action == "run_raw_query" then
        M.execute_raw_query_from_menu()
    elseif action == "show_structure" then
        M.show_structure_menu()
    elseif action == "show_procedure" then
        M.handle_procedure_selection()
    elseif action == "create_config" then
        M.create_config_template()
    end
end

-- Обработчик выбора в меню структуры
function M.handle_structure_selection(action)
    if action == "structure" then
        M.show_table_picker(struct_view.get_available_actions, "structure")
    elseif action == "data" then
        M.show_table_picker(struct_view.get_available_actions, "data")
    end
end

-- Обработчик выбора процедур
function M.handle_procedure_selection(action)
    M.show_table_picker(procedure_view.get_available_actions, "procedure")
end

-- Универсальная функция для выбора таблиц/процедур
function M.show_table_picker(get_actions_func, action_type)
    local actions = get_actions_func()
    if not actions or #actions == 0 then
        utils.warn("Нет доступных элементов в базе данных")
        return
    end
    
    local titles = {
        structure = "🏗️  Выберите таблицу для просмотра структуры",
        data = "📊 Выберите таблицу для просмотра данных", 
        procedure = "🔄 Выберите процедуру для просмотра"
    }
    
    telescope_menu.show_table_picker(actions, titles[action_type] or "Выберите элемент", function(selected_item)
        if selected_item then
            if action_type == "structure" then
                struct_view.run_action(selected_item)
            elseif action_type == "data" then
                utils.notify("Загружаем данные таблицы: " .. selected_item)
                M.create_table_data_query(selected_item)
            elseif action_type == "procedure" then
                procedure_view.run_action(selected_item)
            end
        end
    end)
end

-- Создание шаблона конфигурационного файла
function M.create_config_template()
    local success = config_loader.create_template_config()
    if success then
        -- Перезагружаем конфигурацию
        if config_loader.has_config() then
            utils.notify("✅ Конфигурация перезагружена")
        end
    end
end

-- Показать данные таблицы (альтернативный вызов)
function M.show_table_data()
    M.show_table_picker(struct_view.get_available_actions, "data")
end

-- Создание запроса для данных таблицы
function M.create_table_data_query(table_name)
    -- Генерируем уникальное имя для буфера
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local buffer_name = string.format("db_workflow://data/%s_%s.sql", table_name, timestamp)
    
    -- Создаем новый буфер
    vim.cmd("edit " .. vim.fn.fnameescape(buffer_name))
    local buf = vim.api.nvim_get_current_buf()
    
    -- Настраиваем буфер для SQL
    vim.bo[buf].filetype = "sql"
    vim.bo[buf].buftype = ""
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = true
    vim.bo[buf].readonly = false
    
    -- Создаем SQL запрос для данных таблицы
    local query_template = {
        "-- Данные таблицы: " .. table_name,
        "-- Создан: " .. os.date("%Y-%m-%d %H:%M:%S"),
        "",
        "SELECT * FROM " .. table_name,
        "LIMIT 1000;",
        ""
    }
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, query_template)
    
    -- Устанавливаем курсор после запроса
    vim.api.nvim_win_set_cursor(0, {6, 0})
    
    utils.notify("✅ Создан запрос для данных таблицы: " .. table_name)
end

-- Создание нового SQL запроса
function M.create_new_query()
    -- Генерируем уникальное имя для буфера
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local buffer_name = string.format("db_workflow://query/new_query_%s.sql", timestamp)
    
    -- Создаем новый буфер
    vim.cmd("edit " .. vim.fn.fnameescape(buffer_name))
    local buf = vim.api.nvim_get_current_buf()
    
    -- Настраиваем буфер для SQL
    vim.bo[buf].filetype = "sql"
    vim.bo[buf].buftype = ""
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = true
    vim.bo[buf].readonly = false
    
    -- Добавляем шаблон запроса
    local template = {
        "-- Новый SQL запрос",
        "-- Создан: " .. os.date("%Y-%m-%d %H:%M:%S"),
        "",
        "SELECT * FROM table_name",
        "WHERE condition = 'value'",
        "ORDER BY column_name",
        "LIMIT 100;",
        ""
    }
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, template)
    
    -- Устанавливаем курсор после шаблона
    vim.api.nvim_win_set_cursor(0, {8, 0})
    
    utils.notify("✅ Создан новый SQL запрос")
end

-- Функции для вызова из меню с проверкой выделения
function M.execute_query_from_menu()
    local selected_text, line_count = utils.get_visual_selection()
    local is_valid, error_msg = utils.validate_selection(selected_text)
    
    if not is_valid then
        utils.warn("Сначала выделите SQL запрос для выполнения")
        return
    end
    
    query.execute({})
end

function M.execute_raw_query_from_menu()
    local selected_text, line_count = utils.get_visual_selection()
    local is_valid, error_msg = utils.validate_selection(selected_text)
    
    if not is_valid then
        utils.warn("Сначала выделите SQL запрос для выполнения")
        return
    end
    
    raw_query.execute({})
end

-- Создание шаблона запроса для создания таблицы
function M.create_new_table_query()
    -- Генерируем уникальное имя для буфера
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local buffer_name = string.format("db_workflow://table/new_table_%s.sql", timestamp)
    
    -- Создаем новый буфер
    vim.cmd("edit " .. vim.fn.fnameescape(buffer_name))
    local buf = vim.api.nvim_get_current_buf()
    
    -- Настраиваем буфер для SQL
    vim.bo[buf].filetype = "sql"
    vim.bo[buf].buftype = ""
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = true
    vim.bo[buf].readonly = false
    
    -- Добавляем шаблон создания таблицы
    local template = {
        "-- Создание новой таблицы",
        "-- Создан: " .. os.date("%Y-%m-%d %H:%M:%S"),
        "",
        "CREATE TABLE table_name (",
        "    id INT AUTO_INCREMENT PRIMARY KEY,",
        "    -- Добавьте свои колонки здесь",
        "    -- column_name TYPE NOT NULL DEFAULT value,",
        "    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,",
        "    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP",
        ");",
        ""
    }
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, template)
    
    -- Устанавливаем курсор на место для редактирования
    vim.api.nvim_win_set_cursor(0, {6, 4})  -- Перемещаем курсор к строке с комментарием
    
    utils.notify("✅ Создан шаблон запроса создания таблицы")
end

-- API для внешнего использования
M.execute_query = query.execute
M.execute_raw_query = raw_query.execute
M.show_struct = struct_view.show
M.show_procedure = procedure_view.show
M.new_query = M.create_new_query

return M
