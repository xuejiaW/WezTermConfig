local wezterm = require 'wezterm'

local is_windows = wezterm.target_triple:find('windows') ~= nil
local primary_mod = is_windows and 'CTRL' or 'CMD'

return {
  is_windows = is_windows,
  primary_mod = primary_mod,
  direct_mods = primary_mod .. '|ALT',
}
