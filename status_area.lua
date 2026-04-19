local wezterm = require 'wezterm'
local agent_status = require 'agent_status'

local M = {}

local KEY_TABLE_LABELS = {
  copy_mode = ' COPY  h/j/k/l  v select  y copy ',
  resize_panes = ' RESIZE  h/j/k/l ',
  search_mode = ' SEARCH ',
}

local function add_agent_summary(elements)
  local counts = agent_status.counts()
  local waiting = counts.waiting or 0
  local working = counts.working or 0
  local idle = counts.idle or 0
  local has_any = waiting > 0 or working > 0 or idle > 0

  if not has_any then
    return false
  end

  if waiting > 0 then
    table.insert(elements, { Foreground = { Color = agent_status.status_color 'waiting' } })
    table.insert(elements, { Text = string.format(' %s %d waiting ', agent_status.status_icon 'waiting', waiting) })
    table.insert(elements, { Foreground = { Color = 'Default' } })
  end

  if working > 0 then
    table.insert(elements, { Foreground = { Color = agent_status.status_color 'working' } })
    table.insert(elements, { Text = string.format(' %s %d working ', agent_status.status_icon 'working', working) })
    table.insert(elements, { Foreground = { Color = 'Default' } })
  end

  if idle > 0 then
    table.insert(elements, { Foreground = { Color = agent_status.status_color 'idle' } })
    table.insert(elements, { Text = string.format(' %s %d idle ', agent_status.status_icon 'idle', idle) })
    table.insert(elements, { Foreground = { Color = 'Default' } })
  end

  return true
end

function M.apply_to_config(config)
  config.status_update_interval = 250

  wezterm.on('update-status', function(window, _pane)
    agent_status.update_window(window)

    local key_table = window:active_key_table()
    local label = KEY_TABLE_LABELS[key_table]
    local elements = {}

    if label then
      table.insert(elements, { Background = { Color = '#3a3f4b' } })
      table.insert(elements, { Foreground = { Color = '#e5c07b' } })
      table.insert(elements, { Attribute = { Intensity = 'Bold' } })
      table.insert(elements, { Text = label })
      table.insert(elements, { Attribute = { Intensity = 'Normal' } })
      table.insert(elements, { Foreground = { Color = 'Default' } })
    end

    local has_summary = add_agent_summary(elements)

    if #elements == 0 or (not label and not has_summary) then
      window:set_right_status ''
      return
    end

    window:set_right_status(wezterm.format(elements))
  end)
end

return M
