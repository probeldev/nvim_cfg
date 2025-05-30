-- lua/lsp.lua
local M = {}

function M.setup()
-- Перехватчик для textDocument/publishDiagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, {
		virtual_text = {
			prefix = '●',
		},
		signs = true,
		update_in_insert = true,
		severity_sort = true,
	}
)



-- Включение LSP серверов
vim.lsp.enable({ 'gopls', 'golangci_lint_ls' })
vim.lsp.set_log_level("debug")

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


end

return M
