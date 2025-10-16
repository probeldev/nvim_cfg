local M = {}

-- Функция для удаления выполненных задач в выделенной области
function M.remove_completed_tasks()
    -- Получаем визуальное выделение через маркеры '< и '>
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")

    -- Проверяем, есть ли выделение (в визуальном режиме эти маркеры устанавливаются)
    if start_line == 0 or end_line == 0 then
        print("Пожалуйста, сначала выделите задачи в визуальном режиме")
        return
    end

    -- Сохраняем позицию курсора
    local saved_cursor = vim.fn.getpos('.')

    -- Собираем строки для обработки
    local lines = {}
    for i = start_line, end_line do
        table.insert(lines, vim.fn.getline(i))
    end

    -- Фильтруем строки, оставляя только невыполненные задачи
    local filtered_lines = {}
    for _, line in ipairs(lines) do
        -- Оставляем строки, которые НЕ начинаются с "- [x]" или "- [X]"
        if not line:match("^%s*%-%s*%[x%]") and not line:match("^%s*%-%s*%[X%]") then
            table.insert(filtered_lines, line)
        end
    end

    -- Если количество строк изменилось, заменяем содержимое
    if #filtered_lines ~= #lines then
        -- Удаляем старые строки
        vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, {})
        
        -- Вставляем отфильтрованные строки
        if #filtered_lines > 0 then
            vim.api.nvim_buf_set_lines(0, start_line - 1, start_line - 1, false, filtered_lines)
        end

        print("Удалено " .. (#lines - #filtered_lines) .. " выполненных задач")
    else
        print("В выделенной области нет выполненных задач")
    end

    -- Восстанавливаем позицию курсора
    vim.fn.setpos('.', saved_cursor)
end

-- Создаем команду для вызова функции
vim.api.nvim_create_user_command('RemoveCompletedTasks', function()
    M.remove_completed_tasks()
end, { range = true })

return M
