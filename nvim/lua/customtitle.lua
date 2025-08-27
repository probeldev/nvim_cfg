local M = {}

function M.setup()

vim.opt.title = true
vim.opt.titlelen = 85
vim.opt.titlestring = [[%{expand('%:p:~')} %(%{&modified ? '[+]' : ''}%) - nvim]]

-- Обновлять заголовок при смене буфера и изменении файла
vim.api.nvim_create_augroup("DynamicTitle", { clear = true })
vim.api.nvim_create_autocmd({"BufEnter", "BufWritePost"}, {
  group = "DynamicTitle",
  callback = function()
    vim.opt.titlestring = [[NeoVim: %{expand('%:p:~')} %(%{&modified ? '[+]' : ''}%) - nvim]]
  end
})

end

return M
