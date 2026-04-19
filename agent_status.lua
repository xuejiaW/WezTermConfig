local wezterm = require 'wezterm'
local agent_deck = wezterm.plugin.require 'https://github.com/Eric162/wezterm-agent-deck'

local M = {}

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
}

local function pane_id_of(pane)
  if pane.pane_id then
    return pane.pane_id
  end

  local ok, pane_id = pcall(function()
    return pane:pane_id()
  end)

  return ok and pane_id or nil
end

function M.apply_to_config(_config)
  agent_deck.setup(OPTIONS)
end

function M.update_window(window)
  for _, mux_tab in ipairs(window:mux_window():tabs()) do
    for _, pane in ipairs(mux_tab:panes()) do
      agent_deck.update_pane(pane)
    end
  end
end

function M.tab_states(panes)
  local states = {}

  for _, pane in ipairs(panes or {}) do
    local pane_id = pane_id_of(pane)
    if pane_id then
      local state = agent_deck.get_agent_state(pane_id)
      if state then
        table.insert(states, {
          pane_id = pane_id,
          agent_type = state.agent_type,
          status = state.status,
        })
      end
    end
  end

  return states
end

function M.counts()
  return agent_deck.count_agents_by_status()
end

function M.status_icon(status)
  return agent_deck.get_status_icon(status)
end

function M.status_color(status)
  return agent_deck.get_status_color(status)
end

return M
