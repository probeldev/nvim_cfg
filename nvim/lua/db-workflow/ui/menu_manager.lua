local M = {}

local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")

M.menu_actions = {}
M.custom_quickfix_windows = {}

function M.create_dynamic_menu(actions_callback)
    local menu_output = vim.fn.system(config.get_command() .. ' -tables')
    local menu_lines = utils.split_lines(menu_output)
    
    local qf_items = {}
    local actions_list = {}
    
    for i, line in ipairs(menu_lines) do
        if line ~= '' then
            local action_name = line:match('^%s*(%S+)%s*$')
            if action_name then
                table.insert(actions_list, action_name)
                table.insert(qf_items, {
                    filename = "db-workflow:menu",
                    text = "Show " .. action_name
                })
            end
        end
    end
    
    M.menu_actions = {}
    for i, action_name in ipairs(actions_list) do
        M.menu_actions[i] = function()
            actions_callback(action_name)
        end
    end
    
    if #qf_items > 0 then
        vim.fn.setqflist(qf_items, ' ')
        vim.cmd('copen')
        
        local win_id = vim.api.nvim_get_current_win()
        M.custom_quickfix_windows[win_id] = true
        M.setup_window_mappings(win_id)
        
        return true
    else
        utils.warn("Меню пустое или программа не вернула действия")
        return false
    end
end

function M.setup_window_mappings(win_id)
    local buf = vim.api.nvim_win_get_buf(win_id)
    
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', 
        '<cmd>lua require("db-workflow.modules.struct_view").handle_menu_select()<CR>',
        { silent = true, noremap = true })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>cclose<CR>', { silent = true, noremap = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>cclose<CR>', { silent = true, noremap = true })
end

function M.handle_menu_select()
    local line_num = vim.fn.line('.')
    if M.menu_actions and M.menu_actions[line_num] then
        M.menu_actions[line_num]()
    else
        vim.cmd('cc')
    end
end

return M
