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
    -- Сохраняем текущую позицию курсора
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    -- Выполняем goimports
    vim.cmd("%!goimports")
    -- Восстанавливаем позицию курсора
    vim.api.nvim_win_set_cursor(0, cursor_pos)
  end,
})
