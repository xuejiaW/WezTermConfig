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
