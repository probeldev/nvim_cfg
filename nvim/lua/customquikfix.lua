local M = {}

function M.create_custom_quickfix()
    local items = {
        {
            filename = "custom://actions",
            lnum = 1,
            col = 1,
            text = "📝 Создать новую заметку",
			action = function()
				vim.cmd('tabnew')  -- Открыть в новой вкладке вместо сплита
				vim.api.nvim_buf_set_lines(0, 0, -1, false, {
					'# Новая заметка',
					'Создано: ' .. os.date('%Y-%m-%d %H:%M'),
					'',
					'Ваш текст здесь...'
				})
				vim.bo.buftype = 'nofile'
				vim.bo.bufhidden = 'hide'
				vim.bo.swapfile = false
				vim.bo.filetype = 'markdown'  -- Можно установить тип файла
			end
        },
        {
            filename = "custom://actions", 
            lnum = 2,
            col = 1,
            text = "📊 Показать статистику буфера",
            action = function()
                local line_count = vim.api.nvim_buf_line_count(0)
                local word_count = 0
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                
                for _, line in ipairs(lines) do
                    local words = vim.split(line, '%s+')
                    for _ in pairs(words) do
                        word_count = word_count + 1
                    end
                end
                
                vim.cmd('new')
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    'Статистика буфера:',
                    'Строк: ' .. line_count,
                    'Слов: ' .. word_count,
                    'Байт: ' .. vim.fn.line2byte(line_count + 1) - 1
                })
                vim.bo.buftype = 'nofile'
                vim.bo.bufhidden = 'hide'
                vim.bo.swapfile = false
            end
        },
        {
            filename = "custom://actions",
            lnum = 3, 
            col = 1,
            text = "🎨 Сменить цветовую схему",
            action = function()
                local schemes = {'github_light', 'github_dark', 'desert', 'industry'}
                local random_scheme = schemes[math.random(#schemes)]
                vim.cmd('colorscheme ' .. random_scheme)
                
                vim.cmd('new')
                vim.api.nvim_buf_set_lines(0, 0, -1, false, {
                    'Цветовая схема изменена на: ' .. random_scheme
                })
                vim.bo.buftype = 'nofile'
                vim.bo.bufhidden = 'hide'
                vim.bo.swapfile = false
            end
        }
    }
    
    -- Сохраняем действия для использования
    M.quickfix_actions = {}
    local qf_items = {}
    
    for i, item in ipairs(items) do
        M.quickfix_actions[i] = item.action
        table.insert(qf_items, {
            filename = item.filename,
            lnum = item.lnum,
            col = item.col,
            text = item.text
        })
    end
    
    vim.fn.setqflist(qf_items, ' ')
    vim.cmd('copen')
end

-- Обработчик выбора в quickfix
function M.setup_quickfix_mappings()
    vim.cmd([[
    augroup CustomQuickfix
        autocmd!
        autocmd FileType qf nnoremap <buffer> <CR> :lua require('customquikfix').handle_quickfix_select()<CR>
    augroup END
    ]])
end

function M.handle_quickfix_select()
    local line_num = vim.fn.line('.')
    if M.quickfix_actions and M.quickfix_actions[line_num] then
        M.quickfix_actions[line_num]()
        vim.cmd('cclose') -- Закрываем quickfix после выбора
    else
        vim.cmd('cc') -- Стандартное поведение
    end
end

-- Автоматическая настройка при загрузке модуля
M.setup_quickfix_mappings()

return M
