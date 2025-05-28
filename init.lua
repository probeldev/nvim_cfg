-- Импорт пользовательских горячих клавиш
vim.cmd('source ~/.config/nvim/hotkey.vim')

-- Инициализация менеджера плагинов (vim-plug)
local Plug = vim.fn['plug#begin']()
vim.fn['plug#']('nvim-tree/nvim-tree.lua')
vim.fn['plug#']('nvim-lua/plenary.nvim')
vim.fn['plug#']('nvim-tree/nvim-web-devicons')
vim.fn['plug#']('MunifTanjim/nui.nvim')
vim.fn['plug#']('hrsh7th/nvim-cmp')
vim.fn['plug#']('hrsh7th/cmp-nvim-lsp')
vim.fn['plug#']('saadparwaiz1/cmp_luasnip')
vim.fn['plug#']('L3MON4D3/LuaSnip')
vim.fn['plug#']('ray-x/lsp_signature.nvim')
vim.fn['plug#']('lewis6991/gitsigns.nvim')
vim.fn['plug#']('romgrk/barbar.nvim')
vim.fn['plug#']('ryanoasis/vim-devicons')
vim.fn['plug#']('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.6' })
vim.fn['plug#']('tomtom/tcomment_vim')
vim.fn['plug#']('akinsho/toggleterm.nvim', { ['tag'] = '*' })
vim.fn['plug#']('tpope/vim-dadbod')
vim.fn['plug#']('kristijanhusak/vim-dadbod-ui')
vim.fn['plug#']('nvim-lualine/lualine.nvim')
vim.fn['plug#']('stevearc/conform.nvim')
vim.fn['plug#']('projekt0n/github-nvim-theme')
vim.fn['plug#']('dstein64/nvim-scrollview')
vim.fn['plug#']('SmiteshP/nvim-navic')
vim.fn['plug#']('utilyre/barbecue.nvim')
vim.fn['plug#']('sontungexpt/stcursorword')
vim.fn['plug#']('David-Kunz/gen.nvim')
vim.fn['plug#']('kdheepak/lazygit.nvim')
vim.fn['plug#']('karb94/neoscroll.nvim')
vim.fn['plug#']('tanvirtin/vgit.nvim')
vim.fn['plug#end']()

-- Базовые настройки редактора
vim.opt.mouse = 'a'                          -- Включить мышь
vim.opt.number = true                        -- Показывать номера строк
vim.opt.tabstop = 4                          -- Размер табуляции
vim.opt.shiftwidth = 4                       -- Размер отступа
vim.opt.list = true                          -- Показывать скрытые символы
vim.opt.listchars = 'tab:|—,trail:⋅,nbsp:⋅'  -- Символы для табуляции и пробелов
vim.opt.cursorline = true                    -- Подсветка текущей строки
vim.opt.clipboard = 'unnamedplus'            -- Использовать системный буфер обмена

-- Цветовая схема
vim.opt.background = 'light'
vim.cmd('colorscheme github_light')

-- Настройка плагинов
require('toggleterm').setup()
require('vgit').setup()
require('lualine').setup()

-- Форматирование с conform.nvim
require('conform').setup({
  formatters_by_ft = {
    sh = { 'shfmt' },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})


-- Перехватчик для textDocument/publishDiagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = {
      prefix = '●',
    },
    signs = true,
    update_in_insert = true,
    severity_sort = true,
  }
)



-- Включение LSP серверов
vim.lsp.enable({ 'gopls', 'golangci_lint_ls' })

-- Настройка диагностики (показ всех уровней)
vim.diagnostic.config({
  virtual_lines =  true,
  virtual_text = false,
  signs = true,
  update_in_insert = true,
  severity_sort = true,
})

-- Автодополнение с nvim-cmp
vim.o.completeopt = 'menuone,noselect'

local cmp = require('cmp')
cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }),
}

-- Автоматическое включение автодополнения для LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client.supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf)
    end
  end,
})

-- Настройка nvim-tree
require('nvim-tree').setup({
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
})

-- Настройка barbar
require('barbar').setup({
  sidebar_filetypes = {
    NvimTree = true,
    undotree = {
      text = 'undotree',
      align = 'center',
    },
    ['neo-tree'] = { event = 'BufWipeout' },
    Outline = { event = 'BufWinLeave', text = 'symbols-outline', align = 'right' },
  },
})

-- Дополнительные настройки плагинов
require('barbecue').setup()
require('stcursorword').setup()
require('neoscroll').setup()
require('telescope').setup()
