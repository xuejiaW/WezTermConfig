local wezterm = require 'wezterm'
local act = wezterm.action
local platform = require 'platform'
local pane_actions = require 'pane_actions'
local tab_rename = require 'tab_rename'

local M = {}

function M.apply_to_config(config)
    local tab_close_action = platform.is_windows and act.CloseCurrentTab {
        confirm = true
    } or act.DisableDefaultAssignment
    local primary_shift_mods = platform.primary_mod .. '|SHIFT'
    local move_tab_mods = platform.direct_mods .. '|SHIFT'
    local disable_tab_number_mods = {platform.primary_mod, 'CTRL|SHIFT'}

    config.keys = { -- Disable WezTerm's default Alt+Enter fullscreen toggle.
    {
        key = 'Enter',
        mods = 'ALT',
        action = act.DisableDefaultAssignment
    }, -- GUI pane management: direct keys, no WezTerm leader required.
    {
        key = 'v',
        mods = platform.direct_mods,
        action = act.SplitPane {
            direction = 'Right',
            size = {
                Percent = 50
            }
        }
    }, {
        key = 's',
        mods = platform.direct_mods,
        action = act.SplitPane {
            direction = 'Down',
            size = {
                Percent = 50
            }
        }
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
        action = act.SpawnTab 'CurrentPaneDomain'
    }, {
        key = 'w',
        mods = platform.primary_mod,
        action = tab_close_action
    }, {
        key = 'x',
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
        action = act.ActivateCopyMode
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

    config.key_tables = {
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
