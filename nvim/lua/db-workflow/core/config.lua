local M = {}

-- Конфигурация по умолчанию
local default_config = {
    command = "/Users/sergey/work/opensource/db-workflow/main",
    result_buffer_name = "DB_Workflow_Result",
    sidescroll = 1,
    sidescrolloff = 5,
    max_result_height = 20,
    min_result_height = 5
}

local config = vim.deepcopy(default_config)

function M.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config or {})
end

function M.get()
    return config
end

function M.get_command()
    return config.command
end

function M.get_buffer_settings()
    return {
        name = config.result_buffer_name,
        sidescroll = config.sidescroll,
        sidescrolloff = config.sidescrolloff
    }
end

function M.get_window_settings()
    return {
        max_height = config.max_result_height,
        min_height = config.min_result_height
    }
end

return M
