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
