local wezterm = require 'wezterm'
local agent_deck = wezterm.plugin.require 'https://github.com/Eric162/wezterm-agent-deck'

local M = {}

local OPTIONS = {
  update_interval = 500,
  right_status = {
    components = {
      { type = 'badge', filter = 'waiting', label = 'waiting' },
      { type = 'separator', text = ' | ' },
      { type = 'badge', filter = 'working', label = 'working' },
      { type = 'separator', text = ' | ' },
      { type = 'badge', filter = 'idle', label = 'idle' },
    },
  },
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

return M
