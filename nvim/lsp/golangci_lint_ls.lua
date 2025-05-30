vim.lsp.config.golangci_lint_ls = {
  cmd = { 'golangci-lint-langserver' },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { 'go.mod', '.git' })
    if root then
      on_dir(root)
    else
      local cwd = vim.fn.getcwd()
      on_dir(cwd)
    end
  end,
  filetypes = { 'go', 'gomod' },
  init_options = {
    command = {
      'golangci-lint', 'run', "--output.json.path", "stdout", "--show-stats=false", "--issues-exit-code=1",
    },
  },
  on_init = function(client)
  end,
}
