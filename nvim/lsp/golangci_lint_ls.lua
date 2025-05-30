-- lsp/golangci_lint_ls.lua
return {
  cmd = { 'golangci-lint-langserver' },
  filetypes = { 'go', 'gomod' },
  init_options = {
    command = {
      'golangci-lint', 'run', 
    },
  },
  root_dir = vim.fs.dirname(vim.fs.find({ 'go.mod', '.git' }, { upward = true })[1]),
}
