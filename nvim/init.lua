
-- Настройка путей для swap, backup и undo файлов
vim.opt.directory = { vim.fn.stdpath('data') .. '/swap//', '.' }
vim.opt.backupdir = { vim.fn.stdpath('data') .. '/backup//', '.' }
vim.opt.undodir = { vim.fn.stdpath('data') .. '/undo//', '.' }

-- Создать необходимые директории при запуске Neovim
local function create_directories()
  local data_dir = vim.fn.stdpath('data')
  local dirs = {
    data_dir .. '/swap',
    data_dir .. '/backup', 
    data_dir .. '/undo',
  }
  
  for _, dir in ipairs(dirs) do
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end
end

create_directories()

vim.o.grepprg = "rg --vimgrep"

-- Отключить все возможности Tree-sitter
vim.treesitter.start = function() end

-- Добавляем ~/.config/nvim/ в package.path
package.path = package.path .. ";" .. vim.fn.stdpath("config") .. "/?.lua"

-- Инициализация менеджера плагинов (vim-plug)
local Plug = vim.fn['plug#begin']()
vim.fn['plug#']('nvim-tree/nvim-tree.lua')
vim.fn['plug#']('nvim-lua/plenary.nvim')
vim.fn['plug#']('nvim-tree/nvim-web-devicons')
vim.fn['plug#']('MunifTanjim/nui.nvim')
vim.fn['plug#']('lewis6991/gitsigns.nvim')
vim.fn['plug#']('romgrk/barbar.nvim')
-- vim.fn['plug#']('ryanoasis/vim-devicons')
vim.fn['plug#']('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.6' })
vim.fn['plug#']('tomtom/tcomment_vim')
vim.fn['plug#']('akinsho/toggleterm.nvim', { ['tag'] = '*' })
vim.fn['plug#']('projekt0n/github-nvim-theme')
vim.fn['plug#']('dstein64/nvim-scrollview')




vim.fn['plug#']('utilyre/barbecue.nvim')
vim.fn['plug#']('SmiteshP/nvim-navic')


vim.fn['plug#']('sontungexpt/stcursorword')
vim.fn['plug#']('karb94/neoscroll.nvim')


vim.fn['plug#']('MeanderingProgrammer/render-markdown.nvim')
vim.fn['plug#']('dhruvasagar/vim-table-mode')

vim.fn['plug#']('David-Kunz/gen.nvim')



vim.fn['plug#']('folke/snacks.nvim') -- for opencode
vim.fn['plug#']('nickjvandyke/opencode.nvim')

vim.fn['plug#end']()


-- Цветовая схема
vim.opt.background = 'light'
vim.cmd('colorscheme github_light')


-- Настройка плагинов
require('toggleterm').setup()

-- Настройка nvim-tree
require('nvim-tree').setup({
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true
  },
  renderer = {
	  indent_width = 3,
	  icons = {
		  show = {
			  hidden = true
		  },
		  git_placement = "after",
		  bookmarks_placement = "after",
		  symlink_arrow = " -> ",
		  glyphs = {
			  folder = {
				  arrow_closed = " ",
				  arrow_open = " ",
				  default = "",
				  open = "",
				  empty = "",
				  empty_open = "",
				  symlink = "",
				  symlink_open = ""
			  },
			  default = "󱓻",
			  symlink = "󱓻",
			  bookmark = "",
			  modified = "",
			  hidden = "󱙝",
			  git = {
				  unstaged = "×",
				  staged = "",
				  unmerged = "󰧾",
				  untracked = "",
				  renamed = "",
				  deleted = "",
				  ignored = "∅"
			  }
		  }
	  }
  }
})

-- Настройка barbar
require('barbar').setup({
  sidebar_filetypes = {
    NvimTree = true,
    undotree = {
      text = 'undotree',
      align = 'center',
    },
    ['neo-tree'] = { event = 'BufWipeout' },
    Outline = { event = 'BufWinLeave', text = 'symbols-outline', align = 'right' },
  },
})


require('gen').setup({
 		-- model = "llama3.1:8b", -- The default model to use.
 		-- model = "qwen2.5-coder:14b", -- The default model to use.
 		model = "qwen2.5-coder:7b", -- The default model to use.
 		-- model = "qwen3:8b", -- The default model to use.
 		-- model = "codellama:7b", -- The default model to use.
		-- model = "deepseek-r1:1.5b", -- The default model to use.
 		-- model = "deepseek-r1:8b-llama-distill-q4_K_M", -- The default model to use.
        display_mode = "horizontal-split", -- The display mode. Can be "float" or "split" or "horizontal-split" or "vertical-split".
        show_prompt = true, -- Shows the prompt submitted to Ollama. Can be true (3 lines) or "full".
        show_model = true, -- Displays which model you are using at the beginning of your chat session.
        no_auto_close = true, -- Never closes the window automatically.
})

require('gen').prompts['Summarize'] = {
  prompt = "Отвечай на русском языке! Summarize the following text:\n$text"
}
require('gen').prompts['Review_Code'] = {
  prompt = "Отвечай на русском языке! Не выводи исправленный код. Review the following code and make concise suggestions:\n```$filetype\n$text\n```",
}

-- Дополнительные настройки плагинов
require('barbecue').setup()
require('stcursorword').setup()
require('neoscroll').setup()
require('telescope').setup()


require('render-markdown').setup({})

-- Хелпер для float окна opencode
local opencode_float_opts = {
  relative = "editor",
  row = math.floor(vim.o.lines * 0.1),
  col = math.floor(vim.o.columns * 0.1),
  width = math.floor(vim.o.columns * 0.8),
  height = math.floor(vim.o.lines * 0.8),
  style = "minimal",
  border = "rounded",
}

vim.g.opencode_opts = {
  server = {
    start = function()
      local term = require("opencode.terminal")
      -- Переопределяем open временно, чтобы курсор оставался в float окне
      local orig_open = term.open
      term.open = function(cmd, opts)
        if term.bufnr ~= nil and vim.api.nvim_buf_is_valid(term.bufnr) then
          return
        end
        opts = opts or opencode_float_opts
        term.bufnr = vim.api.nvim_create_buf(false, false)
        term.winid = vim.api.nvim_open_win(term.bufnr, true, opts)
        vim.api.nvim_create_autocmd("ExitPre", {
          once = true,
          callback = function()
            term.close()
          end,
        })
        term.setup(term.winid)
        vim.fn.jobstart(cmd, {
          term = true,
          on_exit = function()
            term.close()
          end,
        })
        -- НЕ возвращаем курсор назад — оставляем в float окне
        -- Небольшая задержка, чтобы opencode успел инициализироваться
        vim.defer_fn(function()
          if term.winid and vim.api.nvim_win_is_valid(term.winid) then
            vim.api.nvim_set_current_win(term.winid)
            vim.cmd("startinsert")
          end
        end, 100)
      end
      term.open("opencode --port", opencode_float_opts)
      term.open = orig_open
    end,
    stop = function()
      require("opencode.terminal").close()
    end,
    toggle = function()
      local term = require("opencode.terminal")
      if term.winid ~= nil and vim.api.nvim_win_is_valid(term.winid) then
        vim.api.nvim_win_hide(term.winid)
        term.winid = nil
      elseif term.bufnr ~= nil and vim.api.nvim_buf_is_valid(term.bufnr) then
        term.winid = vim.api.nvim_open_win(term.bufnr, true, opencode_float_opts)
        vim.cmd("startinsert")
      else
        -- Вызываем кастомный start
        vim.g.opencode_opts.server.start()
      end
    end,
  },
}

require("opencode")

-- Подключение пользовательских модулей
require("hotkey").setup()
require("ui").setup()
require("lsp").setup()
require("customtitle").setup()




-- Загрузка плагина
require('db-workflow').setup({
    mysql_path = "docker exec -t mysql mysql"  -- для Docker или нестандартного расположения
})

require("remove-completed-tasks")
local show_my_command = require("show-my-command")


vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]]



