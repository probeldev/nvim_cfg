vim.lsp.config.vtsls = {
  cmd = { "vtsls", "--stdio" }, -- Команда для запуска сервера
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" }, -- Поддерживаемые типы файлов
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" }, -- Файлы/папки, определяющие корень проекта
  settings = { -- Настройки, передаваемые серверу
    typescript = {
      tsdk = vim.fn.expand("~/.nvm/versions/node/v20.17.0/lib/node_modules/typescript/lib"), -- Путь к TypeScript SDK (указать свой путь, если требуется)
    },
  },
}
