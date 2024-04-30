call plug#begin()

set mouse=a
set number
" set relativenumber

" настройка отступов
" set tabstop=4
" set shiftwidth=4
" set list
" set listchars=tab:\|\—,trail:⋅,nbsp:⋅

" set smartindent
" Копирует отступ от предыдущей строки
" set autoindent

" Подсетка текущей строки
set cursorline

" Буфур обмена
set clipboard=unnamedplus


Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
"nnoremap <leader>n :NERDTreeFocus<CR>
"nnoremap <C-w> :NERDTree<CR>
nnoremap <A-a> :NERDTreeToggle<CR>
"nnoremap <C-f> :NERDTreeFind<CR>

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


Plug 'nvim-lualine/lualine.nvim'
" If you want to have icons in your statusline choose one of these
Plug 'nvim-tree/nvim-web-devicons'


Plug 'aveplen/ruscmd.nvim'

Plug 'stevearc/conform.nvim'

Plug 'projekt0n/github-nvim-theme'


nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-f> <cmd>Telescope live_grep<cr>

call plug#end()

" set background=light
" colorscheme adwaita
colorscheme github_light  


nnoremap <silent>    <A-h> <Cmd>BufferPrevious<CR>
nnoremap <silent>    <A-l> <Cmd>BufferNext<CR>
nnoremap <silent>    <A-j> <Cmd>BufferClose<CR>


lua require("toggleterm").setup()
nnoremap <A-x> <Cmd>ToggleTerm size=80 direction=float<CR>
nnoremap <A-s> <Cmd>ToggleTerm size=80 direction=vertical<CR>
tnoremap <Esc> <C-\><C-n>


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
  },
   format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
EOF
