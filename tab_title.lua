local wezterm = require 'wezterm'
local agent_status = require 'agent_status'

local M = {}

local function is_non_empty(value)
  return type(value) == 'string' and value ~= ''
end

local function tab_index_prefix(tab, config)
  local index = tab.tab_index
  if not config.tab_and_split_indices_are_zero_based then
    index = index + 1
  end
  return tostring(index) .. ': '
end

local function percent_decode(text)
  return text:gsub('%%(%x%x)', function(hex)
    return string.char(tonumber(hex, 16))
  end)
end

local function cwd_path(pane)
  if not pane or not pane.current_working_dir then
    return nil
  end

  local cwd = pane.current_working_dir
  local value = cwd.file_path or cwd.path or tostring(cwd)
  if not is_non_empty(value) then
    return nil
  end

  if value:match('^file://') then
    value = value:match('^file://[^/]*(/.*)$') or value
  end

  return percent_decode(value)
end

local function basename(path)
  if not is_non_empty(path) then
    return nil
  end

  local normalized = path:gsub('[\\/]+$', '')
  if normalized == '' then
    return path
  end

  return normalized:match('([^/\\]+)$') or normalized
end

local function normalized_pane_title(pane)
  local title = pane and pane.title or ''
  if not is_non_empty(title) then
    return nil
  end

  local prefix, rest = title:match('^(%S+)%s+(.+)$')
  if prefix and not prefix:match('[%w]') then
    return rest
  end

  return title
end

local function resolved_title(tab)
  local pane = tab.active_pane
  local explicit_title = tab.tab_title
  if is_non_empty(explicit_title) then
    return explicit_title
  end

  local pane_title = normalized_pane_title(pane)
  if is_non_empty(pane_title) then
    return pane_title
  end

  local cwd_name = basename(cwd_path(pane))
  if is_non_empty(cwd_name) then
    return cwd_name
  end

  return 'shell'
end

local function append_state_markers(elements, states)
  for _, state in ipairs(states) do
    table.insert(elements, {
      Foreground = { Color = agent_status.status_color(state.status) },
    })
    table.insert(elements, {
      Text = agent_status.status_icon(state.status),
    })
    table.insert(elements, {
      Foreground = { Color = 'Default' },
    })
  end
end

function M.apply_to_config(_config)
  wezterm.on('format-tab-title', function(tab, _tabs, panes, config, _hover, max_width)
    local prefix = ' ' .. tab_index_prefix(tab, config)
    local title = resolved_title(tab)
    local states = agent_status.tab_states(panes)
    local reserved = #prefix + 1 + (#states * 2)
    local truncated_title = wezterm.truncate_right(title, math.max(max_width - reserved, 1))

    local elements = {
      { Text = prefix },
      { Text = truncated_title .. ' ' },
    }

    if #states > 0 then
      append_state_markers(elements, states)
      table.insert(elements, { Text = ' ' })
    end

    return elements
  end)
end

return M
