local wezterm = require 'wezterm'
local config = wezterm.config_builder()

require('appearance').apply_to_config(config)
require('shell').apply_to_config(config)
require('agent_status').apply_to_config(config)
require('tab_rename').apply_to_config(config)
require('mouse').apply_to_config(config)
require('pane_actions').apply_to_config(config)
require('keys').apply_to_config(config)

return config
