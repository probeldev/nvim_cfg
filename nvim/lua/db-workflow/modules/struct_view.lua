local M = {}

local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")
local menu_manager = require("db-workflow.ui.menu_manager")
local result_display = require("db-workflow.ui.result_display")

local result_buffer_id = nil

function M.show()
    return menu_manager.create_dynamic_menu(M.run_action)
end

function M.run_action(action_name)
    local command = config.get_command() .. " -table=" .. action_name
    local output = vim.fn.system(command)
    
    local qf_win = vim.api.nvim_get_current_win()
    local qf_height = vim.api.nvim_win_get_height(qf_win)
    local win_view = vim.fn.winsaveview()
    
    local result_buf = M.get_or_create_result_buffer()
    local result_win = M.find_result_window()
    
    if result_win then
        vim.api.nvim_win_set_buf(result_win, result_buf)
    else
        vim.cmd('only')
        vim.cmd('split')
        result_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(result_win, result_buf)
    end
    
    local lines = utils.split_lines(output)
    vim.api.nvim_buf_set_lines(result_buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_name(result_buf, 'action://' .. action_name)
    
    local filetype = action_name == "logs" and "log" or "text"
    vim.api.nvim_buf_set_option(result_buf, 'filetype', filetype)
    
    vim.api.nvim_set_current_win(qf_win)
    vim.api.nvim_win_set_height(qf_win, qf_height)
    vim.fn.winrestview(win_view)
end

function M.get_or_create_result_buffer()
    if result_buffer_id and vim.api.nvim_buf_is_valid(result_buffer_id) then
        return result_buffer_id
    end
    
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, 'action://results')
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'text')
    
    result_buffer_id = buf
    return buf
end

function M.find_result_window()
    if not result_buffer_id or not vim.api.nvim_buf_is_valid(result_buffer_id) then
        return nil
    end
    
    local windows = vim.api.nvim_list_wins()
    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        if buf == result_buffer_id then
            return win
        end
    end
    return nil
end

function M.handle_menu_select()
    menu_manager.handle_menu_select()
end

return M
