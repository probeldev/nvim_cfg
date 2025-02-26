nnoremap <space>a :NvimTreeToggle<CR>
nnoremap <space>g :LazyGit<CR>
nnoremap <space>c :lua require('lazyclip').show_clipboard()<CR>
nnoremap gr :Telescope lsp_references<CR>
nnoremap <space>b :Telescope lsp_document_symbols symbol_width=50 <CR>
nnoremap <space>e :Telescope diagnostics bufnr=0<CR>
nnoremap <space>g :Telescope current_buffer_fuzzy_find<CR>
nnoremap <space>p <cmd>Telescope find_files previewer=false<cr>
nnoremap <space>f <cmd>Telescope live_grep<cr>

vnoremap <space>f :'<,'>!go-multiline-formatter<CR>

nnoremap <space>x <Cmd>ToggleTerm size=80 direction=float<CR>
nnoremap <space>s <Cmd>ToggleTerm size=10 direction=horizontal<CR>

nnoremap <silent>    <space>h <Cmd>BufferPrevious<CR>
nnoremap <silent>    <space>l <Cmd>BufferNext<CR>
nnoremap <silent>    <space>j <Cmd>BufferClose<CR>


tnoremap <Esc> <C-\><C-n>
noremap <C-a> ^
noremap <C-e> $
