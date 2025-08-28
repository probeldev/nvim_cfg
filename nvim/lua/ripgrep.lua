
-- lua/lsp.lua
local M = {}

function M.setup()
vim.api.nvim_create_user_command('Rg', function(opts)
    vim.fn.execute("cex system('rg --vimgrep " .. opts.args .. "')")
    vim.fn.execute('copen')
end, { nargs = '+' })

function _G.rg_find_files(pattern)
    if pattern == nil or pattern == '' then
        pattern = vim.fn.input('File pattern: ')
    end
    if pattern == '' then return end
    
    -- Используем rg для поиска файлов
    local cmd = "rg --files | rg " .. vim.fn.shellescape(pattern)
    local results = vim.fn.systemlist(cmd)
    
    if vim.v.shell_error ~= 0 or #results == 0 then
        print("No files found matching: " .. pattern)
        return
    end
    
    -- Создаем quickfix список
    vim.fn.setqflist({}, ' ', {
        title = 'Files: ' .. pattern,
        lines = results,
        efm = '%f'
    })
    vim.cmd('copen')
end

-- Команда для поиска файлов
vim.api.nvim_create_user_command('RgFiles', function(opts)
    _G.rg_find_files(opts.args)
end, { nargs = '?', desc = 'Find files with ripgrep' })

end

return M
