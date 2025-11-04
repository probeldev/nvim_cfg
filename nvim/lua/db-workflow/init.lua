local M = {}

-- Общая конфигурация
local config = {
    command = "/Users/sergey/work/opensource/db-workflow/main",
    result_buffer_name = "DB_Workflow_Result",
    -- Глобальные настройки скролла
    sidescroll = 1,
    sidescrolloff = 5
}

function M.setup(user_config)
    config = vim.tbl_extend("force", config, user_config or {})
end

-- Общие утилиты
local utils = {}

function utils.show_result(output, title_suffix)
    local buffer_name = config.result_buffer_name
    if title_suffix then
        buffer_name = buffer_name .. "_" .. title_suffix
    end

    -- Закрываем предыдущее окно с результатами, если есть
    local existing_buf = vim.fn.bufnr(buffer_name)
    if existing_buf ~= -1 then
        local existing_win = vim.fn.bufwinid(existing_buf)
        if existing_win ~= -1 then
            vim.api.nvim_win_close(existing_win, true)
        end
        vim.api.nvim_buf_delete(existing_buf, { force = true })
    end

    -- Сохраняем текущие настройки скролла
    local old_sidescroll = vim.o.sidescroll
    local old_sidescrolloff = vim.o.sidescrolloff
    
    -- Устанавливаем глобальные настройки для горизонтального скролла
    vim.o.sidescroll = config.sidescroll
    vim.o.sidescrolloff = config.sidescrolloff

    -- Создаем новое окно снизу
    vim.cmd("belowright new")
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    
    -- Настраиваем буфер
    vim.api.nvim_buf_set_name(buf, buffer_name)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "text"
    vim.bo[buf].modifiable = true
    
    -- Ключевые настройки для горизонтального скролла (оконные опции)
    vim.wo[win].wrap = false          -- Отключаем перенос строк
    vim.wo[win].linebreak = false     -- Отключаем перенос по словам

    -- Записываем данные
    local lines = vim.split(output, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Устанавливаем только для чтения
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    
    -- Настраиваем размер окна
    local height = math.min(math.max(#lines + 2, 5), 20)
    vim.api.nvim_win_set_height(win, height)
    
    -- Автоматически прокручиваем к началу
    vim.cmd("normal! gg")
    
    print("Операция завершена! Результат в буфере: " .. buffer_name)
    
    -- Устанавливаем маппинги для удобного скролла
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Left>', 'zh', {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Right>', 'zl', {noremap = true, silent = true})
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', {noremap = true, silent = true})
    
    -- Восстанавливаем настройки при закрытии буфера
    vim.api.nvim_buf_attach(buf, false, {
        on_detach = function()
            vim.o.sidescroll = old_sidescroll
            vim.o.sidescrolloff = old_sidescrolloff
        end
    })
end

function utils.execute_command(cmd_args, selected_text)
    local full_command = config.command .. " " .. cmd_args
    local output = vim.fn.system(full_command .. " ", selected_text)
    
    if vim.v.shell_error ~= 0 then
        vim.notify("Ошибка выполнения команды: код " .. vim.v.shell_error, vim.log.levels.ERROR)
        return nil
    end
    
    return output
end

-- Модуль для выполнения запросов с raw выводом
function M.execute_raw_query()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)
    local selected_text = table.concat(lines, "\n")

    if selected_text == "" then
        vim.notify("Нет выделенного текста!", vim.log.levels.WARN)
        return
    end

    print("Выполняем raw запрос: " .. #lines .. " строк")

    local output = utils.execute_command("-query -raw", selected_text)
    if output then
        utils.show_result("=== Результат raw запроса: ===\n" .. output, "raw")
    end
end

-- Модуль для выполнения обычных запросов
function M.execute_query()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)
    local selected_text = table.concat(lines, "\n")

    if selected_text == "" then
        vim.notify("Нет выделенного текста!", vim.log.levels.WARN)
        return
    end

    print("Выполняем запрос: " .. #lines .. " строк")

    local output = utils.execute_command("-query", selected_text)
    if output then
        utils.show_result("=== Результат запроса: ===\n" .. output, "query")
    end
end

-- Модуль для показа структуры (динамическое меню)
M.menu_actions = {}
M.custom_quickfix_windows = {}
M.result_buffer_id = nil

function M.get_or_create_result_buffer()
    if M.result_buffer_id and vim.api.nvim_buf_is_valid(M.result_buffer_id) then
        return M.result_buffer_id
    end
    
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, 'action://results')
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'text')
    
    M.result_buffer_id = buf
    return buf
end

function M.find_result_window()
    if not M.result_buffer_id or not vim.api.nvim_buf_is_valid(M.result_buffer_id) then
        return nil
    end
    
    local windows = vim.api.nvim_list_wins()
    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        if buf == M.result_buffer_id then
            return win
        end
    end
    return nil
end

function M.run_action(action_name)
    local command = config.command .. " -table=" .. action_name
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
    
    local lines = vim.split(output, '\n')
    vim.api.nvim_buf_set_lines(result_buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_name(result_buf, 'action://' .. action_name)
    
    if action_name == "logs" then
        vim.api.nvim_buf_set_option(result_buf, 'filetype', 'log')
    else
        vim.api.nvim_buf_set_option(result_buf, 'filetype', 'text')
    end
    
    vim.api.nvim_set_current_win(qf_win)
    vim.api.nvim_win_set_height(qf_win, qf_height)
    vim.fn.winrestview(win_view)
end

function M.create_dynamic_menu()
    local menu_output = vim.fn.system(config.command .. ' -tables')
    local menu_lines = vim.split(menu_output, '\n')
    
    local qf_items = {}
    local actions_list = {}
    
    for i, line in ipairs(menu_lines) do
        if line ~= '' then
            local action_name = line:match('^%s*(%S+)%s*$')
            if action_name then
                table.insert(actions_list, action_name)
                table.insert(qf_items, {
                    filename = "db:custom_menu",
                    text = "Show " .. action_name
                })
            end
        end
    end
    
    M.menu_actions = {}
    for i, action_name in ipairs(actions_list) do
        M.menu_actions[i] = function()
            M.run_action(action_name)
        end
    end
    
    if #qf_items > 0 then
        vim.fn.setqflist(qf_items, ' ')
        vim.cmd('copen')
        
        local win_id = vim.api.nvim_get_current_win()
        M.custom_quickfix_windows[win_id] = true
        M.setup_window_mappings(win_id)
    else
        vim.notify("Меню пустое или программа не вернула действия", vim.log.levels.WARN)
    end
end

function M.setup_window_mappings(win_id)
    local buf = vim.api.nvim_win_get_buf(win_id)
    
    vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', 
        '<cmd>lua require("db-workflow").handle_menu_select()<CR>',
        {silent = true, noremap = true})
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', 
        '<cmd>cclose<CR>',
        {silent = true, noremap = true})
    
    vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', 
        '<cmd>cclose<CR>',
        {silent = true, noremap = true})
end

function M.handle_menu_select()
    local line_num = vim.fn.line('.')
    if M.menu_actions and M.menu_actions[line_num] then
        M.menu_actions[line_num]()
    else
        vim.cmd('cc')
    end
end

-- Регистрация пользовательских команд
vim.api.nvim_create_user_command("DbWorkflowRunQueryRaw", function()
    M.execute_raw_query()
end, { range = true, desc = "Выполнить raw запрос db-workflow" })

vim.api.nvim_create_user_command("DbWorkflowRunQuery", function()
    M.execute_query()
end, { range = true, desc = "Выполнить запрос db-workflow" })

vim.api.nvim_create_user_command("DbWorkflowShowStruct", function()
    M.create_dynamic_menu()
end, { desc = "Показать структуры db-workflow" })

return M
