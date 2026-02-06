-- hotkey.lua
local M = {}

-- Установка <space> как leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

function M.setup()
  local map = vim.keymap.set

  -- Нормальный режим
  map("n", "<leader>a", ":NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
  -- map("n", "<leader>c", ":lua require('lazyclip').show_clipboard()<CR>", { desc = "Show clipboard" }) -- Удалите или исправьте
  -- map("n", "gr", ":Telescope lsp_references<CR>", { desc = "LSP references" })

  map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", { noremap = true, silent = true })

  map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", { noremap = true, silent = true })
  map("n", "<leader>b", ":Telescope lsp_document_symbols symbol_width=50<CR>", { desc = "Document symbols" })
  map("n", "<leader>e", ":Telescope diagnostics bufnr=0<CR>", { desc = "Diagnostics" })
  -- map("n", "<leader>fg", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Fuzzy find in buffer" })
  map("n", "<leader>p", "<cmd>Telescope find_files previewer=false layout_strategy=center<CR>", { desc = "Find files" })
  map("n", "<leader>f", "<cmd>Telescope live_grep<CR>", { desc = "Live grep" })

  map("n", "<leader>d", "<cmd>DbWorkflow<CR>")

  -- map("n", "<leader>p", "<cmd>RgFiles<CR>", { desc = "Find files" })
  -- map("n", "<leader>f", "<cmd>Rg<CR>", { desc = "Live grep" })

  -- Визуальный режим
  map("v", "<leader>f", ":'<,'>!go-multiline-formatter -multiline<CR>", { desc = "Format with go-multiline-formatter" })
  map("v", "<leader>l", ":'<,'>!go-multiline-formatter -logfunc<CR>", { desc = "Format with go-multiline-formatter" })

  -- Терминал и вкладки
  map("n", "<leader>x", "<Cmd>ToggleTerm size=80 direction=float<CR>", { desc = "Toggle floating terminal" })
  map("n", "<leader>s", "<Cmd>ToggleTerm size=10 direction=horizontal<CR>", { desc = "Toggle horizontal terminal" })

  -- Навигация по буферам
  map("n", "<leader>h", "<Cmd>BufferPrevious<CR>", { desc = "Previous buffer", silent = true })
  map("n", "<leader>l", "<Cmd>BufferNext<CR>", { desc = "Next buffer", silent = true })
  map("n", "<leader>j", "<Cmd>BufferClose<CR>", { desc = "Close buffer", silent = true })

  -- Терминал
  map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

  -- Перемещение по строке
  map({ "n", "v" }, "<C-a>", "^", { desc = "Move to start of line" })
  map({ "n", "v" }, "<C-e>", "$", { desc = "Move to end of line" })

  vim.keymap.set('i', '<C-Space>', '<Nop>', { silent = true })


  --  предыдущая из гита, следующая из гита
  map("n", "gj", "<cmd>Gitsigns next_hunk<CR>")
  map("n", "gk", "<cmd>Gitsigns prev_hunk<CR>")
end

return M
