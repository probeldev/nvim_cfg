local M = {}

local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")
local result_display = require("db-workflow.ui.result_display")
local nvim_ui_picker = require("db-workflow.ui.nvim_ui_picker")

function M.show()
    local actions = M.get_available_actions()
    if not actions or #actions == 0 then
        utils.warn("Нет доступных таблиц в базе данных")
        return
    end
    
    -- Используем floating window версию с гарантированной навигацией
    nvim_ui_picker.show_actions_best(actions, function(selected_action)
        if selected_action then
            utils.notify("Загружаем структуру: " .. selected_action)
            M.run_action(selected_action)
        end
    end)
end

-- Экспортируем функцию получения доступных действий
function M.get_available_actions()
    local menu_output = vim.fn.system(config.get_command() .. ' -tables')
    local menu_lines = utils.split_lines(menu_output)
    
    local actions = {}
    for _, line in ipairs(menu_lines) do
        if line ~= '' then
            local action_name = line:match('^%s*(%S+)%s*$')
            if action_name then
                table.insert(actions, {
                    value = action_name,
                    display = action_name,
                    ordinal = action_name
                })
            end
        end
    end
    
    return actions
end

function M.run_action(action_name)
    local command = config.get_command() .. " -table=" .. action_name
    local output, err = utils.execute_system_command(command, "")
    
    if not output then
        utils.error("Ошибка выполнения: " .. (err or "неизвестная ошибка"))
        return
    end
    
    -- Используем специальную функцию для структур (полноэкранный режим)
    result_display.show_structure(output, action_name, "sql")
end

return M
