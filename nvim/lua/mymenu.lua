local M = {}

-- Глобальная переменная для хранения ID буфера результатов
M.result_buffer_id = nil


function M.setup(user_config)
end

-- Функция для получения или создания буфера результатов
function M.get_or_create_result_buffer()
	-- Если буфер уже существует и валиден, возвращаем его
	if M.result_buffer_id and vim.api.nvim_buf_is_valid(M.result_buffer_id) then
		return M.result_buffer_id
	end
	
	-- Создаем новый буфер
	local buf = vim.api.nvim_create_buf(false, true)
	
	-- Настраиваем буфер
	vim.api.nvim_buf_set_name(buf, 'action://results')
	vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
	vim.api.nvim_buf_set_option(buf, 'swapfile', false)
	vim.api.nvim_buf_set_option(buf, 'filetype', 'text')
	
	M.result_buffer_id = buf
	return buf
end

-- Функция для поиска окна с буфером результатов
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

-- Функция для запуска action программы
function M.run_action(action_name)
	local command = "/home/sergey/work/opensource/db-workflow/main -table=" .. action_name
	local output = vim.fn.system(command)
	
	-- Запоминаем текущее quickfix окно
	local qf_win = vim.api.nvim_get_current_win()
	local qf_height = vim.api.nvim_win_get_height(qf_win)
	local win_view = vim.fn.winsaveview()
	
	-- Получаем или создаем буфер результатов
	local result_buf = M.get_or_create_result_buffer()
	
	-- Ищем окно с результатом
	local result_win = M.find_result_window()
	
	if result_win then
		-- Если окно с результатом уже существует, используем его
		vim.api.nvim_win_set_buf(result_win, result_buf)
	else
		-- Если окна с результатом нет, создаем разделение
		vim.cmd('only') -- Закрываем все другие окна, кроме quickfix
		vim.cmd('split') -- Создаем горизонтальное разделение
		result_win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(result_win, result_buf)
	end
	
	-- Очищаем и заполняем буфер выводом программы
	local lines = vim.split(output, '\n')
	vim.api.nvim_buf_set_lines(result_buf, 0, -1, false, lines)
	
	-- Обновляем имя буфера с учетом текущего действия
	vim.api.nvim_buf_set_name(result_buf, 'action://' .. action_name)
	
	-- Устанавливаем синтаксис в зависимости от действия
	if action_name == "logs" then
		vim.api.nvim_buf_set_option(result_buf, 'filetype', 'log')
	else
		vim.api.nvim_buf_set_option(result_buf, 'filetype', 'text')
	end
	
	-- Возвращаем фокус в quickfix окно
	vim.api.nvim_set_current_win(qf_win)
	
	-- Восстанавливаем размер quickfix окна
	vim.api.nvim_win_set_height(qf_win, qf_height)
	
	-- Восстанавливаем вид окна (позицию прокрутки и курсор)
	vim.fn.winrestview(win_view)
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
		-- Выполняем действие
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

-- Функция для закрытия буфера результатов
function M.close_result_buffer()
	if M.result_buffer_id and vim.api.nvim_buf_is_valid(M.result_buffer_id) then
		local result_win = M.find_result_window()
		if result_win then
			vim.api.nvim_win_close(result_win, false)
		end
		vim.api.nvim_buf_delete(M.result_buffer_id, { force = true })
		M.result_buffer_id = nil
	end
end

-- Инициализация при загрузке модуля
M.setup_quickfix_mappings()


-- Команда для вызова меню
vim.api.nvim_create_user_command('DbWorkflowShowStruc', function()
   M.create_dynamic_menu()
end, {desc = 'Открыть кастомное меню'})

return M
