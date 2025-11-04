local M = {}

-- Загрузка модулей
local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")
local query = require("db-workflow.modules.query")
local raw_query = require("db-workflow.modules.raw_query")
local struct_view = require("db-workflow.modules.struct_view")

function M.setup(user_config)
    config.setup(user_config)
    M.setup_commands()
end

function M.setup_commands()
    -- Регистрация пользовательских команд
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

-- Экспорт API для использования в других плагинах
M.execute_query = query.execute
M.execute_raw_query = raw_query.execute
M.show_struct = struct_view.show

return M
