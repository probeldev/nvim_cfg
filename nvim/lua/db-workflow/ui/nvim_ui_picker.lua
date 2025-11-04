local M = {}

local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")

-- Иконки для разных типов таблиц
local icons = {
    table = "📊",
    view = "👁️",
    function_ = "⚙️",
    procedure = "🔄",
    log = "📝",
    system = "⚡",
    default = "🗂️"
}

-- Определяем тип таблицы по имени для подбора иконки
local function get_table_type(table_name)
    local lower_name = table_name:lower()
    
    if lower_name:match("log") or lower_name:match("_logs") then
        return "log"
    elseif lower_name:match("view") or lower_name:match("_v") then
        return "view"
    elseif lower_name:match("func") or lower_name:match("_fn") then
        return "function_"
    elseif lower_name:match("proc") or lower_name:match("_sp") then
        return "procedure"
    elseif lower_name:match("sys") or lower_name:match("_sys") then
        return "system"
    else
        return "table"
    end
end

-- Красивое форматирование пунктов меню
local function format_menu_item(table_name)
    local table_type = get_table_type(table_name)
    local icon = icons[table_type] or icons.default
    
    -- Добавляем описание в зависимости от типа
    local descriptions = {
        table = "Таблица данных",
        view = "Представление", 
        function_ = "Функция",
        procedure = "Хранимая процедура",
        log = "Логи",
        system = "Системная таблица",
        default = "Объект базы данных"
    }
    
    local description = descriptions[table_type] or descriptions.default
    
    return string.format("%s %-25s %s", icon, table_name, description)
end

-- Основная функция с гарантированной навигацией
function M.show_actions(actions, on_select)
    if not actions or #actions == 0 then
        utils.warn("Нет доступных таблиц для отображения")
        return
    end
    
    -- Форматируем пункты меню
    local formatted_items = {}
    for _, action in ipairs(actions) do
        table.insert(formatted_items, {
            value = action.value,
            display = format_menu_item(action.value),
            ordinal = action.value
        })
    end
    
    -- Сортируем по имени для удобства
    table.sort(formatted_items, function(a, b)
        return a.value < b.value
    end)
    
    -- Создаем display тексты для vim.ui.select
    local display_texts = {}
    local value_map = {}
    
    for _, item in ipairs(formatted_items) do
        table.insert(display_texts, item.display)
        value_map[item.display] = item.value
    end
    
    -- Используем улучшенные настройки с явным указанием kind
    vim.ui.select(display_texts, {
        prompt = "🗃️  Database Tables:",
        format_item = function(item)
            return item
        end,
        kind = "dbworkflow_selector"
    }, function(selected, idx)
        if selected and value_map[selected] then
            on_select(value_map[selected])
        else
            utils.notify("Выбор отменен", vim.log.levels.INFO)
        end
    end)
end

-- Альтернатива: кастомная floating window с гарантированной навигацией
function M.show_actions_floating(actions, on_select)
    if not actions or #actions == 0 then
        utils.warn("Нет доступных таблиц для отображения")
        return
    end
    
    -- Подготавливаем данные
    local display_texts = {}
    local value_map = {}
    
    for _, action in ipairs(actions) do
        local display_text = format_menu_item(action.value)
        table.insert(display_texts, display_text)
        value_map[display_text] = action.value
    end
    
    table.sort(display_texts)
    
    -- Создаем буфер и окно
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 80
    local height = math.min(#display_texts + 6, 25)
    
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
        "│" .. string.format(" %-76s", "🗃️  Database Tables") .. "│",
        "│" .. string.format(" %-76s", "Use j/k or ↑/↓ to navigate, / to search") .. "│",
        "│" .. string.format(" %-76s", "Enter to select, Esc/q to close") .. "│",
        "├" .. string.rep("─", width - 2) .. "┤",
    }
    
    for _, text in ipairs(display_texts) do
        table.insert(content, "│ " .. text .. string.rep(" ", width - #text - 3) .. "│")
    end
    
    table.insert(content, "├" .. string.rep("─", width - 2) .. "┤")
    table.insert(content, "│" .. string.format(" %-76s", "Found " .. #display_texts .. " tables") .. "│")
    table.insert(content, "└" .. string.rep("─", width - 2) .. "┘")
    
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'dbworkflow_menu')
    
    -- Настройка подсветки
    vim.cmd([[
    syntax match DbWorkflowTitle /^│.*🗃️.*│$/
    syntax match DbWorkflowHelp /^│.*Use j.k.*│$/
    syntax match DbWorkflowHelp /^│.*Enter to select.*│$/
    syntax match DbWorkflowStats /^│.*Found.*tables.*│$/
    syntax match DbWorkflowBorder /^[┌├└][─]*[┐┤┘]$/
    syntax match DbWorkflowBorder /^│/
    
    highlight link DbWorkflowTitle Title
    highlight link DbWorkflowHelp Comment
    highlight link DbWorkflowStats Number
    highlight link DbWorkflowBorder Comment
    ]])
    
    -- Текущая позиция (начинаем с первого элемента)
    local current_line = 6  -- Первый элемент данных
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
    
    -- Функция поиска
    local function search()
        vim.api.nvim_win_close(win, true)  -- Временно закрываем окно
        
        vim.fn.inputsave()
        local pattern = vim.fn.input("Search table: ")
        vim.fn.inputrestore()
        
        if pattern and pattern ~= "" then
            -- Ищем совпадение
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
        
        -- Выбор
        { 'n', '<CR>', function() 
            select_current()
        end, { buffer = buf } },
        
        { 'n', '<Space>', function() 
            select_current()
        end, { buffer = buf } },
        
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

-- Умная функция выбора реализации
function M.show_actions_best(actions, on_select)
    -- Всегда используем floating window для гарантированной навигации
    return M.show_actions_floating(actions, on_select)
end

return M
