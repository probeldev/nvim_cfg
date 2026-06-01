return {
  cmd = { "vtsls", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", "tsconfig.json", ".git" },
  settings = {
    typescript = {
      tsdk = vim.fn.expand("~/.nvm/versions/node/v20.17.0/lib/node_modules/typescript/lib"),
    },
  },
}
