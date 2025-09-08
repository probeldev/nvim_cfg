-- lua/ripgrep.lua
local M = {}

function M.setup()
    -- Функция для настройки маппинга в quickfix
    local function setup_quickfix_mappings()
        -- Ждем немного, чтобы quickfix окно успело открыться
        vim.defer_fn(function()
            local qf_win = vim.fn.getqflist({winid = 0}).winid
            if qf_win > 0 then
                -- Устанавливаем маппинг только для quickfix буфера
                vim.api.nvim_buf_set_keymap(
                    vim.fn.winbufnr(qf_win),
                    'n',
                    '<CR>',
                    '<CR><C-w>p',
                    {noremap = true, silent = true}
                )
            end
        end, 50)
    end

    -- Общая функция для поиска контента
    function _G.ripgrep_search(pattern)
        if pattern == nil or pattern == '' then
            pattern = vim.fn.input('Search pattern: ')
        end
        if pattern == '' then return end
        
        local escaped_pattern = vim.fn.shellescape(pattern)
        vim.cmd('cex system("rg --vimgrep ' .. escaped_pattern .. '")')
        vim.cmd('copen')
        setup_quickfix_mappings()
    end

    -- Функция для поиска файлов
    function _G.ripgrep_find_files(pattern)
        if pattern == nil or pattern == '' then
            pattern = vim.fn.input('File pattern: ')
        end
        if pattern == '' then return end
        
        local escaped_pattern = vim.fn.shellescape(pattern)
        local cmd = "rg --files | rg " .. escaped_pattern
        local results = vim.fn.systemlist(cmd)
        
        if vim.v.shell_error ~= 0 or #results == 0 then
            print("No files found matching: " .. pattern)
            return
        end
        
        vim.fn.setqflist({}, ' ', {
            title = 'Files: ' .. pattern,
            lines = results,
            efm = '%f'
        })
        
        vim.cmd('copen')
        setup_quickfix_mappings()
    end

    -- Команды
    vim.api.nvim_create_user_command('Rg', function(opts)
        _G.ripgrep_search(opts.args)
    end, { nargs = '*', desc = 'Search content with ripgrep' })

    vim.api.nvim_create_user_command('RgFiles', function(opts)
        _G.ripgrep_find_files(opts.args)
    end, { nargs = '*', desc = 'Find files with ripgrep' })
end

return M
