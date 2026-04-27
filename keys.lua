local wezterm = require 'wezterm'
local act = wezterm.action
local platform = require 'platform'
local pane_actions = require 'pane_actions'
local tab_rename = require 'tab_rename'

local M = {}

local function upsert_key_binding(bindings, entry)
    for index, binding in ipairs(bindings) do
        if binding.key == entry.key and binding.mods == entry.mods then
            bindings[index] = entry
            return
        end
    end

    table.insert(bindings, entry)
end

function M.apply_to_config(config)
    local default_key_tables = wezterm.gui.default_key_tables()
    local copy_mode = default_key_tables.copy_mode
    local search_mode = default_key_tables.search_mode
    local tab_close_action = platform.is_windows and act.CloseCurrentTab {
        confirm = true
    } or act.DisableDefaultAssignment
    local fullscreen_mods = platform.is_windows and 'CTRL|SHIFT' or 'CMD|CTRL'
    local primary_shift_mods = platform.primary_mod .. '|SHIFT'
    local move_tab_mods = platform.direct_mods .. '|SHIFT'
    local disable_tab_number_mods = {platform.primary_mod, 'CTRL|SHIFT'}
    local activate_copy_mode_action = act.Multiple {
        act.ActivateCopyMode,
        act.CopyMode 'ClearPattern'
    }

    config.keys = { -- Disable WezTerm's default Alt+Enter fullscreen toggle.
    {
        key = 'Enter',
        mods = 'ALT',
        action = act.DisableDefaultAssignment
    }, -- GUI pane management: direct keys, no WezTerm leader required.
    {
        key = 'v',
        mods = platform.direct_mods,
        action = pane_actions.split_with_current_working_dir 'Right'
    }, {
        key = 'v',
        mods = platform.direct_mods .. '|SHIFT',
        action = pane_actions.split_with_launch_path_or_current_working_dir 'Right'
    }, {
        key = 's',
        mods = platform.direct_mods,
        action = pane_actions.split_with_current_working_dir 'Bottom'
    }, {
        key = 's',
        mods = platform.direct_mods .. '|SHIFT',
        action = pane_actions.split_with_launch_path_or_current_working_dir 'Bottom'
    }, {
        key = 'h',
        mods = platform.direct_mods,
        action = act.ActivatePaneDirection 'Left'
    }, {
        key = 'j',
        mods = platform.direct_mods,
        action = act.ActivatePaneDirection 'Down'
    }, {
        key = 'k',
        mods = platform.direct_mods,
        action = act.ActivatePaneDirection 'Up'
    }, {
        key = 'l',
        mods = platform.direct_mods,
        action = act.ActivatePaneDirection 'Right'
    }, -- On macOS, leave Cmd+W to terminal apps such as Neovim by explicitly
    -- overriding WezTerm's default close-tab binding. Windows keeps Ctrl+W as a
    -- terminal-tab close shortcut.
    {
        key = 't',
        mods = platform.primary_mod,
        action = act.DisableDefaultAssignment
    }, {
        key = 't',
        mods = platform.direct_mods,
        action = act.SpawnTab 'CurrentPaneDomain'
    }, {
        key = 't',
        mods = platform.direct_mods .. '|SHIFT',
        action = act.ShowLauncherArgs {
            flags = 'FUZZY|LAUNCH_MENU_ITEMS',
            title = 'New tab in'
        }
    }, {
        key = 'f',
        mods = fullscreen_mods,
        action = act.ToggleFullScreen
    }, {
        key = 'w',
        mods = platform.primary_mod,
        action = tab_close_action
    }, {
        key = 'w',
        mods = platform.direct_mods,
        action = act.EmitEvent(pane_actions.close_pane_event)
    }, {
        key = 'r',
        mods = platform.direct_mods,
        action = act.EmitEvent(tab_rename.rename_event)
    }, {
        key = 'e',
        mods = platform.direct_mods,
        action = act.ActivateKeyTable {
            name = 'resize_panes',
            one_shot = false,
            timeout_milliseconds = 1500,
            until_unknown = true
        }
    }, {
        key = '[',
        mods = platform.direct_mods,
        action = activate_copy_mode_action
    }, {
        key = 'x',
        mods = 'CTRL|SHIFT',
        action = activate_copy_mode_action
    }, -- Previous/next GUI tab.
    {
        key = 'h',
        mods = primary_shift_mods,
        action = act.ActivateTabRelative(-1)
    }, {
        key = 'l',
        mods = primary_shift_mods,
        action = act.ActivateTabRelative(1)
    }, -- Reorder the current tab with the keyboard.
    {
        key = 'h',
        mods = move_tab_mods,
        action = act.MoveTabRelative(-1)
    }, {
        key = 'l',
        mods = move_tab_mods,
        action = act.MoveTabRelative(1)
    }}

    for i = 1, 9 do
        for _, mods in ipairs(disable_tab_number_mods) do
            table.insert(config.keys, {
                key = tostring(i),
                mods = mods,
                action = act.DisableDefaultAssignment
            })
        end
        table.insert(config.keys, {
            key = tostring(i),
            mods = 'ALT',
            action = act.ActivateTab(i - 1)
        })
    end

    upsert_key_binding(copy_mode, {
        key = 'Escape',
        mods = 'NONE',
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ''

            if has_selection then
                window:perform_action(act.ClearSelection, pane)
                window:perform_action(act.CopyMode 'ClearSelectionMode', pane)
                return
            end

            window:perform_action(act.CopyMode 'Close', pane)
        end)
    })
    upsert_key_binding(copy_mode, {
        key = '/',
        mods = 'NONE',
        action = act.Search 'CurrentSelectionOrEmptyString'
    })
    upsert_key_binding(copy_mode, {
        key = '/',
        mods = 'SHIFT',
        action = act.Search 'CurrentSelectionOrEmptyString'
    })
    upsert_key_binding(copy_mode, {
        key = 'L',
        mods = 'NONE',
        action = act.CopyMode 'MoveToEndOfLineContent'
    })
    upsert_key_binding(copy_mode, {
        key = 'n',
        mods = 'NONE',
        action = act.CopyMode 'PriorMatch'
    })
    upsert_key_binding(copy_mode, {
        key = 'N',
        mods = 'NONE',
        action = act.CopyMode 'NextMatch'
    })

    upsert_key_binding(search_mode, {
        key = 'Enter',
        mods = 'NONE',
        action = act.CopyMode 'AcceptPattern'
    })

    config.key_tables = {
        copy_mode = copy_mode,
        search_mode = search_mode,
        resize_panes = {{
            key = 'h',
            action = act.AdjustPaneSize {'Left', 3}
        }, {
            key = 'j',
            action = act.AdjustPaneSize {'Down', 3}
        }, {
            key = 'k',
            action = act.AdjustPaneSize {'Up', 3}
        }, {
            key = 'l',
            action = act.AdjustPaneSize {'Right', 3}
        }, {
            key = 'Escape',
            action = act.PopKeyTable
        }, {
            key = 'Enter',
            action = act.PopKeyTable
        }}
    }
end

return M
