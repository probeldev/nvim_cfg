local M = {}

-- Загрузка модулей
local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")
local query = require("db-workflow.modules.query")
local raw_query = require("db-workflow.modules.raw_query")
local struct_view = require("db-workflow.modules.struct_view")
local main_menu = require("db-workflow.ui.main_menu")

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
        struct_view.show()
    end, { desc = "Показать структуры db-workflow" })
end

-- Главное меню
function M.show_main_menu()
    main_menu.show_main_menu(function(selected_action)
        M.handle_menu_selection(selected_action)
    end)
end

-- Обработчик выбора в меню
function M.handle_menu_selection(action)
    if action == "run_query" then
        M.execute_query_from_menu()
    elseif action == "run_raw_query" then
        M.execute_raw_query_from_menu()
    elseif action == "show_structure" then
        struct_view.show()
    end
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

return M
