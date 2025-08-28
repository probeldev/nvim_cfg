-- lua/ripgrep.lua
local M = {}

function M.setup()
    -- Общая функция для поиска контента
    function _G.ripgrep_search(pattern)
        if pattern == nil or pattern == '' then
            pattern = vim.fn.input('Search pattern: ')
        end
        if pattern == '' then return end
        
        local escaped_pattern = vim.fn.shellescape(pattern)
        -- Правильный вызов: используем vim.cmd и правильный синтаксис
        vim.cmd('cex system("rg --vimgrep ' .. escaped_pattern .. '")')
        vim.cmd('copen')
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
