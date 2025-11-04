local M = {}

local buffer_cache = {}
local scroll_settings = {}

function M.create_result_buffer(buffer_name, filetype)
    -- Проверяем, существует ли уже буфер с таким именем
    local existing_buf = vim.fn.bufnr(buffer_name)
    if existing_buf ~= -1 and vim.api.nvim_buf_is_valid(existing_buf) then
        -- Буфер существует, переключаемся на него
        local existing_win = M.find_window_by_buffer(existing_buf)
        if existing_win then
            vim.api.nvim_set_current_win(existing_win)
        else
            -- Буфер есть, но окна нет - создаем новое окно
            vim.cmd("edit " .. vim.fn.fnameescape(buffer_name))
        end
        return existing_buf, vim.api.nvim_get_current_win()
    end

    -- Сохраняем текущие настройки скролла
    scroll_settings[buffer_name] = {
        sidescroll = vim.o.sidescroll,
        sidescrolloff = vim.o.sidescrolloff
    }

    -- Создаем новый буфер (не сплитим, а заменяем текущее окно)
    vim.cmd("edit " .. vim.fn.fnameescape(buffer_name))
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()

    -- Настраиваем буфер
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = filetype or "text"
    vim.bo[buf].modifiable = true
    vim.bo[buf].readonly = false

    -- Настройки окна для горизонтального скролла
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
    -- Для полноэкранного режима не меняем размер
    -- Можно добавить авто-размер если нужно, но пока оставим полноэкранный
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
                vim.o.sidescroll = buffer_info.scroll_settings.sidescroll
                vim.o.sidescrolloff = buffer_info.scroll_settings.sidescrolloff
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
