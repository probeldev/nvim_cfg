vim.lsp.config.gopls = {
  cmd = { 'gopls' },
  filetypes = { 'go' },
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
        unusedwrite = true,
      },
      staticcheck = true,
      completeUnimported = true,
      directoryFilters = { '-.git', '-node_modules' },
      buildFlags = { "-tags", "integration" },
    },
  },
}

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    -- Сохраняем оригинальное содержимое
    local original_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    -- Пробуем выполнить goimports
    local formatted = vim.fn.systemlist('goimports', original_content)
    
    -- Проверяем успешность выполнения (код возврата 0)
    if vim.v.shell_error == 0 then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted)
      vim.api.nvim_win_set_cursor(0, cursor_pos)
    else
      vim.notify("goimports failed: " .. table.concat(formatted, "\n"), vim.log.levels.ERROR)
    end
  end,
})
