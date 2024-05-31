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

Plug 'nvim-neo-tree/neo-tree.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'MunifTanjim/nui.nvim'

nnoremap <A-a> :Neotree<CR>


Plug 'nvim-treesitter/nvim-treesitter'
Plug 'EdenEast/nightfox.nvim'


Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Plug 'neoclide/coc.nvim', {'branch': 'release'}
inoremap <silent><expr> <cr> coc#pum#visible() && coc#pum#info()['index'] != -1 ? coc#pum#confirm() :
        \ "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

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
Plug 'sindrets/diffview.nvim'

Plug 'nvim-lualine/lualine.nvim'
" If you want to have icons in your statusline choose one of these
Plug 'nvim-tree/nvim-web-devicons'


Plug 'aveplen/ruscmd.nvim'

Plug 'stevearc/conform.nvim'

" theme
Plug 'projekt0n/github-nvim-theme'

Plug 'dstein64/nvim-scrollview'

" barbecue
Plug 'SmiteshP/nvim-navic'
Plug 'utilyre/barbecue.nvim'


Plug 'sontungexpt/stcursorword'


Plug 'folke/which-key.nvim'

nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-f> <cmd>Telescope live_grep<cr>


call plug#end()

set background=light
" colorscheme adwaita
colorscheme github_light


nnoremap <silent>    <A-h> <Cmd>BufferPrevious<CR>
nnoremap <silent>    <A-l> <Cmd>BufferNext<CR>
nnoremap <silent>    <A-j> <Cmd>BufferClose<CR>

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gr <Plug>(coc-references)

" Symbol renaming
nmap <A-r> <Plug>(coc-rename)
nmap <A-e> :CocList diagnostics<CR>

lua require("toggleterm").setup()
nnoremap <A-x> <Cmd>ToggleTerm size=80 direction=float<CR>
nnoremap <A-s> <Cmd>ToggleTerm size=80 direction=vertical<CR>
tnoremap <Esc> <C-\><C-n>

nmap <A-d> :DiffviewOpen<CR>

" Use ctrl-[hjkl] to select the active split!
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

lua require('vgit').setup()
lua require('lualine').setup()

lua << EOF
require('ruscmd').setup{}
EOF

lua << EOF
require("conform").setup({
	formatters_by_ft = {
    -- Use a sub-list to run only the first available formatter
    javascript = { { "prettierd", "prettier" } },
    html = { { "prettierd", "prettier" } },
    css = { { "prettierd", "prettier" } },
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
require("which-key").setup({
  ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
})
EOF
