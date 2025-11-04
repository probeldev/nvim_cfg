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
        description = "Показать структуры и данные таблиц БД",
        icon = "🏗️",
        key = "s"
    },
    {
        value = "create_config",
        display = "⚙️  Создать конфиг",
        description = "Создать шаблон конфигурационного файла",
        icon = "⚙️",
        key = "c"
    }
}

-- Опции подменю для структуры БД
local structure_menu_options = {
    {
        value = "structure",
        display = "📋 Структура таблицы",
        description = "Показать структуру таблицы (столбцы, типы)",
        icon = "📋",
        key = "s"
    },
    {
        value = "data",
        display = "📊 Данные таблицы",
        description = "Показать данные таблицы (SELECT с лимитом)",
        icon = "📊",
        key = "d"
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
    local height = #menu_options + 9  -- +1 строка для информации о конфиге
    
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = "minimal",
        border = "rounded",
    })
    
    -- Получаем информацию о конфигурации
    local config_info = utils.get_config_info()
    
    -- Заполняем содержимое
    local content = {
        "┌" .. string.rep("─", width - 2) .. "┐",
        "│" .. string.format(" %-81s", "🚀 DB Workflow - Главное меню") .. "│",
        "│" .. string.format(" %-81s", config_info) .. "│",
        "│" .. string.format(" %-81s", "j/k/↑/↓ - навигация, Enter - выбрать, Esc - закрыть") .. "│",
        "├" .. string.rep("─", width - 2) .. "┤",
    }
    
    for i, text in ipairs(display_texts) do
        local option = menu_options[i]
        local line = string.format("│   %-79s │", text)
        table.insert(content, line)
    end
    
    table.insert(content, "├" .. string.rep("─", width - 2) .. "┤")
    table.insert(content, "│" .. string.format(" %-81s", "Enter - выбрать, Esc - закрыть") .. "│")
    table.insert(content, "└" .. string.rep("─", width - 2) .. "┘")
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'dbworkflow_main_menu')
    
    -- Настройка подсветки
    vim.cmd([[
    syntax match DbWorkflowTitle /^│.*🚀 DB Workflow.*│$/
    syntax match DbWorkflowConfig /^│.*📁.*│$/
    syntax match DbWorkflowConfig /^│.*❌.*│$/
    syntax match DbWorkflowHelp /^│.*Выберите действие:.*│$/
    syntax match DbWorkflowHelp /^│.*j.k.↑.↓.*│$/
    syntax match DbWorkflowHelp /^│.*Enter - выбрать.*│$/
    syntax match DbWorkflowBorder /^[┌├└][─]*[┐┤┘]$/
    syntax match DbWorkflowBorder /^│/
    
    highlight link DbWorkflowTitle Title
    highlight link DbWorkflowConfig Comment
    highlight link DbWorkflowHelp Comment
    highlight link DbWorkflowBorder Comment
    ]])
    
    -- Текущая позиция (начинаем с первого пункта меню)
    local current_line = 6
    local max_line = 5 + #display_texts
    
    -- Функция обновления подсветки
    local function update_highlight()
        -- Очищаем предыдущую подсветку
        vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
        
        -- Подсвечиваем текущую строку
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
    
    -- Функция выбора текущего элемента
    local function select_current()
        if current_line >= 6 and current_line <= max_line then
            local selected_text = display_texts[current_line - 5]
            if value_map[selected_text] then
                close_window()
                on_select(value_map[selected_text])
                return true
            end
        end
        return false
    end
    
    -- Инициализация подсветки
    update_highlight()
    
    -- Упрощенные key mappings (без быстрых клавиш)
    local mappings = {
        -- Навигация вниз
        { 'n', 'j', function() 
            if current_line < max_line then
                current_line = current_line + 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        { 'n', '<Down>', function() 
            if current_line < max_line then
                current_line = current_line + 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        -- Навигация вверх
        { 'n', 'k', function() 
            if current_line > 6 then
                current_line = current_line - 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        { 'n', '<Up>', function() 
            if current_line > 6 then
                current_line = current_line - 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        -- Выбор
        { 'n', '<CR>', select_current, { buffer = buf } },
        { 'n', '<Space>', select_current, { buffer = buf } },
        
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
        { 'n', 'q', close_window, { buffer = buf } },
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

-- Подменю для структуры БД
function M.show_structure_submenu(on_select)
    local display_texts = {}
    local value_map = {}
    
    for _, option in ipairs(structure_menu_options) do
        local display_text = format_menu_item(option)
        table.insert(display_texts, display_text)
        value_map[display_text] = option.value
    end
    
    -- Создаем floating window для подменю
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 85
    local height = #structure_menu_options + 7
    
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
        "│" .. string.format(" %-81s", "🏗️  DB Workflow - Просмотр таблиц") .. "│",
        "│" .. string.format(" %-81s", "Выберите тип просмотра:") .. "│",
        "│" .. string.format(" %-81s", "j/k/↑/↓ - навигация, Enter - выбрать, Esc - закрыть") .. "│",
        "├" .. string.rep("─", width - 2) .. "┤",
    }
    
    for i, text in ipairs(display_texts) do
        local line = string.format("│   %-79s │", text)
        table.insert(content, line)
    end
    
    table.insert(content, "├" .. string.rep("─", width - 2) .. "┤")
    table.insert(content, "│" .. string.format(" %-81s", "Enter - выбрать, Esc - закрыть") .. "│")
    table.insert(content, "└" .. string.rep("─", width - 2) .. "┘")
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'dbworkflow_structure_menu')
    
    -- Настройка подсветки
    vim.cmd([[
    syntax match DbWorkflowTitle /^│.*🏗️  DB Workflow.*│$/
    syntax match DbWorkflowHelp /^│.*Выберите тип просмотра:.*│$/
    syntax match DbWorkflowHelp /^│.*j.k.↑.↓.*│$/
    syntax match DbWorkflowHelp /^│.*Enter - выбрать.*│$/
    syntax match DbWorkflowBorder /^[┌├└][─]*[┐┤┘]$/
    syntax match DbWorkflowBorder /^│/
    
    highlight link DbWorkflowTitle Title
    highlight link DbWorkflowHelp Comment
    highlight link DbWorkflowBorder Comment
    ]])
    
    -- Текущая позиция
    local current_line = 6
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
    
    -- Функция выбора текущего элемента
    local function select_current()
        if current_line >= 6 and current_line <= max_line then
            local selected_text = display_texts[current_line - 5]
            if value_map[selected_text] then
                close_window()
                on_select(value_map[selected_text])
                return true
            end
        end
        return false
    end
    
    -- Инициализация подсветки
    update_highlight()
    
    -- Упрощенные key mappings для подменю
    local mappings = {
        -- Навигация вниз
        { 'n', 'j', function() 
            if current_line < max_line then
                current_line = current_line + 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        { 'n', '<Down>', function() 
            if current_line < max_line then
                current_line = current_line + 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        -- Навигация вверх
        { 'n', 'k', function() 
            if current_line > 6 then
                current_line = current_line - 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        { 'n', '<Up>', function() 
            if current_line > 6 then
                current_line = current_line - 1
                update_highlight()
            end
        end, { buffer = buf } },
        
        -- Выбор
        { 'n', '<CR>', select_current, { buffer = buf } },
        { 'n', '<Space>', select_current, { buffer = buf } },
        
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
        { 'n', 'q', close_window, { buffer = buf } },
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
