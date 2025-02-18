call plug#begin()

set mouse=a
set number
" set relativenumber

" настройка отступов
set tabstop=4
set shiftwidth=4
set list
set listchars=tab:\|\—,trail:⋅,nbsp:⋅

" set smartindent
" Копирует отступ от предыдущей строки
" set autoindent

" Подсетка текущей строки
set cursorline

" Буфур обмена
set clipboard=unnamedplus


Plug 'nvim-tree/nvim-tree.lua'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'

nnoremap <space>a :NvimTreeToggle<CR>
nnoremap <space>g :LazyGit<CR>
nnoremap <space>c :lua require('lazyclip').show_clipboard()<CR>

vnoremap <space>f :'<,'>!go-multiline-formatter<CR>


Plug 'nvim-treesitter/nvim-treesitter'
Plug 'EdenEast/nightfox.nvim'


Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
" Plug 'crusj/structrue-go.nvim'

" Plug 'neoclide/coc.nvim', {'branch': 'release'}

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'L3MON4D3/LuaSnip'
Plug 'ray-x/lsp_signature.nvim'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'



" inoremap <silent><expr> <cr> coc#pum#visible() && coc#pum#info()['index'] != -1 ? coc#pum#confirm() :
"         \ "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"


Plug 'nvim-tree/nvim-web-devicons' " OPTIONAL: for file icons
Plug 'lewis6991/gitsigns.nvim' " OPTIONAL: for git status
Plug 'romgrk/barbar.nvim'

Plug 'ryanoasis/vim-devicons'

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.6' }


Plug 'tomtom/tcomment_vim'

Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}

Plug 'MunifTanjim/nui.nvim'
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'


" Plug 'Mofiqul/adwaita.nvim'

Plug 'nvim-lua/plenary.nvim'
Plug 'tanvirtin/vgit.nvim'
" Plug 'sindrets/diffview.nvim'

Plug 'nvim-lualine/lualine.nvim'
" If you want to have icons in your statusline choose one of these
Plug 'nvim-tree/nvim-web-devicons'



Plug 'stevearc/conform.nvim'

" theme
Plug 'projekt0n/github-nvim-theme'

Plug 'dstein64/nvim-scrollview'

" barbecue
Plug 'SmiteshP/nvim-navic'
Plug 'utilyre/barbecue.nvim'


Plug 'sontungexpt/stcursorword'



Plug 'David-Kunz/gen.nvim'


Plug 'kdheepak/lazygit.nvim'

Plug 'karb94/neoscroll.nvim'


Plug 'atiladefreitas/lazyclip'

Plug 'dcampos/nvim-snippy'

Plug 'lukas-reineke/indent-blankline.nvim'

Plug 'https://git.sr.ht/~whynothugo/lsp_lines.nvim'

nnoremap <space>p <cmd>Telescope find_files<cr>
nnoremap <space>f <cmd>Telescope live_grep<cr>


call plug#end()

set background=light
" colorscheme adwaita
colorscheme github_light


nnoremap <silent>    <space>h <Cmd>BufferPrevious<CR>
nnoremap <silent>    <space>l <Cmd>BufferNext<CR>
nnoremap <silent>    <space>j <Cmd>BufferClose<CR>

" nmap <silent> gd <Plug>(coc-definition)
" nmap <silent> gr <Plug>(coc-references)

" Symbol renaming
" nmap <A-r> <Plug>(coc-rename)
" nmap <A-e> :CocList diagnostics<CR>

lua require("toggleterm").setup()
nnoremap <space>x <Cmd>ToggleTerm size=80 direction=float<CR>
nnoremap <space>s <Cmd>ToggleTerm size=10 direction=horizontal<CR>
tnoremap <Esc> <C-\><C-n>

" nmap <A-d> :DiffviewOpen<CR>
"
" nmap <A-g> :lua require'structrue-go'.toggle()<CR>


" " Use ctrl-[hjkl] to select the active split!
" nmap <silent> <c-k> :wincmd k<CR>
" nmap <silent> <c-j> :wincmd j<CR>
" nmap <silent> <c-h> :wincmd h<CR>
" nmap <silent> <c-l> :wincmd l<CR>

lua require('vgit').setup()
lua require('lualine').setup()


lua << EOF
require("conform").setup({
	formatters_by_ft = {
    -- Use a sub-list to run only the first available formatter
	-- javascript = { "prettierd", "prettier", stop_after_first = true },
    -- html = {"prettierd", "prettier" },
    -- css = {"prettierd", "prettier"},
    sh = { "shfmt" }
  },
   format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
EOF

lua << EOF 
require("barbecue").setup()
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


lua << EOF 
    require("stcursorword").setup({
        max_word_length = 100, -- if cursorword length > max_word_length then not highlight
        min_word_length = 2, -- if cursorword length < min_word_length then not highlight
        excluded = {
            filetypes = {
                "TelescopePrompt",
            },
            buftypes = {
                -- "nofile",
                -- "terminal",
            },
            patterns = { -- the pattern to match with the file path
                -- "%.png$",
                -- "%.jpg$",
                -- "%.jpeg$",
                -- "%.pdf$",
                -- "%.zip$",
                -- "%.tar$",
                -- "%.tar%.gz$",
                -- "%.tar%.xz$",
                -- "%.tar%.bz2$",
                -- "%.rar$",
                -- "%.7z$",
                -- "%.mp3$",
                -- "%.mp4$",
            },
        },
        highlight = {
            underline = true,
            fg = nil,
            bg = nil,
        },
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



" переход в начало / в конец строки
noremap <C-a> ^
noremap <C-e> $


lua << EOF
-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- luasnip setup
local luasnip = require 'luasnip'
local async = require "plenary.async"

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  completion = {
    -- autocomplete = true 
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
      elseif luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, true, true), 'n')
      elseif luasnip.jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), '')
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

local nvim_lsp = require('lspconfig')


-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
--  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  require "lsp_signature".on_attach({
      bind = true, -- This is mandatory, otherwise border config won't get registered.
      floating_window = true,
      floating_window_above_cur_line = true,
      floating_window_off_x = 20,
      doc_lines = 10,
      hint_prefix = '👻 '
    }, bufnr)  -- Note: add in lsp client on-attach
end



-- Stylelint format after save
require'lspconfig'.stylelint_lsp.setup{
  settings = {
    stylelintplus = {
      autoFixOnSave = true,
      autoFixOnFormat = true,
    }
  }
}

require'lspconfig'.clangd.setup({
  cmd = {'clangd', '--background-index', '--clang-tidy', '--log=verbose'},
  init_options = {
    fallbackFlags = { },
  },
})


-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'gopls', 'vtsls', 'intelephense'}
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end

-- Для lsp-lines
vim.diagnostic.config({
  virtual_text = false,
})

EOF

lua << EOF
	require('mason').setup()
EOF

lua <<EOF
require'nvim-treesitter.configs'.setup {
	ensure_installed = { all },
	auto_install = true,
	
	highlight = {
	    enable = true,
	},
}
EOF

lua << EOF
	require('neoscroll').setup({ mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>'} })
EOF

lua << EOF
	require("lazyclip").setup()
EOF

lua << EOF
	require('snippy').setup({
		mappings = {
			is = {
				['<Tab>'] = 'expand_or_advance',
				['<S-Tab>'] = 'previous',
			},
			nx = {
				['<leader>x'] = 'cut_text',
			},
		},
	})
EOF

lua << EOF
	require("lsp_lines").setup()
EOF
