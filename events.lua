local wezterm = require 'wezterm'
local act = wezterm.action

local M = {}
local tab_states = {}
local COMPLETED_ICON = '●'
local COMPLETED_ICON_COLOR = '#98c379'

local function tab_index_prefix(tab, config)
  local index = tab.tab_index
  if not config.tab_and_split_indices_are_zero_based then
    index = index + 1
  end
  return tostring(index) .. ': '
end

local function active_pane_title(tab)
  local pane = tab.active_pane
  if not pane or not pane.title or pane.title == '' then
    return ''
  end
  return pane.title
end

local function split_pane_title(title)
  local prefix, rest = title:match('^(%S+)%s+(.+)$')
  if not prefix then
    return nil, title
  end

  -- Codex uses a leading spinner/symbol in the pane title while work is in
  -- progress or when surfacing status. Ignore regular text titles such as
  -- "Yazi:" or "nvim".
  if prefix:match('[%w]') then
    return nil, title
  end

  return prefix, rest
end

local function tab_state_for(tab)
  local state = tab_states[tab.tab_id]
  if not state then
    state = {
      show_completed = false,
      was_busy = false,
    }
    tab_states[tab.tab_id] = state
  end
  return state
end

function M.apply_to_config(_config)
  -- This registers a custom WezTerm event called "rename-current-tab".
  -- It is not a shell command and does not depend on pwsh being active.
  -- When triggered, WezTerm opens its own PromptInputLine overlay, lets you type
  -- a title, and then renames the current GUI tab via active_tab():set_title().
  -- This is why it still works even when the foreground app is Codex, lazygit,
  -- yazi, vim, or any other full-screen terminal UI.
  wezterm.on('rename-current-tab', function(window, pane)
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

  wezterm.on('format-tab-title', function(tab, _tabs, _panes, config, _hover, max_width)
    local pane_title = active_pane_title(tab)
    local explicit_title = tab.tab_title
    local busy_prefix, pane_title_without_prefix = split_pane_title(pane_title)
    local state = tab_state_for(tab)

    if busy_prefix then
      state.was_busy = true
      state.show_completed = false
    elseif state.was_busy then
      state.was_busy = false
      state.show_completed = true
    end

    local title = explicit_title and explicit_title ~= '' and explicit_title or pane_title_without_prefix
    local elements = {
      { Text = ' ' .. tab_index_prefix(tab, config) },
    }

    if busy_prefix then
      table.insert(elements, { Text = busy_prefix .. ' ' })
    end

    if state.show_completed then
      local reserved = #tab_index_prefix(tab, config) + 4
      local truncated_title = wezterm.truncate_right(title, math.max(max_width - reserved, 1))
      table.insert(elements, { Text = truncated_title .. ' ' })
      table.insert(elements, { Foreground = { Color = COMPLETED_ICON_COLOR } })
      table.insert(elements, { Text = COMPLETED_ICON })
      table.insert(elements, { Foreground = { Color = 'Default' } })
      table.insert(elements, { Text = ' ' })
      return elements
    end

    local reserved = #tab_index_prefix(tab, config) + (busy_prefix and 3 or 2)
    local truncated_title = wezterm.truncate_right(title, math.max(max_width - reserved, 1))
    table.insert(elements, { Text = truncated_title .. ' ' })
    return elements
  end)
end

return M
