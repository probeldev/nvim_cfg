call plug#begin()

set mouse=a

Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
"nnoremap <leader>n :NERDTreeFocus<CR>
"nnoremap <C-w> :NERDTree<CR>
nnoremap <C-w> :NERDTreeToggle<CR>
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

"Plug 'xemptuous/sqlua.nvim' " Не разобрался посмотреть потом:)

nnoremap <C-p> <cmd>Telescope find_files<cr>
nnoremap <C-f> <cmd>Telescope live_grep<cr>

call plug#end()

colorscheme duskfox

nnoremap <silent>    <A-,> <Cmd>BufferPrevious<CR>
nnoremap <silent>    <A-.> <Cmd>BufferNext<CR>
nnoremap <silent>    <A-c> <Cmd>BufferClose<CR>



