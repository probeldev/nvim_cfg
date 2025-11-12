local M = {}

local buffer_cache = {}
local scroll_settings = {}

-- Закрываем ВСЕ буферы, начинающиеся на db_workflow://
function M.close_all_result_buffers()
    local windows = vim.api.nvim_list_wins()
    for _, win in ipairs(windows) do
        local bufnr = vim.api.nvim_win_get_buf(win)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if bufname:match("^db_workflow://") then
            vim.api.nvim_win_close(win, true)
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end
    end
end

function M.create_result_buffer(buffer_name, filetype)
    -- Закрываем ВСЕ предыдущие буферы результата
    M.close_all_result_buffers()

    -- Создаём новый буфер для результата
    local buf = vim.api.nvim_create_buf(false, false)  -- обычный буфер, не scratch

    -- Настраиваем буфер
    vim.bo[buf].buftype = ""
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = filetype or "text"
    vim.bo[buf].modifiable = true
    vim.bo[buf].readonly = false

    -- Устанавливаем имя буфера
    vim.api.nvim_buf_set_name(buf, buffer_name)

    -- Создаём окно внизу
    local height = math.min(math.floor(vim.o.lines / 3), 15)
    local opts = {
        relative = "editor",
        row = vim.o.lines - height,
        col = 0,
        width = vim.o.columns,
        height = height,
        style = "minimal",
        border = "single",
    }

    local win = vim.api.nvim_open_win(buf, false, opts)  -- не фокусируем

    -- Отключаем перенос строк
    vim.wo[win].wrap = false
    vim.wo[win].linebreak = false

    -- Кешируем буфер
    buffer_cache[buffer_name] = {
        buf = buf,
        win = win,
        scroll_settings = scroll_settings[buffer_name]
    }

    return buf, win
end

function M.find_window_by_buffer(bufnr)
    local windows = vim.api.nvim_list_wins()
    for _, win in ipairs(windows) do
        if vim.api.nvim_win_get_buf(win) == bufnr then
            return win
        end
    end
    return nil
end

function M.configure_buffer_size(win, content_lines, config)
    -- Можно расширить логику динамической высоты, если нужно
end

function M.setup_buffer_mappings(buf)
    local mappings = {
        { 'n', '<Left>', 'zh', { noremap = true, silent = true } },
        { 'n', '<Right>', 'zl', { noremap = true, silent = true } },
        { 'n', 'q', ':q<CR>', { noremap = true, silent = true } },
        { 'n', '<Esc>', ':q<CR>', { noremap = true, silent = true } },
        { 'n', '<C-w>', ':q<CR>', { noremap = true, silent = true } }
    }

    for _, mapping in ipairs(mappings) do
        vim.api.nvim_buf_set_keymap(buf, mapping[1], mapping[2], mapping[3], mapping[4])
    end

    -- Восстанавливаем настройки при закрытии буфера
    vim.api.nvim_buf_attach(buf, false, {
        on_detach = function()
            local buffer_info = buffer_cache[vim.api.nvim_buf_get_name(buf)]
            if buffer_info and buffer_info.scroll_settings then
                buffer_cache[vim.api.nvim_buf_get_name(buf)] = nil
            end
        end
    })
end

function M.close_buffer_by_name(buffer_name)
    local existing_buf = vim.fn.bufnr(buffer_name)
    if existing_buf ~= -1 then
        local existing_win = M.find_window_by_buffer(existing_buf)
        if existing_win then
            vim.api.nvim_win_close(existing_win, true)
        end
        vim.api.nvim_buf_delete(existing_buf, { force = true })
    end
end

function M.get_buffer_info(buffer_name)
    return buffer_cache[buffer_name]
end

return M
