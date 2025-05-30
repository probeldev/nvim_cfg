-- lsp/gopls.lua
return {
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
      buildFlags = { '-tags', 'integration' },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      diagnosticsTrigger = "Edit",
    },
  },
  root_dir = vim.fs.dirname(vim.fs.find({ 'go.mod', '.git' }, { upward = true })[1])
}
