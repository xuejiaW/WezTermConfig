local wezterm = require 'wezterm'
local act = wezterm.action
local platform = require 'platform'

local M = {}

function M.apply_to_config(config)
  config.mouse_bindings = {
    -- Make plain click only complete text selection, and require the platform
    -- primary modifier to open hyperlinks.
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = act.CompleteSelection 'ClipboardAndPrimarySelection',
    },
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = platform.primary_mod,
      action = act.OpenLinkAtMouseCursor,
    },
    {
      event = { Down = { streak = 1, button = 'Left' } },
      mods = platform.primary_mod,
      action = act.Nop,
    },
  }
end

return M
