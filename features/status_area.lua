local wezterm = require 'wezterm'
local agent_status = require 'features.agent_status'

local M = {}

local KEY_TABLE_LABELS = {
  copy_mode = ' COPY  h/j/k/l/L  Esc clear/exit  / ? search  n/N match ',
  resize_panes = ' RESIZE  h/j/k/l ',
  search_mode = ' SEARCH  Enter back-to-copy  Ctrl-n/p next-prev ',
}

local function append_agent_badge(elements, status, count, label)
  if count <= 0 then
    return
  end

  table.insert(elements, { Foreground = { Color = agent_status.status_color(status) } })
  table.insert(elements, {
    Text = string.format(' %s %d %s ', agent_status.status_icon(status), count, label),
  })
  table.insert(elements, { Foreground = { Color = 'Default' } })
end

function M.apply_to_config(config)
  config.status_update_interval = 250

  wezterm.on('update-status', function(window, _pane)
    local key_table = window:active_key_table()
    local label = KEY_TABLE_LABELS[key_table]
    local counts = agent_status.counts()
    local waiting = counts.waiting or 0
    local working = counts.working or 0
    local idle = counts.idle or 0
    local elements = {}

    if label then
      table.insert(elements, { Background = { Color = '#3a3f4b' } })
      table.insert(elements, { Foreground = { Color = '#e5c07b' } })
      table.insert(elements, { Attribute = { Intensity = 'Bold' } })
      table.insert(elements, { Text = label })
      table.insert(elements, { Attribute = { Intensity = 'Normal' } })
      table.insert(elements, { Foreground = { Color = 'Default' } })
    end

    append_agent_badge(elements, 'waiting', waiting, 'waiting')
    append_agent_badge(elements, 'working', working, 'working')
    append_agent_badge(elements, 'idle', idle, 'idle')

    if #elements == 0 then
      window:set_right_status ''
      return
    end

    window:set_right_status(wezterm.format(elements))
  end)
end

return M
