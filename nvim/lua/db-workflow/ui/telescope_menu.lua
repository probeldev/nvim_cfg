local M = {}

local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
    return M
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local config = require("db-workflow.core.config")
local utils = require("db-workflow.core.utils")

-- Главное меню
M.main_menu_items = {
    {
        value = "new_query",
        display = "🆕 Новый запрос",
        description = "Создать новый SQL запрос в буфере",
        ordinal = "1_new_query"
    },
    {
        value = "run_query", 
        display = "📝 Выполнить запрос",
        description = "Выполнить SQL запрос с форматированием",
        ordinal = "2_run_query"
    },
    {
        value = "run_raw_query",
        display = "⚡ Выполнить запрос (RAW)",
        description = "Выполнить SQL запрос без форматирования", 
        ordinal = "3_run_raw_query"
    },
    {
        value = "show_structure",
        display = "🏗️  Показать структуру БД",
        description = "Показать структуры и данные таблиц БД",
        ordinal = "4_show_structure"
    },
    {
        value = "show_procedure", 
        display = "🔄 Показать хранимые процедуры",
        description = "Показать структуры хранимых процедур",
        ordinal = "5_show_procedure"
    },
    {
        value = "create_config",
        display = "⚙️  Создать конфиг",
        description = "Создать шаблон конфигурационного файла",
        ordinal = "6_create_config"
    }
}

-- Меню структуры БД
M.structure_menu_items = {
    {
        value = "structure",
        display = "📋 Структура таблицы",
        description = "Показать структуру таблицы (столбцы, типы)",
        ordinal = "1_structure"
    },
    {
        value = "data",
        display = "📊 Данные таблицы", 
        description = "Показать данные таблицы (SELECT с лимитом)",
        ordinal = "2_data"
    }
}

-- Форматирование отображения в Telescope
local function display_formatter(item)
    return item.display
end

-- Главное меню через Telescope
function M.show_main_menu(on_select)
    local config_info = utils.get_config_info()
    
    pickers.new({}, {
        prompt_title = "🚀 DB Workflow - " .. config_info,
        finder = finders.new_table({
            results = M.main_menu_items,
            entry_maker = function(entry)
                return {
                    value = entry.value,
                    display = display_formatter(entry),
                    ordinal = entry.ordinal
                }
            end
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    on_select(selection.value)
                end
            end)
            return true
        end,
    }):find()
end

-- Меню структуры через Telescope
function M.show_structure_menu(on_select)
    pickers.new({}, {
        prompt_title = "🏗️  DB Workflow - Просмотр таблиц",
        finder = finders.new_table({
            results = M.structure_menu_items,
            entry_maker = function(entry)
                return {
                    value = entry.value,
                    display = display_formatter(entry),
                    ordinal = entry.ordinal
                }
            end
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    on_select(selection.value)
                end
            end)
            return true
        end,
    }):find()
end

-- Picker для таблиц с улучшенным отображением
function M.show_table_picker(actions_list, title, on_select)
    if not actions_list or #actions_list == 0 then
        utils.warn("Нет доступных элементов для отображения")
        return
    end

    -- Обогащаем данные иконками
    local enriched_actions = {}
    for _, action in ipairs(actions_list) do
        local table_type = M.get_table_type(action.value)
        local icon = M.get_table_icon(table_type)
        
        table.insert(enriched_actions, {
            value = action.value,
            display = string.format("%s %s", icon, action.value),
            ordinal = action.value
        })
    end

    -- Сортируем по имени
    table.sort(enriched_actions, function(a, b)
        return a.value < b.value
    end)

    pickers.new({}, {
        prompt_title = title,
        finder = finders.new_table({
            results = enriched_actions,
            entry_maker = function(entry)
                return {
                    value = entry.value,
                    display = entry.display,
                    ordinal = entry.ordinal
                }
            end
        }),
        sorter = conf.generic_sorter({}),
        previewer = nil,
        layout_config = {
            width = 0.8,
            height = 0.6
        },
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                    on_select(selection.value)
                end
            end)
            return true
        end,
    }):find()
end

-- Вспомогательные функции для определения типа таблицы
function M.get_table_type(table_name)
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

function M.get_table_icon(table_type)
    local icons = {
        table = "📊",
        view = "👁️",
        function_ = "⚙️",
        procedure = "🔄",
        log = "📝",
        system = "⚡",
        default = "🗂️"
    }
    return icons[table_type] or icons.default
end

return M
