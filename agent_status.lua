local wezterm = require 'wezterm'
local agent_deck = wezterm.plugin.require 'https://github.com/Eric162/wezterm-agent-deck'

local M = {}

local OPTIONS = {
  update_interval = 500,
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

function M.apply_to_config(config)
  agent_deck.apply_to_config(config, OPTIONS)
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
