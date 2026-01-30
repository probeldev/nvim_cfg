local M = {}

vim.opt.spell = true                -- Включить проверку орфографии
vim.opt.spelllang = { 'ru', 'en' }  -- Установить языки (русский и английский)
vim.opt.spelloptions = 'camel'      -- Опционально: улучшает проверку для CamelCase слов

-- Настройки переноса текста
vim.o.wrap = true           -- включить перенос
vim.o.linebreak = true      -- не разбивать слова
vim.o.breakindent = true    -- отступ для перенесенных строк
vim.o.showbreak = '↪ '      -- символ в начале перенесенной строки (опционально)
vim.o.list = false          -- важно для корректного отображения

-- Базовые настройки редактора
vim.opt.mouse = 'a'                          -- Включить мышь
vim.opt.number = true                        -- Показывать номера строк
vim.opt.tabstop = 4                          -- Размер табуляции
vim.opt.shiftwidth = 4                       -- Размер отступа
vim.opt.cursorline = true                    -- Подсветка текущей строки
vim.opt.clipboard = 'unnamedplus'            -- Использовать системный буфер обмена

vim.opt.laststatus = 0 -- отключает сатусбар


vim.opt.list = true -- Включает отображение скрытых символов
vim.opt.listchars = {
  eol = '¬',      -- Перенос строки (End Of Line)
  tab = '>-',     -- Табы (показывает начало и заполнение)
  trail = '~',    -- Пробелы в конце строки
  extends = '>',  -- Если строка продолжается за пределы экрана (справа)
  precedes = '<', -- Если строка продолжается за пределы экрана (слева)
  space = ' ',    -- Пробелы (если нужно их подсвечивать)
}

function M.setup()
end

return M
