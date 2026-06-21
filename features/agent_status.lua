local wezterm = require 'wezterm'
local agent_deck = wezterm.plugin.require 'https://github.com/Eric162/wezterm-agent-deck'

local M = {}
local pane_status_overrides = {}
local window_override_signatures = {}

local OPTIONS = {
  update_interval = 500,
  tab_title = { enabled = false },
  right_status = { enabled = false },
  notifications = {
    enabled = true,
    on_waiting = true,
  },
  colors = {
    working = '#98c379',
    waiting = '#e5c07b',
    idle = '#61afef',
    inactive = '#5c6370',
  },
  icons = {
    style = 'unicode',
    unicode = {
      working = '●',
      waiting = '◔',
      idle = '○',
      inactive = '◌',
    },
  },
  agents = {
    codex = {
      status_patterns = {
        working = {
          'esc to interrupt',
          'esc interrupt',
          'ctrl%+c to interrupt',
          'waiting for background terminal',
          'running command',
          'running commands',
          'making edits',
          'applying patch',
          'thinking',
          'processing',
          'analyzing',
          'generating',
        },
        waiting = {
          'allow command%?',
          '%[y/n/e/a%]',
          '%[y/N/e/a%]',
          "yes, and don't ask again",
          "don't ask again this session",
          "don't ask again for this command",
          'esc to cancel',
          'do you want to',
          'approve',
          '%(y/n%)',
          '%(Y/n%)',
          '%[y/n%]',
          '%[Y/n%]',
          '%(y/N%)',
          '%(Y/N%)',
          '%[y/N%]',
          '%[Y/N%]',
          'continue%?',
          'proceed%?',
        },
        idle = {
          '^>%s*$',
          '^> $',
          '^>$',
          '^›%s*$',
          'worked for',
        },
      },
    },
    copilot = {
      patterns = { 'copilot' },
      executable_patterns = {
        '/copilot%-cli/',
        '@github/copilot',
        '/homebrew/bin/copilot',
        '/copilot$',
        '^copilot$',
      },
      argv_patterns = {
        '@github/copilot',
        'npx%s+@github/copilot',
        'npx%s+copilot',
        '^copilot%s',
        '^copilot$',
      },
      title_patterns = {
        'github copilot',
        'copilot',
      },
      status_patterns = {
        waiting = {
          'esc to cancel',
          'allow copilot',
          'do you want to',
          'approve',
          '%(y/n%)',
          '%(Y/n%)',
          '%[y/n%]',
          '%[Y/n%]',
          '%(y/N%)',
          '%(Y/N%)',
          '%[y/N%]',
          '%[Y/N%]',
          ' Yes',
          ' No',
          'continue%?',
          'proceed%?',
        },
      },
    },
  },
}

local function pane_id_of(pane)
  if not pane then
    return nil
  end

  local raw_pane_id = pane.pane_id
  if type(raw_pane_id) == 'number' or type(raw_pane_id) == 'string' then
    return raw_pane_id
  end

  local ok, pane_id = pcall(function()
    return pane:pane_id()
  end)

  if ok then
    return pane_id
  end

  return nil
end

local function strip_ansi(text)
  if not text then
    return ''
  end

  local result = text
  result = result:gsub('\27%[%d*;?%d*;?%d*[A-Za-z]', '')
  result = result:gsub('\27%].-\007', '')
  result = result:gsub('\27%].-\27\\', '')
  result = result:gsub('\27%[%?%d+[hl]', '')
  result = result:gsub('\27%[%d*[ABCDEFGJKST]', '')
  result = result:gsub('\27%[%d*;%d*[Hf]', '')
  result = result:gsub('\27%[%d*m', '')
  result = result:gsub('\27%[[0-9;]*m', '')
  result = result:gsub('\r', '')
  return result
end

local function last_lines(text, n)
  local lines = {}
  for line in (text or ''):gmatch('[^\n]+') do
    table.insert(lines, line)
  end

  local start = math.max(1, #lines - n + 1)
  local result = {}
  for i = start, #lines do
    table.insert(result, lines[i])
  end

  return table.concat(result, '\n')
end

local function get_pane_text(pane, max_lines)
  local ok, text = pcall(function()
    return pane:get_lines_as_text(max_lines)
  end)

  if ok and text and text ~= '' then
    return text
  end

  ok, text = pcall(function()
    return pane:get_logical_lines_as_text(max_lines)
  end)

  if ok and text then
    return text
  end

  return ''
end

local function has_in_progress_task(pane)
  local text = strip_ansi(get_pane_text(pane, 80)):lower()
  local recent = last_lines(text, 40)

  return recent:find('%d+%s+tasks?%s*%([^%)]-in progress') ~= nil
end

local function override_status_for_pane(pane)
  local pane_id = pane_id_of(pane)
  if not pane_id then
    return
  end

  local pane_key = tostring(pane_id)
  local state = agent_deck.get_agent_state(pane_id)
  if state and state.status == 'idle' and has_in_progress_task(pane) then
    pane_status_overrides[pane_key] = 'working'
  else
    pane_status_overrides[pane_key] = nil
  end
end

local function override_signature()
  local parts = {}
  for pane_id, status in pairs(pane_status_overrides) do
    table.insert(parts, tostring(pane_id) .. ':' .. tostring(status))
  end
  table.sort(parts)
  return table.concat(parts, '|')
end

local function refresh_overrides(window)
  local seen = {}

  pcall(function()
    for _, tab in ipairs(window:mux_window():tabs()) do
      for _, pane in ipairs(tab:panes()) do
        local pane_id = pane_id_of(pane)
        if pane_id then
          seen[tostring(pane_id)] = true
        end
        override_status_for_pane(pane)
      end
    end
  end)

  for pane_id, _ in pairs(pane_status_overrides) do
    if not seen[pane_id] then
      pane_status_overrides[pane_id] = nil
    end
  end
end

local function default_tab_title(tab)
  local explicit_title = tab.tab_title or ''
  if explicit_title ~= '' then
    return explicit_title
  end

  local pane = tab.active_pane or {}
  local title = pane.title or ''
  if title ~= '' then
    return title
  end

  local process_name = pane.foreground_process_name or ''
  if process_name ~= '' then
    return process_name:match('[/\\]([^/\\]+)$') or process_name
  end

  return 'Terminal'
end

local function tab_index_prefix(tab, wezterm_config)
  local index = tab.tab_index or 0
  if not wezterm_config or not wezterm_config.tab_and_split_indices_are_zero_based then
    index = index + 1
  end

  return tostring(index) .. ': '
end

local function effective_status(pane_id, state)
  return pane_status_overrides[tostring(pane_id)] or state.status or 'inactive'
end

local function status_rank(status)
  if status == 'waiting' then
    return 4
  end
  if status == 'working' then
    return 3
  end
  if status == 'idle' then
    return 2
  end
  return 1
end

local function higher_priority_status(left, right)
  if status_rank(left) >= status_rank(right) then
    return left
  end

  return right
end

local function render_tab_title(tab, wezterm_config)
  local pane_states = {}
  local tab_status = 'inactive'

  for _, pane_info in ipairs(tab.panes or {}) do
    local state = agent_deck.get_agent_state(pane_info.pane_id)
    if state then
      local status = effective_status(pane_info.pane_id, state)
      table.insert(pane_states, {
        pane_id = pane_info.pane_id,
        status = status,
      })

      tab_status = higher_priority_status(tab_status, status)
    end
  end

  if #pane_states == 0 then
    return nil
  end

  local result = { { Text = ' ' } }
  for _, pane_state in ipairs(pane_states) do
    table.insert(result, { Foreground = { Color = M.status_color(pane_state.status) } })
    table.insert(result, { Text = M.status_icon(pane_state.status) })
  end

  table.insert(result, { Foreground = { Color = M.status_color(tab_status) } })
  table.insert(result, {
    Text = ' ' .. tab_index_prefix(tab, wezterm_config) .. default_tab_title(tab) .. ' ',
  })

  return result
end

function M.apply_to_config(config)
  agent_deck.apply_to_config(config, OPTIONS)

  wezterm.on('update-status', function(window, _pane)
    refresh_overrides(window)

    local window_id = window:window_id()
    local signature = override_signature()
    if window_override_signatures[window_id] ~= signature then
      window_override_signatures[window_id] = signature
      window:set_config_overrides(window:get_config_overrides() or {})
    end
  end)

  wezterm.on('format-tab-title', function(tab, _tabs, _panes, wezterm_config)
    return render_tab_title(tab, wezterm_config)
  end)
end

function M.counts()
  local counts = { working = 0, waiting = 0, idle = 0, inactive = 0 }
  for pane_id, state in pairs(agent_deck.get_all_agent_states()) do
    local status = effective_status(pane_id, state)
    counts[status] = (counts[status] or 0) + 1
  end
  return counts
end

function M.status_icon(status)
  return agent_deck.get_status_icon(status)
end

function M.status_color(status)
  return agent_deck.get_status_color(status)
end

return M
