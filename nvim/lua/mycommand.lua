local M = {}

-- Конфигурация по умолчанию
local config = {
    result_buffer_name = "Sort_Result",
    command = "/home/sergey/work/opensource/db-workflow/main -query",
    args = {} -- без аргументов, просто сортировка
}

function M.setup(user_config)
    config = vim.tbl_extend("force", config, user_config or {})
end

function M.execute_sort_command()
    -- Получаем выделенный текст
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)
    local selected_text = table.concat(lines, "\n")

    if selected_text == "" then
        vim.notify("Нет выделенного текста!", vim.log.levels.WARN)
        return
    end

    print("Сортируем текст: " .. #lines .. " строк")

    -- Используем vim.fn.system для простоты
    local output = vim.fn.system(config.command .. " ", selected_text)
    
    if vim.v.shell_error ~= 0 then
        vim.notify("Ошибка выполнения sort: код " .. vim.v.shell_error, vim.log.levels.ERROR)
        return
    end

    M.show_result("=== Результат запроса: ===\n" .. output)
end

function M.show_result(output)
    -- Закрываем предыдущее окно с результатами, если есть
    local existing_buf = vim.fn.bufnr(config.result_buffer_name)
    if existing_buf ~= -1 then
        local existing_win = vim.fn.bufwinid(existing_buf)
        if existing_win ~= -1 then
            vim.api.nvim_win_close(existing_win, true)
        end
        vim.api.nvim_buf_delete(existing_buf, { force = true })
    end

    -- Создаем новое окно снизу
    vim.cmd("belowright new")
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()
    
    -- Настраиваем буфер
    vim.api.nvim_buf_set_name(buf, config.result_buffer_name)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "text"
    vim.bo[buf].modifiable = true
    
    -- Записываем данные
    local lines = vim.split(output, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    
    -- Устанавливаем только для чтения
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    
    -- Настраиваем размер окна
    local height = math.min(math.max(#lines + 2, 5), 20)
    vim.api.nvim_win_set_height(win, height)
    
    print("Сортировка завершена! Результат в буфере: " .. config.result_buffer_name)
end

-- Создаем пользовательскую команду
vim.api.nvim_create_user_command("DbWorkflowRunQuery", function()
    M.execute_sort_command()
end, { range = true })

return M
