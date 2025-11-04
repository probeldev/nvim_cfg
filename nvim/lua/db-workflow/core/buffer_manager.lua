local M = {}

local buffer_cache = {}
local scroll_settings = {}

function M.create_result_buffer(buffer_name, filetype)
    -- Закрываем предыдущее окно с таким же именем буфера
    M.close_buffer_by_name(buffer_name)

    -- Сохраняем текущие настройки скролла
    scroll_settings[buffer_name] = {
        sidescroll = vim.o.sidescroll,
        sidescrolloff = vim.o.sidescrolloff
    }

    -- Создаем новое окно снизу
    vim.cmd("belowright new")
    local buf = vim.api.nvim_get_current_buf()
    local win = vim.api.nvim_get_current_win()

    -- Настраиваем буфер
    vim.api.nvim_buf_set_name(buf, buffer_name)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = filetype or "text"
    vim.bo[buf].modifiable = true

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

function M.configure_buffer_size(win, content_lines, config)
    local line_count = #content_lines
    local height = math.min(math.max(line_count + 2, config.min_height), config.max_height)
    vim.api.nvim_win_set_height(win, height)
end

function M.setup_buffer_mappings(buf)
    local mappings = {
        { 'n', '<Left>', 'zh', { noremap = true, silent = true } },
        { 'n', '<Right>', 'zl', { noremap = true, silent = true } },
        { 'n', 'q', ':q<CR>', { noremap = true, silent = true } },
        { 'n', '<Esc>', ':q<CR>', { noremap = true, silent = true } }
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
        local existing_win = vim.fn.bufwinid(existing_buf)
        if existing_win ~= -1 then
            vim.api.nvim_win_close(existing_win, true)
        end
        vim.api.nvim_buf_delete(existing_buf, { force = true })
    end
end

function M.get_buffer_info(buffer_name)
    return buffer_cache[buffer_name]
end

return M
