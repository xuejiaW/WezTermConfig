local wezterm = require 'wezterm'
local agent_status = require 'agent_status'

local M = {}

local KEY_TABLE_LABELS = {
  copy_mode = ' COPY  h/j/k/l  v select  y copy ',
  resize_panes = ' RESIZE  h/j/k/l ',
  search_mode = ' SEARCH ',
}

function M.apply_to_config(config)
  config.status_update_interval = 250

  wezterm.on('update-status', function(window, _pane)
    agent_status.update_window(window)

    local key_table = window:active_key_table()
    local label = KEY_TABLE_LABELS[key_table]

    if not label then
      window:set_right_status ''
      return
    end

    window:set_right_status(wezterm.format {
      { Background = { Color = '#3a3f4b' } },
      { Foreground = { Color = '#e5c07b' } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = label },
    })
  end)
end

return M
