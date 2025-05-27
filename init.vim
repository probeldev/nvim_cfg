source ~/.config/nvim/hotkey.vim

call plug#begin()

set mouse=a
set number

" Настройка отступов
set tabstop=4
set shiftwidth=4
set list
set listchars=tab:\|\—,trail:⋅,nbsp:⋅
set cursorline
set clipboard=unnamedplus

" Плагины (убраны lspconfig и mason)
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
Plug 'ray-x/lsp_signature.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'ryanoasis/vim-devicons'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.6' }
Plug 'tomtom/tcomment_vim'
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'nvim-lualine/lualine.nvim'
Plug 'stevearc/conform.nvim'
Plug 'projekt0n/github-nvim-theme'
Plug 'dstein64/nvim-scrollview'
Plug 'SmiteshP/nvim-navic'
Plug 'utilyre/barbecue.nvim'
Plug 'sontungexpt/stcursorword'
Plug 'David-Kunz/gen.nvim'
Plug 'kdheepak/lazygit.nvim'
Plug 'karb94/neoscroll.nvim'
Plug 'tanvirtin/vgit.nvim'

call plug#end()

" Цветовая схема
set background=light
colorscheme github_light

" Базовые настройки
lua require("toggleterm").setup()
lua require('vgit').setup()
lua require('lualine').setup()

" Форматирование
lua <<EOF
require("conform").setup({
  formatters_by_ft = {
    sh = { "shfmt" }
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
EOF

" LSP настройки
lua <<EOF
-- Настройки LSP серверов
vim.lsp.config.gopls = {
  cmd = {'gopls'},
  root_markers = {'go.mod'},
  filetypes = {'go'},
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        shadow = true,
        unusedwrite = true,
      },
      staticcheck = true,
      completeUnimported = true,
      directoryFilters = { "-.git", "-node_modules" },
    },
  },
}

vim.lsp.config.golangci_lint_ls = {
  cmd = {'golangci-lint-langserver'},
  root_markers = {'.git', 'go.mod'},
  filetypes = {'go', 'gomod'},
  init_options = {
    command = {
      "golangci-lint", "run", "--output.json.path", "stdout",
      "--show-stats=false", "--issues-exit-code=1"
    }
  }
}

-- Включение LSP серверов
vim.lsp.enable({'gopls', 'golangci_lint_ls'})

-- Настройка диагностики
vim.diagnostic.config({
  virtual_lines = {
    current_line = true,
  },
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
    prefix = '●',
  },
  signs = true,
  underline = true,
  update_in_insert = false,
})

-- Автодополнение
vim.o.completeopt = 'menuone,noselect'

local cmp = require 'cmp'
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

-- Автоматическое включение LSP автодополнения
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client.supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf)
    end
  end,
})
EOF

lua << EOF 
require("nvim-tree").setup({
diagnostics = {
      enable = true,
      show_on_dirs = true,
    }, 
})
EOF


lua << EOF 
require("barbar").setup({
 sidebar_filetypes = {
    -- Use the default values: {event = 'BufWinLeave', text = '', align = 'left'}
    NvimTree = true,
    -- Or, specify the text used for the offset:
    undotree = {
      text = 'undotree',
      align = 'center', -- *optionally* specify an alignment (either 'left', 'center', or 'right')
    },
    -- Or, specify the event which the sidebar executes when leaving:
    ['neo-tree'] = {event = 'BufWipeout'},
    -- Or, specify all three
    Outline = {event = 'BufWinLeave', text = 'symbols-outline', align = 'right'},
  },
})
EOF


" Дополнительные настройки плагинов
lua <<EOF
require("barbecue").setup()
require("stcursorword").setup()
require("neoscroll").setup()
require("telescope").setup()
EOF
