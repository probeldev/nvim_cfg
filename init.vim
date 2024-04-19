call plug#begin()

set mouse=a
set number
" set relativenumber

" настройка отступов
set tabstop=4
set shiftwidth=4
set list
set listchars=tab:\|\—,trail:⋅,nbsp:⋅

set smartindent
" Копирует отступ от предыдущей строки
set autoindent

" Подсетка текущей строки
set cursorline


Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
"nnoremap <leader>n :NERDTreeFocus<CR>
"nnoremap <C-w> :NERDTree<CR>
nnoremap <A-a> :NERDTreeToggle<CR>
"nnoremap <C-f> :NERDTreeFind<CR>

Plug 'nvim-treesitter/nvim-treesitter'
Plug 'EdenEast/nightfox.nvim'

Plug 'vim-airline/vim-airline'

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


Plug 'Mofiqul/adwaita.nvim'


nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-f> <cmd>Telescope live_grep<cr>

call plug#end()

set background=light
colorscheme adwaita


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
