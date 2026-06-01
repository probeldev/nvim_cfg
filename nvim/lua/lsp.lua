-- lua/lsp.lua
local M = {}

function M.setup()
-- Включение LSP серверов
vim.lsp.enable({ 
	'gopls',
	'golangci_lint_ls',
	'vtsls',
	'ra'
})
vim.lsp.log.set_level("debug")

-- Настройка диагностики (показ всех уровней)
vim.diagnostic.config({
	virtual_lines =  true,
	virtual_text = false,
	signs = true,
	update_in_insert = true,
	severity_sort = true,
})

vim.opt.completeopt = { 'menuone', 'noselect', 'noinsert' }
-- Автоматическое включение автодополнения для LSP
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		if client.server_capabilities.completionProvider then
			-- Только буквы (латиница + кириллица + возможно другие языки)
			client.server_capabilities.completionProvider.triggerCharacters = {
				'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
				'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
				'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
				'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
				'а', 'б', 'в', 'г', 'д', 'е', 'ё', 'ж', 'з', 'и', 'й', 'к', 'л',
				'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш',
				'щ', 'ъ', 'ы', 'ь', 'э', 'ю', 'я',
				'А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ё', 'Ж', 'З', 'И', 'Й', 'К', 'Л',
				'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф', 'Х', 'Ц', 'Ч', 'Ш',
				'Щ', 'Ъ', 'Ы', 'Ь', 'Э', 'Ю', 'Я',
				'.',
			}
		end

		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { 
				autotrigger = true,
				convert = function(item)
					-- Опционально: можно преобразовывать элементы дополнения
					return {
						abbr = item.label:gsub('%b()', ''),  -- Удаляем скобки для краткости
						word = item.insertText or item.label,  -- Используем insertText если есть
						kind = item.kind,                     -- Сохраняем тип
					}
				end
			})
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    vim.lsp.buf.format({ async = false })  -- синхронное форматирование
  end,
})

-- goimports для Go файлов
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local original_content = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    local formatted = vim.fn.systemlist('goimports', original_content)
    
    if vim.v.shell_error == 0 then
      vim.api.nvim_buf_set_lines(0, 0, -1, false, formatted)
      vim.api.nvim_win_set_cursor(0, cursor_pos)
    else
      vim.notify("goimports failed: " .. table.concat(formatted, "\n"), vim.log.levels.ERROR)
    end
  end,
})

end

return M
