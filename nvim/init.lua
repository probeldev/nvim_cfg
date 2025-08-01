vim.opt.spell = true                -- Включить проверку орфографии
vim.opt.spelllang = { 'ru', 'en' }  -- Установить языки (русский и английский)
vim.opt.spelloptions = 'camel'      -- Опционально: улучшает проверку для CamelCase слов

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
vim.fn['plug#']('nvim-lualine/lualine.nvim')
vim.fn['plug#']('projekt0n/github-nvim-theme')
vim.fn['plug#']('dstein64/nvim-scrollview')

vim.fn['plug#']('utilyre/barbecue.nvim')
vim.fn['plug#']('SmiteshP/nvim-navic')


vim.fn['plug#']('sontungexpt/stcursorword')
vim.fn['plug#']('karb94/neoscroll.nvim')


vim.fn['plug#']('MeanderingProgrammer/render-markdown.nvim')
vim.fn['plug#end']()

-- Базовые настройки редактора
vim.opt.mouse = 'a'                          -- Включить мышь
vim.opt.number = true                        -- Показывать номера строк
vim.opt.tabstop = 4                          -- Размер табуляции
vim.opt.shiftwidth = 4                       -- Размер отступа
vim.opt.cursorline = true                    -- Подсветка текущей строки
vim.opt.clipboard = 'unnamedplus'            -- Использовать системный буфер обмена

vim.opt.list = true -- Включает отображение скрытых символов
vim.opt.listchars = {
  eol = '¬',      -- Перенос строки (End Of Line)
  tab = '>-',     -- Табы (показывает начало и заполнение)
  trail = '~',    -- Пробелы в конце строки
  extends = '>',  -- Если строка продолжается за пределы экрана (справа)
  precedes = '<', -- Если строка продолжается за пределы экрана (слева)
  space = ' ',    -- Пробелы (если нужно их подсвечивать)
}

-- Цветовая схема
vim.opt.background = 'light'
vim.cmd('colorscheme github_light')

-- Настройка плагинов
require('toggleterm').setup()
require('lualine').setup()

-- Настройка nvim-tree
require('nvim-tree').setup({
  diagnostics = {
    enable = true,
    show_on_dirs = true,
  },
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

-- Дополнительные настройки плагинов
require('barbecue').setup()
require('stcursorword').setup()
require('neoscroll').setup()
require('telescope').setup()

-- Подключение пользовательских модулей
require("hotkey").setup()
require("lsp").setup()
require('render-markdown').setup({})

