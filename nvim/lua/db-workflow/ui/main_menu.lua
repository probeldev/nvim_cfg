local M = {}

local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")

-- Опции главного меню
local menu_options = {
    {
        value = "new_query",
        display = "🆕 Новый запрос",
        description = "Создать новый SQL запрос в буфере",
        icon = "🆕",
        key = "n"
    },
    {
        value = "run_query",
        display = "📝 Выполнить запрос",
        description = "Выполнить SQL запрос с форматированием",
        icon = "📝",
        key = "q"
    },
    {
        value = "run_raw_query", 
        display = "⚡ Выполнить запрос (RAW)",
        description = "Выполнить SQL запрос без форматирования",
        icon = "⚡",
        key = "r"
    },
    {
        value = "show_structure",
        display = "🏗️  Показать структуру БД",
        description = "Показать структуры таблиц и объектов БД",
        icon = "🏗️",
        key = "s"
    }
}

-- Форматирование пунктов меню
local function format_menu_item(option)
    return string.format("%s %-30s %s", option.icon, option.display, option.description)
end

-- Главное меню
function M.show_main_menu(on_select)
    local display_texts = {}
    local value_map = {}
    
    for _, option in ipairs(menu_options) do
        local display_text = format_menu_item(option)
        table.insert(display_texts, display_text)
        value_map[display_text] = option.value
    end
    
    -- Создаем floating window для главного меню
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 85
    local height = #menu_options + 8
    
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = "minimal",
        border = "rounded",
    })
    
    -- Заполняем содержимое
    local content = {
        "┌" .. string.rep("─", width - 2) .. "┐",
        "│" .. string.format(" %-81s", "🚀 DB Workflow - Главное меню") .. "│",
        "│" .. string.format(" %-81s", "Выберите действие:") .. "│",
        "│" .. string.format(" %-81s", "j/k/↑/↓ - навигация, / - поиск, 1-4 - быстрый выбор") .. "│",
        "├" .. string.rep("─", width - 2) .. "┤",
    }
    
    for i, text in ipairs(display_texts) do
        local option = menu_options[i]
        local quick_key = string.format("[%s]", option.key)
        local line = string.format("│ %-2s %-78s │", quick_key, text)
        table.insert(content, line)
    end
    
    table.insert(content, "├" .. string.rep("─", width - 2) .. "┤")
    table.insert(content, "│" .. string.format(" %-81s", "Enter - выбрать, Esc/q - закрыть") .. "│")
    table.insert(content, "└" .. string.rep("─", width - 2) .. "┘")
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'dbworkflow_main_menu')
    
    -- Настройка подсветки
    vim.cmd([[
    syntax match DbWorkflowTitle /^│.*🚀 DB Workflow.*│$/
    syntax match DbWorkflowHelp /^│.*Выберите действие:.*│$/
    syntax match DbWorkflowHelp /^│.*j.k.↑.↓.*│$/
    syntax match DbWorkflowHelp /^│.*Enter - выбрать.*│$/
    syntax match DbWorkflowQuickKey /\[[nqrs]\]/
    syntax match DbWorkflowBorder /^[┌├└][─]*[┐┤┘]$/
    syntax match DbWorkflowBorder /^│/
    
    highlight link DbWorkflowTitle Title
    highlight link DbWorkflowHelp Comment
    highlight link DbWorkflowQuickKey Number
    highlight link DbWorkflowBorder Comment
    ]])
    
    -- Текущая позиция
    local current_line = 6  -- Первый элемент данных
    local max_line = 5 + #display_texts
    
    -- Функция обновления подсветки
    local function update_highlight()
        vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
        
        if current_line >= 6 and current_line <= max_line then
            vim.api.nvim_buf_add_highlight(buf, -1, "Visual", current_line - 1, 0, -1)
        end
    end
    
    -- Функция закрытия окна
    local function close_window()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
    
    -- Функция выбора
    local function select_option(option_value)
        close_window()
        on_select(option_value)
    end
    
    -- Функция выбора текущего элемента
    local function select_current()
        if current_line >= 6 and current_line <= max_line then
            local selected_text = display_texts[current_line - 5]
            if value_map[selected_text] then
                select_option(value_map[selected_text])
                return true
            end
        end
        return false
    end
    
    -- Функция быстрого выбора по цифре
    local function quick_select(key)
        for i, option in ipairs(menu_options) do
            if option.key == key then
                select_option(option.value)
                return true
            end
        end
        return false
    end
    
    -- Функция поиска
    local function search()
        vim.api.nvim_win_close(win, true)
        
        vim.fn.inputsave()
        local pattern = vim.fn.input("Поиск действия: ")
        vim.fn.inputrestore()
        
        if pattern and pattern ~= "" then
            for i, text in ipairs(display_texts) do
                if text:lower():find(pattern:lower(), 1, true) then
                    current_line = i + 5
                    break
                end
            end
        end
        
        -- Пересоздаем окно
        win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = width,
            height = height,
            col = math.floor((vim.o.columns - width) / 2),
            row = math.floor((vim.o.lines - height) / 2),
            style = "minimal",
            border = "rounded",
        })
        
        vim.api.nvim_set_current_win(win)
        update_highlight()
    end
    
    -- Инициализация подсветки
    update_highlight()
    
    -- Настройка keymaps
    local mappings = {
        -- Навигация
        { 'n', 'j', function() 
            if current_line < max_line then
                current_line = current_line + 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        { 'n', 'k', function() 
            if current_line > 6 then
                current_line = current_line - 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        { 'n', '<Down>', function() 
            if current_line < max_line then
                current_line = current_line + 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        { 'n', '<Up>', function() 
            if current_line > 6 then
                current_line = current_line - 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        -- Быстрый выбор по цифрам и буквам
        { 'n', '1', function() quick_select('n') end, { buffer = buf } },
        { 'n', '2', function() quick_select('q') end, { buffer = buf } },
        { 'n', '3', function() quick_select('r') end, { buffer = buf } },
        { 'n', '4', function() quick_select('s') end, { buffer = buf } },
        
        { 'n', 'n', function() quick_select('n') end, { buffer = buf } },
        { 'n', 'q', function() quick_select('q') end, { buffer = buf } },
        { 'n', 'r', function() quick_select('r') end, { buffer = buf } },
        { 'n', 's', function() quick_select('s') end, { buffer = buf } },
        
        -- Выбор
        { 'n', '<CR>', select_current, { buffer = buf } },
        { 'n', '<Space>', select_current, { buffer = buf } },
        
        -- Поиск
        { 'n', '/', search, { buffer = buf } },
        { 'n', '?', search, { buffer = buf } },
        
        -- Быстрая навигация
        { 'n', 'gg', function() 
            current_line = 6
            update_highlight()
        end, { buffer = buf } },
        
        { 'n', 'G', function() 
            current_line = max_line
            update_highlight()
        end, { buffer = buf } },
        
        -- Закрытие
        { 'n', '<ESC>', close_window, { buffer = buf } },
        { 'n', 'Q', close_window, { buffer = buf } },
        { 'n', '<C-c>', close_window, { buffer = buf } },
    }
    
    -- Применяем mappings
    for _, map in ipairs(mappings) do
        vim.api.nvim_buf_set_keymap(buf, map[1], map[2], '', {
            callback = map[3],
            noremap = true,
            silent = true
        })
    end
    
    -- Фокус на окне
    vim.api.nvim_set_current_win(win)
end

return M
