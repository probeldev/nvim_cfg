local M = {}

function M.get_visual_selection()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    local lines = vim.fn.getline(start_line, end_line)
    return table.concat(lines, "\n"), #lines
end

function M.execute_system_command(full_command, input)
    local output = vim.fn.system(full_command .. " ", input)
    
    if vim.v.shell_error ~= 0 then
        return nil, "Ошибка выполнения команды: код " .. vim.v.shell_error
    end
    
    return output, nil
end

function M.validate_selection(selected_text)
    if selected_text == "" then
        return false, "Нет выделенного текста!"
    end
    return true, nil
end

function M.split_lines(text)
    return vim.split(text, "\n")
end

function M.notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO)
end

function M.warn(message)
    M.notify(message, vim.log.levels.WARN)
end

function M.error(message)
    M.notify(message, vim.log.levels.ERROR)
end

return M
