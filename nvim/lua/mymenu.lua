local M = {}

-- Функция для запуска action программы
function M.run_action(action_name)
    local command = "/home/sergey/work/opensource/db-workflow/main -table=" .. action_name
    local output = vim.fn.system(command)
    
    -- Запоминаем текущее quickfix окно
    local qf_win = vim.api.nvim_get_current_win()
    local qf_height = vim.api.nvim_win_get_height(qf_win)
    local win_view = vim.fn.winsaveview()
    
    -- Закрываем все другие окна, кроме quickfix
    vim.cmd('only')
    
    -- Создаем горизонтальное разделение окна
    vim.cmd('split')
    
    -- Получаем новое окно (окно с результатом)
    local result_win = vim.api.nvim_get_current_win()
    
    -- Заполняем буфер выводом программы
    local lines = vim.split(output, '\n')
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    
    -- Настраиваем буфер
    vim.bo.buftype = 'nofile'
    vim.bo.bufhidden = 'hide'
    vim.bo.swapfile = false
    vim.bo.filetype = 'text'
    vim.api.nvim_buf_set_name(0, 'action://' .. action_name)
    
    -- Устанавливаем синтаксис в зависимости от действия
    if action_name == "logs" then
        vim.bo.filetype = 'log'
    end
    
    -- Возвращаем фокус в quickfix окно
    vim.api.nvim_set_current_win(qf_win)
    
    -- Восстанавливаем размер quickfix окна
    vim.api.nvim_win_set_height(qf_win, qf_height)
    
    -- Восстанавливаем вид окна (позицию прокрутки и курсор)
    vim.fn.winrestview(win_view)
    
    -- Quickfix остается активным, результат виден в соседнем окне
end

-- Динамически загружаем меню из программы
function M.create_dynamic_menu()
    -- Запускаем menu.go чтобы получить список действий
    local menu_output = vim.fn.system('/home/sergey/work/opensource/db-workflow/main -tables')
    local menu_lines = vim.split(menu_output, '\n')
    
    local qf_items = {}
    local actions_list = {}
    
    -- Собираем действия и создаем пункты меню
    for i, line in ipairs(menu_lines) do
        if line ~= '' then
            local action_name = line:match('^%s*(%S+)%s*$')
            if action_name then
                table.insert(actions_list, action_name)
                display_text = "Show " .. action_name
                
                table.insert(qf_items, {
                    filename = "db:",
                    text = display_text
                })
            end
        end
    end
    
    -- Сохраняем mapping действий
    M.menu_actions = {}
    for i, action_name in ipairs(actions_list) do
        M.menu_actions[i] = function()
            M.run_action(action_name)
        end
    end
    
    -- Показываем меню в quickfix
    if #qf_items > 0 then
        vim.fn.setqflist(qf_items, ' ')
        vim.cmd('copen')
    else
        vim.notify("Меню пустое или программа menu не вернула действия", vim.log.levels.WARN)
    end
end

-- Обработчик выбора в меню (разделение окна)
function M.handle_menu_select()
    local line_num = vim.fn.line('.')
    if M.menu_actions and M.menu_actions[line_num] then
        -- Выполняем действие (закрывает другие окна и открывает результат в split)
        M.menu_actions[line_num]()
    else
        vim.cmd('cc') -- Стандартное поведение
    end
end

-- Настройка mappings для quickfix
function M.setup_quickfix_mappings()
    vim.cmd([[
    augroup CustomQuickfixMenu
        autocmd!
        autocmd FileType qf nnoremap <buffer> <CR> :lua require('mymenu').handle_menu_select()<CR>
        autocmd FileType qf nnoremap <buffer> q :cclose<CR>
        autocmd FileType qf nnoremap <buffer> <Esc> :cclose<CR>
    augroup END
    ]])
end

-- Инициализация при загрузке модуля
M.setup_quickfix_mappings()

return M
