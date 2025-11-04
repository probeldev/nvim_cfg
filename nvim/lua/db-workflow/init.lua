local M = {}

-- Загрузка модулей
local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")
local query = require("db-workflow.modules.query")
local raw_query = require("db-workflow.modules.raw_query")
local struct_view = require("db-workflow.modules.struct_view")
local main_menu = require("db-workflow.ui.main_menu")
local nvim_ui_picker = require("db-workflow.ui.nvim_ui_picker")

function M.setup(user_config)
    config.setup(user_config)
    M.setup_commands()
end

function M.setup_commands()
    -- Главная команда
    vim.api.nvim_create_user_command("DbWorkflow", function()
        M.show_main_menu()
    end, { desc = "Главное меню DB Workflow" })

    -- Индивидуальные команды (оставляем для обратной совместимости)
    vim.api.nvim_create_user_command("DbWorkflowRunQueryRaw", function(opts)
        raw_query.execute(opts)
    end, { range = true, desc = "Выполнить raw запрос db-workflow" })

    vim.api.nvim_create_user_command("DbWorkflowRunQuery", function(opts)
        query.execute(opts)
    end, { range = true, desc = "Выполнить запрос db-workflow" })

    vim.api.nvim_create_user_command("DbWorkflowShowStruct", function()
        M.show_structure_menu()
    end, { desc = "Показать структуры db-workflow" })

    -- Новая команда для создания запроса
    vim.api.nvim_create_user_command("DbWorkflowNewQuery", function()
        M.create_new_query()
    end, { desc = "Создать новый SQL запрос" })
end

-- Главное меню
function M.show_main_menu()
    main_menu.show_main_menu(function(selected_action)
        M.handle_menu_selection(selected_action)
    end)
end

-- Меню для структуры БД
function M.show_structure_menu()
    main_menu.show_structure_submenu(function(selected_action)
        M.handle_structure_selection(selected_action)
    end)
end

-- Обработчик выбора в главном меню
function M.handle_menu_selection(action)
    if action == "new_query" then
        M.create_new_query()
    elseif action == "run_query" then
        M.execute_query_from_menu()
    elseif action == "run_raw_query" then
        M.execute_raw_query_from_menu()
    elseif action == "show_structure" then
        M.show_structure_menu()
    end
end

-- Обработчик выбора в меню структуры
function M.handle_structure_selection(action)
    if action == "structure" then
        struct_view.show()
    elseif action == "data" then
        M.show_table_data()
    end
end

-- Показать данные таблицы
function M.show_table_data()
    local actions = struct_view.get_available_actions()
    if not actions or #actions == 0 then
        utils.warn("Нет доступных таблиц в базе данных")
        return
    end
    
    nvim_ui_picker.show_actions_best(actions, function(selected_table)
        if selected_table then
            utils.notify("Загружаем данные таблицы: " .. selected_table)
            M.create_table_data_query(selected_table)
        end
    end)
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

-- API для внешнего использования
M.execute_query = query.execute
M.execute_raw_query = raw_query.execute
M.show_struct = struct_view.show
M.new_query = M.create_new_query

return M
