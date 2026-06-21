local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}
M.rename_event = 'rename-current-tab'

function M.apply_to_config(_config)
  wezterm.on(M.rename_event, function(window, pane)
    window:perform_action(
      act.PromptInputLine {
        description = 'Rename current tab',
        action = wezterm.action_callback(function(win, _, line)
          if line and line ~= '' then
            win:active_tab():set_title(line)
          end
        end),
      },
      pane
    )
  end)
end

return M
