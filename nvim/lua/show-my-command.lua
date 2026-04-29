local M = {}

-- === Команды для разных режимов ===
-- Теперь func это функция, а не строка!
local my_commands = {
	-- === Команды для ВИЗУАЛЬНОГО режима (VISUAL) ===
	visual_commands = {
		{
			name = "OpenCode: Ask",
			func = function()
				require("opencode").ask("@this: ", { submit = true })
			end
		},
	},
	-- === Команды для НОРМАЛЬНОГО режима (NORMAL) ===
	normal_commands = {
		{
			name = "OpenCode: Open",
			func = function()
				require("opencode").toggle()
			end
		},
		{
			name = "Git: Show diff",
			func = function()
				vim.cmd("Gitsigns diffthis")
			end
		},
		{
			name = "Git: Stage this file",
			func = function()
				vim.cmd("Gitsigns stage_buffer")
			end
		},
		{
			name = "LSP: Show symbols",
			func = function()
				require("telescope.builtin").lsp_document_symbols({ symbol_width = 50 })
			end
		},
	},
}

local function get_current_mode()
	local mode = vim.fn.mode()
	if mode == "v" or mode == "V" or mode == "\22" then -- "\22" это Ctrl+V (режим выделения блока)
		return "visual"
	else
		return "normal"
	end
end

function M.show_my_commands(forced_mode, visual_marks)
	local mode = forced_mode or get_current_mode()
	local commands_list = {}

	-- Выбираем список в зависимости от режима
	if mode == "visual" then
		commands_list = my_commands.visual_commands
	else
		commands_list = my_commands.normal_commands
	end

	-- Запускаем Telescope
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values

	pickers.new({}, {
		prompt_title = "Мои команды (" .. mode .. " режим)",
		layout_strategy = "center",
		layout_config = {
			width = 0.5,
			height = 0.4,
			prompt_position = "top",
		},
		sorting_strategy = "ascending",
		border = true,
		borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		finder = finders.new_table {
			results = commands_list,
			entry_maker = function(entry)
				return {
					value = entry,
					display = entry.name,
					ordinal = entry.name,
				}
			end,
		},
		sorter = conf.generic_sorter({}),
		attach_mappings = function(prompt_bufnr)
			actions.select_default:replace(function()
				actions.close(prompt_bufnr)
				local selection = action_state.get_selected_entry()
				-- Восстанавливаем визуальное выделение если есть
				if visual_marks then
					local buf = vim.api.nvim_get_current_buf()
					vim.api.nvim_buf_set_mark(buf, "<", visual_marks.start_pos[2], visual_marks.start_pos[3] - 1, {})
					vim.api.nvim_buf_set_mark(buf, ">", visual_marks.end_pos[2], visual_marks.end_pos[3] - 1, {})
					vim.cmd("normal! gv")
				end
				-- Выполняем команду (теперь это функция!)
				selection.value.func()
			end)
			return true
		end,
	}):find()
end

vim.api.nvim_create_user_command("ShowMyCommands", function(opts)
	-- Сохраняем режим из опций команды (для визуального режима)
	local mode = opts.range == 2 and "visual" or nil
	-- Сохраняем позиции визуального выделения
	local visual_marks = nil
	if mode == "visual" then
		visual_marks = {
			start_pos = vim.fn.getpos("'<"),
			end_pos = vim.fn.getpos("'>")
		}
	end
	M.show_my_commands(mode, visual_marks)
end, { range = true })

function M.setup()
	-- Горячие клавиши настраиваются в init.lua или здесь
end

return M
