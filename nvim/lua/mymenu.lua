local M = {}

-- Функция для запуска action программы
function M.run_action(action_name)
    local command = "/home/sergey/work/opensource/db-workflow/main -table=" .. action_name
    local output = vim.fn.system(command)
    
    -- Создаем новую вкладку
    vim.cmd('tabnew')
    
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
                
                -- Создаем красивый текст для меню
                -- local display_text = ""
                -- if action_name == "users" then
                --     display_text = "👥 Показать пользователей"
                -- elseif action_name == "orders" then
                --     display_text = "📦 Показать заказы"
                -- elseif action_name == "requests" then
                --     display_text = "📝 Показать запросы"
                -- elseif action_name == "statistics" then
                --     display_text = "📊 Показать статистику"
                -- elseif action_name == "logs" then
                --     display_text = "📋 Показать логи"
                -- else
                --     display_text = "🔧 " .. action_name
                -- end

				display_text = "Show " .. action_name
                
                table.insert(qf_items, {
                    filename = "menu://action",
                    lnum = i,
                    col = 1,
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

-- Обработчик выбора в меню
function M.handle_menu_select()
    local line_num = vim.fn.line('.')
    if M.menu_actions and M.menu_actions[line_num] then
        M.menu_actions[line_num]()
        vim.cmd('cclose') -- Закрываем меню после выбора
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
